package com.warden.brain;

import android.app.Activity;
import android.app.DownloadManager;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Color;
import android.graphics.Typeface;
import android.graphics.drawable.GradientDrawable;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.os.StatFs;
import android.view.Gravity;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.ScrollView;
import android.widget.TextView;
import java.io.File;
import java.util.Locale;

/** WardenCB Beyin: modeli indirir, durumu gösterir, deneme sorusu sordurur. Warden Motion ile aynı renkler. */
public class MainActivity extends Activity {
    private static final int BG = Color.parseColor("#0F1834"), CARD = Color.parseColor("#1E2A55"), LINE = Color.parseColor("#2C3E78");
    private static final int TEXT = Color.parseColor("#DCE9FF"), TEXT2 = Color.parseColor("#8FA6D6"), TURQ = Color.parseColor("#22D3C5"), NAVY = Color.parseColor("#0B1430");

    private final Handler ui = new Handler(Looper.getMainLooper());
    private TextView status, testOut;
    private ProgressBar bar;
    private Button dlBtn, delBtn, testBtn;
    private EditText testIn;
    private long downloadId = -1;

    @Override
    protected void onCreate(Bundle b) {
        super.onCreate(b);
        getWindow().setStatusBarColor(BG);
        getWindow().setNavigationBarColor(BG);
        downloadId = getSharedPreferences("brain", MODE_PRIVATE).getLong("dl", -1);

        ScrollView sv = new ScrollView(this);
        sv.setBackgroundColor(BG);
        LinearLayout root = col();
        root.setPadding(dp(20), dp(28), dp(20), dp(28));
        sv.addView(root);

        LinearLayout head = new LinearLayout(this);
        head.setGravity(Gravity.CENTER_VERTICAL);
        ImageView icon = new ImageView(this);
        icon.setImageResource(R.mipmap.ic_launcher);
        head.addView(icon, new LinearLayout.LayoutParams(dp(64), dp(64)));
        LinearLayout ht = col();
        ht.setPadding(dp(14), 0, 0, 0);
        ht.addView(text("WardenCB Beyin", 22, TEXT, true));
        ht.addView(text("İnternetsiz yapay zekâ · Warden Motion için", 13, TEXT2, false));
        head.addView(ht);
        root.addView(head);

        LinearLayout c1 = card(root);
        c1.addView(text("Model", 16, TEXT, true));
        c1.addView(text(Brain.MODEL_NAME + " · yaklaşık 1,6 GB. Bir kere indirilir, sonra internetsiz çalışır. Wi‑Fi ile indirmen önerilir.", 13, TEXT2, false));
        status = text("", 14, TEXT, false);
        status.setPadding(0, dp(8), 0, dp(4));
        c1.addView(status);
        bar = new ProgressBar(this, null, android.R.attr.progressBarStyleHorizontal);
        bar.setMax(1000);
        bar.getProgressDrawable().setTint(TURQ);
        c1.addView(bar, new LinearLayout.LayoutParams(-1, dp(10)));
        dlBtn = button("Modeli indir", true);
        dlBtn.setOnClickListener(v -> startDownload());
        c1.addView(dlBtn);
        delBtn = button("Modeli sil (yer aç)", false);
        delBtn.setOnClickListener(v -> deleteModel());
        c1.addView(delBtn);

        LinearLayout c2 = card(root);
        c2.addView(text("Dene", 16, TEXT, true));
        testIn = new EditText(this);
        testIn.setTextColor(TEXT);
        testIn.setHintTextColor(TEXT2);
        testIn.setHint("WardenCB'ye bir şey sor…");
        testIn.setText("Merhaba! Kendini bir cümleyle tanıtır mısın?");
        testIn.setBackground(round(NAVY, LINE, 12));
        testIn.setPadding(dp(12), dp(10), dp(12), dp(10));
        c2.addView(testIn, lp(dp(8)));
        testBtn = button("Sor", true);
        testBtn.setOnClickListener(v -> test());
        c2.addView(testBtn);
        testOut = text("", 14, TEXT, false);
        testOut.setPadding(0, dp(8), 0, 0);
        c2.addView(testOut);

        LinearLayout c3 = card(root);
        c3.addView(text("Nasıl kullanılır?", 16, TEXT, true));
        c3.addView(text("Model indikten sonra Warden Motion'da sağ üstteki WardenCB'ye dokun. Ayarlarda \"İnternetsiz (WardenCB Beyin)\" seçili olsun. Sorularını ve video isteklerini bu telefonun içinde, internetsiz cevaplar. Bu uygulamayı kapatsan da çalışır.", 13, TEXT2, false));

        setContentView(sv);
        refresh();
    }

