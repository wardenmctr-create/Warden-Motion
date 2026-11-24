package com.warden.motion.app.ui

import android.graphics.Bitmap
import androidx.activity.compose.BackHandler
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.gestures.awaitEachGesture
import androidx.compose.foundation.gestures.awaitFirstDown
import androidx.compose.foundation.gestures.scrollBy
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.clipToBounds
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.drawscope.drawIntoCanvas
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.graphics.nativeCanvas
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.input.pointer.PointerEventPass
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.input.pointer.positionChange
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.layout.onSizeChanged
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.IntSize
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.zIndex
import com.warden.motion.app.data.Store
import com.warden.motion.app.model.*
import com.warden.motion.app.render.LayerThumbs
import com.warden.motion.app.render.TR
import com.warden.motion.app.render.drawMotionPath
import com.warden.motion.app.render.drawSelection
import com.warden.motion.app.render.hitTest
import com.warden.motion.app.render.parentWorld
import com.warden.motion.app.render.pickHandle
import com.warden.motion.app.render.toLocal
import com.warden.motion.app.render.worldTransform
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import kotlin.math.PI
import kotlin.math.abs
import kotlin.math.atan2
import kotlin.math.cos
import kotlin.math.exp
import kotlin.math.hypot
import kotlin.math.max
import kotlin.math.min
import kotlin.math.roundToInt
import kotlin.math.sin

enum class Panel(val title: String) { ADD(""), MOVE("Taşı ve Çevir"), COLOR("Renk ve Dolgu"), OPACITY("Karıştırma ve Opaklık"), EFFECTS("Efektler"), CB("CB Ayarları"), TEXT("Metni Düzenle"), SHAPE("Şekli Düzenle"), VOLUME("Ses Düzeyi") }

private const val PPS_MIN = 15f
private const val PPS_MAX = 1200f
private val BLUES = listOf(0xFF3FB4DA to 0xFF3B7FE0, 0xFF5BD0E8 to 0xFF2FA6D6, 0xFF4C8DF0 to 0xFF3A5FD8, 0xFF2FC4C8 to 0xFF2E8FC8, 0xFF6FA8F5 to 0xFF4F7CE8)
private val PURPLES = listOf(0xFF7B4FD6 to 0xFF5A36B8, 0xFFA066E0 to 0xFF7E44C8, 0xFF6248C8 to 0xFF4430A6, 0xFFB57AE6 to 0xFF9150CC, 0xFF8A5CF0 to 0xFF6C3FD6)
private fun Layer.isMedia() = (type == "image" || type == "video" || type == "cb") && src != null

