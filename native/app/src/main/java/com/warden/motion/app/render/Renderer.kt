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
class Renderer(private val ctx: Context, private val maxSide: Int = 2048) {
    private val store = Store.get(ctx)
    private val cache = object : LruCache<String, Bitmap>(64 * 1024 * 1024) { override fun sizeOf(key: String, value: Bitmap) = value.byteCount }
    private val loading = HashSet<String>()
    private val failed = HashSet<String>()
    private val io = CoroutineScope(SupervisorJob() + Dispatchers.IO)
    private val _version = MutableStateFlow(0)
    /** Bir görsel yüklendiğinde artar (ekran yeniden çizilsin) */
    val version: StateFlow<Int> = _version

    fun image(src: String): Bitmap? {
        cache.get(src)?.let { return it }
        if (src in failed) return null
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
            paintLayer(c, p, l, t)
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
