package com.warden.motion.app.render

import com.warden.motion.app.model.Effect
import com.warden.motion.app.model.Layer
import com.warden.motion.app.model.Project
import com.warden.motion.app.model.value
import kotlin.math.PI
import kotlin.math.abs
import kotlin.math.cos
import kotlin.math.floor
import kotlin.math.hypot
import kotlin.math.max
import kotlin.math.min
import kotlin.math.sin

/** Ses katmanlarının seviye verisi (saniyede 100 tepe); Renderer bağlar */
object AudioLevels {
    @Volatile var resolver: ((Layer) -> FloatArray?)? = null
    fun level(l: Layer, t: Double): Double {
        val pk = resolver?.invoke(l) ?: return 0.0
        val i = ((t - l.start + (l.srcIn ?: 0.0)) * 100).toInt()
        if (i < 0 || i >= pk.size) return 0.0
        var m = 0f; for (j in max(0, i - 2)..min(pk.size - 1, i + 2)) m = max(m, pk[j]); return m.toDouble()
    }
}

/**
 * Countryball rig efektleri (403 Göz Takibi, 404 Göz Kırpma, 405 Kaş, 406 Konuşma, 426 İfade, 427 Parçalı Rig, 429 Harita Sabitleme).
 * Efekt bir "ana" katmanda durur ve seçilen diğer katmanların yerel dönüşümünü değiştirir.
 */
private val RIG = setOf("cbeyes", "cbblink", "cbbrow", "cbexpr", "cbrig", "cbmaplock", "lipsync")
private var rigDepth = 0

private fun ids(e: Effect, k: String) = e.c?.get(k)?.split(',')?.filter { it.isNotBlank() } ?: emptyList()
private fun h1(n: Double): Double { val x = sin(n * 127.1 + 311.7) * 43758.5453; return x - floor(x) }

/** Seçim (adımlı) ayarının yumuşak geçişi: [t-g, t] aralığında hangi değerin ne kadar sürdüğüne göre ağırlık */
private fun choiceWeights(e: Effect, k: String, t: Double, g: Double, n: Int): DoubleArray {
    val w = DoubleArray(n)
    if (g <= 0.001) { w[e.value(k, t).toInt().coerceIn(0, n - 1)] = 1.0; return w }
    val S = 12; for (i in 0 until S) { val v = e.value(k, t - g * (i + 0.5) / S).toInt().coerceIn(0, n - 1); w[v] += 1.0 / S }
    return w
}

