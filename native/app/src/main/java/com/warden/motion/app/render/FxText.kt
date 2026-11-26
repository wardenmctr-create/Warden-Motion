package com.warden.motion.app.render

import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Path
import android.graphics.RectF
import com.warden.motion.app.model.Effect
import com.warden.motion.app.model.Layer
import com.warden.motion.app.model.fxMeta
import com.warden.motion.app.model.value
import kotlin.math.PI
import kotlin.math.abs
import kotlin.math.cos
import kotlin.math.exp
import kotlin.math.floor
import kotlin.math.max
import kotlin.math.min
import kotlin.math.pow
import kotlin.math.roundToInt
import kotlin.math.sin

/**
 * Metin efektleri (katalogda kind = "text"): yazı harf harf yerleştirilir, her harfe konum / açı / ölçek / opaklık / renk uygulanır.
 * Ayarlar rehberdeki anahtarlarla okunur.
 */
object FxText {
    private class G(val s: String, var x: Float, var y: Float, val w: Float, val line: Int, val idx: Int, val word: Int) {
        var dx = 0f; var dy = 0f; var rot = 0f; var sc = 1f; var a = 1f; var col: Int? = null; var sx = 1f
    }

    fun has(l: Layer) = l.effects.any { it.on != false && fxMeta(it.type).kind == "text" }

    private fun ease(k: Int, p: Double): Double = when (k) { 1 -> p; 2 -> { val c = 1.70158; 1 + (c + 1) * (p - 1).pow(3) + c * (p - 1).pow(2) }; else -> 1 - (1 - p).pow(3) }
    private fun h1(n: Double): Double { val x = sin(n * 127.1 + 311.7) * 43758.5453; return x - floor(x) }
    private fun graphemes(s: String): List<String> { val out = ArrayList<String>(); val it = java.text.BreakIterator.getCharacterInstance(); it.setText(s); var st = it.first(); var en = it.next()
        while (en != java.text.BreakIterator.DONE) { out += s.substring(st, en); st = en; en = it.next() }; return out }

