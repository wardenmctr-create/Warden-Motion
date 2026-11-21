package com.warden.motion;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import androidx.activity.result.ActivityResult;
import androidx.core.content.FileProvider;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.ActivityCallback;
import com.getcapacitor.annotation.CapacitorPlugin;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.OutputStream;

/**
 * Proje dosyasını seçilen yere kaydeder:
 *  drive → Google Drive'ın "Drive'a yükle" ekranı
 *  files → Android'in kaydetme ekranı (Google Files / Dosyalar: klasör seçilir)
 */
@CapacitorPlugin(name = "SaveTo")
public class SaveToPlugin extends Plugin {
    private static final String DRIVE = "com.google.android.apps.docs";

    private boolean has(String pkg) {
        try { getContext().getPackageManager().getPackageInfo(pkg, 0); return true; }
        catch (PackageManager.NameNotFoundException e) { return false; }
    }

    private File cacheFile(String uriOrPath) {
        String p = uriOrPath.startsWith("file://") ? Uri.parse(uriOrPath).getPath() : uriOrPath;
        return new File(p);
    }

    @PluginMethod
    public void available(PluginCall call) {
        JSObject r = new JSObject();
        r.put("drive", has(DRIVE));
        call.resolve(r);
    }

    @PluginMethod
    public void drive(PluginCall call) {
        File f = cacheFile(call.getString("path", ""));
        if (!f.exists()) { call.reject("Dosya bulunamadı."); return; }
        Uri uri = FileProvider.getUriForFile(getContext(), getContext().getPackageName() + ".fileprovider", f);
        Intent i = new Intent(Intent.ACTION_SEND);
        i.setType("application/octet-stream");
        i.putExtra(Intent.EXTRA_STREAM, uri);
        i.putExtra(Intent.EXTRA_TITLE, call.getString("name", f.getName()));
        i.setPackage(DRIVE);
        i.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION | Intent.FLAG_ACTIVITY_NEW_TASK);
        try { getContext().startActivity(i); call.resolve(); }
        catch (Exception e) { call.reject("Google Drive açılamadı."); }
    }

    @PluginMethod
    public void files(PluginCall call) {
        File f = cacheFile(call.getString("path", ""));
        if (!f.exists()) { call.reject("Dosya bulunamadı."); return; }
        Intent i = new Intent(Intent.ACTION_CREATE_DOCUMENT);
        i.addCategory(Intent.CATEGORY_OPENABLE);
        i.setType("application/octet-stream");
        i.putExtra(Intent.EXTRA_TITLE, call.getString("name", f.getName()));
        startActivityForResult(call, i, "filesResult");
    }

    @ActivityCallback
    private void filesResult(PluginCall call, ActivityResult result) {
        if (call == null) return;
        if (result.getResultCode() != Activity.RESULT_OK || result.getData() == null || result.getData().getData() == null) {
            JSObject r = new JSObject(); r.put("saved", false); call.resolve(r); return;
        }
        File f = cacheFile(call.getString("path", ""));
        try (InputStream in = new FileInputStream(f); OutputStream out = getContext().getContentResolver().openOutputStream(result.getData().getData())) {
            byte[] buf = new byte[65536];
            int n;
            while ((n = in.read(buf)) > 0) out.write(buf, 0, n);
            JSObject r = new JSObject(); r.put("saved", true); call.resolve(r);
        } catch (Exception e) {
            call.reject("Kaydedilemedi: " + e.getMessage());
        }
    }
}
