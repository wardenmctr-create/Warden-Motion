package com.warden.motion.app.ui

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.util.LruCache
import androidx.compose.foundation.Image
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import com.warden.motion.app.data.Store
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONArray
import org.json.JSONObject
import java.util.Locale

data class PackPart(val name: String, val src: String, val back: Boolean = false, val parent: Int? = null)
data class PackItem(val name: String, val src: String, val id: String? = null, val parts: List<PackPart>? = null, val root: Int? = null)
data class PackFolder(val name: String, val items: List<PackItem>)
data class FlagMeta(val code: String, val en: String, val continent: String, val iso: Boolean, val name: String)

/** Hazır pack (assets/packs/hazir/manifest.json), bayraklar ve kullanıcının kendi pack/bayrakları */
object Packs {
    private var readyCache: List<PackFolder>? = null
    private var flagCache: List<FlagMeta>? = null

    fun ready(ctx: Context): List<PackFolder> = readyCache ?: run {
        val o = JSONObject(ctx.assets.open("packs/hazir/manifest.json").bufferedReader().readText())
        val fs = o.getJSONArray("folders")
        List(fs.length()) { i ->
            val f = fs.getJSONObject(i); val its = f.getJSONArray("items")
            PackFolder(f.getString("name"), List(its.length()) { j ->
                val it = its.getJSONObject(j)
                val parts = it.optJSONArray("parts")?.let { a -> List(a.length()) { k -> val p = a.getJSONObject(k); PackPart(p.getString("name"), p.getString("src"), p.optBoolean("back"), if (p.has("parent")) p.getInt("parent") else null) } }
                PackItem(it.getString("name"), it.getString("src"), parts = parts, root = if (it.has("root")) it.getInt("root") else null)
            })
        }.also { readyCache = it }
    }

    val CONT = mapOf("Europe" to "Avrupa", "Asia" to "Asya", "Africa" to "Afrika", "North America" to "Kuzey Amerika", "South America" to "Güney Amerika", "Oceania" to "Okyanusya", "Antarctica" to "Antarktika")

    fun flags(ctx: Context): List<FlagMeta> = flagCache ?: run {
        val a = JSONArray(ctx.assets.open("flags/flags.json").bufferedReader().readText())
        val tr = Locale("tr")
        List(a.length()) { i ->
            val f = a.getJSONObject(i)
            val code = f.getString("code"); val en = f.getString("en"); val iso = f.optBoolean("iso")
            val name = if (iso && code.length == 2) Locale("", code.uppercase()).getDisplayCountry(tr).ifBlank { en } else en
            FlagMeta(code, en, f.optString("continent"), iso, name)
        }.sortedWith(compareByDescending<FlagMeta> { it.code == "wardencb" }.thenBy(java.text.Collator.getInstance(tr)) { it.name }).also { flagCache = it }
    }

    // ---------- Kullanıcının pack'i ve bayrakları (bu cihazda) ----------
    data class UserItem(val id: String, val name: String, val folder: String)
    private fun prefs(ctx: Context) = ctx.getSharedPreferences("wm-pack", Context.MODE_PRIVATE)
    fun userPack(ctx: Context): List<UserItem> = runCatching {
        val a = JSONArray(prefs(ctx).getString("items", "[]")); List(a.length()) { val o = a.getJSONObject(it); UserItem(o.getString("id"), o.getString("name"), o.optString("folder", "Genel")) }
    }.getOrDefault(emptyList())
    fun userFolders(ctx: Context): List<String> = runCatching { val a = JSONArray(prefs(ctx).getString("folders", "[]")); List(a.length()) { a.getString(it) } }.getOrDefault(emptyList())
    fun saveUserPack(ctx: Context, items: List<UserItem>) = prefs(ctx).edit().putString("items", JSONArray(items.map { JSONObject().put("id", it.id).put("name", it.name).put("folder", it.folder) }).toString()).apply()
    fun addUserFolder(ctx: Context, n: String) { val f = userFolders(ctx); if (n !in f) prefs(ctx).edit().putString("folders", JSONArray(f + n).toString()).apply() }
    fun userFlags(ctx: Context): List<UserItem> = runCatching {
        val a = JSONArray(prefs(ctx).getString("flags", "[]")); List(a.length()) { val o = a.getJSONObject(it); UserItem(o.getString("id"), o.getString("name"), "") }
    }.getOrDefault(emptyList())
    fun saveUserFlags(ctx: Context, items: List<UserItem>) = prefs(ctx).edit().putString("flags", JSONArray(items.map { JSONObject().put("id", it.id).put("name", it.name) }).toString()).apply()

    // Son kullanılanlar
    fun recent(ctx: Context): List<String> = runCatching { val a = JSONArray(prefs(ctx).getString("recent", "[]")); List(a.length()) { a.getString(it) } }.getOrDefault(emptyList())
    fun pushRecent(ctx: Context, src: String) = prefs(ctx).edit().putString("recent", JSONArray((listOf(src) + recent(ctx).filter { it != src }).take(12)).toString()).apply()
}

/** Küçük önizleme resimleri (pack, bayrak, kullanıcı görselleri) */
object Previews {
    private val cache = object : LruCache<String, Bitmap>(24 * 1024 * 1024) { override fun sizeOf(key: String, value: Bitmap) = value.byteCount }
    fun get(k: String) = cache.get(k)
    suspend fun load(ctx: Context, src: String, max: Int = 256): Bitmap? = withContext(Dispatchers.IO) {
        cache.get("$src@$max")?.let { return@withContext it }
        val b = runCatching {
            if (src.endsWith(".svg")) {
                val svg = ctx.assets.open(src).use { com.caverock.androidsvg.SVG.getFromInputStream(it) }
                val vb = svg.documentViewBox
                val aw = (vb?.width() ?: svg.documentWidth).takeIf { it > 0 } ?: 640f; val ah = (vb?.height() ?: svg.documentHeight).takeIf { it > 0 } ?: 480f
                val k = max / maxOf(aw, ah)
                val bm = Bitmap.createBitmap((aw * k).toInt().coerceAtLeast(1), (ah * k).toInt().coerceAtLeast(1), Bitmap.Config.ARGB_8888)
                svg.setDocumentWidth("100%"); svg.setDocumentHeight("100%")
                svg.renderToCanvas(android.graphics.Canvas(bm), android.graphics.RectF(0f, 0f, bm.width.toFloat(), bm.height.toFloat()))
                bm
            } else {
                val open = { if (src.startsWith("media:")) Store.get(ctx).mediaFile(src.removePrefix("media:")).inputStream() else ctx.assets.open(src) }
                val o = BitmapFactory.Options().apply { inJustDecodeBounds = true }
                open().use { BitmapFactory.decodeStream(it, null, o) }
                var s = 1; while (maxOf(o.outWidth, o.outHeight) / (s * 2) >= max) s *= 2
                open().use { BitmapFactory.decodeStream(it, null, BitmapFactory.Options().apply { inSampleSize = s }) }
            }
        }.getOrNull()
        if (b != null) cache.put("$src@$max", b)
        b
    }
}

@Composable
fun AssetImg(src: String, modifier: Modifier, max: Int = 256, crop: Boolean = false) {
    val ctx = LocalContext.current
    var b by remember(src) { mutableStateOf(Previews.get("$src@$max")) }
    LaunchedEffect(src) { if (b == null) b = Previews.load(ctx, src, max) }
    b?.let { Image(it.asImageBitmap(), null, modifier, contentScale = if (crop) ContentScale.Crop else ContentScale.Fit) }
}
