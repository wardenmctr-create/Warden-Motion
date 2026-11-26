package com.warden.motion.app.ui

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.gestures.awaitEachGesture
import androidx.compose.foundation.gestures.awaitFirstDown
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Slider
import androidx.compose.material3.SliderDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.draw.clipToBounds
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.layout.onSizeChanged
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.warden.motion.app.model.*
import kotlin.math.PI
import kotlin.math.abs
import kotlin.math.atan2
import kotlin.math.max
import kotlin.math.min
import kotlin.math.roundToInt
import kotlin.math.truncate

private val PANEL_BG = Color(0xFF1E2A55)
private val LCOL_LINE = Color(0xFF2C3E78)

@Composable
fun PanelHost(s: EditorState, layer: Layer, panel: Panel, W: Float, onClose: () -> Unit, onChangeFlag: () -> Unit, toast: (String) -> Unit, sheetMax: Float = 0f) {
    val h = (W * 0.56f).dp
    // Metni Düzenle ve CB Ayarları: eski uygulamadaki gibi alttan açılan sayfa (ekranın en çok yarısı)
    val mod = if (panel.isSheet()) Modifier.fillMaxWidth().heightIn(max = sheetMax.dp).shadow(18.dp, RoundedCornerShape(topStart = 18.dp, topEnd = 18.dp))
        .clip(RoundedCornerShape(topStart = 18.dp, topEnd = 18.dp)).background(PANEL_BG).tap { }.navigationBarsPadding()
        else Modifier.fillMaxWidth().height(h).background(PANEL_BG).navigationBarsPadding()
    Box(mod) {
        when (panel) {
            Panel.MOVE -> MovePanel(s, layer, onClose)
            Panel.COLOR -> ColorPanel(s, layer, onClose)
            Panel.OPACITY -> OpacityPanel(s, layer, onClose)
            Panel.VOLUME -> VolumePanel(s, layer, onClose)
            Panel.EFFECTS -> EffectsPanel(s, layer, onClose)
            Panel.TEXT -> TextPanel(s, layer, onClose)
            Panel.CB -> CBPanel(s, layer, onClose, onChangeFlag)
            Panel.SHAPE -> ShapeEditPanel(s, layer, onClose)
            Panel.ADD -> {}
        }
    }
}

/** Sol sütun: geri + (keyframe) + alt düğme */
@Composable
private fun LCol(onBack: () -> Unit, kf: Boolean? = null, onKf: () -> Unit = {}, bottom: (@Composable () -> Unit)? = null) {
    Column(Modifier.width(48.dp).fillMaxHeight().drawBehind { drawLine(LCOL_LINE, Offset(size.width, 0f), Offset(size.width, size.height), 1.dp.toPx()) }.padding(top = 6.dp),
        horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(4.dp)) {
        Box(Modifier.size(44.dp).tap(onClick = onBack), contentAlignment = Alignment.Center) { Ico("back", C.dText, 22.dp) }
        if (kf != null) Box(Modifier.size(44.dp).target("kf-btn", onKf).tap(onClick = onKf), contentAlignment = Alignment.Center) { KfIcon(kf) }
        Spacer(Modifier.weight(1f))
        bottom?.invoke()
    }
}

/** Keyframe düğmesi: yoksa içinde +, varsa − olan elmas */
@Composable
fun KfIcon(has: Boolean, enabled: Boolean = true) {
    Canvas(Modifier.size(26.dp)) {
        val k = size.width / 26f
        val col = if (!enabled) C.dDim else if (has) C.turq else C.dText
        drawPath(Path().apply { moveTo(13 * k, 2 * k); lineTo(24 * k, 13 * k); lineTo(13 * k, 24 * k); lineTo(2 * k, 13 * k); close() }, col)
        drawLine(C.dDeep, Offset(8.5f * k, 13 * k), Offset(17.5f * k, 13 * k), 2.4f * k, StrokeCap.Round)
        if (!has) drawLine(C.dDeep, Offset(13 * k, 8.5f * k), Offset(13 * k, 17.5f * k), 2.4f * k, StrokeCap.Round)
    }
}

private fun fmt2(n: Double) = "%.2f".format(n).replace('.', ',')
private fun fmtP(n: Double, step: Double) = (if (step >= 1) n.roundToInt().toString() else if (step < 0.01) "%.3f".format(n) else "%.2f".format(n)).replace('.', ',')

/** Kayar bir değer için, sürüklemeyi izleyen dokunuş (başlangıç değeri + piksel farkı) */
private fun Modifier.drag(key: Any?, onStart: (Offset) -> Unit, onMove: (Offset, Offset) -> Unit): Modifier = pointerInput(key) {
    awaitEachGesture {
        val d = awaitFirstDown(); d.consume()
        onStart(d.position)
        while (true) {
            val e = awaitPointerEvent(); val c = e.changes.first(); c.consume()
            if (!c.pressed) break
            onMove(d.position, c.position)
        }
    }
}

