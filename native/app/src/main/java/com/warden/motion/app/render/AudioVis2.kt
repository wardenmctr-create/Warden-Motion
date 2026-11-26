package com.warden.motion.app.render

import com.warden.motion.app.model.Effect
import com.warden.motion.app.model.Layer
import com.warden.motion.app.model.value
import kotlin.math.*

/** 1000 rehberi ses görselleştiricileri (959, 960, 962, 963, 964, 977, 978): projedeki sesten shader verisi (p_dv) */
object AudioVis2 {
    val TYPES = setOf("cutbeatpreview", "pitchcurve", "tuningmeter", "chromawheel", "tempocurve", "onsetdetect", "envelopeparts", "stereodir")
    private val envCache = HashMap<String, DoubleArray>()
    /** Seviye zarfı (saniyede 100 örnek, mono mutlak tepe) — katman başına önbellek */
    private fun env(l: Layer, pcm: Pcm): DoubleArray = envCache.getOrPut(l.id + l.src + pcm.frames) { val W = pcm.rate / 100; DoubleArray(pcm.frames / W) { b -> var m = 0.0; for (i in b * W until min(pcm.frames, (b + 1) * W)) m = max(m, abs((pcm.data[i * 2] + pcm.data[i * 2 + 1]) / 2.0)); m } }
    private fun mono(pcm: Pcm, a: Int, n: Int) = DoubleArray(n) { val j = a + it; if (j in 0 until pcm.frames) (pcm.data[j * 2] + pcm.data[j * 2 + 1]) / 2.0 else 0.0 }

