package com.warden.motion.app.model

import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Path
import android.graphics.RectF
import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.min
import kotlin.math.roundToInt
import kotlin.math.sin

/** Şekil ayarlarının varsayılanları (Şekli Düzenle) */
val SHAPE_DEFS: Map<String, Map<String, Double>> = mapOf(
    "roundrect" to mapOf("rad" to 0.18),
    "star" to mapOf("n" to 5.0, "inner" to 0.45),
    "hexagon" to mapOf("n" to 6.0),
    "polygon" to mapOf("n" to 5.0),
    "plus" to mapOf("thick" to 0.32),
    "bar" to mapOf("round" to 1.0),
    "crescent" to mapOf("cx" to 0.3, "cy" to -0.1, "r" to 0.9),
)

fun Layer.sp(key: String): Double = sp?.get(key) ?: SHAPE_DEFS[shape]?.get(key) ?: 0.0

fun regularPts(n: Int): List<List<Double>> = List(n) { i ->
    val a = PI * 2 / n * i - PI / 2
    listOf((cos(a) * 500).roundToInt() / 1000.0, (sin(a) * 500).roundToInt() / 1000.0)
}

/** Şeklin yolu, katmanın merkezine göre (hilal hariç) */
fun shapePath(l: Layer): Path {
    val p = Path()
    val w = l.w.toFloat(); val h = l.h.toFloat()
    val hw = w / 2; val hh = h / 2
    fun poly(pts: List<Pair<Float, Float>>) { pts.forEachIndexed { i, (x, y) -> if (i == 0) p.moveTo(x, y) else p.lineTo(x, y) }; p.close() }
    when (l.shape) {
        "circle", "crescent" -> p.addOval(RectF(-hw, -hh, hw, hh), Path.Direction.CW)
        "rect" -> p.addRect(-hw, -hh, hw, hh, Path.Direction.CW)
        "roundrect" -> { val r = (min(w, h) * l.sp("rad")).toFloat(); p.addRoundRect(RectF(-hw, -hh, hw, hh), r, r, Path.Direction.CW) }
        "bar" -> { val r = if (l.sp("round") != 0.0) min(w, h) / 2 else 0f; p.addRoundRect(RectF(-hw, -hh, hw, hh), r, r, Path.Direction.CW) }
        "triangle" -> poly(listOf(0f to -hh, hw to hh, -hw to hh))
        "hexagon", "polygon" -> {
            val n = l.sp("n").roundToInt().coerceAtLeast(3)
            poly(List(n) { i -> val a = PI * 2 / n * i - PI / 2; (cos(a) * hw).toFloat() to (sin(a) * hh).toFloat() })
        }
        "star" -> {
            val n = l.sp("n").roundToInt().coerceAtLeast(3); val r0 = l.sp("inner")
            poly(List(n * 2) { i -> val r = if (i % 2 == 1) r0 else 1.0; val a = PI / n * i - PI / 2; (cos(a) * hw * r).toFloat() to (sin(a) * hh * r).toFloat() })
        }
        "custom" -> poly((l.pts ?: regularPts(5)).map { (it[0] * w).toFloat() to (it[1] * h).toFloat() })
        "plus" -> {
            val t = l.sp("thick").toFloat()
            p.addRect(-hw * t, -hh, hw * t, hh, Path.Direction.CW)
            p.addRect(-hw, -hh * t, hw, hh * t, Path.Direction.CW)
            p.fillType = Path.FillType.WINDING
        }
        "heart" -> {
            p.moveTo(0f, hh)
            p.cubicTo(-hw * 1.3f, -hh * 0.1f, -hw * 0.6f, -hh * 1.2f, 0f, -hh * 0.45f)
            p.cubicTo(hw * 0.6f, -hh * 1.2f, hw * 1.3f, -hh * 0.1f, 0f, hh)
            p.close()
        }
        else -> p.addRect(-hw, -hh, hw, hh, Path.Direction.CW)
    }
    return p
}

/** Şekli doldurur (hilal: dış elips − iç elips) */
fun fillShape(c: Canvas, l: Layer, paint: Paint) {
    if (l.shape == "crescent") {
        val w = l.w.toFloat(); val h = l.h.toFloat()
        val outer = shapePath(l)
        val cut = Path().apply {
            val r = l.sp("r"); val cx = (l.sp("cx") * w).toFloat(); val cy = (l.sp("cy") * h).toFloat()
            addOval(RectF(cx - (r * w / 2).toFloat(), cy - (r * h / 2).toFloat(), cx + (r * w / 2).toFloat(), cy + (r * h / 2).toFloat()), Path.Direction.CW)
        }
        outer.op(cut, Path.Op.DIFFERENCE)
        c.drawPath(outer, paint)
        return
    }
    c.drawPath(shapePath(l), paint)
}

/** Görünen kutu (kırpma dahil), katmanın merkezine göre */
fun Layer.visBox(): RectF {
    val c = crop ?: Crop()
    return RectF((-w / 2 + c.l * w).toFloat(), (-h / 2 + c.t * h).toFloat(), (w / 2 - c.r * w).toFloat(), (h / 2 - c.b * h).toFloat())
}

