package com.warden.brain;

import android.app.Service;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;
import android.os.Message;
import android.os.Messenger;
import android.os.Process;
import android.os.RemoteException;

/**
 * Köprü: Warden Motion bu servise bağlanır, soruyu gönderir, cevabı parça parça alır.
 * Sadece AYNI imzayla imzalanmış uygulamalara cevap verir (izin + imza kontrolü).
 *
 * Mesajlar:  1 durum  → 10 durum cevabı {downloaded, loaded, loading, busy, model, backend}
 *            2 sor {prompt, temperature} → 11 parça {text} · 12 bitti {text} · 13 hata {error}
 *            3 iptal
 */
public class BrainService extends Service {
    static final int STATUS = 1, ASK = 2, CANCEL = 3;
    static final int R_STATUS = 10, R_PARTIAL = 11, R_DONE = 12, R_ERROR = 13;

    private final Handler handler = new Handler(Looper.getMainLooper()) {
        @Override
        public void handleMessage(Message msg) {
            Messenger reply = msg.replyTo;
            if (reply == null) return;
            // İmza kontrolü: gönderen uygulama bizimle aynı anahtarla imzalanmış olmalı
            int uid = msg.sendingUid;
            if (uid != -1 && uid != Process.myUid()
                && getPackageManager().checkSignatures(Process.myUid(), uid) != PackageManager.SIGNATURE_MATCH) {
                send(reply, R_ERROR, b("error", "İzin yok"));
                return;
            }
            Brain brain = Brain.get(BrainService.this);
            switch (msg.what) {
                case STATUS: {
                    Bundle r = new Bundle();
                    r.putBoolean("downloaded", brain.isDownloaded());
                    r.putBoolean("loaded", brain.isLoaded());
                    r.putBoolean("loading", brain.isLoading());
                    r.putBoolean("busy", brain.isBusy());
                    r.putString("model", Brain.MODEL_NAME);
                    r.putString("backend", brain.backend());
                    send(reply, R_STATUS, r);
                    break;
                }
                case ASK: {
                    Bundle d = msg.getData();
                    String prompt = d.getString("prompt", "");
                    float temp = d.getFloat("temperature", 0.6f);
                    final long[] last = { 0 };
                    brain.generate(prompt, temp, new Brain.Listener() {
                        @Override public void partial(String t) {
                            long now = System.currentTimeMillis();
                            if (now - last[0] > 250) { last[0] = now; send(reply, R_PARTIAL, b("text", t)); }
                        }
                        @Override public void done(String t) { send(reply, R_DONE, b("text", t)); }
                        @Override public void error(String m) { send(reply, R_ERROR, b("error", m)); }
                    });
                    break;
                }
                case CANCEL: brain.cancel(); break;
            }
        }
    };
    private final Messenger messenger = new Messenger(handler);

    private static Bundle b(String k, String v) { Bundle x = new Bundle(); x.putString(k, v); return x; }

    private static void send(Messenger to, int what, Bundle data) {
        Message m = Message.obtain(null, what);
        m.setData(data);
        try { to.send(m); } catch (RemoteException ignored) {}
    }

    @Override
    public IBinder onBind(Intent intent) { return messenger.getBinder(); }
}
