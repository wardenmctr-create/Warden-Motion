package com.warden.motion.app.render

import android.graphics.Bitmap
import android.graphics.ColorMatrix
import com.warden.motion.app.model.Effect
import com.warden.motion.app.model.value
import kotlin.math.PI
import kotlin.math.ceil
import kotlin.math.cos
import kotlin.math.floor
import kotlin.math.max
import kotlin.math.min
import kotlin.math.roundToInt
import kotlin.math.sin

val LIGHT_FX = setOf("glow", "shadow")
val COLOR_FX = setOf("brightness", "contrast", "saturate", "hue", "grayscale", "sepia", "invert")

/** Renk efektleri (CSS filtreleriyle aynı formüller) tek bir renk matrisinde */
fun colorMatrix(effects: List<Effect>, t: Double): ColorMatrix? {
    var m: ColorMatrix? = null
    fun mul(x: ColorMatrix) { m = (m ?: ColorMatrix()).also { it.postConcat(x) } }
    for (e in effects) {
        if (e.type !in COLOR_FX) continue
        val a = e.value("amount", t)
        when (e.type) {
            "brightness" -> { val k = (a / 100).toFloat(); mul(ColorMatrix(floatArrayOf(k, 0f, 0f, 0f, 0f, 0f, k, 0f, 0f, 0f, 0f, 0f, k, 0f, 0f, 0f, 0f, 0f, 1f, 0f))) }
            "contrast" -> { val k = (a / 100).toFloat(); val o = 255 * (0.5f - 0.5f * k); mul(ColorMatrix(floatArrayOf(k, 0f, 0f, 0f, o, 0f, k, 0f, 0f, o, 0f, 0f, k, 0f, o, 0f, 0f, 0f, 1f, 0f))) }
            "saturate" -> mul(ColorMatrix().apply { setSaturation((a / 100).toFloat()) })
            "grayscale" -> mul(ColorMatrix().apply { setSaturation((1 - min(1.0, a / 100)).toFloat()) })
            "hue" -> {
                val r = a * PI / 180; val c = cos(r).toFloat(); val s = sin(r).toFloat()
                mul(ColorMatrix(floatArrayOf(
                    0.213f + c * 0.787f - s * 0.213f, 0.715f - c * 0.715f - s * 0.715f, 0.072f - c * 0.072f + s * 0.928f, 0f, 0f,
                    0.213f - c * 0.213f + s * 0.143f, 0.715f + c * 0.285f + s * 0.140f, 0.072f - c * 0.072f - s * 0.283f, 0f, 0f,
                    0.213f - c * 0.213f - s * 0.787f, 0.715f - c * 0.715f + s * 0.715f, 0.072f + c * 0.928f + s * 0.072f, 0f, 0f,
                    0f, 0f, 0f, 1f, 0f)))
            }
            "sepia" -> { val k = min(1.0, a / 100).toFloat(); val i = 1 - k
                mul(ColorMatrix(floatArrayOf(0.393f + 0.607f * i, 0.769f - 0.769f * i, 0.189f - 0.189f * i, 0f, 0f, 0.349f - 0.349f * i, 0.686f + 0.314f * i, 0.168f - 0.168f * i, 0f, 0f,
                    0.272f - 0.272f * i, 0.534f - 0.534f * i, 0.131f + 0.869f * i, 0f, 0f, 0f, 0f, 0f, 1f, 0f))) }
            "invert" -> { val k = min(1.0, a / 100).toFloat(); val d = 1 - 2 * k
                mul(ColorMatrix(floatArrayOf(d, 0f, 0f, 0f, 255 * k, 0f, d, 0f, 0f, 255 * k, 0f, 0f, d, 0f, 255 * k, 0f, 0f, 0f, 1f, 0f))) }
        }
    }
    return m
}

/**
 * Hızlı Gauss yaklaşığı: 3 geçişli kutu bulanıklığı (önceden çarpılmış ARGB), yerinde.
 * Büyük yarıçapta önce küçültülüp bulanıklaştırılır (göze aynı, çok daha hızlı).
 */
