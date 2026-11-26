package com.warden.motion.app.render

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.BlendMode
import android.graphics.Canvas
import android.graphics.LinearGradient
import android.graphics.Paint
import android.graphics.Path
import android.graphics.RadialGradient
import android.graphics.RectF
import android.graphics.Shader
import android.graphics.Typeface
import android.os.Build
import android.util.LruCache
import com.warden.motion.app.data.Store
import com.warden.motion.app.model.Effect
import com.warden.motion.app.model.Layer
import com.warden.motion.app.model.fxMeta
import com.warden.motion.app.model.Project
import com.warden.motion.app.model.at
import com.warden.motion.app.model.fillShape
import com.warden.motion.app.model.value
import com.warden.motion.app.model.visBox
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import kotlin.math.PI
import kotlin.math.pow
import kotlin.math.cos
import kotlin.math.floor
import kotlin.math.hypot
import kotlin.math.max
import kotlin.math.min
import kotlin.math.sin
import kotlin.math.roundToInt

/** Katmanın sahnedeki dönüşümü */
data class TR(val x: Double, val y: Double, val rot: Double, val scale: Double, val opacity: Double, val sx: Double = 1.0, val sy: Double = 1.0, val skew: Double = 0.0)

private fun noise(t: Double, seed: Int) = sin(t * 12.9898 + seed * 78.233) * 0.5 + sin(t * 4.1 + seed) * 0.5

fun layerTransform(l: Layer, t0: Double): TR {
    var t = t0
    // Karton Kukla: stop-motion hissi (düşük kare hızı, eklemlerde sertlik, mikro sallanma)
    val cp = l.effects.find { it.type == "cardpuppet" && it.on != false && it.value("stopMotion", t0) >= 0.5 }
    if (cp != null) { val fps = cp.value("kuklaFps", t0).coerceIn(1.0, 60.0); val q = kotlin.math.floor((t0 - l.start) * fps) / fps + l.start; t = q + (t0 - q) * (1 - cp.value("eklemSert", t0) / 100) * 0.3 }
    // Kare Atla: "Hareketi de kare kare oynat" açıksa katmanın dönüşümü de seçilen kare hızında ilerler
    l.effects.find { it.type == "posterizetime" && it.on != false && it.value("hareketAtla", t0) >= 0.5 }?.let { e ->
        val f = kotlin.math.max(0.1, e.value("kareHizi", t0)); t = kotlin.math.floor((t - l.start + e.value("zamanKaym", t0)) * f) / f + l.start }
    var tr = TR(l.x.at(t), l.y.at(t), l.rotation.at(t), l.scale.at(t), l.opacity.at(t))
    if (cp != null) { val tick = kotlin.math.floor((t0 - l.start) * cp.value("kuklaFps", t0)); val m = cp.value("mikroSallan", t0) / 100
        tr = tr.copy(x = tr.x + (noise1(tick, 1.0) * 3 * m), y = tr.y + noise1(tick, 2.0) * 3 * m, rot = tr.rot + noise1(tick, 3.0) * 2.5 * m) }
    // Karton Kukla esnekliği: hızlı harekette hareket yönünde hafif esneme, yavaşlayınca geri toplanma
    l.effects.find { it.type == "cardpuppet" && it.on != false && it.value("esneklik", t0) > 0 }?.let { e ->
        val dt = 1.0 / 30; val vx = (l.x.at(t) - l.x.at(t - dt)) / dt; val vy = (l.y.at(t) - l.y.at(t - dt)) / dt
        val k = (kotlin.math.hypot(vx, vy) / 1500 * e.value("esneklik", t0) / 100).coerceAtMost(0.35)
        if (k > 1e-4) { val horiz = kotlin.math.abs(vx) >= kotlin.math.abs(vy); tr = if (horiz) tr.copy(sx = tr.sx * (1 + k), sy = tr.sy / (1 + k)) else tr.copy(sx = tr.sx / (1 + k), sy = tr.sy * (1 + k)) } }
    return if (l.effects.isEmpty()) tr else applyMotionFx(l, t, tr)
}

/** Takip zinciri (ebeveyn) dahil gerçek dönüşüm */
fun worldTransform(p: Project, l: Layer, t: Double, depth: Int = 0): TR {
    var loc = layerTransform(l, t)
    l.effects.find { it.type == "cbtalk" && it.on != false }?.let { loc = talkFx(p, l, it, t, loc) }
    val par = if (l.parent != null && depth < 8) p.layers.find { it.id == l.parent } else null
    val pw = if (par != null) worldTransform(p, par, t, depth + 1) else null
    loc = rigLocal(p, l, t, loc, pw)
    if (l.effects.isNotEmpty()) { loc = Physics.local(p, l, t, loc); loc = Motion2.local(p, l, t, loc) }
    if (pw == null) return loc
    val a = pw.rot * PI / 180
    return TR(
        pw.x + (loc.x * cos(a) - loc.y * sin(a)) * pw.scale,
        pw.y + (loc.x * sin(a) + loc.y * cos(a)) * pw.scale,
        pw.rot + loc.rot, pw.scale * loc.scale, loc.opacity, loc.sx, loc.sy, loc.skew,
    )
}

fun parseCol(hex: String?, def: Int = 0xFF8F7CF0.toInt()): Int = runCatching { android.graphics.Color.parseColor(hex) }.getOrDefault(def)

/**
 * Çizim motoru: bir projenin t anındaki karesini Android Canvas'a çizer (donanım hızlandırmalı).
 * Görseller önbellekte tutulur; önizlemede küçültülmüş (maxSide), dışa aktarmada asıl hâliyle.
 */
class Renderer(private val ctx: Context, maxSide: Int = 2048, private val sync: Boolean = false, cacheMb: Int = 64) {
    private val store = Store.get(ctx)
    private val pcmCache = android.util.LruCache<String, Pcm>(3)
    init { AudioVis.pcmOf = { l -> l.src?.takeIf { it.startsWith("media:") }?.let { src -> pcmCache.get(src) ?: runCatching { AudioDecode.decode(store.mediaFile(src.removePrefix("media:")), 600.0) }.getOrNull()?.also { pcmCache.put(src, it) } } } }
    init { AudioLevels.resolver = { l -> l.src?.takeIf { it.startsWith("media:") }?.let { runCatching { AudioDecode.peaks(store.mediaFile(it.removePrefix("media:"))) }.getOrNull() } } }
    /** Önizlemedeki görsellerin en uzun kenarı (Lite ayarı 'img'); değişince görseller yeniden çözülür */
    var maxSide: Int = maxSide
        set(v) { if (v != field && !sync) { field = v; cache.evictAll(); failed.clear(); _version.value++ } else field = v }
    private val cache = object : LruCache<String, Bitmap>(cacheMb * 1024 * 1024) { override fun sizeOf(key: String, value: Bitmap) = value.byteCount }
    private val loading = HashSet<String>()
    private val failed = HashSet<String>()
    // Aynı anda en fazla 2 görsel çözülür (bellek ve işlemci taşmasın)
    @OptIn(kotlinx.coroutines.ExperimentalCoroutinesApi::class)
    private val io = CoroutineScope(SupervisorJob() + Dispatchers.IO.limitedParallelism(2))
    private val _version = MutableStateFlow(0)
    /** Bir görsel yüklendiğinde artar (ekran yeniden çizilsin) */
    val version: StateFlow<Int> = _version

