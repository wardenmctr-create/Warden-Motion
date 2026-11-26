package com.warden.motion.app.render

import com.warden.motion.app.model.Effect
import com.warden.motion.app.model.Layer
import com.warden.motion.app.model.Project
import com.warden.motion.app.model.at
import com.warden.motion.app.model.value
import kotlin.math.*

/** 800 rehberi bölüm 6: hedefe/hıza/sınıra bağlı hareket, sönüm, basamak, döngü, yüzeyde kayma, yapışma, eklem, eğriye yapışma */
object Motion2 {
    private fun tgt(p: Project, e: Effect, k: String) = e.c?.get(k)?.let { id -> p.layers.find { it.id == id } }
    private fun pos(l: Layer, t: Double) = doubleArrayOf(l.x.at(t), l.y.at(t))
    private fun angDiff(a: Double, b: Double): Double { var d = (a - b) % 360; if (d > 180) d -= 360; if (d < -180) d += 360; return d }

    /** 497 Ters Kinematik: iki kemikli zincir; [üst kemik açısı, alt kemik açısı (dünya), dirsek x, dirsek y] */
    fun ik(p: Project, l: Layer, e: Effect, t: Double, base: TR): DoubleArray? {
        val L1 = max(1.0, e.value("kemikUzun", t)); val L2 = L1; val g = tgt(p, e, "hedefKatm")
        val (tx, ty) = if (g != null) worldTransform(p, g, t).let { it.x to it.y } else (base.x + (e.value("ucHedeX", t) / 100 - 0.5) * l.w * base.scale) to (base.y + (e.value("ucHedeY", t) / 100 - 0.5) * l.h * base.scale)
        var dx = tx - base.x; var dy = ty - base.y; var d = hypot(dx, dy); if (d < 1e-6) return null
        if (e.value("uzunlukKoru", t) >= 0.5 && d > L1 + L2) { dx *= (L1 + L2) / d * 0.9999; dy *= (L1 + L2) / d * 0.9999; d = L1 + L2 - 1e-3 }
        val c2 = ((d * d - L1 * L1 - L2 * L2) / (2 * L1 * L2)).coerceIn(-1.0, 1.0); var a2 = acos(c2); val lim = Math.toRadians(e.value("eklemAciSini", t)); a2 = a2.coerceAtMost(lim)
        val dir = when (e.value("bukulmeYonu", t).roundToInt()) { 1 -> -1.0; 2 -> if (dx >= 0) 1.0 else -1.0; else -> 1.0 }; a2 *= dir
        val a1 = atan2(dy, dx) - atan2(L2 * sin(a2), L1 + L2 * cos(a2)); val ex = base.x + cos(a1) * L1; val ey = base.y + sin(a1) * L1
        return doubleArrayOf(Math.toDegrees(a1), Math.toDegrees(a1 + a2), ex, ey) }

