package com.warden.motion.app.render

import com.warden.motion.app.model.Effect
import com.warden.motion.app.model.Layer
import com.warden.motion.app.model.value
import kotlin.math.PI
import kotlin.math.abs
import kotlin.math.cos
import kotlin.math.exp
import kotlin.math.floor
import kotlin.math.max
import kotlin.math.min
import kotlin.math.pow
import kotlin.math.sin
import kotlin.math.sqrt

/**
 * Hareket (xform), opaklık ve zaman efektleri: katmanın dönüşümünü / opaklığını / zamanını değiştirir.
 * Shader gerekmez; katalogdaki ayar anahtarları (rehberdeki tablolar) kullanılır.
 */
private fun h1(n: Double): Double { val x = sin(n * 127.1 + 311.7) * 43758.5453; return x - floor(x) }
/** Yumuşak 1B gürültü (-1..1), tohumlu */
fun noise1(x: Double, seed: Double): Double {
    val i = floor(x); val f = x - i; val u = f * f * (3 - 2 * f)
    return (h1(i + seed * 17.13) * (1 - u) + h1(i + 1 + seed * 17.13) * u) * 2 - 1
}
private fun tri(x: Double) = 1 - 4 * abs(((x / (2 * PI)) % 1 + 1) % 1 - 0.5) // -1..1 üçgen, sin ile aynı faz
private fun wave(kind: Int, a: Double) = when (kind) { 1 -> tri(a); 2 -> if (sin(a) >= 0) 1.0 else -1.0; else -> sin(a) }
private fun easeOut(p: Double) = 1 - (1 - p).pow(3)
private fun easeIn(p: Double) = p.pow(3)
private fun easeInOut(p: Double) = if (p < .5) 4 * p * p * p else 1 - (-2 * p + 2).pow(3) / 2
/** Yay (aşan, sönen) 0→1 */
private fun spring(p: Double, over: Double = 0.15, damp: Double = 0.6): Double {
    if (p >= 1) return 1.0
    val w = 2 * PI * 1.6; val z = 2.5 + damp * 4
    return 1 - exp(-z * p) * cos(w * p) * (1 - over) - over * exp(-z * p * 2) * cos(w * p * 2)
}
private fun curve(kind: Int, p: Double, inMode: Boolean = false) = when (kind) {
    1 -> p; 2 -> spring(p); else -> if (inMode) easeIn(p) else easeOut(p)
}

/** box% pivotu → katman merkezine göre birim (katman yönünde) */
private fun pivot(e: Effect, k: String, l: Layer, t: Double) = Pair((e.value(k + "X", t) / 100 - 0.5) * l.w, (e.value(k + "Y", t) / 100 - 0.5) * l.h)

/** Dönüşüm üzerinde: yerel (px, py) pivotu etrafında da derece döndür */
private fun rotAbout(tr: TR, px: Double, py: Double, da: Double): TR {
    if (da == 0.0) return tr
    val a = tr.rot * PI / 180; val k = tr.scale
    // pivotun dünyadaki yeri sabit kalır
    val wx = (px * tr.sx * cos(a) - py * tr.sy * sin(a)) * k; val wy = (px * tr.sx * sin(a) + py * tr.sy * cos(a)) * k
    val b = (tr.rot + da) * PI / 180
    val nx = (px * tr.sx * cos(b) - py * tr.sy * sin(b)) * k; val ny = (px * tr.sx * sin(b) + py * tr.sy * cos(b)) * k
    return tr.copy(x = tr.x + wx - nx, y = tr.y + wy - ny, rot = tr.rot + da)
}
private fun sclAbout(tr: TR, px: Double, py: Double, fx: Double, fy: Double): TR {
    val a = tr.rot * PI / 180; val k = tr.scale
    val dx = px * tr.sx * (1 - fx); val dy = py * tr.sy * (1 - fy)
    return tr.copy(x = tr.x + (dx * cos(a) - dy * sin(a)) * k, y = tr.y + (dx * sin(a) + dy * cos(a)) * k, sx = tr.sx * fx, sy = tr.sy * fy)
}
private fun move(tr: TR, dx: Double, dy: Double) = tr.copy(x = tr.x + dx, y = tr.y + dy)