    fun image(src: String): Bitmap? {
        cache.get(src)?.let { return it }
        if (src in failed) return null
        if (sync) {
            // Arka plan çizimi (küçük resim, dışa aktarma): beklemeden yükle
            val bmp = runCatching { decode(src) }.getOrNull()
            if (bmp != null) cache.put(src, bmp) else failed.add(src)
            return bmp
        }
        synchronized(loading) { if (!loading.add(src)) return null }
        io.launch {
            val bmp = runCatching { decode(src) }.getOrNull()
            if (bmp != null) cache.put(src, bmp) else failed.add(src)
            synchronized(loading) { loading.remove(src) }
            _version.value++
        }
        return null
    }

    private fun decode(src: String): Bitmap? {
        if (src.endsWith(".svg")) {
            // Bayraklar SVG: istenen boyutta resme çevrilir
            val svg = ctx.assets.open(src.removePrefix("/")).use { com.caverock.androidsvg.SVG.getFromInputStream(it) }
            val vb = svg.documentViewBox
            val aw = (vb?.width() ?: svg.documentWidth).takeIf { it > 0 } ?: 640f
            val ah = (vb?.height() ?: svg.documentHeight).takeIf { it > 0 } ?: 480f
            val k = minOf(maxSide, 1024) / maxOf(aw, ah)
            val b = Bitmap.createBitmap((aw * k).toInt().coerceAtLeast(1), (ah * k).toInt().coerceAtLeast(1), Bitmap.Config.ARGB_8888)
            svg.setDocumentWidth("100%"); svg.setDocumentHeight("100%")
            svg.renderToCanvas(Canvas(b), android.graphics.RectF(0f, 0f, b.width.toFloat(), b.height.toFloat()))
            return b
        }
        val opts = BitmapFactory.Options().apply { inJustDecodeBounds = true }
        val open = { if (src.startsWith("media:")) store.mediaFile(src.removePrefix("media:")).inputStream() else ctx.assets.open(src.removePrefix("/")) }
        open().use { BitmapFactory.decodeStream(it, null, opts) }
        var s = 1
        while (max(opts.outWidth, opts.outHeight) / (s * 2) >= maxSide) s *= 2
        return open().use { BitmapFactory.decodeStream(it, null, BitmapFactory.Options().apply { inSampleSize = s }) }
    }

    // ---------- Videolar ----------
    private val videos = HashMap<String, VideoSource?>()
    /** Oynatılıyor mu (videolar ileriden toplu çözülür) */
    @Volatile var playing = false
    private var curT = 0.0
    /** Videonun kısa kenarı (0 = asıl) — önizlemede Lite ayarından */
    var videoSide = 720
    fun video(src: String): VideoSource? = synchronized(videos) {
        videos.getOrPut(src) {
            val f = store.mediaFile(src.removePrefix("media:"))
            if (!f.exists()) null else runCatching { VideoSource(f, if (sync) 0 else if (videoSide <= 0) 1920 else videoSide * 16 / 9) { _version.value++ } }.getOrNull()
        }
    }
    fun releaseVideos() = synchronized(videos) { videos.values.forEach { it?.release() }; videos.clear() }

    private val paint = Paint(Paint.ANTI_ALIAS_FLAG or Paint.FILTER_BITMAP_FLAG)
    // Eski uygulamadaki gibi Inter Bold (700)
    private val bold = runCatching { androidx.core.content.res.ResourcesCompat.getFont(ctx, com.warden.motion.app.R.font.inter_bold) }.getOrNull() ?: Typeface.create(Typeface.DEFAULT, Typeface.BOLD)

    /** scale: proje pikselinden ekran pikseline oran */
    fun draw(c: Canvas, p: Project, t: Double, scale: Float) {
        curT = t; curQ = scale
        c.save()
        c.scale(scale, scale)
        paint.reset(); paint.isAntiAlias = true
        paint.color = parseCol(p.background, android.graphics.Color.WHITE)
        c.drawRect(0f, 0f, p.width.toFloat(), p.height.toFloat(), paint)
        c.clipRect(0f, 0f, p.width.toFloat(), p.height.toFloat())
        FxText.project = p
        for (l in drawOrder(p, t)) {
            if (l.type == "audio" || l.hidden == true || t < l.start || t >= l.end) continue
            val m = l.mask?.let { id -> p.layers.find { it.id == id } }
            if (m != null) {
                // Kırpma maskesi: katman ayrı katmana çizilir, maskenin şekliyle kesilir (Hariç Tutma: tersi)
                val bp = Paint().apply { blendOf(l.blend)?.let { if (Build.VERSION.SDK_INT >= 29) blendMode = it } }
                c.saveLayer(null, bp)
                paintLayer(c, p, l.copy(blend = null), t)
                c.saveLayer(null, Paint().apply { xfermode = android.graphics.PorterDuffXfermode(if (l.maskInvert == true) android.graphics.PorterDuff.Mode.DST_OUT else android.graphics.PorterDuff.Mode.DST_IN) })
                paintLayer(c, p, m.copy(hidden = null, effects = emptyList(), blend = null), t)
                c.restore(); c.restore()
            } else paintLayer(c, p, l, t)
        }
        c.restore()
    }

    // ---------- Efekt ayarları ----------
    /** Lite efekt sınırları (önizlemede): blur 0..3, warp 0..2, light 0..1, color 0..1. Dışa aktarmada hepsi tam */
    var limits: Map<String, Double> = mapOf("blur" to 3.0, "warp" to 2.0, "light" to 1.0, "color" to 1.0)
    var exporting = false
    /** Dışa aktarma kalitesi 0..1 (ağır efektlerde) */
    var fxQuality = 0.5
    /** Lite: yalnız önizlemede efekt ara resmi küçültülür, sürü/örnek sayıları azaltılır; dışa aktarmada gerçek değerler */
    var lite = false
    private var curQ = 1f
    private fun lim(k: String) = if (exporting) 9.0 else (limits[k] ?: 9.0)

