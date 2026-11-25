package com.warden.motion.app.ui

import android.content.Context
import android.graphics.BitmapFactory
import android.media.MediaMetadataRetriever
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.drawIntoCanvas
import androidx.compose.ui.graphics.nativeCanvas
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.warden.motion.app.data.Store
import com.warden.motion.app.model.*
import com.warden.motion.app.render.parseCol
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import kotlin.math.max
import kotlin.math.min
import kotlin.math.roundToInt

/** Görselin, videonun ya da sesin boyutu ve süresi */
data class MediaInfo(val w: Double, val h: Double, val dur: Double)

suspend fun mediaInfo(ctx: Context, src: String): MediaInfo = withContext(Dispatchers.IO) {
    runCatching {
        if (src.endsWith(".svg")) {
            val svg = ctx.assets.open(src).use { com.caverock.androidsvg.SVG.getFromInputStream(it) }
            val vb = svg.documentViewBox
            return@runCatching MediaInfo((vb?.width() ?: svg.documentWidth).toDouble().takeIf { it > 0 } ?: 640.0, (vb?.height() ?: svg.documentHeight).toDouble().takeIf { it > 0 } ?: 480.0, 0.0)
        }
        val f = if (src.startsWith("media:")) Store.get(ctx).mediaFile(src.removePrefix("media:")) else null
        val mime = f?.let { Store.get(ctx).sniffMime(it) } ?: "image/png"
        // Görsel değilse (ya da türü tanınmadıysa ve görsel olarak açılmıyorsa) telefonun çözücüsüyle süresi okunur
        val notImage = f != null && !mime.startsWith("image/") && run { val o = BitmapFactory.Options().apply { inJustDecodeBounds = true }; f.inputStream().use { BitmapFactory.decodeStream(it, null, o) }; o.outWidth <= 0 }
        if (f != null && notImage) {
            val r = MediaMetadataRetriever()
            try {
                r.setDataSource(f.absolutePath)
                val d = (r.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)?.toDoubleOrNull() ?: 5000.0) / 1000
                var w = r.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH)?.toDoubleOrNull() ?: 640.0
                var h = r.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT)?.toDoubleOrNull() ?: 360.0
                val rot = r.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_ROTATION)?.toIntOrNull() ?: 0
                if (rot == 90 || rot == 270) { val x = w; w = h; h = x }
                MediaInfo(w, h, d)
            } finally { r.release() }
        } else {
            val o = BitmapFactory.Options().apply { inJustDecodeBounds = true }
            (f?.inputStream() ?: ctx.assets.open(src)).use { BitmapFactory.decodeStream(it, null, o) }
            MediaInfo(o.outWidth.toDouble().takeIf { it > 0 } ?: 512.0, o.outHeight.toDouble().takeIf { it > 0 } ?: 512.0, 0.0)
        }
    }.getOrDefault(MediaInfo(512.0, 512.0, 5.0))
}

private val TABS = listOf("shape" to ("Şekil" to "shapes"), "media" to ("Medya" to "image"), "audio" to ("Ses" to "music"), "text" to ("Metin" to "text"), "cb" to ("CB" to "ball"), "flags" to ("Bayrak" to "flag"))

