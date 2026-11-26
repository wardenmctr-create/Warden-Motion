package com.warden.motion.app.render

import com.warden.motion.app.model.Effect
import com.warden.motion.app.model.Layer
import com.warden.motion.app.model.value
import kotlin.math.*

/** 1000 rehberi ses işlemcileri (957–976). true dönerse işlendi. Tampon: stereo, aralıklı (L, R, L, R…). */
object AudioFx3 {
    val TYPES = setOf("vocalsplit", "hpss", "autotune", "silencegap", "binaural3d", "earlyreflect", "reverseverb", "freqshift", "specblur", "audiofreeze",
        "harmonizer", "roombox", "parallelchain", "chanalign", "specmatch")
    private fun db(x: Double) = 10.0.pow(x / 20.0)

    /** STFT (Hann, %75 örtüşme): her kare için (re, im) dizilerini işleyen fonksiyon; ters dönüşüm ve örtüşmeli toplama */
    private fun stft(x: DoubleArray, N: Int, fn: (re: DoubleArray, im: DoubleArray, frame: Int) -> Unit): DoubleArray {
        val H = N / 4; val win = DoubleArray(N) { 0.5 - 0.5 * cos(2 * PI * it / N) }; val out = DoubleArray(x.size); val norm = DoubleArray(x.size); val re = DoubleArray(N); val im = DoubleArray(N)
        var f = 0; var s = -N / 2
        while (s < x.size) { for (k in 0 until N) { val j = s + k; re[k] = (if (j in x.indices) x[j] else 0.0) * win[k]; im[k] = 0.0 }
            AudioFx.fft(re, im, false); fn(re, im, f); AudioFx.fft(re, im, true)
            for (k in 0 until N) { val j = s + k; if (j in x.indices) { out[j] += re[k] * win[k]; norm[j] += win[k] * win[k] } }
            s += H; f++ }
        for (i in out.indices) if (norm[i] > 1e-6) out[i] /= norm[i]
        return out
    }
    private fun ch(buf: FloatArray, c: Int) = DoubleArray(buf.size / 2) { buf[it * 2 + c].toDouble() }
    private fun put(buf: FloatArray, c: Int, x: DoubleArray) { for (i in x.indices) buf[i * 2 + c] = x[i].toFloat() }

    /** Otokorelasyonla temel frekans (Hz) ve güven; çok kısa ya da sessiz pencerede 0 */
    fun pitch(x: DoubleArray, at: Int, rate: Int, lo: Double = 60.0, hi: Double = 1200.0): Pair<Double, Double> {
        val W = (rate * 0.04).toInt(); val a = at - W / 2; if (a < 0 || a + W * 2 >= x.size) return 0.0 to 0.0
        var e0 = 0.0; for (i in 0 until W) e0 += x[a + i] * x[a + i]; if (e0 < 1e-6 * W) return 0.0 to 0.0
        val minL = (rate / hi).toInt().coerceAtLeast(2); val maxL = (rate / lo).toInt().coerceAtMost(W); var best = 0.0; var bl = 0
        for (L in minL..maxL) { var c = 0.0; var e1 = 0.0; for (i in 0 until W) { c += x[a + i] * x[a + i + L]; e1 += x[a + i + L] * x[a + i + L] }; val r = c / sqrt(e0 * e1 + 1e-12); if (r > best) { best = r; bl = L } }
        return if (bl == 0) 0.0 to 0.0 else rate.toDouble() / bl to best
    }