// ---------------------------------------------------------------------------------------------
// Taşı ve Çevir
// ---------------------------------------------------------------------------------------------
@Composable
private fun MovePanel(s: EditorState, layer: Layer, onClose: () -> Unit) {
    var mode by remember { mutableStateOf("move") }
    var curve by remember { mutableStateOf(false) }
    LaunchedEffect(mode) { s.kfFocus = listOf(when (mode) { "move" -> "pos"; "rotate" -> "rot"; else -> "scl" }) }
    DisposableEffect(Unit) { onDispose { s.kfFocus = null } }
    val t = s.time
    val props: List<String> = when (mode) { "move" -> listOf("x", "y"); "rotate" -> listOf("rotation"); else -> listOf("scale") }
    fun anim(l: Layer, pr: String) = when (pr) { "x" -> l.x; "y" -> l.y; "rotation" -> l.rotation; else -> l.scale }
    fun with(l: Layer, pr: String, a: Anim) = when (pr) { "x" -> l.copy(x = a); "y" -> l.copy(y = a); "rotation" -> l.copy(rotation = a); else -> l.copy(scale = a) }
    val hasKey = props.any { anim(layer, it).keyAt(t) != null }
    val animated = props.any { (anim(layer, it).k?.size ?: 0) > 0 }
    val toggle = {
        s.updateLayer(layer.id) { l ->
            val any = props.any { anim(l, it).keyAt(t) != null }
            var n = l
            for (pr in props) { val has = anim(l, pr).keyAt(t) != null; if (if (any) has else !has) n = with(n, pr, anim(l, pr).toggleKey(t)) }
            n
        }
    }
    Row(Modifier.fillMaxSize()) {
        LCol({ if (curve) curve = false else onClose() }, if (curve) null else hasKey, toggle) {
            if (!curve) Box(Modifier.size(44.dp).tap { curve = true }, contentAlignment = Alignment.Center) { Ico("curve", if (animated) C.dText else C.dDim, 20.dp) }
        }
        val cur = s.project.layers.find { it.id == layer.id } ?: layer
        Box(Modifier.weight(1f).fillMaxHeight().padding(horizontal = 4.dp, vertical = 8.dp).clip(RoundedCornerShape(6.dp)).background(Color(0xFF2A3560)), contentAlignment = Alignment.Center) {
            if (curve) CurveEditor(s, cur, props.first(), { l -> anim(l, props.first()) }) { l, e -> var n = l; for (pr in props) n = with(n, pr, setEase(anim(l, pr), t, e)); n }
            else {
                // Köşe işaretleri
                Canvas(Modifier.matchParentSize()) {
                    val m = 6.dp.toPx(); val L = 12.dp.toPx(); val w = 1.5.dp.toPx(); val c = Color(0xFF5C6E9E)
                    for ((x, y, dx, dy) in listOf(listOf(m, m, 1f, 1f), listOf(size.width - m, m, -1f, 1f), listOf(m, size.height - m, 1f, -1f), listOf(size.width - m, size.height - m, -1f, -1f))) {
                        drawLine(c, Offset(x, y), Offset(x + dx * L, y), w); drawLine(c, Offset(x, y), Offset(x, y + dy * L), w)
                    }
                }
                var v0 by remember { mutableStateOf(listOf(0.0)) }
                var lastAng by remember { mutableStateOf<Double?>(null) }
                var acc by remember { mutableDoubleStateOf(0.0) }
                val dens = androidx.compose.ui.platform.LocalDensity.current.density
                var padSize by remember { mutableStateOf(androidx.compose.ui.unit.IntSize.Zero) }
                Box(Modifier.matchParentSize().onSizeChanged { padSize = it }.drag(mode, onStart = {
                    s.checkpoint(); v0 = props.map { anim(cur, it).at(s.time) }; lastAng = null
                }) { st, now ->
                    val dx = (now.x - st.x) / dens; val dy = (now.y - st.y) / dens
                    when (mode) {
                        "move" -> s.updateLayer(layer.id, false) { it.copy(x = it.x.set(s.time, Math.round((v0[0] + dx * 1.5) * 100) / 100.0), y = it.y.set(s.time, Math.round((v0[1] + dy * 1.5) * 100) / 100.0)) }
                        "rotate" -> {
                            // Kadran: her hareketteki açı farkı toplanır (sınırsız tur)
                            val ang = atan2((now.y - padSize.height / 2f).toDouble(), (now.x - padSize.width / 2f).toDouble()) * 180 / PI
                            val la = lastAng
                            if (la == null) { lastAng = ang; acc = v0[0] } else {
                                var da = ang - la; if (da > 180) da -= 360 else if (da < -180) da += 360
                                lastAng = ang; acc += da
                                s.updateLayer(layer.id, false) { it.copy(rotation = it.rotation.set(s.time, Math.round(acc * 10) / 10.0)) }
                            }
                        }
                        else -> s.updateLayer(layer.id, false) { it.copy(scale = it.scale.set(s.time, max(0.01, Math.round((v0[0] + dx * 0.004) * 1000) / 1000.0))) }
                    }
                })
                when (mode) {
                    "move" -> {
                        Text("${fmt2(cur.x.at(t))}, ${fmt2(cur.y.at(t))}", fontSize = 11.sp, color = Color(0xFF6E7FAE), modifier = Modifier.align(Alignment.TopCenter).padding(top = 12.dp))
                        Text("Taşımak için kaydırın", fontSize = 14.sp, color = C.dText2)
                    }
                    "rotate" -> {
                        val rot = cur.rotation.at(t)
                        Box(Modifier.size(116.dp).border(2.dp, C.dDim, CircleShape), contentAlignment = Alignment.Center) {
                            Box(Modifier.size(116.dp).rotate(rot.toFloat())) { Box(Modifier.align(Alignment.CenterEnd).offset(x = 11.dp).size(22.dp).clip(CircleShape).background(Color(0xFFF7F8FA))) }
                            Row(Modifier.clip(RoundedCornerShape(4.dp)).background(C.dDeep).padding(horizontal = 10.dp, vertical = 2.dp), verticalAlignment = Alignment.Bottom) {
                                if (abs(rot) >= 360) Text("×${truncate(rot / 360).toInt()} ", fontSize = 12.sp, color = C.dText2)
                                Text("${(rot - truncate(rot / 360) * 360).roundToInt()}°", fontSize = 22.sp, fontWeight = FontWeight.SemiBold, color = C.turq)
                            }
                        }
                    }
                    else -> {
                        val sc = cur.scale.at(t)
                        Row(Modifier.align(Alignment.TopCenter).padding(top = 10.dp), verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                            Text("${(cur.w * sc).roundToInt()}px", fontSize = 13.sp, color = C.turq, modifier = Modifier.clip(RoundedCornerShape(4.dp)).background(C.dDeep).padding(horizontal = 8.dp, vertical = 2.dp))
                            Ico("link", C.dText2, 14.dp)
                            Text("${(cur.h * sc).roundToInt()}px", fontSize = 13.sp, color = C.turq, modifier = Modifier.clip(RoundedCornerShape(4.dp)).background(C.dDeep).padding(horizontal = 8.dp, vertical = 2.dp))
                        }
                        Canvas(Modifier.fillMaxSize().padding(top = 44.dp)) {
                            val off = ((sc * 250) % 12).toFloat() * density
                            var x = off; while (x < size.width) { drawLine(C.dDim, Offset(x, 0f), Offset(x, size.height), 1f); x += 12 * density }
                            drawLine(C.turq, Offset(size.width / 2, 0f), Offset(size.width / 2, size.height), 2 * density)
                        }
                    }
                }
            }
        }
        Column(Modifier.width(52.dp).fillMaxHeight().padding(top = 6.dp), horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(4.dp)) {
            if (curve) EASES.drop(1).forEach { e ->
                Box(Modifier.size(44.dp).tap { s.updateLayer(layer.id) { l -> var n = l; for (pr in props) n = with(n, pr, setEase(anim(l, pr), s.time, e.e)); n } }, contentAlignment = Alignment.Center) {
                    Canvas(Modifier.size(22.dp)) {
                        val k = size.width / 24f; val q = e.e!!
                        drawPath(Path().apply { moveTo(3 * k, 21 * k); cubicTo((3 + q[0] * 18).toFloat() * k, (21 - q[1] * 18).toFloat() * k, (3 + q[2] * 18).toFloat() * k, (21 - q[3] * 18).toFloat() * k, 21 * k, 3 * k) }, C.dText, style = Stroke(1.8f * k))
                    }
                }
            } else {
                listOf("move" to "move", "rotate" to "rotate", "scale" to "scale").forEach { (m, ic) ->
                    Box(Modifier.size(44.dp).clip(RoundedCornerShape(12.dp)).background(if (mode == m) Color(0xFF0D162F) else Color.Transparent).tap { mode = m }, contentAlignment = Alignment.Center) { Ico(ic, if (mode == m) C.turq else C.dText, 22.dp) }
                }
                Box(Modifier.size(44.dp), contentAlignment = Alignment.Center) { Ico("skew", C.dDim, 22.dp) }
            }
        }
    }
}