    fun data(e: Effect, t: Double, l: Layer, pcm: Pcm, idx: (Double) -> Int): DoubleArray? {
        if (e.type !in TYPES) return null; val rate = pcm.rate; fun v(k: String) = e.value(k, t)
        when (e.type) {
            "pitchcurve" -> { val lo = v("altSini"); val hi = max(lo + 10, v("ustSini")); val conf = v("guvenEsig") / 100; val out = DoubleArray(129)
                for (i in 0 until 128) { val tt = t - 3.0 + 3.0 * i / 127; val c = idx(tt); val x = mono(pcm, c - rate / 20, rate / 5); val (f0, cf) = AudioFx3.pitch(x, rate / 20, rate, lo, hi); out[i] = if (f0 > 0 && cf >= conf) 69 + 12 * log2(f0 / 440.0) else 0.0 }
                out[128] = out[127]; return out }
            "tuningmeter" -> { val sm = max(0.0, v("yumusatm")); var acc = 0.0; var cnt = 0; for (k in 0 until 5) { val c = idx(t - sm * k / 4); val x = mono(pcm, c - rate / 20, rate / 5); val (f0, cf) = AudioFx3.pitch(x, rate / 20, rate); if (f0 > 0 && cf > 0.5) { acc += f0; cnt++ } }
                if (cnt == 0) return doubleArrayOf(0.0, 0.0, 0.0); val f = acc / cnt; val midi = 69 + 12 * log2(f / max(1.0, v("referansA"))); val near = midi.roundToInt(); return doubleArrayOf((midi - near) * 100, near.toDouble(), f) }
            "chromawheel" -> { val N = 8192; val W = (v("pencere") * rate).toInt().coerceIn(1024, N); val c = idx(t); val re = DoubleArray(N); val im = DoubleArray(N); val x = mono(pcm, c - W, W)
                for (k in 0 until W) re[k] = x[k] * (0.5 - 0.5 * cos(2 * PI * k / W)); AudioFx.fft(re, im, false); val ch = DoubleArray(12)
                for (k in 1 until N / 2) { val f = k.toDouble() * rate / N; if (f < 60 || f > 5000) continue; val pc = (((69 + 12 * log2(f / 440.0)).roundToInt() % 12) + 12) % 12; ch[pc] += hypot(re[k], im[k]) }
                val mx = max(1e-9, ch.max()); for (i in 0 until 12) ch[i] /= mx; var best = 0; var bs = -1.0; var minor = 0.0
                for (r in 0 until 12) for (m in 0..1) { val s = ch[r] + ch[(r + if (m == 0) 4 else 3) % 12] + ch[(r + 7) % 12]; if (s > bs) { bs = s; best = r; minor = m.toDouble() } }
                return ch + doubleArrayOf(best.toDouble(), minor) }
            "tempocurve" -> { val en = env(l, pcm); if (en.size < 200) return null; val nov = DoubleArray(en.size) { if (it == 0) 0.0 else max(0.0, en[it] - en[it - 1]) }; val win = (v("pencere") * 100).toInt().coerceIn(100, 3000)
                val lo = (6000 / max(20.0, v("maxBpm"))).toInt().coerceAtLeast(10); val hi = (6000 / max(10.0, v("minBpm"))).toInt().coerceAtLeast(lo + 1); val out = DoubleArray(65)
                for (s in 0 until 64) { val center = (en.size * (s + 0.5) / 64).toInt(); val a = max(0, center - win / 2); val b = min(en.size, a + win); var best = 0.0; var bl = lo
                    for (L in lo..hi) { var c = 0.0; for (i in a until b - L) c += nov[i] * nov[i + L]; if (c > best) { best = c; bl = L } }; out[s] = 6000.0 / bl }
                if (v("elleDuze") >= 0.5) for (s in 1 until 63) out[s] = (out[s - 1] + out[s] * 2 + out[s + 1]) / 4
                out[64] = ((t - l.start + (l.srcIn ?: 0.0)) * 100 / en.size).coerceIn(0.0, 1.0); return out }
            "cutbeatpreview" -> { val en = env(l, pcm); val i0 = (idx(t).toDouble() / pcm.frames * en.size).toInt(); val span = (v("arama") * 100).toInt().coerceIn(5, 300); val out = ArrayList<Double>(); var last = -1000
                for (i in max(1, i0 - span)..min(en.size - 1, i0 + span)) { var mean = 0.0; for (k in 1..20) mean += en[max(0, i - k)]; mean /= 20; if (en[i] - en[i - 1] > 0.25 * (mean + 0.05) && i - last > 12) { out += (i - i0) / 100.0; last = i; if (out.size >= 16) break } }
                return out.toDoubleArray() }
            "onsetdetect" -> { val en = env(l, pcm); val i0 = (idx(t).toDouble() / pcm.frames * en.size).toInt(); val th = 0.5 - v("duyarlil") / 220; val gap = max(1, (v("enAzAral") / 10).toInt()); val ages = ArrayList<Double>(); var last = Int.MAX_VALUE
                for (i in i0 downTo max(1, i0 - 300)) { if (i >= en.size) continue; var mean = 0.0; for (k in 1..20) mean += en[max(0, i - k)]; mean /= 20; val mode = v("mod").roundToInt(); val nov = if (mode == 1) en[i] - mean else (en[i] - en[i - 1]) * (if (mode == 2) 1.5 else 2.0)
                    if (nov > th * (mean + 0.05) && last - i >= gap) { ages += (i0 - i) / 100.0; last = i; if (ages.size >= 8) break } }
                return DoubleArray(9) { if (it < ages.size) ages[it] else if (it == 8) ages.size.toDouble() else 99.0 } }
            "envelopeparts" -> { val en = env(l, pcm); val i0 = (idx(t).toDouble() / pcm.frames * en.size).toInt(); val aT = max(0.001, v("baslangiTepk") / 1000); val rT = max(0.01, v("kuyrukTepk") / 1000)
                val fa = exp(-0.01 / aT); val fr = exp(-0.01 / rT); var fast = 0.0; var slow = 0.0; val att = DoubleArray(64); val rel = DoubleArray(64); val start = i0 - 200
                for (i in start - 100 until i0) { val x = if (i in en.indices) en[i] else 0.0; fast = if (x > fast) x else fast * fa; slow = if (x > slow) slow * fr + x * (1 - fr) else slow * fr + x * (1 - fr)
                    val k = (i - start) * 64 / 200; if (k in 0 until 64) { att[k] = max(att[k], max(0.0, fast - slow)); rel[k] = max(rel[k], max(0.0, slow - fast * 0.5)) } }
                return att + rel }
            "stereodir" -> { val bands = v("bant").roundToInt().coerceIn(8, 64); val N = 4096; val lo = max(20.0, v("altFrek")); val hi = max(lo * 1.1, min(rate / 2.0, v("ustFrek"))); val sm = max(0.0, v("yumusatm")); val out = DoubleArray(bands * 2); val frames = if (sm > 0.01) 3 else 1
                for (f in 0 until frames) { val c = idx(t - sm * f / 2); val L = DoubleArray(N); val Li = DoubleArray(N); val R = DoubleArray(N); val Ri = DoubleArray(N)
                    for (k in 0 until N) { val j = c - N + k; val w = 0.5 - 0.5 * cos(2 * PI * k / N); if (j in 0 until pcm.frames) { L[k] = pcm.data[j * 2] * w; R[k] = pcm.data[j * 2 + 1] * w } }
                    AudioFx.fft(L, Li, false); AudioFx.fft(R, Ri, false)
                    for (b in 0 until bands) { val f0 = lo * (hi / lo).pow(b.toDouble() / bands); val f1 = lo * (hi / lo).pow((b + 1.0) / bands); var a = 0.0; var r = 0.0
                        for (k in (f0 / rate * N).toInt().coerceIn(1, N / 2 - 1)..(f1 / rate * N).toInt().coerceIn(1, N / 2 - 1)) { a += hypot(L[k], Li[k]); r += hypot(R[k], Ri[k]) }
                        out[b * 2] += (r - a) / (r + a + 1e-9) / frames; out[b * 2 + 1] += ((20 * log10((a + r) / N * 4 + 1e-6) + 70) / 70).coerceIn(0.0, 1.0) / frames } }
                return out }
        }
        return null
    }
}