    fun one(e: Effect, l: Layer, buf: FloatArray, rate: Int, side: (String) -> FloatArray?): Boolean {
        if (e.type !in TYPES) return false
        val n = buf.size / 2; if (n == 0) return true
        fun v(k: String, i: Int = 0) = e.value(k, l.start + i.toDouble() / rate)
        when (e.type) {
            "vocalsplit" -> { // 957: merkez (L≈R) bileşen = vokal tahmini; kalan = eşlik. Kalite FFT boyunu, kalıntı azaltma maskeyi keskinleştirir
                val N = intArrayOf(1024, 2048, 4096)[v("kalite").roundToInt().coerceIn(0, 2)]; val L = ch(buf, 0); val R = ch(buf, 1); val sharp = 1 + v("kalintiAzal") / 100 * 4; val mode = v("cikti").roundToInt()
                val specR = ArrayList<Pair<DoubleArray, DoubleArray>>(); stft(R, N) { re, im, _ -> specR += re.copyOf() to im.copyOf() }
                val masks = ArrayList<DoubleArray>(); stft(L, N) { re, im, f -> val (rr, ri) = specR.getOrNull(f) ?: return@stft; val m = DoubleArray(N); for (k in 0 until N) { val a = hypot(re[k], im[k]); val b = hypot(rr[k], ri[k]); val dRe = re[k] - rr[k]; val dIm = im[k] - ri[k]
                    val side = hypot(dRe, dIm) / (a + b + 1e-9); m[k] = (1 - side).coerceIn(0.0, 1.0).pow(sharp) }; masks += m }
                fun apply(x: DoubleArray, vocal: Boolean) = stft(x, N) { re, im, f -> val m = masks.getOrNull(f) ?: return@stft; for (k in 0 until N) { val g = if (vocal) m[k] else 1 - m[k]; re[k] *= g; im[k] *= g } }
                when (mode) { 0 -> { put(buf, 0, apply(L, true)); put(buf, 1, apply(R, true)) }; 1 -> { put(buf, 0, apply(L, false)); put(buf, 1, apply(R, false)) }
                    else -> { val vo = apply(DoubleArray(n) { (L[it] + R[it]) / 2 }, true); val ac = apply(DoubleArray(n) { (L[it] + R[it]) / 2 }, false); put(buf, 0, vo); put(buf, 1, ac) } } }
            "hpss" -> { // 958: harmonik/darbeli ayrım — zaman yönünde yumuşatılmış (harmonik) ve frekans yönünde yumuşatılmış (darbeli) genliklerden yumuşak maske; "İkisi": sol darbeli, sağ harmonik
                val N = 2048; val H = N / 4; val tw = max(1, (v("zamanPenc") / 1000 * rate / H).roundToInt()); val fw = max(1, (v("frekansPenc") / rate * N).roundToInt()); val p = 1 + v("ayirmaSert") / 100 * 3; val mode = v("cikti").roundToInt()
                fun sep(x: DoubleArray, harmonic: Boolean): DoubleArray { val mags = ArrayList<DoubleArray>(); stft(x, N) { re, im, _ -> mags += DoubleArray(N / 2) { hypot(re[it], im[it]) } }
                    return stft(x, N) { re, im, f -> for (k in 0 until N / 2) { var hs = 0.0; var hn = 0; for (d in -tw..tw) mags.getOrNull(f + d)?.let { hs += it[k]; hn++ }; var ps = 0.0; var pn = 0; for (d in -fw..fw) { val kk = k + d; if (kk in 0 until N / 2) { ps += mags[f][kk]; pn++ } }
                        val hh = (hs / max(1, hn)).pow(p); val pp = (ps / max(1, pn)).pow(p); val mh = hh / (hh + pp + 1e-12); val g = if (harmonic) mh else 1 - mh; re[k] *= g; im[k] *= g; if (k > 0) { re[N - k] *= g; im[N - k] *= g } } } }
                if (mode == 2) { val m = DoubleArray(n) { (buf[it * 2] + buf[it * 2 + 1]) / 2.0 }; put(buf, 0, sep(m, false)); put(buf, 1, sep(m, true)) }
                else for (c in 0..1) put(buf, c, sep(ch(buf, c), mode == 1)) }
            "autotune" -> { // 961: blok başına perde ölçülür, gamdaki en yakın notaya oranla kaydırılır (tepki: oran yumuşatma)
                val scale = when (v("gam").roundToInt()) { 1 -> intArrayOf(0, 2, 4, 5, 7, 9, 11); 2 -> intArrayOf(0, 2, 3, 5, 7, 8, 10); else -> IntArray(12) { it } }
                val mono = DoubleArray(n) { (buf[it * 2] + buf[it * 2 + 1]) / 2.0 }; val B = rate / 50; val ratios = DoubleArray(n / B + 2) { 1.0 }; var r = 1.0; val a = exp(-B.toDouble() / max(1.0, v("tepki") / 1000 * rate))
                for (b in ratios.indices) { val (f0, conf) = pitch(mono, b * B, rate); var target = 1.0
                    if (f0 > 0 && conf > 0.6) { val midi = 69 + 12 * log2(f0 / 440.0); val pc = ((midi.roundToInt() % 12) + 12) % 12; val near = scale.minByOrNull { d -> min(abs(d - pc), 12 - abs(d - pc)) } ?: pc
                        var tm = midi.roundToInt() - pc + near; if (tm - midi > 6) tm -= 12; if (midi - tm > 6) tm += 12; target = 2.0.pow((tm - midi) / 12 * v("duzeltme") / 100) }
                    r = a * r + (1 - a) * target; ratios[b] = r }
                AudioFx.shiftPitch(buf, rate, { i -> ratios[(i / B).coerceIn(0, ratios.size - 1)] }, rate * 0.04, { 1.0 }, { 1.0 }, true) }
            "silencegap" -> { // 965: eşik altındaki ve en az süreden uzun sessiz aralıklar (kenar payı bırakılarak) susturulur; yalnız analizde dokunulmaz
                if (v("yalnizAnal") >= 0.5) return true; val th = db(v("esik")); val W = max(1, rate / 100); val minS = (v("enAzSess") * rate).toInt(); val pad = (v("kenarPayi") * rate).toInt()
                val quiet = BooleanArray(n / W + 1) { b -> var m = 0.0; for (i in b * W until min(n, (b + 1) * W)) m = max(m, abs(buf[i * 2].toDouble()) + abs(buf[i * 2 + 1].toDouble())); m / 2 < th }
                var b = 0; while (b < quiet.size) { if (!quiet[b]) { b++; continue }; var e2 = b; while (e2 < quiet.size && quiet[e2]) e2++; val s0 = b * W + pad; val s1 = min(n, e2 * W) - pad
                    if ((e2 - b) * W >= minS && s1 > s0) for (i in s0 until s1) { val g = min(1.0, min(i - s0, s1 - i).toDouble() / max(1, rate / 200)); buf[i * 2] = (buf[i * 2] * (1 - g)).toFloat(); buf[i * 2 + 1] = (buf[i * 2 + 1] * (1 - g)).toFloat() }; b = e2 } }
            "binaural3d" -> { // 966: azimut → kulaklar arası gecikme (ITD) ve seviye/gölge filtresi (ILD); yükseklik tizleri değiştirir; uzaklık zayıflatır
                val x = v("konumX"); val y = v("konumY"); val z = v("konumZ"); val az = atan2(x, max(1.0, -z + 100)); val el = atan2(-y, 100.0); val dist = max(0.1, v("mesafe")); val wet = v("islakKari") / 100
                val itd = (0.00066 * sin(az) * rate); val mono = DoubleArray(n) { (buf[it * 2] + buf[it * 2 + 1]) / 2.0 }; val g = 1 / dist
                val shadowL = AudioFx.Biquad().apply { set(0, 1500.0 + 14000.0 * (1 - max(0.0, sin(az))), 0.7, 0.0, rate) }; val shadowR = AudioFx.Biquad().apply { set(0, 1500.0 + 14000.0 * (1 - max(0.0, -sin(az))), 0.7, 0.0, rate) }
                val elv = AudioFx.Biquad().apply { set(4, 7000.0, 0.7, el * 8, rate) }
                for (i in 0 until n) { fun at(d: Double): Double { val p = i - d; val j = floor(p).toInt(); val f = p - j; return if (j >= 0 && j + 1 < n) mono[j] * (1 - f) + mono[j + 1] * f else 0.0 }
                    val l2 = elv.run(shadowL.run(at(max(0.0, itd)))) * g; val r2 = shadowR.run(at(max(0.0, -itd))) * g
                    buf[i * 2] = (buf[i * 2] * (1 - wet) + l2 * wet).toFloat(); buf[i * 2 + 1] = (buf[i * 2 + 1] * (1 - wet) + r2 * wet).toFloat() } }
            "earlyreflect" -> { // 967: görüntü kaynağı yöntemi, altı birinci derece yansıma (oda boyutları ve kaynak konumundan gecikme/zayıflama)
                val W = max(1.0, v("odaX")); val Hh = max(1.0, v("odaY")); val D = max(1.0, v("odaZ")); val sx = v("kaynakX").coerceIn(0.0, W); val sy = v("kaynakY").coerceIn(0.0, Hh); val sz = v("kaynakZ").coerceIn(0.0, D)
                val lx = W / 2; val ly = Hh / 2; val lz = D / 2; val absorb = 1 - v("yuzeyEmil") / 100; val mix = v("yansimaKari") / 100; val c = 343.0
                val imgs = listOf(doubleArrayOf(-sx, sy, sz), doubleArrayOf(2 * W - sx, sy, sz), doubleArrayOf(sx, -sy, sz), doubleArrayOf(sx, 2 * Hh - sy, sz), doubleArrayOf(sx, sy, -sz), doubleArrayOf(sx, sy, 2 * D - sz))
                val direct = sqrt((sx - lx).pow(2) + (sy - ly).pow(2) + (sz - lz).pow(2)).coerceAtLeast(0.3); val src = buf.copyOf()
                imgs.forEachIndexed { k, p -> val d = sqrt((p[0] - lx).pow(2) + (p[1] - ly).pow(2) + (p[2] - lz).pow(2)); val delay = ((d - direct) / c * rate).toInt().coerceAtLeast(1); val g = absorb * direct / d * mix; val pan = if (k == 0) 0.8 else if (k == 1) -0.8 else 0.0
                    for (i in delay until n) { buf[i * 2] += (src[(i - delay) * 2] * g * (1 - pan) * 0.5 * 2).toFloat() * 0.5f; buf[i * 2 + 1] += (src[(i - delay) * 2 + 1] * g * (1 + pan) * 0.5 * 2).toFloat() * 0.5f } } }
            "reverseverb" -> { // 968: ters yankı — ses ters çevrilir, yankılanır, yeniden ters çevrilir: olaydan önce büyüyen kuyruk
                val tail = max(0.05, v("kuyruk")); val pre = (v("onBosl") * rate).toInt(); val mix = v("karisim") / 100; val keep = v("anaSesiKoru") >= 0.5
                for (c in 0..1) { val x = ch(buf, c); val r = x.reversedArray(); val out = DoubleArray(n); var fb = 0.0; val dl = IntArray(6) { (rate * (0.029 + it * 0.0071)).toInt() }; val lines = dl.map { DoubleArray(it) }; val w = IntArray(6); val g = 10.0.pow(-3.0 * dl.average() / (tail * rate))
                    for (i in 0 until n) { var y = 0.0; for (k in 0 until 6) { val b = lines[k]; val o = b[w[k]]; b[w[k]] = r[i] * 0.2 + o * g; w[k] = (w[k] + 1) % b.size; y += o }; out[i] = y / 3; fb = y }
                    val back = out.reversedArray(); for (i in 0 until n) { val j = i + pre; val wv = if (j < n) back[j] else 0.0; buf[i * 2 + c] = ((if (keep) x[i] else x[i] * (1 - mix)) + wv * mix).toFloat() } } }
            "freqshift" -> { // 969: tek yan bant frekans kaydırma (analitik sinyal × e^{i2πft}); stereo ayrı: sağ kanal ters yöne
                val sh = v("kaydirma"); val mix = v("karisim") / 100; val N = 4096
                for (c in 0..1) { val x = ch(buf, c); val dir = if (c == 1 && v("stereoAyri") >= 0.5) -1.0 else 1.0; val hil = stft(x, N) { re, im, _ -> for (k in 1 until N / 2) { val t = re[k]; re[k] = im[k]; im[k] = -t }; for (k in N / 2 + 1 until N) { val t = re[k]; re[k] = -im[k]; im[k] = t }; re[0] = 0.0; im[0] = 0.0 }
                    for (i in 0 until n) { val ph = 2 * PI * sh * dir * i / rate; val y = x[i] * cos(ph) - hil[i] * sin(ph); buf[i * 2 + c] = (x[i] * (1 - mix) + y * mix).toFloat() } } }
            "specblur" -> { // 970: genlik spektrumu frekans ve zaman boyunca yumuşatılır (faz korunur)
                val N = 2048; val fw = max(0, (v("frekansYayi") / rate * N).roundToInt()); val tw = max(0, (v("zamanYayi") / 1000 * rate / (N / 4)).roundToInt()); val mix = v("karisim") / 100
                for (c in 0..1) { val x = ch(buf, c); val mags = ArrayList<DoubleArray>(); stft(x, N) { re, im, _ -> mags += DoubleArray(N / 2) { hypot(re[it], im[it]) } }
                    val y = stft(x, N) { re, im, f -> for (k in 1 until N / 2) { var s = 0.0; var cnt = 0; for (d in -tw..tw) { val m = mags.getOrNull(f + d) ?: continue; for (e2 in -fw..fw) { val kk = k + e2; if (kk in 0 until N / 2) { s += m[kk]; cnt++ } } }
                        val target = s / max(1, cnt); val cur = hypot(re[k], im[k]); val g = if (cur > 1e-9) target / cur else 0.0; re[k] *= g; im[k] *= g; re[N - k] *= g; im[N - k] *= g } }
                    for (i in 0 until n) buf[i * 2 + c] = (x[i] * (1 - mix) + y[i] * mix).toFloat() } }
            "audiofreeze" -> { // 971: başlangıçtaki kısa örnek, çapraz geçişli döngüyle sürdürme süresince tekrarlanır; sonra kayıt kaldığı yerden sürer
                val s0 = (v("donguBasl") * rate).toInt().coerceIn(0, n - 1); val L = max(8, (v("ornekUzun") / 1000 * rate).toInt()); val hold = (v("surdurme") * rate).toInt(); val xf = max(1, (v("caprazGeci") / 1000 * rate).toInt().coerceAtMost(L / 2)); val src = buf.copyOf()
                if (s0 + L >= n) return true
                for (i in 0 until n) { val j = when { i < s0 -> i; i < s0 + hold -> { val k = (i - s0) % L; s0 + k }; else -> i - hold + L }; for (c in 0..1) { var y = if (j in 0 until n) src[j * 2 + c] else 0f
                    if (i in s0 until s0 + hold) { val k = (i - s0) % L; if (k < xf && i - s0 >= L) { val f = k.toFloat() / xf; val jp = s0 + L + k - L; y = y * f + (if (s0 + L - xf + k in 0 until n) src[(s0 + L - xf + k) * 2 + c] else 0f) * (1 - f) } }
                    buf[i * 2 + c] = y } } }
            "harmonizer" -> { // 972: gamda üçlü ve beşli üstte perde kaydırılmış kopyalar; seviye ve stereo dağılım
                val minor = v("gam").roundToInt() == 1; val lvl = db(v("harmoniSevi")); val spread = v("stereoDagi") / 100; val src = buf.copyOf()
                val a = src.copyOf(); AudioFx.shiftPitch(a, rate, { 2.0.pow((if (minor) 3 else 4) / 12.0) }, rate * 0.04, { 1.0 }, { 1.0 }, true)
                val b = src.copyOf(); AudioFx.shiftPitch(b, rate, { 2.0.pow(7 / 12.0) }, rate * 0.04, { 1.0 }, { 1.0 }, true)
                for (i in 0 until n) { val ha = (a[i * 2] + a[i * 2 + 1]) / 2f; val hb = (b[i * 2] + b[i * 2 + 1]) / 2f
                    buf[i * 2] = (src[i * 2] + (ha * (1 + spread) / 2 + hb * (1 - spread) / 2) * lvl).toFloat(); buf[i * 2 + 1] = (src[i * 2 + 1] + (ha * (1 - spread) / 2 + hb * (1 + spread) / 2) * lvl).toFloat() } }
            "roombox" -> { // 973: kutu odanın eksenel modları (c / 2L × k) rezonans süzgeçleriyle; sönüm Q'yu, tavan kazancı sınırlar
                val dims = doubleArrayOf(max(0.3, v("boyutX")), max(0.3, v("boyutY")), max(0.3, v("boyutZ"))); val q = 2 + (100 - v("sonum")) / 100 * 30; val mix = v("karisim") / 100; val cap = v("rezonansTava")
                val modes = dims.flatMap { L -> (1..3).map { k -> 343.0 / (2 * L) * k } }.filter { it < rate * 0.45 }.take(9)
                for (c in 0..1) { val fs = modes.map { f -> AudioFx.Biquad().apply { set(2, f, q, cap, rate) } }; for (i in 0 until n) { val x = buf[i * 2 + c].toDouble(); var y = x; for (f in fs) y = f.run(y); buf[i * 2 + c] = (x * (1 - mix) + y * mix).toFloat() } } }
            "parallelchain" -> { // 974: seçilen katmanların efekt zincirleri bu sese ayrı ayrı (paralel) uygulanır ve ortalanarak karıştırılır
                val pr = AudioFx.project ?: return true; val ids = e.c?.get("islemKoll")?.split(',')?.filter { it.isNotBlank() } ?: return true; val src = buf.copyOf(); val acc = FloatArray(buf.size); var k = 0
                for (id in ids.take(4)) { val o = pr.layers.find { it.id == id } ?: continue; if (o.id == l.id) continue; val copy = src.copyOf(); AudioFx.apply(o.copy(start = l.start, effects = o.effects.filter { it.type in AudioFx.TYPES && it.type != "parallelchain" }), copy, rate, side); for (i in acc.indices) acc[i] += copy[i]; k++ }
                if (k == 0) return true; val g = db(v("cikis")) / k; for (i in buf.indices) buf[i] = (acc[i] * g).toFloat() }
            "chanalign" -> { // 975: iki kanal arasındaki gecikme çapraz ilintiyle bulunur; seçilen kanal referansa hizalanır
                val maxL = (v("aramaSini") / 1000 * rate).toInt().coerceIn(1, rate / 2); val L = ch(buf, 0); val R = ch(buf, 1); var best = 0.0; var lag = 0; val win = min(n, rate * 10)
                for (d in -maxL..maxL) { var c = 0.0; var i = max(0, -d); while (i < win - max(0, d)) { c += L[i] * R[i + d]; i += 4 }; if (c > best) { best = c; lag = d } }
                val sh = (lag * v("guc") / 100).roundToInt(); val refRight = v("referans").roundToInt() == 1
                if (refRight) for (i in 0 until n) { val j = i - sh; buf[i * 2] = if (j in 0 until n) L[j].toFloat() else 0f } else for (i in 0 until n) { val j = i + sh; buf[i * 2 + 1] = if (j in 0 until n) R[j].toFloat() else 0f } }
            "specmatch" -> { // 976: referans sesin uzun dönem spektrumu bu sese yumuşak eğriyle aktarılır (sınırlı dB)
                val id = e.c?.get("referans")?.takeIf { it.isNotBlank() } ?: return true; val ref = side("raw:$id") ?: side(id) ?: return true; val N = 4096; val span = (v("analizSure") * rate).toInt()
                fun ltas(b: FloatArray): DoubleArray { val m = DoubleArray(N / 2); val x = DoubleArray(min(b.size / 2, span)) { (b[it * 2] + b[it * 2 + 1]) / 2.0 }; var cnt = 0; stft(x, N) { re, im, _ -> for (k in 0 until N / 2) m[k] += hypot(re[k], im[k]); cnt++ }; for (k in m.indices) m[k] = m[k] / max(1, cnt); return m }
                val a = ltas(buf); val r = ltas(ref); val lim = v("duzeltmeSini"); val k2 = v("guc") / 100
                val gain = DoubleArray(N / 2) { k -> var sa = 0.0; var sr = 0.0; val w = max(2, k / 6); for (d in -w..w) { val kk = (k + d).coerceIn(0, N / 2 - 1); sa += a[kk]; sr += r[kk] }; val dbv = (20 * log10((sr + 1e-9) / (sa + 1e-9))).coerceIn(-lim, lim) * k2; db(dbv) }
                for (c in 0..1) { val x = ch(buf, c); put(buf, c, stft(x, N) { re, im, _ -> for (k in 1 until N / 2) { re[k] *= gain[k]; im[k] *= gain[k]; re[N - k] *= gain[k]; im[N - k] *= gain[k] } }) } }
        }
        return true
    }
}