/** Katman zamanı efektleri (Kare Atla, Hız Değiştir, Komedi Beklemesi): katmanın içinde kullanılan yerel süre */
fun fxLocalTime(l: Layer, t: Double): Double {
    var lt = t - l.start
    for (e in l.effects) {
        if (e.on == false) continue
        when (e.type) {
            "speed" -> {
                val sp = e.value("hiz", t) / 100
                lt = if (e.value("mod", t) >= 0.5) e.value("kaynakZama", t) else lt * sp
                if (e.value("dongu", t) >= .5 && l.srcDur != null && l.srcDur > 0) lt = ((lt % l.srcDur) + l.srcDur) % l.srcDur
                if (lt < 0) lt = max(0.0, (l.srcDur ?: (l.end - l.start)) + lt)
            }
            "posterizetime" -> { val f = max(0.1, e.value("kareHizi", t)); val sh = e.value("zamanKaym", t); lt = floor((lt + sh) * f + if (e.value("orneklem", t) >= .5) 0.5 else 0.0) / f }
            "cbhold" -> {
                val tg = e.value("tetiklem", t); val hold = e.value("bekleme", t)
                if (e.value("kareyiDond", t) >= .5) { if (lt > tg) lt = if (lt < tg + hold) tg else lt - hold }
            }
        }
    }
    return lt
}