@Composable
fun AddPanel(s: EditorState, tab: String?, setTab: (String) -> Unit, replaceFlagOf: String?, W: Float, onClose: () -> Unit, toast: (String) -> Unit) {
    val ctx = LocalContext.current
    val store = remember { Store.get(ctx) }
    val scope = rememberCoroutineScope()
    val defDur by store.defaultDuration.collectAsState()
    val p = s.project
    val t = s.time

    val addImage = { src: String, name: String, frac: Double ->
        scope.launch {
            val i = mediaInfo(ctx, src)
            val k = min(p.width, p.height) * frac / max(i.w, i.h)
            s.addLayer(makeLayer(p, t, defDur, "image", name) { it.copy(src = src, w = (i.w * k).roundToInt().toDouble(), h = (i.h * k).roundToInt().toDouble()) })
            Packs.pushRecent(ctx, src)
            onClose()
        }
    }
    val addVideo = { src: String, name: String ->
        scope.launch {
            val i = mediaInfo(ctx, src)
            val k = min(p.width / i.w, p.height / i.h)
            s.addLayer(makeLayer(p, t, Math.round(i.dur * 100) / 100.0, "video", name) { it.copy(src = src, srcDur = i.dur.takeIf { d -> d > 0 }, w = (i.w * k).roundToInt().toDouble(), h = (i.h * k).roundToInt().toDouble()) })
            onClose()
        }
    }
    val addAudio = { src: String, name: String ->
        scope.launch {
            val i = mediaInfo(ctx, src)
            s.addLayer(makeLayer(p, t, Math.round((i.dur.takeIf { it > 0 } ?: 5.0) * 100) / 100.0, "audio", name) { it.copy(src = src, srcDur = i.dur.takeIf { d -> d > 0 }, w = 0.0, h = 0.0, fill = "#7B4FD6") })
            toast("\"$name\" eklendi. Oynatınca duyulur, dışa aktarınca videoya eklenir.")
            onClose()
        }
    }
    /** Çok parçalı pack öğesi: bütün gibi gelir ama her parça ayrı katmandır */
    val addParts = { it: PackItem ->
        scope.launch {
            val parts = it.parts!!; val root = it.root ?: 0
            val i = mediaInfo(ctx, parts[root].src)
            val k = min(p.width, p.height) * (if ("wardencb/" in it.src) 0.6 else 0.45) / max(i.w, i.h)
            val ids = parts.map { uid() }
            val made = parts.mapIndexed { j, pt ->
                makeLayer(p, t, defDur, "image", "${it.name} ${pt.name}") { l ->
                    val b = l.copy(id = ids[j], src = pt.src, w = (i.w * k).roundToInt().toDouble(), h = (i.h * k).roundToInt().toDouble())
                    if (j == root) b else b.copy(parent = ids[pt.parent ?: root], x = Anim(0.0), y = Anim(0.0))
                }
            }.toMutableList()
            s.update { pp ->
                val layers = pp.layers.toMutableList()
                val backs = made.filterIndexed { j, _ -> parts[j].back }; val rest = made.filterIndexed { j, _ -> !parts[j].back }
                var at = layers.size
                if (backs.isNotEmpty()) {
                    val isBody = { l: Layer -> l.parent == null && (l.type == "cb" || Regex("govdeler/").containsMatchIn(l.src ?: "") || layers.any { c -> c.parent == l.id }) }
                    val body = layers.lastOrNull(isBody)
                    if (body != null) {
                        val fam = mutableSetOf(body.id); var ch = true
                        while (ch) { ch = false; for (l in layers) if (l.parent != null && l.parent in fam && l.id !in fam) { fam += l.id; ch = true } }
                        at = layers.indexOfFirst { it.id in fam }
                        // Ushanka basık gövdeye konuyorsa ölçüp tam yerine oturt (gövde 400, ushanka 516 birim)
                        if (Regex("govdeler/wardencb-cizgi").containsMatchIn(body.src ?: "") && "ushanka" in it.src) {
                            val u = body.w / 400; val ri = made.indexOfFirst { m -> m.id == ids[root] }
                            val r = made[ri].copy(w = (516 * u).roundToInt().toDouble(), h = (416 * u).roundToInt().toDouble(), x = Anim((body.x.at(t) + 28 * u).roundToInt().toDouble()), y = Anim((body.y.at(t) - 26 * u).roundToInt().toDouble()), scale = Anim(body.scale.at(t)))
                            made[ri] = r
                            for (bi in made.indices) if (parts[bi].back) made[bi] = made[bi].copy(w = r.w, h = r.h)
                        }
                    }
                }
                val backs2 = made.filterIndexed { j, _ -> parts[j].back }; val rest2 = made.filterIndexed { j, _ -> !parts[j].back }
                rest.size; backs.size
                layers.addAll(at.coerceIn(0, layers.size), backs2)
                pp.copy(layers = layers + rest2)
            }
            s.selectedId = ids[root]
            Packs.pushRecent(ctx, it.src)
            toast("${it.name}: ${parts.size} ayrı katman olarak eklendi${if (parts.any { x -> x.back }) " (arka kulak CB'nin arkasında)" else ""}.")
            onClose()
        }
    }
    /** Gövde kur: çizgi (ebeveyn) + beyaz iç (takip eder) [+ bayrak iç'e kırpılmış] [+ gözler] */
    val buildBody = { shape: String, flagSrc: String?, flagName: String? ->
        val (made, lineId) = cbBodyLayers(p, t, defDur, shape, flagSrc, flagName)
        s.addLayers(made, lineId)
        toast(if (flagSrc != null) "CB hazır: çizgiyi taşıyınca hepsi birlikte hareket eder." else "Gövde kuruldu: iç, çizgiyi takip ediyor.")
        onClose()
    }

    Box(Modifier.fillMaxSize().tap(onClick = onClose)) {
        Column(Modifier.align(Alignment.BottomCenter).navigationBarsPadding().padding(horizontal = (W * 0.022f).dp, vertical = 8.dp).fillMaxWidth().heightIn(max = 460.dp)
            .clip(RoundedCornerShape(14.dp)).background(C.dPanel).border(1.dp, Color(0xFF34488A), RoundedCornerShape(14.dp)).tap { }) {
            if (replaceFlagOf != null) Row(Modifier.fillMaxWidth().padding(4.dp), verticalAlignment = Alignment.CenterVertically) {
                Text("Bayrağı Değiştir", fontWeight = FontWeight.Bold, color = C.dText, modifier = Modifier.weight(1f).padding(horizontal = 10.dp))
                Box(Modifier.size(44.dp).tap(onClick = onClose), contentAlignment = Alignment.Center) { Ico("close", C.dText, 20.dp, 2.2f) }
            } else Row(Modifier.fillMaxWidth().padding(4.dp), horizontalArrangement = Arrangement.spacedBy(2.dp), verticalAlignment = Alignment.CenterVertically) {
                TABS.forEach { (id, lb) ->
                    val on = tab == id
                    Column(Modifier.weight(1f).height(52.dp).target("atab:${lb.first}") { setTab(id) }.clip(RoundedCornerShape(10.dp)).background(if (on) Color(0xFF2E3F7E) else Color.Transparent).tap { setTab(id) },
                        horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.Center) {
                        Ico(lb.second, if (on) C.turq else C.dText, 22.dp)
                        Spacer(Modifier.height(3.dp))
                        Text(lb.first, fontSize = 10.5.sp, fontWeight = FontWeight.SemiBold, color = if (on) C.turq else C.dText)
                    }
                }
                Box(Modifier.size(44.dp).target("add-close", onClose).tap(onClick = onClose), contentAlignment = Alignment.Center) { Ico("close", C.dText, 20.dp, 2.2f) }
            }
            LaunchedEffect(tab) { UiState.addTab = TABS.find { it.first == tab }?.second?.first }
            val tb = if (replaceFlagOf != null) "flags" else tab
            if (tb != null) Column(Modifier.fillMaxWidth().drawBehind { drawLine(C.dLine, Offset(0f, 0f), Offset(size.width, 0f), 1.dp.toPx()) }.padding(start = 10.dp, end = 10.dp, top = 6.dp, bottom = 10.dp)) {
                when (tb) {
                    "shape" -> Pager(SHAPES, 7) { sh ->
                        val addShape = { s.addLayer(makeLayer(p, t, defDur, "shape", sh.name) { it.copy(shape = sh.kind, w = sh.w ?: 240.0, h = sh.h ?: 240.0, pts = sh.pts) }); onClose() }
                        Box(Modifier.fillMaxWidth().height(44.dp).target("cell:${sh.name}", addShape).tap {
                            s.addLayer(makeLayer(p, t, defDur, "shape", sh.name) { it.copy(shape = sh.kind, w = sh.w ?: 240.0, h = sh.h ?: 240.0, pts = sh.pts) }); onClose()
                        }, contentAlignment = Alignment.Center) { ShapeIcon(sh) }
                    }
                    "media" -> MediaTab(s, onAudio = { setTab("audio") }, toast = toast) { src, name, kind -> if (kind == "video") addVideo(src, name) else addImage(src, name, 0.7) }
                    "audio" -> AudioTab(s, toast) { src, name -> addAudio(src, name) }
                    "text" -> TextTab { text -> s.addLayer(makeLayer(p, t, defDur, "text", text.take(18).ifEmpty { "Metin" }) { it.copy(text = text, fontSize = (p.height / 12.0).roundToInt().toDouble(), fill = "#0D1631", w = (p.width * 0.6).roundToInt().toDouble(), h = (p.height / 8.0).roundToInt().toDouble()) }); onClose() }
                    "cb" -> CBTab(toast, onPick = { it -> if (it.parts != null) addParts(it) else addImage(it.src, it.name, 0.45) }, onBody = { buildBody(it, null, null) })
                    "flags" -> FlagsTab(replaceFlagOf != null, toast) { src, name, mode ->
                        if (replaceFlagOf != null) { s.updateLayer(replaceFlagOf) { it.copy(src = src) }; onClose() }
                        else if (mode != "flat") buildBody(when (mode) { "cbsoft" -> "yumusak-top"; "cbwarden" -> "wardencb"; else -> "top" }, src, name)
                        else addImage(src, "$name Bayrağı", 0.6)
                    }
                }
            }
        }
    }
}

@Composable
private fun ShapeIcon(sh: ShapeDef) {
    Canvas(Modifier.size(40.dp)) {
        val l = Layer("x", "", "shape", 0.0, 1.0, w = if (sh.kind == "bar") 64.0 else 58.0, h = if (sh.kind == "bar") 14.0 else 56.0, shape = sh.kind, pts = sh.pts)
        drawIntoCanvas { c ->
            val nc = c.nativeCanvas
            nc.save(); nc.translate(size.width / 2, size.height / 2); nc.scale(size.width / 80f, size.width / 80f)
            fillShape(nc, l, android.graphics.Paint(android.graphics.Paint.ANTI_ALIAS_FLAG).apply { color = parseCol("#B9C6DC") })
            nc.restore()
        }
    }
}

/** Sayfalı ızgara: parmakla sağa-sola kaydırılır, altta sayfa noktaları */
@OptIn(ExperimentalFoundationApi::class)
@Composable
fun <T> Pager(items: List<T>, cols: Int, rows: Int = 2, cell: @Composable (T) -> Unit) {
    if (items.isEmpty()) return
    val per = cols * rows
    val pages = items.chunked(per)
    val st = rememberPagerState { pages.size }
    val scope = rememberCoroutineScope()
    Column {
        HorizontalPager(st, Modifier.fillMaxWidth()) { pg ->
            Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                pages[pg].chunked(cols).forEach { row ->
                    Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                        row.forEach { Box(Modifier.weight(1f)) { cell(it) } }
                        repeat(cols - row.size) { Spacer(Modifier.weight(1f)) }
                    }
                }
            }
        }
        if (pages.size > 1) Box(Modifier.fillMaxWidth().padding(top = 6.dp), contentAlignment = Alignment.Center) {
            if (pages.size <= 8) Row(horizontalArrangement = Arrangement.spacedBy(2.dp), verticalAlignment = Alignment.CenterVertically) {
                pages.indices.forEach { i ->
                    Box(Modifier.size(22.dp).tap { scope.launch { st.animateScrollToPage(i) } }, contentAlignment = Alignment.Center) {
                        Box(Modifier.size(if (i == st.currentPage) 18.dp else 7.dp, 7.dp).clip(RoundedCornerShape(4.dp)).background(if (i == st.currentPage) C.turq else C.dLine))
                    }
                }
            } else Row(verticalAlignment = Alignment.CenterVertically) {
                Box(Modifier.size(44.dp, 22.dp).tap(st.currentPage > 0) { scope.launch { st.animateScrollToPage(st.currentPage - 1) } }, contentAlignment = Alignment.Center) { Ico("back", C.dText, 18.dp) }
                Text("${st.currentPage + 1} / ${pages.size}", fontSize = 12.sp, color = C.dText2, textAlign = TextAlign.Center, modifier = Modifier.widthIn(min = 56.dp))
                Box(Modifier.size(44.dp, 22.dp).tap(st.currentPage < pages.size - 1) { scope.launch { st.animateScrollToPage(st.currentPage + 1) } }, contentAlignment = Alignment.Center) { Ico("chevR", C.dText, 18.dp) }
            }
            if (pages.size <= 8) Text("${st.currentPage + 1}/${pages.size}", fontSize = 11.sp, color = C.dText2, modifier = Modifier.align(Alignment.CenterEnd))
        }
    }
}

