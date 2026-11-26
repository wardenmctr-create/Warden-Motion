package com.warden.motion.app.render

import android.graphics.Canvas
import android.graphics.DashPathEffect
import android.graphics.Paint
import android.graphics.Path
import android.graphics.PathMeasure
import android.graphics.RectF
import com.warden.motion.app.model.Effect
import com.warden.motion.app.model.Layer
import com.warden.motion.app.model.fxMeta
import com.warden.motion.app.model.shapePath
import com.warden.motion.app.model.value
import kotlin.math.PI
import kotlin.math.atan2
import kotlin.math.cos
import kotlin.math.max
import kotlin.math.min
import kotlin.math.roundToInt
import kotlin.math.sin
import kotlin.math.sqrt

/** Efektin renk ayarı (yoksa katalogdaki varsayılan) */
fun Effect.color(k: String, def: String = "#FFFFFF"): Int = parseCol(c?.get(k) ?: fxMeta(type).params.find { it.key == k }?.defStr ?: def)

/**
 * Şekil efektleri (uygulamanın şekil katmanları):
 * 70 Çizerek Belirme, 102 Çizgi İnceltme, 271 Yol Dönüşümü, 418 CB Gezi Çizgisi (rota çizgisi), 417 CB Sınır Çizimi.
 */
object ShapeFx {
    private fun Layer.fx(type: String) = effects.find { it.type == type && it.on != false }

    fun has(l: Layer) = l.type == "shape" && l.effects.any { it.on != false && it.type in TYPES }
    private val TYPES = setOf("drawpath", "stroketaper", "morphpath", "cbtrail")

    /** Şeklin yolu; Yol Dönüşümü varsa hedef şekle doğru ara yol */
    fun path(l: Layer, t: Double): Path {
        val base = shapePath(l)
        val e = l.fx("morphpath") ?: return base
        val k = (e.value("ilerleme", t) / 100).coerceIn(0.0, 1.0); if (k <= 0.0) return base
        val n = e.value("noktaSayi", t).roundToInt().coerceIn(8, 512)
        val a = sample(base, n)
        val hw = l.w / 2; val hh = l.h / 2
        val tgt = Path().apply {
            when (e.value("hedefSeki", t).roundToInt()) {
                0 -> addOval(RectF((-hw).toFloat(), (-hh).toFloat(), hw.toFloat(), hh.toFloat()), Path.Direction.CW)
                1 -> addRect((-hw).toFloat(), (-hh).toFloat(), hw.toFloat(), hh.toFloat(), Path.Direction.CW)
                else -> { for (i in 0 until 10) { val r = if (i % 2 == 1) 0.45 else 1.0; val an = PI / 5 * i - PI / 2; val x = (cos(an) * hw * r).toFloat(); val y = (sin(an) * hh * r).toFloat(); if (i == 0) moveTo(x, y) else lineTo(x, y) }; close() }
            }
        }
        var b = sample(tgt, n)
        if (e.value("yonuTersCevi", t) >= 0.5) b = b.reversed()
        // başlangıç noktası: hedefin ilk noktasını kaydırır; ayrıca kaynağa en yakın noktaya hizalar
        val off0 = (0 until n).minByOrNull { j -> val q = b[j]; (q[0] - a[0][0]) * (q[0] - a[0][0]) + (q[1] - a[0][1]) * (q[1] - a[0][1]) } ?: 0
        val off = (off0 + (e.value("baslangiNokt", t) / 100 * n).roundToInt()).mod(n)
        b = List(n) { b[(it + off) % n] }
        var pts = List(n) { i -> floatArrayOf((a[i][0] + (b[i][0] - a[i][0]) * k).toFloat(), (a[i][1] + (b[i][1] - a[i][1]) * k).toFloat()) }
        if (e.value("alaniKoru", t) >= 0.5) { // ara şeklin alanını kaynağın alanına eşitle
            val s = sqrt(max(1e-6, area(a)) / max(1e-6, area(pts))).toFloat(); pts = pts.map { floatArrayOf(it[0] * s, it[1] * s) }
        }
        return Path().apply { pts.forEachIndexed { i, q -> if (i == 0) moveTo(q[0], q[1]) else lineTo(q[0], q[1]) }; close() }
    }

