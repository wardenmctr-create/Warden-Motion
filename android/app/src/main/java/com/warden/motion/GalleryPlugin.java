package com.warden.motion;

import android.Manifest;
import android.app.Activity;
import android.content.ContentResolver;
import android.content.ContentUris;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Build;
import android.provider.MediaStore;
import android.provider.OpenableColumns;
import android.util.Size;
import android.webkit.MimeTypeMap;
import androidx.activity.result.ActivityResult;
import androidx.core.content.ContextCompat;
import com.getcapacitor.JSArray;
import com.getcapacitor.JSObject;
import com.getcapacitor.PermissionState;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.ActivityCallback;
import com.getcapacitor.annotation.CapacitorPlugin;
import com.getcapacitor.annotation.Permission;
import com.getcapacitor.annotation.PermissionCallback;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * Uygulama içi galeri: telefonun fotoğraf/videolarını Warden Motion'dan çıkmadan listeler,
 * küçük resimlerini üretir, seçileni uygulamanın önbelleğine kopyalar. Ayrıca Google Fotoğraflar'dan seçtirir.
 */
@CapacitorPlugin(
    name = "Gallery",
    permissions = {
        @Permission(alias = "media33", strings = { Manifest.permission.READ_MEDIA_IMAGES, Manifest.permission.READ_MEDIA_VIDEO }),
        @Permission(alias = "media34", strings = { Manifest.permission.READ_MEDIA_IMAGES, Manifest.permission.READ_MEDIA_VIDEO, Manifest.permission.READ_MEDIA_VISUAL_USER_SELECTED }),
        @Permission(alias = "storage", strings = { Manifest.permission.READ_EXTERNAL_STORAGE }),
    }
)
public class GalleryPlugin extends Plugin {
    private static final String PHOTOS = "com.google.android.apps.photos";
    private final ExecutorService pool = Executors.newFixedThreadPool(3);

    private String alias() {
        if (Build.VERSION.SDK_INT >= 34) return "media34";
        if (Build.VERSION.SDK_INT >= 33) return "media33";
        return "storage";
    }

    private boolean granted(String p) { return ContextCompat.checkSelfPermission(getContext(), p) == PackageManager.PERMISSION_GRANTED; }

    /** "full", "partial" (sadece seçtikleri) ya da "none" */
    private String access() {
        if (Build.VERSION.SDK_INT >= 33) {
            if (granted(Manifest.permission.READ_MEDIA_IMAGES) || granted(Manifest.permission.READ_MEDIA_VIDEO)) return "full";
            if (Build.VERSION.SDK_INT >= 34 && granted(Manifest.permission.READ_MEDIA_VISUAL_USER_SELECTED)) return "partial";
            return "none";
        }
        return granted(Manifest.permission.READ_EXTERNAL_STORAGE) ? "full" : "none";
    }

    private boolean has(String pkg) {
        try { getContext().getPackageManager().getPackageInfo(pkg, 0); return true; }
        catch (PackageManager.NameNotFoundException e) { return false; }
    }

    @PluginMethod
    public void status(PluginCall call) {
        JSObject r = new JSObject();
        r.put("access", access());
        r.put("photos", has(PHOTOS));
        call.resolve(r);
    }

    @PluginMethod
    public void request(PluginCall call) {
        if (!"none".equals(access()) && !call.getBoolean("again", false)) { status(call); return; }
        requestPermissionForAlias(alias(), call, "permDone");
    }

    @PermissionCallback
    private void permDone(PluginCall call) { status(call); }