    /** Katmanın yazısını efektlerle çizer. fp: hazır dolgu boyası (yazı tipi, boyut, renk) */
    fun draw(c: Canvas, l: Layer, fp: Paint, t: Double) {
        val lt = t - l.start; val dur = l.end - l.start
        val fx = l.effects.filter { it.on != false && fxMeta(it.type).kind == "text" }
        var text = l.text ?: ""
        // 1) Metni değiştirenler
        for (e in fx) {
            fun v(k: String) = e.value(k, t)
            when (e.type) {
                "counter" -> {
                    val p = if (v("otomatik") >= .5) (lt / max(0.01, v("sure"))).coerceIn(0.0, 1.0) else v("ilerleme") / 100
                    val x = v("baslangi") + (v("bitis") - v("baslangi")) * (1 - (1 - p).pow(3)); val dec = v("ondalik").roundToInt().coerceIn(0, 8)
                    val sym = java.text.DecimalFormatSymbols(java.util.Locale("tr"))
                    val f = java.text.DecimalFormat((if (v("binlikAyir") >= .5) "#,##0" else "0") + (if (dec > 0) "." + "0".repeat(dec) else ""), sym)
                    text = (e.c?.get("onEk") ?: "") + f.format(x) + (e.c?.get("sonEk") ?: "")
                }
                "timecode" -> {
                    val fps = max(1.0, v("kareHizi")); var tt = (if (v("zamanKayn") >= .5) lt else t) + v("baslangiZama")
                    if (v("geriSayi") >= .5) tt = max(0.0, v("bitisZama") - tt)
                    val sep = e.c?.get("ayirici") ?: ":"; val hh = (tt / 3600).toInt(); val mm = ((tt / 60) % 60).toInt(); val ss = (tt % 60).toInt(); val ff = ((tt % 1) * fps).toInt()
                    text = when (v("bicim").roundToInt()) { 1 -> "%02d$sep%02d".format(mm, ss); 2 -> "%.1f".format(tt); else -> "%02d$sep%02d$sep%02d$sep%02d".format(hh, mm, ss, ff) }
                }
                "scramble" -> {
                    val p = if (v("otomatik") >= .5) (lt / max(0.01, v("sure"))).coerceIn(0.0, 1.0) else v("ilerleme") / 100
                    val set = when (v("karakterSeti").roundToInt()) { 1 -> "0123456789"; 2 -> "ABCÇDEFGĞHIİJKLMNOÖPRSŞTUÜVYZ0123456789#%&*"; 3 -> e.c?.get("ozelKara") ?: "ABC012"; else -> "ABCÇDEFGĞHIİJKLMNOÖPRSŞTUÜVYZ" }
                    val gs = graphemes(text); val tick = floor(lt * max(0.5, v("degisimHizi")))
                    text = gs.mapIndexed { i, ch -> if (i < (p * gs.size).toInt() || (ch.isBlank() && v("bosluguKoru") >= .5)) ch else set[(h1(i * 3.1 + tick * 7.7 + v("tohum")) * set.length).toInt().coerceIn(0, set.length - 1)].toString() }.joinToString("")
                }
            }
        }
        var roll: Pair<Double, Int>? = null
        fx.find { it.type == "rollcounter" }?.let { e -> val num = Regex("-?\\d+(?:[.,]\\d+)?").find(text)?.value?.replace(',', '.')?.toDoubleOrNull()
            if (num != null) { val dec = e.value("ondalik", t).roundToInt().coerceIn(0, 6); val dur = max(0.1, abs(num).toString().length / max(0.1, e.value("hiz", t)) * 2); val p = (lt / dur).coerceIn(0.0, 1.0)
                val cur = num * (1 - (1 - p).pow(3)); roll = cur to dec; text = Regex("-?\\d+(?:[.,]\\d+)?").replaceFirst(text, String.format(java.util.Locale.US, "%0${num.toLong().toString().length + if (dec > 0) dec + 1 else 0}.${dec}f", floor(cur * 10.0.pow(dec)) / 10.0.pow(dec))) } }
        // 2) Yerleşim
        val lines = text.split("\n"); val gl = ArrayList<G>()
        var spacing = 0f; var wordSp = 0f
        fx.find { it.type == "spacing" }?.let { e -> val em = fp.textSize; spacing = (if (e.value("birim", t) >= .5) e.value("harfAral", t) / 100 * em else e.value("harfAral", t)).toFloat(); wordSp = e.value("kelimeAral", t).toFloat() }
        val lh = fp.textSize * 1.15f; val fm = fp.fontMetrics; val mid = -(fm.ascent + fm.descent) / 2
        var idx = 0; var word = 0
        lines.forEachIndexed { li, ln ->
            val gs = graphemes(ln); val ws = gs.map { fp.measureText(it) + spacing + if (it == " ") wordSp else 0f }
            val total = ws.sum() - spacing; var x = -total / 2; val y = (li - (lines.size - 1) / 2f) * lh + mid
            gs.forEachIndexed { i, s -> if (s == " ") word++; gl += G(s, x, y, ws[i] - spacing, li, idx++, word); x += ws[i] }
            word++
        }
        val n = max(1, gl.size)
        // 702 Dikey dizim: her satır bir sütun olur, harfler alt alta
        fx.find { it.type == "verticaltext" }?.let { e -> val up = e.value("dizim", t) >= 0.5; val colW = fp.textSize * e.value("satirAral", t).toFloat(); val rowH = fp.textSize * 1.05f
            val cols = gl.groupBy { it.line }; val nc = cols.size
            cols.forEach { (li, gs) -> val x0 = (li - (nc - 1) / 2f) * colW; gs.forEachIndexed { i, g -> val k = if (up) gs.size - 1 - i else i; g.x = x0 - g.w / 2; g.y = (k - (gs.size - 1) / 2f) * rowH + mid
                if (e.value("latinKaraDond", t) >= 0.5 && g.s.firstOrNull()?.let { it in 'A'..'z' } == true) g.rot += 90f } } }
        // 707 Dönen sayaç: rakamlar bir alttakine doğru kayar (tambur)
        roll?.let { (cur, dec) -> val digits = gl.filter { it.s.firstOrNull()?.isDigit() == true }; val nInt = digits.size - dec
            digits.forEachIndexed { i, g -> val place = (nInt - 1 - i).toDouble(); val frac = ((abs(cur) / 10.0.pow(place)) % 1.0); val f = if (place == 0.0 - dec || i == digits.size - 1) frac else (frac - 0.9).coerceAtLeast(0.0) * 10
                g.dy -= (f * lh * 0.9).toFloat(); if (f > 0.01) gl += G(((g.s.toInt() + 1) % 10).toString(), g.x, g.y + lh * 0.9f, g.w, g.line, g.idx, g.word).also { it.dy = g.dy } } }
        // 3) Harf efektleri
        for (e in fx) {
            fun v(k: String) = e.value(k, t)
            when (e.type) {
                "typewriter" -> {
                    val p = if (v("otomatik") >= .5) max(0.0, lt - v("gecikme")) * v("harfHizi") else v("ilerleme") / 100 * n
                    val unit = v("birim").roundToInt(); val shown = p
                    gl.forEach { g -> val k = when (unit) { 1 -> g.word.toDouble(); 2 -> g.line.toDouble(); else -> g.idx.toDouble() }; if (k >= floor(shown)) g.a = 0f }
                    if (v("imlec") >= .5 && (lt * 2).toInt() % 2 == 0) {
                        val last = gl.lastOrNull { it.a > 0 }; val cx = (last?.let { it.x + it.w } ?: gl.firstOrNull()?.x ?: 0f); val cy = last?.y ?: gl.firstOrNull()?.y ?: mid
                        val cp = Paint(fp).apply { color = parseCol(e.c?.get("imlecReng") ?: "#FFFFFF"); shader = null }; c.drawText(e.c?.get("imlecMetn") ?: "▏", cx, cy, cp)
                    }
                }
                "wavetext" -> { gl.forEach { g -> val ph = g.idx / max(1.0, v("dalgaBoyu")) * 2 * PI - lt * v("frekans") * 2 * PI + v("faz") * PI / 180; val a = v("aci") * PI / 180
                    val h = sin(ph) * v("yuksekli"); g.dx += (sin(a) * h).toFloat(); g.dy -= (cos(a) * h).toFloat(); if (v("harfleriDond") >= .5) g.rot += (cos(ph) * 20).toFloat() } }
                "charfade" -> {
                    val p = if (v("otomatik") >= .5) (lt / max(0.01, v("sure"))).coerceIn(0.0, 1.0) else v("ilerleme") / 100; val tr = v("harfGeci") / 100
                    gl.forEach { g -> val o = when (v("sira").roundToInt()) { 1 -> (n - 1 - g.idx).toDouble() / n; 2 -> h1(g.idx + v("tohum")); else -> g.idx.toDouble() / n }
                        val k = ((p * (1 + tr) - o) / max(tr, 0.01)).coerceIn(0.0, 1.0); g.a *= (v("baslangiOpak") / 100 + (1 - v("baslangiOpak") / 100) * k).toFloat() }
                }
                "textbounce" -> gl.forEach { g -> val ph = lt * v("frekans") * 2 * PI - (if (v("sira") >= 1.5) h1(g.idx.toDouble()) * 6 else g.idx * (if (v("sira").roundToInt() == 1) -1 else 1).toDouble()) * v("harfFazAdim") * PI / 180
                    val b = abs(sin(ph)).pow(1 + v("yercekimGoru") / 50); g.dy -= (b * v("yuksekli")).toFloat(); g.rot += (sin(ph) * v("donus")).toFloat() }
                "rainbowtext" -> gl.forEach { g -> val hue = ((v("baslangiTonu") + g.idx * v("harfTonAdim") + lt * v("hiz")) % 360 + 360) % 360
                    val rc = Color.HSVToColor(floatArrayOf(hue.toFloat(), (v("doygunlu") / 100).toFloat(), (v("parlakli") / 100).toFloat())); g.col = mixCol(rc, fp.color, v("orijinalRengKari") / 100) }
                "textshake" -> gl.forEach { g -> val x = lt * v("frekans"); val sm = v("yumusatm") / 100; val s = v("tohum") + g.idx * 13.0
                    val nz = { o: Double -> noise1(if (sm < .1) floor(x) else x, s + o) }; g.dx += (nz(1.0) * v("konumX")).toFloat(); g.dy += (nz(2.0) * v("konumY")).toFloat(); g.rot += (nz(3.0) * v("donus")).toFloat() }
                "texttransform" -> {
                    val p = if (v("otomatik") >= .5) (lt / max(0.01, v("sure"))).coerceIn(0.0, 1.0) else v("ilerleme") / 100; val del = v("parcaGeci") / 100
                    val unit = v("birim").roundToInt(); val cnt = max(1, when (unit) { 1 -> (gl.maxOfOrNull { it.word } ?: 0) + 1; 2 -> lines.size; else -> n })
                    gl.forEach { g -> val k0 = when (unit) { 1 -> g.word; 2 -> g.line; else -> g.idx }.toDouble() / cnt
                        var k = ((p * (1 + del) - k0 * del) / 1.0).coerceIn(0.0, 1.0); k = ease(v("egri").roundToInt(), k)
                        g.dx += ((1 - k) * v("baslangiKaymX")).toFloat(); g.dy += ((1 - k) * v("baslangiKaymY")).toFloat(); g.sc *= (v("baslangiOlce") / 100 + (1 - v("baslangiOlce") / 100) * k).toFloat()
                        g.rot += ((1 - k) * v("baslangiAcis")).toFloat(); g.a *= (v("baslangiOpak") / 100 + (1 - v("baslangiOpak") / 100) * k).toFloat() }
                }
                "textglitch" -> gl.forEach { g -> val tk = floor(lt * max(0.1, v("frekans")) * 4); val r = h1(g.idx * 2.3 + tk + v("tohum"))
                    if (r < v("bozulma") / 100) { g.dx += ((h1(g.idx + tk * 1.7) - 0.5) * 2 * v("kayma")).toFloat(); g.col = if (h1(tk + g.idx * 9.0) > .5) Color.rgb(255, 60, 120) else Color.rgb(60, 220, 255) } }
                "wordhighlight" -> { val words = (e.c?.get("sozcukle") ?: "").split(',', ' ', ';').map { it.trim().lowercase(java.util.Locale("tr")) }.filter { it.isNotEmpty() }
                    val byWord = gl.groupBy { it.word }; val col = parseCol(e.c?.get("renk") ?: "#F0C84B"); val sc = (v("vurguBuyu") / 100).toFloat()
                    byWord.forEach { (_, gs) -> val w = gs.joinToString("") { it.s }.trim().lowercase(java.util.Locale("tr")).trim(',', '.', '!', '?', ':', ';'); if (w.isEmpty() || w !in words) return@forEach
                        if (v("vurguArkaKutu") >= 0.5) { val fm2 = fp.fontMetrics; val r = RectF(gs.minOf { it.x } - 6f, gs.minOf { it.y } + fm2.ascent - 3f, gs.maxOf { it.x + it.w } + 6f, gs.maxOf { it.y } + fm2.descent + 3f)
                            c.drawRoundRect(r, 8f, 8f, Paint(Paint.ANTI_ALIAS_FLAG).apply { color = parseCol(e.c?.get("kutuReng") ?: "#173B69") }) }
                        gs.forEach { it.col = col; it.sc *= sc } } }
                "linereveal" -> { val dir = v("yon").roundToInt(); gl.forEach { g -> val st = g.line * v("satirGeci"); val k = ((lt - st) / max(0.01, v("acilisSure"))).coerceIn(0.0, 1.0); val e2 = (1 - (1 - k).pow(3)).toFloat()
                    when (dir) { 0 -> g.dx -= (1 - e2) * fp.textSize; 1 -> g.dx += (1 - e2) * fp.textSize; 2 -> g.dy -= (1 - e2) * fp.textSize * 0.8f; else -> g.dy += (1 - e2) * fp.textSize * 0.8f }; g.a *= e2 } }
                "textreveal" -> {
                    val p = if (v("otomatik") >= .5) (lt / max(0.01, v("sure"))).coerceIn(0.0, 1.0) else v("ilerleme") / 100; val del = v("harfGeci") / 100; val a = v("yon") * PI / 180
                    gl.forEach { g -> val k = ((p * (1 + del) - g.idx.toDouble() / n * del)).coerceIn(0.0, 1.0); val e2 = 1 - (1 - k).pow(3)
                        g.dx += (cos(a) * v("kayma") * (1 - e2)).toFloat(); g.dy += (sin(a) * v("kayma") * (1 - e2)).toFloat(); g.a *= k.toFloat().coerceIn(0f, 1f) }
                }
                "pathtext" -> {
                    val path = v("yol").roundToInt(); val R = v("yaricap"); val arc = v("yayAcis") * PI / 180; val a0 = v("baslangiAcis") * PI / 180
                    val tw = gl.sumOf { (it.w + v("harfAral")).toDouble() }; var acc = 0.0; val dirSign = if (v("tersYon") >= .5) -1 else 1
                    val cx = (v("merkezX") / 100 - 0.5) * l.w; val cy = (v("merkezY") / 100 - 0.5) * l.h
                    gl.forEach { g -> val u = (acc + g.w / 2) / max(1.0, tw); acc += g.w + v("harfAral")
                        val (px, py, ang) = when (path) {
                            1 -> { val th = a0 + (u - 0.5) * arc * dirSign; Triple(cx + cos(th) * R, cy + sin(th) * R * 0.6, th + PI / 2) }
                            2 -> { val x = (u - 0.5) * tw; Triple(cx + x, cy + sin(u * 2 * PI) * R * 0.3, kotlin.math.atan(cos(u * 2 * PI) * R * 0.3 * 2 * PI / max(tw, 1.0))) }
                            else -> { val th = a0 + u * 2 * PI * dirSign; Triple(cx + cos(th) * R, cy + sin(th) * R, th + PI / 2) }
                        }
                        g.dx += (px - (g.x + g.w / 2)).toFloat(); g.dy += (py - g.y).toFloat(); if (v("yolaDond") >= .5) g.rot += Math.toDegrees(ang).toFloat() }
                }
            }
        }
        // 4) Balon / etiket / altyazı kutuları (yazının arkasına)
        for (e in fx) {
            fun v(k: String) = e.value(k, t)
            when (e.type) {
                "cbbubble" -> drawBubble(c, e, gl, fp, t, l)
                "cblabel" -> { val b = bounds(gl, fp); val pad = v("icBosl").toFloat(); val bg = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = parseCol(e.c?.get("arkaPlan") ?: "#14263F") }
                    val ox = v("etiketKaymX").toFloat(); val oy = v("etiketKaymY").toFloat(); val r = RectF(b.left - pad + ox, b.top - pad + oy, b.right + pad + ox, b.bottom + pad + oy)
                    if (v("baglantiCizg") >= .5) { val lp = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = parseCol(e.c?.get("cizgiReng") ?: "#FFFFFF"); strokeWidth = v("cizgiKali").toFloat(); style = Paint.Style.STROKE }
                        val ax = ((v("bagliNoktX") / 100 - 0.5) * l.w).toFloat(); val ay = ((v("bagliNoktY") / 100 - 0.5) * l.h).toFloat(); c.drawLine(ax, ay, r.centerX(), r.bottom, lp); c.drawCircle(ax, ay, v("cizgiKali").toFloat() * 2, lp.apply { style = Paint.Style.FILL }) }
                    c.drawRoundRect(r, pad, pad, bg); gl.forEach { it.dx += ox; it.dy += oy } }
                "cbcaption" -> {
                    val p = if (v("otomatik") >= .5) (lt / max(0.01, dur)).coerceIn(0.0, 1.0) else v("ilerleme") / 100
                    val words = (gl.maxOfOrNull { it.word } ?: 0) + 1; val cur = min(words - 1, (p * words).toInt())
                    val act = parseCol(e.c?.get("aktifRenk") ?: "#55AAFF"); val pas = parseCol(e.c?.get("pasifRenk") ?: "#FFFFFF")
                    val b = bounds(gl, fp); val pad = v("icBosl").toFloat(); val bx = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = parseCol(e.c?.get("kutuReng") ?: "#122039"); alpha = (v("kutuOpak") / 100 * 255).toInt() }
                    c.drawRoundRect(RectF(b.left - pad, b.top - pad, b.right + pad, b.bottom + pad), v("kose").toFloat(), v("kose").toFloat(), bx)
                    gl.forEach { g -> if (g.word == cur) { g.col = act; val k = (p * words - cur).coerceIn(0.0, 1.0); g.sc *= (1 + v("yaylanma") / 100 * sin(k * PI)).toFloat() } else g.col = pas }
                }
            }
        }
        // 5) Çiz
        val p2 = Paint(fp)
        for (g in gl) {
            if (g.a <= 0.003 || g.s.isBlank()) continue
            c.save(); c.translate(g.x + g.w / 2 + g.dx, g.y + g.dy - mid * 0.35f); c.rotate(g.rot); c.scale(g.sc * g.sx, g.sc)
            p2.set(fp); p2.textAlign = Paint.Align.CENTER; g.col?.let { p2.shader = null; p2.color = it }; p2.alpha = (fp.alpha * g.a).toInt().coerceIn(0, 255)
            c.drawText(g.s, 0f, mid * 0.35f, p2); c.restore()
        }
    }

    private fun bounds(gl: List<G>, fp: Paint): RectF {
        if (gl.isEmpty()) return RectF(-10f, -10f, 10f, 10f); val fm = fp.fontMetrics
        val l = gl.minOf { it.x + it.dx }; val r = gl.maxOf { it.x + it.w + it.dx }; val top = gl.minOf { it.y + it.dy } + fm.ascent * 0.85f; val bot = gl.maxOf { it.y + it.dy } + fm.descent
        return RectF(l, top, r, bot)
    }

    private fun drawBubble(c: Canvas, e: Effect, gl: List<G>, fp: Paint, t: Double, l: Layer) {
        fun v(k: String) = e.value(k, t)
        val b = bounds(gl, fp); val pad = v("icBosl").toFloat(); val r = RectF(b.left - pad, b.top - pad, b.right + pad, b.bottom + pad)
        val fill = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = parseCol(e.c?.get("dolgu") ?: "#FFFFFF") }
        val st = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = parseCol(e.c?.get("konturReng") ?: "#111111"); style = Paint.Style.STROKE; strokeWidth = v("kontur").toFloat(); strokeJoin = Paint.Join.ROUND }
        val tx = ((v("kuyrukHedeX") / 100 - 0.5) * max(l.w, r.width().toDouble())).toFloat(); val ty = (r.bottom + max(30f, pad * 2)).coerceAtLeast(((v("kuyrukHedeY") / 100 - 0.5) * l.h).toFloat())
        val kind = v("bicim").roundToInt(); val path = Path(); val rad = v("koseYari").toFloat()
        if (kind == 1) { path.addOval(r, Path.Direction.CW); for (i in 0..2) { val k = i / 3f; val cx = r.centerX() + (tx - r.centerX()) * (0.55f + k * 0.4f); val cy = r.bottom + (ty - r.bottom) * (0.3f + k * 0.6f); path.addCircle(cx, cy, (pad * 0.5f) * (1 - k * 0.6f), Path.Direction.CW) } }
        else {
            path.addRoundRect(r, if (kind == 2) 2f else rad, if (kind == 2) 2f else rad, Path.Direction.CW)
            if (kind == 0) { val w = v("kuyrukGeni").toFloat() / 2; val bx = r.centerX().coerceIn(r.left + rad + w, r.right - rad - w)
                val tail = Path().apply { moveTo(bx - w, r.bottom - 1); lineTo(tx, ty); lineTo(bx + w, r.bottom - 1); close() }; path.op(tail, Path.Op.UNION) }
        }
        c.drawPath(path, fill); if (v("kontur") > 0) c.drawPath(path, st)
    }

    private fun mixCol(a: Int, b: Int, k: Double): Int { val kk = k.coerceIn(0.0, 1.0)
        fun ch(s: Int) = (((a shr s) and 255) * (1 - kk) + ((b shr s) and 255) * kk).toInt()
        return Color.argb(255, ch(16), ch(8), ch(0)) }
}
