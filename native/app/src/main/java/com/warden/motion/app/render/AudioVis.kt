package com.warden.motion.app.render

import android.graphics.Bitmap
import com.warden.motion.app.model.Effect
import com.warden.motion.app.model.Layer
import com.warden.motion.app.model.Project
import com.warden.motion.app.model.value
import kotlin.math.*

/** Ses görselleştiricileri (773 Spektrogram, 774 Stereo Faz, 775 Gürlük Ölçeri): projedeki ilk sesli katmanın sesinden görüntü/veri */
object AudioVis {
    @Volatile var pcmOf: ((Layer) -> Pcm?)? = null
    private val TYPES = setOf("spectrogram", "phasescope", "loudmeter")
    /** 207 Ses Spektrumu (bant seviyeleri 0..1) ve 208 Ses Dalgası (örnekler −1..1): shader'a p_dv olarak gider */
    fun data(p: Project, e: Effect, t: Double): DoubleArray? {
        val l = (e.c?.get("sesKayn") ?: e.c?.get("ses"))?.takeIf { it.isNotBlank() }?.let { id -> p.layers.find { it.id == id } }
            ?: p.layers.firstOrNull { hasAudio(it) && t >= it.start && t < it.end } ?: p.layers.firstOrNull { hasAudio(it) } ?: return null
        val pcm = pcmOf?.invoke(l) ?: return null; val rate = pcm.rate
        fun idx(tt: Double) = ((tt - l.start + (l.srcIn ?: 0.0)) * rate).toInt()
        fun mono(j: Int) = if (j in 0 until pcm.frames) (pcm.data[j * 2] + pcm.data[j * 2 + 1]) / 2.0 else 0.0
        AudioVis2.data(e, t, l, pcm, ::idx)?.let { return it }
        if (e.type == "audiowave") {
            val n = e.value("ornekSayi", t).roundToInt().coerceIn(8, 256); val win = max(0.005, e.value("zamanPenc", t)); val ch = e.value("kanal", t).roundToInt()
            val c0 = idx(t - win / 2); val span = win * rate
            return DoubleArray(n) { i -> val j = c0 + (span * i / (n - 1)).toInt(); if (j !in 0 until pcm.frames) 0.0 else when (ch) { 1 -> pcm.data[j * 2].toDouble(); 2 -> pcm.data[j * 2 + 1].toDouble(); else -> mono(j) } }
        }
        val bands = e.value("bantSayi", t).roundToInt().coerceIn(2, 128); val N = 2048; val lo = max(10.0, e.value("altFrek", t)); val hi = max(lo * 1.01, min(rate / 2.0, e.value("ustFrek", t)))
        val sm = max(0.0, e.value("yumusatm", t)); val out = DoubleArray(bands); val re = DoubleArray(N); val im = DoubleArray(N); val frames = if (sm > 0.01) 3 else 1
        for (f in 0 until frames) { val c = idx(t - sm * f / 2)
            for (k in 0 until N) { re[k] = mono(c - N + k) * (0.5 - 0.5 * cos(2 * PI * k / N)); im[k] = 0.0 }
            AudioFx.fft(re, im, false)
            for (b in 0 until bands) { val f0 = lo * (hi / lo).pow(b.toDouble() / bands); val f1 = lo * (hi / lo).pow((b + 1.0) / bands)
                val k0 = (f0 / rate * N).toInt().coerceIn(1, N / 2 - 1); val k1 = (f1 / rate * N).toInt().coerceIn(k0, N / 2 - 1)
                var m = 0.0; for (k in k0..k1) m = max(m, hypot(re[k], im[k]) / N * 4)
                out[b] += ((20 * log10(max(m, 1e-6)) + 70) / 70).coerceIn(0.0, 1.0) / frames } }
        return out
    }

