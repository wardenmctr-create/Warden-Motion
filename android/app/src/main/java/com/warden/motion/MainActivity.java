package com.warden.motion;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.webkit.ValueCallback;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import com.getcapacitor.BridgeActivity;
import com.getcapacitor.BridgeWebChromeClient;
import java.util.ArrayList;
import java.util.List;

/**
 * Dosya seçme: Android'in sadece fotoğraf gösteren seçicisi (Photo Picker) yerine
 * klasörlü tam dosya seçiciyi açar (İndirilenler, dahili depolama, WhatsApp görselleri, Google Fotoğraflar…).
 */
public class MainActivity extends BridgeActivity {
    private ValueCallback<Uri[]> pending;
    private ActivityResultLauncher<Intent> picker;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        registerPlugin(GalleryPlugin.class); // uygulama içi galeri
        registerPlugin(SaveToPlugin.class); // proje dosyasını Drive / Files'a kaydetme
        super.onCreate(savedInstanceState);
        picker = registerForActivityResult(new ActivityResultContracts.StartActivityForResult(), result -> {
            ValueCallback<Uri[]> cb = pending;
            pending = null;
            if (cb == null) return;
            Uri[] uris = null;
            Intent data = result.getData();
            if (result.getResultCode() == RESULT_OK && data != null) {
                if (data.getClipData() != null) {
                    int n = data.getClipData().getItemCount();
                    uris = new Uri[n];
                    for (int i = 0; i < n; i++) uris[i] = data.getClipData().getItemAt(i).getUri();
                } else if (data.getData() != null) {
                    uris = new Uri[] { data.getData() };
                }
            }
            cb.onReceiveValue(uris);
        });
        WebView wv = getBridge().getWebView();
        wv.setWebChromeClient(new BridgeWebChromeClient(getBridge()) {
            @Override
            public boolean onShowFileChooser(WebView view, ValueCallback<Uri[]> callback, WebChromeClient.FileChooserParams params) {
                if (params.isCaptureEnabled()) return super.onShowFileChooser(view, callback, params);
                if (pending != null) pending.onReceiveValue(null);
                pending = callback;
                List<String> types = new ArrayList<>();
                for (String t : params.getAcceptTypes()) {
                    for (String p : t.split(",")) {
                        String s = p.trim();
                        if (s.isEmpty()) continue;
                        if (s.startsWith(".")) s = s.equals(".png") ? "image/png" : "*/*";
                        if (!types.contains(s)) types.add(s);
                    }
                }
                if (types.isEmpty()) types.add("*/*");
                Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT);
                intent.addCategory(Intent.CATEGORY_OPENABLE);
                intent.setType(types.size() == 1 ? types.get(0) : "*/*");
                if (types.size() > 1) intent.putExtra(Intent.EXTRA_MIME_TYPES, types.toArray(new String[0]));
                if (params.getMode() == WebChromeClient.FileChooserParams.MODE_OPEN_MULTIPLE) intent.putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true);
                try {
                    picker.launch(intent);
                } catch (Exception e) {
                    pending = null;
                    return super.onShowFileChooser(view, callback, params);
                }
                return true;
            }
        });
    }
}
