package com.warden.motion;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;
import android.os.Message;
import android.os.Messenger;
import android.os.RemoteException;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import java.util.ArrayList;
import java.util.List;

/**
 * Köprü: telefonda "WardenCB Beyin" uygulaması yüklüyse ona bağlanır, soruyu gönderir, cevabı alır.
 * Beyin sadece aynı anahtarla imzalanmış uygulamaya cevap verir.
 */
@CapacitorPlugin(name = "WardenBrain")
public class BrainPlugin extends Plugin {
    private static final String PKG = "com.warden.brain";
    private static final int STATUS = 1, ASK = 2, CANCEL = 3;
    private static final int R_STATUS = 10, R_PARTIAL = 11, R_DONE = 12, R_ERROR = 13;

    private Messenger service;
    private boolean binding = false;
    private final List<Runnable> onConnect = new ArrayList<>();
    private final List<PluginCall> statusCalls = new ArrayList<>();
    private PluginCall askCall;

    private final Handler replies = new Handler(Looper.getMainLooper()) {
        @Override
        public void handleMessage(Message m) {
            Bundle d = m.getData();
            switch (m.what) {
                case R_STATUS: {
                    JSObject r = new JSObject();
                    r.put("installed", true);
                    r.put("downloaded", d.getBoolean("downloaded"));
                    r.put("loaded", d.getBoolean("loaded"));
                    r.put("loading", d.getBoolean("loading"));
                    r.put("busy", d.getBoolean("busy"));
                    r.put("model", d.getString("model", ""));
                    r.put("backend", d.getString("backend", ""));
                    for (PluginCall c : statusCalls) c.resolve(r);
                    statusCalls.clear();
                    break;
                }
                case R_PARTIAL: {
                    JSObject r = new JSObject();
                    r.put("text", d.getString("text", ""));
                    notifyListeners("partial", r);
                    break;
                }
                case R_DONE: {
                    if (askCall != null) { JSObject r = new JSObject(); r.put("text", d.getString("text", "")); askCall.resolve(r); askCall = null; }
                    break;
                }
                case R_ERROR: {
                    String e = d.getString("error", "Hata");
                    if (askCall != null) { askCall.reject(e); askCall = null; }
                    for (PluginCall c : statusCalls) c.reject(e);
                    statusCalls.clear();
                    break;
                }
            }
        }
    };
    private final Messenger replyTo = new Messenger(replies);

    private final ServiceConnection conn = new ServiceConnection() {
        @Override public void onServiceConnected(ComponentName n, IBinder b) {
            service = new Messenger(b);
            binding = false;
            for (Runnable r : onConnect) r.run();
            onConnect.clear();
        }
        @Override public void onServiceDisconnected(ComponentName n) {
            service = null;
            // Beyin kapandı/çöktü (ör. bellek yetmedi): bekleyen soruyu bildir
            if (askCall != null) { askCall.reject("WardenCB Beyin kapandı. Telefonun belleği yetmemiş olabilir; diğer uygulamaları kapatıp tekrar dene."); askCall = null; }
        }
    };

    private boolean installed() {
        try { getContext().getPackageManager().getPackageInfo(PKG, 0); return true; }
        catch (PackageManager.NameNotFoundException e) { return false; }
    }

    private void withService(PluginCall call, Runnable r) {
        if (service != null) { r.run(); return; }
        onConnect.add(r);
        if (binding) return;
        Intent i = new Intent("com.warden.brain.BIND");
        i.setPackage(PKG);
        boolean ok;
        try { ok = getContext().bindService(i, conn, Context.BIND_AUTO_CREATE); } catch (SecurityException e) { ok = false; }
        if (!ok) {
            onConnect.clear();
            call.reject("WardenCB Beyin'e bağlanılamadı. İki uygulamanın da en son sürümünü yükle.");
            return;
        }
        binding = true;
    }

    private void send(int what, Bundle data) {
        Message m = Message.obtain(null, what);
        if (data != null) m.setData(data);
        m.replyTo = replyTo;
        try { service.send(m); } catch (RemoteException e) { service = null; }
    }

    @PluginMethod
    public void status(PluginCall call) {
        if (!installed()) { JSObject r = new JSObject(); r.put("installed", false); call.resolve(r); return; }
        withService(call, () -> { statusCalls.add(call); send(STATUS, null); });
    }

    @PluginMethod
    public void ask(PluginCall call) {
        if (!installed()) { call.reject("WardenCB Beyin yüklü değil."); return; }
        if (askCall != null) { call.reject("WardenCB şu an düşünüyor, biraz bekle."); return; }
        String prompt = call.getString("prompt", "");
        float temp = call.getFloat("temperature", 0.6f);
        withService(call, () -> {
            askCall = call;
            Bundle b = new Bundle();
            b.putString("prompt", prompt);
            b.putFloat("temperature", temp);
            send(ASK, b);
        });
    }

    @PluginMethod
    public void cancel(PluginCall call) {
        if (service != null) send(CANCEL, null);
        call.resolve();
    }

    /** Beyin uygulamasını aç (modeli indirmek için) */
    @PluginMethod
    public void open(PluginCall call) {
        Intent i = getContext().getPackageManager().getLaunchIntentForPackage(PKG);
        if (i == null) { call.reject("WardenCB Beyin yüklü değil."); return; }
        i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        getContext().startActivity(i);
        call.resolve();
    }

    @Override
    protected void handleOnDestroy() {
        if (service != null || binding) try { getContext().unbindService(conn); } catch (Exception ignored) {}
        service = null;
    }
}