fun rigLocal(p: Project, l: Layer, t: Double, loc0: TR, parent: TR?): TR {
    if (rigDepth > 2) return loc0
    var loc = loc0
    val hosts = p.layers.filter { h -> h.effects.any { it.type in RIG && it.on != false } }
    if (hosts.isEmpty()) return loc
    rigDepth++
    try {
        fun worldOffset(dx: Double, dy: Double): Pair<Double, Double> {
            if (parent == null) return dx to dy
            val a = -parent.rot * PI / 180; val s = if (abs(parent.scale) < 1e-6) 1.0 else parent.scale
            return (dx * cos(a) - dy * sin(a)) / s to (dx * sin(a) + dy * cos(a)) / s
        }
        for (h in hosts) for (e in h.effects) {
            if (e.on == false || e.type !in RIG || h.id == l.id && e.type != "cbmaplock") continue
            fun v(k: String) = e.value(k, t)
            when (e.type) {
                "cbeyes" -> {
                    val eyes = ids(e, "solGozKatm") + ids(e, "sagGozKatm"); if (l.id !in eyes) continue
                    val hw = worldTransform(p, h, t)
                    fun target(tt: Double): Pair<Double, Double> {
                        val tg = if (v("hedefTuru") >= 0.5) e.c?.get("hedefKatm")?.let { id -> p.layers.find { it.id == id } } else null
                        if (tg != null) { val w = worldTransform(p, tg, tt); return w.x to w.y }
                        val a = hw.rot * PI / 180; val ox = (e.value("hedefNoktX", tt) / 100 - 0.5) * h.w * hw.scale; val oy = (e.value("hedefNoktY", tt) / 100 - 0.5) * h.h * hw.scale
                        return hw.x + ox * cos(a) - oy * sin(a) to hw.y + ox * sin(a) + oy * cos(a)
                    }
                    // Tepki süresi: hedef son anların ortalamasıyla izlenir (gecikmeli, yumuşak)
                    val lag = max(0.0, v("tepkiSure")); var tx = 0.0; var ty = 0.0; val S = if (lag > 0.01) 6 else 1
                    for (i in 0 until S) { val (a, b) = target(t - lag * i / max(1, S - 1).toDouble()); tx += a / S; ty += b / S }
                    val ew = if (v("gozleriBagl") >= 0.5) hw.x to hw.y else { val pw = parent ?: TR(0.0, 0.0, 0.0, 1.0, 1.0); val a = pw.rot * PI / 180
                        pw.x + (loc.x * cos(a) - loc.y * sin(a)) * pw.scale to pw.y + (loc.x * sin(a) + loc.y * cos(a)) * pw.scale }
                    var dx = tx - ew.first; var dy = ty - ew.second; val d = hypot(dx, dy); val mx = v("maksimumKaym")
                    if (d > 1e-6) { val k = if (v("siniriKoru") >= 0.5) min(mx, d) / d else mx / d * min(1.0, d / max(1.0, mx * 4)); dx *= k; dy *= k } else { dx = 0.0; dy = 0.0 }
                    val (lx, ly) = worldOffset(dx, dy); loc = loc.copy(x = loc.x + lx, y = loc.y + ly)
                }
                "cbblink" -> {
                    val eyes = ids(e, "gozKatm"); val idx = eyes.indexOf(l.id); if (idx < 0) continue
                    val gap = max(0.3, v("aralik")); val rnd = v("rastgele") / 100; val seed = v("tohum") + if (v("gozleriBagl") >= 0.5) 0.0 else idx * 0.37
                    val close = max(0.01, v("kapanmaSure")); val open = max(0.01, v("acilmaSure")); val lt = t - h.start
                    // Her döngünün kırpma anı tohuma bağlı sabit rastgelelikle kayar (zaman taramasından bağımsız)
                    var sy = 1.0; val c0 = floor(lt / gap)
                    for (c in (c0 - 1).toInt()..(c0 + 1).toInt()) {
                        val at = c * gap + gap * 0.5 + (h1(c + seed * 13.1) - 0.5) * gap * rnd
                        fun lid(s: Double): Double { val u = lt - s; return when { u < 0 -> 1.0; u < close -> 1 - u / close; u < close + open -> (u - close) / open; else -> 1.0 } }
                        var k = lid(at); if (v("ciftKirp") >= 0.5) k = min(k, lid(at + close + open + 0.08))
                        sy = min(sy, k)
                    }
                    val mn = v("kapaliYuks") / 100; loc = loc.copy(sy = loc.sy * (mn + (1 - mn) * sy))
                }
                "cbbrow" -> {
                    val L = e.c?.get("solKas"); val R = e.c?.get("sagKas"); if (l.id != L && l.id != R) continue
                    val wv = choiceWeights(e, "duygu", t, v("gecisSure"), 5); val g = v("guc") / 100; val left = l.id == L
                    // Normal, Şaşkın, Kızgın, Şüpheli, Üzgün: (açı, yükselme px)
                    val ang = doubleArrayOf(0.0, if (left) -6.0 else 6.0, if (left) 18.0 else -18.0, if (left) -12.0 else 4.0, if (left) -16.0 else 16.0)
                    val up = doubleArrayOf(0.0, -10.0, 4.0, if (left) -8.0 else 2.0, -2.0)
                    var a = 0.0; var u = 0.0; for (i in 0 until 5) { a += ang[i] * wv[i]; u += up[i] * wv[i] }
                    if (v("simetri") < 0.5 && !left) a = -a
                    a = a * g + if (left) v("solAciDuze") else v("sagAciDuze")
                    val (lx, ly) = worldOffset(0.0, u * g * h.h / 100); loc = loc.copy(x = loc.x + lx, y = loc.y + ly, rot = loc.rot + a)
                }
                "cbexpr" -> {
                    val faces = listOf("normalYuz", "saskinYuz", "kizginYuz", "uzgunYuz", "ozelYuz").map { e.c?.get(it) }
                    val fi = faces.indexOf(l.id); if (fi < 0) continue
                    val wv = if (v("gecisTuru") >= 0.5) choiceWeights(e, "ifade", t, v("gecisSure"), 5) else choiceWeights(e, "ifade", t, 0.0, 5)
                    loc = loc.copy(opacity = loc.opacity * wv[fi])
                }
                "lipsync" -> {
                    val mouths = listOf("kapaliAgiz", "yariAcikAgiz", "acikAgiz").map { e.c?.get(it) }; val mi = mouths.indexOf(l.id); if (mi < 0) continue
                    val src = e.c?.get("sesKatm")?.let { id -> p.layers.find { it.id == id } }
                    // Enerji: tepki süresi boyunca en yüksek seviye; kapanma süresi kadar açık tutar
                    var lvl = 0.0; if (src != null) { val sh = v("zamanFark") / 1000; val win = max(0.01, v("tepki") / 1000); val hold = v("kapanma") / 1000
                        for (i in 0..8) { val tt = t - sh - (win + hold) * i / 8.0; lvl = max(lvl, AudioLevels.level(src, tt) * (if (i * (win + hold) / 8.0 > win) 0.8 else 1.0)) } }
                    val dbv = 20 * kotlin.math.log10(max(lvl, 1e-6)); val th = v("sesEsig"); val state = if (dbv < th) 0 else if (dbv < th + 12) 1 else 2
                    val show = if (mouths[state] != null) state else if (state == 2 && mouths[1] != null) 1 else if (state == 1 && mouths[2] != null) 2 else 0
                    loc = loc.copy(opacity = if (mi == show) loc.opacity else 0.0)
                }
                "cbrig" -> {
                    val body = e.c?.get("govde")?.let { id -> p.layers.find { it.id == id } } ?: continue
                    val eyes = ids(e, "gozGrub"); val acc = ids(e, "aksesuarGrub")
                    if (l.id != body.id && (l.id in eyes || l.id in acc)) {
                        // Döngüsel takibi engelle: gövde, takipçi katmanların arasındaysa uygulanmaz
                        if (body.id in eyes || body.id in acc || body.parent == l.id) continue
                        if (v("govdeyiTakiEt") >= 0.5) {
                            val b0 = worldTransform(p, body, body.start); val b1 = worldTransform(p, body, t)
                            val ra = (if (v("donusuTakiEt") >= 0.5) b1.rot - b0.rot else 0.0) * PI / 180; val sc = if (v("olcegiTakiEt") >= 0.5 && abs(b0.scale) > 1e-6) b1.scale / b0.scale else 1.0
                            val rx = loc.x - b0.x; val ry = loc.y - b0.y
                            val nx = b1.x + (rx * cos(ra) - ry * sin(ra)) * sc; val ny = b1.y + (rx * sin(ra) + ry * cos(ra)) * sc
                            loc = loc.copy(x = nx, y = ny, rot = loc.rot + ra * 180 / PI, scale = loc.scale * sc)
                        }
                        if (l.id in eyes) { val (lx, ly) = worldOffset(v("gozKaym"), 0.0); loc = loc.copy(x = loc.x + lx, y = loc.y + ly) }
                        else { val (lx, ly) = worldOffset(0.0, v("aksesuarKaym")); loc = loc.copy(x = loc.x + lx, y = loc.y + ly, rot = loc.rot + v("aksesuarAcis")) }
                    }
                }
                "cbmaplock" -> {
                    val map = e.c?.get("haritaKatm")?.let { id -> p.layers.find { it.id == id } } ?: continue
                    val labels = ids(e, "etiketKatm"); if (l.id !in labels || l.id == map.id) continue
                    val mw = worldTransform(p, map, t); val inherits = l.parent == map.id
                    val ref = max(0.01, v("referansOlce") / 100); val fix = v("sabitEkraOlce") / 100
                    if (inherits) {
                        loc = loc.copy(scale = loc.scale * fix * ref / max(0.01, abs(mw.scale)))
                        if (v("donusuTelaEt") >= 0.5) loc = loc.copy(rot = loc.rot - mw.rot)
                    } else if (v("konumuTakiEt") >= 0.5) {
                        val m0 = worldTransform(p, map, map.start); val k = mw.scale / (if (abs(m0.scale) > 1e-6) m0.scale else 1.0); val ra = (mw.rot - m0.rot) * PI / 180
                        val rx = loc.x - m0.x; val ry = loc.y - m0.y
                        loc = loc.copy(x = mw.x + (rx * cos(ra) - ry * sin(ra)) * k, y = mw.y + (rx * sin(ra) + ry * cos(ra)) * k, scale = loc.scale * fix,
                            rot = if (v("donusuTelaEt") >= 0.5) loc.rot else loc.rot + ra * 180 / PI)
                    }
                    if (v("sinirdaGizl") >= 0.5) { val w = if (parent != null) parent.x + loc.x else loc.x; val hh = if (parent != null) parent.y + loc.y else loc.y
                        if (w < 0 || hh < 0 || w > p.width || hh > p.height) loc = loc.copy(opacity = 0.0) }
                }
            }
        }
    } finally { rigDepth-- }
    return loc
}

