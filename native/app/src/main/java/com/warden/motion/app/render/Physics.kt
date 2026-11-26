package com.warden.motion.app.render

import com.warden.motion.app.model.Effect
import com.warden.motion.app.model.Layer
import com.warden.motion.app.model.Project
import com.warden.motion.app.model.at
import com.warden.motion.app.model.value
import kotlin.math.*

/**
 * Basit, belirlenimci fizik (498 Yay Zinciri, 501 Çarpışma ve Sekme, 504 Yumuşak Cisim, 506 Sürü Hareketi).
 * Benzetim her zaman katmanın başından sabit adımla (1/60 sn) yürütülür; zaman çizelgesinde ileri-geri gitmek aynı sonucu verir.
 * Son durum önbellekte tutulur, ileri oynatmada kaldığı yerden devam eder.
 */
object Physics {
    const val DT = 1.0 / 60
    private class Sim(val key: Int, var t: Double, val s: DoubleArray)
    private val cache = HashMap<String, Sim>()

    /** Önbellekli adım: init başlangıç durumu, step bir adım ilerletir */
    fun sim(id: String, key: Int, start: Double, t: Double, init: () -> DoubleArray, step: (DoubleArray, Double) -> Unit) = run(id, key, start, t, init, step)
    private fun run(id: String, key: Int, start: Double, t: Double, init: () -> DoubleArray, step: (DoubleArray, Double) -> Unit): DoubleArray {
        var sim = cache[id]
        if (sim == null || sim.key != key || sim.t > t + 1e-9) { sim = Sim(key, start, init()); cache[id] = sim }
        var guard = 0
        while (sim.t + DT <= t + 1e-9 && guard < 60 * 600) { step(sim.s, sim.t); sim.t += DT; guard++ }
        if (cache.size > 64) cache.keys.take(16).forEach { cache.remove(it) }
        return sim.s
    }
    private fun sig(e: Effect, extra: Any? = null) = (e.v.hashCode() * 31 + (e.c?.hashCode() ?: 0)) * 31 + (extra?.hashCode() ?: 0)
    private fun base(l: Layer, t: Double) = doubleArrayOf(l.x.at(t), l.y.at(t))

    /** Katmanın yerel dönüşümüne fizik etkisi (Renderer.worldTransform içinden) */
    fun local(p: Project, l: Layer, t: Double, tr0: TR): TR {
        var tr = tr0
        for (e in l.effects) { if (e.on == false) continue
            when (e.type) {
                "springchain" -> { val root = e.c?.get("kokKatm")?.let { id -> p.layers.find { it.id == id } } ?: continue; if (root.id == l.id) continue
                    val r0 = worldTransform(p, root, l.start); val o0x = l.x.at(l.start) - r0.x; val o0y = l.y.at(l.start) - r0.y; val rest = max(1.0, e.value("parcaAral", t))
                    val st = run(l.id + e.id, sig(e, root.x.hashCode() * 7 + root.y.hashCode()), l.start, t, { doubleArrayOf(l.x.at(l.start), l.y.at(l.start), 0.0, 0.0) }) { s, tt ->
                        val r = worldTransform(p, root, tt); val ax = r.x + o0x; val ay = r.y + o0y; val k = 2.0 + e.value("yaySert", tt) / 100 * 120; val c = e.value("sonum", tt) / 100 * 2 * sqrt(k)
                        val m = max(0.1, e.value("kutle", tt)); var fx = k * (ax - s[0]) - c * s[2]; var fy = k * (ay - s[1]) - c * s[3] + e.value("yercekim", tt) * m
                        s[2] += fx / m * DT; s[3] += fy / m * DT; s[0] += s[2] * DT; s[1] += s[3] * DT
                        if (e.value("uzunluguKoru", tt) >= 0.5) { val dx = s[0] - r.x; val dy = s[1] - r.y; val d = hypot(dx, dy); val L = max(rest, hypot(o0x, o0y)); if (d > L && d > 1e-6) { s[0] = r.x + dx / d * L; s[1] = r.y + dy / d * L } } }
                    tr = tr.copy(x = st[0], y = st[1]) }
                "collide" -> { val st = run(l.id + e.id, sig(e, p.width.toInt() * 31 + p.height.toInt()), l.start, t, { doubleArrayOf(l.x.at(l.start), l.y.at(l.start), e.value("baslangiHiziX", l.start), e.value("baslangiHiziY", l.start), 0.0) }) { s, tt ->
                        val sc = l.scale.at(tt); val shape = e.value("carpismaSekl", tt).roundToInt(); val hw = if (shape == 0) min(l.w, l.h) / 2 * sc else l.w / 2 * sc; val hh = if (shape == 0) hw else l.h / 2 * sc
                        val drag = 1 - e.value("havaDire", tt) / 100 * DT * 2; s[2] = (s[2] + e.value("yercekimX", tt) * DT) * drag; s[3] = (s[3] + e.value("yercekimY", tt) * DT) * drag
                        s[0] += s[2] * DT; s[1] += s[3] * DT; val rest = e.value("sekme", tt) / 100; val fr = 1 - e.value("surtunme", tt) / 100
                        if (s[0] - hw < 0) { s[0] = hw; s[2] = abs(s[2]) * rest; s[3] *= fr }; if (s[0] + hw > p.width) { s[0] = p.width - hw; s[2] = -abs(s[2]) * rest; s[3] *= fr }
                        if (s[1] - hh < 0) { s[1] = hh; s[3] = abs(s[3]) * rest; s[2] *= fr }; if (s[1] + hh > p.height) { s[1] = p.height - hh; s[3] = -abs(s[3]) * rest; s[2] *= fr }
                        if (e.value("donusuSimuEt", tt) >= 0.5) s[4] += s[2] * DT / max(hw, 1.0) * 180 / PI }
                    val b = base(l, t); val b0 = base(l, l.start); tr = tr.copy(x = st[0] + (b[0] - b0[0]), y = st[1] + (b[1] - b0[1]), rot = tr.rot + st[4]) }
                "softbody" -> { if (e.value("hareketiKaynKatm", t) < 0.5) continue
                    val st = run(l.id + e.id, sig(e, l.x.hashCode() * 31 + l.y.hashCode()), l.start, t, { DoubleArray(4) }) { s, tt ->
                        val v0 = base(l, tt - DT); val v1 = base(l, tt); val v2 = base(l, tt + DT); val ax = (v2[0] - 2 * v1[0] + v0[0]) / (DT * DT); val ay = (v2[1] - 2 * v1[1] + v0[1]) / (DT * DT)
                        val k = 20.0 + e.value("sertlik", tt) / 100 * 400; val c = e.value("sonum", tt) / 100 * 2 * sqrt(k); val ine = e.value("atalet", tt) / 100 * 0.6
                        s[2] += (-k * s[0] - c * s[2] - ax * ine) * DT; s[3] += (-k * s[1] - c * s[3] - ay * ine) * DT; s[0] += s[2] * DT; s[1] += s[3] * DT }
                    val lim = e.value("maksimumEsne", t) / 100; var ex = (st[0] / max(l.w, 1.0)).coerceIn(-lim, lim); var ey = (st[1] / max(l.h, 1.0)).coerceIn(-lim, lim)
                    val keep = e.value("alanKoru", t) / 100; var sx = 1 + abs(ex) - abs(ey) * keep; var sy = 1 + abs(ey) - abs(ex) * keep; sx = max(0.3, sx); sy = max(0.3, sy)
                    tr = tr.copy(sx = tr.sx * sx, sy = tr.sy * sy, skew = tr.skew + (ex - ey) * 0.0)
                    if (e.value("tabaniSabi", t) >= 0.5) tr = tr.copy(y = tr.y + l.h * tr.scale * (1 - sy) / 2) }
            } }
        return tr
    }