/** t'den önceki (ya da t'deki) keyframe: yumuşatma eğrisi bu keyframe'e yazılır */
fun segmentKey(a: Anim, t: Double): Key? {
    val k = a.k ?: return null
    if (k.size < 2) return null
    var best: Key? = null
    for (x in k) if (x.t <= t + EPS) best = x
    if (best == null || best === k.last()) best = k[max(0, k.size - 2)]
    return best
}
fun setEase(a: Anim, t: Double, e: List<Double>?): Anim {
    val seg = segmentKey(a, t) ?: return a
    return a.copy(k = a.k!!.map { if (it === seg) it.copy(e = e) else it })
}

/** Yumuşatma eğrisi: iki tutamaçlı cubic-bezier */
@Composable
private fun CurveEditor(s: EditorState, layer: Layer, prop: String, anim: (Layer) -> Anim, apply: (Layer, List<Double>?) -> Layer) {
    val t = s.time
    val seg = segmentKey(anim(layer), t)
    if (seg == null) { Text("Yumuşatma için bu özellikte en az iki keyframe olmalı.", fontSize = 14.sp, color = C.dText2, textAlign = TextAlign.Center, modifier = Modifier.padding(10.dp)); return }
    val ease = seg.e ?: listOf(0.25, 0.25, 0.75, 0.75)
    var which by remember { mutableIntStateOf(0) }
    var sz by remember { mutableStateOf(androidx.compose.ui.unit.IntSize(1, 1)) }
    Canvas(Modifier.aspectRatio(1f).fillMaxHeight().padding(4.dp).onSizeChanged { sz = it }
        .pointerInput(prop) {
            awaitEachGesture {
                val d = awaitFirstDown(); d.consume()
                val g = min(size.width, size.height) / 124f
                fun pos(px: Double, py: Double) = Offset((12 + px * 100).toFloat() * g, (12 + (1 - py) * 100).toFloat() * g)
                val cur = (s.project.layers.find { it.id == layer.id } ?: layer).let { anim(it) }.let { segmentKey(it, s.time)?.e ?: listOf(0.25, 0.25, 0.75, 0.75) }
                val p1 = pos(cur[0], cur[1]); val p2 = pos(cur[2], cur[3])
                which = if ((d.position - p1).getDistance() < (d.position - p2).getDistance()) 1 else 2
                s.checkpoint()
                while (true) {
                    val e = awaitPointerEvent(); val c = e.changes.first(); c.consume()
                    if (!c.pressed) break
                    val x = ((c.position.x / g - 12) / 100.0).coerceIn(0.0, 1.0); val y = (1 - (c.position.y / g - 12) / 100.0).coerceIn(-0.6, 1.6)
                    val l0 = s.project.layers.find { it.id == layer.id } ?: break
                    val e0 = segmentKey(anim(l0), s.time)?.e ?: listOf(0.25, 0.25, 0.75, 0.75)
                    val n = if (which == 1) listOf(Math.round(x * 1000) / 1000.0, Math.round(y * 1000) / 1000.0, e0[2], e0[3]) else listOf(e0[0], e0[1], Math.round(x * 1000) / 1000.0, Math.round(y * 1000) / 1000.0)
                    s.updateLayer(layer.id, false) { apply(it, n) }
                }
                which = 0
            }
        }) {
        val g = size.minDimension / 124f
        fun P(x: Float, y: Float) = Offset(x * g, y * g)
        for (i in 0..10) { drawLine(Color(0xFF34477A), P(12f + i * 10, 12f), P(12f + i * 10, 112f), .4f * g); drawLine(Color(0xFF34477A), P(12f, 12f + i * 10), P(112f, 12f + i * 10), .4f * g) }
        val p1 = P((12 + ease[0] * 100).toFloat(), (12 + (1 - ease[1]) * 100).toFloat()); val p2 = P((12 + ease[2] * 100).toFloat(), (12 + (1 - ease[3]) * 100).toFloat())
        drawLine(C.dText, P(12f, 112f), p1, .8f * g); drawLine(C.dText, P(112f, 12f), p2, .8f * g)
        drawPath(Path().apply { moveTo(12 * g, 112 * g); cubicTo(p1.x, p1.y, p2.x, p2.y, 112 * g, 12 * g) }, C.turq, style = Stroke(2 * g))
        drawCircle(C.dText, 2.5f * g, P(12f, 112f)); drawCircle(C.dText, 2.5f * g, P(112f, 12f))
        for (p in listOf(p1, p2)) { drawCircle(Color(0xFFF7F8FA), 6 * g, p); drawCircle(C.dDeep, 6 * g, p, style = Stroke(g)) }
    }
}