    fun sources(p: Project, fx: List<Effect>, t: Double): Map<String, Bitmap> {
        val e = fx.firstOrNull { it.type in TYPES } ?: return emptyMap()
        val l = p.layers.firstOrNull { hasAudio(it) && t >= it.start && t < it.end } ?: p.layers.firstOrNull { hasAudio(it) } ?: return emptyMap()
        val pcm = pcmOf?.invoke(l) ?: return emptyMap(); val rate = pcm.rate
        fun idx(tt: Double) = ((tt - l.start + (l.srcIn ?: 0.0)) * rate).toInt()
        when (e.type) {
            "spectrogram" -> { val W = 128; val Hh = 96; val N = Integer.highestOneBit(e.value("fftBoyu", t).toInt().coerceIn(256, 4096)); val span = e.value("zamanAral", t).coerceAtLeast(0.1); val logF = e.value("frekansOlce", t) >= 0.5
                val out = IntArray(W * Hh); val re = DoubleArray(N); val im = DoubleArray(N)
                for (x in 0 until W) { val c = idx(t - span + span * x / (W - 1)); for (k in 0 until N) { val j = c - N / 2 + k; val s = if (j in 0 until pcm.frames) (pcm.data[j * 2] + pcm.data[j * 2 + 1]) / 2.0 else 0.0; re[k] = s * (0.5 - 0.5 * cos(2 * PI * k / N)); im[k] = 0.0 }
                    AudioFx.fft(re, im, false)
                    for (y in 0 until Hh) { val fr = y.toDouble() / (Hh - 1); val bin = if (logF) (20.0 * (rate / 2.0 / 20.0).pow(fr) / rate * N).toInt() else (fr * N / 2).toInt(); val b = bin.coerceIn(1, N / 2 - 1)
                        val mag = hypot(re[b], im[b]) / N * 4; val db = (20 * log10(max(mag, 1e-6)) + 90) / 90; val g = (db.coerceIn(0.0, 1.0) * 255).toInt(); out[(Hh - 1 - y) * W + x] = (255 shl 24) or (g shl 16) or (g shl 8) or g } }
                return mapOf("anl" to Bitmap.createBitmap(out, W, Hh, Bitmap.Config.ARGB_8888)) }
            "phasescope" -> { val N = 96; val cnt = DoubleArray(N * N); val win = (e.value("pencere", t) / 1000 * rate).toInt().coerceIn(64, rate); val trail = (e.value("izSure", t) * rate).toInt(); val c0 = idx(t)
                for (j in max(0, c0 - win - trail) until min(pcm.frames, c0)) { val L = pcm.data[j * 2].toDouble(); val R = pcm.data[j * 2 + 1].toDouble(); val m = (L + R) * 0.7071; val s = (L - R) * 0.7071
                    val x = ((s * 0.7 + 0.5) * (N - 1)).roundToInt().coerceIn(0, N - 1); val y = ((0.5 - m * 0.7) * (N - 1)).roundToInt().coerceIn(0, N - 1); cnt[y * N + x] += if (j < c0 - win) 0.3 else 1.0 }
                val mx = (cnt.maxOrNull() ?: 1.0).coerceAtLeast(1.0); val out = IntArray(N * N) { val g = (sqrt(cnt[it] / mx) * 255).toInt().coerceIn(0, 255); (g shl 24) or 0xFFFFFF }
                return mapOf("anl" to Bitmap.createBitmap(out, N, N, Bitmap.Config.ARGB_8888)) }
            else -> { fun rms(sec: Double): Double { val c = idx(t); val n = (sec * rate).toInt(); var a = 0.0; var k = 0; for (j in max(0, c - n) until min(pcm.frames, c)) { val s = (pcm.data[j * 2] + pcm.data[j * 2 + 1]) / 2.0; a += s * s; k++ }; return if (k > 0) -0.691 + 10 * log10(max(a / k * 2, 1e-12)) else -90.0 }
                var pk = 0.0; val c = idx(t); for (j in max(0, c - rate / 10) until min(pcm.frames, c)) pk = max(pk, max(abs(pcm.data[j * 2]), abs(pcm.data[j * 2 + 1])).toDouble())
                val vals = doubleArrayOf(rms(0.4), rms(3.0), rms(min(30.0, t - l.start).coerceAtLeast(0.4)), 20 * log10(max(pk, 1e-6)))
                val bmp = Bitmap.createBitmap(4, 1, Bitmap.Config.ARGB_8888); vals.forEachIndexed { i, v -> val g = ((v + 60) / 60 * 255).toInt().coerceIn(0, 255); bmp.setPixel(i, 0, (255 shl 24) or (g shl 16) or (g shl 8) or g) }
                return mapOf("anl" to bmp) }
        }
    }
}