fun blurBitmap(b: Bitmap, radius: Float) {
    if (radius < 0.5f) return
    val w = b.width; val h = b.height
    val px = IntArray(w * h); b.getPixels(px, 0, w, 0, 0, w, h)
    premul(px)
    // CSS blur(r): sigma = r. 3 kutu geçişi ≈ Gauss
    val sigma = radius.toDouble()
    val boxes = boxesForGauss(sigma, 3)
    val tmp = IntArray(w * h)
    for (bx in boxes) { boxH(px, tmp, w, h, (bx - 1) / 2); boxV(tmp, px, w, h, (bx - 1) / 2) }
    unpremul(px)
    b.setPixels(px, 0, w, 0, 0, w, h)
}

/** getPixels önceden çarpılmamış renk verir; karıştırmadan önce çarpılır, sonra geri açılır (kenarlar kararmasın) */
fun premul(px: IntArray) {
    for (i in px.indices) { val c = px[i]; val a = c ushr 24; if (a == 255) continue; if (a == 0) { px[i] = 0; continue }
        px[i] = (a shl 24) or ((((c shr 16) and 255) * a / 255) shl 16) or ((((c shr 8) and 255) * a / 255) shl 8) or ((c and 255) * a / 255) }
}
fun unpremul(px: IntArray) {
    for (i in px.indices) { val c = px[i]; val a = c ushr 24; if (a == 255 || a == 0) continue
        px[i] = (a shl 24) or (min(255, ((c shr 16) and 255) * 255 / a) shl 16) or (min(255, ((c shr 8) and 255) * 255 / a) shl 8) or min(255, (c and 255) * 255 / a) }
}

private fun boxesForGauss(sigma: Double, n: Int): IntArray {
    val wIdeal = Math.sqrt(12 * sigma * sigma / n + 1)
    var wl = floor(wIdeal).toInt(); if (wl % 2 == 0) wl--
    val wu = wl + 2
    val mIdeal = (12 * sigma * sigma - n * wl * wl - 4 * n * wl - 3 * n) / (-4 * wl - 4)
    val m = mIdeal.roundToInt()
    return IntArray(n) { if (it < m) wl else wu }
}

private fun boxH(src: IntArray, dst: IntArray, w: Int, h: Int, r: Int) {
    if (r <= 0) { System.arraycopy(src, 0, dst, 0, src.size); return }
    val div = 2 * r + 1
    for (y in 0 until h) {
        var a = 0; var rr = 0; var g = 0; var bb = 0
        val row = y * w
        for (i in -r..r) { val c = src[row + i.coerceIn(0, w - 1)]; a += c ushr 24; rr += (c shr 16) and 255; g += (c shr 8) and 255; bb += c and 255 }
        for (x in 0 until w) {
            dst[row + x] = ((a / div) shl 24) or ((rr / div) shl 16) or ((g / div) shl 8) or (bb / div)
            val cin = src[row + min(w - 1, x + r + 1)]; val cout = src[row + max(0, x - r)]
            a += (cin ushr 24) - (cout ushr 24); rr += ((cin shr 16) and 255) - ((cout shr 16) and 255)
            g += ((cin shr 8) and 255) - ((cout shr 8) and 255); bb += (cin and 255) - (cout and 255)
        }
    }
}

private fun boxV(src: IntArray, dst: IntArray, w: Int, h: Int, r: Int) {
    if (r <= 0) { System.arraycopy(src, 0, dst, 0, src.size); return }
    val div = 2 * r + 1
    for (x in 0 until w) {
        var a = 0; var rr = 0; var g = 0; var bb = 0
        for (i in -r..r) { val c = src[i.coerceIn(0, h - 1) * w + x]; a += c ushr 24; rr += (c shr 16) and 255; g += (c shr 8) and 255; bb += c and 255 }
        for (y in 0 until h) {
            dst[y * w + x] = ((a / div) shl 24) or ((rr / div) shl 16) or ((g / div) shl 8) or (bb / div)
            val cin = src[min(h - 1, y + r + 1) * w + x]; val cout = src[max(0, y - r) * w + x]
            a += (cin ushr 24) - (cout ushr 24); rr += ((cin shr 16) and 255) - ((cout shr 16) and 255)
            g += ((cin shr 8) and 255) - ((cout shr 8) and 255); bb += (cin and 255) - (cout and 255)
        }
    }
}

