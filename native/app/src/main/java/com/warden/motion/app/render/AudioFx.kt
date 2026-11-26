package com.warden.motion.app.render

import com.warden.motion.app.model.Effect
import com.warden.motion.app.model.Layer
import com.warden.motion.app.model.value
import kotlin.math.*

/**
 * Ses efektleri (Ses kategorisi + 540–550). Katmanın stereo sesi (iç içe L,R; katman zamanı 0'dan) yerinde işlenir.
 * Ayarlar 256 örneklik bloklar hâlinde okunur; anahtar kareler böylece ses boyunca uygulanır.
 */
object AudioFx {
    val TYPES = setOf("reverse", "basstreble", "delay", "flanger", "filter", "modulator", "parameq", "reverb", "stereo", "tone",
        "compressor", "limiter", "noisegate", "deesser", "pitchshift", "voicechar", "audiodenoise", "ducking", "stereowide", "robotvoice", "audiodistort",
        "loudnorm", "peaknorm", "dcremove", "declick", "declip", "dropoutfix", "notchfilter", "dynamiceq", "multibandcomp", "expander", "transient", "phaseinvert", "chandelay",
        "phaser", "rotary", "convreverb", "specfreeze", "granular", "speechrate", "autocrossfade", "autopan", "distancefx")
    fun has(l: Layer) = l.effects.any { it.on != false && it.type in TYPES }
    fun signature(l: Layer) = l.effects.filter { it.on != false && it.type in TYPES }.hashCode()

    private const val BLK = 256
    private fun db(x: Double) = 10.0.pow(x / 20.0)

    /** İkinci derece filtre (RBJ) */
    class Biquad { var b0 = 1.0; var b1 = 0.0; var b2 = 0.0; var a1 = 0.0; var a2 = 0.0; private var x1 = 0.0; private var x2 = 0.0; private var y1 = 0.0; private var y2 = 0.0
        fun set(type: Int, f: Double, q: Double, gainDb: Double, rate: Int) { val w = 2 * PI * f.coerceIn(10.0, rate * 0.49) / rate; val cs = cos(w); val sn = sin(w); val al = sn / (2 * max(q, 0.05)); val A = 10.0.pow(gainDb / 40)
            var B0: Double; var B1: Double; var B2: Double; var A0: Double; var A1: Double; var A2: Double
            when (type) {
                0 -> { B0 = (1 - cs) / 2; B1 = 1 - cs; B2 = (1 - cs) / 2; A0 = 1 + al; A1 = -2 * cs; A2 = 1 - al } // alçak geçiren
                1 -> { B0 = (1 + cs) / 2; B1 = -(1 + cs); B2 = (1 + cs) / 2; A0 = 1 + al; A1 = -2 * cs; A2 = 1 - al } // yüksek geçiren
                2 -> { B0 = 1 + al * A; B1 = -2 * cs; B2 = 1 - al * A; A0 = 1 + al / A; A1 = -2 * cs; A2 = 1 - al / A } // tepe
                3 -> { val s = 2 * sqrt(A) * al; B0 = A * ((A + 1) - (A - 1) * cs + s); B1 = 2 * A * ((A - 1) - (A + 1) * cs); B2 = A * ((A + 1) - (A - 1) * cs - s); A0 = (A + 1) + (A - 1) * cs + s; A1 = -2 * ((A - 1) + (A + 1) * cs); A2 = (A + 1) + (A - 1) * cs - s } // alçak raf
                4 -> { val s = 2 * sqrt(A) * al; B0 = A * ((A + 1) + (A - 1) * cs + s); B1 = -2 * A * ((A - 1) + (A + 1) * cs); B2 = A * ((A + 1) + (A - 1) * cs - s); A0 = (A + 1) - (A - 1) * cs + s; A1 = 2 * ((A - 1) - (A + 1) * cs); A2 = (A + 1) - (A - 1) * cs - s } // yüksek raf
                else -> { B0 = al; B1 = 0.0; B2 = -al; A0 = 1 + al; A1 = -2 * cs; A2 = 1 - al } // bant geçiren
            }
            b0 = B0 / A0; b1 = B1 / A0; b2 = B2 / A0; a1 = A1 / A0; a2 = A2 / A0 }
        fun run(x: Double): Double { val y = b0 * x + b1 * x1 + b2 * x2 - a1 * y1 - a2 * y2; x2 = x1; x1 = x; y2 = y1; y1 = y; return y }
    }