@Composable
fun EditorScreen(initial: Project, onClose: () -> Unit) {
    val ctx = LocalContext.current
    val store = remember { Store.get(ctx) }
    val scope = rememberCoroutineScope()
    val s = remember(initial.id) { EditorState(initial, store, scope) }
    val r = LocalRenderer.current
    val ver by r.version.collectAsState()
    val lite by store.lite.collectAsState()
    val liteCfg by store.liteCfg.collectAsState()
    val perf = if (lite) LITE_DEFAULT + liteCfg else FULL_QUALITY
    val haptic = LocalHapticFeedback.current
    val dens = LocalDensity.current

    val p = s.project
    val sel = s.sel
    val dur = p.duration
    var panel by remember { mutableStateOf<Panel?>(null) }
    var addTab by remember { mutableStateOf<String?>(null) }
    var replaceFlagOf by remember { mutableStateOf<String?>(null) }
    var loop by remember { mutableStateOf(true) }
    var menu by remember { mutableStateOf(false) }
    var mmenu by remember { mutableStateOf(false) }
    var projMenu by remember { mutableStateOf(false) }
    var pick by remember { mutableStateOf<String?>(null) }
    var exDlg by remember { mutableStateOf(false) }
    var toast by remember { mutableStateOf("") }
    var toastN by remember { mutableIntStateOf(0) }
    val show: (String) -> Unit = { m -> toast = m; toastN++ }
    LaunchedEffect(toastN) { if (toast.isNotEmpty()) { delay(2600); toast = "" } }
    var PPS by remember { mutableFloatStateOf(100f) }
    val tickStep = listOf(1, 2, 3, 5, 6, 10, 15, 30, 60).filter { p.fps % it == 0 || it >= p.fps }.firstOrNull { it * PPS / p.fps >= 6 } ?: p.fps

    DisposableEffect(Unit) { onDispose { s.flush() } }
    val close = { s.playing = false; s.flush(); onClose() }

    // ---------- Geri tuşu ----------
    BackHandler {
        when {
            exDlg -> exDlg = false
            mmenu -> mmenu = false
            s.multi != null -> s.multi = null
            pick != null -> pick = null
            menu || projMenu -> { menu = false; projMenu = false }
            panel != null -> { panel = null; replaceFlagOf = null }
            s.selectedId != null -> s.selectedId = null
            else -> close()
        }
    }

    // ---------- Oynatma ----------
    LaunchedEffect(s.playing) {
        if (!s.playing) { s.time = (s.time * s.project.fps).roundToInt().toDouble() / s.project.fps; return@LaunchedEffect }
        var last = withFrameNanos { it }
        while (isActive && s.playing) {
            val now = withFrameNanos { it }
            var t = s.time + (now - last) / 1e9
            last = now
            val d = s.project.duration
            if (t >= d) { if (loop) t = 0.0 else { s.time = d; s.playing = false; break } }
            s.time = t
        }
    }

    fun linkParent(childId: String, parentId: String?) {
        s.update { pp ->
            val child = pp.layers.first { it.id == childId }
            val w = worldTransform(pp, child, s.time)
            val pw = parentId?.let { id -> worldTransform(pp, pp.layers.first { it.id == id }, s.time) } ?: com.warden.motion.app.render.IDENT
            val loc = toLocal(pw, w)
            pp.copy(layers = pp.layers.map { if (it.id == childId) it.copy(parent = parentId, x = Anim(loc.x), y = Anim(loc.y), rotation = Anim(loc.rot), scale = Anim(loc.scale)) else it })
        }
        show(if (parentId != null) "Artık takip ediyor. Ebeveyni hareket ettirince bu da hareket eder." else "Takip bırakıldı.")
    }
    fun isAncestor(maybeAnc: String, id: String): Boolean {
        var cur = p.layers.find { it.id == id }
        repeat(10) { val par = cur?.parent ?: return false; if (par == maybeAnc) return true; cur = p.layers.find { it.id == par } }
        return false
    }
    fun trim(kind: String) {
        val l = sel ?: return
        val t = s.time
        if (t <= l.start || t >= l.end) { show("Oynatma çizgisini katmanın üstüne getir."); return }
        when (kind) {
            "start" -> s.updateLayer(l.id) { it.copy(start = t) }
            "end" -> s.updateLayer(l.id) { it.copy(end = t) }
            else -> s.update { pp ->
                val i = pp.layers.indexOfFirst { it.id == l.id }
                val ls = pp.layers.toMutableList()
                ls[i] = l.copy(end = t); ls.add(i + 1, l.copy(id = uid(), start = t, name = l.name + " (2)"))
                pp.copy(layers = ls)
            }
        }
    }
    fun placeWorld(ids: List<String>, fn: (Layer, TR) -> Pair<Double?, Double?>) {
        s.update { pp ->
            pp.copy(layers = pp.layers.map { l ->
                if (l.id !in ids) return@map l
                val w = worldTransform(pp, l, s.time); val pw = parentWorld(pp, l, s.time)
                val (nx, ny) = fn(l, w)
                val loc = toLocal(pw, w.copy(x = nx ?: w.x, y = ny ?: w.y))
                l.copy(x = l.x.set(s.time, loc.x.roundToInt().toDouble()), y = l.y.set(s.time, loc.y.roundToInt().toDouble()))
            })
        }
    }
    val rows = p.layers.reversed()
    fun multiAction(kind: String) {
        val ids = s.multi ?: emptyList()
        mmenu = false
        when (kind) {
            "mask", "exclude" -> {
                if (ids.size < 2) { show("En az iki katman seç."); return }
                val top = p.layers.map { it.id }.filter { it in ids }.last()
                s.update { pp -> pp.copy(layers = pp.layers.map { l -> if (l.id == top) l.copy(hidden = true, name = if ("Maske" in l.name) l.name else "${l.name} (Maske)") else if (l.id in ids) l.copy(mask = top, maskInvert = kind == "exclude") else l }) }
                s.multi = null
                show(if (kind == "mask") "Maskeleme grubu oluşturuldu." else "Hariç tutma grubu oluşturuldu.")
            }
            "cv" -> placeWorld(ids) { _, _ -> null to p.height / 2.0 }
            "ch" -> placeWorld(ids) { _, _ -> p.width / 2.0 to null }
            "dv", "dh" -> {
                val ws = ids.map { id -> id to worldTransform(p, p.layers.first { it.id == id }, s.time) }.sortedBy { if (kind == "dv") it.second.y else it.second.x }
                val lo = if (kind == "dv") ws.first().second.y else ws.first().second.x; val hi = if (kind == "dv") ws.last().second.y else ws.last().second.x
                val pos = ws.mapIndexed { i, (id, _) -> id to lo + (hi - lo) * i / max(1, ws.size - 1) }.toMap()
                placeWorld(ids) { l, _ -> if (kind == "dv") null to pos[l.id] else pos[l.id] to null }
            }
            "dt" -> {
                val order = rows.map { it.id }.filter { it in ids }
                s.update { pp ->
                    var t0 = order.minOf { id -> pp.layers.first { it.id == id }.start }
                    val starts = HashMap<String, Double>()
                    for (id in order) { val l = pp.layers.first { it.id == id }; starts[id] = t0; t0 += l.end - l.start }
                    pp.copy(layers = pp.layers.map { l -> starts[l.id]?.let { st -> l.copy(start = st, end = st + (l.end - l.start)) } ?: l })
                }
            }
        }
    }
    val openAdd = { tab: String? -> addTab = tab; replaceFlagOf = null; panel = Panel.ADD; s.playing = false }

    BoxWithConstraints(Modifier.fillMaxSize().background(C.dBg)) {
        val W = maxWidth.value
        val wd = { f: Float -> (W * f).dp }
        Column(Modifier.fillMaxSize().statusBarsPadding()) {
            // ---------- Üst çubuk ----------
            Row(Modifier.fillMaxWidth().height(wd(0.117f)).background(C.dBar).padding(horizontal = 4.dp), verticalAlignment = Alignment.CenterVertically) {
                val ib = @Composable { icon: String, label: String, size: Float, stroke: Float, tint: Color, on: () -> Unit ->
                    Box(Modifier.width(wd(0.12f)).fillMaxHeight().tap(onClick = on), contentAlignment = Alignment.Center) { Ico(icon, tint, size.dp, stroke) }
                }
                val m = s.multi
                when {
                    m != null -> Row(Modifier.fillMaxSize().background(C.turq), verticalAlignment = Alignment.CenterVertically) {
                        ib("close", "Seçimi bitir", 22f, 1.8f, C.dDeep) { s.multi = null }
                        Text("${m.size} katman seçildi", color = C.dDeep, fontSize = (W * 0.044f).sp, fontWeight = FontWeight.Medium, modifier = Modifier.weight(1f))
                        ib("copy", "Seçilenleri çoğalt", 22f, 1.8f, C.dDeep) { m.forEach { s.duplicateLayer(it) }; s.multi = null }
                        ib("trash", "Seçilenleri sil", 22f, 1.8f, C.dDeep) { s.update { pp -> pp.copy(layers = pp.layers.filter { it.id !in m }) }; s.multi = null }
                        ib("more", "Diğer", 26f, 3f, C.dDeep) { mmenu = !mmenu }
                    }
                    sel != null && panel != null && panel != Panel.ADD -> {
                        ib("back", "Geri", 22f, 1.8f, C.dText) { panel = null }
                        Text(panel!!.title, color = C.dText, fontSize = (W * 0.044f).sp, fontWeight = FontWeight.Medium, modifier = Modifier.weight(1f).padding(start = 2.dp))
                    }
                    sel != null -> {
                        ib("back", "Seçimi kaldır", 22f, 1.8f, C.dText) { s.selectedId = null; panel = null }
                        TitleField(sel.name, W, Modifier.weight(1f)) { v -> s.updateLayer(sel.id, false) { it.copy(name = v) } }
                        ib("trash", "Sil", 22f, 1.8f, C.dText) { s.removeLayer(sel.id); panel = null }
                        ib("more", "Diğer", 26f, 3f, C.dText) { menu = !menu }
                    }
                    else -> {
                        ib("exit", "Projeden çık", 22f, 1.8f, C.dText) { close() }
                        TitleField(p.name, W, Modifier.weight(1f)) { v -> s.update(false) { it.copy(name = v) } }
                        ib("gear", "Proje ayarları", 22f, 1.8f, C.dText) { projMenu = !projMenu }
                        ib("export", "Dışa aktar", 22f, 1.8f, C.dText) { s.playing = false; s.selectedId = null; projMenu = false; if (p.layers.isEmpty()) show("Önce bir katman ekle.") else exDlg = true }
                    }
                }
            }
            // ---------- Önizleme ----------
            Stage(s, panel, perf, ver, Modifier.fillMaxWidth().weight(1.042f, fill = true).heightIn(min = 120.dp).background(C.dDeep)) { if (it) { if (panel != null && panel != Panel.ADD) panel = null } }
            // ---------- Oynatma düğmeleri ----------
            Row(Modifier.fillMaxWidth().height(wd(0.122f)).padding(horizontal = 2.dp), verticalAlignment = Alignment.CenterVertically) {
                val ib = @Composable { icon: String, enabled: Boolean, size: Float, tint: Color, bg: Color, on: () -> Unit ->
                    Box(Modifier.size(wd(0.11f)).clip(RoundedCornerShape(12.dp)).background(bg).tap(enabled, on), contentAlignment = Alignment.Center) { Ico(icon, if (enabled) tint else C.dDim, size.dp) }
                }
                ib("undo", s.past.isNotEmpty(), 22f, C.dText, Color.Transparent) { s.undo() }
                ib("redo", s.future.isNotEmpty(), 22f, C.dText, Color.Transparent) { s.redo() }
                Spacer(Modifier.weight(1f))
                ib("toStart", true, 22f, C.dText, Color.Transparent) { s.time = 0.0 }
                ib(if (s.playing) "pause" else "play", true, 26f, C.dText, Color.Transparent) { s.playing = !s.playing }
                ib("toEnd", true, 22f, C.dText, Color.Transparent) { s.time = dur }
                Spacer(Modifier.weight(1f))
                ib("fit", true, 22f, C.dText, Color.Transparent) { s.selectedId = null; panel = null; s.time = 0.0; s.playing = true }
                ib("loop", true, 22f, if (loop) C.turq else C.dText2, if (loop) C.turq.copy(alpha = .12f) else Color.Transparent) { loop = !loop }
            }
            // ---------- Alt kısım: zaman çizelgesi + araçlar / panel ----------
            Column(Modifier.fillMaxWidth().weight(1.2f)) {
                Timeline(s, PPS, { PPS = it.coerceIn(PPS_MIN, PPS_MAX) }, tickStep, panel, W, Modifier.fillMaxWidth().weight(1f).heightIn(min = wd(0.2f)), haptic) { show(it) }
                if (sel != null && panel == null) Tools(s, sel, W, { panel = it }, ::trim)
                if (panel != null && panel != Panel.ADD && sel != null) PanelHost(s, sel, panel!!, W, onClose = { panel = null }, onChangeFlag = { addTab = "flags"; replaceFlagOf = sel.id; panel = Panel.ADD }, toast = show)
            }
        }
        // Katman ekle düğmesi
        if (panel == null && sel == null) Box(
            Modifier.align(Alignment.BottomEnd).navigationBarsPadding().padding(end = wd(0.0375f), bottom = wd(0.044f)).size(wd(0.128f))
                .shadow(8.dp, CircleShape).clip(CircleShape).background(C.turq).tap { openAdd(null) },
            contentAlignment = Alignment.Center,
        ) { Ico("plus", C.dDeep, 28.dp, 2.4f) }
        if (panel == Panel.ADD) AddPanel(s, addTab, { addTab = it }, replaceFlagOf, W, onClose = { panel = null; replaceFlagOf = null }, toast = show)

        // ---------- Menüler ----------
        if (mmenu && s.multi != null) DarkMenu({ mmenu = false }) {
            DItem("Maskeleme Grubu Oluştur") { multiAction("mask") }
            DItem("Hariç Tutma Grubu Oluştur") { multiAction("exclude") }
            DSep()
            DItem("Dikey Ortala") { multiAction("cv") }
            DItem("Yatay Ortala") { multiAction("ch") }
            DItem("Dikey Dağıt", (s.multi?.size ?: 0) >= 3) { multiAction("dv") }
            DItem("Yatay Dağıt", (s.multi?.size ?: 0) >= 3) { multiAction("dh") }
            DItem("Zaman Çizelgesine Dağıt") { multiAction("dt") }
        }
        if (menu && sel != null) DarkMenu({ menu = false }) {
            val done = { menu = false }
            DItem("Katmanı Çoğalt") { s.duplicateLayer(sel.id); done() }
            DItem("Katmanı Sil") { s.removeLayer(sel.id); done() }
            DItem("Yatay Çevir") { s.updateLayer(sel.id) { it.copy(flipX = !(it.flipX ?: false)) }; done() }
            DItem("Dikey Çevir") { s.updateLayer(sel.id) { it.copy(flipY = !(it.flipY ?: false)) }; done() }
            val fitTo = { k: Double -> s.updateLayer(sel.id) { it.copy(w = (it.w * k).roundToInt().toDouble(), h = (it.h * k).roundToInt().toDouble(), x = Anim(p.width / 2.0), y = Anim(p.height / 2.0), scale = Anim(1.0), rotation = Anim(0.0)) }; done() }
            DItem("Ekrana Sığdır") { fitTo(min(p.width / sel.w, p.height / sel.h)) }
            DItem("Ekranı Doldur") { fitTo(max(p.width / sel.w, p.height / sel.h)) }
            DItem("Ekrana Uzat") { s.updateLayer(sel.id) { it.copy(w = p.width.toDouble(), h = p.height.toDouble(), x = Anim(p.width / 2.0), y = Anim(p.height / 2.0), scale = Anim(1.0), rotation = Anim(0.0)) }; done() }
            Row(Modifier.padding(start = 20.dp, end = 20.dp, top = 8.dp, bottom = 12.dp), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                listOf("", "#22D3C5", "#3B9BFF", "#8F7CF0", "#E84393", "#F2C230").forEach { c ->
                    val on = (sel.tag ?: "") == c
                    Box(Modifier.size(26.dp).then(if (on) Modifier.border(2.dp, C.dText, RoundedCornerShape(5.dp)).padding(3.dp) else Modifier)
                        .clip(RoundedCornerShape(4.dp)).background(if (c.isEmpty()) Color.Transparent else colorOf(c)).border(1.5.dp, C.dDim, RoundedCornerShape(4.dp))
                        .tap { s.updateLayer(sel.id) { it.copy(tag = c.ifEmpty { null }) }; done() })
                }
            }
            DSep()
            DItem("Öne Getir") { s.update { pp -> pp.copy(layers = pp.layers.filter { it.id != sel.id } + sel) }; done() }
            DItem("Arkaya Gönder") { s.update { pp -> pp.copy(layers = listOf(sel) + pp.layers.filter { it.id != sel.id }) }; done() }
            DItem("Kompozisyon Alanını Doldur") {
                val ratio = sel.w / sel.h; val cover = max(p.width / sel.w, p.height / sel.h)
                s.updateLayer(sel.id) { it.copy(w = (it.w * cover).roundToInt().toDouble(), h = (it.w * cover / ratio).roundToInt().toDouble(), x = Anim(p.width / 2.0), y = Anim(p.height / 2.0), scale = Anim(1.0)) }; done()
            }
            DItem("Ortaya Hizala") { s.updateLayer(sel.id) { it.copy(x = Anim(p.width / 2.0), y = Anim(p.height / 2.0)) }; done() }
            DSep()
            if (sel.parent != null) DItem("Takibi Bırak (${p.layers.find { it.id == sel.parent }?.name})") { linkParent(sel.id, null); done() }
            else DItem("Takip Et (çocuk yap)…", p.layers.size >= 2) { pick = "parent"; done() }
            if (sel.mask != null) DItem("Kırpma Maskesini Kaldır") { s.updateLayer(sel.id) { it.copy(mask = null) }; done() }
            else DItem("Kırpma Maskesi Oluştur…", p.layers.size >= 2) { pick = "mask"; done() }
            DSep()
            DItem("Tüm Süreye Yay") { s.updateLayer(sel.id) { it.copy(start = 0.0, end = max(it.end, dur)) }; done() }
        }
        if (pick != null && sel != null) ChoiceBox({ pick = null }) {
            Text(if (pick == "parent") "\"${sel.name}\" hangi katmanı takip etsin?" else "\"${sel.name}\" hangi katmanın şekline kırpılsın?", color = C.dText, fontSize = 16.sp, fontWeight = FontWeight.Bold)
            Text(if (pick == "parent") "Seçtiğin katman ebeveyn olur; onu taşıyınca bu da taşınır." else "Örn. bayrağı gövdenin beyaz içine kırp.", color = C.dText2, fontSize = 12.sp)
            Column(Modifier.heightIn(max = 300.dp).verticalScroll(rememberScrollState()), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                p.layers.filter { it.id != sel.id && !(pick == "parent" && isAncestor(sel.id, it.id)) }.forEach { l ->
                    DBtn(l.name, ghost = true) {
                        if (pick == "parent") linkParent(sel.id, l.id) else { s.updateLayer(sel.id) { it.copy(mask = l.id) }; show("Kırpma maskesi oluşturuldu.") }
                        pick = null
                    }
                }
            }
            DBtn("Vazgeç") { pick = null }
        }
        if (projMenu && sel == null) DarkMenu({ projMenu = false }) {
            var picker by remember { mutableStateOf(false) }
            Column(Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
                Text("Proje Ayarları", color = C.dText, fontWeight = FontWeight.Bold)
                Text("${p.width} × ${p.height} · ${p.fps} fps · ${fmtTime(dur, p.fps)}", fontSize = 13.sp, color = C.dText2)
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text("Arka Fon", color = C.dText, modifier = Modifier.weight(1f))
                    Box(Modifier.size(40.dp, 30.dp).clip(RoundedCornerShape(6.dp)).background(colorOf(p.background)).border(1.dp, C.dLine, RoundedCornerShape(6.dp)).tap { picker = true })
                }
                DBtn("Videoyu Dışa Aktar", icon = "export") { projMenu = false; if (p.layers.isEmpty()) show("Önce bir katman ekle.") else exDlg = true }
            }
            if (picker) ColorPickerDialog(p.background, dark = true, onDismiss = { picker = false }) { c -> s.update { it.copy(background = c) }; picker = false }
        }
        if (exDlg) ExportDialog(s, onClose = { exDlg = false }, toast = show)
        if (toast.isNotEmpty()) Box(Modifier.fillMaxSize().navigationBarsPadding().padding(bottom = 90.dp), contentAlignment = Alignment.BottomCenter) {
            Text(toast, color = C.dText, fontSize = 14.sp, modifier = Modifier.widthIn(max = 340.dp).clip(RoundedCornerShape(10.dp)).background(Color(0xFF1B2A55)).padding(horizontal = 16.dp, vertical = 10.dp))
        }
        TutorialOverlay(s)
    }
}