    private fun drawTransformed(c: Canvas, l: Layer, tr: TR, fx: Bitmap? = null, fxRect: RectF? = null) {
        c.save()
        c.translate(tr.x.toFloat(), tr.y.toFloat()); c.rotate(tr.rot.toFloat()); c.scale(tr.scale.toFloat() * tr.sx.toFloat(), tr.scale.toFloat() * tr.sy.toFloat())
        if (tr.skew != 0.0) c.skew(kotlin.math.tan(tr.skew * PI / 180).toFloat(), 0f)
        if (l.flipX == true || l.flipY == true) c.scale(if (l.flipX == true) -1f else 1f, if (l.flipY == true) -1f else 1f)
        if (fx != null && fxRect != null) c.drawBitmap(fx, null, fxRect, Paint(Paint.FILTER_BITMAP_FLAG))
        else drawLayer(c, l)
        c.restore()
    }

    private fun drawMotionPath(c: Canvas, p: Project, l: Layer, e: Effect, t: Double) {
        val tgt = e.c?.get("izlenenKatm")?.let { id -> p.layers.find { it.id == id } } ?: l
        val from = if (e.value("tumGecmGost", t) >= 0.5) tgt.start else max(tgt.start, t - e.value("izSure", t)); if (t <= from) return
        val step = max(1.0, e.value("ornekAral", t)) / p.fps; val pts = ArrayList<TR>(); var tt = from
        while (tt <= t && pts.size < 4000) { pts += worldTransform(p, tgt, tt); tt += step }; pts += worldTransform(p, tgt, t); if (pts.size < 2) return
        val col = parseCol(e.c?.get("renk") ?: "#43A8FF"); val w = e.value("kalinlik", t).toFloat(); val fade = e.value("ucSolm", t) / 100; val st = e.value("bicim", t).roundToInt()
        val pt = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = col; strokeWidth = w; style = Paint.Style.STROKE; strokeCap = Paint.Cap.ROUND
            if (st == 1) pathEffect = android.graphics.DashPathEffect(floatArrayOf(w * 3, w * 2), 0f) else if (st == 2) pathEffect = android.graphics.DashPathEffect(floatArrayOf(0.1f, w * 2.2f), 0f) }
        for (i in 1 until pts.size) { val k = i.toDouble() / (pts.size - 1); pt.alpha = ((1 - fade * (1 - k)) * 255).toInt().coerceIn(0, 255)
            c.drawLine(pts[i - 1].x.toFloat(), pts[i - 1].y.toFloat(), pts[i].x.toFloat(), pts[i].y.toFloat(), pt) }
        if (e.value("uctaIsar", t) >= 0.5) { val h = pts.last(); c.drawCircle(h.x.toFloat(), h.y.toFloat(), w * 1.8f, Paint(Paint.ANTI_ALIAS_FLAG).apply { color = col }) }
    }
    private var echoMul = 1.0; private var echoBlend: BlendMode? = null; private var inEcho = false
    /** Canlı Bağlantı Çizgisi / Ölçü Oku: uçlara seçilen katmanların o anki konumu yazılır (katmanın kutusuna göre %) */
    private fun linkPoints(p: Project, l: Layer, e: Effect, t: Double, tr: TR): Effect {
        // Grafik/harita verisi: seçilen metin katmanındaki satırlar (virgül/boşlukla ayrılmış sayılar) → dv dizisi, dvR satır, dvC sütun
        if (e.type == "puppetpin") { val x0 = e.value("pimKonuX", l.start); val y0 = e.value("pimKonuY", l.start)
            return e.copy(v = (e.v ?: emptyMap()) + ("dv0" to com.warden.motion.app.model.Anim((x0 / 100 - 0.5) * l.w)) + ("dv1" to com.warden.motion.app.model.Anim((y0 / 100 - 0.5) * l.h))) }
        val dataKey = listOf("veri", "zamanSeri", "baglanti", "noktaVeri", "veriDosy", "olayDosy", "akisTabl").firstOrNull { k -> fxMeta(e.type).params.any { it.key == k } }
        if (dataKey != null) { val src = e.c?.get(dataKey)?.let { id -> p.layers.find { it.id == id } }; val txt = src?.text ?: return e
            val rows = txt.lines().map { ln -> Regex("-?\\d+(?:[.,]\\d+)?").findAll(ln).map { it.value.replace(',', '.').toDouble() }.toList() }.filter { it.isNotEmpty() }.take(64)
            val cols = rows.maxOfOrNull { it.size }?.coerceAtMost(16) ?: 0; if (rows.isEmpty() || cols == 0) return e; var v = e.v ?: emptyMap(); var i = 0
            for (r in rows) for (cI in 0 until cols) { if (i >= 256) break; v = v + ("dv$i" to com.warden.motion.app.model.Anim(r.getOrElse(cI) { 0.0 })); i++ }
            v = v + ("dvR" to com.warden.motion.app.model.Anim(min(rows.size, 256 / cols).toDouble())) + ("dvC" to com.warden.motion.app.model.Anim(cols.toDouble())); return e.copy(v = v) }
        if (e.type == "compass") { val m = e.c?.get("harita")?.let { id -> p.layers.find { it.id == id } } ?: return e
            return e.copy(v = (e.v ?: emptyMap()) + ("dv0" to com.warden.motion.app.model.Anim(worldTransform(p, m, t).rot - tr.rot))) }
        if (e.type == "minimap") { val m = e.c?.get("anaHari")?.let { id -> p.layers.find { it.id == id } } ?: return e; val w = worldTransform(p, m, t); val a = -w.rot * PI / 180; val sc = if (kotlin.math.abs(w.scale) > 1e-6) w.scale else 1.0
            fun uv(x: Double, y: Double): Pair<Double, Double> { val dx = x - w.x; val dy = y - w.y; return ((dx * cos(a) - dy * sin(a)) / sc / m.w + 0.5) to ((dx * sin(a) + dy * cos(a)) / sc / m.h + 0.5) }
            val (u0, v0) = uv(0.0, 0.0); val (u1, v1) = uv(p.width.toDouble(), p.height.toDouble())
            return e.copy(v = (e.v ?: emptyMap()) + ("dv0" to com.warden.motion.app.model.Anim(min(u0, u1))) + ("dv1" to com.warden.motion.app.model.Anim(min(v0, v1))) + ("dv2" to com.warden.motion.app.model.Anim(max(u0, u1))) + ("dv3" to com.warden.motion.app.model.Anim(max(v0, v1)))) }
        if (e.type == "elasticline") { // iki uç katman: dv0..dv3 (katman birimi, kutu merkezine göre)
            val ids = e.c?.get("uclar")?.split(',')?.filter { it.isNotBlank() } ?: return e; if (ids.size < 2) return e; var v = e.v ?: emptyMap()
            ids.take(2).forEachIndexed { i, id -> val o = p.layers.find { it.id == id } ?: return e; val w = worldTransform(p, o, t); val a = -tr.rot * PI / 180; val dx = w.x - tr.x; val dy = w.y - tr.y; val sc = if (kotlin.math.abs(tr.scale) > 1e-6) tr.scale else 1.0
                v = v + ("dv${i * 2}" to com.warden.motion.app.model.Anim((dx * cos(a) - dy * sin(a)) / sc)) + ("dv${i * 2 + 1}" to com.warden.motion.app.model.Anim((dx * sin(a) + dy * cos(a)) / sc)) }
            return e.copy(v = v) }
        val pairs = when (e.type) { "connector" -> listOf("baslangiKatm" to "baslangiBagl", "bitisKatm" to "bitisBagl"); else -> return e }
        var v = e.v ?: emptyMap()
        for ((src, key) in pairs) { val o = e.c?.get(src)?.let { id -> p.layers.find { it.id == id } } ?: continue; val w = worldTransform(p, o, t)
            val a = -tr.rot * PI / 180; val dx = w.x - tr.x; val dy = w.y - tr.y; val sc = tr.scale.takeIf { kotlin.math.abs(it) > 1e-6 } ?: 1.0
            val lx = (dx * cos(a) - dy * sin(a)) / sc / tr.sx; val ly = (dx * sin(a) + dy * cos(a)) / sc / tr.sy
            v = v + (key + "X" to com.warden.motion.app.model.Anim(lx / l.w * 100 + 50)) + (key + "Y" to com.warden.motion.app.model.Anim(ly / l.h * 100 + 50)) }
        return e.copy(v = v)
    }
    /**
     * Zamansal efektler için kare şeridi (s_hist): katman, istenen anlarda bu karenin yerel düzlemine göre (kendi hareketi dahil) çizilir.
     * Kareler yan yana dizilir; shader k. kareyi ((k + u) / N, v) ile okur. Önbellek gerekmez; ileri-geri sarmada sonuç aynıdır.
     */
    private fun historySource(p: Project, l: Layer, fx: List<Effect>, t: Double, tr: TR, bw: Int, bh: Int, q: Double): Map<String, Bitmap> {
        if (historyDepth > 0) return emptyMap()
        val times = fx.firstNotNullOfOrNull { History.times(it, l, t, p.fps.toDouble(), exporting) } ?: return emptyMap()
        val n = times.size; if (n == 0) return emptyMap()
        val maxW = if (exporting) 8192 else 4096; val f = min(1.0, min(maxW.toDouble() / (bw * n), (if (exporting) 2048.0 else 1024.0) / max(bw, bh)))
        val fw = max(1, (bw * f).toInt()); val fh = max(1, (bh * f).toInt()); val out = Bitmap.createBitmap(fw * n, fh, Bitmap.Config.ARGB_8888); val c = Canvas(out)
        val keepT = curT; historyDepth++
        try { for ((i, tt0) in times.withIndex()) { val tt = tt0.coerceIn(l.start, l.end - 1e-4); val b = worldTransform(p, l, tt)
            c.save(); c.clipRect(i * fw, 0, (i + 1) * fw, fh); c.translate(i * fw + fw / 2f, fh / 2f); c.scale((q * f).toFloat(), (q * f).toFloat())
            // önceki/sonraki anın dönüşümü, şimdiki karenin yerel düzlemine göre
            val a = -tr.rot * PI / 180; val dx = (b.x - tr.x); val dy = (b.y - tr.y); val sc = if (kotlin.math.abs(tr.scale) > 1e-6) tr.scale else 1.0
            c.translate(((dx * cos(a) - dy * sin(a)) / sc / tr.sx).toFloat(), ((dx * sin(a) + dy * cos(a)) / sc / tr.sy).toFloat()); c.rotate((b.rot - tr.rot).toFloat())
            c.scale((b.scale * b.sx / (sc * tr.sx)).toFloat(), (b.scale * b.sy / (sc * tr.sy)).toFloat())
            if (l.flipX == true || l.flipY == true) c.scale(if (l.flipX == true) -1f else 1f, if (l.flipY == true) -1f else 1f)
            curT = tt; drawLayer(c, l); c.restore() } } finally { curT = keepT; historyDepth-- }
        return mapOf("hist" to out)
    }
    private var historyDepth = 0
    /** 693 Karakter Parça Sırası: seçili parçalar, açı eşiğine göre ana katmanın önüne ya da arkasına alınır */
    private fun drawOrder(p: Project, t: Double): List<Layer> {
        val hosts = p.layers.filter { h -> h.effects.any { it.type == "partorder" && it.on != false } }; if (hosts.isEmpty()) return p.layers
        val list = p.layers.toMutableList()
        for (h in hosts) for (e in h.effects) { if (e.type != "partorder" || e.on == false) continue
            val ids = e.c?.get("parcalar")?.split(',')?.filter { it.isNotBlank() } ?: continue; val ang = e.value("aci", t); val mode = e.value("siraSabl", t).roundToInt()
            val behind = when (mode) { 0 -> ang < 0; 2 -> kotlin.math.abs(((worldTransform(p, h, t).rot + ang) % 360 + 360) % 360 - 180) < 90; else -> false }; if (mode == 1) continue
            val parts = list.filter { it.id in ids }; list.removeAll(parts); val hi = list.indexOfFirst { it.id == h.id }; if (hi < 0) continue
            list.addAll(if (behind) hi else hi + 1, parts) }
        return list
    }
    private var flockXf: DoubleArray? = null
    private fun paintLayer(c: Canvas, p: Project, l: Layer, t: Double) {
        // 506 Sürü Hareketi: katman, sürüdeki her birey için kopyalanır
        l.effects.find { it.type == "flock" && it.on != false }?.let { fe ->
            val rest = l.copy(effects = l.effects.filter { it.type != "flock" })
            for (b in Physics.flock(l, fe, t, p.width.toDouble(), p.height.toDouble())) { flockXf = doubleArrayOf(b[0], b[1], if (fe.value("hareketYonuDon", t) >= 0.5) b[2] else 0.0, b[3]); paintLayer(c, p, rest, t) }
            flockXf = null; return }
        // 505 Hareket Yolu Çizimi: katman çizildikten sonra izlenen katmanın yolu
        l.effects.find { it.type == "motionpath" && it.on != false }?.let { me -> paintLayer(c, p, l.copy(effects = l.effects.filter { it !== me }), t); drawMotionPath(c, p, l, me, t); return }
        val ec = if (!inEcho) l.effects.find { it.type == "echo" && it.on != false } else null
        if (ec != null) {
            // Yankı: katmanın önceki/sonraki anları azalan opaklıkla
            val n = ec.value("yankiSayi", t).roundToInt().coerceIn(1, if (playing && !exporting) 16 else 64); val gap = ec.value("yankiAral", t)
            val a0 = ec.value("baslangiOpak", t) / 100; val dec = 1 - ec.value("sonum", t) / 100; val mode = ec.value("birlesti", t).roundToInt()
            fun echoes() { inEcho = true; echoBlend = if (Build.VERSION.SDK_INT >= 29) when (mode) { 2 -> BlendMode.PLUS; 3 -> BlendMode.LIGHTEN; else -> null } else null
                for (i in n downTo 1) { val tt = t + gap * i; if (tt < l.start || tt > l.end) continue; echoMul = a0 * dec.pow(i - 1); if (echoMul > 0.004) paintLayer(c, p, l.copy(effects = l.effects.filter { it.type != "echo" }), tt) }
                inEcho = false; echoMul = 1.0; echoBlend = null }
            if (mode != 1) echoes()
            inEcho = true; paintLayer(c, p, l, t); inEcho = false
            if (mode == 1) echoes()
            return
        }
        val tr = worldTransform(p, l, t).let { if (echoMul != 1.0) it.copy(opacity = it.opacity * echoMul) else it }.let { w -> flockXf?.let { f -> w.copy(x = w.x + f[0], y = w.y + f[1], rot = w.rot + f[2], scale = w.scale * f[3]) } ?: w }
        val alpha = (tr.opacity.coerceIn(0.0, 1.0) * 255).toInt()
        if (alpha <= 0) return
        val blend = echoBlend ?: blendOf(l.blend)
        val gpu = if (lim("warp") > 0 && !GlFx.failed) l.effects.filter { e -> e.on != false && fxMeta(e.type).kind in GlFx.GPU_KINDS }.map { linkPoints(p, l, it, t, tr) } else emptyList()
        val mb = if (lim("blur") > 0) l.effects.find { (it.type == "motionblur" || it.type == "pixelmb") && it.on != false } else null
        if (gpu.isEmpty() && mb == null) {
            val needLayer = alpha < 255 || blend != null
            if (needLayer) {
                val rr = (hypot(l.w, l.h) / 2 * kotlin.math.abs(tr.scale) * max(tr.sx, tr.sy)).toFloat() + 4f
                c.saveLayer(tr.x.toFloat() - rr, tr.y.toFloat() - rr, tr.x.toFloat() + rr, tr.y.toFloat() + rr, Paint().apply { this.alpha = alpha; if (blend != null && Build.VERSION.SDK_INT >= 29) blendMode = blend })
                drawTransformed(c, l, tr)
                c.restore()
            } else drawTransformed(c, l, tr)
            return
        }
        paintBuffered(c, p, l, t, tr, alpha, blend, gpu, mb)
    }

    /** Efektin katman çevresinde istediği boşluk (katman birimi) */
    private fun padOf(e: Effect, m: com.warden.motion.app.model.FxMeta, t: Double, l: Layer): Double {
        val pd = m.pad ?: return 0.0
        if (pd.box > 0) return pd.box * max(l.w, l.h) + pd.add
        if (pd.sum != null) return max(0.0, pd.sum.sumOf { k -> max(0.0, e.value(k, t)) } * pd.mul + pd.add)
        if (pd.max != null) return pd.max.maxOf { k -> max(0.0, e.value(k, t)) }
        return max(0.0, pd.add + (pd.k?.let { e.value(it, t) } ?: 0.0) * pd.mul)
    }

    /**
     * Efektli katman: katman kendi düzleminde (dönüşümsüz, pad dahil) ara resme çizilir,
     * GPU efekt zinciri uygulanır, sonuç dönüşümle sahneye konur. Hareket bulanıklığında ara anlar toplanır.
     */
    private fun paintBuffered(c: Canvas, p: Project, l: Layer, t: Double, tr: TR, alpha: Int, blend: BlendMode?, gpu: List<Effect>, mb: Effect?) {
        // Ara resim çözünürlüğü: sahnedeki ölçeğe göre (önizlemede oynarken daha düşük)
        val world = kotlin.math.abs(tr.scale) * max(tr.sx, tr.sy)
        var q = curQ.toDouble() * max(0.05, world)
        if (!exporting && playing) q *= 0.7
        if (!exporting && lite) q *= 0.6
        var pad = 2.0
        for (e in gpu) pad += padOf(e, fxMeta(e.type), t, l)
        val maxSide = if (exporting) 4096.0 else 1600.0
        q = min(q, maxSide / max(l.w + 2 * pad, l.h + 2 * pad))
        val bw = kotlin.math.ceil((l.w + 2 * pad) * q).toInt(); val bh = kotlin.math.ceil((l.h + 2 * pad) * q).toInt()
        if (bw <= 0 || bh <= 0) return
        var buf = Bitmap.createBitmap(bw, bh, Bitmap.Config.ARGB_8888)
        val bc = Canvas(buf); bc.translate(bw / 2f, bh / 2f); bc.scale(q.toFloat(), q.toFloat())
        if (l.flipX == true || l.flipY == true) bc.scale(if (l.flipX == true) -1f else 1f, if (l.flipY == true) -1f else 1f)
        drawLayer(bc, l)
        if (gpu.isNotEmpty()) {
            val box = floatArrayOf((pad * q).toFloat(), (pad * q).toFloat(), (l.w * q).toFloat(), (l.h * q).toFloat())
            val job = GlFx.Job(gpu.map { it to fxMeta(it.type) }, t, t - l.start, l.end - l.start, box, q.toFloat(), sourcesFor(p, l, gpu, t, q) + Analysis.sources(gpu, buf, t) + AudioVis.sources(p, gpu, t) + historySource(p, l, gpu, t, tr, bw, bh, q), tr.rot.toFloat(), exporting)
            GlFx.apply(buf, job)?.let { buf.recycle(); buf = it }
        }
        val rect = RectF((-bw / q / 2).toFloat(), (-bh / q / 2).toFloat(), (bw / q / 2).toFloat(), (bh / q / 2).toFloat())
        val lf = l.copy(flipX = null, flipY = null)
        val samples = ArrayList<TR>()
        if (mb != null) {
            val pix = mb.type == "pixelmb"
            val span = max(0.0, mb.value(if (pix) "obturatoAcis" else "deklansoAcis", t)) / 360.0 / p.fps * 2 * (if (pix) mb.value("hareketHass", t) / 50 else 1.0)
            val phase = if (pix) 0.0 else mb.value("deklansoFazi", t) / 360.0
            val usePos = pix || mb.value("konumuIzle", t) >= .5; val useScl = pix || mb.value("olcegiIzle", t) >= .5; val useAng = pix || mb.value("donmeyiIzle", t) >= .5
            fun trAt(u: Double): TR { val tt = (t + span * (u - 0.5 + phase)).coerceIn(l.start, l.end - 1e-4); val w = worldTransform(p, l, tt); return tr.copy(x = if (usePos) w.x else tr.x, y = if (usePos) w.y else tr.y, scale = if (useScl) w.scale else tr.scale, rot = if (useAng) w.rot else tr.rot) }
            val a0 = trAt(0.0); val a1 = trAt(1.0); val rr = hypot(l.w, l.h) / 2
            val dist = (hypot(a1.x - a0.x, a1.y - a0.y) + kotlin.math.abs(a1.scale - a0.scale) * rr + kotlin.math.abs(a1.rot - a0.rot) * PI / 180 * rr * tr.scale) * curQ
            val want = mb.value("ornekSayi", t).roundToInt().coerceIn(2, 256)
            val n = if (dist < 1 || span <= 0) 1 else if (exporting) max(6, min(want, kotlin.math.ceil(dist / (1.6 - fxQuality)).toInt()))
                else min(if (playing) 6 else 16, max(4, min(want, (dist / 4).toInt())))
            if (n <= 1) samples += tr else for (i in 0 until n) samples += trAt(i / (n - 1.0))
        } else samples += tr
        val pt = Paint().apply { this.alpha = alpha; if (blend != null && Build.VERSION.SDK_INT >= 29) blendMode = blend }
        if (samples.size == 1) {
            if (alpha < 255 || blend != null) {
                val rr = (hypot(bw / q, bh / q) / 2 * world).toFloat() + 4f
                c.saveLayer(tr.x.toFloat() - rr, tr.y.toFloat() - rr, tr.x.toFloat() + rr, tr.y.toFloat() + rr, pt)
                drawTransformed(c, lf, tr, buf, rect); c.restore()
            } else drawTransformed(c, lf, tr, buf, rect)
            buf.recycle(); return
        }
        // Hareket bulanıklığı: ara anları sahne biriminde topla (ortalama)
        val sq = curQ.toDouble()
        var x0 = Double.MAX_VALUE; var y0 = Double.MAX_VALUE; var x1 = -Double.MAX_VALUE; var y1 = -Double.MAX_VALUE
        for (s in samples) { val rr = hypot(bw / q, bh / q) / 2 * kotlin.math.abs(s.scale) * max(s.sx, s.sy); x0 = min(x0, s.x - rr); y0 = min(y0, s.y - rr); x1 = max(x1, s.x + rr); y1 = max(y1, s.y + rr) }
        x0 = max(x0, -pad); y0 = max(y0, -pad); x1 = min(x1, p.width + pad); y1 = min(y1, p.height + pad)
        val aw = kotlin.math.ceil((x1 - x0) * sq).toInt(); val ah = kotlin.math.ceil((y1 - y0) * sq).toInt()
        if (aw <= 0 || ah <= 0 || aw > 8192 || ah > 8192) { buf.recycle(); return }
        val acc = IntArray(aw * ah * 4); val px = IntArray(aw * ah)
        val tmp = Bitmap.createBitmap(aw, ah, Bitmap.Config.ARGB_8888); val tc = Canvas(tmp); tc.scale(sq.toFloat(), sq.toFloat()); tc.translate(-x0.toFloat(), -y0.toFloat())
        for (s in samples) {
            tmp.eraseColor(0); drawTransformed(tc, lf, s, buf, rect); tmp.getPixels(px, 0, aw, 0, 0, aw, ah); premul(px)
            for (i in px.indices) { val v = px[i]; if (v == 0) continue; val k = i * 4; acc[k] += v ushr 24; acc[k + 1] += (v shr 16) and 255; acc[k + 2] += (v shr 8) and 255; acc[k + 3] += v and 255 }
        }
        val n = samples.size
        for (i in px.indices) { val k = i * 4; px[i] = ((acc[k] / n) shl 24) or ((acc[k + 1] / n) shl 16) or ((acc[k + 2] / n) shl 8) or (acc[k + 3] / n) }
        unpremul(px); tmp.setPixels(px, 0, aw, 0, 0, aw, ah)
        c.drawBitmap(tmp, null, RectF(x0.toFloat(), y0.toFloat(), (x0 + aw / sq).toFloat(), (y0 + ah / sq).toFloat()), Paint(Paint.FILTER_BITMAP_FLAG).apply { this.alpha = alpha; if (blend != null && Build.VERSION.SDK_INT >= 29) blendMode = blend })
        tmp.recycle(); buf.recycle()
    }

    private var bgDepth = 0
    /** Efektlerin "Kaynak seçici" ayarlarındaki katmanlar (harita, doku…): kendi düzleminde, aynı boyutta çizilir */
    private fun sourcesFor(p: Project, l: Layer, fx: List<Effect>, t: Double, q: Double): Map<String, Bitmap> {
        val out = HashMap<String, Bitmap>()
        if (fx.any { it.type == "copybg" || it.type == "magnifybg" || it.type == "blackhole" || (it.type == "dispmap" && it.value("etkiAlan", t).roundToInt() == 1) || (it.type == "wetsurface" && it.value("yansimaKayn", t).roundToInt() == 1) } && bgDepth < 2) {
            // Katmanın arkasındaki görüntü, katmanın kendi düzleminde (kutusu boyunda)
            val w = kotlin.math.ceil(l.w * q).toInt().coerceIn(1, 2048); val h = kotlin.math.ceil(l.h * q).toInt().coerceIn(1, 2048)
            val b = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888); val cc = Canvas(b)
            val tr = worldTransform(p, l, t)
            cc.translate(w / 2f, h / 2f); cc.scale(q.toFloat(), q.toFloat()); cc.scale(1f / tr.scale.toFloat(), 1f / tr.scale.toFloat()); cc.rotate(-tr.rot.toFloat()); cc.translate(-tr.x.toFloat(), -tr.y.toFloat())
            paint.reset(); paint.color = parseCol(p.background, android.graphics.Color.WHITE); cc.drawRect(0f, 0f, p.width.toFloat(), p.height.toFloat(), paint)
            bgDepth++
            try { for (below in p.layers) { if (below.id == l.id) break; if (below.type == "audio" || below.hidden == true || t < below.start || t >= below.end) continue; paintLayer(cc, p, below, t) } } finally { bgDepth-- }
            out["bgsrc"] = b
        }
        for (e in fx) for (pr in fxMeta(e.type).params) if (pr.kind == "source") {
            val id = e.c?.get(pr.key) ?: continue
            val src = p.layers.find { it.id == id } ?: continue
            if (src.id == l.id) continue
            val w = kotlin.math.ceil(src.w * q).toInt().coerceIn(1, 2048); val h = kotlin.math.ceil(src.h * q).toInt().coerceIn(1, 2048)
            val b = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
            val cc = Canvas(b); cc.translate(w / 2f, h / 2f); cc.scale(q.toFloat(), q.toFloat()); drawLayer(cc, src)
            out[pr.key] = b
        }
        return out
    }

    private fun blendOf(b: String?): BlendMode? = if (Build.VERSION.SDK_INT < 29) null else when (b) {
        "multiply" -> BlendMode.MULTIPLY; "screen" -> BlendMode.SCREEN; "overlay" -> BlendMode.OVERLAY
        "darken" -> BlendMode.DARKEN; "lighten" -> BlendMode.LIGHTEN; "color-dodge" -> BlendMode.COLOR_DODGE
        "difference" -> BlendMode.DIFFERENCE; else -> null
    }

    private fun fillPaint(l: Layer): Paint {
        paint.reset(); paint.isAntiAlias = true; paint.style = Paint.Style.FILL
        val g = l.grad
        if (l.fill2 != null && g != null) {
            val ax = (g.x1 * l.w).toFloat(); val ay = (g.y1 * l.h).toFloat(); val bx = (g.x2 * l.w).toFloat(); val by = (g.y2 * l.h).toFloat()
            paint.shader = if (l.gtype == "radial") RadialGradient(ax, ay, max(1f, hypot(bx - ax, by - ay)), parseCol(l.fill), parseCol(l.fill2), Shader.TileMode.CLAMP)
            else LinearGradient(ax, ay, bx, by, parseCol(l.fill), parseCol(l.fill2), Shader.TileMode.CLAMP)
        } else paint.color = parseCol(l.fill)
        return paint
    }

    private fun drawBitmap(c: Canvas, b: Bitmap, dst: RectF) {
        paint.reset(); paint.isAntiAlias = true; paint.isFilterBitmap = true
        c.drawBitmap(b, null, dst, paint)
    }

    fun drawLayer(c: Canvas, l: Layer) {
        val w = l.w.toFloat(); val h = l.h.toFloat()
        val crop = l.crop
        if (crop != null && l.type != "shape" && l.type != "text") { c.save(); c.clipRect(l.visBox()) }
        when (l.type) {
            "shape" -> if (l.noFill != true) fillShape(c, l, fillPaint(l))
            "text" -> {
                val fp = fillPaint(l)
                fp.typeface = bold; fp.textSize = (l.fontSize ?: 64.0).toFloat(); fp.textAlign = Paint.Align.CENTER
                if (FxText.has(l)) { FxText.draw(c, l, Paint(fp), curT); if (crop != null) c.restore(); return }
                val lines = (l.text ?: "").split("\n")
                val lh = fp.textSize * 1.15f
                val fm = fp.fontMetrics
                val mid = -(fm.ascent + fm.descent) / 2
                lines.forEachIndexed { i, ln -> c.drawText(ln, 0f, (i - (lines.size - 1) / 2f) * lh + mid, fp) }
            }
            "image" -> l.src?.let { s -> image(s)?.let { drawBitmap(c, it, RectF(-w / 2, -h / 2, w / 2, h / 2)) } }
            "video" -> {
                val v = l.src?.let { video(it) }
                val fr = v?.let { if (sync) it.frameSync(fxLocalTime(l, curT) + (l.srcIn ?: 0.0)) else it.frame(fxLocalTime(l, curT) + (l.srcIn ?: 0.0), playing) }
                if (fr != null) drawBitmap(c, fr, RectF(-w / 2, -h / 2, w / 2, h / 2))
                else { paint.reset(); paint.color = 0xFF26386C.toInt(); c.drawRect(-w / 2, -h / 2, w / 2, h / 2, paint) }
            }
            "cb" -> {
                val r = min(w, h) / 2
                c.save()
                c.clipPath(Path().apply { addCircle(0f, 0f, r, Path.Direction.CW) })
                val img = l.src?.let { image(it) }
                if (img != null) {
                    val k = max(2 * r / img.width, 2 * r / img.height)
                    drawBitmap(c, img, RectF(-img.width * k / 2, -img.height * k / 2, img.width * k / 2, img.height * k / 2))
                } else { paint.reset(); paint.color = 0xFFC9D3E3.toInt(); c.drawCircle(0f, 0f, r, paint) }
                c.restore()
                val ow = (l.cb?.outline ?: 6.0).toFloat()
                if (ow > 0) { paint.reset(); paint.isAntiAlias = true; paint.style = Paint.Style.STROKE; paint.strokeWidth = ow; paint.color = android.graphics.Color.BLACK; c.drawCircle(0f, 0f, r - ow / 2, paint) }
                l.cb?.eyes?.let { e -> image(e)?.let { val ew = r * 1.3f; drawBitmap(c, it, RectF(-ew / 2, -r * 0.62f, ew / 2, -r * 0.62f + ew)) } }
            }
        }
        if (crop != null && l.type != "shape" && l.type != "text") c.restore()
    }
}