    private fun area(p: List<FloatArray>): Double { var s = 0.0; for (i in p.indices) { val a = p[i]; val b = p[(i + 1) % p.size]; s += a[0] * b[1] - b[0] * a[1].toDouble() }; return kotlin.math.abs(s) / 2 }

    /** Yolu eşit aralıklı n noktaya böler (yalnız ilk kontur) */
    fun sample(p: Path, n: Int): List<FloatArray> {
        val pm = PathMeasure(p, true); val len = max(1e-3f, pm.length); val pos = FloatArray(2)
        return List(n) { i -> pm.getPosTan(len * i / n, pos, null); floatArrayOf(pos[0], pos[1]) }
    }

    /** Şekil katmanını efektleriyle çizer (drawLayer içinden, katmanın yerel düzleminde). */
    fun draw(c: Canvas, l: Layer, fill: Paint, t: Double) {
        val path = path(l, t)
        val dp = l.fx("drawpath"); val tp = l.fx("stroketaper"); val tr = l.fx("cbtrail")
        val hideFill = (dp != null && dp.value("yalnizCizg", t) >= 0.5) || tr != null
        if (!hideFill && l.noFill != true) c.drawPath(path, fill)
        if (dp == null && tp == null && tr == null) return
        var a0 = 0.0; var a1 = 1.0; var w = 5.0; var col = parseCol(l.fill); var cap = Paint.Cap.ROUND; var rev = false; var dash: FloatArray? = null
        if (dp != null) {
            a0 = (dp.value("baslangi", t) / 100).coerceIn(0.0, 1.0); a1 = (dp.value("bitis", t) / 100).coerceIn(0.0, 1.0)
            w = dp.value("cizgiKali", t); if (dp.value("kaynakCizgKull", t) < 0.5) col = dp.color("renk")
            cap = when (dp.value("uc", t).roundToInt()) { 1 -> Paint.Cap.BUTT; 2 -> Paint.Cap.SQUARE; else -> Paint.Cap.ROUND }; rev = dp.value("tersYon", t) >= 0.5
        }
        if (tr != null) {
            a0 = 0.0; a1 = (tr.value("ilerleme", t) / 100).coerceIn(0.0, 1.0); w = tr.value("kalinlik", t); col = tr.color("cizgiReng", "#55AAFF")
            if (tr.value("kesikli", t) >= 0.5) dash = floatArrayOf((w * 3).toFloat().coerceAtLeast(2f), (w * 2).toFloat().coerceAtLeast(2f))
        }
        if (a1 < a0) { val x = a0; a0 = a1; a1 = x }
        val pm = PathMeasure(path, false)
        do {
            val len = pm.length; if (len <= 0f) continue
            var s0 = (a0 * len).toFloat(); var s1 = (a1 * len).toFloat(); if (rev) { val x = len - s1; s1 = len - s0; s0 = x }
            if (s1 - s0 < 0.01f) continue
            if (tp != null) taper(c, pm, s0, s1, len, w, col, tp, t)
            else {
                val seg = Path(); pm.getSegment(s0, s1, seg, true)
                val pt = Paint(Paint.ANTI_ALIAS_FLAG).apply { style = Paint.Style.STROKE; strokeWidth = w.toFloat(); color = col; strokeCap = cap; strokeJoin = Paint.Join.ROUND; dash?.let { pathEffect = DashPathEffect(it, 0f) } }
                c.drawPath(seg, pt)
            }
            if (tr != null && tr.value("baslangiGost", t) >= 0.5) { val p0 = FloatArray(2); pm.getPosTan(0f, p0, null); c.drawCircle(p0[0], p0[1], (w * 1.6).toFloat(), Paint(Paint.ANTI_ALIAS_FLAG).apply { color = col }) }
        } while (pm.nextContour())
    }