@Composable
private fun TitleField(v: String, W: Float, modifier: Modifier, onChange: (String) -> Unit) {
    BasicTextField(v, onChange, singleLine = true, textStyle = TextStyle(color = C.dText, fontSize = (W * 0.044f).sp, fontFamily = Inter),
        cursorBrush = androidx.compose.ui.graphics.SolidColor(C.turq),
        modifier = modifier.padding(vertical = 6.dp).drawBehind { drawLine(C.dDeep, Offset(0f, size.height + 4.dp.toPx()), Offset(size.width, size.height + 4.dp.toPx()), 1.dp.toPx()) })
}

// ---------------------------------------------------------------------------------------------
// Önizleme: dokunarak seç, sürükle, iki parmakla büyüt/döndür, tutamaçlarla boyutlandır/kırp
// ---------------------------------------------------------------------------------------------
@Composable
private fun Stage(s: EditorState, panel: Panel?, perf: Map<String, Double>, ver: Int, modifier: Modifier, onEmptyTap: (Boolean) -> Unit) {
    val r = LocalRenderer.current
    var box by remember { mutableStateOf(IntSize(1, 1)) }
    val p = s.project
    // Efekt panelinde 2B parametre seçiliyse önizlemede kaydırarak ayarlanır
    val fxSel = if (panel == Panel.EFFECTS) s.sel?.let { l -> s.fxParam?.let { (fid, key) -> l.effects.find { it.id == fid }?.let { e -> fxMeta(e.type).params.find { it.key == key && it.two }?.let { e to it } } } } else null
    var swiping by remember { mutableStateOf(false) }
    Box(modifier.onSizeChanged { box = it }, contentAlignment = Alignment.Center) {
        val fit = min(box.width.toFloat() / p.width, box.height.toFloat() / p.height)
        val dw = with(LocalDensity.current) { (p.width * fit).toDp() }; val dh = with(LocalDensity.current) { (p.height * fit).toDp() }
        Canvas(Modifier.size(dw, dh).shadow(12.dp)
            .pointerInput(p.id) { stageGestures(s, { panel }, { fxSel }, { swiping = it }, onEmptyTap) }) {
            ver.hashCode()
            val q = size.width / s.project.width
            val res = (perf["res"] ?: 1.0).toFloat()
            val pr = s.project
            drawIntoCanvas { cv ->
                val nc = cv.nativeCanvas
                if (res < 0.99f) {
                    // Lite: düşük çözünürlükte çizip büyüt
                    val bw = max(1, (size.width * res).toInt()); val bh = max(1, (size.height * res).toInt())
                    val b = lowBuf(bw, bh)
                    b.eraseColor(0)
                    r.draw(android.graphics.Canvas(b), pr, s.time, q * res)
                    nc.drawBitmap(b, null, android.graphics.RectF(0f, 0f, size.width, size.height), android.graphics.Paint(android.graphics.Paint.FILTER_BITMAP_FLAG))
                } else r.draw(nc, pr, s.time, q)
                val sel = if (s.playing) null else s.sel
                if (sel != null) {
                    if (panel == Panel.MOVE) drawMotionPath(nc, pr, sel, q)
                    if (s.time >= sel.start && s.time < sel.end && sel.hidden != true && sel.type != "audio") drawSelection(nc, sel, worldTransform(pr, sel, s.time), q, panel == Panel.COLOR)
                }
            }
        }
        if (fxSel != null) Column(Modifier.align(Alignment.Center).graphicsLayer { alpha = if (swiping) .35f else 1f }, horizontalAlignment = Alignment.CenterHorizontally) {
            Text("↑", color = Color.White, fontSize = 18.sp)
            Text("← Ayarlamak için kaydır →", color = Color.White, fontSize = 13.sp, modifier = Modifier.clip(RoundedCornerShape(8.dp)).background(Color(0x990B1430)).padding(horizontal = 10.dp, vertical = 4.dp))
            Text(fxSel.second.label, color = C.turq, fontSize = 14.sp, fontWeight = FontWeight.Bold)
            Text("↓", color = Color.White, fontSize = 18.sp)
        }
    }
}