    /** Gecikme hattı (kesirli okuma) */
    class Line(n: Int) { val b = DoubleArray(max(n, 4)); var w = 0
        fun push(x: Double) { b[w] = x; w = (w + 1) % b.size }
        fun read(d: Double): Double { val p = w - 1 - d; val i = floor(p).toInt(); val f = p - i; val a = b[((i % b.size) + b.size) % b.size]; val c = b[(((i + 1) % b.size) + b.size) % b.size]; return a + (c - a) * f } }

    /** Kendi içinde zaman sınırlı bir ses parçası: buf (L,R), örnek hızı; sidechain = başka katmanın sesi (Otomatik Müzik Kısma) */
    /** pos: görsel katmanın o anki yatay konumu (−1 sol … 1 sağ) ve uzaklık oranı; Hareketli Ses Konumu için */
    var pos: (String, Double) -> DoubleArray? = { _, _ -> null }
    fun apply(l: Layer, buf: FloatArray, rate: Int, sidechain: (String) -> FloatArray? = { null }) {
        for (e in l.effects) { if (e.on == false || e.type !in TYPES) continue; runCatching { if (!AudioFx2.one(e, l, buf, rate, sidechain)) one(e, l, buf, rate, sidechain) } }
    }

    private fun one(e: Effect, l: Layer, buf: FloatArray, rate: Int, side: (String) -> FloatArray?) {
        val n = buf.size / 2; if (n == 0) return
        fun v(k: String, i: Int) = e.value(k, l.start + i.toDouble() / rate)
        when (e.type) {
            "reverse" -> { if (v("tersOyna", 0) < 0.5) return; val a = (v("baslangi", 0) * rate).toInt().coerceIn(0, n); val bEnd = v("bitis", 0); val b = (if (bEnd <= 0) n else (bEnd * rate).toInt()).coerceIn(a, n)
                val dry = v("orijinalKari", 0) / 100; val src = buf.copyOf(); val xf = max(1, (v("kenarGeci", 0) * rate).toInt())
                for (i in a until b) { val j = b - 1 - (i - a); val g = min(1.0, min(i - a, b - 1 - i).toDouble() / xf); for (c in 0..1) buf[i * 2 + c] = ((src[j * 2 + c] * g + src[i * 2 + c] * (1 - g)) * (1 - dry) + src[i * 2 + c] * dry).toFloat() } }
            "basstreble", "parameq", "filter" -> {
                val fs = Array(2) { Array(4) { Biquad() } }
                for (s0 in 0 until n step BLK) {
                    when (e.type) {
                        "basstreble" -> for (c in 0..1) { fs[c][0].set(3, v("basSini", s0), 0.707, v("bas", s0), rate); fs[c][1].set(4, v("tizSini", s0), 0.707, v("tiz", s0), rate) }
                        "parameq" -> for (c in 0..1) for (k in 1..3) fs[c][k - 1].set(2, v("bant${k}Frek", s0), v("bant${k}Q", s0), v("bant${k}Kaza", s0), rate)
                        else -> for (c in 0..1) for (k in 0..3) fs[c][k].set(if (v("mod", s0) >= 0.5) 1 else 0, v("kesimFrek", s0), if (k == 0) v("rezonans", s0) else 0.707, 0.0, rate)
                    }
                    val stages = when (e.type) { "basstreble" -> 2; "parameq" -> 3; else -> when (v("egim", s0).roundToInt()) { 0 -> 1; 1 -> 2; else -> 4 } }
                    val out = db(when (e.type) { "basstreble" -> v("cikisKaza", s0); "parameq" -> v("cikis", s0); else -> 0.0 }); val mix = if (e.type == "filter") v("karisim", s0) / 100 else 1.0
                    for (i in s0 until min(n, s0 + BLK)) for (c in 0..1) { val x = buf[i * 2 + c].toDouble(); var y = x; for (k in 0 until stages) y = fs[c][k].run(y); buf[i * 2 + c] = ((x * (1 - mix) + y * mix) * out).toFloat() }
                } }
            "delay" -> { val L = Array(2) { Line(rate * 5 + 4) }
                for (i in 0 until n) { val bt = if (v("tempoEsle", i) >= 0.5) 60.0 / max(20.0, v("tempo", i)) * when (v("nota", i).roundToInt()) { 0 -> 1.0; 1 -> 0.5; else -> 0.25 } else v("gecikme", i)
                    val d = (bt * rate).coerceIn(1.0, rate * 5.0); val fb = v("geriBesl", i) / 100; val wet = v("islakSiny", i) / 100; val dry = v("kuruSiny", i) / 100; val pp = v("stereoPingPong", i) >= 0.5
                    val x0 = buf[i * 2].toDouble(); val x1 = buf[i * 2 + 1].toDouble(); val y0 = L[0].read(d); val y1 = L[1].read(d)
                    if (pp) { L[0].push(x0 * 0.5 + x1 * 0.5 + y1 * fb); L[1].push(y0 * fb) } else { L[0].push(x0 + y0 * fb); L[1].push(x1 + y1 * fb) }
                    buf[i * 2] = (x0 * dry + y0 * wet).toFloat(); buf[i * 2 + 1] = (x1 * dry + y1 * wet).toFloat() } }
            "flanger" -> { val L = Array(2) { Line(rate / 10 + 4) }; var ph = 0.0
                for (i in 0 until n) { if (i % BLK == 0) Unit; val chorus = v("mod", i) >= 0.5; val base = v("gecikme", i) / 1000 * rate * (if (chorus) 2.0 else 1.0); val dep = v("derinlik", i) / 1000 * rate; val fb = if (chorus) 0.0 else v("geriBesl", i) / 100
                    ph += 2 * PI * v("frekans", i) / rate; val sw = v("stereoGeni", i) / 100 * PI * 0.5; val mix = v("karisim", i) / 100
                    for (c in 0..1) { val d = (base + dep * (0.5 + 0.5 * sin(ph + c * sw))).coerceIn(1.0, rate / 10.0); val x = buf[i * 2 + c].toDouble(); val y = L[c].read(d); L[c].push(x + y * fb); buf[i * 2 + c] = (x * (1 - mix * 0.5) + y * mix).toFloat() } } }
            "modulator" -> { val L = Array(2) { Line(rate / 20 + 4) }; var ph = 0.0
                for (i in 0 until n) { ph += 2 * PI * v("frekans", i) / rate; val p = ph + v("faz", i) * PI / 180; val w = if (v("dalga", i) >= 0.5) 1 - 4 * abs(((p / (2 * PI)) % 1 + 1) % 1 - 0.5) else sin(p); val mix = v("karisim", i) / 100
                    for (c in 0..1) { val x = buf[i * 2 + c].toDouble(); val y = if (v("mod", i) < 0.5) x * (1 - v("sesDeri", i) / 100 * (0.5 - 0.5 * w)) else { L[c].push(x); val dep = (2.0.pow(v("perdeDeri", i) / 1200) - 1) * rate / (2 * PI * max(0.1, v("frekans", i))); L[c].read((dep * (1 + w) + 2).coerceIn(1.0, rate / 20.0 - 2)) }
                        buf[i * 2 + c] = (x * (1 - mix) + y * mix).toFloat() } } }
            "reverb" -> reverb(e, l, buf, rate)
            "stereo" -> for (i in 0 until n) { var a = buf[i * 2] * db(v("solKaza", i)); var b = buf[i * 2 + 1] * db(v("sagKaza", i)); if (v("kanallarDegi", i) >= 0.5) { val t = a; a = b; b = t }
                val m = (a + b) / 2; val s = (a - b) / 2 * v("genislik", i) / 100; a = m + s; b = m - s; if (v("mono", i) >= 0.5) { a = m; b = m }
                val pan = v("pan", i) / 100; buf[i * 2] = (a * min(1.0, 1 - pan)).toFloat(); buf[i * 2 + 1] = (b * min(1.0, 1 + pan)).toFloat() }
            "tone" -> { var p1 = 0.0; var p2 = 0.0
                for (i in 0 until n) { val t = i.toDouble() / rate; val dur = n.toDouble() / rate; val g = db(v("sesSevi", i)) * min(1.0, t / max(1e-3, v("baslangiYumu", i))) * min(1.0, (dur - t) / max(1e-3, v("bitisYumu", i)))
                    p1 += 2 * PI * v("frekans", i) / rate; p2 += 2 * PI * v("ikinciFrek", i) / rate; val k = v("dalga", i).roundToInt(); val ph0 = v("faz", i) * PI / 180
                    fun w(p: Double): Double { val x = ((p + ph0) / (2 * PI)) % 1; return when (k) { 1 -> 1 - 4 * abs(x - 0.5); 2 -> if (x < 0.5) 1.0 else -1.0; 3 -> 2 * x - 1; else -> sin(p + ph0) } }
                    val s = (w(p1) + if (v("ikinciTon", i) >= 0.5) w(p2) else 0.0) * g; buf[i * 2] += s.toFloat(); buf[i * 2 + 1] += s.toFloat() } }
            "compressor", "limiter", "noisegate" -> dynamics(e, l, buf, rate)
            "deesser" -> { val det = Array(2) { Biquad() }; val split = Array(2) { Biquad() }; var env = 0.0
                for (i in 0 until n) { if (i % BLK == 0) for (c in 0..1) { det[c].set(5, v("merkezFrek", i), 1.0 / max(0.1, v("bantGeni", i)), 0.0, rate); split[c].set(5, v("merkezFrek", i), 1.0 / max(0.1, v("bantGeni", i)), 0.0, rate) }
                    val bandL = det[0].run(buf[i * 2].toDouble()); val bandR = det[1].run(buf[i * 2 + 1].toDouble()); val lvl = max(abs(bandL), abs(bandR))
                    val at = exp(-1.0 / (max(0.1, v("saldiri", i)) / 1000 * rate)); val rl = exp(-1.0 / (max(1.0, v("birakma", i)) / 1000 * rate)); env = if (lvl > env) at * env + (1 - at) * lvl else rl * env + (1 - rl) * lvl
                    val over = 20 * log10(max(env, 1e-9)) - v("esik", i); val red = if (over > 0) min(v("maksimumAzal", i), over) else 0.0; val g = db(-red)
                    if (v("yalnizAlgiBand", i) >= 0.5) { buf[i * 2] = bandL.toFloat(); buf[i * 2 + 1] = bandR.toFloat(); continue }
                    if (v("yontem", i) < 0.5) { buf[i * 2] = (buf[i * 2] - bandL * (1 - g)).toFloat(); buf[i * 2 + 1] = (buf[i * 2 + 1] - bandR * (1 - g)).toFloat() } else { buf[i * 2] = (buf[i * 2] * g).toFloat(); buf[i * 2 + 1] = (buf[i * 2 + 1] * g).toFloat() } } }
            "pitchshift" -> { val q = v("kalite", 0).roundToInt(); val win = when (q) { 0 -> 0.03; 1 -> 0.05; else -> 0.08 } * rate
                shiftPitch(buf, rate, { i -> 2.0.pow((v("yarimSes", i) + v("inceAyar", i) / 100) / 12) }, win, { i -> v("karisim", i) / 100 }, { i -> db(v("kazanc", i)) }, v("sureyiKoru", 0) >= 0.5) }
            "voicechar" -> { val k0 = 2.0.pow(v("formantKaym", 0) / 12); val src = buf.copyOf()
                // Biçimlendiriciyi kaydır: yeniden örnekle (perde + formant), sonra perdeyi tanecikli kaydırmayla geri al → formant kayar, perde korunur
                if (abs(k0 - 1) > 1e-3) { for (i in 0 until n) { val p = i * k0; val j = p.toInt(); val f = p - j; for (c in 0..1) buf[i * 2 + c] = if (j + 1 < n) (src[j * 2 + c] * (1 - f) + src[j * 2 + 2 + c] * f).toFloat() else 0f }
                    if (v("perdeyiKoru", 0) >= 0.5) shiftPitch(buf, rate, { 1.0 / k0 }, 0.04 * rate, { 1.0 }, { 1.0 }, true) }
                val f = Array(2) { Array(3) { Biquad() } }; for (c in 0..1) { f[c][0].set(4, 3000.0, 0.707, v("parlakli", 0) / 100 * 9, rate); f[c][1].set(3, 220.0, 0.707, v("govde", 0) / 100 * 9, rate); f[c][2].set(2, 1100.0, 1.4, v("burunsul", 0) / 100 * 9, rate) }
                val mix = v("karisim", 0) / 100; val g = db(v("kazanc", 0)); for (i in 0 until n) for (c in 0..1) { var y = buf[i * 2 + c].toDouble(); for (k in 0..2) y = f[c][k].run(y); buf[i * 2 + c] = ((src[i * 2 + c] * (1 - mix) + y * mix) * g).toFloat() } }
            "audiodenoise" -> denoise(e, l, buf, rate)
            "ducking" -> { val sc = e.c?.get("konusmaKatm")?.let(side) ?: return; var env = 0.0; var hold = 0; var gain = 1.0; val la = (v("ileriBaki", 0) / 1000 * rate).toInt()
                for (i in 0 until n) { val j = i + la; val s = if (j < sc.size / 2) max(abs(sc[j * 2]), abs(sc[j * 2 + 1])).toDouble() else 0.0; env = max(s, env * exp(-1.0 / (0.01 * rate)))
                    val on = 20 * log10(max(env, 1e-9)) > v("esik", i); if (on) hold = (v("bekleme", i) / 1000 * rate).toInt() else if (hold > 0) hold--
                    val target = if (on || hold > 0) db(v("kismaMikt", i)) else 1.0; val tc = if (target < gain) v("saldiri", i) else v("birakma", i); val k = exp(-1.0 / (max(1.0, tc) / 1000 * rate)); gain = target + (gain - target) * k
                    buf[i * 2] = (buf[i * 2] * gain).toFloat(); buf[i * 2 + 1] = (buf[i * 2 + 1] * gain).toFloat() } }
            "stereowide" -> { val lp = Biquad(); for (i in 0 until n) { if (i % BLK == 0) lp.set(0, v("basSini", i), 0.707, 0.0, rate); val a = buf[i * 2].toDouble(); val b = buf[i * 2 + 1].toDouble()
                    val m = (a + b) / 2 * db(v("ortaKanaKaza", i)); var s = (a - b) / 2 * db(v("yanKanaKaza", i)); val bass = lp.run(s); if (v("baslariMerkTut", i) >= 0.5) s -= bass
                    var w = v("genislik", i) / 100; if (v("monoUyumKont", i) >= 0.5) w = min(w, 1.8); val mix = v("karisim", i) / 100; val g = db(v("kazanc", i))
                    buf[i * 2] = ((a * (1 - mix) + (m + s * w) * mix) * g).toFloat(); buf[i * 2 + 1] = ((b * (1 - mix) + (m - s * w) * mix) * g).toFloat() } }
            "robotvoice" -> robot(e, l, buf, rate)
            "audiodistort" -> { val hp = Array(2) { Biquad() }; val lp = Array(2) { Biquad() }; var held = DoubleArray(2); var cnt = 0.0
                for (i in 0 until n) { if (i % BLK == 0) for (c in 0..1) { hp[c].set(1, v("altKesi", i), 0.707, 0.0, rate); lp[c].set(0, v("ustKesi", i), 0.707, 0.0, rate) }
                    val drive = db(v("surus", i) * 6) * (1 + v("bozulmaGucu", i) / 25); val k = v("bozulmaTuru", i).roundToInt(); val mix = v("karisim", i) / 100; val out = db(v("cikisKaza", i))
                    cnt += 1.0; val hold = max(1.0, 1.0 / max(0.02, 1 - v("ornekTutmOran", i) / 100 * 0.95)); val refresh = cnt >= hold; if (refresh) cnt = 0.0
                    for (c in 0..1) { val x = buf[i * 2 + c].toDouble(); var y = hp[c].run(x) * drive
                        y = when (k) { 0 -> tanh(y); 1 -> y.coerceIn(-1.0, 1.0); else -> { val q = 2.0.pow(v("bitDeri", i).coerceIn(1.0, 16.0)) / 2; if (refresh) held[c] = floor(y.coerceIn(-1.0, 1.0) * q) / q; held[c] } }
                        y = lp[c].run(y); var r = (x * (1 - mix) + y * mix) * out; if (v("tepeSini", i) >= 0.5) r = r.coerceIn(-1.0, 1.0); buf[i * 2 + c] = r.toFloat() } } }
        }
    }