val IDENT = TR(0.0, 0.0, 0.0, 1.0, 1.0)

fun parentWorld(p: Project, l: Layer, t: Double): TR = l.parent?.let { id -> p.layers.find { it.id == id } }?.let { worldTransform(p, it, t) } ?: IDENT

/** Sahnedeki bir değeri (dünya) ebeveynin yerel koordinatına çevirir */
fun toLocal(pw: TR, w: TR): TR {
    val a = -pw.rot * PI / 180
    val dx = (w.x - pw.x) / pw.scale; val dy = (w.y - pw.y) / pw.scale
    return TR(dx * cos(a) - dy * sin(a), dx * sin(a) + dy * cos(a), w.rot - pw.rot, w.scale / pw.scale, w.opacity)
}

/** Önizlemede dokunulan katman (üstten alta) */
fun hitTest(p: Project, t: Double, px: Double, py: Double, only: String? = null): Layer? {
    for (i in p.layers.indices.reversed()) {
        val l = p.layers[i]
        if (only != null && l.id != only) continue
        if (l.type == "audio" || l.hidden == true || t < l.start || t >= l.end) continue
        val tr = worldTransform(p, l, t)
        val a = -tr.rot * PI / 180; val dx = px - tr.x; val dy = py - tr.y
        val lx = dx * cos(a) - dy * sin(a); val ly = dx * sin(a) + dy * cos(a)
        val b = l.visBox()
        val ux = lx / tr.scale * (if (l.flipX == true) -1 else 1); val uy = ly / tr.scale * (if (l.flipY == true) -1 else 1)
        if (ux >= b.left && ux <= b.right && uy >= b.top && uy <= b.bottom) return l
    }
    return null
}