private var lowBitmap: Bitmap? = null
private fun lowBuf(w: Int, h: Int): Bitmap {
    val b = lowBitmap
    if (b != null && b.width == w && b.height == h) return b
    return Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888).also { lowBitmap = it }
}

private suspend fun androidx.compose.ui.input.pointer.PointerInputScope.stageGestures(
    s: EditorState, panel: () -> Panel?, fxSel: () -> Pair<Effect, FxParam>?, setSwiping: (Boolean) -> Unit, onEmpty: (Boolean) -> Unit,
) {
    awaitEachGesture {
        val down = awaitFirstDown(requireUnconsumed = false)
        if (s.playing) s.playing = false
        val p0 = s.project
        val k = size.width.toFloat() / p0.width
        fun toProj(o: Offset) = Offset(o.x / k, o.y / k)
        fun toLayerLocal(l: Layer, pt: Offset): Pair<Double, Double> {
            val w = worldTransform(s.project, l, s.time)
            val a = -w.rot * PI / 180; val dx = pt.x - w.x; val dy = pt.y - w.y
            return (dx * cos(a) - dy * sin(a)) / w.scale to (dx * sin(a) + dy * cos(a)) / w.scale
        }
        val t = s.time
        val sel = s.sel
        val pt = toProj(down.position)
        // Hangi iş?
        var mode = "none"
        var dragId: String? = null; var w0: TR? = null; var pw0: TR? = null
        var gWhich = 0
        var hd: Handle? = null; var l0: Layer? = null; var hStart = 0.0 to 0.0; var kids = emptyList<Layer>()
        var fx0 = 0.0 to 0.0
        val fs = fxSel()
        if (fs != null) {
            s.checkpoint(); mode = "fx"; setSwiping(true)
            fx0 = fs.first.value(fs.second.key + "X", t) to fs.first.value(fs.second.key + "Y", t)
        } else {
            if (panel() == Panel.COLOR && sel?.grad != null && sel.fill2 != null) {
                val (lx, ly) = toLayerLocal(sel, pt)
                val tol = 40 / worldTransform(p0, sel, t).scale
                for (which in listOf(1, 2)) {
                    val gx = (if (which == 1) sel.grad.x1 else sel.grad.x2) * sel.w; val gy = (if (which == 1) sel.grad.y1 else sel.grad.y2) * sel.h
                    if (hypot(lx - gx, ly - gy) < tol) { s.checkpoint(); mode = "grad"; gWhich = which; break }
                }
            }
            if (mode == "none" && sel != null && t >= sel.start && t < sel.end) {
                val h = pickHandle(p0, sel, t, pt.x.toDouble(), pt.y.toDouble(), 20.0 * p0.width / size.width * density / 2.6)
                if (h != null) {
                    s.checkpoint(); mode = "handle"; hd = h; l0 = sel
                    val (lx, ly) = toLayerLocal(sel, pt)
                    hStart = lx * (if (sel.flipX == true) -1 else 1) to ly * (if (sel.flipY == true) -1 else 1)
                    // Onu takip eden bütün parçalar birlikte büyür
                    val fam = mutableSetOf(sel.id)
                    var ch = true
                    while (ch) { ch = false; for (l in p0.layers) if (l.parent != null && l.parent in fam && l.id !in fam) { fam += l.id; ch = true } }
                    kids = p0.layers.filter { it.id != sel.id && it.id in fam }
                }
            }
            if (mode == "none") {
                val hit = hitTest(p0, t, pt.x.toDouble(), pt.y.toDouble())
                val keep = sel != null && hitTest(p0, t, pt.x.toDouble(), pt.y.toDouble(), sel.id) != null
                val target = if (keep) sel else hit
                if (s.multi == null) s.selectedId = target?.id
                if (target == null) { onEmpty(true); return@awaitEachGesture }
                s.checkpoint(); mode = "drag"; dragId = target.id
                w0 = worldTransform(p0, target, t); pw0 = parentWorld(p0, target, t)
            }
        }
        // Takip: tek parmak sürükleme / iki parmak büyütme-döndürme
        var pinch: DoubleArray? = null // d0, a0, s0, r0
        var pinchId: String? = null
        while (true) {
            val ev = awaitPointerEvent(PointerEventPass.Main)
            val pressed = ev.changes.filter { it.pressed }
            if (pressed.isEmpty()) break
            if (pressed.size >= 2) {
                val (a, b) = pressed
                val d = hypot((b.position.x - a.position.x).toDouble(), (b.position.y - a.position.y).toDouble()).coerceAtLeast(1.0)
                val ang = atan2((b.position.y - a.position.y).toDouble(), (b.position.x - a.position.x).toDouble()) * 180 / PI
                if (pinch == null) {
                    pinchId = dragId ?: s.selectedId
                    val l = s.project.layers.find { it.id == pinchId }
                    if (l != null) pinch = doubleArrayOf(d, ang, l.scale.at(s.time), l.rotation.at(s.time))
                    mode = "pinch"
                } else {
                    val pc = pinch
                    val sc = max(0.02, Math.round(pc[2] * d / pc[0] * 1000) / 1000.0)
                    val rot = Math.round((pc[3] + ang - pc[1]) * 10) / 10.0
                    s.updateLayer(pinchId!!, false) { it.copy(scale = it.scale.set(s.time, sc), rotation = it.rotation.set(s.time, rot)) }
                }
                ev.changes.forEach { it.consume() }
                continue
            }
            val c = pressed[0]
            val cur = toProj(c.position)
            when (mode) {
                "fx" -> {
                    val (e, pr) = fs!!
                    val dx = (c.position.x - down.position.x) / density * 2; val dy = (c.position.y - down.position.y) / density * 2
                    s.updateLayer(s.selectedId!!, false) { l -> l.copy(effects = l.effects.map { x ->
                        if (x.id != e.id) x else {
                            val v = (x.v ?: emptyMap()).toMutableMap()
                            v[pr.key + "X"] = (v[pr.key + "X"] ?: Anim(fx0.first)).set(s.time, (fx0.first + dx).roundToInt().toDouble())
                            v[pr.key + "Y"] = (v[pr.key + "Y"] ?: Anim(fx0.second)).set(s.time, (fx0.second + dy).roundToInt().toDouble())
                            x.copy(v = v)
                        }
                    }) }
                }
                "grad" -> {
                    val l = s.sel ?: break
                    val (lx, ly) = toLayerLocal(l, cur)
                    val nx = Math.round(lx / l.w * 1000) / 1000.0; val ny = Math.round(ly / l.h * 1000) / 1000.0
                    s.updateLayer(l.id, false) { it.copy(grad = if (gWhich == 1) it.grad!!.copy(x1 = nx, y1 = ny) else it.grad!!.copy(x2 = nx, y2 = ny)) }
                }
                "handle" -> {
                    val l = s.sel ?: break
                    val (lx, ly) = toLayerLocal(l, cur)
                    val nl = applyHandle(l0!!, hd!!.id, lx * (if (l.flipX == true) -1 else 1), ly * (if (l.flipY == true) -1 else 1), hStart.first, hStart.second)
                    val kx = nl.w / l0.w; val ky = nl.h / l0.h
                    val resize = (nl.w != l0.w || nl.h != l0.h) && kids.isNotEmpty()
                    fun sc(a: Anim, f: Double) = Anim((a.v * f).roundToInt().toDouble(), a.k?.map { it.copy(v = (it.v * f).roundToInt().toDouble()) })
                    s.update(false) { pp -> pp.copy(layers = pp.layers.map { x ->
                        if (x.id == l.id) nl.copy(x = x.x, y = x.y, scale = x.scale, rotation = x.rotation, opacity = x.opacity)
                        else if (resize) kids.find { it.id == x.id }?.let { k0 ->
                            x.copy(w = max(1.0, (k0.w * kx).roundToInt().toDouble()), h = max(1.0, (k0.h * ky).roundToInt().toDouble()),
                                fontSize = if (k0.type == "text" && k0.fontSize != null) max(4.0, (k0.fontSize * min(kx, ky)).roundToInt().toDouble()) else x.fontSize,
                                x = sc(k0.x, kx), y = sc(k0.y, ky))
                        } ?: x else x
                    }) }
                }
                "drag" -> {
                    val loc = toLocal(pw0!!, w0!!.copy(x = w0.x + cur.x - pt.x, y = w0.y + cur.y - pt.y))
                    s.updateLayer(dragId!!, false) { it.copy(x = it.x.set(s.time, loc.x.roundToInt().toDouble()), y = it.y.set(s.time, loc.y.roundToInt().toDouble())) }
                }
            }
            if (c.positionChange() != Offset.Zero) c.consume()
        }
        setSwiping(false)
    }
}

