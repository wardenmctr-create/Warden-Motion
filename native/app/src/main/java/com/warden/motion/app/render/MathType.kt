package com.warden.motion.app.render

import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Path
import kotlin.math.max

/**
 * 916 Matematik İfade Dizimi: küçük dizgi motoru.
 * Desteklenen: a/b (kesir), x^2 ya da x^{n+1} (üs), x_i ya da x_{ij} (alt indis), sqrt(...) ya da √x (kök), (...) parantez (yüksekliğe göre büyür),
 * {...} gruplama, ² ³ gibi üst simgeler, ';' ya da satır sonu ile çok satır.
 */
object MathType {
    private abstract class Box { var w = 0f; var asc = 0f; var desc = 0f; abstract fun draw(c: Canvas, x: Float, y: Float, p: Paint) }
    private class Sym(val s: String, p: Paint) : Box() { init { w = p.measureText(s) + if (s in setOf("+", "−", "=", "-", "×", "÷", "<", ">", "≤", "≥")) p.textSize * 0.35f else 0f; val fm = p.fontMetrics; asc = -fm.ascent * 0.8f; desc = fm.descent * 0.8f }
        override fun draw(c: Canvas, x: Float, y: Float, p: Paint) { val pad = if (s in setOf("+", "−", "=", "-", "×", "÷", "<", ">", "≤", "≥")) p.textSize * 0.175f else 0f; c.drawText(if (s == "-") "−" else s, x + pad, y, p) } }
    private class Row(val items: List<Box>) : Box() { init { w = items.sumOf { it.w.toDouble() }.toFloat(); asc = items.maxOfOrNull { it.asc } ?: 0f; desc = items.maxOfOrNull { it.desc } ?: 0f }
        override fun draw(c: Canvas, x: Float, y: Float, p: Paint) { var cx = x; for (b in items) { b.draw(c, cx, y, p); cx += b.w } } }
    private class Scaled(val b: Box, val k: Float, val dy: Float) : Box() { init { w = b.w * k; asc = max(0f, b.asc * k - dy); desc = max(0f, b.desc * k + dy) }
        override fun draw(c: Canvas, x: Float, y: Float, p: Paint) { c.save(); c.translate(x, y + dy); c.scale(k, k); b.draw(c, 0f, 0f, p); c.restore() } }
    private class Frac(val n: Box, val d: Box, val size: Float) : Box() { val axis = size * 0.3f; val gap = size * 0.12f
        init { w = max(n.w, d.w) + size * 0.3f; asc = axis + gap + n.desc + n.asc; desc = -axis + gap + d.asc + d.desc }
        override fun draw(c: Canvas, x: Float, y: Float, p: Paint) { val ly = y - axis; n.draw(c, x + (w - n.w) / 2, ly - gap - n.desc, p); d.draw(c, x + (w - d.w) / 2, ly + gap + d.asc, p)
            val sw = p.strokeWidth; val st = p.style; p.style = Paint.Style.STROKE; p.strokeWidth = max(1f, size * 0.06f); c.drawLine(x + size * 0.08f, ly, x + w - size * 0.08f, ly, p); p.strokeWidth = sw; p.style = st } }
    private class Root(val b: Box, val size: Float) : Box() { init { w = b.w + size * 0.75f; asc = b.asc + size * 0.18f; desc = b.desc }
        override fun draw(c: Canvas, x: Float, y: Float, p: Paint) { val h = size * 0.55f; b.draw(c, x + size * 0.65f, y, p); val path = Path().apply { moveTo(x + size * 0.05f, y - h * 0.4f); lineTo(x + size * 0.2f, y - h * 0.55f); lineTo(x + size * 0.38f, y + b.desc); lineTo(x + size * 0.58f, y - asc); lineTo(x + w, y - asc) }
            val sw = p.strokeWidth; val st = p.style; p.style = Paint.Style.STROKE; p.strokeWidth = max(1f, size * 0.06f); p.strokeJoin = Paint.Join.ROUND; c.drawPath(path, p); p.strokeWidth = sw; p.style = st } }
    private class Paren(val b: Box, val size: Float) : Box() { val pw = size * 0.32f; init { w = b.w + pw * 2; asc = b.asc + size * 0.05f; desc = b.desc + size * 0.05f }
        override fun draw(c: Canvas, x: Float, y: Float, p: Paint) { b.draw(c, x + pw, y, p); val sw = p.strokeWidth; val st = p.style; p.style = Paint.Style.STROKE; p.strokeWidth = max(1f, size * 0.06f)
            val top = y - asc; val bot = y + desc; val mid = (top + bot) / 2
            c.drawPath(Path().apply { moveTo(x + pw * 0.8f, top); quadTo(x + pw * 0.1f, mid, x + pw * 0.8f, bot) }, p); c.drawPath(Path().apply { moveTo(x + w - pw * 0.8f, top); quadTo(x + w - pw * 0.1f, mid, x + w - pw * 0.8f, bot) }, p)
            p.strokeWidth = sw; p.style = st } }