@Composable
private fun TextTab(onAdd: (String) -> Unit) {
    var v by remember { mutableStateOf("") }
    val fr = remember { FocusRequester() }
    LaunchedEffect(Unit) { runCatching { fr.requestFocus() } }
    Row(horizontalArrangement = Arrangement.spacedBy(8.dp), verticalAlignment = Alignment.CenterVertically) {
        BasicTextField(v, { v = it }, singleLine = true, textStyle = TextStyle(color = C.dText, fontSize = 15.sp, fontFamily = Inter),
            keyboardOptions = KeyboardOptions(imeAction = ImeAction.Done), keyboardActions = KeyboardActions(onDone = { if (v.isNotEmpty()) onAdd(v) }),
            cursorBrush = androidx.compose.ui.graphics.SolidColor(C.turq),
            decorationBox = { inner -> Box { if (v.isEmpty()) Text("Yazını gir", color = C.dDim, fontSize = 15.sp); inner() } },
            modifier = Modifier.weight(1f).height(40.dp).focusRequester(fr).clip(RoundedCornerShape(10.dp)).border(1.dp, C.dLine, RoundedCornerShape(10.dp)).background(C.dDeep).padding(horizontal = 12.dp, vertical = 10.dp))
        DBtn("Ekle", enabled = v.isNotEmpty(), modifier = Modifier.width(80.dp)) { if (v.isNotEmpty()) onAdd(v) }
    }
}