    private fun dynamics(e: Effect, l: Layer, buf: FloatArray, rate: Int) {
        val n = buf.size / 2
        fun v(k: String, i: Int) = e.value(k, l.start + i.toDouble() / rate)
        val la = if (e.type == "limiter") (v("ileriBaki", 0) / 1000 * rate).toInt().coerceIn(0, rate / 10) else 0
        val src = if (la > 0) buf.copyOf() else buf; var env = 0.0; var env2 = 0.0; var gGate = 0.0; var hold = 0; var open = false; var gl = 1.0
        for (i in 0 until n) {
            val j = min(n - 1, i + la); val pk = if (e.type == "compressor" && v("stereoKanaBagl", i) < 0.5) 0.0 else max(abs(src[j * 2]), abs(src[j * 2 + 1])).toDouble()
            when (e.type) {
                "compressor" -> { val at = exp(-1.0 / (max(0.1, v("saldiri", i)) / 1000 * rate)); val rl = exp(-1.0 / (max(1.0, v("birakma", i)) / 1000 * rate))
                    val lv = if (v("stereoKanaBagl", i) < 0.5) (abs(buf[i * 2]) + abs(buf[i * 2 + 1])) / 2.0 else pk; env = if (lv > env) at * env + (1 - at) * lv else rl * env + (1 - rl) * lv
                    val x = 20 * log10(max(env, 1e-9)); val th = v("esik", i); val r = max(1.0, v("oran", i)); val kn = max(0.01, v("dizYumu", i))
                    val over = x - th; val red = when { over <= -kn / 2 -> 0.0; over >= kn / 2 -> over * (1 - 1 / r); else -> (1 - 1 / r) * (over + kn / 2).pow(2) / (2 * kn) }
                    val g = db(-red + v("telafiKaza", i)); val mix = v("karisim", i) / 100
                    for (c in 0..1) { var y = buf[i * 2 + c] * (1 - mix) + buf[i * 2 + c] * g * mix; if (v("tepeSini", i) >= 0.5) y = y.coerceIn(-1.0, 1.0); buf[i * 2 + c] = y.toFloat() } }
                "limiter" -> { val ceil = db(v("cikisTava", i)); val inG = db(v("girisKaza", i)); val p = pk * inG; val target = if (p > ceil) ceil / p else 1.0
                    val rl = exp(-1.0 / (max(1.0, v("birakma", i)) / 1000 * rate)); gl = if (target < gl) target else target + (gl - target) * rl
                    for (c in 0..1) buf[i * 2 + c] = (src[i * 2 + c] * inG * gl).coerceIn(-ceil, ceil).toFloat() }
                else -> { val lvl = 20 * log10(max(pk, 1e-9)); val th = v("acilmaEsig", i); if (lvl > th) { open = true; hold = (v("bekleme", i) / 1000 * rate).toInt() } else if (lvl < th - v("histerez", i)) { if (hold > 0) hold-- else open = false }
                    val target = if (open) 1.0 else db(v("azaltma", i)); val tc = if (target > gGate) v("saldiri", i) else v("birakma", i); val k = exp(-1.0 / (max(0.1, tc) / 1000 * rate)); gGate = target + (gGate - target) * k
                    if (v("algilamaSinyDinl", i) >= 0.5) { val m = if (open) 1f else 0f; buf[i * 2] *= m; buf[i * 2 + 1] *= m } else { buf[i * 2] = (buf[i * 2] * gGate).toFloat(); buf[i * 2 + 1] = (buf[i * 2 + 1] * gGate).toFloat() } }
            }
        }
    }