/** Seçili katmanın tutamaçlarından noktaya en yakını */
fun pickHandle(p: Project, l: Layer, t: Double, px: Double, py: Double, tol: Double): com.warden.motion.app.model.Handle? {
    val tr = worldTransform(p, l, t)
    val a = tr.rot * PI / 180; val fx = if (l.flipX == true) -1 else 1; val fy = if (l.flipY == true) -1 else 1
    var best: com.warden.motion.app.model.Handle? = null; var bd = tol
    for (hd in com.warden.motion.app.model.layerHandles(l)) {
        val lx = hd.x * fx * tr.scale; val ly = hd.y * fy * tr.scale
        val wx = tr.x + lx * cos(a) - ly * sin(a); val wy = tr.y + lx * sin(a) + ly * cos(a)
        val d = hypot(wx - px, wy - py)
        if (d < bd - (if (hd.kind == "special" || hd.kind == "vertex") 0.5 else 0.0)) { bd = d; best = hd }
    }
    return best
}

/** Seçim kutusu + tutamaçlar (+ renk geçişi noktaları). q: proje→ekran oranı */
fun drawSelection(c: Canvas, l: Layer, tr: TR, q: Float, grad: Boolean) {
    val pt = Paint(Paint.ANTI_ALIAS_FLAG)
    c.save()
    c.scale(q, q)
    c.translate(tr.x.toFloat(), tr.y.toFloat())
    c.rotate(tr.rot.toFloat())
    val fx = if (l.flipX == true) -1f else 1f; val fy = if (l.flipY == true) -1f else 1f; val k = tr.scale.toFloat()
    val lw = 2f / q
    val b = l.visBox()
    pt.style = Paint.Style.STROKE; pt.strokeWidth = lw; pt.color = 0xFF3B9BFF.toInt()
    c.drawRect(minOf(b.left * fx, b.right * fx) * k, minOf(b.top * fy, b.bottom * fy) * k, maxOf(b.left * fx, b.right * fx) * k, maxOf(b.top * fy, b.bottom * fy) * k, pt)
    val hr = lw * 3.5f
    if (l.shape == "custom" && l.pts != null) {
        val path = Path(); l.pts.forEachIndexed { i, p0 -> val x = (p0[0] * l.w * k * fx).toFloat(); val y = (p0[1] * l.h * k * fy).toFloat(); if (i == 0) path.moveTo(x, y) else path.lineTo(x, y) }; path.close()
        pt.color = 0xFF22D3C5.toInt(); pt.pathEffect = android.graphics.DashPathEffect(floatArrayOf(lw * 3, lw * 2), 0f); c.drawPath(path, pt); pt.pathEffect = null
    }
    for (hd in com.warden.motion.app.model.layerHandles(l)) {
        val x = (hd.x * k * fx).toFloat(); val y = (hd.y * k * fy).toFloat()
        val special = hd.kind == "special" || hd.kind == "vertex"
        pt.style = Paint.Style.FILL; pt.color = if (special) 0xFF22D3C5.toInt() else 0xFFDCE9FF.toInt()
        val shape: () -> Unit = if (hd.kind == "crop") {
            val vert = hd.id == "k-l" || hd.id == "k-r"
            val r = RectF(x - (if (vert) hr * .6f else hr * 2.2f), y - (if (vert) hr * 2.2f else hr * .6f), x + (if (vert) hr * .6f else hr * 2.2f), y + (if (vert) hr * 2.2f else hr * .6f))
            ({ c.drawRoundRect(r, hr * .6f, hr * .6f, pt) })
        } else ({ c.drawCircle(x, y, if (special) hr * 1.25f else hr, pt) })
        shape()
        pt.style = Paint.Style.STROKE; pt.strokeWidth = lw; pt.color = if (special) 0xFF0B1430.toInt() else 0xFF3B9BFF.toInt()
        shape()
    }
    val g = l.grad
    if (grad && g != null && l.fill2 != null) {
        val ax = (g.x1 * l.w * k).toFloat(); val ay = (g.y1 * l.h * k).toFloat(); val bx = (g.x2 * l.w * k).toFloat(); val by = (g.y2 * l.h * k).toFloat()
        pt.style = Paint.Style.STROKE; pt.color = 0xFFF7F8FA.toInt(); pt.strokeWidth = lw; c.drawLine(ax, ay, bx, by, pt)
        for ((x, y, col) in listOf(Triple(ax, ay, l.fill), Triple(bx, by, l.fill2))) {
            pt.style = Paint.Style.FILL; pt.color = parseCol(col); c.drawCircle(x, y, hr * 1.6f, pt)
            pt.style = Paint.Style.STROKE; pt.color = 0xFF0B1430.toInt(); pt.strokeWidth = lw * 1.5f; c.drawCircle(x, y, hr * 1.6f, pt)
        }
    }
    c.restore()
}

