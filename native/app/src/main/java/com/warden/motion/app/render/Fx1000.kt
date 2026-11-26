package com.warden.motion.app.render

import com.warden.motion.app.model.Anim
import com.warden.motion.app.model.Effect
import com.warden.motion.app.model.Layer
import com.warden.motion.app.model.Project
import com.warden.motion.app.model.shapePath
import com.warden.motion.app.model.value
import kotlin.math.*

/**
 * 1000 rehberindeki efektler için motorun hesapladığı veri (shader'a p_dv olarak gider; katman birimi, kutu merkezine göre).
 * 870 Fourier Eğri Çizimi, 872 Evolüt/İnvolüt, 883 Simetrik Fonksiyon Çizimi, 885 Gölge Voronoi Sınırlama.
 */
object Fx1000 {
    /** loc: dünya koordinatını bu katmanın yerel birimine çevirir */
    fun data(p: Project, l: Layer, e: Effect, t: Double, loc: (Double, Double) -> Pair<Double, Double>): Effect? {
        val out = when (e.type) {
            "fourierdraw" -> fourier(p, e, t, loc)
            "evolute" -> evolute(p, e, t, loc)
            "plotfunc" -> plot(e, t)
            "routewindow" -> if (e.c?.get("rota").isNullOrBlank()) null else curvePts(p, e, "rota", t, 32, loc).flatMap { it.toList() }
            "focustrack" -> e.c?.get("hedef")?.let { id -> p.layers.find { it.id == id } }?.let { o -> val sm = max(0.0, e.value("tepki", t)); var x = 0.0; var y = 0.0; val S = if (sm > 0.01) 6 else 1
                for (i in 0 until S) { val w = worldTransform(p, o, t - sm * i / max(1, S - 1)); val (a, b) = loc(w.x, w.y); x += a / S; y += b / S }; listOf(x, y) }
            "lightvoronoi" -> e.c?.get("kaynakla")?.split(',')?.filter { it.isNotBlank() }?.take(8)?.mapNotNull { id -> p.layers.find { it.id == id } }
                ?.flatMap { o -> val w = worldTransform(p, o, t); loc(w.x, w.y).toList() }
            else -> null
        } ?: return null
        var v = e.v ?: emptyMap(); out.forEachIndexed { i, x -> v = v + ("dv$i" to Anim(if (x.isFinite()) x else 0.0)) }
        return e.copy(v = v)
    }

    /** Kaynak şeklin yolu, n eşit aralıklı nokta (bu katmanın yerel biriminde); kaynak yoksa yıldız */
    private fun curvePts(p: Project, e: Effect, key: String, t: Double, n: Int, loc: (Double, Double) -> Pair<Double, Double>): List<Pair<Double, Double>> {
        val o = e.c?.get(key)?.let { id -> p.layers.find { it.id == id } }
        if (o == null && key == "rota") return emptyList()
        if (o == null) return List(n) { i -> val a = 2 * PI * i / n; val r = 60.0 * (0.62 + 0.38 * cos(5 * a)); r * cos(a) to r * sin(a) }
        val w = worldTransform(p, o, t); val ra = w.rot * PI / 180
        val pts = if (o.type == "shape") ShapeFx.sample(shapePath(o), n).map { it[0].toDouble() to it[1].toDouble() } else List(n) { i -> val a = 2 * PI * i / n; cos(a) * o.w / 2 to sin(a) * o.h / 2 }
        return pts.map { (x, y) -> loc(w.x + (x * cos(ra) - y * sin(ra)) * w.scale, w.y + (x * sin(ra) + y * cos(ra)) * w.scale) }
    }

    /** dv: 0..127 yeniden kurulmuş eğri (64 nokta), 128..175 dönen daireler (16 × merkez x, y, yarıçap) */
    private fun fourier(p: Project, e: Effect, t: Double, loc: (Double, Double) -> Pair<Double, Double>): List<Double> {
        val N = 128; val pts = curvePts(p, e, "kaynakEgri", t, N, loc)
        val H = e.value("harmonik", t).roundToInt().coerceIn(1, 63)
        // katsayılar c_k = 1/N Σ z_n e^{-2πikn/N}, k = -H..H; büyüklüğe göre sıralı (en büyük daireler önce)
        val ks = (-H..H).map { k -> var re = 0.0; var im = 0.0
            for ((n, z) in pts.withIndex()) { val a = -2 * PI * k * n / N; re += z.first * cos(a) - z.second * sin(a); im += z.first * sin(a) + z.second * cos(a) }
            Triple(k, re / N, im / N) }.sortedByDescending { hypot(it.second, it.third) }
        fun at(u: Double): Pair<Double, Double> { var x = 0.0; var y = 0.0; for ((k, re, im) in ks) { val a = 2 * PI * k * u; x += re * cos(a) - im * sin(a); y += re * sin(a) + im * cos(a) }; return x to y }
        val prog = (e.value("ilerleme", t) / 100).let { if (it <= 0.0) 1.0 else it }
        val out = ArrayList<Double>()
        for (i in 0 until 64) { val (x, y) = at(prog * i / 63); out += x; out += y }
        var cx = 0.0; var cy = 0.0; var shown = 0
        for ((k, re, im) in ks) { if (shown >= 16) break; val r = hypot(re, im); val a = 2 * PI * k * prog; if (k != 0) { out += cx; out += cy; out += r; shown++ }; cx += re * cos(a) - im * sin(a); cy += re * sin(a) + im * cos(a) }
        while (out.size < 176) out += 0.0
        return out
    }

