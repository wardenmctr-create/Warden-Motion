package com.warden.motion.app.render

import com.warden.motion.app.model.Anim
import com.warden.motion.app.model.Effect
import com.warden.motion.app.model.Layer
import com.warden.motion.app.model.Project
import com.warden.motion.app.model.at
import com.warden.motion.app.model.value
import kotlin.math.*

/**
 * 1000 rehberi bölüm 5 (891–912): animasyon, rig ve Countryball yardımcıları.
 * local: efektin bulunduğu katmanın kendi dönüşümü; rig: efektin seçtiği diğer katmanlar (ayak, uzuv, iris, yüz parçaları, poz grupları).
 */
object Anim1000 {
    val RIG = setOf("posehold", "slopeattach", "bonepropagate", "bubblelayout", "labelavoid", "footlock", "stepcycle", "irislock", "exprweights", "facecoords", "jointlimit", "phasespread", "speedpose", "motionmirror")
    private fun ids(e: Effect, k: String) = e.c?.get(k)?.split(',')?.filter { it.isNotBlank() } ?: emptyList()
    private fun lay(p: Project, e: Effect, k: String) = e.c?.get(k)?.split(',')?.firstOrNull { it.isNotBlank() }?.let { id -> p.layers.find { it.id == id } }
    private fun h1(n: Double): Double { val x = sin(n * 127.1 + 311.7) * 43758.5453; return x - floor(x) }
    private fun sm(x: Double) = x.coerceIn(0.0, 1.0).let { it * it * (3 - 2 * it) }
    /** Katmanın kendi keyframe'li konumu (efektsiz), hız ölçümü için */
    private fun pos(l: Layer, t: Double) = l.x.at(t) to l.y.at(t)
    private fun speed(l: Layer, t: Double): Double { val d = 1.0 / 30; val (a, b) = pos(l, t - d); val (c, e) = pos(l, t); return hypot(c - a, e - b) / d }

