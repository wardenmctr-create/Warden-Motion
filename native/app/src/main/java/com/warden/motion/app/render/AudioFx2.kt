package com.warden.motion.app.render

import com.warden.motion.app.model.Effect
import com.warden.motion.app.model.Layer
import com.warden.motion.app.model.value
import kotlin.math.*

/** 800 rehberi ses efektleri (751–772). true dönerse işlendi. */
object AudioFx2 {
    private fun db(x: Double) = 10.0.pow(x / 20.0)
    fun one(e: Effect, l: Layer, buf: FloatArray, rate: Int, side: (String) -> FloatArray?): Boolean {
        val n = buf.size / 2; if (n == 0) return true
        fun v(k: String, i: Int = 0) = e.value(k, l.start + i.toDouble() / rate)
        when (e.type) {
            "loudnorm" -> { // K ağırlığına yakın: 2 kutuplu yüksek geçiren + raf; RMS'ten LUFS yaklaşımı
                val hp = AudioFx.Biquad().apply { set(1, 60.0, 0.5, 0.0, rate) }; val sh = AudioFx.Biquad().apply { set(4, 1500.0, 0.707, 4.0, rate) }; var acc = 0.0
                for (i in 0 until n) { val m = (buf[i * 2] + buf[i * 2 + 1]) / 2.0; val y = sh.run(hp.run(m)); acc += y * y }
                val lufs = -0.691 + 10 * log10(max(acc / n * 2, 1e-12)); val g = db(v("hedefLufs") - lufs); val ceil = db(v("tepeTava")); val lim = v("tepeTavaKaza") >= 0.5
                for (i in buf.indices) { var y = buf[i] * g; if (lim) y = (ceil * tanh(y / ceil)); buf[i] = y.toFloat() } }
            "peaknorm" -> { var pl = 0f; var pr = 0f; for (i in 0 until n) { pl = max(pl, abs(buf[i * 2])); pr = max(pr, abs(buf[i * 2 + 1])) }; val t = db(v("hedefDbfs"))
                if (v("stereoBagl") >= 0.5) { val g = t / max(1e-9, max(pl, pr).toDouble()); for (i in buf.indices) buf[i] = (buf[i] * g).toFloat() } else { val gl = t / max(1e-9, pl.toDouble()); val gr = t / max(1e-9, pr.toDouble()); for (i in 0 until n) { buf[i * 2] = (buf[i * 2] * gl).toFloat(); buf[i * 2 + 1] = (buf[i * 2 + 1] * gr).toFloat() } } }
            "dcremove" -> { val k = v("guc") / 100; for (c in 0..1) { if (v("yontem") < 0.5) { var m = 0.0; for (i in 0 until n) m += buf[i * 2 + c]; m /= n; for (i in 0 until n) buf[i * 2 + c] = (buf[i * 2 + c] - m * k).toFloat() }
                else { var x1 = 0.0; var y1 = 0.0; for (i in 0 until n) { val x = buf[i * 2 + c].toDouble(); val y = x - x1 + 0.995 * y1; x1 = x; y1 = y; buf[i * 2 + c] = (x * (1 - k) + y * k).toFloat() } } } }
            "declick" -> { val maxL = max(1, (v("azamiSure") / 1000 * rate).toInt()); val th = 0.05 + (1 - v("esik") / 100) * 0.6; val src = buf.copyOf(); val listen = v("yalnizFarkDinl") >= 0.5
                for (c in 0..1) { var i = 2; while (i < n - maxL - 2) { val pred = 2 * src[(i - 1) * 2 + c] - src[(i - 2) * 2 + c]; if (abs(src[i * 2 + c] - pred) > th) { var j = i; while (j < i + maxL && abs(src[j * 2 + c] - src[(i - 1) * 2 + c]) > th * 0.5) j++
                    val a = src[(i - 1) * 2 + c]; val b = src[min(n - 1, j + 1) * 2 + c]; for (k in i..j) { val f = (k - i + 1).toFloat() / (j - i + 2); buf[k * 2 + c] = a + (b - a) * f }; i = j + 1 } else i++ }
                    if (listen) for (k in 0 until n) buf[k * 2 + c] = src[k * 2 + c] - buf[k * 2 + c] } }
            "declip" -> { val th = db(v("kirpmaEsig")).toFloat() * 0.999f; val maxG = (v("azamiBosl") / 1000 * rate).toInt()
                for (c in 0..1) { var i = 1; while (i < n - 1) { if (abs(buf[i * 2 + c]) >= th) { var j = i; while (j < n - 1 && abs(buf[j * 2 + c]) >= th && j - i < maxG) j++
                    if (j - i in 1 until maxG && i >= 2 && j + 1 < n) { val y0 = buf[(i - 1) * 2 + c]; val y1 = buf[(j) * 2 + c]; val d0 = buf[(i - 1) * 2 + c] - buf[(i - 2) * 2 + c]; val d1 = buf[(j + 1) * 2 + c] - buf[j * 2 + c]; val L = (j - i + 1).toFloat()
                        for (k in i until j) { val t = (k - i + 1) / L; val h00 = 2 * t * t * t - 3 * t * t + 1; val h10 = t * t * t - 2 * t * t + t; val h01 = -2 * t * t * t + 3 * t * t; val h11 = t * t * t - t * t; buf[k * 2 + c] = (h00 * y0 + h10 * d0 * L + h01 * y1 + h11 * d1 * L) } }
                    i = j + 1 } else i++ } } }
            "dropoutfix" -> { val maxG = (v("azamiBosl") / 1000 * rate).toInt(); val th = (1 - v("algilama") / 100) * 0.002 + 1e-5
                for (c in 0..1) { var i = 1; while (i < n) { if (abs(buf[i * 2 + c]) < th && abs(buf[(i - 1) * 2 + c]) > th * 10) { var j = i; while (j < n && abs(buf[j * 2 + c]) < th) j++
                    if (j - i in 8..maxG && j < n) { val seg = j - i; for (k in i until j) { val f = (k - i).toDouble() / seg; val back = buf[max(0, k - seg) * 2 + c]; val fwd = buf[min(n - 1, k + seg) * 2 + c]
                        buf[k * 2 + c] = if (v("yontem") < 0.5) (buf[(i - 1) * 2 + c] * (1 - f) + buf[j * 2 + c] * f).toFloat() else (back * (1 - f) + fwd * f).toFloat() } }; i = j } else i++ } } }
            "notchfilter" -> { val f = Array(2) { AudioFx.Biquad() }; for (i in 0 until n) { if (i % 256 == 0) for (c in 0..1) { f[c].set(2, v("merkez", i), v("q", i), v("azaltma", i), rate) }; for (c in 0..1) buf[i * 2 + c] = f[c].run(buf[i * 2 + c].toDouble()).toFloat() } }
            "dynamiceq" -> { val det = AudioFx.Biquad(); val f = Array(2) { AudioFx.Biquad() }; var env = 0.0; var lastG = 99.0
                for (i in 0 until n) { if (i % 256 == 0) det.set(5, v("merkez", i), v("q", i), 0.0, rate); val b = det.run((buf[i * 2] + buf[i * 2 + 1]) / 2.0); val at = exp(-1.0 / (v("saldiri", i) / 1000 * rate)); val rl = exp(-1.0 / (v("birakma", i) / 1000 * rate))
                    env = if (abs(b) > env) at * env + (1 - at) * abs(b) else rl * env + (1 - rl) * abs(b); val over = 20 * log10(max(env, 1e-9)) - v("esik", i); val g = if (over > 0) v("kazanc", i) * min(1.0, over / 12) else 0.0
                    if (abs(g - lastG) > 0.25) { for (c in 0..1) f[c].set(2, v("merkez", i), v("q", i), g, rate); lastG = g }; for (c in 0..1) buf[i * 2 + c] = f[c].run(buf[i * 2 + c].toDouble()).toFloat() } }
            "multibandcomp" -> { val nb = v("bant").roundToInt().coerceIn(2, 3); val lo = Array(2) { AudioFx.Biquad().apply { set(0, v("ayirma1"), 0.707, 0.0, rate) } }; val hi = Array(2) { AudioFx.Biquad().apply { set(1, v("ayirma2"), 0.707, 0.0, rate) } }
                val env = DoubleArray(3); val at = exp(-1.0 / (v("saldiri") / 1000 * rate)); val rl = exp(-1.0 / (v("birakma") / 1000 * rate)); val th = v("esik"); val r = max(1.0, v("oran"))
                for (i in 0 until n) { val bands = Array(3) { DoubleArray(2) }; for (c in 0..1) { val x = buf[i * 2 + c].toDouble(); val l0 = lo[c].run(x); val h0 = if (nb >= 3) hi[c].run(x) else 0.0; bands[0][c] = l0; bands[2][c] = h0; bands[1][c] = x - l0 - h0 }
                    var o0 = 0.0; var o1 = 0.0; for (b in 0 until 3) { val lv = max(abs(bands[b][0]), abs(bands[b][1])); env[b] = if (lv > env[b]) at * env[b] + (1 - at) * lv else rl * env[b] + (1 - rl) * lv
                        val over = 20 * log10(max(env[b], 1e-9)) - th; val g = if (over > 0) db(-over * (1 - 1 / r)) else 1.0; o0 += bands[b][0] * g; o1 += bands[b][1] * g }
                    buf[i * 2] = o0.toFloat(); buf[i * 2 + 1] = o1.toFloat() } }
            "expander" -> { var env = 0.0; val at = exp(-1.0 / (v("saldiri") / 1000 * rate)); val rl = exp(-1.0 / (v("birakma") / 1000 * rate))
                for (i in 0 until n) { val lv = max(abs(buf[i * 2]), abs(buf[i * 2 + 1])).toDouble(); env = if (lv > env) at * env + (1 - at) * lv else rl * env + (1 - rl) * lv
                    val under = v("esikDbfs", i) - 20 * log10(max(env, 1e-9)); val g = if (under > 0) db(-under * (v("oran", i) - 1)) else 1.0; buf[i * 2] = (buf[i * 2] * g).toFloat(); buf[i * 2 + 1] = (buf[i * 2 + 1] * g).toFloat() } }
            "transient" -> { var fast = 0.0; var slow = 0.0; val bsel = v("bant").roundToInt(); val f = Array(2) { AudioFx.Biquad().apply { set(if (bsel == 0) 0 else if (bsel == 2) 1 else 5, if (bsel == 0) 250.0 else if (bsel == 2) 4000.0 else 1200.0, 0.7, 0.0, rate) } }
                val kf = exp(-1.0 / (0.002 * rate)); val ks = exp(-1.0 / (0.05 * rate))
                for (i in 0 until n) { val lv = max(abs(buf[i * 2]), abs(buf[i * 2 + 1])).toDouble(); fast = max(lv, fast * kf); slow = slow * ks + lv * (1 - ks); val tr = ((fast - slow) / max(slow, 1e-4)).coerceIn(0.0, 4.0)
                    val g = db((v("atak", i) / 100 * 12) * min(1.0, tr) + (v("surdurme", i) / 100 * 12) * (1 - min(1.0, tr)))
                    for (c in 0..1) { val x = buf[i * 2 + c].toDouble(); val part = if (bsel == 3) x else f[c].run(x); buf[i * 2 + c] = (x + part * (g - 1)).toFloat() } } }
            "phaseinvert" -> { val ch = v("kanal").roundToInt(); if (v("tersCevi") >= 0.5) for (i in 0 until n) { if (ch != 1) buf[i * 2] = -buf[i * 2]; if (ch != 0) buf[i * 2 + 1] = -buf[i * 2 + 1] }
                if (v("monoKont") >= 0.5) for (i in 0 until n) { val m = (buf[i * 2] + buf[i * 2 + 1]) / 2; buf[i * 2] = m; buf[i * 2 + 1] = m } }
            "chandelay" -> { val src = buf.copyOf(); val dl = (v("sol") / 1000 * rate).toInt(); val dr = (v("sag") / 1000 * rate).toInt()
                for (i in 0 until n) { buf[i * 2] = if (i - dl >= 0) src[(i - dl) * 2] else 0f; buf[i * 2 + 1] = if (i - dr >= 0) src[(i - dr) * 2 + 1] else 0f; if (v("monoKont") >= 0.5) { val m = (buf[i * 2] + buf[i * 2 + 1]) / 2; buf[i * 2] = m; buf[i * 2 + 1] = m } } }
            "phaser" -> { val st = v("kademe").roundToInt().coerceIn(2, 12); val zs = Array(2) { DoubleArray(st) }; val fb = DoubleArray(2); var ph = 0.0
                for (i in 0 until n) { ph += 2 * PI * v("tarama", i) / rate; val fc = 300.0 * 10.0.pow(0.5 + 0.5 * sin(ph)) * 3; val w = tan(PI * min(fc, rate * 0.45) / rate); val a = (w - 1) / (w + 1); val mix = v("karisim", i) / 100
                    for (c in 0..1) { val x = buf[i * 2 + c].toDouble(); var y = x + fb[c] * v("geriBesl", i) / 100; for (k in 0 until st) { val o = a * y + zs[c][k]; zs[c][k] = y - a * o; y = o }; fb[c] = y; buf[i * 2 + c] = (x * (1 - mix * 0.5) + y * mix).toFloat() } } }
            "rotary" -> { val L = Array(2) { AudioFx.Line(rate / 50 + 4) }; var ph = 0.0
                for (i in 0 until n) { ph += 2 * PI * v("donus", i) / rate; val dp = v("dopplerGucu", i) / 100; val sd = v("stereoDeri", i) / 100
                    for (c in 0..1) { val p = ph + c * PI * sd; val x = buf[i * 2 + c].toDouble(); L[c].push(x); val d = 2.0 + (1 + sin(p)) * dp * rate * 0.0015; val y = L[c].read(d) * (1 - 0.35 * dp * (1 - cos(p)) * 0.5); buf[i * 2 + c] = y.toFloat() } } }
            "convreverb" -> { val ir0 = e.c?.get("durtuYani")?.let { side("raw:$it") } ?: return true; val irn = min(ir0.size / 2, rate * 2); if (irn < 16) return true
                val pre = (v("onGeci") / 1000 * rate).toInt(); val mix = v("karisim") / 100; val N = Integer.highestOneBit(irn * 2 - 1) shl 1; val src = buf.copyOf()
                for (c in 0..1) { val hr = DoubleArray(N); val hi = DoubleArray(N); var norm = 0.0; for (k in 0 until irn) { hr[k] = ir0[k * 2 + c].toDouble(); norm += hr[k] * hr[k] }; norm = 1.0 / sqrt(max(norm, 1e-9)) * 0.5; AudioFx.fft(hr, hi, false)
                    val B = N - irn + 1; val out = DoubleArray(n + N + pre); var p = 0
                    while (p < n) { val xr = DoubleArray(N); val xi = DoubleArray(N); for (k in 0 until min(B, n - p)) xr[k] = src[(p + k) * 2 + c].toDouble(); AudioFx.fft(xr, xi, false)
                        for (k in 0 until N) { val r = xr[k] * hr[k] - xi[k] * hi[k]; val im = xr[k] * hi[k] + xi[k] * hr[k]; xr[k] = r; xi[k] = im }; AudioFx.fft(xr, xi, true); for (k in 0 until N) out[p + k + pre] += xr[k] * norm; p += B }
                    for (i in 0 until n) buf[i * 2 + c] = (src[i * 2 + c] * (1 - mix * 0.5) + out[i] * mix).toFloat() } }
            "specfreeze" -> { val cap = (v("yakalamaZama") * rate).toInt().coerceIn(0, n - 1); val N = 2048; val H = N / 4; val win = DoubleArray(N) { 0.5 - 0.5 * cos(2 * PI * it / N) }; val xf = max(1.0, v("gecis") / 1000 * rate)
                for (c in 0..1) { val mr = DoubleArray(N); val mi = DoubleArray(N); for (k in 0 until N) { val idx = cap + k - N / 2; mr[k] = (if (idx in 0 until n) buf[idx * 2 + c].toDouble() else 0.0) * win[k] }; AudioFx.fft(mr, mi, false); val mag = DoubleArray(N) { hypot(mr[it], mi[it]) }
                    val out = DoubleArray(n + N); val rnd = java.util.Random(5L + c); var p = cap; var fr = 0
                    while (p < n) { val re = DoubleArray(N); val im = DoubleArray(N); val decay = (1 - v("azalma") / 100 * 0.02).pow(fr.toDouble()); for (k in 1 until N / 2) { val ph = rnd.nextDouble() * 2 * PI; re[k] = mag[k] * cos(ph) * decay; im[k] = mag[k] * sin(ph) * decay; re[N - k] = re[k]; im[N - k] = -im[k] }
                        AudioFx.fft(re, im, true); for (k in 0 until N) out[p + k - N / 2 + N / 2] += re[k] * win[k] / 1.5; p += H; fr++ }
                    for (i in cap until n) { val k = min(1.0, (i - cap) / xf); buf[i * 2 + c] = (buf[i * 2 + c] * (1 - k) + out[i] * k).toFloat() } } }
            "granular" -> { val src = buf.copyOf(); java.util.Arrays.fill(buf, 0f); val g = max(32, (v("parca") / 1000 * rate).toInt()); val dens = v("yogunluk").coerceAtLeast(1.0); val rnd = java.util.Random(v("tohum").toLong()); val r = v("rastgele") / 100
                var t = 0.0; val step = rate / dens; while (t < n) { val start = (t + (rnd.nextDouble() - 0.5) * r * g * 4).toInt().coerceIn(0, max(0, n - g)); val at = t.toInt()
                    for (k in 0 until g) { val o = at + k; if (o >= n) break; val w = sin(PI * k / g).pow(2); val s = start + k; if (s >= n) break; buf[o * 2] += (src[s * 2] * w * 0.7).toFloat(); buf[o * 2 + 1] += (src[s * 2 + 1] * w * 0.7).toFloat() }; t += step } }
            "speechrate" -> { val r = v("hizOran").coerceIn(0.25, 4.0); if (abs(r - 1) < 1e-3) return true; val src = buf.copyOf(); java.util.Arrays.fill(buf, 0f); val W = max(256, (0.04 * rate * (0.5 + v("kalite") / 100)).toInt()); val H = W / 2
                if (v("perdeyiKoru") < 0.5) { for (i in 0 until n) { val p = i * r; val j = p.toInt(); if (j + 1 >= n) break; val f = (p - j).toFloat(); for (c in 0..1) buf[i * 2 + c] = src[j * 2 + c] * (1 - f) + src[j * 2 + 2 + c] * f }; return true }
                var o = 0; while (o < n) { val s = (o * r).toInt(); if (s + W >= n) break; for (k in 0 until W) { val oi = o + k; if (oi >= n) break; val w = sin(PI * k / W).pow(2); buf[oi * 2] += (src[(s + k) * 2] * w).toFloat(); buf[oi * 2 + 1] += (src[(s + k) * 2 + 1] * w).toFloat() }; o += H } }
            "autocrossfade" -> { val d = max(1, (v("sure") * rate).toInt()); val k = v("egri").roundToInt()
                fun gain(x: Double) = when (k) { 1 -> x; 2 -> x * x * (3 - 2 * x); else -> sin(x * PI / 2) }
                for (i in 0 until min(d, n)) { val g = gain(i.toDouble() / d); buf[i * 2] = (buf[i * 2] * g).toFloat(); buf[i * 2 + 1] = (buf[i * 2 + 1] * g).toFloat() }
                for (i in max(0, n - d) until n) { val g = gain((n - 1 - i).toDouble() / d); buf[i * 2] = (buf[i * 2] * g).toFloat(); buf[i * 2 + 1] = (buf[i * 2 + 1] * g).toFloat() } }
            "autopan" -> { val id = e.c?.get("gorselHede") ?: return true; val lp = AudioFx.Biquad(); val lpR = AudioFx.Biquad(); var cur = doubleArrayOf(0.0, 0.0)
                for (i in 0 until n) { if (i % 512 == 0) { cur = AudioFx.pos(id, l.start + i.toDouble() / rate) ?: cur; val cut = 18000.0 * (1 - v("mesafeAzal", i) / 100 * cur[1]).coerceIn(0.05, 1.0); lp.set(0, cut, 0.707, 0.0, rate); lpR.set(0, cut, 0.707, 0.0, rate) }
                    val pan = (cur[0] * v("panGeni", i) / 100).coerceIn(-1.0, 1.0); val gl = cos((pan + 1) * PI / 4); val gr = sin((pan + 1) * PI / 4); val att = 1 - v("mesafeAzal", i) / 100 * cur[1] * 0.6
                    val m = (buf[i * 2] + buf[i * 2 + 1]) / 2.0; buf[i * 2] = (lp.run(m) * gl * 1.414 * att).toFloat(); buf[i * 2 + 1] = (lpR.run(m) * gr * 1.414 * att).toFloat() } }
            "distancefx" -> { val d = v("mesafe").coerceAtLeast(0.1); val g = 1.0 / max(1.0, d / 1.5); val cut = 20000.0 / (1 + d * v("emilim") / 100 * 0.8); val f = Array(2) { AudioFx.Biquad().apply { set(0, cut, 0.707, 0.0, rate) } }
                val L = Array(2) { AudioFx.Line(rate / 5) }; val wet = v("yankiPayi") / 100 * min(1.0, d / 10)
                for (i in 0 until n) for (c in 0..1) { val x = f[c].run(buf[i * 2 + c].toDouble()) * g; val r = L[c].read(rate * (0.03 + 0.017 * c)) ; L[c].push(x + r * 0.55); buf[i * 2 + c] = (x * (1 - wet * 0.5) + r * wet).toFloat() } }
            else -> return false
        }
        return true
    }
}