// ---------------------------------------------------------------------------------------------
// Zaman çizelgesi
// ---------------------------------------------------------------------------------------------
@Composable
private fun Timeline(s: EditorState, PPS: Float, setPPS: (Float) -> Unit, tickStep: Int, panel: Panel?, W: Float, modifier: Modifier,
                     haptic: androidx.compose.ui.hapticfeedback.HapticFeedback, show: (String) -> Unit) {
    val p = s.project
    val dens = LocalDensity.current.density
    val TOP = 44f; val ROW = 26f
    val sel = s.sel
    val rows = p.layers.reversed()
    val vScroll = rememberScrollState()
    var tlW by remember { mutableFloatStateOf(360f) }
    val half = tlW / 2
    val dur = p.duration
    var reord by remember { mutableStateOf<Pair<Int, Int>?>(null) }
    var trimming by remember { mutableStateOf<Triple<String, String, Double>?>(null) } // id, side, eski değer
    var kfMoving by remember { mutableStateOf<String?>(null) }
    val scope = rememberCoroutineScope()
    var inertia by remember { mutableStateOf<kotlinx.coroutines.Job?>(null) }
    val stepTo = { raw: Double ->
        val fr = (raw * p.fps / tickStep).roundToInt() * tickStep
        val f2 = fr.coerceIn(0, ((s.project.duration + 2) * p.fps).roundToInt())
        val t = f2.toDouble() / p.fps
        if (abs(t - s.time) > 1e-9) s.time = t
    }
    // PPS: saniye başına dp
    val P = PPS
    Box(modifier.clipToBounds().onSizeChanged { tlW = it.width / dens }
        .pointerInput(p.fps, tickStep) {
            // Yatay kaydırma: kare kare zaman; iki parmak: yakınlaştır
            awaitEachGesture {
                val d0 = awaitFirstDown(requireUnconsumed = false, pass = PointerEventPass.Initial)
                inertia?.cancel()
                var on = false; var vert = false
                val t0 = s.time; var vx = 0.0; var lastX = d0.position.x; var lastT = d0.uptimeMillis
                var pinch0 = 0.0; var pps0 = PPS
                while (true) {
                    val ev = awaitPointerEvent(PointerEventPass.Initial)
                    val pr = ev.changes.filter { it.pressed }
                    if (pr.isEmpty()) break
                    if (pr.size >= 2) {
                        val dd = hypot((pr[0].position.x - pr[1].position.x).toDouble(), (pr[0].position.y - pr[1].position.y).toDouble())
                        if (pinch0 == 0.0) { pinch0 = dd; pps0 = PPS } else setPPS((pps0 * dd / pinch0).toFloat())
                        ev.changes.forEach { it.consume() }; on = true; continue
                    }
                    val c = pr[0]
                    if (c.isConsumed) { if (!on) break else continue }
                    val dx = c.position.x - d0.position.x; val dy = c.position.y - d0.position.y
                    if (!on && !vert) {
                        if (abs(dx) < 6 * density && abs(dy) < 6 * density) continue
                        if (abs(dy) > abs(dx)) { vert = true } else { on = true; if (s.playing) s.playing = false }
                    }
                    if (vert) { scope.launch { vScroll.scrollBy(-(c.position.y - c.previousPosition.y)) }; c.consume(); continue }
                    val now = c.uptimeMillis
                    vx = 0.8 * vx + 0.2 * ((c.position.x - lastX) / density / max(1L, now - lastT))
                    lastX = c.position.x; lastT = now
                    stepTo(t0 - dx / density / P)
                    c.consume()
                }
                if (on && !vert) {
                    if (abs(vx) > 0.6) inertia = scope.launch {
                        var v = vx * 1000 / P; var t = s.time; var last = withFrameNanos { it }
                        while (isActive) {
                            val now = withFrameNanos { it }; val dt = (now - last) / 1e9; last = now
                            v *= exp(-dt * 4); if (abs(v) < 0.05) break
                            t -= v * dt; stepTo(t)
                        }
                    }
                }
            }
        }) {
        // İçerik: zaman × ölçek kadar sola kaydırılır (yeniden çizim yok, sadece katman taşınır)
        Box(Modifier.fillMaxSize().verticalScroll(vScroll, enabled = false)) {
            Box(Modifier.height((TOP + rows.size * ROW + 90).dp).fillMaxWidth().graphicsLayer { translationX = -(s.time * P * dens).toFloat() }) {
                // Cetvel
                Canvas(Modifier.offset(x = half.dp).width(((dur + 2) * P).dp).height(14.dp)) {
                    val fps = p.fps; val fpx = P * dens / fps
                    val half2 = if (fps % 2 == 0) fps / 2 else 0
                    val n = ((dur + 2) * fps).toInt()
                    var f = 0
                    while (f <= n) {
                        val big = f % fps == 0; val mid = half2 > 0 && f % half2 == 0
                        val h = if (big) 13.dp.toPx() else if (mid) 8.dp.toPx() else 4.dp.toPx()
                        drawLine(if (big) C.dText else if (mid) C.dText2 else C.dDim, Offset(f * fpx, size.height - h), Offset(f * fpx, size.height), if (big) 1.5f * density / 1.2f else 1f * density / 1.6f)
                        f += tickStep
                    }
                    if (half2 > 0 && tickStep > half2) { var sec = 0.5; while (sec <= dur + 2) { drawLine(C.dText2, Offset((sec * P * dens).toFloat(), size.height - 8.dp.toPx()), Offset((sec * P * dens).toFloat(), size.height), 1f); sec += 1.0 } }
                }
                // Satır şeritleri (sıra değiştirmek için basılı tut)
                if (sel == null) rows.forEachIndexed { i, _ ->
                    Box(Modifier.offset(y = (TOP + i * ROW - 3).dp).fillMaxWidth().height(26.dp).graphicsLayer { translationX = (s.time * P * dens).toFloat() }
                        .background(if (reord?.first == i) C.turq.copy(alpha = .08f) else Color.Transparent)
                        .pointerInput(rows.size) {
                            awaitEachGesture {
                                val d = awaitFirstDown(requireUnconsumed = false)
                                val longPress = withTimeoutOrNull(400) { while (true) { val e = awaitPointerEvent(); val c = e.changes.first(); if (!c.pressed) return@withTimeoutOrNull false; if ((c.position - d.position).getDistance() > 8 * density) return@withTimeoutOrNull false } ; @Suppress("UNREACHABLE_CODE") false }
                                if (longPress != null) return@awaitEachGesture
                                haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                                reord = i to i
                                while (true) {
                                    val e = awaitPointerEvent(); val c = e.changes.first()
                                    c.consume()
                                    if (!c.pressed) break
                                    val cur = (i + ((c.position.y - d.position.y) / density / ROW).roundToInt()).coerceIn(0, rows.size - 1)
                                    if (reord?.second != cur) reord = i to cur
                                }
                                val ro = reord
                                if (ro != null && ro.first != ro.second) {
                                    val nr = rows.toMutableList(); val it2 = nr.removeAt(ro.first); nr.add(ro.second, it2)
                                    s.update { pp -> pp.copy(layers = nr.reversed().map { l -> pp.layers.first { it.id == l.id } }) }
                                }
                                reord = null
                            }
                        })
                }
                reord?.let { (_, cur) -> Box(Modifier.offset(y = (TOP + cur * ROW - 3).dp).fillMaxWidth().height(2.dp).graphicsLayer { translationX = (s.time * P * dens).toFloat() }.background(C.turq)) }
                // Şeritler
                var nb = 0; var na = 0
                val look = HashMap<String, Pair<Long, Long>?>()
                for (l in p.layers) look[l.id] = when { l.type == "audio" -> PURPLES[na++ % PURPLES.size]; l.isMedia() -> null; else -> BLUES[nb++ % BLUES.size] }
                (if (sel != null) listOf(sel) else rows).forEachIndexed { i, l ->
                    val off = reord?.let { (from, cur) -> when { i == from -> (cur - from) * ROW; from < cur && i > from && i <= cur -> -ROW; from > cur && i < from && i >= cur -> ROW; else -> 0f } } ?: 0f
                    Track(s, l, i, half + (l.start * P).toFloat(), max(8f, ((l.end - l.start) * P).toFloat()), TOP + i * ROW + off, look[l.id], P, W, panel,
                        isSel = l.id == s.selectedId, isMulti = s.multi?.contains(l.id) == true, haptic = haptic,
                        trimming = trimming, setTrimming = { trimming = it }, kfMoving = kfMoving, setKfMoving = { kfMoving = it })
                }
            }
        }
        if (p.layers.isEmpty()) Text("Katman eklemek için + butonuna bas.", color = C.dText2, fontSize = 13.sp, modifier = Modifier.align(Alignment.TopCenter).padding(top = 72.dp).background(C.dBg).padding(horizontal = 10.dp, vertical = 6.dp))
        // Soldaki katman simgeleri (zamanla kaymaz)
        if (sel == null && p.layers.isNotEmpty()) Box(Modifier.fillMaxHeight().width(56.dp).graphicsLayer { translationY = -vScroll.value.toFloat() }) {
            rows.forEachIndexed { i, l ->
                val on = s.multi?.contains(l.id) == true
                Box(Modifier.offset(y = (TOP + i * ROW).dp).size(if (on) 52.dp else 40.dp, (W * 0.0625f).dp).clip(RoundedCornerShape(topEnd = 10.dp, bottomEnd = 10.dp)).background(if (on) C.turq else Color(0xFF26386C))
                    .layerPress(s, l.id, haptic), contentAlignment = Alignment.Center) { LayerDot(l) }
            }
        }
        trimming?.let { (id, side, v0) ->
            val l = p.layers.find { it.id == id }
            if (l != null) Row(Modifier.fillMaxWidth().background(C.dBg).padding(horizontal = 8.dp, vertical = 4.dp).zIndex(7f)) {
                val d = if (side == "start") l.start - v0 else l.end - v0
                listOf("Başlangıç" to fmtTime(l.start, p.fps), "Bitiş" to fmtTime(l.end, p.fps), "Süre" to fmtTime(l.end - l.start, p.fps), "Değişiklik" to (if (d < 0) "-" else "+") + fmtTime(abs(d), p.fps)).forEach { (a, b) ->
                    Column(Modifier.weight(1f)) { Text(a, fontSize = 10.sp, color = C.dText2); Text(b, fontSize = 12.sp, color = C.dText) }
                }
            }
        }
        // Oynatma çizgisi + zaman göstergesi
        Box(Modifier.offset(x = (half - 1).dp).width(2.dp).fillMaxHeight().background(C.dText))
        TimeCode(s, Modifier.offset(x = half.dp, y = (W * 0.05f).dp), W)
    }
}