    private var depth = 0
    fun local(p: Project, l: Layer, t: Double, tr0: TR): TR {
        if (depth > 2 || l.effects.none { it.type in LOCAL }) return tr0
        depth++
        try { return local0(p, l, t, tr0) } finally { depth-- }
    }
    private val LOCAL = setOf("posehold", "multicentroid", "axisparent", "dynpivot", "wheelroll", "twopointstretch", "contactsquash", "weightshift", "eyesaccade", "overshootstop", "anticipation", "rhythmquant", "looplock")
    private fun local0(p: Project, l: Layer, t: Double, tr0: TR): TR {
        var tr = tr0
        for (e in l.effects) { if (e.on == false) continue; fun v(k: String) = e.value(k, t)
            when (e.type) {
                "posehold" -> if (e.c?.get("dondurulKatm").isNullOrBlank() || e.c?.get("dondurulKatm") == l.id) { val tt = holdTime(e, l, t); val a = layerTransform(l, tt); val b = layerTransform(l, t)
                    tr = tr.copy(x = tr.x + a.x - b.x, y = tr.y + a.y - b.y, rot = tr.rot + a.rot - b.rot, scale = tr.scale * (if (abs(b.scale) > 1e-6) a.scale / b.scale else 1.0)) }
                "multicentroid" -> { // 891: seçili hedeflerin (gecikmeli) ağırlık merkezi; ağırlık = sıra (ilk hedefler daha baskın)
                    val tg = ids(e, "hedefler").mapNotNull { id -> p.layers.find { it.id == id } }.filter { it.id != l.id }; if (tg.isEmpty()) continue
                    val tt = t - v("gecikme"); var x = 0.0; var y = 0.0; var ws = 0.0
                    tg.forEachIndexed { i, g -> val w = 1.0 / (1 + i * 0.5); val wt = worldTransform(p, g, tt); x += wt.x * w; y += wt.y * w; ws += w }
                    tr = tr.copy(x = x / ws + v("ofsetX"), y = y / ws + v("ofsetY")) }
                "axisparent" -> { // 892: X, Y, dönüş, ölçek ayrı kaynakların başlangıca göre değişimini izler
                    val keep = v("baslangiOfseKoru") >= 0.5
                    lay(p, e, "xKayn")?.let { s -> val a = worldTransform(p, s, t).x; tr = tr.copy(x = if (keep) tr.x + a - worldTransform(p, s, l.start).x else a) }
                    lay(p, e, "yKayn")?.let { s -> val a = worldTransform(p, s, t).y; tr = tr.copy(y = if (keep) tr.y + a - worldTransform(p, s, l.start).y else a) }
                    lay(p, e, "donusKayn")?.let { s -> val a = worldTransform(p, s, t).rot; tr = tr.copy(rot = if (keep) tr.rot + a - worldTransform(p, s, l.start).rot else a) }
                    lay(p, e, "olcekKayn")?.let { s -> val a = worldTransform(p, s, t).scale; val b = worldTransform(p, s, l.start).scale; tr = tr.copy(scale = if (keep && abs(b) > 1e-6) tr.scale * a / b else a) } }
                "dynpivot" -> { // 893: dönüş/ölçek, katman merkezi yerine hedef noktası (katman ya da ofset) çevresinde; görsel konum korunur
                    val g = lay(p, e, "pivotHede"); val sm = max(0.0, v("yumusatm")); var px = 0.0; var py = 0.0; val S = if (sm > 0.01) 5 else 1
                    for (i in 0 until S) { val tt = t - sm * i / max(1, S - 1); if (g != null) { val w = worldTransform(p, g, tt); px += w.x / S; py += w.y / S } else { px += (tr.x + v("ofsetX")) / S; py += (tr.y + v("ofsetY")) / S } }
                    val r0 = l.rotation.at(l.start); val dr = (tr.rot - r0) * PI / 180; val k = if (abs(l.scale.at(l.start)) > 1e-6) tr.scale / l.scale.at(l.start) else 1.0
                    val dx = tr.x - px; val dy = tr.y - py; val nx = px + (dx * cos(dr) - dy * sin(dr)) * k; val ny = py + (dx * sin(dr) + dy * cos(dr)) * k
                    tr = if (v("gorselKonuKoru") >= 0.5) tr.copy(x = (nx + tr.x) / 2, y = (ny + tr.y) / 2) else tr.copy(x = nx, y = ny) }
                "wheelroll" -> { // 894: kat edilen yatay yol / yarıçap → dönüş (kayma payı ile)
                    val src = lay(p, e, "hareketKayn") ?: l; val R = max(1.0, v("yaricap")); var dist = 0.0; val n = min(600, max(8, ((t - l.start) * 60).toInt())); var prev = worldTransform(p, src, l.start).x
                    for (i in 1..n) { val tt = l.start + (t - l.start) * i / n; val x = if (src === l) l.x.at(tt) else worldTransform(p, src, tt).x; dist += x - prev; prev = x }
                    val dir = when (v("yon").roundToInt()) { 1 -> 1.0; 2 -> -1.0; else -> 1.0 }; val ang = dist / R * 180 / PI * dir * (1 - v("kayma") / 100)
                    tr = tr.copy(rot = tr.rot + if (v("yon").roundToInt() == 0) ang else abs(ang) * dir) }
                "twopointstretch" -> { // 895: katmanın iki ucu iki hedefe; boy ekseni uzar (sınırlı), isteğe bağlı genişlik korunur
                    val a = lay(p, e, "basHede") ?: continue; val b = lay(p, e, "sonHede") ?: continue; val wa = worldTransform(p, a, t); val wb = worldTransform(p, b, t)
                    val d = hypot(wb.x - wa.x, wb.y - wa.y); val base = max(1.0, l.w * l.scale.at(t)); val k = min(d / base, v("esnemeSini") / 100)
                    tr = tr.copy(x = (wa.x + wb.x) / 2, y = (wa.y + wb.y) / 2, rot = atan2(wb.y - wa.y, wb.x - wa.x) * 180 / PI, sx = tr.sx * k, sy = if (v("genisligKoru") >= 0.5) tr.sy else tr.sy * k) }
                "contactsquash" -> { // 896: temas katmanına yaklaştıkça temas doğrultusunda ezilme, ayrılınca yumuşak geri dönüş
                    val c = lay(p, e, "temasKatm") ?: continue; fun gap(tt: Double): Double { val a = layerTransform(l, tt); val b = worldTransform(p, c, tt); return hypot(b.x - tr.x, b.y - tr.y) - (l.w * a.scale + c.w * b.scale) / 2 }
                    val R = max(1.0, v("etkiYari")); val back = max(0.01, v("geriDonu")); var k = 0.0; for (i in 0..8) { val tt = t - back * i / 8; k = max(k, (1 - gap(tt) / R).coerceIn(0.0, 1.0) * (1 - i / 9.0)) }
                    val q = k * v("ezilme") / 100; val b = worldTransform(p, c, t); val horiz = abs(b.x - tr.x) > abs(b.y - tr.y)
                    tr = if (horiz) tr.copy(sx = tr.sx * (1 - q), sy = tr.sy * (1 + q * 0.5)) else tr.copy(sy = tr.sy * (1 - q), sx = tr.sx * (1 + q * 0.5)) }
                "weightshift" -> { // 897: gövde destek noktalarının (ağırlık konumu oranında) üstüne kayarken eğilir
                    val sp = ids(e, "destekNokt").mapNotNull { id -> p.layers.find { it.id == id } }; if (sp.isEmpty()) continue
                    val tt = t - v("gecikme"); val xs = sp.map { worldTransform(p, it, tt).x }.sorted(); val target = xs.first() + (xs.last() - xs.first()) * v("agirlikKonu") / 100
                    val off = (tr.x - target) / max(1.0, l.w * tr.scale); tr = tr.copy(rot = tr.rot - off.coerceIn(-1.0, 1.0) * v("egim"), x = tr.x + (target - tr.x) * 0.15) }
                "eyesaccade" -> { // 900: hedefler arasında bekle–sıçra; küçük titreşim
                    val tg = ids(e, "hedefler").mapNotNull { id -> p.layers.find { it.id == id } }; val hold = max(0.1, v("bekleme")); val jump = max(0.01, v("sicrama"))
                    val lt = t - l.start; val k = floor(lt / hold).toInt(); val f = lt - k * hold
                    fun look(i: Int): Pair<Double, Double> { if (tg.isEmpty()) { val a = h1(i * 3.1) * 2 * PI; return cos(a) to sin(a) * 0.6 }
                        val g = worldTransform(p, tg[((i % tg.size) + tg.size) % tg.size], t); val dx = g.x - tr.x; val dy = g.y - tr.y; val d = max(1.0, hypot(dx, dy)); return dx / d to dy / d }
                    val (ax, ay) = look(k - 1); val (bx, by) = look(k); val u = sm(f / jump); val R = l.w * tr.scale * 0.18
                    tr = tr.copy(x = tr.x + (ax + (bx - ax) * u) * R + (h1(floor(lt * 20) + 1.3) - 0.5) * v("mikroHare"), y = tr.y + (ay + (by - ay) * u) * R + (h1(floor(lt * 20) + 7.7) - 0.5) * v("mikroHare")) }
                "overshootstop" -> { // 905: hareket durduğunda (hız eşiğin altına düşünce) son hız yönünde ön asma ve toparlanma
                    val src = lay(p, e, "kaynak") ?: l; val th = v("hizEsig"); val rec = max(0.01, v("toparlan")); var stopAt = -1.0; var vx = 0.0; var vy = 0.0
                    for (i in 0..40) { val tt = t - i / 60.0; if (tt <= src.start) break; val s = speed(src, tt); val sPrev = speed(src, tt - 1 / 60.0); if (s < th && sPrev >= th) { stopAt = tt; val (a, b) = pos(src, tt - 1 / 30.0); val (c, d) = pos(src, tt); vx = c - a; vy = d - b; break } }
                    if (stopAt >= 0) { val u = (t - stopAt) / rec; val m = hypot(vx, vy); if (m > 1e-6 && u in 0.0..1.0) { val k = sin(u * PI) * (1 - u) * v("onAsma"); tr = tr.copy(x = tr.x + vx / m * k, y = tr.y + vy / m * k) } } }
                "anticipation" -> { // 906: her hareket başlangıcından hemen önce ters yönde küçük hazırlık (keyframe'ler değişmez)
                    val ks = (l.x.k.orEmpty().map { it.t } + l.y.k.orEmpty().map { it.t }).distinct().sorted(); val D = max(0.01, v("hazirlikSure"))
                    for ((i, k0) in ks.withIndex()) { if (i + 1 >= ks.size) break; val u = (t - (k0 - D)) / D; if (u !in 0.0..1.0) continue
                        val (ax, ay) = pos(l, k0); val (bx, by) = pos(l, ks[i + 1]); val a = sin(u * PI) * v("miktar") / 100; tr = tr.copy(x = tr.x - (bx - ax) * a * 0.5, y = tr.y - (by - ay) * a * 0.5) } }
                "rhythmquant" -> { // 909: konum keyframe'leri ses başlangıçlarının alt bölümlerine çekilerek değerlendirilir
                    val src = lay(p, e, "ses") ?: p.layers.firstOrNull { it.type == "audio" } ?: continue; val sub = intArrayOf(1, 1, 2, 4, 8)[v("altBolu").roundToInt().coerceIn(0, 4)]
                    val beats = beats(src); if (beats.size < 2) continue; val grid = ArrayList<Double>(); for (i in 0 until beats.size - 1) for (s in 0 until sub) grid += beats[i] + (beats[i + 1] - beats[i]) * s / sub
                    fun snap(x: Double): Double { val g = grid.minByOrNull { abs(it - x) } ?: x; return x + (g - x) * v("guc") / 100 }
                    fun warp(a: Anim): Anim = a.k?.let { ks -> a.copy(k = ks.map { it.copy(t = snap(it.t)) }.sortedBy { it.t }) } ?: a
                    val nx = warp(l.x).at(t); val ny = warp(l.y).at(t); val k = 1 - v("yumusatm") / 200; tr = tr.copy(x = tr.x + (nx - l.x.at(t)) * k, y = tr.y + (ny - l.y.at(t)) * k) }
                "looplock" -> { // 912: döngü süresine göre tekrar; uç pozlar arasındaki fark döngüye yayılır (ek yeri kapanır)
                    val T = max(0.1, v("donguSure")); val lt = t - l.start; val u = ((lt % T) + T) % T; val tt = l.start + u; val k = v("duzeltme") / 100
                    val (x0, y0) = pos(l, l.start); val (x1, y1) = pos(l, l.start + T); val r0 = l.rotation.at(l.start); val r1 = l.rotation.at(l.start + T)
                    var nx = l.x.at(tt) - (x1 - x0) * (u / T) * k; var ny = l.y.at(tt) - (y1 - y0) * (u / T) * k
                    if (v("hizKili") >= 0.5) { val h = 1.0 / 60; val va = (l.x.at(l.start + h) - x0) / h; val vb = (x1 - l.x.at(l.start + T - h)) / h; nx -= (vb - va) * T * (u / T) * (1 - u / T) * 0.5 * k
                        val wa = (l.y.at(l.start + h) - y0) / h; val wb = (y1 - l.y.at(l.start + T - h)) / h; ny -= (wb - wa) * T * (u / T) * (1 - u / T) * 0.5 * k }
                    if (v("konumKili") >= 0.5) tr = tr.copy(x = tr.x - l.x.at(t) + nx, y = tr.y - l.y.at(t) + ny)
                    tr = tr.copy(rot = tr.rot - l.rotation.at(t) + l.rotation.at(tt) - (r1 - r0) * (u / T) * k) }
            }
        }
        return tr
    }