    /** dv: 0..127 temel eğri (64 nokta), 128..255 evolüt ya da involüt (64 nokta) */
    private fun evolute(p: Project, e: Effect, t: Double, loc: (Double, Double) -> Pair<Double, Double>): List<Double> {
        val N = 64; val c = curvePts(p, e, "temelEgri", t, N, loc); val out = ArrayList<Double>(); c.forEach { out += it.first; out += it.second }
        val inv = e.value("tur", t).roundToInt() == 1
        if (!inv) for (i in 0 until N) { // eğrilik merkezi: C = P + N * (|P'|^2 / κ)
            val a = c[(i - 1 + N) % N]; val b = c[i]; val d = c[(i + 1) % N]
            val dx = (d.first - a.first) / 2; val dy = (d.second - a.second) / 2; val ddx = d.first - 2 * b.first + a.first; val ddy = d.second - 2 * b.second + a.second
            val cr = dx * ddy - dy * ddx; val s2 = dx * dx + dy * dy
            if (abs(cr) < 1e-6) { out += b.first; out += b.second } else { val k = s2 / cr; out += (b.first - dy * k).coerceIn(-4000.0, 4000.0); out += (b.second + dx * k).coerceIn(-4000.0, 4000.0) }
        } else { var s = 0.0 // açılan ip: Q = P − T · s (s: başlangıçtan yay uzunluğu)
            for (i in 0 until N) { val b = c[i]; val d = c[(i + 1) % N]; if (i > 0) { val a = c[i - 1]; s += hypot(b.first - a.first, b.second - a.second) }
                val tx = d.first - b.first; val ty = d.second - b.second; val L = max(1e-6, hypot(tx, ty)); out += b.first - tx / L * s; out += b.second - ty / L * s }
        }
        return out
    }

    /** dv: 0..127 f(x) örnekleri x ∈ [−R, R] (R = 2π × xÖlçek), 128 = en büyük |f| */
    private fun plot(e: Effect, t: Double): List<Double> {
        val expr = e.c?.get("ifade")?.takeIf { it.isNotBlank() } ?: "sin(x)"
        val f = runCatching { Expr(expr) }.getOrNull() ?: return emptyList()
        val R = 2 * PI * max(0.01, e.value("xOlce", t)); val ys = List(128) { i -> val x = -R + 2 * R * i / 127; runCatching { f.eval(x, t) }.getOrDefault(Double.NaN).let { if (it.isFinite()) it.coerceIn(-1e4, 1e4) else 0.0 } }
        return ys + listOf(max(1e-6, ys.maxOf { abs(it) }))
    }

    /** Güvenli ifade ayrıştırıcı: + − × ÷ ^, parantez, x, t, pi, e ve sin cos tan asin acos atan sinh cosh tanh exp log ln sqrt abs floor ceil round sign */
    class Expr(src: String) {
        private val s = src.lowercase().replace(" ", "").replace("×", "*").replace("÷", "/").replace("π", "pi").replace(',', '.'); private var i = 0
        private val root: (Double, Double) -> Double
        init { root = sum(); require(i == s.length) { "beklenmeyen: ${s.substring(i)}" } }
        fun eval(x: Double, t: Double) = root(x, t)
        private fun peek() = if (i < s.length) s[i] else '\u0000'
        private fun sum(): (Double, Double) -> Double { var a = prod(); while (peek() == '+' || peek() == '-') { val op = s[i++]; val b = prod(); val l = a; a = if (op == '+') { x, t -> l(x, t) + b(x, t) } else { x, t -> l(x, t) - b(x, t) } }; return a }
        private fun prod(): (Double, Double) -> Double { var a = unary(); while (peek() == '*' || peek() == '/' || peek().isLetter() || peek() == '(') { val op = if (peek() == '*' || peek() == '/') s[i++] else '*'; val b = unary(); val l = a; a = if (op == '*') { x, t -> l(x, t) * b(x, t) } else { x, t -> l(x, t) / b(x, t) } }; return a }
        private fun unary(): (Double, Double) -> Double { if (peek() == '-') { i++; val a = unary(); return { x, t -> -a(x, t) } }; if (peek() == '+') { i++ }; return pow() }
        private fun pow(): (Double, Double) -> Double { val a = atom(); if (peek() == '^') { i++; val b = unary(); return { x, t -> a(x, t).pow(b(x, t)) } }; return a }
        private fun atom(): (Double, Double) -> Double {
            if (peek() == '(') { i++; val a = sum(); require(peek() == ')') { ") eksik" }; i++; return a }
            if (peek().isDigit() || peek() == '.') { val st = i; while (peek().isDigit() || peek() == '.') i++; val v = s.substring(st, i).toDouble(); return { _, _ -> v } }
            val st = i; while (peek().isLetter()) i++; val name = s.substring(st, i)
            when (name) { "x" -> return { x, _ -> x }; "t" -> return { _, t -> t }; "pi" -> return { _, _ -> PI }; "e" -> return { _, _ -> E } }
            val fn: (Double) -> Double = when (name) { "sin" -> ::sin; "cos" -> ::cos; "tan" -> ::tan; "asin" -> ::asin; "acos" -> ::acos; "atan" -> ::atan; "sinh" -> ::sinh; "cosh" -> ::cosh; "tanh" -> ::tanh
                "exp" -> ::exp; "log", "ln" -> ::ln; "sqrt" -> ::sqrt; "abs" -> ::abs; "floor" -> ::floor; "ceil" -> ::ceil; "round" -> { v -> Math.round(v).toDouble() }; "sign" -> ::sign; else -> error("bilinmeyen: $name") }
            require(peek() == '(') { "$name( bekleniyordu" }; i++; val a = sum(); require(peek() == ')') { ") eksik" }; i++; return { x, t -> fn(a(x, t)) }
        }
    }
}
