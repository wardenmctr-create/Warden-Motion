package com.warden.motion.app.render

import android.graphics.Bitmap
import com.warden.motion.app.model.Effect
import com.warden.motion.app.model.value
import com.warden.motion.app.model.at
import kotlin.math.*

/**
 * Izgara benzetimleri (belirlenimci, tohumlu): Gray-Scott reaksiyon-difüzyon (507, 664), hücresel otomat (665),
 * kendini kaçınan yol (666), dallanarak birikme (667). Sonuç gri tonlu küçük görüntü; aynı ayarlar için önbellekten gelir.
 */
object Sims {
    val TYPES = setOf("reactdiff", "turingmaze", "cellauto", "selfavoid", "dla", "organicgrow")
    private val cache = object : LinkedHashMap<String, Bitmap>(16, 0.75f, true) { override fun removeEldestEntry(e: MutableMap.MutableEntry<String, Bitmap>?) = size > 12 }
    fun source(e: Effect, t: Double): Bitmap? {
        fun v(k: String) = e.value(k, t)
        val key = e.type + "|" + e.v?.entries?.filter { !it.key.startsWith("_") }?.sortedBy { it.key }?.joinToString { it.key + "=" + it.value.at(t) }
        cache[key]?.let { return it }
        val bmp = when (e.type) {
            "reactdiff" -> { val steps = (v("adimSayi") * (if (v("zamanlaGeli") >= 0.5) min(1.0, t / 5.0) else 1.0)).roundToInt(); grayScott(160, v("besleme"), v("tuketim"), v("yayilmaA"), v("yayilmaB"), steps, v("tohum").toInt()) }
            "turingmaze" -> grayScott(160, 0.029, 0.057, 1.0, 0.5, (v("adim") * 4 * v("gelisimIler") / 100).roundToInt(), v("tohum").toInt())
            "cellauto" -> cellAuto(v("izgara").roundToInt().coerceIn(8, 256), v("kural").roundToInt(), v("nesil").roundToInt().coerceIn(0, 2000), v("tohum").toInt())
            "selfavoid" -> selfAvoid(200, v("uzunluk").roundToInt().coerceIn(1, 10000), max(1, (v("adim") / 4).roundToInt()), v("enAzMesa"))
            "dla" -> dla(180, (v("parcacik") * v("buyumeIler") / 100).roundToInt().coerceIn(0, 5000), v("tohum").toInt())
            "organicgrow" -> organic((v("yineleme") * v("buyumeHizi") / 50).roundToInt().coerceIn(0, 1000), v("baslangiBoyu"), v("noktaUzak"), v("itmeGucu") / 100, v("yumusatm") / 100, v("tohum").toInt())
            else -> null
        } ?: return null
        cache[key] = bmp; return bmp
    }
    private fun toBmp(n: Int, f: (Int) -> Double): Bitmap { val px = IntArray(n * n) { val g = (f(it).coerceIn(0.0, 1.0) * 255).toInt(); (255 shl 24) or (g shl 16) or (g shl 8) or g }; return Bitmap.createBitmap(px, n, n, Bitmap.Config.ARGB_8888) }
    private fun grayScott(n: Int, F: Double, k: Double, da: Double, db: Double, steps: Int, seed: Int): Bitmap {
        var a = DoubleArray(n * n) { 1.0 }; var b = DoubleArray(n * n); val r = java.util.Random(seed.toLong())
        repeat(12) { val cx = r.nextInt(n); val cy = r.nextInt(n); for (y in -4..4) for (x in -4..4) b[((cy + y + n) % n) * n + (cx + x + n) % n] = 1.0 }
        var a2 = DoubleArray(n * n); var b2 = DoubleArray(n * n)
        repeat(steps.coerceIn(0, 6000)) { for (y in 0 until n) for (x in 0 until n) { val i = y * n + x; val l = (y * n + (x + n - 1) % n); val rr = (y * n + (x + 1) % n); val u = (((y + n - 1) % n) * n + x); val d = (((y + 1) % n) * n + x)
                val la = a[l] + a[rr] + a[u] + a[d] - 4 * a[i]; val lb = b[l] + b[rr] + b[u] + b[d] - 4 * b[i]; val abb = a[i] * b[i] * b[i]
                a2[i] = (a[i] + da * 0.2 * la - abb + F * (1 - a[i])).coerceIn(0.0, 1.0); b2[i] = (b[i] + db * 0.2 * lb + abb - (k + F) * b[i]).coerceIn(0.0, 1.0) }
            val ta = a; a = a2; a2 = ta; val tb = b; b = b2; b2 = tb }
        return toBmp(n) { (b[it] * 3.0) }
    }
    private fun cellAuto(n: Int, rule: Int, gens: Int, seed: Int): Bitmap {
        val r = java.util.Random(seed.toLong()); var g = BooleanArray(n * n) { r.nextDouble() < (if (rule == 1) 0.08 else 0.35) }; var g2 = BooleanArray(n * n)
        repeat(gens) { for (y in 0 until n) for (x in 0 until n) { var c = 0; for (dy in -1..1) for (dx in -1..1) if ((dx != 0 || dy != 0) && g[((y + dy + n) % n) * n + (x + dx + n) % n]) c++
                val alive = g[y * n + x]; g2[y * n + x] = when (rule) { 1 -> !alive && c == 2; 2 -> if (alive) c == 2 || c == 3 else c == 3 || c == 6; else -> if (alive) c == 2 || c == 3 else c == 3 } }
            val t = g; g = g2; g2 = t }
        return toBmp(n) { if (g[it]) 1.0 else 0.0 }
    }
    private fun selfAvoid(n: Int, len: Int, step: Int, minD: Double): Bitmap {
        val grid = BooleanArray(n * n); var x = n / 2; var y = n / 2; val r = java.util.Random(7); val out = DoubleArray(n * n); val gap = max(1, (minD / 4).roundToInt())
        for (s in 0 until len) { grid[y * n + x] = true; out[y * n + x] = 1.0
            val opts = listOf(1 to 0, -1 to 0, 0 to 1, 0 to -1).filter { (dx, dy) -> (1..step * gap).all { k -> val nx = x + dx * k; val ny = y + dy * k; nx in 0 until n && ny in 0 until n && !grid[ny * n + nx] } }
            if (opts.isEmpty()) break; val (dx, dy) = opts[r.nextInt(opts.size)]; repeat(step) { x += dx; y += dy; grid[y * n + x] = true; out[y * n + x] = 1.0 } }
        return toBmp(n) { out[it] }
    }
    /** Farksal büyüme: kapalı çizgi, komşu itmesi + düzleştirme; uzayan kenarlara nokta eklenir */
    private fun organic(iters: Int, start: Double, gap: Double, push: Double, smooth: Double, seed: Int): Bitmap {
        val n = 256; val r = java.util.Random(seed.toLong()); var xs = ArrayList<Double>(); var ys = ArrayList<Double>(); val r0 = (start / 1000 * n).coerceIn(5.0, n * 0.3); val g = (gap / 100 * n * 0.2).coerceIn(1.5, 12.0)
        val m = max(12, (2 * PI * r0 / g).toInt()); for (i in 0 until m) { val a = 2 * PI * i / m; xs += n / 2 + cos(a) * r0 + r.nextDouble() * 0.3; ys += n / 2 + sin(a) * r0 + r.nextDouble() * 0.3 }
        repeat(iters) { val N = xs.size; val fx = DoubleArray(N); val fy = DoubleArray(N); val R = g * 2.2
            for (i in 0 until N) { for (j in i + 1 until N) { val dx = xs[i] - xs[j]; val dy = ys[i] - ys[j]; val d2 = dx * dx + dy * dy; if (d2 < R * R && d2 > 1e-6) { val d = sqrt(d2); val f = (R - d) / R * push; fx[i] += dx / d * f; fy[i] += dy / d * f; fx[j] -= dx / d * f; fy[j] -= dy / d * f } }
                val p = (i + N - 1) % N; val q = (i + 1) % N; fx[i] += ((xs[p] + xs[q]) / 2 - xs[i]) * smooth; fy[i] += ((ys[p] + ys[q]) / 2 - ys[i]) * smooth }
            for (i in 0 until N) { xs[i] = (xs[i] + fx[i]).coerceIn(2.0, n - 3.0); ys[i] = (ys[i] + fy[i]).coerceIn(2.0, n - 3.0) }
            if (N < 900) { val nx = ArrayList<Double>(); val ny = ArrayList<Double>(); for (i in 0 until N) { nx += xs[i]; ny += ys[i]; val q = (i + 1) % N; if (hypot(xs[q] - xs[i], ys[q] - ys[i]) > g * 1.6) { nx += (xs[i] + xs[q]) / 2; ny += (ys[i] + ys[q]) / 2 } }; xs = nx; ys = ny } }
        val bmp = Bitmap.createBitmap(n, n, Bitmap.Config.ARGB_8888); val c = android.graphics.Canvas(bmp); val pt = android.graphics.Paint(android.graphics.Paint.ANTI_ALIAS_FLAG).apply { color = android.graphics.Color.WHITE; strokeWidth = 1.6f; style = android.graphics.Paint.Style.STROKE }
        c.drawColor(android.graphics.Color.BLACK); val path = android.graphics.Path(); for (i in xs.indices) { if (i == 0) path.moveTo(xs[i].toFloat(), ys[i].toFloat()) else path.lineTo(xs[i].toFloat(), ys[i].toFloat()) }; path.close(); c.drawPath(path, pt)
        return bmp
    }
    private fun dla(n: Int, count: Int, seed: Int): Bitmap {
        val g = BooleanArray(n * n); val c = n / 2; g[c * n + c] = true; val r = java.util.Random(seed.toLong()); var rad = 4.0; val age = DoubleArray(n * n); age[c * n + c] = 1.0
        for (p in 0 until count) { val a = r.nextDouble() * 2 * PI; var x = (c + cos(a) * (rad + 5)).toInt(); var y = (c + sin(a) * (rad + 5)).toInt(); var guard = 0
            while (guard++ < 4000) { x += r.nextInt(3) - 1; y += r.nextInt(3) - 1; if (hypot((x - c).toDouble(), (y - c).toDouble()) > rad + 20 || x <= 0 || y <= 0 || x >= n - 1 || y >= n - 1) { val b = r.nextDouble() * 2 * PI; x = (c + cos(b) * (rad + 5)).toInt(); y = (c + sin(b) * (rad + 5)).toInt(); continue }
                if (g[(y - 1) * n + x] || g[(y + 1) * n + x] || g[y * n + x - 1] || g[y * n + x + 1]) { g[y * n + x] = true; age[y * n + x] = 1.0 - p.toDouble() / max(1, count) * 0.6; rad = max(rad, hypot((x - c).toDouble(), (y - c).toDouble())); break } }
            if (rad > n / 2 - 22) break }
        return toBmp(n) { age[it] }
    }
}