@Composable
fun Chip(label: String, on: Boolean, icon: String? = null, color: Color? = null, onClick: () -> Unit) {
    Row(Modifier.height(34.dp).clip(RoundedCornerShape(17.dp)).background(if (on) C.turq else C.dPanel2).tap(onClick = onClick).padding(horizontal = 12.dp),
        verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(6.dp)) {
        val fg = color ?: if (on) C.dDeep else C.dText2
        if (icon != null) Ico(icon, fg, 14.dp)
        Text(label, fontSize = 13.sp, fontWeight = FontWeight.SemiBold, color = fg, maxLines = 1)
    }
}

// ---------- CB Araçları ----------
@Composable
private fun CBTab(toast: (String) -> Unit, onPick: (PackItem) -> Unit, onBody: (String) -> Unit) {
    val ctx = LocalContext.current
    val scope = rememberCoroutineScope()
    val prefs = remember { ctx.getSharedPreferences("wm", Context.MODE_PRIVATE) }
    var which by remember { mutableStateOf(prefs.getString("packTab", "ready") ?: "ready") }
    val ready = remember { Packs.ready(ctx) }
    var folder by remember(which) { mutableStateOf("Tümü") }
    var mine by remember { mutableStateOf(Packs.userPack(ctx)) }
    var myFolders by remember { mutableStateOf(Packs.userFolders(ctx)) }
    var edit by remember { mutableStateOf(false) }
    var askFolder by remember { mutableStateOf<List<android.net.Uri>?>(null) }
    var newFolder by remember { mutableStateOf(false) }
    LaunchedEffect(which) { prefs.edit().putString("packTab", which).apply(); edit = false }
    val upload = androidx.activity.compose.rememberLauncherForActivityResult(androidx.activity.result.contract.ActivityResultContracts.PickMultipleVisualMedia(40)) { uris ->
        if (uris.isNotEmpty()) { if (folder != "Tümü" && folder != "Son") scope.launch { addUserPack(ctx, uris, folder); mine = Packs.userPack(ctx); toast("${uris.size} PNG \"$folder\" klasörüne eklendi.") } else askFolder = uris }
    }
    val recent = Packs.recent(ctx).filter { it.startsWith("packs/") || mine.any { m -> "media:" + m.id == it } }
    val itemOf = { src: String -> ready.flatMap { it.items }.find { it.src == src } ?: PackItem(mine.find { "media:" + it.id == src }?.name ?: "", src) }
    val folders = if (which == "ready") ready.map { it.name } else myFolders
    val shown: List<PackItem> = when {
        folder == "Son" -> recent.map(itemOf)
        which == "ready" -> ready.filter { folder == "Tümü" || it.name == folder }.flatMap { it.items }
        else -> mine.filter { folder == "Tümü" || it.folder == folder }.map { PackItem(it.name, "media:" + it.id, it.id) }
    }
    Column {
        Row(Modifier.fillMaxWidth().clip(RoundedCornerShape(8.dp)).background(C.dPanel2).padding(3.dp), horizontalArrangement = Arrangement.spacedBy(2.dp)) {
            listOf("ready" to "Hazır Pack", "mine" to "Yüklediğim Pack").forEach { (k, lb) ->
                Box(Modifier.weight(1f).height(36.dp).clip(RoundedCornerShape(6.dp)).background(if (which == k) C.text else Color.Transparent).tap { which = k }, contentAlignment = Alignment.Center) {
                    Text(lb, fontSize = 14.sp, fontWeight = FontWeight.SemiBold, color = if (which == k) C.cyan else C.dText)
                }
            }
        }
        Spacer(Modifier.height(8.dp))
        Row(Modifier.horizontalScroll(rememberScrollState()).padding(bottom = 8.dp), horizontalArrangement = Arrangement.spacedBy(6.dp)) {
            if (recent.isNotEmpty()) Chip("Son kullanılanlar", folder == "Son", "undo") { folder = "Son" }
            (listOf("Tümü") + folders).forEach { f -> Box(Modifier.target("chip:$f") { folder = f }) { Chip(f, folder == f, if (f != "Tümü") "folder" else null) { folder = f } } }
            if (which == "mine") {
                Chip("Klasör", false, "plus") { newFolder = true }
                if (mine.isNotEmpty()) Chip(if (edit) "Bitti" else "Düzenle", edit) { edit = !edit }
            }
        }
        if (which == "ready" && folder == "Gövdeler") Row(Modifier.horizontalScroll(rememberScrollState()).padding(bottom = 8.dp), horizontalArrangement = Arrangement.spacedBy(6.dp)) {
            listOf("wardencb" to "Basık top", "yumusak-top" to "Yumuşak top", "yumusak-kup" to "Yumuşak küp", "top" to "Top", "dikdortgen" to "Dikdörtgen", "kup" to "Küp", "ucgen" to "Üçgen").forEach { (k, n) ->
                Chip("$n gövdesi kur", false, "ball", C.turq) { onBody(k) }
            }
        }
        LaunchedEffect(folder) { PackUi.folder = folder }
        val items: List<PackItem> = (if (which == "mine") listOf(PackItem("PNG Yükle", "__upload")) else emptyList()) + shown
        // Asistan "Ushanka"yı bulabilsin: listede varsa ilk sayfadaymış gibi hedef olur
        items.find { it.name == "Ushanka" }?.let { u -> Box(Modifier.size(1.dp).target("pack:Ushanka") { onPick(u) }) }
        Box(Modifier.target("pack-grid")) { Pager(items, 5) { it ->
            Column {
                if (it.src == "__upload") {
                    Box(Modifier.fillMaxWidth().aspectRatio(1f).clip(RoundedCornerShape(10.dp)).background(C.dPanel2).border(2.dp, C.dLine, RoundedCornerShape(10.dp))
                        .tap { upload.launch(androidx.activity.result.PickVisualMediaRequest(androidx.activity.result.contract.ActivityResultContracts.PickVisualMedia.ImageOnly)) }, contentAlignment = Alignment.Center) { Ico("upload", C.turq, 22.dp) }
                    Text("Galeriden yükle", fontSize = 10.sp, color = C.dText2, maxLines = 1, textAlign = TextAlign.Center, modifier = Modifier.fillMaxWidth().padding(top = 3.dp))
                } else {
                    Box(Modifier.fillMaxWidth().aspectRatio(1f).clip(RoundedCornerShape(10.dp)).checker().tap(!edit) { onPick(it) }.padding(6.dp), contentAlignment = Alignment.Center) {
                        AssetImg(it.src, Modifier.fillMaxSize(), 200)
                        if (edit && it.id != null) Box(Modifier.align(Alignment.TopEnd).size(24.dp).clip(CircleShape).background(Color(0xFFC8323F)).tap {
                            Packs.saveUserPack(ctx, Packs.userPack(ctx).filter { x -> x.id != it.id }); mine = Packs.userPack(ctx)
                        }, contentAlignment = Alignment.Center) { Ico("close", C.dText, 14.dp, 2.4f) }
                    }
                    Text(it.name, fontSize = 10.sp, color = C.dText2, maxLines = 1, overflow = TextOverflow.Ellipsis, textAlign = TextAlign.Center, modifier = Modifier.fillMaxWidth().padding(top = 3.dp))
                }
            }
        } }
        if (which == "mine" && mine.isEmpty()) Text("Kendi PNG'lerini yükle, klasörlere ayır; burada hızlıca kullan.", color = C.dText2, fontSize = 12.sp, modifier = Modifier.padding(top = 6.dp))
    }
    if (newFolder) AskText("Yeni klasör adı", "", "Oluştur", { newFolder = false }) { n -> newFolder = false; if (n.isNotBlank()) { Packs.addUserFolder(ctx, n.trim()); myFolders = Packs.userFolders(ctx); folder = n.trim() } }
    askFolder?.let { uris -> AskText("Hangi klasöre eklensin?", "Genel", "Ekle", { askFolder = null }) { n ->
        askFolder = null; val target = n.ifBlank { "Genel" }
        scope.launch { addUserPack(ctx, uris, target); Packs.addUserFolder(ctx, target); mine = Packs.userPack(ctx); myFolders = Packs.userFolders(ctx); folder = target; toast("${uris.size} PNG \"$target\" klasörüne eklendi.") }
    } }
}