    /** İki uçlu gecikme hattıyla perde kaydırma (süre korunur): okuma hızı oranla değişir, iki tanecik üst üste biner */
    private fun shiftPitch(buf: FloatArray, rate: Int, ratio: (Int) -> Double, win: Double, mix: (Int) -> Double, gain: (Int) -> Double, keepDur: Boolean) {
        val n = buf.size / 2; val src = buf.copyOf(); val W = max(64.0, win)
        if (!keepDur) { var p = 0.0; for (i in 0 until n) { val j = p.toInt(); val f = p - j; val m = mix(i); for (c in 0..1) { val y = if (j + 1 < n) src[j * 2 + c] * (1 - f) + src[j * 2 + 2 + c] * f else 0.0; buf[i * 2 + c] = ((src[i * 2 + c] * (1 - m) + y * m) * gain(i)).toFloat() }; p += ratio(i) }; return }
        var ph = 0.0
        for (i in 0 until n) { val r = ratio(i); ph = (ph + (1 - r)) % W; if (ph < 0) ph += W; val m = mix(i); val g = gain(i)
            for (c in 0..1) { var y = 0.0; for (k in 0..1) { val d = (ph + k * W / 2) % W; val pos = i - d; val j = floor(pos).toInt(); val f = pos - j; val s = if (j >= 0 && j + 1 < n) src[j * 2 + c] * (1 - f) + src[j * 2 + 2 + c] * f else 0.0
                    y += s * sin(PI * d / W).pow(2) } ; buf[i * 2 + c] = ((src[i * 2 + c] * (1 - m) + y * m) * g).toFloat() } }
    }