    /** 989 Kare Sonu Poz Tutma: poz anında durur, tutma süresince bekler, sonra çıkış yumuşatmasıyla kaldığı yerden sürer */
    private fun holdTime(e: Effect, l: Layer, t: Double): Double { val tp = e.value("pozZama", t); val hold = max(0.0, e.value("tutma", t)); val ex = max(0.0, e.value("cikisYumu", t)); val lt = t - l.start
        if (lt < tp) return t; if (lt < tp + hold) return l.start + tp; val u = lt - tp - hold; return l.start + tp + if (ex > 1e-3 && u < ex) u * u / (2 * ex) else u - ex / 2 }

    /** Ses başlangıçları (seviye zarfındaki yerel tepeler), katman başına önbellekli */
    private val beatCache = HashMap<String, List<Double>>()
    private fun beats(a: Layer): List<Double> = beatCache.getOrPut(a.id + a.src + a.start + a.srcIn) {
        val out = ArrayList<Double>(); var last = -1.0; val step = 0.01; var tt = a.start; var prev = 0.0
        while (tt < a.end && out.size < 2000) { val lv = AudioLevels.level(a, tt); var mean = 0.0; for (i in 1..25) mean += AudioLevels.level(a, tt - i * step); mean /= 25
            if (lv > mean * 1.4 + 0.02 && lv >= prev && tt - last > 0.18) { out += tt; last = tt }; prev = lv; tt += step }
        out
    }

