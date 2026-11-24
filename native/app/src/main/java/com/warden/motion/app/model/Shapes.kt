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


// ---------------------------------------------------------------------------------------------
// Tutamaçlar (katmanın kendi koordinatında, ölçeksiz)
// ---------------------------------------------------------------------------------------------
/** kind: corner | edge | crop | special | vertex */
data class Handle(val id: String, val x: Double, val y: Double, val kind: String)

fun Layer.isAppShape() = type == "shape" && shape != null

fun layerHandles(l: Layer): List<Handle> {
    val b = l.visBox(); val mx = (b.left + b.right) / 2.0; val my = (b.top + b.bottom) / 2.0
    val out = ArrayList<Handle>()
    if (l.shape == "bar") return listOf(Handle("bar-len", l.w / 2, 0.0, "special"), Handle("bar-thk", 0.0, -l.h / 2, "special"))
    for ((sx, sy) in listOf(-1 to -1, 1 to -1, 1 to 1, -1 to 1)) out += Handle("c$sx$sy", (if (sx < 0) b.left else b.right).toDouble(), (if (sy < 0) b.top else b.bottom).toDouble(), "corner")
    if (l.isAppShape()) {
        out += Handle("e-x", b.left.toDouble(), my, "edge"); out += Handle("e+x", b.right.toDouble(), my, "edge")
        out += Handle("e-y", mx, b.top.toDouble(), "edge"); out += Handle("e+y", mx, b.bottom.toDouble(), "edge")
    } else if (l.type != "text") {
        out += Handle("k-l", b.left.toDouble(), my, "crop"); out += Handle("k-r", b.right.toDouble(), my, "crop")
        out += Handle("k-t", mx, b.top.toDouble(), "crop"); out += Handle("k-b", mx, b.bottom.toDouble(), "crop")
    }
    val mn = minOf(l.w, l.h)
    if (l.shape == "crescent") out += Handle("cres", l.sp("cx") * l.w, l.sp("cy") * l.h, "special")
    if (l.shape == "roundrect") { val o = maxOf(l.sp("rad") * mn, mn * 0.08); out += Handle("rad", -l.w / 2 + o, -l.h / 2 + o, "special") }
    if (l.shape == "star") {
        val n = l.sp("n").roundToInt(); val a = PI / n - PI / 2; val r = l.sp("inner")
        out += Handle("inner", cos(a) * l.w / 2 * r, sin(a) * l.h / 2 * r, "special")
    }
    if (l.shape == "custom") (l.pts ?: regularPts(5)).forEachIndexed { i, p -> out += Handle("v$i", p[0] * l.w, p[1] * l.h, "vertex") }
    return out
}

private fun r3(v: Double) = Math.round(v * 1000) / 1000.0

/** Tutamaç sürüklenince katmanın yeni hâli. l0: başlangıçtaki katman, lx/ly: parmağın katman koordinatı, sx/sy: başlangıç noktası */
fun applyHandle(l0: Layer, id: String, lx: Double, ly: Double, sx: Double, sy: Double): Layer {
    val mn = minOf(l0.w, l0.h)
    if (id.startsWith("c") && id.length > 1 && (id[1] == '-' || id[1] == '1')) {
        val k = maxOf(0.02, Math.hypot(lx, ly) / maxOf(1.0, Math.hypot(sx, sy)))
        val w = maxOf(4.0, Math.round(l0.w * k).toDouble()); val h = maxOf(4.0, Math.round(l0.h * k).toDouble())
        return if (l0.type == "text") l0.copy(w = w, h = h, fontSize = maxOf(6.0, Math.round((l0.fontSize ?: 64.0) * k).toDouble())) else l0.copy(w = w, h = h)
    }
    return when {
        id == "e-x" || id == "e+x" -> l0.copy(w = maxOf(4.0, Math.round(Math.abs(lx) * 2).toDouble()))
        id == "e-y" || id == "e+y" -> l0.copy(h = maxOf(4.0, Math.round(Math.abs(ly) * 2).toDouble()))
        id == "bar-len" -> l0.copy(w = maxOf(l0.h, Math.round(Math.abs(lx) * 2).toDouble()))
        id == "bar-thk" -> l0.copy(h = maxOf(2.0, minOf(l0.w, Math.round(Math.abs(ly) * 2).toDouble())))
        id.startsWith("k-") -> {
            val c = l0.crop ?: Crop(); val fx = (lx + l0.w / 2) / l0.w; val fy = (ly + l0.h / 2) / l0.h
            l0.copy(crop = when (id) {
                "k-l" -> c.copy(l = r3(fx.coerceIn(0.0, 1 - c.r - 0.05)))
                "k-r" -> c.copy(r = r3((1 - fx).coerceIn(0.0, 1 - c.l - 0.05)))
                "k-t" -> c.copy(t = r3(fy.coerceIn(0.0, 1 - c.b - 0.05)))
                else -> c.copy(b = r3((1 - fy).coerceIn(0.0, 1 - c.t - 0.05)))
            })
        }
        id == "cres" -> l0.copy(sp = (l0.sp ?: emptyMap()) + mapOf("cx" to r3((lx / l0.w).coerceIn(-5.0, 5.0)), "cy" to r3((ly / l0.h).coerceIn(-5.0, 5.0))))
        id == "rad" -> l0.copy(sp = (l0.sp ?: emptyMap()) + ("rad" to r3(((lx + l0.w / 2) / mn).coerceIn(0.0, 0.5))))
        id == "inner" -> {
            val n = l0.sp("n").roundToInt(); val a = PI / n - PI / 2
            val ux = cos(a) * l0.w / 2; val uy = sin(a) * l0.h / 2
            l0.copy(sp = (l0.sp ?: emptyMap()) + ("inner" to r3(((lx * ux + ly * uy) / (ux * ux + uy * uy)).coerceIn(0.05, 0.95))))
        }
        id.startsWith("v") -> {
            val i = id.substring(1).toInt(); val pts = (l0.pts ?: regularPts(5)).toMutableList()
            pts[i] = listOf(r3((lx / l0.w).coerceIn(-0.5, 0.5)), r3((ly / l0.h).coerceIn(-0.5, 0.5)))
            l0.copy(pts = pts)
        }
        else -> l0
    }
}

/** Serbest çokgene köşe ekle (en uzun kenarın ortasına) */
fun addVertex(pts: List<List<Double>>): List<List<Double>> {
    var best = 0; var bl = -1.0
    for (i in pts.indices) { val a = pts[i]; val b = pts[(i + 1) % pts.size]; val d = Math.hypot(a[0] - b[0], a[1] - b[1]); if (d > bl) { bl = d; best = i } }
    val a = pts[best]; val b = pts[(best + 1) % pts.size]
    return pts.toMutableList().apply { add(best + 1, listOf(r3((a[0] + b[0]) / 2), r3((a[1] + b[1]) / 2))) }
}