// ---------------------------------------------------------------------------------------------
// Renk ve Dolgu
// ---------------------------------------------------------------------------------------------
val SWATCHES = listOf("#E8333F", "#FF8A1F", "#F2E230", "#8A5A2B", "#7ED957", "#A23BD6", "#2B3BE8",
    "#4A90E2", "#22D3C5", "#B8F28A", "#000000", "#555E6E", "#9AA6B8", "#FFFFFF",
    "#1B2A55", "#2F7BF6", "#0E5A63", "#3FD0F0", "#F5DCA0", "#E84393", "#8F7CF0")
private fun ink(hex: String): Color { val c = colorOf(hex); return if (c.red * 255 * .299 + c.green * 255 * .587 + c.blue * 255 * .114 > 140) C.text else C.onPrimary }

@Composable
private fun ColorPanel(s: EditorState, layer: Layer, onClose: () -> Unit) {
    val grad = layer.fill2 != null && layer.grad != null
    val mode = if (layer.noFill == true) "none" else if (grad) "grad" else "solid"
    var slot by remember { mutableIntStateOf(1) }
    var pal by remember { mutableStateOf(false) }
    var picker by remember { mutableStateOf(false) }
    val cur = if (slot == 2 && grad) layer.fill2!! else layer.fill
    val setColor = { c: String, commit: Boolean -> s.updateLayer(layer.id, commit) { l -> if (slot == 2 && grad) l.copy(fill2 = c) else l.copy(fill = c) } }
    val setMode = { m: String ->
        pal = false; slot = 1
        s.updateLayer(layer.id) { l -> when (m) { "none" -> l.copy(noFill = true); "solid" -> l.copy(noFill = false, fill2 = null, grad = null); else -> l.copy(noFill = false, fill2 = l.fill2 ?: "#F2C230", grad = l.grad ?: Grad(0.0, -0.5, 0.0, 0.5), gtype = l.gtype ?: "linear") } }
    }
    val palette = @Composable {
        Row(Modifier.fillMaxWidth().height(IntrinsicSize.Min), horizontalArrangement = Arrangement.spacedBy(6.dp)) {
            Column(Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(6.dp)) {
                var hex by remember(cur) { mutableStateOf(cur.uppercase()) }
                val focus = LocalFocusManager.current
                BasicTextField(hex, { hex = it.uppercase().take(7); if (Regex("^#[0-9A-F]{6}$").matches(hex)) setColor(hex, true) }, singleLine = true,
                    textStyle = TextStyle(color = ink(cur), fontWeight = FontWeight.Bold, fontSize = 14.sp, textAlign = TextAlign.Center, fontFamily = Inter),
                    keyboardOptions = KeyboardOptions(imeAction = ImeAction.Done), keyboardActions = KeyboardActions(onDone = { focus.clearFocus() }),
                    modifier = Modifier.fillMaxWidth().height(30.dp).clip(RoundedCornerShape(4.dp)).background(colorOf(cur)).padding(top = 6.dp))
                SWATCHES.chunked(7).forEach { row ->
                    Row(horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                        row.forEach { c -> Box(Modifier.weight(1f).aspectRatio(1f).clip(RoundedCornerShape(3.dp)).background(colorOf(c)).border(2.dp, if (cur.uppercase() == c) C.turq else Color.Transparent, RoundedCornerShape(3.dp)).tap { setColor(c, true) }) }
                    }
                }
            }
            Box(Modifier.width(44.dp).fillMaxHeight().clip(RoundedCornerShape(8.dp)).background(C.dPanel2).tap { s.checkpoint(); picker = true }, contentAlignment = Alignment.Center) { Ico("bucket", C.dText, 20.dp) }
        }
    }
    Row(Modifier.fillMaxSize()) {
        LCol({ if (pal) pal = false else onClose() })
        Column(Modifier.weight(1f).fillMaxHeight().verticalScroll(rememberScrollState()).padding(start = 4.dp, end = 12.dp, top = 10.dp, bottom = 12.dp)) {
            Row(Modifier.fillMaxWidth().clip(RoundedCornerShape(8.dp)).background(C.dPanel2).padding(3.dp), horizontalArrangement = Arrangement.spacedBy(2.dp)) {
                listOf("none" to "nofill", "solid" to "bucket", "grad" to "", "img" to "image").forEach { (m, ic) ->
                    Box(Modifier.weight(1f).height(34.dp).clip(RoundedCornerShape(6.dp)).background(if (mode == m) C.text else Color.Transparent).tap(m != "img") { setMode(m) }, contentAlignment = Alignment.Center) {
                        if (m == "grad") Box(Modifier.size(22.dp, 12.dp).clip(RoundedCornerShape(2.dp)).background(Brush.horizontalGradient(listOf(Color(0xFF8FA6D6), Color(0xFFF7F8FA)))))
                        else Ico(ic, if (m == "img") C.dDim else if (mode == m) C.cyan else C.dText, 18.dp)
                    }
                }
            }
            Spacer(Modifier.height(8.dp))
            when {
                mode == "solid" -> palette()
                mode == "none" -> Text("Bu katmanın dolgusu yok.", color = C.dText2, fontSize = 13.sp, textAlign = TextAlign.Center, modifier = Modifier.fillMaxWidth().padding(vertical = 18.dp))
                pal -> palette()
                else -> {
                    Row(Modifier.fillMaxWidth().padding(bottom = 12.dp), horizontalArrangement = Arrangement.Center) {
                        for (gt in listOf("linear", "radial")) {
                            val on = (layer.gtype ?: "linear") == gt
                            Box(Modifier.padding(horizontal = 4.dp).size(44.dp, 30.dp).clip(RoundedCornerShape(6.dp)).background(C.dPanel2).border(2.dp, if (on) C.turq else Color.Transparent, RoundedCornerShape(6.dp)).tap { s.updateLayer(layer.id) { it.copy(gtype = gt) } }, contentAlignment = Alignment.Center) {
                                Box(Modifier.size(22.dp, 14.dp).clip(RoundedCornerShape(2.dp)).background(if (gt == "linear") Brush.horizontalGradient(listOf(Color.White, Color(0xFF4A5E8C))) else Brush.radialGradient(listOf(Color.White, Color(0xFF4A5E8C)))))
                            }
                        }
                    }
                    Box(Modifier.fillMaxWidth().height(34.dp).clip(RoundedCornerShape(17.dp)).background(Brush.horizontalGradient(listOf(colorOf(layer.fill), colorOf(layer.fill2))))) {
                        for (n in 1..2) Box(Modifier.align(if (n == 1) Alignment.CenterStart else Alignment.CenterEnd).padding(horizontal = 3.dp).size(28.dp).clip(CircleShape)
                            .background(colorOf(if (n == 1) layer.fill else layer.fill2)).border(3.dp, Color.White, CircleShape).tap { slot = n; pal = true })
                    }
                    Text("Uçlara dokunarak renk seç; yönü önizlemedeki noktaları sürükleyerek ayarla.", fontSize = 11.sp, color = C.dText2, textAlign = TextAlign.Center, modifier = Modifier.fillMaxWidth().padding(top = 8.dp))
                }
            }
        }
    }
    if (picker) ColorPickerDialog(cur, dark = true, onDismiss = { picker = false }) { setColor(it, false); picker = false }
}