    private void refresh() {
        Brain br = Brain.get(this);
        boolean has = br.isDownloaded();
        int st = dlState();
        boolean downloading = st == DownloadManager.STATUS_RUNNING || st == DownloadManager.STATUS_PENDING || st == DownloadManager.STATUS_PAUSED;
        if (st == DownloadManager.STATUS_SUCCESSFUL && !has) finishDownload();
        has = br.isDownloaded();
        if (has) {
            status.setText("✔ Model hazır" + (br.isLoaded() ? " · bellekte (" + br.backend() + ")" : ""));
            bar.setProgress(1000);
        } else if (downloading) {
            long[] p = dlProgress();
            bar.setProgress(p[1] > 0 ? (int) (p[0] * 1000 / p[1]) : 0);
            status.setText(String.format(Locale.forLanguageTag("tr"), "İndiriliyor… %%%d  (%s / %s)%s", p[1] > 0 ? p[0] * 100 / p[1] : 0, mb(p[0]), mb(p[1] > 0 ? p[1] : Brain.MODEL_SIZE), st == DownloadManager.STATUS_PAUSED ? " · bağlantı bekleniyor" : ""));
        } else if (st == DownloadManager.STATUS_FAILED) {
            status.setText("İndirme yarıda kaldı. Tekrar dene.");
            bar.setProgress(0);
        } else {
            status.setText("Model indirilmedi.");
            bar.setProgress(0);
        }
        dlBtn.setVisibility(has || downloading ? View.GONE : View.VISIBLE);
        delBtn.setVisibility(has ? View.VISIBLE : View.GONE);
        testBtn.setEnabled(has);
        testBtn.setAlpha(has ? 1f : 0.4f);
        if (downloading) ui.postDelayed(this::refresh, 1000);
    }