@Composable
private fun TimeCode(s: EditorState, modifier: Modifier, W: Float) {
    var w by remember { mutableIntStateOf(0) }
    val dens = LocalDensity.current.density
    Text(fmtTime(s.time, s.project.fps), color = C.dText, fontSize = (W * 0.042f).sp, fontFamily = Inter,
        modifier = modifier.onSizeChanged { w = it.width }.graphicsLayer { translationX = -w / 2f }.background(C.dBg.copy(alpha = .0f)).padding(horizontal = 6.dp, vertical = 1.dp))
    dens.hashCode()
}

/** Dokun: seç (çoklu seçimde ekle/çıkar); basılı tut: çoklu seçim */
private fun Modifier.layerPress(s: EditorState, id: String, haptic: androidx.compose.ui.hapticfeedback.HapticFeedback): Modifier = pointerInput(id) {
    awaitEachGesture {
        val d = awaitFirstDown(requireUnconsumed = false)
        var moved = false
        val up = withTimeoutOrNull(450) {
            while (true) {
                val e = awaitPointerEvent(); val c = e.changes.first()
                if ((c.position - d.position).getDistance() > 8 * density) moved = true
                if (!c.pressed) return@withTimeoutOrNull true
            }
            @Suppress("UNREACHABLE_CODE") true
        }
        if (moved) return@awaitEachGesture
        if (up == null) {
            // Uzun basma: çoklu seçim
            haptic.performHapticFeedback(HapticFeedbackType.LongPress)
            s.multi = listOf(id); s.selectedId = null
            do { val e = awaitPointerEvent() } while (e.changes.any { it.pressed })
            return@awaitEachGesture
        }
        val m = s.multi
        if (m != null) { val n = if (id in m) m - id else m + id; s.multi = n.ifEmpty { null } } else s.selectedId = id
    }
}