    private class Parser(val s: String, val p: Paint) { var i = 0; val size = p.textSize
        fun peek() = if (i < s.length) s[i] else '\u0000'
        fun expr(stop: Char = '\u0000'): Box { val items = ArrayList<Box>(); while (i < s.length && peek() != stop && peek() != ')' && peek() != '}') { val a = factor(); if (peek() == '/') { i++; val b = factor(); items += Frac(strip(a), strip(b), size) } else items += a }; return Row(items) }
        fun strip(b: Box) = if (b is Paren) b.b else b
        fun factor(): Box { var b = atom(); while (true) { b = when (peek()) {
            '^' -> { i++; Row(listOf(b, Scaled(atom().let(::strip), 0.62f, -size * 0.42f))) }
            '_' -> { i++; Row(listOf(b, Scaled(atom().let(::strip), 0.62f, size * 0.2f))) }
            '²', '³', '¹', '⁴', '⁵', '⁶', '⁷', '⁸', '⁹', '⁰', 'ⁿ' -> { val d = "²³¹⁴⁵⁶⁷⁸⁹⁰ⁿ".indexOf(s[i]); i++; Row(listOf(b, Scaled(Sym("2314567890n"[d].toString(), p), 0.62f, -size * 0.42f))) }
            else -> return b } } }
        fun atom(): Box { val ch = peek()
            if (ch == ' ') { i++; return Sym(" ", p) }
            if (ch == '(') { i++; val b = expr(')'); if (peek() == ')') i++; return Paren(b, size) }
            if (ch == '{') { i++; val b = expr('}'); if (peek() == '}') i++; return b }
            if (ch == '√') { i++; return Root(strip(atom()), size) }
            if (s.startsWith("sqrt(", i)) { i += 5; val b = expr(')'); if (peek() == ')') i++; return Root(b, size) }
            if (ch.isDigit() || ch == '.') { val st = i; while (peek().isDigit() || peek() == '.' || peek() == ',') i++; return Sym(s.substring(st, i), p) }
            if (ch.isLetter()) { val st = i; i++; if (s.regionMatches(st, "sin", 0, 3) || s.regionMatches(st, "cos", 0, 3) || s.regionMatches(st, "log", 0, 3) || s.regionMatches(st, "tan", 0, 3)) i = st + 3; return Sym(s.substring(st, i), p) }
            i++; return Sym(if (ch == '*') "×" else ch.toString(), p) }
    }

    fun draw(c: Canvas, src: String, p: Paint, lineGap: Float) {
        p.isAntiAlias = true; p.textAlign = Paint.Align.LEFT
        val lines = src.split(';', '\n').map { it.trim() }.filter { it.isNotEmpty() }.map { Parser(it, p).expr() }
        val total = lines.sumOf { (it.asc + it.desc).toDouble() }.toFloat() + lineGap * (lines.size - 1); var y = -total / 2
        for (b in lines) { y += b.asc; b.draw(c, -b.w / 2, y, p); y += b.desc + lineGap }
    }
}