// ---------------------------------------------------------------------------------------------
// Karıştırma ve Opaklık / Ses Düzeyi
// ---------------------------------------------------------------------------------------------
private val BLENDS = listOf("normal" to "Normal", "multiply" to "Çoğalt", "screen" to "Ekran", "overlay" to "Kaplama", "darken" to "Koyulaştır", "lighten" to "Açıklaştır", "color-dodge" to "Renk Soldurma", "difference" to "Fark")

@Composable
private fun DSlider(v: Float, range: ClosedFloatingPointRange<Float>, enabled: Boolean = true, modifier: Modifier = Modifier, onStart: () -> Unit = {}, onChange: (Float) -> Unit) {
    var dragging by remember { mutableStateOf(false) }
    Slider(v, { if (!dragging) { dragging = true; onStart() }; onChange(it) }, modifier, enabled = enabled, valueRange = range, onValueChangeFinished = { dragging = false },
        colors = SliderDefaults.colors(thumbColor = Color(0xFFF7F8FA), activeTrackColor = C.turq, inactiveTrackColor = C.dLine))
}

@Composable
private fun OpacityPanel(s: EditorState, layer: Layer, onClose: () -> Unit) {
    DisposableEffect(Unit) { s.kfFocus = listOf("op"); onDispose { s.kfFocus = null } }
    val ctx = LocalContext.current
    val t = s.time
    val v = layer.opacity.at(t)
    val has = layer.opacity.keyAt(t) != null
    val bm = layer.blend ?: "normal"
    Row(Modifier.fillMaxSize()) {
        LCol(onClose, has, { s.updateLayer(layer.id) { it.copy(opacity = it.opacity.toggleKey(s.time)) } })
        Column(Modifier.weight(1f).padding(start = 4.dp, end = 12.dp, top = 10.dp)) {
            Row(Modifier.horizontalScroll(rememberScrollState()).padding(bottom = 6.dp), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                BLENDS.forEach { (id, name) ->
                    Column(Modifier.width(58.dp).tap { s.updateLayer(layer.id) { it.copy(blend = id) } }, horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(4.dp)) {
                        val res = remember(id) { ctx.resources.getIdentifier("blend_" + id.replace("-", "_"), "drawable", ctx.packageName) }
                        Image(painterResource(res), null, Modifier.size(44.dp).clip(RoundedCornerShape(8.dp)).border(2.dp, if (bm == id) C.turq else Color.Transparent, RoundedCornerShape(8.dp)), contentScale = ContentScale.Crop)
                        Text(name, fontSize = 10.sp, color = if (bm == id) C.turq else C.dText2, maxLines = 1)
                    }
                }
            }
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(10.dp), modifier = Modifier.padding(top = 6.dp)) {
                Ico("opacity", C.dText2, 18.dp)
                DSlider(v.toFloat(), 0f..1f, modifier = Modifier.weight(1f), onStart = { s.checkpoint() }) { x -> s.updateLayer(layer.id, false) { it.copy(opacity = it.opacity.set(s.time, Math.round(x * 1000) / 1000.0)) } }
                Text("%.3f".format(v), fontSize = 12.sp, color = C.dText, modifier = Modifier.widthIn(min = 40.dp))
            }
        }
    }
}