    private fun reverb(e: Effect, l: Layer, buf: FloatArray, rate: Int) {
        val n = buf.size / 2
        fun v(k: String) = e.value(k, l.start)
        val preset = v("hazirOrta").roundToInt(); var size = v("odaBoyu") / 100; var decay = v("sonumSure"); var damp = v("yuksekFrekSonu") / 100
        when (preset) { 0 -> { size = min(size, 0.45); decay = min(decay, 1.0) }; 1 -> { size = max(size, 0.7); decay = max(decay, 2.2) }; 2 -> { size = 1.0; decay = max(decay, 4.0); damp *= 0.5 } }
        val combs = intArrayOf(1116, 1188, 1277, 1356, 1422, 1491, 1557, 1617).map { (it * rate / 44100.0 * (0.5 + size)).toInt() }; val aps = intArrayOf(556, 441, 341, 225).map { (it * rate / 44100.0).toInt() }
        val pre = (v("onGeci") / 1000 * rate).toInt().coerceIn(0, rate); val wet = v("islak") / 100; val dry = v("kuru") / 100; val dif = v("difuzyon") / 100 * 0.7
        for (c in 0..1) { val cb = combs.map { DoubleArray(it + c * 23) }; val cw = IntArray(8); val cf = DoubleArray(8); val ab = aps.map { DoubleArray(it + c * 13) }; val aw = IntArray(4); val pd = DoubleArray(pre + 1); var pw = 0
            for (i in 0 until n) { val x = buf[i * 2 + c].toDouble(); pd[pw] = x; pw = (pw + 1) % pd.size; val xin = pd[pw] * 0.015; var y = 0.0
                for (k in 0 until 8) { val b = cb[k]; val o = b[cw[k]]; val fb = 10.0.pow(-3.0 * b.size / (max(0.1, decay) * rate)); cf[k] = o * (1 - damp) + cf[k] * damp; b[cw[k]] = xin + cf[k] * fb; cw[k] = (cw[k] + 1) % b.size; y += o }
                for (k in 0 until 4) { val b = ab[k]; val o = b[aw[k]]; val t = y + o * dif; b[aw[k]] = t; aw[k] = (aw[k] + 1) % b.size; y = o - t * dif }
                buf[i * 2 + c] = (x * dry + y * wet).toFloat() } }
    }