    /** Uçlara doğru incelen çizgi: kalınlık profili başlangıç → orta → bitiş */
    private fun taper(c: Canvas, pm: PathMeasure, s0: Float, s1: Float, len: Float, w0: Double, col: Int, e: Effect, t: Double) {
        val ws = e.value("baslangiKali", t) / 100; val wm = e.value("ortaKali", t) / 100; val we = e.value("bitisKali", t) / 100
        val ls = max(1e-3, e.value("baslangiInceUzun", t) / 100); val le = max(1e-3, e.value("bitisInceUzun", t) / 100)
        val pt = Paint(Paint.ANTI_ALIAS_FLAG).apply { style = Paint.Style.STROKE; color = col; strokeCap = if (e.value("uclariYuva", t) >= 0.5) Paint.Cap.ROUND else Paint.Cap.BUTT }
        val step = max(0.75f, (s1 - s0) / 600f); val a = FloatArray(2); val b = FloatArray(2)
        var s = s0
        while (s < s1) {
            val sn = min(s1, s + step); val u = ((s + sn) / 2 / len).toDouble()
            val f = when { u < ls -> ws + (wm - ws) * smooth(u / ls); u > 1 - le -> we + (wm - we) * smooth((1 - u) / le); else -> wm }
            val ww = (w0 * f).toFloat(); if (ww > 0.05f) { pm.getPosTan(s, a, null); pm.getPosTan(sn, b, null); pt.strokeWidth = ww; c.drawLine(a[0], a[1], b[0], b[1], pt) }
            s = sn
        }
    }
    private fun smooth(x: Double): Double { val q = x.coerceIn(0.0, 1.0); return q * q * (3 - 2 * q) }

    /** Rota üzerindeki nokta ve yön (katmanın yerel düzleminde): CB Gezi Çizgisi simgesi için */
    fun routePoint(l: Layer, t: Double, u: Double): Triple<Float, Float, Float> {
        val pm = PathMeasure(path(l, t), false); val p = FloatArray(2); val tg = FloatArray(2)
        pm.getPosTan(pm.length * u.coerceIn(0.0, 1.0).toFloat(), p, tg)
        return Triple(p[0], p[1], (atan2(tg[1].toDouble(), tg[0].toDouble()) * 180 / PI).toFloat())
    }

    /** 417 CB Sınır Çizimi: kaynak şekil katmanının sınırını sahne koordinatında, ilerlemeye göre çizer */
    fun border(c: Canvas, src: Layer, e: Effect, t: Double, place: (Canvas) -> Unit) {
        val path = path(src, t); val k = (e.value("ilerleme", t) / 100).coerceIn(0.0, 1.0); if (k <= 0) return
        val rev = e.value("tersYon", t) >= 0.5; val w = e.value("kalinlik", t).toFloat()
        val pt = Paint(Paint.ANTI_ALIAS_FLAG).apply { style = Paint.Style.STROKE; strokeWidth = w; color = e.color("renk"); strokeJoin = Paint.Join.ROUND
            strokeCap = if (e.value("uc", t).roundToInt() == 1) Paint.Cap.BUTT else Paint.Cap.ROUND
            if (e.value("cizgiBici", t).roundToInt() == 1) pathEffect = DashPathEffect(floatArrayOf(max(1f, e.value("kesikUzun", t).toFloat()), max(1f, e.value("bosluk", t).toFloat())), 0f) }
        c.save(); place(c)
        val pm = PathMeasure(path, false)
        do { val len = pm.length; if (len <= 0f) continue; val seg = Path()
            if (rev) pm.getSegment(len * (1 - k.toFloat()), len, seg, true) else pm.getSegment(0f, len * k.toFloat(), seg, true); c.drawPath(seg, pt) } while (pm.nextContour())
        c.restore()
    }
}