@Composable
private fun VolumePanel(s: EditorState, layer: Layer, onClose: () -> Unit) {
    val v = layer.volume ?: 1.0
    val muted = layer.muted == true
    Row(Modifier.fillMaxSize()) {
        Column(Modifier.width(48.dp).fillMaxHeight().drawBehind { drawLine(LCOL_LINE, Offset(size.width, 0f), Offset(size.width, size.height), 1.dp.toPx()) }.padding(top = 6.dp), horizontalAlignment = Alignment.CenterHorizontally) {
            Box(Modifier.size(44.dp).tap(onClick = onClose), contentAlignment = Alignment.Center) { Ico("back", C.dText, 22.dp) }
            Box(Modifier.size(44.dp).tap { s.updateLayer(layer.id) { it.copy(muted = !(it.muted ?: false)) } }, contentAlignment = Alignment.Center) { Ico(if (muted) "volOff" else "music", if (muted) C.turq else C.dText, 22.dp) }
        }
        Column(Modifier.weight(1f).padding(start = 4.dp, end = 12.dp, top = 10.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                Ico("music", C.dText2, 18.dp)
                DSlider((v * 100).toFloat(), 0f..200f, !muted, Modifier.weight(1f), { s.checkpoint() }) { x -> s.updateLayer(layer.id, false) { it.copy(volume = x.roundToInt() / 100.0) } }
                Text(if (muted) "Sessiz" else "%${(v * 100).roundToInt()}", fontSize = 12.sp, color = C.dText)
            }
            Row(Modifier.padding(top = 10.dp), horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                listOf(0.5, 1.0, 1.5, 2.0).forEach { x ->
                    val on = !muted && abs(v - x) < 0.005
                    Text("%${(x * 100).toInt()}", fontSize = 13.sp, fontWeight = FontWeight.SemiBold, color = if (on) C.dDeep else C.dText, modifier = Modifier.clip(RoundedCornerShape(16.dp)).background(if (on) C.turq else Color(0xFF26386C)).tap { s.updateLayer(layer.id) { it.copy(volume = x, muted = false) } }.padding(horizontal = 12.dp, vertical = 6.dp))
                }
                Text("Sessiz", fontSize = 13.sp, fontWeight = FontWeight.SemiBold, color = if (muted) C.dDeep else C.dText, modifier = Modifier.clip(RoundedCornerShape(16.dp)).background(if (muted) C.turq else Color(0xFF26386C)).tap { s.updateLayer(layer.id) { it.copy(muted = !(it.muted ?: false)) } }.padding(horizontal = 12.dp, vertical = 6.dp))
            }
            if (layer.type == "video") Text("Videonun kendi sesi. Önizlemede oynatırken duyulur, dışa aktarınca videoya eklenir.", fontSize = 12.sp, color = C.dText2, modifier = Modifier.padding(top = 10.dp))
        }
    }
}

// ---------------------------------------------------------------------------------------------
// Efektler
// ---------------------------------------------------------------------------------------------
/** Parametrenin değerini t anında yazar (keyframe varsa o anda keyframe günceller) */
fun setFxParams(l: Layer, fxId: String, vals: Map<String, Double>, t: Double): Layer = l.copy(effects = l.effects.map { e ->
    if (e.id != fxId) e else {
        val v = (e.v ?: emptyMap()).toMutableMap()
        for ((k, n) in vals) v[k] = (v[k] ?: Anim(e.value(k, t))).set(t, n)
        val amt = vals["amount"]
        e.copy(v = v, amount = if (amt != null && v["amount"]?.k.isNullOrEmpty()) amt else e.amount)
    }
})

// ---------------------------------------------------------------------------------------------
// Metin, CB, Şekli Düzenle
// ---------------------------------------------------------------------------------------------
@Composable
private fun DHead(title: String, onBack: () -> Unit) {
    Row(Modifier.fillMaxWidth().padding(start = 4.dp, end = 8.dp, top = 4.dp), verticalAlignment = Alignment.CenterVertically) {
        Box(Modifier.size(44.dp).tap(onClick = onBack), contentAlignment = Alignment.Center) { Ico("back", C.dText, 22.dp) }
        Text(title, fontSize = 16.sp, fontWeight = FontWeight.SemiBold, color = C.dText)
    }
}

@Composable
private fun PropSlider(label: String, value: String, v: Float, range: ClosedFloatingPointRange<Float>, onStart: () -> Unit, onChange: (Float) -> Unit) {
    Column(Modifier.fillMaxWidth().padding(bottom = 6.dp)) {
        Row { Text(label, fontSize = 13.sp, color = C.dText, modifier = Modifier.weight(1f)); Text(value, fontSize = 13.sp, fontWeight = FontWeight.Bold, color = C.dText) }
        DSlider(v, range, onStart = onStart, onChange = onChange)
    }
}

fun Panel.isSheet() = this == Panel.TEXT || this == Panel.CB