    /** 506 Sürü Hareketi: kopyaların konumları (katmana göre) ve yön açıları */
    fun flock(l: Layer, e: Effect, t: Double, w: Double, h: Double): List<DoubleArray> {
        val N = e.value("kopyaSayi", t).roundToInt().coerceIn(1, 120)
        val st = run(l.id + e.id, sig(e, N), l.start, t, {
            val s = DoubleArray(N * 4); val sd = e.value("tohum", l.start)
            for (i in 0 until N) { fun h1(k: Double) = (sin((i * 12.9898 + k * 78.233 + sd * 3.17)) * 43758.5453).let { it - floor(it) }
                s[i * 4] = (h1(1.0) - 0.5) * w; s[i * 4 + 1] = (h1(2.0) - 0.5) * h; val a = h1(3.0) * 2 * PI; s[i * 4 + 2] = cos(a) * 50; s[i * 4 + 3] = sin(a) * 50 }; s }) { s, tt ->
            val R = max(1.0, e.value("komsulukYari", tt)); val sep = e.value("ayrilma", tt) / 100; val ali = e.value("hizalanm", tt) / 100; val coh = e.value("yakinlas", tt) / 100; val sp = e.value("hiz", tt)
            val gx = e.value("genelYonX", tt); val gy = e.value("genelYonY", tt)
            for (i in 0 until N) { var cx = 0.0; var cy = 0.0; var vx = 0.0; var vy = 0.0; var px = 0.0; var py = 0.0; var c = 0
                for (j in 0 until N) { if (i == j) continue; val dx = s[j * 4] - s[i * 4]; val dy = s[j * 4 + 1] - s[i * 4 + 1]; val d = hypot(dx, dy); if (d > R) continue; c++
                    cx += dx; cy += dy; vx += s[j * 4 + 2]; vy += s[j * 4 + 3]; if (d < R * 0.4 && d > 1e-6) { px -= dx / d * (R * 0.4 - d); py -= dy / d * (R * 0.4 - d) } }
                var ax = gx * sp * 0.5; var ay = gy * sp * 0.5
                if (c > 0) { ax += cx / c * coh * 1.5 + (vx / c - s[i * 4 + 2]) * ali * 2 + px * sep * 6; ay += cy / c * coh * 1.5 + (vy / c - s[i * 4 + 3]) * ali * 2 + py * sep * 6 }
                // kutu sınırında yumuşak geri dönüş
                if (abs(s[i * 4]) > w * 0.6) ax -= sign(s[i * 4]) * sp * 3; if (abs(s[i * 4 + 1]) > h * 0.6) ay -= sign(s[i * 4 + 1]) * sp * 3
                s[i * 4 + 2] += ax * DT; s[i * 4 + 3] += ay * DT; val v = hypot(s[i * 4 + 2], s[i * 4 + 3]); if (v > sp && v > 1e-6) { s[i * 4 + 2] *= sp / v; s[i * 4 + 3] *= sp / v } }
            for (i in 0 until N) { s[i * 4] += s[i * 4 + 2] * DT; s[i * 4 + 1] += s[i * 4 + 3] * DT } }
        val sd = e.value("tohum", t); val rnd = e.value("boyutRast", t) / 100
        return (0 until N).map { i -> val k = (sin(i * 7.13 + sd) * 43758.5453).let { it - floor(it) }; doubleArrayOf(st[i * 4], st[i * 4 + 1], Math.toDegrees(atan2(st[i * 4 + 3], st[i * 4 + 2])), 1 + (k - 0.5) * 2 * rnd) }
    }
}