// ---------- Fraktal Bükme (fraktal gürültüyle yer değiştirme) ----------
private val PERM = IntArray(512).also { perm ->
    var s = 1337L; val p = IntArray(256) { it }
    for (i in 255 downTo 1) { s = (s * 16807) % 2147483647; val j = (s % (i + 1)).toInt(); val x = p[i]; p[i] = p[j]; p[j] = x }
    for (i in 0 until 512) perm[i] = p[i and 255]
}
private val GX = intArrayOf(1, -1, 1, -1, 1, -1, 0, 0); private val GY = intArrayOf(1, 1, -1, -1, 0, 0, 1, -1)
fun perlin(x: Double, y: Double): Double {
    val xi = floor(x).toInt(); val yi = floor(y).toInt(); val xf = x - xi; val yf = y - yi
    val X = xi and 255; val Y = yi and 255
    val u = xf * xf * xf * (xf * (xf * 6 - 15) + 10); val v = yf * yf * yf * (yf * (yf * 6 - 15) + 10)
    fun g(h: Int, dx: Double, dy: Double) = GX[h and 7] * dx + GY[h and 7] * dy
    val aa = PERM[PERM[X] + Y]; val ab = PERM[PERM[X] + Y + 1]; val ba = PERM[PERM[X + 1] + Y]; val bb = PERM[PERM[X + 1] + Y + 1]
    val x1 = g(aa, xf, yf) + u * (g(ba, xf - 1, yf) - g(aa, xf, yf))
    val x2 = g(ab, xf, yf - 1) + u * (g(bb, xf - 1, yf - 1) - g(ab, xf, yf - 1))
    return x1 + v * (x2 - x1)
}
fun fbm(x: Double, y: Double, oct: Double, ox: Double, oy: Double, px: Double, py: Double, seed: Double): Double {
    var sum = 0.0; var amp = 1.0; var f = 1.0; var norm = 0.0
    val n = ceil(oct).toInt() + 1
    for (i in 0 until n) {
        val w = if (i < floor(oct).toInt() + 1) 1.0 else (oct + 1 - i)
        if (w <= 0) break
        sum += perlin((x + ox + px * i) * f + seed, (y + oy + py * i) * f - seed) * amp * w
        norm += amp * w; amp *= 0.5; f *= 2.0
    }
    return if (norm != 0.0) sum / norm else 0.0
}

/** Bitmap'teki katman görüntüsünü fraktal gürültüyle büker. q: piksel / proje birimi, (bx,by): bitmap'in sahnedeki köşesi */
fun fractalWarp(b: Bitmap, e: Effect, t: Double, q: Double, bx: Int, by: Int, quality: Double) {
    val mag = e.value("mag", t); val det = e.value("det", t); val scl = max(0.1, e.value("scl", t))
    if (mag <= 0) return
    val ox = e.value("posX", t) / 200; val oy = e.value("posY", t) / 200; val px = e.value("parX", t) / 200; val py = e.value("parY", t) / 200
    val D = mag * 260 * q
    val W = b.width; val H = b.height
    val src = IntArray(W * H); b.getPixels(src, 0, W, 0, 0, W, H)
    val out = IntArray(W * H)
    val S = 1 / (200 * q * scl)
    val G = max(1, (8 - quality * 7).roundToInt())
    val gw = W / G + 3; val gh = H / G + 3
    val dxs = FloatArray(gw * gh); val dys = FloatArray(gw * gh)
    for (j in 0 until gh) for (i in 0 until gw) {
        val X = (bx + i * G) * S; val Y = (by + j * G) * S
        dxs[j * gw + i] = (fbm(X, Y, det, ox, oy, px, py, 3.7) * D).toFloat()
        dys[j * gw + i] = (fbm(X, Y, det, ox, oy, px, py, 11.3) * D).toFloat()
    }
    for (y in 0 until H) {
        val gy = y.toFloat() / G; val j = gy.toInt(); val fy = gy - j
        for (x in 0 until W) {
            val gx = x.toFloat() / G; val i = gx.toInt(); val fx = gx - i
            val k = j * gw + i
            val dx = (dxs[k] * (1 - fx) + dxs[k + 1] * fx) * (1 - fy) + (dxs[k + gw] * (1 - fx) + dxs[k + gw + 1] * fx) * fy
            val dy = (dys[k] * (1 - fx) + dys[k + 1] * fx) * (1 - fy) + (dys[k + gw] * (1 - fx) + dys[k + gw + 1] * fx) * fy
            val sx = (x + dx).toInt(); val sy = (y + dy).toInt()
            if (sx < 0 || sy < 0 || sx >= W || sy >= H) continue
            out[y * W + x] = src[sy * W + sx]
        }
    }
    b.setPixels(out, 0, W, 0, 0, W, H)
}