    private fun robot(e: Effect, l: Layer, buf: FloatArray, rate: Int) {
        val n = buf.size / 2
        fun v(k: String, i: Int) = e.value(k, l.start + i.toDouble() / rate)
        val mode = v("mod", 0).roundToInt(); var ph = 0.0
        val B = v("vocoderBantSayi", 0).roundToInt().coerceIn(4, 32); val anal = Array(B) { Biquad() }; val syn = Array(B) { Biquad() }; val env = DoubleArray(B)
        if (mode == 1) for (b in 0 until B) { val f = 120.0 * (8000.0 / 120.0).pow(b.toDouble() / (B - 1)); anal[b].set(5, f, 6.0, 0.0, rate); syn[b].set(5, f, 6.0, 0.0, rate) }
        val tone = Biquad(); tone.set(4, 2500.0, 0.707, (v("tini", 0) - 50) / 50 * 9, rate)
        for (i in 0 until n) { ph += 2 * PI * v("tasiyiciFrek", i) / rate; val wk = v("tasiyiciDalg", i).roundToInt(); val x01 = (ph / (2 * PI)) % 1
            val car = when (wk) { 1 -> 1 - 4 * abs(x01 - 0.5); 2 -> if (x01 < 0.5) 1.0 else -1.0; else -> sin(ph) }; val mix = v("karisim", i) / 100; val dep = v("modulasyGucu", i) / 100; val g = db(v("kazanc", i))
            val mono = (buf[i * 2] + buf[i * 2 + 1]) / 2.0; var y = when (mode) {
                0 -> mono * (1 - dep + dep * car)
                1 -> { var acc = 0.0; val saw = 2 * x01 - 1; for (b in 0 until B) { val a = anal[b].run(mono); env[b] = max(abs(a), env[b] * 0.999); acc += syn[b].run(saw) * env[b] }; mono * (1 - dep) + acc * dep * 4 }
                else -> { val q = 16.0; val cr = floor(mono * q) / q; cr * (1 - dep + dep * car) } }
            y = tone.run(y) * g; if (v("tepeSini", i) >= 0.5) y = y.coerceIn(-1.0, 1.0)
            for (c in 0..1) buf[i * 2 + c] = (buf[i * 2 + c] * (1 - mix) + y * mix).toFloat() }
    }