    /** 918/919: üyelerin çakışmasız yerleşimi (kutuları ayrılana kadar itilir, en fazla "sınır" kadar); üye id → (dx, dy) */
    private val layoutCache = HashMap<String, Map<String, Pair<Double, Double>>>()
    fun layoutOffsets(p: Project, e: Effect, t: Double): Map<String, Pair<Double, Double>> {
        val key = if (e.type == "bubblelayout") "balonlar" else "etiketle"; val ms = ids(e, key).mapNotNull { id -> p.layers.find { it.id == id } }.filter { t >= it.start && t < it.end }
        val ck = e.id + "|" + t + "|" + ms.joinToString { it.id + it.x.at(t) + it.y.at(t) }; layoutCache[ck]?.let { return it }
        val gap = e.value(if (e.type == "bubblelayout") "enAzBosl" else "aralik", t); val lim = e.value(if (e.type == "bubblelayout") "bagUzun" else "tasimaSini", t)
        val x0 = ms.map { layerTransform(it, t).x }; val y0 = ms.map { layerTransform(it, t).y }; val hw = ms.map { val tr = layerTransform(it, t); it.w * abs(tr.scale) / 2 + gap / 2 }; val hh = ms.map { val tr = layerTransform(it, t); it.h * abs(tr.scale) / 2 + gap / 2 }
        val x = x0.toDoubleArray(); val y = y0.toDoubleArray()
        repeat(40) { for (i in ms.indices) for (j in i + 1 until ms.size) { val ox = hw[i] + hw[j] - abs(x[i] - x[j]); val oy = hh[i] + hh[j] - abs(y[i] - y[j]); if (ox <= 0 || oy <= 0) continue
            if (ox < oy) { val d = ox / 2 * (if (x[i] < x[j] || (x[i] == x[j] && i < j)) -1 else 1); x[i] += d; x[j] -= d } else { val d = oy / 2 * (if (y[i] < y[j] || (y[i] == y[j] && i < j)) -1 else 1); y[i] += d; y[j] -= d } }
            for (i in ms.indices) { val dx = x[i] - x0[i]; val dy = y[i] - y0[i]; val L = hypot(dx, dy); if (L > lim && L > 0) { x[i] = x0[i] + dx / L * lim; y[i] = y0[i] + dy / L * lim } } }
        val out = ms.indices.associate { ms[it].id to ((x[it] - x0[it]) to (y[it] - y0[it])) }; if (layoutCache.size > 256) layoutCache.clear(); layoutCache[ck] = out; return out
    }