@Composable
private fun TextPanel(s: EditorState, layer: Layer, onClose: () -> Unit) {
    Column(Modifier.fillMaxWidth()) {
        DHead("Metni Düzenle", onClose)
        Column(Modifier.fillMaxWidth().weight(1f, false).verticalScroll(rememberScrollState()).padding(start = 12.dp, end = 12.dp, top = 10.dp, bottom = 12.dp)) {
            var started by remember { mutableStateOf(false) }
            BasicTextField(layer.text ?: "", { v -> if (!started) { s.checkpoint(); started = true }; s.updateLayer(layer.id, false) { it.copy(text = v) } },
                textStyle = TextStyle(color = C.dText, fontSize = 15.sp, fontFamily = Inter), cursorBrush = androidx.compose.ui.graphics.SolidColor(C.turq),
                modifier = Modifier.fillMaxWidth().height(80.dp).clip(RoundedCornerShape(10.dp)).border(1.dp, C.dLine, RoundedCornerShape(10.dp)).background(C.dDeep).padding(10.dp))
            Spacer(Modifier.height(12.dp))
            PropSlider("Yazı boyutu", "${(layer.fontSize ?: 64.0).roundToInt()}", (layer.fontSize ?: 64.0).toFloat(), 12f..300f, { s.checkpoint() }) { v -> s.updateLayer(layer.id, false) { it.copy(fontSize = v.roundToInt().toDouble(), h = (v * 1.3).roundToInt().toDouble()) } }
            Swatches(layer.fill) { c -> s.updateLayer(layer.id) { it.copy(fill = c) } }
        }
    }
}

@Composable
fun Swatches(cur: String, onPick: (String) -> Unit) {
    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
        SWATCHES.chunked(8).forEach { row ->
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) { row.forEach { c -> Box(Modifier.weight(1f).aspectRatio(1f).clip(RoundedCornerShape(8.dp)).background(colorOf(c)).border(2.dp, if (cur.uppercase() == c) C.turq else Color.Transparent, RoundedCornerShape(8.dp)).tap { onPick(c) }) }; repeat(8 - row.size) { Spacer(Modifier.weight(1f)) } }
        }
    }
}

@Composable
private fun CBPanel(s: EditorState, layer: Layer, onClose: () -> Unit, onChangeFlag: () -> Unit) {
    val ctx = LocalContext.current
    val eyes = remember { Packs.ready(ctx).find { it.name == "Gözler" }?.items ?: emptyList() }
    Column(Modifier.fillMaxWidth()) {
        DHead("CB Ayarları", onClose)
        Column(Modifier.fillMaxWidth().weight(1f, false).verticalScroll(rememberScrollState()).padding(start = 12.dp, end = 12.dp, top = 10.dp, bottom = 12.dp)) {
            DBtn("Bayrağı Değiştir", ghost = true, icon = "flag", onClick = onChangeFlag)
            Spacer(Modifier.height(14.dp))
            PropSlider("Kontur kalınlığı", "${(layer.cb?.outline ?: 0.0).roundToInt()}", (layer.cb?.outline ?: 0.0).toFloat(), 0f..30f, { s.checkpoint() }) { v -> s.updateLayer(layer.id, false) { it.copy(cb = (it.cb ?: CbOpts()).copy(outline = v.roundToInt().toDouble())) } }
            Text("GÖZLER", fontSize = 12.sp, fontWeight = FontWeight.Bold, color = C.dText2, letterSpacing = 0.5.sp, modifier = Modifier.padding(top = 14.dp, bottom = 8.dp))
            val all = listOf<PackItem?>(null) + eyes
            all.chunked(4).forEach { row ->
                Row(Modifier.padding(bottom = 8.dp), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    row.forEach { e ->
                        Column(Modifier.weight(1f)) {
                            Box(Modifier.fillMaxWidth().aspectRatio(1f).clip(RoundedCornerShape(10.dp)).checker().border(2.dp, if (layer.cb?.eyes == e?.src) C.turq else Color.Transparent, RoundedCornerShape(10.dp))
                                .tap { s.updateLayer(layer.id) { it.copy(cb = CbOpts(it.cb?.outline ?: 6.0, e?.src)) } }.padding(6.dp), contentAlignment = Alignment.Center) {
                                if (e == null) Text("Yok", color = C.text2, fontSize = 13.sp) else AssetImg(e.src, Modifier.fillMaxSize())
                            }
                            if (e != null) Text(e.name, fontSize = 10.sp, color = C.dText2, maxLines = 1, textAlign = TextAlign.Center, modifier = Modifier.fillMaxWidth().padding(top = 3.dp))
                        }
                    }
                    repeat(4 - row.size) { Spacer(Modifier.weight(1f)) }
                }
            }
        }
    }
}

private val SHAPE_HELP = mapOf(
    "bar" to "Önizlemede uçtaki tutamaç uzunluğu, üstteki kalınlığı ayarlar.",
    "crescent" to "Önizlemede içteki turkuaz tutamacı kaydır: dışarı çekersen tam top, içeri itersen ince hilal olur. Kesiği büyütüp kenara alırsan yarım daire olur.",
    "star" to "Önizlemede turkuaz tutamaçla yıldızın içini derinleştir.",
    "roundrect" to "Önizlemede turkuaz tutamaçla köşeleri yuvarla.",
    "custom" to "Önizlemede her köşeyi (turkuaz noktalar) istediğin yere sürükle.",
)
private data class SP(val key: String, val label: String, val min: Double, val max: Double, val step: Double, val int: Boolean = false)
private val SHAPE_PARAMS = mapOf(
    "roundrect" to listOf(SP("rad", "Köşe yuvarlaklığı", 0.0, 0.5, 0.01)),
    "star" to listOf(SP("n", "Köşe sayısı", 3.0, 24.0, 1.0, true), SP("inner", "İç derinlik", 0.05, 0.95, 0.01)),
    "hexagon" to listOf(SP("n", "Kenar sayısı", 3.0, 24.0, 1.0, true)),
    "polygon" to listOf(SP("n", "Kenar sayısı", 3.0, 24.0, 1.0, true)),
    "plus" to listOf(SP("thick", "Kalınlık", 0.05, 0.95, 0.01)),
    "bar" to listOf(SP("round", "Yuvarlak uçlar", 0.0, 1.0, 1.0, true)),
    "crescent" to listOf(SP("cx", "Kesik yatay", -5.0, 5.0, 0.01), SP("cy", "Kesik dikey", -5.0, 5.0, 0.01), SP("r", "Kesik büyüklüğü", 0.1, 10.0, 0.01)),
)

