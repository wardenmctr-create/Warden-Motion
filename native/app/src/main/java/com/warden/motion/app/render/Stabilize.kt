package com.warden.motion.app.render

import android.graphics.Bitmap
import kotlin.math.*

/** Kare kayması tahmini: iki kareyi ~96 px genişliğe küçült, gri tonda ±%12 aralıkta en küçük mutlak fark (iki ölçekli arama). */
object Stabilize {
    private fun gray(b: Bitmap, w: Int, h: Int, cropX: Int = 0, frames: Int = 1): FloatArray {
        val src = if (frames > 1) Bitmap.createBitmap(b, 0, 0, b.width / frames, b.height) else b
        val s = Bitmap.createScaledBitmap(src, w, h, true); val px = IntArray(w * h); s.getPixels(px, 0, w, 0, 0, w, h)
        return FloatArray(w * h) { val c = px[it]; (((c shr 16) and 255) * 0.3f + ((c shr 8) and 255) * 0.59f + (c and 255) * 0.11f) * (((c ushr 24) and 255) / 255f) }
    }
    /** Dönüş: (x, y) ara resim pikseli cinsinden kayma (bu kare referansa göre ne kadar kaymış) */
    fun shift(cur: Bitmap, refStrip: Bitmap): Pair<Double, Double> {
        val W = 96; val H = max(8, (96.0 * cur.height / max(1, cur.width)).toInt()); val a = gray(cur, W, H); val b = gray(refStrip, W, H)
        val R = (W * 0.12).toInt(); var best = Float.MAX_VALUE; var bx = 0; var by = 0
        for (dy in -R..R step 2) for (dx in -R..R step 2) { var sad = 0f; var n = 0; for (y in R until H - R step 2) for (x in R until W - R step 2) { sad += abs(a[y * W + x] - b[(y + dy) * W + x + dx]); n++ }; sad /= max(1, n); if (sad < best) { best = sad; bx = dx; by = dy } }
        var fx = bx; var fy = by; best = Float.MAX_VALUE
        for (dy in by - 2..by + 2) for (dx in bx - 2..bx + 2) { if (abs(dx) > R || abs(dy) > R) continue; var sad = 0f; var n = 0; for (y in R until H - R) for (x in R until W - R) { sad += abs(a[y * W + x] - b[(y + dy) * W + x + dx]); n++ }; sad /= max(1, n); if (sad < best) { best = sad; fx = dx; fy = dy } }
        val k = cur.width.toDouble() / W; return -fx * k to -fy * k
    }
}