@Composable
private fun Track(s: EditorState, l: Layer, i: Int, left: Float, width: Float, top: Float, look: Pair<Long, Long>?, P: Float, W: Float, panel: Panel?,
                  isSel: Boolean, isMulti: Boolean, haptic: androidx.compose.ui.hapticfeedback.HapticFeedback,
                  trimming: Triple<String, String, Double>?, setTrimming: (Triple<String, String, Double>?) -> Unit, kfMoving: String?, setKfMoving: (String?) -> Unit) {
    val p = s.project
    val ctx = LocalContext.current
    val h = (W * 0.0625f).dp
    val film = if (l.isMedia()) LayerThumbs.rememberThumb(ctx, l) else null
    val bg: Modifier = when {
        look != null -> Modifier.background(Brush.horizontalGradient(listOf(Color(look.first), Color(look.second))))
        film != null -> Modifier.background(Color(0xFF1B2547)).drawBehind {
            val ib = film.asImageBitmap()
            val sc = size.height / ib.height
            drawIntoCanvas { c ->
                c.save(); c.scale(sc, sc)
                c.nativeCanvas.drawRect(0f, 0f, size.width / sc, ib.height.toFloat(), android.graphics.Paint().apply { shader = android.graphics.BitmapShader(film, android.graphics.Shader.TileMode.REPEAT, android.graphics.Shader.TileMode.CLAMP); isFilterBitmap = true })
                c.restore()
            }
            drawRect(Brush.verticalGradient(listOf(Color(0x0D000000), Color(0x40000000))))
        }
        else -> Modifier.background(Color(0xFF26386C))
    }
    val dark = look != null && l.type != "audio"
    Box(Modifier.offset(x = left.dp, y = top.dp).width(width.dp).height(h).graphicsLayer { alpha = if (l.hidden == true) .45f else 1f }
        .then(if (isMulti) Modifier.border(2.dp, Color(0xFFDCE9FF), RoundedCornerShape(3.dp)) else Modifier)
        .clip(RoundedCornerShape(3.dp)).then(bg).layerPress(s, l.id, haptic).padding(horizontal = if (isSel) 26.dp else 8.dp),
        contentAlignment = Alignment.CenterStart) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            l.tag?.let { Box(Modifier.padding(end = 5.dp).size(8.dp).clip(RoundedCornerShape(2.dp)).background(colorOf(it))) }
            Text((if (l.mask != null) "◐ " else "") + l.name, fontSize = (W * 0.034f).sp, fontWeight = FontWeight.SemiBold, maxLines = 1, overflow = TextOverflow.Ellipsis,
                color = if (dark) C.dDeep else Color.White,
                style = if (!dark) TextStyle(shadow = androidx.compose.ui.graphics.Shadow(Color.Black, Offset(0f, 1f), 3f)) else TextStyle.Default)
        }
    }
    // Keyframe işaretleri (tam opak: seçili katmanda açık panelin işine ait olanlar)
    if (trimming?.first != l.id) {
        val focus = s.kfFocus
        layerMarkers(l).filter { it.t >= l.start - 1e-6 && it.t <= l.end + 1e-6 }
            .map { it to (isSel && focus != null && it.group in focus) }.sortedBy { it.second }
            .forEach { (m, f) ->
                val onIt = f && abs(m.t - s.time) < 0.5 / p.fps
                val moving = kfMoving == m.group + "@" + (m.t * p.fps).roundToInt()
                Canvas(Modifier.offset(x = (left + ((m.t - l.start) * P).toFloat() - 8f).dp, y = (top - 3).dp).size(16.dp, h + 6.dp)
                    .graphicsLayer { alpha = if (f) 1f else .5f }
                    .then(if (f) Modifier.markerDrag(s, l, m, P, haptic, setKfMoving) else Modifier)) {
                    val sc = if (f) 1f else .85f
                    val w = (if (onIt || moving) 11.dp.toPx() else 9.dp.toPx()) * sc; val hh = size.height * (if (onIt || moving) 1f else .88f) * sc
                    val cx = size.width / 2; val cy = size.height / 2
                    val path = Path().apply { moveTo(cx, cy - hh / 2); lineTo(cx + w / 2, cy); lineTo(cx, cy + hh / 2); lineTo(cx - w / 2, cy); close() }
                    drawPath(path, if (onIt || moving) Color(0xFF0B1430) else if (f) Color(0xFFF7F8FA) else Color(0xFFDBDBDC))
                    drawPath(path, if (onIt || moving) Color(0xFFF7F8FA) else Color(0xFF0B1430), style = Stroke((if (onIt) 1.6f else 1.2f) * density))
                }
            }
    }
    // Kırpma tutamaçları
    if (isSel) for (side in listOf("start", "end")) {
        val x = if (side == "start") left else left + width - 26f
        Box(Modifier.offset(x = x.dp, y = (top - 2).dp).size(26.dp, h + 4.dp).clip(RoundedCornerShape(if (side == "start") 4.dp else 0.dp, if (side == "end") 4.dp else 0.dp, if (side == "end") 4.dp else 0.dp, if (side == "start") 4.dp else 0.dp))
            .background(Color(0xFF3A4466))
            .pointerInput(l.id, side) {
                awaitEachGesture {
                    val d = awaitFirstDown(requireUnconsumed = false); d.consume()
                    val l0 = s.project.layers.first { it.id == l.id }
                    s.checkpoint()
                    val v0 = if (side == "start") l0.start else l0.end
                    setTrimming(Triple(l.id, side, v0))
                    while (true) {
                        val e = awaitPointerEvent(PointerEventPass.Initial); val c = e.changes.first(); c.consume()
                        if (!c.pressed) break
                        val v = ((v0 + (c.position.x - d.position.x) / density / P) * p.fps).roundToInt().toDouble() / p.fps
                        s.updateLayer(l.id, false) { if (side == "start") it.copy(start = v.coerceIn(0.0, it.end - 0.1)) else it.copy(end = max(it.start + 0.1, v)) }
                    }
                    setTrimming(null)
                }
            }, contentAlignment = Alignment.Center) { Box(Modifier.size(2.dp, h / 2).background(C.dText)) }
    }
}

/** Keyframe işareti: dokun → o ana git; basılı tutup kaydır → keyframe'i taşı */
private fun Modifier.markerDrag(s: EditorState, l: Layer, m: Marker, P: Float, haptic: androidx.compose.ui.hapticfeedback.HapticFeedback, setMoving: (String?) -> Unit): Modifier = pointerInput(l.id, m) {
    awaitEachGesture {
        val d = awaitFirstDown(requireUnconsumed = false); d.consume()
        val fps = s.project.fps
        var moved = false
        val tapUp = withTimeoutOrNull(300) {
            while (true) {
                val e = awaitPointerEvent(PointerEventPass.Initial); val c = e.changes.first(); c.consume()
                if (abs(c.position.x - d.position.x) > 8 * density) { moved = true; return@withTimeoutOrNull false }
                if (!c.pressed) return@withTimeoutOrNull true
            }
            @Suppress("UNREACHABLE_CODE") true
        }
        if (tapUp == true) { s.time = m.t; return@awaitEachGesture }
        if (moved) return@awaitEachGesture
        haptic.performHapticFeedback(HapticFeedbackType.TextHandleMove)
        s.checkpoint()
        var cur = m.t
        setMoving(m.group + "@" + (m.t * fps).roundToInt())
        while (true) {
            val e = awaitPointerEvent(PointerEventPass.Initial); val c = e.changes.first(); c.consume()
            if (!c.pressed) break
            val lay = s.project.layers.find { it.id == l.id } ?: break
            val t1 = ((m.t + (c.position.x - d.position.x) / density / P) * fps).roundToInt().toDouble() / fps
            val t2 = t1.coerceIn(lay.start, lay.end)
            if (abs(t2 - cur) < 1e-6) continue
            val from = cur; cur = t2
            s.updateLayer(l.id, false) { moveMarker(it, m.group, from, t2) }
            setMoving(m.group + "@" + (t2 * fps).roundToInt())
            s.time = t2
        }
        setMoving(null)
    }
}

