package com.warden.motion.app.render

import android.graphics.Bitmap
import kotlin.math.*

/**
 * Nokta takibi (499 Nokta Takibi, 500 Yüzey Takibi, 582 Yol Maskesi Takibi): katman küçük boyutta kare kare çizilir,
 * başlangıç karesindeki şablon her karede bir önceki konumun çevresinde aranır (en küçük mutlak fark). Sonuçlar kutu yüzdesi (0–1) olarak önbellekte.
 */
object Tracker {
    class Track(val key: String, val fps: Double, val pts: Int) { val pos = ArrayList<DoubleArray>(); var tmpl: Array<FloatArray>? = null; var tw = 0; var th = 0; var conf = 1.0 }
    private val tracks = HashMap<String, Track>()
    fun get(key: String) = tracks[key]
    /** Konum (kutu oranı) — kare sayısı i için; henüz yoksa son bilinen */
    fun at(key: String, i: Int): DoubleArray? = tracks[key]?.pos?.let { if (it.isEmpty()) null else it[min(i, it.size - 1).coerceAtLeast(0)] }

    private fun gray(b: Bitmap): Pair<FloatArray, IntArray> { val w = b.width; val h = b.height; val px = IntArray(w * h); b.getPixels(px, 0, w, 0, 0, w, h)
        return FloatArray(w * h) { val c = px[it]; ((c shr 16) and 255) * 0.3f + ((c shr 8) and 255) * 0.59f + (c and 255) * 0.11f } to intArrayOf(w, h) }

    /**
     * frames(i) = i. karenin küçük görüntüsü. starts: başlangıç noktaları (kutu oranı). tmplFrac/searchFrac: şablon ve arama yarıçapı (genişliğe oranla).
     * key değişince baştan başlar; hedef kare sayısına kadar ilerletir.
     */
    fun ensure(key: String, fps: Double, upto: Int, starts: List<DoubleArray>, tmplFrac: Double, searchFrac: Double, frames: (Int) -> Bitmap?) {
        var tr = tracks[key]; if (tr == null || tr.pts != starts.size) { tr = Track(key, fps, starts.size); tracks.clear(); tracks[key] = tr }
        var guard = 0
        while (tr.pos.size <= upto && guard++ < 600) { val i = tr.pos.size; val bmp = frames(i) ?: break; val (g, sz) = gray(bmp); val w = sz[0]; val h = sz[1]
            val R = max(3, (tmplFrac * w / 2).toInt()); val S = max(2, (searchFrac * w).toInt())
            if (i == 0) { tr.tw = R; tr.tmpl = Array(starts.size) { k -> val cx = (starts[k][0] * w).toInt(); val cy = (starts[k][1] * h).toInt(); FloatArray((2 * R + 1) * (2 * R + 1)) { j -> val x = (cx - R + j % (2 * R + 1)).coerceIn(0, w - 1); val y = (cy - R + j / (2 * R + 1)).coerceIn(0, h - 1); g[y * w + x] } }
                val p = DoubleArray(starts.size * 2); starts.forEachIndexed { k, s -> p[k * 2] = s[0]; p[k * 2 + 1] = s[1] }; tr.pos += p; continue }
            val prev = tr.pos.last(); val out = DoubleArray(prev.size)
            for (k in starts.indices) { val px0 = (prev[k * 2] * w).toInt(); val py0 = (prev[k * 2 + 1] * h).toInt(); var best = Float.MAX_VALUE; var bx = px0; var by = py0; val t = tr.tmpl!![k]; val T = 2 * R + 1
                for (dy in -S..S step 1) for (dx in -S..S step 1) { val cx = px0 + dx; val cy = py0 + dy; var sad = 0f; var j = 0
                    while (j < T * T) { val x = (cx - R + j % T).coerceIn(0, w - 1); val y = (cy - R + j / T).coerceIn(0, h - 1); sad += abs(g[y * w + x] - t[j]); j += 2 }; if (sad < best) { best = sad; bx = cx; by = cy } }
                out[k * 2] = bx.toDouble() / w; out[k * 2 + 1] = by.toDouble() / h }
            tr.pos += out }
    }
}