    private void startDownload() {
        File f = Brain.get(this).modelFile();
        File dir = f.getParentFile();
        long free = new StatFs(dir.getAbsolutePath()).getAvailableBytes();
        if (free < Brain.MODEL_SIZE + 200_000_000L) {
            status.setText("Telefonda yeterli yer yok. En az " + mb(Brain.MODEL_SIZE + 200_000_000L) + " boş alan lazım (şu an " + mb(free) + ").");
            return;
        }
        DownloadManager dm = (DownloadManager) getSystemService(Context.DOWNLOAD_SERVICE);
        DownloadManager.Request r = new DownloadManager.Request(Uri.parse(Brain.MODEL_URL));
        r.setTitle("WardenCB Beyin modeli");
        r.setDescription("İnternetsiz yapay zekâ (" + Brain.MODEL_NAME + ")");
        r.setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED);
        r.setDestinationInExternalFilesDir(this, null, "wardencb-model.part");
        r.setAllowedOverMetered(true);
        r.setAllowedOverRoaming(false);
        new File(dir, "wardencb-model.part").delete();
        downloadId = dm.enqueue(r);
        getSharedPreferences("brain", MODE_PRIVATE).edit().putLong("dl", downloadId).apply();
        refresh();
    }

    private void finishDownload() {
        File dir = Brain.get(this).modelFile().getParentFile();
        File part = new File(dir, "wardencb-model.part");
        if (part.exists() && part.length() >= Brain.MODEL_SIZE - 1024) part.renameTo(Brain.get(this).modelFile());
    }

    private int dlState() {
        if (downloadId < 0) return -1;
        DownloadManager dm = (DownloadManager) getSystemService(Context.DOWNLOAD_SERVICE);
        try (Cursor c = dm.query(new DownloadManager.Query().setFilterById(downloadId))) {
            if (c != null && c.moveToFirst()) return c.getInt(c.getColumnIndexOrThrow(DownloadManager.COLUMN_STATUS));
        } catch (Exception ignored) {}
        return -1;
    }

    private long[] dlProgress() {
        DownloadManager dm = (DownloadManager) getSystemService(Context.DOWNLOAD_SERVICE);
        try (Cursor c = dm.query(new DownloadManager.Query().setFilterById(downloadId))) {
            if (c != null && c.moveToFirst()) return new long[] {
                c.getLong(c.getColumnIndexOrThrow(DownloadManager.COLUMN_BYTES_DOWNLOADED_SO_FAR)),
                c.getLong(c.getColumnIndexOrThrow(DownloadManager.COLUMN_TOTAL_SIZE_BYTES)) };
        } catch (Exception ignored) {}
        return new long[] { 0, 0 };
    }

    private void deleteModel() {
        Brain.get(this).unload();
        Brain.get(this).modelFile().delete();
        getSharedPreferences("brain", MODE_PRIVATE).edit().remove("dl").apply();
        downloadId = -1;
        refresh();
    }

    private void test() {
        String q = testIn.getText().toString().trim();
        if (q.isEmpty()) return;
        testBtn.setEnabled(false);
        testOut.setText("Düşünüyorum… (ilk seferde model belleğe yüklenir, biraz sürebilir)");
        long t0 = System.currentTimeMillis();
        String prompt = "<|im_start|>system\nSen WardenCB'sin: Warden Motion animasyon uygulamasının neşeli asistanı. Kısa ve Türkçe cevap ver.<|im_end|>\n<|im_start|>user\n" + q + "<|im_end|>\n<|im_start|>assistant\n";
        Brain.get(this).generate(prompt, 0.7f, new Brain.Listener() {
            @Override public void partial(String t) { ui.post(() -> testOut.setText(t)); }
            @Override public void done(String t) { ui.post(() -> { testOut.setText(t + "\n\n⏱ " + (System.currentTimeMillis() - t0) / 100 / 10.0 + " sn"); testBtn.setEnabled(true); refresh(); }); }
            @Override public void error(String m) { ui.post(() -> { testOut.setText("⚠ " + m); testBtn.setEnabled(true); }); }
        });
    }

    @Override protected void onResume() { super.onResume(); refresh(); }

    // ---------- görünüm yardımcıları ----------
    private int dp(int v) { return Math.round(v * getResources().getDisplayMetrics().density); }
    private static String mb(long b) { return b >= 1_000_000_000L ? String.format(Locale.forLanguageTag("tr"), "%.1f GB", b / 1e9) : (b / 1_000_000) + " MB"; }
    private LinearLayout col() { LinearLayout l = new LinearLayout(this); l.setOrientation(LinearLayout.VERTICAL); return l; }
    private LinearLayout.LayoutParams lp(int top) { LinearLayout.LayoutParams p = new LinearLayout.LayoutParams(-1, -2); p.topMargin = top; return p; }
    private GradientDrawable round(int fill, int stroke, int r) { GradientDrawable g = new GradientDrawable(); g.setColor(fill); g.setCornerRadius(dp(r)); if (stroke != 0) g.setStroke(dp(1), stroke); return g; }
    private TextView text(String s, int sp, int color, boolean bold) {
        TextView t = new TextView(this); t.setText(s); t.setTextSize(sp); t.setTextColor(color); t.setLineSpacing(0, 1.2f);
        if (bold) t.setTypeface(Typeface.DEFAULT_BOLD);
        return t;
    }
    private LinearLayout card(LinearLayout root) {
        LinearLayout c = col(); c.setBackground(round(CARD, LINE, 18)); c.setPadding(dp(16), dp(14), dp(16), dp(16));
        root.addView(c, lp(dp(16)));
        return c;
    }
    private Button button(String s, boolean primary) {
        Button b = new Button(this); b.setText(s); b.setAllCaps(false); b.setTextSize(15);
        b.setTypeface(Typeface.DEFAULT_BOLD);
        b.setTextColor(primary ? NAVY : TEXT);
        b.setBackground(round(primary ? TURQ : NAVY, primary ? 0 : LINE, 14));
        LinearLayout.LayoutParams p = lp(dp(10)); p.height = dp(48); b.setLayoutParams(p);
        return b;
    }
}
