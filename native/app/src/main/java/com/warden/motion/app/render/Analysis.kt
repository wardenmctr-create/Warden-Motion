package com.warden.motion.app.render

import android.graphics.Bitmap
import com.warden.motion.app.model.Effect
import com.warden.motion.app.model.value
import kotlin.math.*

/**
 * Ölçer efektleri için katmanın kendi görüntüsünden küçük analiz görüntüleri (shader'a s_anl olarak verilir):
 * histogram (256×1), dalga biçimi (128×64), vektör ölçer (64×64). Seyrek örnekleme ile hızlıdır.
 */
object Analysis {
    private val TYPES = setOf("histogram2", "waveform", "vectorscope", "compisolate", "perspfix")
    fun sources(fx: List<Effect>, bmp: Bitmap, t: Double): Map<String, Bitmap> {
        fx.firstOrNull { it.type in Sims.TYPES }?.let { e -> return Sims.source(e, t)?.let { mapOf("anl" to it) } ?: emptyMap() }
        val e = fx.firstOrNull { it.type in TYPES } ?: return emptyMap()
        val w = bmp.width; val h = bmp.height; if (w < 2 || h < 2) return emptyMap()
        val step = max(1, sqrt(w.toDouble() * h / 60000.0).toInt()); val px = IntArray(w * h); bmp.getPixels(px, 0, w, 0, 0, w, h)
        return when (e.type) {
            "perspfix" -> { // dikeye yakın kenarların eğimi x konumuna göre doğrusal: eğim = a + b·x  → (a, b) görüntü olarak
                val W = 160; val H = max(16, 160 * h / max(1, w)); val sb = Bitmap.createScaledBitmap(bmp, W, H, true); val g = IntArray(W * H); sb.getPixels(g, 0, W, 0, 0, W, H)
                fun L(x: Int, y: Int) = g[y * W + x].let { ((it shr 16) and 255) * 0.3 + ((it shr 8) and 255) * 0.59 + (it and 255) * 0.11 }
                var sx = 0.0; var sy = 0.0; var sxx = 0.0; var sxy = 0.0; var n = 0.0
                for (y in 1 until H - 1) for (x in 1 until W - 1) { val gx = L(x + 1, y) - L(x - 1, y); val gy = L(x, y + 1) - L(x, y - 1); val m = hypot(gx, gy); if (m < 40) continue
                    val tilt = atan2(gy, gx); if (abs(abs(tilt) - 0.0) > 0.5 && abs(abs(tilt) - PI) > 0.5) continue; val lean = (if (gx < 0) -gy else gy) / max(abs(gx), 1e-3); val xn = x.toDouble() / W - 0.5
                    sx += xn * m; sy += lean * m; sxx += xn * xn * m; sxy += xn * lean * m; n += m }
                val b = if (n > 0) (n * sxy - sx * sy) / max(1e-9, n * sxx - sx * sx) else 0.0; val a = if (n > 0) (sy - b * sx) / n else 0.0
                val out = Bitmap.createBitmap(2, 1, Bitmap.Config.ARGB_8888); fun enc(v: Double) = ((v.coerceIn(-1.0, 1.0) * 0.5 + 0.5) * 255).toInt().coerceIn(0, 255).let { (255 shl 24) or (it shl 16) }
                out.setPixel(0, 0, enc(a)); out.setPixel(1, 0, enc(b)); mapOf("anl" to out) }
            "compisolate" -> { // alfa bağlı bileşenleri: etiketle, alana göre süz, sırala, seçileni maske yap
                val k = max(1, sqrt(w.toDouble() * h / 250000.0).toInt()); val W = w / k; val H = h / k; val lab = IntArray(W * H) { -1 }; val comps = ArrayList<IntArray>() // [alan, minx, miny, sumx]
                val stack = IntArray(W * H)
                for (y0 in 0 until H) for (x0 in 0 until W) { val i0 = y0 * W + x0; if (lab[i0] >= 0 || ((px[y0 * k * w + x0 * k] ushr 24) and 255) < 128) continue
                    val id = comps.size; var sp = 0; stack[sp++] = i0; lab[i0] = id; var area = 0; var mnx = x0; var mny = y0
                    while (sp > 0) { val i = stack[--sp]; area++; val x = i % W; val y = i / W; if (x < mnx) mnx = x; if (y < mny) mny = y
                        for (d in 0..3) { val nx = x + intArrayOf(1, -1, 0, 0)[d]; val ny = y + intArrayOf(0, 0, 1, -1)[d]; if (nx < 0 || ny < 0 || nx >= W || ny >= H) continue; val j = ny * W + nx
                            if (lab[j] < 0 && ((px[ny * k * w + nx * k] ushr 24) and 255) >= 128) { lab[j] = id; stack[sp++] = j } } }
                    comps += intArrayOf(area, mnx, mny) }
                val minA = e.value("enKucuAlan", t) / (k * k); val order = comps.indices.filter { comps[it][0] >= minA }.sortedWith(when (e.value("siralama", t).roundToInt()) { 1 -> compareBy { comps[it][1] }; 2 -> compareBy { comps[it][2] }; else -> compareByDescending { comps[it][0] } })
                val pick = order.getOrNull(e.value("parcaNo", t).roundToInt() - 1) ?: -2; val out = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888); val op = IntArray(w * h)
                for (y in 0 until h) for (x in 0 until w) { val l = lab[min(H - 1, y / k) * W + min(W - 1, x / k)]; if (l == pick) op[y * w + x] = -1 }
                out.setPixels(op, 0, w, 0, 0, w, h); mapOf("anl" to out) }
            "histogram2" -> { val bins = Array(4) { DoubleArray(256) }
                for (y in 0 until h step step) for (x in 0 until w step step) { val c = px[y * w + x]; val a = (c ushr 24) and 255; if (a < 8) continue
                    val r = (c shr 16) and 255; val g = (c shr 8) and 255; val b = c and 255; bins[0][r]++; bins[1][g]++; bins[2][b]++; bins[3][((r * 0.2126 + g * 0.7152 + b * 0.0722)).toInt().coerceIn(0, 255)]++ }
                val log = e.value("logaritm", t) >= 0.5; val mx = bins.maxOf { b -> b.maxOrNull() ?: 1.0 }.let { if (log) ln(1 + it) else it }.coerceAtLeast(1.0)
                val out = Bitmap.createBitmap(256, 1, Bitmap.Config.ARGB_8888)
                for (i in 0 until 256) { fun n(v: Double) = ((if (log) ln(1 + v) else v) / mx * 255).toInt().coerceIn(0, 255)
                    out.setPixel(i, 0, (n(bins[3][i]) shl 24) or (n(bins[0][i]) shl 16) or (n(bins[1][i]) shl 8) or n(bins[2][i])) }
                mapOf("anl" to out) }
            "waveform" -> { val W = 128; val H = 64; val acc = Array(4) { DoubleArray(W * H) }
                for (y in 0 until h step step) for (x in 0 until w step step) { val c = px[y * w + x]; if (((c ushr 24) and 255) < 8) continue; val col = x * W / w
                    val r = (c shr 16) and 255; val g = (c shr 8) and 255; val b = c and 255; val l = (r * 0.2126 + g * 0.7152 + b * 0.0722).toInt()
                    acc[0][(r * (H - 1) / 255) * W + col]++; acc[1][(g * (H - 1) / 255) * W + col]++; acc[2][(b * (H - 1) / 255) * W + col]++; acc[3][(l * (H - 1) / 255) * W + col]++ }
                val per = (h / step).toDouble().coerceAtLeast(1.0) / H * 6; val out = Bitmap.createBitmap(W, H, Bitmap.Config.ARGB_8888)
                for (i in 0 until W * H) { fun n(v: Double) = (sqrt(v / per) * 255).toInt().coerceIn(0, 255)
                    out.setPixel(i % W, H - 1 - i / W, (n(acc[3][i]) shl 24) or (n(acc[0][i]) shl 16) or (n(acc[1][i]) shl 8) or n(acc[2][i])) }
                mapOf("anl" to out) }
            else -> { val N = 64; val cnt = DoubleArray(N * N); val col = Array(3) { DoubleArray(N * N) }; val uv = e.value("renkUzay", t) >= 0.5
                for (y in 0 until h step step) for (x in 0 until w step step) { val c = px[y * w + x]; if (((c ushr 24) and 255) < 8) continue
                    val r = ((c shr 16) and 255) / 255.0; val g = ((c shr 8) and 255) / 255.0; val b = (c and 255) / 255.0; val yy = 0.2126 * r + 0.7152 * g + 0.0722 * b
                    val cb = (b - yy) / (if (uv) 2.03 else 1.8556); val cr = (r - yy) / (if (uv) 1.14 else 1.5748)
                    val i = ((cb + 0.5) * (N - 1)).roundToInt().coerceIn(0, N - 1); val j = ((0.5 - cr) * (N - 1)).roundToInt().coerceIn(0, N - 1); val k = j * N + i
                    cnt[k]++; col[0][k] += r; col[1][k] += g; col[2][k] += b }
                val mx = (cnt.maxOrNull() ?: 1.0).coerceAtLeast(1.0); val out = Bitmap.createBitmap(N, N, Bitmap.Config.ARGB_8888)
                for (k in 0 until N * N) { val c = cnt[k]; val a = if (c > 0) (sqrt(c / mx) * 255).toInt().coerceIn(8, 255) else 0
                    fun ch(i: Int) = if (c > 0) (col[i][k] / c * 255).toInt().coerceIn(0, 255) else 0
                    out.setPixel(k % N, k / N, (a shl 24) or (ch(0) shl 16) or (ch(1) shl 8) or ch(2)) }
                mapOf("anl" to out) }
        }
    }
}