    /** Spektral gürültü azaltma: 1024'lük kısa süreli Fourier, uyarlanır gürültü tabanı (en küçük istatistik), yumuşak kapı */
    private fun denoise(e: Effect, l: Layer, buf: FloatArray, rate: Int) {
        val n = buf.size / 2
        fun v(k: String) = e.value(k, l.start)
        val N = 1024; val H = N / 4; val win = DoubleArray(N) { 0.5 - 0.5 * cos(2 * PI * it / N) }
        val red = db(-v("azaltma")); val sens = 1.0 + v("hassasiy") / 25; val smooth = v("frekansYumu") / 100; val keepSpeech = v("konusmaKoru") / 100; val onlyNoise = v("yalnizGideSesi") >= 0.5
        val hum = v("sebekeUgulFilt") >= 0.5; val humF = if (v("ugultuFrek") >= 0.5) 60.0 else 50.0
        for (c in 0..1) { val out = DoubleArray(n + N); val floorEst = DoubleArray(N / 2 + 1) { 1e9 }; val re = DoubleArray(N); val im = DoubleArray(N); var frame = 0
            var p = 0; while (p < n) { for (k in 0 until N) { val idx = p + k - N / 2; re[k] = (if (idx in 0 until n) buf[idx * 2 + c].toDouble() else 0.0) * win[k]; im[k] = 0.0 }
                fft(re, im, false); val gains = DoubleArray(N / 2 + 1)
                for (k in 0..N / 2) { val mag = hypot(re[k], im[k]); floorEst[k] = if (frame < 8) min(floorEst[k], mag + 1e-9).let { if (frame == 0) mag + 1e-9 else it } else min(floorEst[k] * 1.002, max(mag, floorEst[k] * 0.98))
                    val snr = mag / (floorEst[k] * sens); var g = if (snr > 1) 1.0 else red + (1 - red) * snr * snr; val f = k.toDouble() * rate / N; if (f in 300.0..3400.0) g = g + (1 - g) * keepSpeech * 0.6
                    if (hum && (1..8).any { h -> abs(f - h * humF) < rate.toDouble() / N * 1.5 }) g = min(g, 0.05); gains[k] = g }
                for (k in 1 until N / 2) gains[k] = gains[k] * (1 - smooth) + (gains[k - 1] + gains[k + 1]) * 0.5 * smooth
                for (k in 0..N / 2) { val g = if (onlyNoise) 1 - gains[k] else gains[k]; re[k] *= g; im[k] *= g; if (k in 1 until N / 2) { re[N - k] = re[k]; im[N - k] = -im[k] } }
                fft(re, im, true); for (k in 0 until N) { val idx = p + k - N / 2; if (idx in 0 until n) out[idx] += re[k] * win[k] / 1.5 }
                p += H; frame++ }
            for (i in 0 until n) buf[i * 2 + c] = out[i].toFloat() }
    }