/** Zaman çizelgesinin solundaki katman simgesi: katmanın kendisi */
@Composable
private fun LayerDot(l: Layer) {
    if (l.type == "audio") { Ico("music", Color(0xFFC9A8FF), 12.dp); return }
    val b = LayerThumbs.rememberThumb(LocalContext.current, l)
    if (b != null) Image(b.asImageBitmap(), null, Modifier.size(24.dp, 16.dp).clip(RoundedCornerShape(2.dp)).background(Color(0x0FFFFFFF)), contentScale = ContentScale.Fit)
    else Box(Modifier.size(14.dp).clip(RoundedCornerShape(3.dp)).background(C.dText2), contentAlignment = Alignment.Center) { Ico("image", C.dDeep, 10.dp) }
}

// ---------------------------------------------------------------------------------------------
// Katman araçları: 5 küçük + 3×2 büyük
// ---------------------------------------------------------------------------------------------
@Composable
private fun Tools(s: EditorState, sel: Layer, W: Float, setPanel: (Panel) -> Unit, trim: (String) -> Unit) {
    val g = (W * 0.008f).dp
    Column(Modifier.fillMaxWidth().height((W * 0.56f).dp).background(Color(0xFF1A2550)).navigationBarsPadding().padding((W * 0.028f).dp), verticalArrangement = Arrangement.spacedBy((W * 0.012f).dp)) {
        Row(Modifier.fillMaxWidth().height((W * 0.11f).dp), horizontalArrangement = Arrangement.spacedBy(g)) {
            listOf("trimL" to { trim("start") }, "split" to { trim("split") }, "trimR" to { trim("end") }, "copy" to { s.duplicateLayer(sel.id) },
                (if (sel.hidden == true) "eyeOff" else "eye") to { s.updateLayer(sel.id) { it.copy(hidden = !(it.hidden ?: false)) } }).forEach { (ic, fn) ->
                Box(Modifier.weight(1f).fillMaxHeight().clip(RoundedCornerShape(6.dp)).background(C.dPanel).tap(onClick = fn), contentAlignment = Alignment.Center) { Ico(ic, C.dText, 20.dp) }
            }
        }
        val big = @Composable { m: Modifier, icon: String, label: String, on: (() -> Unit)? ->
            Column(m.fillMaxHeight().clip(RoundedCornerShape(6.dp)).background(C.dPanel).tap(on != null) { on?.invoke() }, horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.Center) {
                Ico(icon, if (on != null) C.dText else C.dDim, 24.dp)
                Spacer(Modifier.height(4.dp))
                Text(label, fontSize = (W * 0.031f).sp, lineHeight = (W * 0.036f).sp, color = if (on != null) C.dText else C.dDim, maxLines = 2, textAlign = androidx.compose.ui.text.style.TextAlign.Center)
            }
        }
        val items: List<Triple<String, String, (() -> Unit)?>> = if (sel.type == "audio") listOf(
            Triple("music", "Ses Düzeyi") { setPanel(Panel.VOLUME) },
            Triple(if (sel.muted == true) "volOff" else "music", if (sel.muted == true) "Sesi Aç" else "Sessize Al") { s.updateLayer(sel.id) { it.copy(muted = !(it.muted ?: false)) } },
        ) else listOf(
            Triple("bucket", "Renk ve Dolgu", if (sel.type == "shape" || sel.type == "text") ({ setPanel(Panel.COLOR) }) else null),
            when (sel.type) { "cb" -> Triple("ball", "CB Ayarları") { setPanel(Panel.CB) }; "video" -> Triple("music", "Ses Düzeyi") { setPanel(Panel.VOLUME) }; else -> Triple("border", "Kenarlık ve Gölge", null) },
            Triple("layers", "Karıştırma ve Opaklık") { setPanel(Panel.OPACITY) },
            Triple("move", "Taşı ve Çevir") { setPanel(Panel.MOVE) },
            if (sel.type == "text") Triple("text", "Metni Düzenle") { setPanel(Panel.TEXT) } else Triple("pen", "Şekli Düzenle", if (sel.type == "shape" && sel.shape != null) ({ setPanel(Panel.SHAPE) }) else null),
            Triple("sparkle", "Efektler") { setPanel(Panel.EFFECTS) },
        )
        Column(Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(g)) {
            items.chunked(3).forEach { row ->
                Row(Modifier.weight(1f), horizontalArrangement = Arrangement.spacedBy(g)) {
                    row.forEach { (ic, lb, fn) -> big(Modifier.weight(1f), ic, lb, fn) }
                    repeat(3 - row.size) { Spacer(Modifier.weight(1f)) }
                }
            }
        }
    }
}

// ---------------------------------------------------------------------------------------------
// Koyu menü, seçim kutusu, düğmeler
// ---------------------------------------------------------------------------------------------
@Composable
fun DarkMenu(onDismiss: () -> Unit, content: @Composable ColumnScope.() -> Unit) {
    Box(Modifier.fillMaxSize().tap(onClick = onDismiss)) {
        Column(Modifier.align(Alignment.TopEnd).statusBarsPadding().padding(top = 52.dp, end = 8.dp).widthIn(max = 320.dp).fillMaxWidth(0.86f)
            .heightIn(max = 560.dp).shadow(12.dp, RoundedCornerShape(10.dp)).clip(RoundedCornerShape(10.dp)).background(C.dPanel).tap { }.verticalScroll(rememberScrollState()), content = content)
    }
}

@Composable
fun DItem(label: String, enabled: Boolean = true, onClick: () -> Unit) {
    Text(label, fontSize = 15.sp, color = if (enabled) C.dText else C.dDim, modifier = Modifier.fillMaxWidth().tap(enabled, onClick).padding(horizontal = 20.dp, vertical = 14.dp))
}

@Composable
fun DSep() { Box(Modifier.fillMaxWidth().height(1.dp).background(C.dLine)) }

@Composable
fun ChoiceBox(onDismiss: () -> Unit, content: @Composable ColumnScope.() -> Unit) {
    Box(Modifier.fillMaxSize().background(Color(0x9903081A)).tap(onClick = onDismiss).padding(20.dp), contentAlignment = Alignment.Center) {
        Column(Modifier.widthIn(max = 340.dp).fillMaxWidth().clip(RoundedCornerShape(16.dp)).background(C.dPanel).tap { }.padding(18.dp), verticalArrangement = Arrangement.spacedBy(10.dp), content = content)
    }
}

@Composable
fun DBtn(label: String, ghost: Boolean = false, icon: String? = null, enabled: Boolean = true, modifier: Modifier = Modifier.fillMaxWidth(), onClick: () -> Unit) {
    Row(modifier.height(44.dp).clip(RoundedCornerShape(12.dp)).background(if (ghost) C.dPanel2 else C.turq).tap(enabled, onClick).padding(horizontal = 14.dp),
        verticalAlignment = Alignment.CenterVertically, horizontalArrangement = if (ghost) Arrangement.Start else Arrangement.Center) {
        if (icon != null) { Ico(icon, if (ghost) C.dText else C.dDeep, 18.dp); Spacer(Modifier.width(8.dp)) }
        Text(label, fontSize = 15.sp, fontWeight = FontWeight.SemiBold, color = (if (ghost) C.dText else C.dDeep).copy(alpha = if (enabled) 1f else .5f), maxLines = 1, overflow = TextOverflow.Ellipsis)
    }
}

