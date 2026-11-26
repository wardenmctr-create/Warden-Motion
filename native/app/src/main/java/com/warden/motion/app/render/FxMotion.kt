package com.warden.motion.app.render

import com.warden.motion.app.model.Effect
import com.warden.motion.app.model.Layer
import com.warden.motion.app.model.value
import com.warden.motion.app.model.at
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
                // Hız eğrisi: hız keyframe'lenirse zaman, hızın integrali olarak birikir (sıçrama olmaz)
                val hk = e.v?.get("hiz")?.k
                if (e.value("dondur", t) >= .5) { val fz = e.value("dondurZaman", t); val fd = e.value("dondurSure", t); if (lt > fz) lt = if (lt < fz + fd) fz else lt - fd }
                lt = if (e.value("mod", t) >= 0.5) e.value("kaynakZama", t)
                    else if (hk.isNullOrEmpty()) lt * e.value("hiz", t) / 100
                    else { val n = min(3000, max(16, (lt * 60).toInt())); val dt = lt / n; var acc = 0.0; for (i in 0 until n) acc += e.value("hiz", l.start + (i + 0.5) * dt) / 100 * dt; acc }
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
            "sway" -> {
                val (px, py) = pivot(e, "donusMerk", l, t); val f = v("frekans")
                var tt = max(0.0, lt - v("gecikme")); val n = v("donguSayi")
                if (n >= 1 && f > 0 && tt * f > n) tt = n / f
                val w = wave(v("dalga").toInt(), tt * f * 2 * PI + v("faz") * PI / 180) * (if (on("tersYon")) -1 else 1) * exp(-v("sonumS") / 100 * tt * 2)
                var a = if (on("asimetrik")) v("minAci") + (v("maxAci") - v("minAci")) * (w * 0.5 + 0.5) else w * v("salinimAcis")
                a += v("merkezAci")
                if (on("aciSinir")) a = a.coerceIn(min(v("sinirAlt"), v("sinirUst")), max(v("sinirAlt"), v("sinirUst")))
                tr = rotAbout(tr, px, py, a)
            }
            "shake" -> {
                val st = v("stil").toInt(); val f = max(0.0, v("frekans")) * (if (st == 1) 0.6 else 1.0); val seed = v("tohum"); val sm = if (st == 2) 1.0 else v("yumusatm") / 100
                val x = lt * f; val q = if (sm < 0.05) floor(x) else x
                val r = v("rastgele") / 100
                fun n(s: Double) = (noise1(q, seed + s) * r + sin(x * 2 * PI + s) * (1 - r)) + (if (st == 1) noise1(x * 0.25, seed + s + 7) * 0.8 else 0.0)
                val p = if (dur > 0) (lt / dur).coerceIn(0.0, 1.0) else 0.0
                var env = (v("basGuc") + (v("bitGuc") - v("basGuc")) * p) / 100
                if (st == 3) env *= exp(-lt * 5)
                val sx = (if (on("xyAyri")) v("siddetX") else v("konumSidd")) * env; val sy = (if (on("xyAyri")) v("siddetY") else v("konumSidd")) * env
                var dx = if (on("xEkse")) n(1.0) * sx else 0.0; var dy = if (on("yEkse")) n(2.0) * sy else 0.0
                val lim = v("sinirS"); if (lim > 0) { dx = dx.coerceIn(-lim, lim); dy = dy.coerceIn(-lim, lim) }
                tr = move(tr, dx, dy)
                if (on("donus")) tr = tr.copy(rot = tr.rot + n(3.0) * v("donusSidd") * env)
                val ss = v("olcekSidd") / 100 * env; if (ss > 0) { val k = 1 + n(4.0) * ss; tr = sclAbout(tr, 0.0, 0.0, k, k) }
            }
            "spin" -> {
                val (px, py) = pivot(e, "merkez", l, t); val tt = if (v("zamanaGore") >= .5) t else lt
                tr = rotAbout(tr, px, py, (v("baslangiAcis") + tt * v("hiz")) * (if (on("saatYonu")) 1 else -1))
            }
            "pulse" -> {
                val fr = v("frekans"); var tt = lt; var active = true
                if (v("tetikP") >= 0.5) { tt = lt - v("tetikZamanP"); active = tt >= 0 && fr > 0 && tt * fr <= max(1.0, v("nabizSayi")) }
                if (active) {
                    val a = tt * fr * 2 * PI + v("faz") * PI / 180
                    var w = when (v("dalga").toInt()) { 1 -> tri(a); 2 -> spring(((tt * fr) % 1)) * 2 - 1; else -> sin(a) }
                    if (v("tetikP") >= 0.5) w = -cos(tt * fr * 2 * PI) // tek nabız en küçükten başlar ve en küçüğe döner
                    val s = (v("enDusuOlce") + (v("enYuksOlce") - v("enDusuOlce")) * (w * 0.5 + 0.5)) / 100
                    val (px, py) = pivot(e, "merkezP", l, t)
                    tr = sclAbout(tr, px, py, if (on("xEkse")) s else 1.0, if (on("yEkse")) s else 1.0)
                } else { val s = v("enDusuOlce") / 100; val (px, py) = pivot(e, "merkezP", l, t); tr = sclAbout(tr, px, py, if (on("xEkse")) s else 1.0, if (on("yEkse")) s else 1.0) }
            }
            "bounce" -> {
                val f = max(0.01, v("frekans")); var tt = lt
                if (v("tetikB") >= 0.5) tt = lt - v("tetikZamanB")
                val cnt = v("ziplamaSayi"); val done = tt < 0 || (cnt >= 1 && tt * f >= cnt)
                if (!done) {
                    val cyc = floor(tt * f); val ph = tt * f - cyc; val ground = v("yereBasmSure") / 100
                    var air = if (ph < 1 - ground) ph / (1 - ground) else -1.0
                    val damp = (1 - v("sonum") / 100).pow(tt * f)
                    var hgt = 0.0
                    if (air >= 0) { var c = abs(2 * air - 1); val hang = v("askida") / 100; c = max(0.0, (c - hang) / max(0.01, 1 - hang)); hgt = (1 - c.pow(2 * v("yercekimi") / 100)) * v("yuksekli") * damp }
                    if (v("tabanSabit") < 0.5) {
                        tr = move(tr, sin(v("yon") * PI / 180) * hgt, -cos(v("yon") * PI / 180) * hgt)
                        tr = move(tr, v("yatayB") * (cyc + if (air >= 0) air else 1.0), 0.0)
                    } else { val (px, py) = pivot(e, "yerNokt", l, t); val st = 1 + hgt / max(1.0, l.h); tr = sclAbout(tr, px, py, 1 / sqrt(st), st) }
                    if (air < 0) { val sq = v("ezilme") / 100 * sin((ph - (1 - ground)) / ground * PI); val (px, py) = pivot(e, "yerNokt", l, t); tr = sclAbout(tr, px, py, 1 + sq, 1 - sq) }
                } else if (v("yatayB") != 0.0 && tt >= 0) tr = move(tr, v("yatayB") * cnt, 0.0)
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
                val (px, py) = pivot(e, "sabitNokt", l, t); val mode = v("modSq").toInt()
                var amt: Double; var ax = v("eksen") % 180
                when (mode) {
                    1 -> { val dt = 1.0 / 30; val vx = (l.x.at(t) - l.x.at(t - dt)) / dt; val vy = (l.y.at(t) - l.y.at(t - dt)) / dt; val sp = sqrt(vx * vx + vy * vy)
                        amt = min(v("hizSinir") / 100, sp / 1000 * v("hizHass") / 100); if (on("yonTakip") && sp > 1) ax = Math.toDegrees(kotlin.math.atan2(vy, vx)) + 90 }
                    2 -> { val p = (lt - v("tetikZamanS")) / max(0.05, v("sureS")); amt = if (p in 0.0..1.0) { val w = sin(p * 2 * PI) * exp(-p * 2.5); if (w >= 0) w * v("esneme") / 100 else w * v("ezilme") / 100 } else 0.0 }
                    else -> { val w = sin(lt * v("frekans") * 2 * PI + v("faz") * PI / 180); amt = if (w >= 0) w * v("esneme") / 100 else w * v("ezilme") / 100 }
                }
                val a = 1 + amt; val b = if (on("hacmiKoru")) 1 / max(0.05, a) else 1.0
                if (mode == 1 && on("yonTakip")) ax -= tr.rot // katmanın kendi eksenine göre en yakın yönde esnetilir
                tr = if (abs(((ax % 180) + 180) % 180 - 90) < 45) sclAbout(tr, px, py, b, a) else sclAbout(tr, px, py, a, b)
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
                val base = if (v("zamanKayn") >= 0.5) t else lt; val tt = max(0.0, base - v("gecikmeO"))
                // birikimli faz: frekans zamanla değişse bile hareket sıçramaz
                val fk = e.v?.get("frekans")?.k
                val ph = if (fk.isNullOrEmpty()) tt * v("frekans") else { val n = min(2000, max(16, (tt * 60).toInt())); val dt = tt / n; var acc = 0.0
                    val t0 = t - tt; for (i in 0 until n) acc += e.value("frekans", t0 + (i + 0.5) * dt) * dt; acc }
                val k = v("dalga").toInt(); val a0 = ph * 2 * PI + v("faz") * PI / 180
                var d = wave(k, a0) + v("ekDalgaGuc") / 100 * wave(k, a0 * v("ekDalgaOran"))
                d *= v("genlik") * exp(-v("sonumO") / 100 * tt * 2)
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
            "cbhold" -> { // bekleme süresince odak noktasına hafif yakınlaşma (giriş/çıkış yumuşak)
                val tg = v("tetiklem"); val hold = max(1e-3, v("bekleme")); val x = lt - tg
                if (x in 0.0..hold) { val gi = max(1e-3, min(v("giris"), hold / 2)); val ci = max(1e-3, min(v("cikis"), hold / 2))
                    fun sm(q: Double) = q.coerceIn(0.0, 1.0).let { it * it * (3 - 2 * it) }
                    val k = min(sm(x / gi), sm((hold - x) / ci)); val f = 1 + (v("yakinlas") / 100 - 1) * k
                    val oy = (v("odak") / 100 - 0.5) * l.h * tr.scale * tr.sy
                    tr = tr.copy(scale = tr.scale * f, y = tr.y - oy * (f - 1)) }
            }
            "elastic" -> { // anahtar kareye varınca, varış hızıyla orantılı sönümlü yay salınımı
                val f = max(0.1, v("frekans")); val d = max(0.05, v("sure")); val damp = 1.0 + v("sonum") / 100 * 7; val amp = v("tasma") / 20
                fun el(a: com.warden.motion.app.model.Anim): Double {
                    val ks = a.k ?: return 0.0; if (ks.size < 2) return 0.0
                    val k = ks.drop(1).lastOrNull { it.t <= t } ?: return 0.0; val dt = t - k.t; if (dt < 0 || dt > d * 3) return 0.0
                    val h = 1.0 / 60; val vel = (a.at(k.t) - a.at(k.t - h)) / h
                    if (on("yalnizDuru") && kotlin.math.abs(a.at(k.t + h) - a.at(k.t)) / h > kotlin.math.abs(vel) * 0.2 + 1e-6) return 0.0
                    val w = 2 * PI * f; return vel * amp * sin(w * dt) / w * exp(-damp * dt / d) }
                if (on("konum")) tr = move(tr, el(l.x), el(l.y))
                if (on("olcek")) tr = tr.copy(scale = tr.scale + el(l.scale))
                if (on("donus")) tr = tr.copy(rot = tr.rot + el(l.rotation))
            }
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