    fun fft(re: DoubleArray, im: DoubleArray, inv: Boolean) { val n = re.size; var j = 0
        for (i in 1 until n) { var bit = n shr 1; while (j and bit != 0) { j = j xor bit; bit = bit shr 1 }; j = j xor bit; if (i < j) { var t = re[i]; re[i] = re[j]; re[j] = t; t = im[i]; im[i] = im[j]; im[j] = t } }
        var len = 2; while (len <= n) { val ang = 2 * PI / len * (if (inv) 1 else -1); val wr = cos(ang); val wi = sin(ang); var i = 0
            while (i < n) { var cr = 1.0; var ci = 0.0; for (k in 0 until len / 2) { val ur = re[i + k]; val ui = im[i + k]; val vr = re[i + k + len / 2] * cr - im[i + k + len / 2] * ci; val vi = re[i + k + len / 2] * ci + im[i + k + len / 2] * cr
                    re[i + k] = ur + vr; im[i + k] = ui + vi; re[i + k + len / 2] = ur - vr; im[i + k + len / 2] = ui - vi; val nr = cr * wr - ci * wi; ci = cr * wi + ci * wr; cr = nr }; i += len }; len = len shl 1 }
        if (inv) for (i in 0 until n) { re[i] = re[i] / n; im[i] = im[i] / n } }
}