    /** Diğer katmanlara uygulanan rig efektleri; h: efektin bulunduğu katman, l: dönüşümü hesaplanan katman */
    fun rig(p: Project, h: Layer, e: Effect, l: Layer, t: Double, loc0: TR, off: (Double, Double) -> Pair<Double, Double>): TR {
        var loc = loc0; fun v(k: String) = e.value(k, t)
        when (e.type) {
            "posehold" -> { if (e.c?.get("dondurulKatm") != l.id || l.id == h.id) return loc; val tt = holdTime(e, l, t); val a = layerTransform(l, tt); val b = layerTransform(l, t)
                val (lx, ly) = off(a.x - b.x, a.y - b.y); loc = loc.copy(x = loc.x + lx, y = loc.y + ly, rot = loc.rot + a.rot - b.rot, scale = loc.scale * (if (abs(b.scale) > 1e-6) a.scale / b.scale else 1.0)) }
            "bubblelayout", "labelavoid" -> { val o = layoutOffsets(p, e, t)[l.id] ?: return loc; val (lx, ly) = off(o.first, o.second); loc = loc.copy(x = loc.x + lx, y = loc.y + ly) }
            "slopeattach" -> { // 944: nesne yüzey şeklinin üst konturuna oturur; tabanı yerel eğime göre döner, normal yönünde ofset korunur
                if (e.c?.get("takipNesn") != l.id) return loc; val sf = lay(p, e, "yuzey") ?: return loc; if (sf.type != "shape") return loc
                val sw = worldTransform(p, sf, t); val pts = ShapeFx.sample(ShapeFx.path(sf, t), 160).map { q -> val r = sw.rot * PI / 180; val x = q[0] * sw.scale * sw.sx; val y = q[1] * sw.scale * sw.sy; (sw.x + x * cos(r) - y * sin(r)) to (sw.y + x * sin(r) + y * cos(r)) }
                val me = worldTransform(p, l, t); fun topY(x: Double): Double? { var best: Double? = null; for (i in pts.indices) { val a = pts[i]; val b = pts[(i + 1) % pts.size]; if ((a.first - x) * (b.first - x) > 0 || a.first == b.first) continue; val y = a.second + (b.second - a.second) * (x - a.first) / (b.first - a.first); if (best == null || y < best) best = y }; return best }
                val y0 = topY(me.x) ?: return loc; val h = 4.0; val ang = atan2((topY(me.x + h) ?: y0) - (topY(me.x - h) ?: y0), 2 * h); val sm = max(0.0, v("donusYumu")); var a2 = ang
                if (sm > 0.01) { var acc = 0.0; for (k in 0 until 5) { val tt = t - sm * k / 4; val mx = worldTransform(p, l, tt).x; val ya = topY(mx + h); val yb = topY(mx - h); acc += if (ya != null && yb != null) atan2(ya - yb, 2 * h) else ang }; a2 = acc / 5 }
                val off = l.h * abs(me.scale) / 2 + v("ofset"); val tx = me.x + sin(a2) * off; val ty = y0 - cos(a2) * off; val (lx, ly) = off(tx - me.x, ty - me.y)
                loc = loc.copy(x = loc.x + lx, y = loc.y + ly, rot = loc.rot + a2 * 180 / PI) }
            "bonepropagate" -> { // 945: ilk kemiğin dönüşü sonraki kemiklere gecikme ve azalmayla yayılır
                val bones = ids(e, "rig"); val i = bones.indexOf(l.id); if (i <= 0 || i > v("yayilimDeri").roundToInt()) return loc; val first = p.layers.find { it.id == bones[0] } ?: return loc
                val d = first.rotation.at(t - v("gecikme") * i) - first.rotation.at(first.start); loc = loc.copy(rot = loc.rot + d * (1 - v("azalma") / 100).pow(i)) }
            "footlock" -> { // 898: ayak zemine değince temas başlangıcındaki sahne x'inde sabit kalır
                if (e.c?.get("ayak") != l.id) return loc; val g = lay(p, e, "zemin"); val th = max(0.5, v("gecis"))
                fun bottom(tt: Double): Pair<Double, Double> { val w = worldTransform(p, l, tt); return w.x to w.y + l.h / 2 * abs(w.scale) }
                val gy = g?.let { val w = worldTransform(p, it, t); w.y - it.h / 2 * abs(w.scale) } ?: p.height * 0.9
                fun onGround(tt: Double) = abs(bottom(tt).second - gy) <= th
                if (!onGround(t)) return loc; var t0 = t; for (i in 1..120) { val tt = t - i / 60.0; if (tt < l.start || !onGround(tt)) break; t0 = tt }
                val dx = bottom(t0).first - bottom(t).first; val (lx, ly) = off(dx, 0.0); loc = loc.copy(x = loc.x + lx, y = loc.y + ly) }
            "stepcycle" -> { // 899: uzuvlar sırayla adım atar: basma fazında geri kayar, salınım fazında öne gider ve havalanır
                val limbs = ids(e, "rig"); val i = limbs.indexOf(l.id); if (i < 0) return loc; val T = max(0.1, v("adimSure")); val n = limbs.size
                val ph = (((t - h.start) / T + v("faz") / 100 + i.toDouble() / max(2, n)) % 1.0 + 1.0) % 1.0; val swing = ph < 0.5; val u = if (swing) ph * 2 else (ph - 0.5) * 2
                val x = if (swing) (u - 0.5) * v("adimBoyu") else (0.5 - u) * v("adimBoyu"); val y = if (swing) -sin(u * PI) * v("kaldirma") else 0.0
                val (lx, ly) = off(x, y); loc = loc.copy(x = loc.x + lx, y = loc.y + ly) }
            "irislock" -> { // 901: iris göz şeklinin (elips) içinde, kenar payı kadar içeride kalır
                if (e.c?.get("iris") != l.id) return loc; val eye = lay(p, e, "gozMask") ?: return loc; val ew = worldTransform(p, eye, t); val iw = worldTransform(p, l, t)
                val ax = max(1.0, eye.w * abs(ew.scale) / 2 - l.w * abs(iw.scale) / 2 - v("kenarPayi")); val ay = max(1.0, eye.h * abs(ew.scale) / 2 - l.h * abs(iw.scale) / 2 - v("kenarPayi"))
                val dx = iw.x - ew.x; val dy = iw.y - ew.y; val r = hypot(dx / ax, dy / ay); if (r <= 1) return loc
                val (lx, ly) = off(dx / r - dx, dy / r - dy); loc = loc.copy(x = loc.x + lx, y = loc.y + ly) }
            "exprweights" -> { // 902: ifade katmanları zamanla sırayla ağırlık alır (çapraz geçiş); ağırlıklar normalize
                val fs = ids(e, "ifadeSeki"); val i = fs.indexOf(l.id); if (i < 0 || fs.size < 2) return loc; val per = 1.5; val x = ((t - h.start) / per) % fs.size; val soft = max(0.02, v("yumusatm") / 100)
                fun w(j: Int): Double { var d = abs(x - j); d = min(d, fs.size - d); return (1 - sm((d - 0.5 + soft) / (2 * soft))).coerceIn(0.0, 1.0) }
                val sum = if (v("agirliklNormEt") >= 0.5) max(1e-6, fs.indices.sumOf { w(it) }) else 1.0; loc = loc.copy(opacity = loc.opacity * w(i) / sum) }
            "facecoords" -> { // 903: yüz parçası gövde küresinin yüzeyinde; gövde döndükçe konum, basıklık ve arka taraf görünürlüğü
                val ps = ids(e, "yuzParc"); if (l.id !in ps) return loc; val body = lay(p, e, "govde") ?: return loc; val bw = worldTransform(p, body, t); val b0 = worldTransform(p, body, body.start); val l0 = worldTransform(p, l, l.start)
                val R = max(1.0, body.w * abs(b0.scale) / 2); val dx = (l0.x - b0.x) / R; val dy = (l0.y - b0.y) / R
                val lon = asin(dx.coerceIn(-1.0, 1.0)) + v("yatayAci") * PI / 180; val lat = asin(dy.coerceIn(-1.0, 1.0)) + v("dikeyAci") * PI / 180
                val R1 = body.w * abs(bw.scale) / 2; val nx = bw.x + R1 * sin(lon) * cos(lat); val ny = bw.y + R1 * sin(lat); val vis = cos(lon) * cos(lat)
                val (lx, ly) = off(nx - (l0.x - b0.x + bw.x), ny - (l0.y - b0.y + bw.y)); loc = loc.copy(x = loc.x + lx, y = loc.y + ly, sx = loc.sx * max(0.05, abs(cos(lon))), sy = loc.sy * max(0.05, abs(cos(lat))),
                    opacity = if (v("arkaTaraGizl") >= 0.5 && vis < 0) 0.0 else loc.opacity) }
            "jointlimit" -> { // 904: eklem dönüşü en düşük–en yüksek arasında; sınıra yaklaşırken yumuşak
                val target = e.c?.get("eklem")?.takeIf { it.isNotBlank() } ?: h.id; if (target != l.id) return loc; val lo = min(v("enDusu"), v("enYuks")); val hi = max(v("enDusu"), v("enYuks")); val s = max(0.0, v("yumusakYakl"))
                fun soft(a: Double): Double { if (s < 1e-3) return a.coerceIn(lo, hi); return when { a > hi - s -> hi - s + s * tanh((a - (hi - s)) / s); a < lo + s -> lo + s - s * tanh(((lo + s) - a) / s); else -> a } }
                loc = loc.copy(rot = soft(loc.rot)) }
            "phasespread" -> { // 907: grup katmanlarının hareketi sıraya/konuma göre faz kaydırılır
                val g = ids(e, "grup"); val i = g.indexOf(l.id); if (i < 0) return loc; val mode = v("dagitim").roundToInt(); val layers = g.mapNotNull { id -> p.layers.find { it.id == id } }
                val key = when (mode) { 1 -> layers.sortedBy { it.x.at(it.start) }.indexOf(l).toDouble(); 2 -> layers.sortedBy { it.y.at(it.start) }.indexOf(l).toDouble()
                    3 -> { val cx = layers.map { it.x.at(it.start) }.average(); val cy = layers.map { it.y.at(it.start) }.average(); hypot(l.x.at(l.start) - cx, l.y.at(l.start) - cy) / 50 }; else -> i.toDouble() }
                val dur = max(0.1, l.end - l.start); var tt = t - key * v("fazFark") / 360 * min(1.0, dur / 2); if (v("uclarDong") >= 0.5) tt = l.start + (((tt - l.start) % dur) + dur) % dur
                val a = layerTransform(l, tt); val b = layerTransform(l, t); loc = loc.copy(x = loc.x + a.x - b.x, y = loc.y + a.y - b.y, rot = loc.rot + a.rot - b.rot, scale = loc.scale * (if (abs(b.scale) > 1e-6) a.scale / b.scale else 1.0)) }
            "speedpose" -> { // 908: efektin katmanının hızına göre bekleme / yavaş / hızlı poz katmanları (sırayla) görünür
                val ps = ids(e, "pozlar"); val i = ps.indexOf(l.id); if (i < 0) return loc; val g = max(0.0, v("gecis")); var s = 0.0; val S = if (g > 0.01) 6 else 1
                for (k in 0 until S) s += speed(h, t - g * k / max(1, S - 1)) / S
                val lvl = when { s < v("yavasEsik") -> s / max(1.0, v("yavasEsik")); s < v("hizliEsik") -> 1 + (s - v("yavasEsik")) / max(1.0, v("hizliEsik") - v("yavasEsik")); else -> 2.0 }
                val slot = min(i, 2); loc = loc.copy(opacity = loc.opacity * (1 - abs(lvl - slot)).coerceIn(0.0, 1.0)) }
            "motionmirror" -> { // 910: kaynak rig parçasının dönüş/konum değişimi, eksene göre aynalanarak hedefe aktarılır
                if (e.c?.get("hedefRig") != l.id) return loc; val src = lay(p, e, "kaynakRig") ?: return loc; val a = layerTransform(src, t); val b = layerTransform(src, src.start)
                val ax = v("eksen") * PI / 180; val dx = a.x - b.x; val dy = a.y - b.y; val c2 = cos(2 * ax); val s2 = sin(2 * ax); val mx = dx * c2 + dy * s2; val my = dx * s2 - dy * c2
                val dr = a.rot - b.rot; val (lx, ly) = off(mx, my); loc = loc.copy(x = loc.x + lx, y = loc.y + ly, rot = loc.rot + (if (v("aciyiTers") >= 0.5) -dr else dr) + v("ofset")) }
        }
        return loc
    }
}