/** Konum keyframe'leri arasındaki yol */
fun drawMotionPath(c: Canvas, p: Project, l: Layer, q: Float) {
    val ts = ((l.x.k ?: emptyList()) + (l.y.k ?: emptyList())).map { it.t }.distinct().sorted()
    if (ts.size < 2) return
    val t0 = ts.first(); val t1 = ts.last()
    val lw = 1.5f / q
    c.save(); c.scale(q, q)
    val path = Path()
    val n = maxOf(24, ((t1 - t0) * 30).toInt())
    for (i in 0..n) { val w = worldTransform(p, l, t0 + (t1 - t0) * i / n); if (i == 0) path.moveTo(w.x.toFloat(), w.y.toFloat()) else path.lineTo(w.x.toFloat(), w.y.toFloat()) }
    val pt = Paint(Paint.ANTI_ALIAS_FLAG).apply { style = Paint.Style.STROKE }
    pt.color = 0x800D1631.toInt(); pt.strokeWidth = lw * 2.2f; c.drawPath(path, pt)
    pt.color = 0xFFF7F8FA.toInt(); pt.strokeWidth = lw; c.drawPath(path, pt)
    pt.style = Paint.Style.FILL; pt.color = 0xFF22D3C5.toInt()
    for (kt in ts) { val w = worldTransform(p, l, kt); c.drawCircle(w.x.toFloat(), w.y.toFloat(), lw * 3, pt) }
    c.restore()
}