    /** Fotoğraf ve videolar (yeniden eskiye). kind: image | video | any */
    @PluginMethod
    public void list(PluginCall call) {
        if ("none".equals(access())) { call.reject("İzin yok"); return; }
        final int offset = call.getInt("offset", 0), limit = call.getInt("limit", 60);
        final String kind = call.getString("kind", "any");
        final String album = call.getString("album", "");
        pool.execute(() -> {
            JSArray items = new JSArray();
            Uri base = MediaStore.Files.getContentUri("external");
            String sel = "image".equals(kind) ? MediaStore.Files.FileColumns.MEDIA_TYPE + "=" + MediaStore.Files.FileColumns.MEDIA_TYPE_IMAGE
                : "video".equals(kind) ? MediaStore.Files.FileColumns.MEDIA_TYPE + "=" + MediaStore.Files.FileColumns.MEDIA_TYPE_VIDEO
                : MediaStore.Files.FileColumns.MEDIA_TYPE + " IN (" + MediaStore.Files.FileColumns.MEDIA_TYPE_IMAGE + "," + MediaStore.Files.FileColumns.MEDIA_TYPE_VIDEO + ")";
            String[] args = null;
            if (!album.isEmpty()) { sel += " AND bucket_display_name=?"; args = new String[] { album }; }
            String[] cols = { MediaStore.Files.FileColumns._ID, MediaStore.Files.FileColumns.MEDIA_TYPE, MediaStore.Files.FileColumns.MIME_TYPE,
                MediaStore.Files.FileColumns.DISPLAY_NAME, "bucket_display_name", "duration" };
            String order = MediaStore.Files.FileColumns.DATE_ADDED + " DESC";
            try (Cursor c = query(base, cols, sel, args, order, offset, limit)) {
                if (c != null) {
                    int skip = Build.VERSION.SDK_INT >= 26 ? 0 : offset;
                    while (c.moveToNext()) {
                        if (skip-- > 0) continue;
                        if (Build.VERSION.SDK_INT < 26 && items.length() >= limit) break;
                        long id = c.getLong(0);
                        boolean video = c.getInt(1) == MediaStore.Files.FileColumns.MEDIA_TYPE_VIDEO;
                        JSObject o = new JSObject();
                        o.put("id", id);
                        o.put("video", video);
                        o.put("mime", c.getString(2));
                        o.put("name", c.getString(3));
                        o.put("album", c.getString(4));
                        int di = c.getColumnIndex("duration");
                        o.put("duration", di >= 0 ? c.getLong(di) : 0);
                        items.put(o);
                    }
                }
            } catch (Exception e) {
                call.reject("Galeri okunamadı: " + e.getMessage());
                return;
            }
            JSObject r = new JSObject();
            r.put("items", items);
            call.resolve(r);
        });
    }

    private Cursor query(Uri base, String[] cols, String sel, String[] args, String order, int offset, int limit) {
        ContentResolver cr = getContext().getContentResolver();
        if (Build.VERSION.SDK_INT >= 26) {
            android.os.Bundle q = new android.os.Bundle();
            q.putString(ContentResolver.QUERY_ARG_SQL_SELECTION, sel);
            if (args != null) q.putStringArray(ContentResolver.QUERY_ARG_SQL_SELECTION_ARGS, args);
            q.putString(ContentResolver.QUERY_ARG_SQL_SORT_ORDER, order);
            q.putInt(ContentResolver.QUERY_ARG_LIMIT, limit);
            q.putInt(ContentResolver.QUERY_ARG_OFFSET, offset);
            return cr.query(base, cols, q, null);
        }
        return cr.query(base, cols, sel, args, order);
    }

    /** Albüm adları (Kamera, WhatsApp, Ekran görüntüleri…) */
    @PluginMethod
    public void albums(PluginCall call) {
        if ("none".equals(access())) { call.reject("İzin yok"); return; }
        pool.execute(() -> {
            java.util.LinkedHashMap<String, Integer> m = new java.util.LinkedHashMap<>();
            String sel = MediaStore.Files.FileColumns.MEDIA_TYPE + " IN (" + MediaStore.Files.FileColumns.MEDIA_TYPE_IMAGE + "," + MediaStore.Files.FileColumns.MEDIA_TYPE_VIDEO + ")";
            try (Cursor c = getContext().getContentResolver().query(MediaStore.Files.getContentUri("external"), new String[] { "bucket_display_name" }, sel, null, MediaStore.Files.FileColumns.DATE_ADDED + " DESC")) {
                while (c != null && c.moveToNext()) { String b = c.getString(0); if (b != null) { Integer v = m.get(b); m.put(b, v == null ? 1 : v + 1); } }
            } catch (Exception ignored) {}
            JSArray a = new JSArray();
            for (java.util.Map.Entry<String, Integer> e : m.entrySet()) { JSObject o = new JSObject(); o.put("name", e.getKey()); o.put("count", e.getValue()); a.put(o); }
            JSObject r = new JSObject(); r.put("albums", a); call.resolve(r);
        });
    }

    private Uri itemUri(long id, boolean video) {
        return ContentUris.withAppendedId(video ? MediaStore.Video.Media.EXTERNAL_CONTENT_URI : MediaStore.Images.Media.EXTERNAL_CONTENT_URI, id);
    }