/** 406 CB Konuşma Hareketi: ana katman sesle (veya elle) zıplar ve ezilir */
fun talkFx(p: Project, l: Layer, e: Effect, t: Double, tr: TR): TR {
    fun v(k: String) = e.value(k, t)
    var lvl = if (v("mod") >= 0.5) v("elleGuc") / 100 else {
        val src = e.c?.get("sesKayn")?.let { id -> p.layers.find { it.id == id } }
        if (src == null) 0.0 else {
            // tepki/geri dönüş: kısa geçmişte en yüksek seviye, geri dönüş süresince sönerek
            val rel = max(0.01, v("geriDonu")); var m = 0.0; val S = 6
            for (i in 0 until S) { val dt = rel * i / (S - 1); m = max(m, AudioLevels.level(src, t - v("tepki") * 0.5 - dt) * (1 - dt / rel * 0.8)) }
            val th = v("esik") / 100; ((m - th) / max(0.01, 1 - th)).coerceIn(0.0, 1.0) * (0.4 + v("hassasiy") / 100 * 1.2)
        }
    }
    lvl = lvl.coerceIn(0.0, 1.5)
    val up = v("yuksekli") * lvl; val sq = v("ezilme") / 100 * lvl
    var r = tr.copy(sx = tr.sx * (1 + sq * 0.5), sy = tr.sy * (1 - sq))
    if (v("sabitTaba") >= 0.5) { r = r.copy(y = r.y + l.h * tr.scale * sq * 0.5) }
    return r.copy(y = r.y - up)
}