private suspend fun addUserPack(ctx: Context, uris: List<android.net.Uri>, folder: String) {
    val store = Store.get(ctx)
    val list = Packs.userPack(ctx).toMutableList()
    for (u in uris) {
        val src = store.putMedia(u)
        val name = runCatching { ctx.contentResolver.query(u, arrayOf(android.provider.OpenableColumns.DISPLAY_NAME), null, null, null)?.use { c -> if (c.moveToFirst()) c.getString(0) else null } }.getOrNull()?.substringBeforeLast('.') ?: "Görsel"
        list += Packs.UserItem(src.removePrefix("media:"), name, folder)
    }
    Packs.saveUserPack(ctx, list)
}

/** Yazı soran pencere (eski uygulamadaki askText) */
@Composable
fun AskText(title: String, initial: String, ok: String, onDismiss: () -> Unit, onOk: (String) -> Unit) {
    var v by remember { mutableStateOf(initial) }
    val fr = remember { FocusRequester() }
    LaunchedEffect(Unit) { runCatching { fr.requestFocus() } }
    androidx.compose.ui.window.Dialog(onDismissRequest = onDismiss) {
        Column(Modifier.clip(RoundedCornerShape(16.dp)).background(C.dPanel).padding(18.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
            Text(title, color = C.dText, fontSize = 16.sp, fontWeight = FontWeight.Bold)
            BasicTextField(v, { v = it }, singleLine = true, textStyle = TextStyle(color = C.dText, fontSize = 15.sp, fontFamily = Inter), cursorBrush = androidx.compose.ui.graphics.SolidColor(C.turq),
                keyboardOptions = KeyboardOptions(imeAction = ImeAction.Done), keyboardActions = KeyboardActions(onDone = { onOk(v) }),
                modifier = Modifier.fillMaxWidth().focusRequester(fr).clip(RoundedCornerShape(10.dp)).border(1.dp, C.dLine, RoundedCornerShape(10.dp)).background(C.dDeep).padding(12.dp))
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                DBtn("Vazgeç", ghost = true, modifier = Modifier.weight(1f), onClick = onDismiss)
                DBtn(ok, modifier = Modifier.weight(1f)) { onOk(v) }
            }
        }
    }
}

