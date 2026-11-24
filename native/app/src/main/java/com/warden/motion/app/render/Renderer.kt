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
import com.warden.motion.app.model.Layer
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
import kotlin.math.cos
import kotlin.math.floor
import kotlin.math.hypot
import kotlin.math.max
import kotlin.math.min
import kotlin.math.sin

/** Katmanın sahnedeki dönüşümü */
data class TR(val x: Double, val y: Double, val rot: Double, val scale: Double, val opacity: Double)

private fun noise(t: Double, seed: Int) = sin(t * 12.9898 + seed * 78.233) * 0.5 + sin(t * 4.1 + seed) * 0.5

fun layerTransform(l: Layer, t: Double): TR {
    var x = l.x.at(t); var y = l.y.at(t); var rot = l.rotation.at(t)
    val local = t - l.start
    for (e in l.effects) {
        if (e.type == "sway") rot += sin(local * e.value("speed", t) * PI * 2) * e.value("amount", t)
        if (e.type == "shake") {
            val sp = e.value("speed", t); val am = e.value("amount", t)
            val tt = floor(local * sp * 10) / (if (sp == 0.0) 1.0 else sp * 10)
            x += noise(tt, 1) * am; y += noise(tt, 2) * am
        }
    }
    return TR(x, y, rot, l.scale.at(t), l.opacity.at(t))
}

/** Takip zinciri (ebeveyn) dahil gerçek dönüşüm */
fun worldTransform(p: Project, l: Layer, t: Double, depth: Int = 0): TR {
    val loc = layerTransform(l, t)
    val par = if (l.parent != null && depth < 8) p.layers.find { it.id == l.parent } else null
    if (par == null) return loc
    val pw = worldTransform(p, par, t, depth + 1)
    val a = pw.rot * PI / 180
    return TR(
        pw.x + (loc.x * cos(a) - loc.y * sin(a)) * pw.scale,
        pw.y + (loc.x * sin(a) + loc.y * cos(a)) * pw.scale,
        pw.rot + loc.rot, pw.scale * loc.scale, loc.opacity,
    )
}

fun parseCol(hex: String?, def: Int = 0xFF8F7CF0.toInt()): Int = runCatching { android.graphics.Color.parseColor(hex) }.getOrDefault(def)

/**
 * Çizim motoru: bir projenin t anındaki karesini Android Canvas'a çizer (donanım hızlandırmalı).
 * Görseller önbellekte tutulur; önizlemede küçültülmüş (maxSide), dışa aktarmada asıl hâliyle.
 */
class Renderer(private val ctx: Context, private val maxSide: Int = 2048, private val sync: Boolean = false, cacheMb: Int = 64) {
    private val store = Store.get(ctx)
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

    private val paint = Paint(Paint.ANTI_ALIAS_FLAG or Paint.FILTER_BITMAP_FLAG)
    private val bold = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)

    /** scale: proje pikselinden ekran pikseline oran */
    fun draw(c: Canvas, p: Project, t: Double, scale: Float) {
        c.save()
        c.scale(scale, scale)
        paint.reset(); paint.isAntiAlias = true
        paint.color = parseCol(p.background, android.graphics.Color.WHITE)
        c.drawRect(0f, 0f, p.width.toFloat(), p.height.toFloat(), paint)
        c.clipRect(0f, 0f, p.width.toFloat(), p.height.toFloat())
        for (l in p.layers) {
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

    private fun paintLayer(c: Canvas, p: Project, l: Layer, t: Double) {
        val tr = worldTransform(p, l, t)
        val alpha = (tr.opacity.coerceIn(0.0, 1.0) * 255).toInt()
        if (alpha <= 0) return
        val blend = blendOf(l.blend)
        val needLayer = alpha < 255 || blend != null
        c.save()
        c.translate(tr.x.toFloat(), tr.y.toFloat())
        c.rotate(tr.rot.toFloat())
        c.scale(tr.scale.toFloat(), tr.scale.toFloat())
        val mirror = l.effects.any { it.type == "mirror" }
        if (mirror) c.scale(-1f, 1f)
        if (l.flipX == true || l.flipY == true) c.scale(if (l.flipX == true) -1f else 1f, if (l.flipY == true) -1f else 1f)
        if (needLayer) {
            val lp = Paint().apply { this.alpha = alpha; if (blend != null && Build.VERSION.SDK_INT >= 29) blendMode = blend }
            val r = (hypot(l.w, l.h) * 0.75).toFloat() + 4f
            c.saveLayer(-r, -r, r, r, lp)
        }
        drawLayer(c, l)
        if (needLayer) c.restore()
        c.restore()
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
                val lines = (l.text ?: "").split("\n")
                val lh = fp.textSize * 1.15f
                val fm = fp.fontMetrics
                val mid = -(fm.ascent + fm.descent) / 2
                lines.forEachIndexed { i, ln -> c.drawText(ln, 0f, (i - (lines.size - 1) / 2f) * lh + mid, fp) }
            }
            "image" -> l.src?.let { s -> image(s)?.let { drawBitmap(c, it, RectF(-w / 2, -h / 2, w / 2, h / 2)) } }
            "video" -> { paint.reset(); paint.color = 0xFF26386C.toInt(); c.drawRect(-w / 2, -h / 2, w / 2, h / 2, paint) }
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