/** Hareket + opaklık efektleri */
fun applyMotionFx(l: Layer, t: Double, tr0: TR): TR {
    var tr = tr0
    val lt = t - l.start; val dur = l.end - l.start
    for (e in l.effects) {
        if (e.on == false) continue
        fun v(k: String) = e.value(k, t)
        fun on(k: String) = e.value(k, t) >= 0.5
        when (e.type) {
            "sway" -> { val (px, py) = pivot(e, "donusMerk", l, t); val a = wave(v("dalga").toInt(), lt * v("frekans") * 2 * PI + v("faz") * PI / 180) * v("salinimAcis") * (if (on("tersYon")) -1 else 1); tr = rotAbout(tr, px, py, a) }
            "shake" -> {
                val f = max(0.0, v("frekans")); val seed = v("tohum"); val sm = v("yumusatm") / 100
                val x = lt * f; val q = if (sm < 0.05) floor(x) else x
                val r = v("rastgele") / 100
                fun n(s: Double) = noise1(q, seed + s) * r + sin(x * 2 * PI + s) * (1 - r)
                if (on("xEkse")) tr = move(tr, n(1.0) * v("konumSidd"), 0.0)
                if (on("yEkse")) tr = move(tr, 0.0, n(2.0) * v("konumSidd"))
                if (on("donus")) tr = tr.copy(rot = tr.rot + n(3.0) * v("donusSidd"))
            }
            "spin" -> {
                val (px, py) = pivot(e, "merkez", l, t); val tt = if (v("zamanaGore") >= .5) t else lt
                tr = rotAbout(tr, px, py, (v("baslangiAcis") + tt * v("hiz")) * (if (on("saatYonu")) 1 else -1))
            }
            "pulse" -> {
                val a = lt * v("frekans") * 2 * PI + v("faz") * PI / 180
                val w = when (v("dalga").toInt()) { 1 -> tri(a); 2 -> spring(((lt * v("frekans")) % 1)) * 2 - 1; else -> sin(a) }
                val s = (v("enDusuOlce") + (v("enYuksOlce") - v("enDusuOlce")) * (w * 0.5 + 0.5)) / 100
                tr = sclAbout(tr, 0.0, 0.0, if (on("xEkse")) s else 1.0, if (on("yEkse")) s else 1.0)
            }
            "bounce" -> {
                val f = max(0.01, v("frekans")); val ph = (lt * f) % 1; val ground = v("yereBasmSure") / 100
                val air = if (ph < 1 - ground) ph / (1 - ground) else -1.0
                val damp = (1 - v("sonum") / 100).pow(lt * f)
                val hgt = if (air >= 0) 4 * air * (1 - air) * v("yuksekli") * damp else 0.0
                val ang = (v("yon") - 90) * PI / 180
                tr = move(tr, cos(ang) * hgt * 0 + sin(-ang) * 0, 0.0)
                tr = move(tr, sin(v("yon") * PI / 180) * hgt, -cos(v("yon") * PI / 180) * hgt)
                if (air < 0) { val sq = v("ezilme") / 100 * sin((ph - (1 - ground)) / ground * PI); val (px, py) = pivot(e, "yerNokt", l, t); tr = sclAbout(tr, px, py, 1 + sq, 1 - sq) }
            }
            "wiggle" -> {
                val x = lt * v("frekans"); val seed = v("tohum"); val sm = v("yumusatm") / 100
                fun n(s: Double) = noise1(x, seed + s) * sm + noise1(floor(x * 2) / 2, seed + s) * (1 - sm)
                tr = move(tr, if (on("xEkse")) n(1.0) * v("konumGenl") else 0.0, if (on("yEkse")) n(2.0) * v("konumGenl") else 0.0)
                tr = tr.copy(rot = tr.rot + n(3.0) * v("aciGenl"))
            }
            "orbit" -> {
                val a = (lt * v("hiz") * 360 + v("faz")) * PI / 180 * (if (on("tersYon")) -1 else 1)
                val oa = v("yorungeAcis") * PI / 180
                val ox = cos(a) * v("yaricapX"); val oy = sin(a) * v("yaricapY")
                tr = move(tr, ox * cos(oa) - oy * sin(oa), ox * sin(oa) + oy * cos(oa))
                if (on("yolaDogrDon")) tr = tr.copy(rot = tr.rot + a * 180 / PI + 90)
            }
            "float" -> {
                val a = lt * v("frekans") * 2 * PI + v("faz") * PI / 180
                tr = move(tr, sin(a * 0.5) * v("yataySuru"), sin(a) * v("yuksekli")); tr = tr.copy(rot = tr.rot + sin(a * 0.7) * v("donus"))
            }
            "pendulum" -> {
                val tt = max(0.0, lt - v("baslangiGeci")); val (px, py) = pivot(e, "askiNokt", l, t)
                val a = sin(tt * v("frekans") * 2 * PI + v("faz") * PI / 180) * v("aci") * exp(-v("sonum") / 100 * tt * 2)
                tr = rotAbout(tr, px, py, a)
            }
            "heartbeat" -> {
                val per = 60 / max(1.0, v("vurusSayi")); val ph = ((lt + v("faz") / 360 * per) % per) / per
                val d = max(0.01, v("vurusSure") / 100); val gap = v("vurusAral") / 100
                fun beat(c: Double, s: Double) = if (ph in c..(c + d)) sin((ph - c) / d * PI) * (s / 100 - 1) else 0.0
                val s = 1 + beat(0.0, v("ilkVuruOlce")) + beat(gap, v("ikinciVuruOlce"))
                tr = sclAbout(tr, 0.0, 0.0, s, s)
            }
            "squash" -> {
                val w = sin(lt * v("frekans") * 2 * PI + v("faz") * PI / 180)
                val amt = if (w >= 0) w * v("esneme") / 100 else w * v("ezilme") / 100
                val a = 1 + amt; val b = if (on("hacmiKoru")) 1 / max(0.05, a) else 1.0
                val (px, py) = pivot(e, "sabitNokt", l, t)
                val ax = v("eksen") % 180
                tr = if (abs(ax - 90) < 45) sclAbout(tr, px, py, b, a) else sclAbout(tr, px, py, a, b)
            }
            "coinflip" -> {
                var p = lt * v("hiz") + v("faz") / 360
                if (on("yavaslayDur") && dur > 0) { val k = min(1.0, lt / dur); p = v("hiz") * dur * (1 - (1 - k) * (1 - k)) / 2 + v("faz") / 360 }
                val c = cos(p * 2 * PI); val ax = v("donmeEkse") % 180
                tr = if (abs(ax - 90) < 45) sclAbout(tr, 0.0, 0.0, max(0.02, abs(c)) * (if (c < 0) -1 else 1), 1.0) else sclAbout(tr, 0.0, 0.0, 1.0, max(0.02, abs(c)) * (if (c < 0) -1 else 1))
            }
            "jump" -> {
                val f = max(0.01, v("frekans")); val x = lt * f; val i = floor(x); val seed = v("tohum")
                fun at(k: Double, s: Double) = h1(k * 1.37 + seed * 9.1 + s) * 2 - 1
                val p = if (v("gecis") >= .5) easeInOut(min(1.0, (x - i) * 4)) else 1.0
                val dx = at(i - 1, 1.0) + (at(i, 1.0) - at(i - 1, 1.0)) * p; val dy = at(i - 1, 2.0) + (at(i, 2.0) - at(i - 1, 2.0)) * p
                tr = move(tr, dx * v("maksimumKaymX"), dy * v("maksimumKaymY")); tr = tr.copy(rot = tr.rot + (at(i, 3.0)) * v("donusGenl"))
            }
            "slidein", "slideout" -> {
                val inn = e.type == "slidein"; val d = max(0.001, v("sure"))
                val p = if (inn) ((lt - v("gecikme")) / d).coerceIn(0.0, 1.0) else 1 - ((dur - v("bitisPayi") - lt) / d).coerceIn(0.0, 1.0)
                val k = if (inn) 1 - curve(v("egri").toInt(), p) else curve(v("egri").toInt(), p, inMode = true)
                val a = v("yon") * PI / 180
                tr = move(tr, cos(a) * v("mesafe") * k, sin(a) * v("mesafe") * k)
                if (on("opaklikGeci")) tr = tr.copy(opacity = tr.opacity * (1 - k))
            }
            "popin" -> {
                val p = ((lt - v("gecikme")) / max(0.001, v("sure"))).coerceIn(0.0, 1.0)
                val s0 = v("baslangiOlce") / 100; val s = s0 + (1 - s0) * spring(p, v("tasma") / 100, v("sonum") / 100)
                val (px, py) = pivot(e, "merkez", l, t); tr = sclAbout(tr, px, py, s, s)
                if (on("opaklikGeci")) tr = tr.copy(opacity = tr.opacity * min(1.0, p * 3))
            }
            "popout" -> {
                val p = 1 - ((dur - v("bitisPayi") - lt) / max(0.001, v("sure"))).coerceIn(0.0, 1.0)
                val pre = v("onBuyu") / 100; val s1 = v("bitisOlce") / 100
                val s = if (p < 0.3) 1 + pre * sin(p / 0.3 * PI / 2) else (1 + pre) + (s1 - 1 - pre) * easeIn((p - 0.3) / 0.7)
                val (px, py) = pivot(e, "merkez", l, t); tr = sclAbout(tr, px, py, max(0.0, s), max(0.0, s))
                if (on("opaklikGeci")) tr = tr.copy(opacity = tr.opacity * (1 - max(0.0, (p - 0.5) * 2)))
            }
            "transformfx" -> {
                val (px, py) = pivot(e, "merkez", l, t)
                val sx = v("olcekX") / 100; val sy = if (on("oranlariBagl")) sx else v("olcekY") / 100
                tr = sclAbout(tr, px, py, sx, sy); tr = rotAbout(tr, px, py, v("donus"))
                tr = move(tr, v("konumX"), v("konumY")).copy(opacity = tr.opacity * v("opaklik") / 100, skew = tr.skew + v("egmeX"))
            }
            "drift" -> {
                val tt = max(0.0, lt - v("baslangiGeci"))
                tr = move(tr, v("hizX") * tt, v("hizY") * tt); tr = tr.copy(rot = tr.rot + v("donmeHizi") * tt)
            }
            "spiralpath" -> {
                val p = if (on("otomatik")) (if (dur > 0) lt / dur else 0.0) else v("ilerleme") / 100
                val r = v("baslangiYari") + (v("bitisYari") - v("baslangiYari")) * p; val a = p * v("turSayi") * 2 * PI
                tr = move(tr, cos(a) * r, sin(a) * r); if (on("yolaDogrDon")) tr = tr.copy(rot = tr.rot + a * 180 / PI + 90)
            }
            "movepath" -> {
                var p = if (on("otomatik")) lt * v("hiz") + v("ilerleme") / 100 else v("ilerleme") / 100
                p = if (on("dongu")) p % 1 else min(1.0, p)
                val a = p * 2 * PI; val W = v("boyutX") / 2; val H = v("boyutY") / 2
                val (x, y) = when (v("yol").toInt()) {
                    1 -> Pair(sin(a) * W, sin(2 * a) * H)
                    2 -> Pair((p * 2 - 1) * W, sin(a * 2) * H)
                    3 -> Pair(16 * sin(a).pow(3) / 16 * W, -(13 * cos(a) - 5 * cos(2 * a) - 2 * cos(3 * a) - cos(4 * a)) / 16 * H)
                    else -> Pair(cos(a) * W, sin(a) * H)
                }
                tr = move(tr, x, y)
                if (on("yolaDogrDon")) { val (x2, y2) = Pair(x, y); val d = 0.001; val a2 = a + d * 2 * PI
                    val nx = when (v("yol").toInt()) { 1 -> sin(a2) * W; 2 -> ((p + d) * 2 - 1) * W; 3 -> 16 * sin(a2).pow(3) / 16 * W; else -> cos(a2) * W }
                    val ny = when (v("yol").toInt()) { 1 -> sin(2 * a2) * H; 2 -> sin(a2 * 2) * H; 3 -> -(13 * cos(a2) - 5 * cos(2 * a2) - 2 * cos(3 * a2) - cos(4 * a2)) / 16 * H; else -> sin(a2) * H }
                    tr = tr.copy(rot = tr.rot + Math.toDegrees(kotlin.math.atan2(ny - y2, nx - x2))) }
            }
            "oscillate" -> {
                val d = wave(v("dalga").toInt(), lt * v("frekans") * 2 * PI + v("faz") * PI / 180) * v("genlik")
                val a = (v("aci") + if (on("goreliAci")) tr.rot else 0.0) * PI / 180
                tr = move(tr, cos(a) * d, sin(a) * d)
            }
            "scaleassist" -> { val (px, py) = pivot(e, "merkez", l, t); val sx = v("olcekX") / 100; tr = sclAbout(tr, px, py, sx, if (on("bagla")) sx else v("olcekY") / 100) }
            "stretchaxis" -> {
                val s = v("olcek") / 100; val comp = if (on("dikEkseTela")) 1 / sqrt(max(0.01, s)) else 1.0
                val (px, py) = pivot(e, "sabitNokt", l, t); val ax = ((v("eksen") % 180) + 180) % 180
                tr = if (ax in 45.0..135.0) sclAbout(tr, px, py, comp, s) else sclAbout(tr, px, py, s, comp)
            }
            "cbhop" -> {
                val tg = if (on("otomatik")) 0.0 else v("tetiklemZama"); val d = max(0.05, v("sure")); val p = (lt - tg) / d
                val (px, py) = pivot(e, "sabitTaba", l, t)
                if (p in 0.0..1.0) {
                    val pre = 0.15; val land = 0.85
                    when {
                        p < pre -> { val k = sin(p / pre * PI) * v("onEzil") / 100; tr = sclAbout(tr, px, py, 1 + k, 1 - k) }
                        p < land -> { val a = (p - pre) / (land - pre); val hh = 4 * a * (1 - a) * v("yuksekli"); val dir = v("yon") * PI / 180
                            tr = move(tr, cos(dir) * hh * 0, -sin(dir) * hh); val st = 0.08 * (1 - abs(a - 0.5) * 2); tr = sclAbout(tr, px, py, 1 - st, 1 + st) }
                        else -> { val k = sin((p - land) / (1 - land) * PI) * v("inisEzil") / 100; tr = sclAbout(tr, px, py, 1 + k, 1 - k) }
                    }
                }
            }
            // ---- Opaklık ----
            "flicker" -> { val x = lt * v("frekans") * 10; val sm = v("yumusatm") / 100; val n = (noise1(if (sm < .1) floor(x) else x, v("tohum")) * 0.5 + 0.5); tr = tr.copy(opacity = tr.opacity * (v("enDusuOpak") + (v("enYuksOpak") - v("enDusuOpak")) * n) / 100) }
            "blink" -> {
                val ph = ((lt * v("frekans") + v("faz") / 360) % 1 + 1) % 1; val duty = v("acikKalmOran") / 100
                var k = if (ph < duty) 1.0 else 0.0
                if (on("yumusakGeci")) { val e2 = 0.06; k = if (ph < e2) ph / e2 else if (ph < duty) 1.0 else if (ph < duty + e2) 1 - (ph - duty) / e2 else 0.0 }
                tr = tr.copy(opacity = tr.opacity * (v("kapaliOpak") + (v("acikOpak") - v("kapaliOpak")) * k) / 100)
            }
            "fadein", "fadeout" -> {
                val inn = e.type == "fadein"; val d = max(0.001, v("sure"))
                val p = if (inn) ((lt - v("gecikme")) / d).coerceIn(0.0, 1.0) else 1 - ((dur - v("bitisPayi") - lt) / d).coerceIn(0.0, 1.0)
                val c = when (v("egri").toInt()) { 1 -> easeIn(p); 2 -> easeOut(p); 3 -> easeInOut(p); else -> p }
                tr = tr.copy(opacity = tr.opacity * (v("baslangiOpak") + (v("bitisOpak") - v("baslangiOpak")) * c) / 100)
            }
            "randop" -> { val x = lt * v("frekans"); val sm = v("yumusatm") / 100; val n = noise1(if (sm < .1) floor(x) else x, v("tohum")) * 0.5 + 0.5; tr = tr.copy(opacity = tr.opacity * (v("minimum") + (v("maksimum") - v("minimum")) * n) / 100) }
            "breathe" -> { val w = wave(v("dalga").toInt(), lt * v("frekans") * 2 * PI + v("faz") * PI / 180) * 0.5 + 0.5; tr = tr.copy(opacity = tr.opacity * (v("minimum") + (v("maksimum") - v("minimum")) * w) / 100) }
        }
    }
    return tr
}