// ---------- Bayraklar ----------
@Composable
private fun FlagsTab(replace: Boolean, toast: (String) -> Unit, onPick: (String, String, String) -> Unit) {
    val ctx = LocalContext.current
    val scope = rememberCoroutineScope()
    val all = remember { Packs.flags(ctx) }
    var q by remember { mutableStateOf("") }
    var cont by remember { mutableStateOf("Tümü") }
    var mine by remember { mutableStateOf(Packs.userFlags(ctx)) }
    var ask by remember { mutableStateOf<Pair<String, String>?>(null) }
    var nameFor by remember { mutableStateOf<android.net.Uri?>(null) }
    val pickFlag = androidx.activity.compose.rememberLauncherForActivityResult(androidx.activity.result.contract.ActivityResultContracts.PickVisualMedia()) { u -> if (u != null) nameFor = u }
    val tr = java.util.Locale("tr")
    val ql = q.lowercase(tr)
    val list = all.filter { (cont == "Tümü" || Packs.CONT[it.continent] == cont) && (ql.isEmpty() || it.name.lowercase(tr).contains(ql) || it.en.lowercase().contains(ql) || it.code == ql) }
    val choose = { src: String, name: String -> if (replace) onPick(src, name, "flat") else ask = src to name }
    Column {
        BasicTextField(q, { q = it }, singleLine = true, textStyle = TextStyle(color = C.dText, fontSize = 14.sp, fontFamily = Inter), cursorBrush = androidx.compose.ui.graphics.SolidColor(C.turq),
            decorationBox = { inner -> Box { if (q.isEmpty()) Text("Bayrak ara (ör. Türkiye)", color = C.dDim, fontSize = 14.sp); inner() } },
            modifier = Modifier.fillMaxWidth().height(36.dp).clip(RoundedCornerShape(10.dp)).border(1.dp, C.dLine, RoundedCornerShape(10.dp)).background(C.dDeep).padding(horizontal = 12.dp, vertical = 9.dp))
        Spacer(Modifier.height(8.dp))
        Row(Modifier.horizontalScroll(rememberScrollState()).padding(bottom = 8.dp), horizontalArrangement = Arrangement.spacedBy(6.dp)) {
            (listOf("Tümü") + Packs.CONT.values.filter { it != "Antarktika" }).forEach { c -> Chip(c, cont == c) { cont = c } }
        }
        data class FI(val key: String, val src: String, val name: String)
        val items = (if (ql.isNotEmpty() || cont != "Tümü" || replace) emptyList() else listOf(FI("__add", "", "Bayrak ekle"))) +
            mine.filter { ql.isEmpty() || it.name.lowercase(tr).contains(ql) }.map { FI(it.id, "media:" + it.id, it.name) } +
            list.map { FI(it.code, "flags/${it.code}.svg", it.name) }
        if (items.isEmpty()) Text("\"$q\" için bayrak bulunamadı.", color = C.dText2, fontSize = 13.sp)
        else androidx.compose.foundation.lazy.grid.LazyVerticalGrid(androidx.compose.foundation.lazy.grid.GridCells.Fixed(5), Modifier.fillMaxWidth().heightIn(max = 190.dp).target("flags-grid"),
            horizontalArrangement = Arrangement.spacedBy(6.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
            items(items.size, key = { items[it].key }) { i ->
                val f = items[i]
                Column(Modifier.target("flag:${f.key}") { choose(f.src, f.name) }.tap { if (f.key == "__add") pickFlag.launch(androidx.activity.result.PickVisualMediaRequest(androidx.activity.result.contract.ActivityResultContracts.PickVisualMedia.ImageOnly)) else choose(f.src, f.name) }) {
                    if (f.key == "__add") Box(Modifier.fillMaxWidth().aspectRatio(4f / 3).clip(RoundedCornerShape(4.dp)).border(2.dp, C.dLine, RoundedCornerShape(4.dp)), contentAlignment = Alignment.Center) { Ico("plus", C.turq, 22.dp) }
                    else Box(Modifier.fillMaxWidth().aspectRatio(4f / 3).clip(RoundedCornerShape(4.dp))) { AssetImg(f.src, Modifier.fillMaxSize(), 120, crop = true) }
                    Text(f.name, fontSize = 10.sp, color = C.dText2, maxLines = 1, overflow = TextOverflow.Ellipsis, modifier = Modifier.padding(top = 3.dp))
                }
            }
        }
    }
    ask?.let { (src, name) ->
        ChoiceBox({ ask = null }) {
            Text(name, color = C.dText, fontSize = 16.sp, fontWeight = FontWeight.Bold)
            DBtn("Yumuşak CB olarak ekle", icon = "ball") { onPick(src, name, "cbsoft"); ask = null }
            DBtn("Yuvarlak CB olarak ekle", ghost = true, icon = "ball") { onPick(src, name, "cb"); ask = null }
            DBtn("Basık CB olarak ekle", ghost = true, icon = "ball") { onPick(src, name, "cbwarden"); ask = null }
            Text("Top gövdesi kurulur: çizgi + beyaz iç + iç'e kırpılmış bayrak + gözler. Hepsi çizgiyi takip eder.", fontSize = 12.sp, color = C.dText2)
            DBtn("Düz bayrak olarak ekle", ghost = true, icon = "flag") { onPick(src, name, "flat"); ask = null }
            DBtn("Vazgeç", ghost = true) { ask = null }
        }
    }
    nameFor?.let { u -> AskText("Bayrağın adı", "Bayrağım", "Ekle", { nameFor = null }) { n ->
        nameFor = null
        scope.launch {
            val src = Store.get(ctx).putMedia(u)
            Packs.saveUserFlags(ctx, Packs.userFlags(ctx) + Packs.UserItem(src.removePrefix("media:"), n.ifBlank { "Bayrağım" }, ""))
            mine = Packs.userFlags(ctx); toast("\"${n.ifBlank { "Bayrağım" }}\" Bayraklarım'a eklendi.")
        }
    } }
}