    /** Küçük resim: önbelleğe JPEG olarak yazar, yolunu döndürür */
    @PluginMethod
    public void thumb(PluginCall call) {
        final long id = call.getLong("id", 0L);
        final boolean video = call.getBoolean("video", false);
        pool.execute(() -> {
            try {
                File dir = new File(getContext().getCacheDir(), "wmthumbs");
                dir.mkdirs();
                File f = new File(dir, (video ? "v" : "i") + id + ".jpg");
                if (!f.exists()) {
                    Bitmap b;
                    if (Build.VERSION.SDK_INT >= 29) b = getContext().getContentResolver().loadThumbnail(itemUri(id, video), new Size(240, 240), null);
                    else if (video) b = MediaStore.Video.Thumbnails.getThumbnail(getContext().getContentResolver(), id, MediaStore.Video.Thumbnails.MINI_KIND, null);
                    else b = MediaStore.Images.Thumbnails.getThumbnail(getContext().getContentResolver(), id, MediaStore.Images.Thumbnails.MINI_KIND, null);
                    if (b == null) { call.reject("yok"); return; }
                    try (OutputStream o = new FileOutputStream(f)) { b.compress(Bitmap.CompressFormat.JPEG, 82, o); }
                }
                JSObject r = new JSObject(); r.put("path", f.getAbsolutePath()); call.resolve(r);
            } catch (Exception e) { call.reject("Küçük resim alınamadı"); }
        });
    }

    /** Seçilen öğeyi önbelleğe kopyalar (uygulama oradan okur) */
    @PluginMethod
    public void read(PluginCall call) {
        final long id = call.getLong("id", 0L);
        final boolean video = call.getBoolean("video", false);
        pool.execute(() -> {
            try { call.resolve(copy(itemUri(id, video))); }
            catch (Exception e) { call.reject("Dosya okunamadı"); }
        });
    }

    private JSObject copy(Uri uri) throws Exception {
        ContentResolver cr = getContext().getContentResolver();
        String mime = cr.getType(uri);
        String name = "dosya";
        try (Cursor c = cr.query(uri, new String[] { OpenableColumns.DISPLAY_NAME }, null, null, null)) {
            if (c != null && c.moveToFirst() && c.getString(0) != null) name = c.getString(0);
        } catch (Exception ignored) {}
        if (!name.contains(".") && mime != null) { String ext = MimeTypeMap.getSingleton().getExtensionFromMimeType(mime); if (ext != null) name += "." + ext; }
        File dir = new File(getContext().getCacheDir(), "wmpick");
        dir.mkdirs();
        File f = new File(dir, System.nanoTime() + "-" + name.replaceAll("[^\\p{L}\\p{N}._-]", "_"));
        try (InputStream in = cr.openInputStream(uri); OutputStream out = new FileOutputStream(f)) {
            byte[] buf = new byte[1 << 16];
            int n;
            while ((n = in.read(buf)) > 0) out.write(buf, 0, n);
        }
        JSObject r = new JSObject();
        r.put("path", f.getAbsolutePath());
        r.put("mime", mime == null ? "application/octet-stream" : mime);
        r.put("name", name);
        return r;
    }

    /** Google Fotoğraflar'dan seçtir */
    @PluginMethod
    public void photos(PluginCall call) {
        String kind = call.getString("kind", "any");
        Intent i = new Intent(Intent.ACTION_PICK);
        i.setPackage(PHOTOS);
        if ("image".equals(kind)) i.setType("image/*");
        else { i.setType("*/*"); i.putExtra(Intent.EXTRA_MIME_TYPES, new String[] { "image/*", "video/*" }); }
        if (call.getBoolean("multiple", false)) i.putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true);
        try { startActivityForResult(call, i, "photosDone"); }
        catch (Exception e) { call.reject("Google Fotoğraflar açılamadı"); }
    }

    @ActivityCallback
    private void photosDone(PluginCall call, ActivityResult res) {
        if (call == null) return;
        Intent d = res.getData();
        if (res.getResultCode() != Activity.RESULT_OK || d == null) { JSObject r = new JSObject(); r.put("files", new JSArray()); call.resolve(r); return; }
        pool.execute(() -> {
            JSArray files = new JSArray();
            try {
                if (d.getClipData() != null) for (int k = 0; k < d.getClipData().getItemCount(); k++) files.put(copy(d.getClipData().getItemAt(k).getUri()));
                else if (d.getData() != null) files.put(copy(d.getData()));
            } catch (Exception e) { call.reject("Seçilen dosya okunamadı"); return; }
            JSObject r = new JSObject(); r.put("files", files); call.resolve(r);
        });
    }

    @Override
    protected void handleOnDestroy() { pool.shutdown(); }
}