@Composable
private fun Stepper(label: String, v: Int, min: Int, max: Int, onSet: (Int) -> Unit) {
    Row(Modifier.fillMaxWidth().heightIn(min = 46.dp), verticalAlignment = Alignment.CenterVertically) {
        Text(label, fontSize = 13.sp, color = C.dText, modifier = Modifier.weight(1f))
        Row(Modifier.clip(RoundedCornerShape(8.dp)).background(C.dPanel2), verticalAlignment = Alignment.CenterVertically) {
            Box(Modifier.size(38.dp).tap(v > min) { onSet(v - 1) }, contentAlignment = Alignment.Center) { Text("−", fontSize = 20.sp, color = if (v > min) C.dText else C.dDim) }
            Text("$v", fontSize = 15.sp, fontWeight = FontWeight.Bold, color = C.dText, modifier = Modifier.widthIn(min = 30.dp), textAlign = TextAlign.Center)
            Box(Modifier.size(38.dp).tap(v < max) { onSet(v + 1) }, contentAlignment = Alignment.Center) { Text("+", fontSize = 20.sp, color = if (v < max) C.dText else C.dDim) }
        }
    }
}

@Composable
private fun ShapeEditPanel(s: EditorState, layer: Layer, onClose: () -> Unit) {
    val kind = layer.shape ?: return
    val params = SHAPE_PARAMS[kind] ?: emptyList()
    val set = { key: String, v: Double, commit: Boolean -> s.updateLayer(layer.id, commit) { it.copy(sp = (it.sp ?: emptyMap()) + (key to v)) } }
    val pts = layer.pts ?: regularPts(5)
    Column(Modifier.fillMaxSize()) {
        DHead("Şekli Düzenle", onClose)
        Column(Modifier.fillMaxSize().verticalScroll(rememberScrollState()).padding(start = 12.dp, end = 12.dp, top = 6.dp, bottom = 12.dp)) {
            SHAPE_HELP[kind]?.let { Text(it, fontSize = 12.sp, color = C.dText2, modifier = Modifier.padding(bottom = 8.dp)) }
            params.forEach { pr ->
                val v = layer.sp(pr.key)
                when {
                    pr.int && pr.max - pr.min <= 1 -> Row(Modifier.fillMaxWidth().heightIn(min = 46.dp), verticalAlignment = Alignment.CenterVertically) {
                        Text(pr.label, fontSize = 13.sp, color = C.dText, modifier = Modifier.weight(1f))
                        Box(Modifier.size(42.dp, 24.dp).clip(RoundedCornerShape(12.dp)).background(if (v != 0.0) C.turq else C.dDim).tap { set(pr.key, if (v != 0.0) 0.0 else 1.0, true) }) {
                            Box(Modifier.align(if (v != 0.0) Alignment.CenterEnd else Alignment.CenterStart).padding(2.dp).size(20.dp).clip(CircleShape).background(Color(0xFFF7F8FA)))
                        }
                    }
                    pr.int -> Stepper(pr.label, v.roundToInt(), pr.min.toInt(), pr.max.toInt()) { set(pr.key, it.toDouble(), true) }
                    else -> PropSlider(pr.label, "%.2f".format(v).replace('.', ','), v.toFloat(), pr.min.toFloat()..pr.max.toFloat(), { s.checkpoint() }) { x -> set(pr.key, Math.round(x / pr.step) * pr.step, false) }
                }
            }
            if (kind == "crescent") Row(Modifier.padding(top = 6.dp), horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                listOf("Hilal" to mapOf("cx" to 0.3, "cy" to -0.1, "r" to 0.9), "Yarım daire" to mapOf("cx" to 0.0, "cy" to -4.5, "r" to 9.0), "Tam top" to mapOf("cx" to 1.5, "cy" to 0.0, "r" to 0.5)).forEach { (lb, m) ->
                    Text(lb, fontSize = 13.sp, fontWeight = FontWeight.SemiBold, color = C.dText2, modifier = Modifier.clip(RoundedCornerShape(17.dp)).background(C.dPanel2).tap { s.updateLayer(layer.id) { it.copy(sp = (it.sp ?: emptyMap()) + m) } }.padding(horizontal = 12.dp, vertical = 8.dp))
                }
            }
            if (kind == "custom") {
                Row(Modifier.fillMaxWidth().heightIn(min = 46.dp), verticalAlignment = Alignment.CenterVertically) {
                    Text("Köşe sayısı", fontSize = 13.sp, color = C.dText, modifier = Modifier.weight(1f))
                    Row(Modifier.clip(RoundedCornerShape(8.dp)).background(C.dPanel2), verticalAlignment = Alignment.CenterVertically) {
                        Box(Modifier.size(38.dp).tap(pts.size > 3) { s.updateLayer(layer.id) { it.copy(pts = pts.dropLast(1)) } }, contentAlignment = Alignment.Center) { Text("−", fontSize = 20.sp, color = C.dText) }
                        Text("${pts.size}", fontSize = 15.sp, fontWeight = FontWeight.Bold, color = C.dText, modifier = Modifier.widthIn(min = 30.dp), textAlign = TextAlign.Center)
                        Box(Modifier.size(38.dp).tap(pts.size < 40) { s.updateLayer(layer.id) { it.copy(pts = addVertex(pts)) } }, contentAlignment = Alignment.Center) { Text("+", fontSize = 20.sp, color = C.dText) }
                    }
                }
                DBtn("Düzgün çokgene çevir", ghost = true) { s.updateLayer(layer.id) { it.copy(pts = regularPts(pts.size)) } }
            }
            if (params.isEmpty() && kind != "custom") Text("Bu şeklin ayarı yok. Önizlemede köşelerden büyütüp kenarlardan genişlet/daralt.", fontSize = 12.sp, color = C.dText2)
        }
    }
}