    fun local(p: Project, l: Layer, t: Double, tr0: TR): TR {
        var tr = tr0
        for (e in l.effects) { if (e.on == false) continue; fun v(k: String) = e.value(k, t)
            when (e.type) {
                "cbbeat" -> { // 425 CB Ritme Tepki: sesin tepe seviyesinden yükselme/sönüm zarfı → ölçek ve açı
                    val src = tgt(p, e, "sesKayn") ?: p.layers.firstOrNull { it.type == "audio" && it.muted != true } ?: continue
                    val thr = (v("esik") / 100).coerceIn(0.0, 0.99); val gain = v("hassasiy") / 50; val rel = max(0.02, v("sonum")); val att = max(0.0, v("tepki"))
                    var env = 0.0; val win = min(3.0, rel * 5 + att); val n = (win * 100).toInt().coerceIn(1, 300)
                    for (i in 0..n) { val tau = i / 100.0; val tt = t - tau; if (tt < src.start) break
                        var lev = AudioLevels.level(src, tt) * gain; if (v("basAgir") >= 0.5) lev = lev * lev * 1.4
                        val hit = max(0.0, (lev - thr) / (1 - thr)); if (hit <= 0) continue
                        val a = if (att > 1e-3) min(1.0, tau / att) else 1.0
                        env = max(env, hit * a * exp(-max(0.0, tau - att) / rel)) }
                    env = env.coerceIn(0.0, 1.5)
                    val f = 1 + v("buyume") / 100 * env
                    tr = tr.copy(scale = tr.scale * f, rot = tr.rot + v("donus") * env)
                    if (v("sabitTaba") >= 0.5) tr = tr.copy(y = tr.y - l.h / 2 * tr.scale / f * tr.sy * (f - 1)) }
                "lookat" -> { val sm = max(0.0, v("yumusatm")); var ax = 0.0; var ay = 0.0; val S = if (sm > 0.01) 6 else 1
                    for (i in 0 until S) { val tt = t - sm * i / max(1, S - 1); val g = tgt(p, e, "hedef"); val (gx, gy) = if (g != null) worldTransform(p, g, tt).let { it.x to it.y } else (e.value("elleHedeNoktX", tt) / 100 * p.width to e.value("elleHedeNoktY", tt) / 100 * p.height); ax += gx / S; ay += gy / S }
                    tr = tr.copy(rot = Math.toDegrees(atan2(ay - tr.y, ax - tr.x)) + v("aciOfse")) }
                "seek" -> { val g = tgt(p, e, "hedef") ?: continue
                    val st = Physics.sim(l.id + e.id, (e.v.hashCode() * 31 + g.id.hashCode()), l.start, t, { doubleArrayOf(l.x.at(l.start), l.y.at(l.start), 0.0, 0.0) }) { s, tt ->
                        val w = worldTransform(p, g, tt); val dx = w.x - s[0]; val dy = w.y - s[1]; val d = hypot(dx, dy); val stop = e.value("durmaMesa", tt); val vmax = e.value("hiz", tt); val acc = e.value("ivme", tt)
                        val want = if (d <= stop) 0.0 else min(vmax, sqrt(2 * acc * (d - stop))); val tx = if (d > 1e-6) dx / d * want else 0.0; val ty = if (d > 1e-6) dy / d * want else 0.0
                        val ddx = tx - s[2]; val ddy = ty - s[3]; val dv = hypot(ddx, ddy); val lim = acc * Physics.DT; if (dv > lim) { s[2] += ddx / dv * lim; s[3] += ddy / dv * lim } else { s[2] = tx; s[3] = ty }
                        s[0] += s[2] * Physics.DT; s[1] += s[3] * Physics.DT }
                    tr = tr.copy(x = st[0], y = st[1]) }
                "flee" -> { val g = tgt(p, e, "hedef") ?: continue; val w = worldTransform(p, g, t); val dx = tr.x - w.x; val dy = tr.y - w.y; val d = hypot(dx, dy); val R = max(1.0, v("etkiYari"))
                    if (d < R && d > 1e-6) { val k = (1 - d / R).pow(2) * v("itme") * 0.5; tr = tr.copy(x = tr.x + dx / d * k, y = tr.y + dy / d * k) } }
                "keepbounds" -> { val b = tgt(p, e, "sinir"); val m = v("kenarPayi"); var x0 = 0.0; var y0 = 0.0; var x1 = p.width.toDouble(); var y1 = p.height.toDouble()
                    if (b != null) { val w = worldTransform(p, b, t); x0 = w.x - b.w * w.scale / 2; x1 = w.x + b.w * w.scale / 2; y0 = w.y - b.h * w.scale / 2; y1 = w.y + b.h * w.scale / 2 }
                    val hw = l.w * abs(tr.scale) * tr.sx / 2; val hh = l.h * abs(tr.scale) * tr.sy / 2
                    tr = tr.copy(x = tr.x.coerceIn(x0 + m + hw, max(x0 + m + hw, x1 - m - hw)), y = tr.y.coerceIn(y0 + m + hh, max(y0 + m + hh, y1 - m - hh))) }
                "velorient" -> { val sm = max(0.02, v("yumusatm")); var ang: Double? = null; var k = 0
                    while (ang == null && k < 60) { val tt = t - k * 0.05; val a = pos(l, tt - sm / 2); val b = pos(l, tt + sm / 2); val vel = hypot(b[0] - a[0], b[1] - a[1]) / sm; if (vel >= v("asgariHiz")) ang = Math.toDegrees(atan2(b[1] - a[1], b[0] - a[0])); k++ }
                    if (ang != null) tr = tr.copy(rot = tr.rot + ang + v("aciOfse")) }
                "velscale" -> { val dt = 1.0 / 30; val a = pos(l, t - dt); val b = pos(l, t); val sp = hypot(b[0] - a[0], b[1] - a[1]) / dt; val k = 1 + min(1.0, sp / max(1.0, v("azamiHiz")))
                    tr = if (v("oraniKoru") >= 0.5) tr.copy(scale = tr.scale * k) else tr.copy(sx = tr.sx * k, sy = tr.sy / sqrt(k)) }
                "draginertia" -> { val last = maxOf(l.x.k?.maxOfOrNull { it.t } ?: l.start, l.y.k?.maxOfOrNull { it.t } ?: l.start); if (t <= last) continue
                    val dt = 1.0 / 30; val a = pos(l, last - dt); val b = pos(l, last); val vx = (b[0] - a[0]) / dt * v("atalet") / 100; val vy = (b[1] - a[1]) / dt * v("atalet") / 100; val f = max(0.1, v("surtunme"))
                    val tt = min(t - last, v("azamiSure")); val k = (1 - exp(-f * tt)) / f; tr = tr.copy(x = tr.x + vx * k, y = tr.y + vy * k) }
                "motiondamp" -> { val lag = v("azamiGeci") * v("sonum") / 100; if (lag <= 0.001) continue; var sx = 0.0; var sy = 0.0; var ws = 0.0
                    for (i in 0..12) { val tt = t - lag * 2 * i / 12.0; if (v("uclariKoru") >= 0.5 && tt < l.start) break; val w = exp(-i / 4.0); val q = pos(l, tt); sx += q[0] * w; sy += q[1] * w; ws += w }
                    val q = pos(l, t); var dx = sx / ws - q[0]; var dy = sy / ws - q[1]; if (v("uclariKoru") >= 0.5) { val k = min(1.0, min(t - l.start, l.end - t) / max(lag, 1e-3)); dx *= k; dy *= k }
                    tr = tr.copy(x = tr.x + dx, y = tr.y + dy) }
                "quantmotion" -> { fun qz(x: Double, s: Double) = if (s > 1e-6) (x / s).roundToInt() * s else x
                    tr = tr.copy(x = qz(tr.x, v("konumAdimX")), y = qz(tr.y, v("konumAdimY")), rot = qz(tr.rot, v("aciAdim")), scale = if (v("olcekAdim") > 0) qz(tr.scale * 100, v("olcekAdim")) / 100 else tr.scale) }
                "fitpath" -> { var x0 = 1e18; var y0 = 1e18; var x1 = -1e18; var y1 = -1e18; for (i in 0..60) { val q = pos(l, l.start + (l.end - l.start) * i / 60.0); x0 = min(x0, q[0]); y0 = min(y0, q[1]); x1 = max(x1, q[0]); y1 = max(y1, q[1]) }
                    val bw = max(1e-3, x1 - x0); val bh = max(1e-3, y1 - y0); var kx = v("hedefBoyuX") / bw; var ky = v("hedefBoyuY") / bh; if (v("oraniKoru") >= 0.5) { val k = min(kx, ky); kx = k; ky = k }
                    val cx = v("merkezX") / 100 * p.width; val cy = v("merkezY") / 100 * p.height; val q = pos(l, t); tr = tr.copy(x = cx + (q[0] - (x0 + x1) / 2) * kx + (tr.x - q[0]), y = cy + (q[1] - (y0 + y1) / 2) * ky + (tr.y - q[1])) }
                "loopblend" -> { val D = max(0.1, v("donguSure")); val B = min(v("birlesimSure"), D / 2); val rel = t - l.start; val pp = v("ileriGeri") >= 0.5
                    var u = rel % D; if (pp && ((rel / D).toInt() % 2 == 1)) u = D - u
                    val a = pos(l, l.start + u); var x = a[0]; var y = a[1]; if (!pp && B > 0 && u > D - B) { val k = (u - (D - B)) / B; val b = pos(l, l.start + u - D + B - B); x = a[0] * (1 - k) + b[0] * k; y = a[1] * (1 - k) + b[1] * k }
                    val q = pos(l, t); tr = tr.copy(x = tr.x + x - q[0], y = tr.y + y - q[1], rot = l.rotation.at(l.start + u) + (tr.rot - l.rotation.at(t))) }
                "slideon" -> { val g = tgt(p, e, "govde") ?: continue; val w = worldTransform(p, g, t); val a = v("konturIler") / 100 * 2 * PI - PI / 2 + w.rot * PI / 180
                    val rx = g.w * w.scale / 2 + v("uzaklik"); val ry = g.h * w.scale / 2 + v("uzaklik"); tr = tr.copy(x = w.x + cos(a) * rx, y = w.y + sin(a) * ry, rot = tr.rot + Math.toDegrees(a) + 90) }
                "attach" -> { val g = tgt(p, e, "hedef") ?: continue
                    fun stuck(tt: Double): TR { val w = worldTransform(p, g, tt); val ra = w.rot * PI / 180; val ox = v("bagNoktX"); val oy = v("bagNoktY"); return tr.copy(x = w.x + (ox * cos(ra) - oy * sin(ra)) * w.scale, y = w.y + (ox * sin(ra) + oy * cos(ra)) * w.scale, rot = tr.rot + w.rot) }
                    if (e.value("bagli", t) >= 0.5) tr = stuck(t) else { var tb = -1.0; var tt = t; while (tt > l.start) { tt -= 1.0 / 30; if (e.value("bagli", tt) >= 0.5) { tb = tt; break } }
                        if (tb >= 0) tr = if (v("ayrilmadDunyDonu") >= 0.5) stuck(tb) else stuck(tb).copy(rot = tr.rot) } }
                "jigglejoint" -> { val par = tgt(p, e, "ebeveyn") ?: continue
                    val st = Physics.sim(l.id + e.id, (e.v.hashCode() * 31 + par.id.hashCode()), l.start, t, { DoubleArray(2) }) { s, tt ->
                        val a = worldTransform(p, par, tt - Physics.DT); val b = worldTransform(p, par, tt); val c = worldTransform(p, par, tt + Physics.DT); val ax = (c.x - 2 * b.x + a.x) / (Physics.DT * Physics.DT)
                        val k = 5.0 + e.value("sertlik", tt) / 100 * 200; val d = e.value("sonum", tt) / 100 * 2 * sqrt(k); s[1] += (-k * s[0] - d * s[1] - ax * 0.05) * Physics.DT; s[0] += s[1] * Physics.DT }
                    val w = worldTransform(p, par, t); val ra = w.rot * PI / 180; val ox = v("bagNoktX"); val oy = v("bagNoktY"); val jx = w.x + (ox * cos(ra) - oy * sin(ra)) * w.scale; val jy = w.y + (ox * sin(ra) + oy * cos(ra)) * w.scale
                    val ang = st[0].coerceIn(-80.0, 80.0); val rr = ang * PI / 180; val dx = tr.x - jx; val dy = tr.y - jy; tr = tr.copy(x = jx + dx * cos(rr) - dy * sin(rr), y = jy + dx * sin(rr) + dy * cos(rr), rot = tr.rot + ang) }
                "rhythmevents" -> { // sesin vuruşlarında sırayla olay: nabız, zıplama, dönme, sallanma
                    val src = tgt(p, e, "ses") ?: continue; val th = v("esik") / 100 * 0.6; var beat = -1.0; var idx = 0; var prev = 0.0; var tt = l.start
                    while (tt <= t) { val lv = AudioLevels.level(src, tt); if (lv > th && prev <= th) { beat = tt; idx++ }; prev = lv; tt += 1.0 / 60 }
                    if (beat < 0) continue; val age = t - beat; if (age > 0.4) continue; val k = sin(age / 0.4 * PI) * exp(-age * 4)
                    val ev = when (v("olaySira").roundToInt()) { 1 -> 0; 2 -> ((sin(idx * 12.9898) * 43758.5453).let { it - floor(it) } * 4).toInt(); else -> idx % 4 }
                    tr = when (ev) { 0 -> tr.copy(scale = tr.scale * (1 + 0.15 * k)); 1 -> tr.copy(y = tr.y - 30 * k); 2 -> tr.copy(rot = tr.rot + 15 * k); else -> tr.copy(x = tr.x + 12 * k * sin(age * 60)) } }
                "pathmasktrack" -> { val vid = tgt(p, e, "video") ?: continue; val key = l.id + e.id + "|0.5, 0.5" + vid.id; val tr0 = Tracker.get(key) ?: continue; val i = ((t - vid.start) * tr0.fps).toInt(); val pos = Tracker.at(key, i) ?: continue; val p0 = Tracker.at(key, 0) ?: continue
                    val w = worldTransform(p, vid, t); val k = v("deformas") / 100 * 0.5 + 0.5; tr = tr.copy(x = tr.x + (pos[0] - p0[0]) * vid.w * w.scale * k * 2, y = tr.y + (pos[1] - p0[1]) * vid.h * w.scale * k * 2) }
                "ikchain" -> { val ang = ik(p, l, e, t, tr) ?: continue; tr = tr.copy(rot = ang[0]) }
                "paramlink" -> { val src = tgt(p, e, "kaynakPara") ?: continue; val w = worldTransform(p, src, t); val k = v("kaynakOzellik").roundToInt()
                    val sv = when (k) { 0 -> w.x; 1 -> w.y; 2 -> w.rot; 3 -> w.scale * 100; else -> w.opacity * 100 }; val out = sv * v("carpan") + v("ofset")
                    tr = when (v("hedefPara").roundToInt()) { 0 -> tr.copy(x = out); 1 -> tr.copy(y = out); 2 -> tr.copy(rot = out); 3 -> tr.copy(scale = out / 100); else -> tr.copy(opacity = (out / 100).coerceIn(0.0, 1.0)) } }
                "softlimit" -> { val lo = v("altSinir"); val hi = v("ustSinir"); val g = max(1e-6, v("gecis")); fun soft(x: Double): Double { if (x > hi - g) return hi - g + g * tanh((x - (hi - g)) / g); if (x < lo + g) return lo + g - g * tanh(((lo + g) - x) / g); return x }
                    tr = when (v("hedefPara").roundToInt()) { 0 -> tr.copy(x = soft(tr.x)); 1 -> tr.copy(y = soft(tr.y)); 2 -> tr.copy(rot = soft(tr.rot)); 3 -> tr.copy(scale = soft(tr.scale * 100) / 100); else -> tr.copy(opacity = (soft(tr.opacity * 100) / 100).coerceIn(0.0, 1.0)) } }
                "snapcurve" -> { val g = tgt(p, e, "egri") ?: continue; val w = worldTransform(p, g, t); val ra = w.rot * PI / 180
                    val pts = (g.pts?.takeIf { it.size >= 2 }?.map { doubleArrayOf((it[0] - 0.5) * g.w, (it[1] - 0.5) * g.h) } ?: listOf(doubleArrayOf(-g.w / 2, 0.0), doubleArrayOf(g.w / 2, 0.0)))
                        .map { doubleArrayOf(w.x + (it[0] * cos(ra) - it[1] * sin(ra)) * w.scale, w.y + (it[0] * sin(ra) + it[1] * cos(ra)) * w.scale) }
                    var best = 1e18; var bx = tr.x; var by = tr.y; var tang = 0.0
                    for (i in 0 until pts.size - 1) { val a = pts[i]; val b = pts[i + 1]; val abx = b[0] - a[0]; val aby = b[1] - a[1]; val u = (((tr.x - a[0]) * abx + (tr.y - a[1]) * aby) / max(1e-9, abx * abx + aby * aby)).coerceIn(0.0, 1.0)
                        val cx = a[0] + abx * u; val cy = a[1] + aby * u; val d = hypot(tr.x - cx, tr.y - cy); if (d < best) { best = d; bx = cx; by = cy; tang = atan2(aby, abx) } }
                    tr = tr.copy(x = bx - sin(tang) * v("uzaklik"), y = by + cos(tang) * v("uzaklik"), rot = if (v("tegeteDon") >= 0.5) tr.rot + Math.toDegrees(tang) else tr.rot) }
            } }
        return tr
    }
}
