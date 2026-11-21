package com.warden.brain;

import android.content.Context;
import android.content.SharedPreferences;
import com.google.mediapipe.tasks.genai.llminference.LlmInference;
import com.google.mediapipe.tasks.genai.llminference.LlmInferenceSession;
import com.google.mediapipe.tasks.genai.llminference.PromptTemplates;
import java.io.File;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * WardenCB'nin internetsiz beyni: telefona indirilen modeli yükler ve çalıştırır.
 * Model: Qwen2.5-1.5B-Instruct (Apache 2.0), MediaPipe/LiteRT biçiminde (~1,6 GB).
 */
public final class Brain {
    public static final String MODEL_URL =
        "https://huggingface.co/litert-community/Qwen2.5-1.5B-Instruct/resolve/main/Qwen2.5-1.5B-Instruct_multi-prefill-seq_q8_ekv4096.task";
    public static final long MODEL_SIZE = 1598556720L;
    public static final String MODEL_NAME = "Qwen2.5 1.5B";
    static final int MAX_TOKENS = 4096;

    public interface Listener {
        void partial(String textSoFar);
        void done(String text);
        void error(String message);
    }

    private static Brain instance;
    private final Context app;
    private final ExecutorService worker = Executors.newSingleThreadExecutor();
    private LlmInference llm;
    private volatile boolean loading = false;
    private volatile boolean busy = false;
    private volatile String backend = "";
    private LlmInferenceSession current;

    private Brain(Context c) { app = c.getApplicationContext(); }

    public static synchronized Brain get(Context c) {
        if (instance == null) instance = new Brain(c);
        return instance;
    }

    public File modelFile() {
        File dir = app.getExternalFilesDir(null);
        if (dir == null) dir = app.getFilesDir();
        return new File(dir, "wardencb-model.task");
    }

    public boolean isDownloaded() {
        File f = modelFile();
        // İndirme bitmiş ama Beyin açılmadan önce: geçici dosyayı yerine koy
        File part = new File(f.getParentFile(), "wardencb-model.part");
        if (!f.exists() && part.exists() && part.length() >= MODEL_SIZE - 1024) part.renameTo(f);
        return f.exists() && f.length() >= MODEL_SIZE - 1024;
    }

    public synchronized boolean isLoaded() { return llm != null; }
    public boolean isLoading() { return loading; }
    public boolean isBusy() { return busy; }
    public String backend() { return backend; }

    private SharedPreferences prefs() { return app.getSharedPreferences("brain", Context.MODE_PRIVATE); }

    /** Modeli belleğe yükler. Önce hızlı GPU denenir; GPU'da çökerse sonraki açılışta CPU kullanılır. */
    private synchronized void ensureLoaded() throws Exception {
        if (llm != null) return;
        if (!isDownloaded()) throw new IllegalStateException("Model henüz indirilmedi. WardenCB Beyin uygulamasını açıp modeli indir.");
        loading = true;
        try {
            SharedPreferences p = prefs();
            boolean gpuCrashedBefore = p.getBoolean("gpu_trying", false);
            boolean useGpu = !gpuCrashedBefore && !p.getBoolean("gpu_bad", false);
            if (gpuCrashedBefore) p.edit().putBoolean("gpu_bad", true).putBoolean("gpu_trying", false).commit();
            if (useGpu) {
                p.edit().putBoolean("gpu_trying", true).commit();
                try {
                    llm = create(LlmInference.Backend.GPU);
                    backend = "GPU";
                } catch (Throwable t) {
                    p.edit().putBoolean("gpu_bad", true).commit();
                } finally {
                    p.edit().putBoolean("gpu_trying", false).commit();
                }
            }
            if (llm == null) {
                llm = create(LlmInference.Backend.CPU);
                backend = "CPU";
            }
        } finally {
            loading = false;
        }
    }

    private LlmInference create(LlmInference.Backend b) {
        LlmInference.LlmInferenceOptions opts = LlmInference.LlmInferenceOptions.builder()
            .setModelPath(modelFile().getAbsolutePath())
            .setMaxTokens(MAX_TOKENS)
            .setMaxTopK(40)
            .setPreferredBackend(b)
            .build();
        return LlmInference.createFromOptions(app, opts);
    }

    /** Hazırlanmış (ChatML biçimli) metni çalıştırır; parça parça ve sonunda tamamını bildirir */
    public void generate(String prompt, float temperature, Listener l) {
        if (busy) { l.error("WardenCB şu an başka bir soruyu düşünüyor, biraz bekle."); return; }
        busy = true;
        worker.execute(() -> {
            StringBuilder out = new StringBuilder();
            try {
                ensureLoaded();
                // Şablonu biz hazırlıyoruz (ChatML); kütüphane ayrıca eklemesin
                PromptTemplates none = PromptTemplates.builder().setUserPrefix("").setUserSuffix("").setModelPrefix("")
                    .setModelSuffix("").setSystemPrefix("").setSystemSuffix("").build();
                LlmInferenceSession.LlmInferenceSessionOptions so = LlmInferenceSession.LlmInferenceSessionOptions.builder()
                    .setTemperature(temperature).setTopK(40).setTopP(0.95f).setPromptTemplates(none).build();
                LlmInferenceSession s = LlmInferenceSession.createFromOptions(llm, so);
                synchronized (this) { current = s; }
                s.addQueryChunk(prompt);
                final Object lock = new Object();
                final boolean[] finished = { false };
                s.generateResponseAsync((part, done) -> {
                    if (part != null) out.append(part);
                    String t = clean(out.toString());
                    if (done) { synchronized (lock) { finished[0] = true; lock.notifyAll(); } }
                    else l.partial(t);
                });
                synchronized (lock) { while (!finished[0]) lock.wait(250); }
                synchronized (this) { current = null; }
                s.close();
                l.done(clean(out.toString()));
            } catch (Throwable t) {
                String m = t.getMessage() == null ? t.toString() : t.getMessage();
                l.error(m.contains("indirilmedi") ? m : "Model çalıştırılamadı: " + m);
            } finally {
                busy = false;
            }
        });
    }

    public void cancel() {
        synchronized (this) { if (current != null) try { current.cancelGenerateResponseAsync(); } catch (Throwable ignored) {} }
    }

    /** Belleği boşalt (Beyin uygulamasından "modeli sil" için) */
    public synchronized void unload() {
        if (llm != null) { try { llm.close(); } catch (Throwable ignored) {} llm = null; }
    }

    static String clean(String s) {
        int i = s.indexOf("<|im_end|>");
        if (i >= 0) s = s.substring(0, i);
        return s.replace("<|im_start|>", "").replace("<|endoftext|>", "");
    }
}
