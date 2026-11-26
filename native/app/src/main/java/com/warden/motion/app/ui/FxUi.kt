package com.warden.motion.app.ui

import android.content.Context
import android.graphics.ImageDecoder
import android.graphics.drawable.AnimatedImageDrawable
import android.os.Build
import android.widget.ImageView
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.gestures.detectHorizontalDragGestures
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.GridItemSpan
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.*
import androidx.compose.material3.Text
import androidx.compose.foundation.gestures.awaitEachGesture
import androidx.compose.foundation.gestures.awaitFirstDown
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.viewinterop.AndroidView
import com.warden.motion.app.model.*
import com.warden.motion.app.render.GlFx
import java.util.Locale
import kotlin.math.roundToInt

// ---------------------------------------------------------------------------------------------
// Efekt tarayıcısının renkleri (uygulamanın lacivert paleti)
// ---------------------------------------------------------------------------------------------
private val FB_BG = Color(0xFF17224A)
private val FB_BAR = Color(0xFF121D40)
private val FB_CARD = Color(0xFF1E2A55)
private val FB_ROW = Color(0xFF243266)
private val FB_SEL = Color(0xFF2C3E78)
private val GOLD = Color(0xFFF2C230)
private val TR = Locale("tr")

/** Favoriler ve son kullanılanlar (efekt "tür" ya da hazır ayar "tür:KOD") */
object FxPrefs {
    private fun p(c: Context) = c.getSharedPreferences("wm-fx", Context.MODE_PRIVATE)
    var favs by mutableStateOf<List<String>>(emptyList()); private set
    var recent by mutableStateOf<List<String>>(emptyList()); private set
    private var loaded = false
    fun load(c: Context) {
        if (loaded) return; loaded = true
        favs = p(c).getString("fav", "")!!.split('|').filter { it.isNotBlank() }
        recent = p(c).getString("recent", "")!!.split('|').filter { it.isNotBlank() }
    }
    fun toggleFav(c: Context, id: String) { favs = if (id in favs) favs - id else listOf(id) + favs; p(c).edit().putString("fav", favs.joinToString("|")).apply() }
    fun used(c: Context, id: String) { recent = (listOf(id) + recent.filter { it != id }).take(24); p(c).edit().putString("recent", recent.joinToString("|")).apply() }
}

private fun catColors(i: Int): List<Color> = listOf(
    listOf(0xFF1B3A7A, 0xFF6B3FA0), listOf(0xFF0B1430, 0xFF1F68E0), listOf(0xFF2A3A72, 0xFF8FA6D6), listOf(0xFF1B3A7A, 0xFF22D3C5),
    listOf(0xFF3A1B7A, 0xFFE84393), listOf(0xFF0E5A63, 0xFF3FD0F0), listOf(0xFF1F3270, 0xFFF2C230), listOf(0xFF0B1430, 0xFF8F7CF0),
    listOf(0xFF102A4A, 0xFF22B14C), listOf(0xFF2A1B4A, 0xFF8FA6D6), listOf(0xFF1B2A55, 0xFFF7F8FA), listOf(0xFF1F2A55, 0xFF5C6E9E),
    listOf(0xFF0E3A55, 0xFF9AD8FF), listOf(0xFF3A1030, 0xFFFF5BA7), listOf(0xFF102040, 0xFF3B9BFF), listOf(0xFF2A1040, 0xFF22D3C5),
    listOf(0xFFB0121E, 0xFFE30A17),
)[i % 17].map { Color(it) }

/** Efektin hareketli önizlemesi (assets/fx/prev/<tür>.webp); yoksa kategori renginde kutu */
@Composable
fun FxThumb(type: String, modifier: Modifier, corner: Int = 8) {
    val ctx = LocalContext.current
    val m = remember(type) { fxMeta(type) }
    val has = remember(type) { runCatching { ctx.assets.open("fx/prev/$type.webp").close(); true }.getOrDefault(false) }
    Box(modifier.clip(RoundedCornerShape(corner.dp)).background(Brush.linearGradient(catColors(m.catIndex))), contentAlignment = Alignment.Center) {
        if (has && Build.VERSION.SDK_INT >= 28) {
            AndroidView(factory = { c -> ImageView(c).apply { scaleType = ImageView.ScaleType.CENTER_CROP } }, modifier = Modifier.fillMaxSize(), update = { iv ->
                if (iv.tag != type) {
                    iv.tag = type
                    runCatching {
                        val d = ImageDecoder.decodeDrawable(ImageDecoder.createSource(ctx.assets, "fx/prev/$type.webp"))
                        iv.setImageDrawable(d); (d as? AnimatedImageDrawable)?.start()
                    }
                }
            })
        } else if (has) {
            val bmp = remember(type) { runCatching { ctx.assets.open("fx/prev/$type.webp").use { android.graphics.BitmapFactory.decodeStream(it) } }.getOrNull() }
            if (bmp != null) androidx.compose.foundation.Image(bmp.asImageBitmap(), null, Modifier.fillMaxSize(), contentScale = androidx.compose.ui.layout.ContentScale.Crop)
        } else Text(m.name.take(1), fontSize = 22.sp, fontWeight = FontWeight.ExtraBold, color = Color(0xCCF7F8FA))
    }
}

private fun norm(s: String) = s.lowercase(TR).replace('ı', 'i').replace('ğ', 'g').replace('ü', 'u').replace('ş', 's').replace('ö', 'o').replace('ç', 'c')

/** Arama: ad, İngilizce ad, açıklama, etiket ve hazır ayar adlarında */
fun searchFx(q: String): List<FxMeta> {
    val n = norm(q.trim()); if (n.isEmpty()) return emptyList()
    fun score(m: FxMeta): Int {
        val name = norm(m.name); val en = norm(m.en)
        return when {
            name.startsWith(n) -> 100; name.contains(n) -> 80; en.contains(n) -> 70
            m.tags.any { norm(it) == n } -> 60; m.tags.any { norm(it).contains(n) } -> 50
            m.presets.any { norm(it.name).contains(n) } -> 40; norm(m.desc).contains(n) -> 30; else -> 0
        }
    }
    return FX.map { it to score(it) }.filter { it.second > 0 }.sortedByDescending { it.second }.map { it.first }
}

/**
 * Efekt Tarayıcısı (Alight Motion düzeni): arama, Önerilenler, Son & Favoriler, kategori kutuları.
 * onPick(tür, hazır ayar kodu ya da null)
 */
@OptIn(ExperimentalFoundationApi::class)
@Composable
fun EffectBrowser(onClose: () -> Unit, onPick: (String, String?) -> Unit) {
    val ctx = LocalContext.current
    LaunchedEffect(Unit) { FxPrefs.load(ctx) }
    var q by remember { mutableStateOf("") }
    var search by remember { mutableStateOf(false) }
    var cat by remember { mutableStateOf<Int?>(null) }
    var card by remember { mutableStateOf<Pair<List<FxMeta>, Int>?>(null) }
    androidx.activity.compose.BackHandler { when { card != null -> card = null; search -> { search = false; q = "" }; cat != null -> cat = null; else -> onClose() } }
    DisposableEffect(Unit) { UiState.fxb = true; onDispose { UiState.fxb = false } }
    val order = remember { FX_CATS }
    val pick = { t: String, pr: String? -> FxPrefs.used(ctx, if (pr != null) "$t:$pr" else t); onPick(t, pr) }
    Column(Modifier.fillMaxSize().background(FB_BG).statusBarsPadding()) {
        Row(Modifier.fillMaxWidth().height(58.dp).background(FB_BAR).padding(horizontal = 8.dp), verticalAlignment = Alignment.CenterVertically) {
            val back = { if (search) { search = false; q = "" } else if (cat != null) cat = null else onClose() }
            Box(Modifier.size(44.dp).target("fxb-close") { back() }.tap { back() }, contentAlignment = Alignment.Center) { Ico(if (cat != null || search) "back" else "close", C.dText, 24.dp, 2f) }
            if (search) BasicTextField(q, { q = it }, singleLine = true, textStyle = TextStyle(color = C.dText, fontSize = 16.sp, fontFamily = Inter), cursorBrush = androidx.compose.ui.graphics.SolidColor(C.turq),
                modifier = Modifier.weight(1f).height(38.dp).clip(RoundedCornerShape(10.dp)).background(C.dDeep).padding(horizontal = 12.dp, vertical = 9.dp),
                decorationBox = { inner -> if (q.isEmpty()) Text("Efekt, etiket ya da hazır ayar ara", color = C.dDim, fontSize = 15.sp); inner() })
            else if (cat != null) {
                val ci = order.indexOfFirst { it.second == cat }
                Box(Modifier.size(40.dp).tap { cat = order[(ci - 1 + order.size) % order.size].second }, contentAlignment = Alignment.Center) { Text("‹", fontSize = 28.sp, color = C.dText) }
                Text(FxCatalog.cats[cat!!], fontSize = 18.sp, fontWeight = FontWeight.SemiBold, color = C.dText, textAlign = TextAlign.Center, modifier = Modifier.weight(1f))
                Box(Modifier.size(40.dp).tap { cat = order[(ci + 1) % order.size].second }, contentAlignment = Alignment.Center) { Text("›", fontSize = 28.sp, color = C.dText) }
            } else Text("Efekt Ekle", fontSize = 18.sp, fontWeight = FontWeight.SemiBold, color = C.dText, textAlign = TextAlign.Center, modifier = Modifier.weight(1f))
            Box(Modifier.size(44.dp).tap { search = !search; q = "" }, contentAlignment = Alignment.Center) { Ico(if (search) "close" else "search", C.dText, 22.dp, 2f) }
        }
        when {
            search -> {
                val res = remember(q) { searchFx(q) }
                LazyVerticalGrid(GridCells.Fixed(1), Modifier.fillMaxSize().navigationBarsPadding(), contentPadding = PaddingValues(10.dp), verticalArrangement = Arrangement.spacedBy(6.dp)) {
                    if (q.isNotBlank() && res.isEmpty()) item { Text("\"$q\" için efekt bulunamadı.", color = C.dText2, modifier = Modifier.padding(16.dp)) }
                    items(res, key = { it.type }) { m ->
                        Row(Modifier.fillMaxWidth().clip(RoundedCornerShape(8.dp)).background(FB_CARD).tap { card = res to res.indexOf(m) }.padding(8.dp), verticalAlignment = Alignment.CenterVertically) {
                            FxThumb(m.type, Modifier.size(56.dp))
                            Column(Modifier.padding(start = 10.dp).weight(1f)) {
                                Text(m.name, fontSize = 14.5.sp, fontWeight = FontWeight.SemiBold, color = C.dText)
                                Text(m.desc, fontSize = 11.5.sp, color = C.dText2, maxLines = 2, overflow = TextOverflow.Ellipsis, lineHeight = 14.sp)
                            }
                        }
                    }
                }
            }
            cat != null -> {
                val list = remember(cat) { FX.filter { it.catIndex == cat } }
                LazyVerticalGrid(GridCells.Fixed(3), Modifier.fillMaxSize().navigationBarsPadding().pointerInput(cat) {
                    var acc = 0f
                    detectHorizontalDragGestures(onDragEnd = { val ci = order.indexOfFirst { it.second == cat }; if (acc < -120) cat = order[(ci + 1) % order.size].second else if (acc > 120) cat = order[(ci - 1 + order.size) % order.size].second; acc = 0f }) { _, d -> acc += d }
                }, contentPadding = PaddingValues(12.dp), horizontalArrangement = Arrangement.spacedBy(10.dp), verticalArrangement = Arrangement.spacedBy(14.dp)) {
                    items(list, key = { it.type }) { m -> FxCell(m) { card = list to list.indexOf(m) } }
                }
            }
            else -> Column(Modifier.fillMaxSize().verticalScroll(rememberScrollState()).navigationBarsPadding().padding(bottom = 16.dp)) {
                // Önerilenler
                Text("Önerilenler", fontSize = 13.sp, fontWeight = FontWeight.Bold, color = C.dText2, modifier = Modifier.padding(start = 14.dp, top = 14.dp, bottom = 8.dp))
                val feat = remember { FEATURED.map { fxMeta(it) }.filter { it.name.isNotEmpty() } }
                Row(Modifier.fillMaxWidth().horizontalScroll(rememberScrollState()).padding(horizontal = 12.dp), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                    feat.forEachIndexed { i, m ->
                        Column(Modifier.width(150.dp).target("fxb:${m.name}") { pick(m.type, null) }.tap { card = feat to i }, horizontalAlignment = Alignment.CenterHorizontally) {
                            FxThumb(m.type, Modifier.size(150.dp), 10); Text(m.name, fontSize = 13.5.sp, color = C.dText, modifier = Modifier.padding(top = 6.dp))
                        }
                    }
                }
                // Son kullanılanlar ve favoriler: 4x2 sayfalar
                val rf = remember(FxPrefs.favs, FxPrefs.recent) { (FxPrefs.favs + FxPrefs.recent).distinct().take(32) }
                Text("Son Kullanılanlar ve Favoriler", fontSize = 13.sp, fontWeight = FontWeight.Bold, color = C.dText2, modifier = Modifier.padding(start = 14.dp, top = 18.dp, bottom = 8.dp))
                if (rf.isEmpty()) Text("Kullandığın ve ⭐ verdiğin efektler burada görünür.", fontSize = 12.5.sp, color = C.dDim, modifier = Modifier.padding(horizontal = 14.dp))
                else {
                    val pages = rf.chunked(8)
                    val ps = rememberPagerState { pages.size }
                    HorizontalPager(ps, Modifier.fillMaxWidth()) { pg ->
                        Column(Modifier.padding(horizontal = 12.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
                            pages[pg].chunked(4).forEach { row ->
                                Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                                    row.forEach { id ->
                                        val t = id.substringBefore(':'); val code = id.substringAfter(':', "").ifEmpty { null }
                                        val m = fxMeta(t); val pr = code?.let { c -> m.presets.find { it.code == c } }
                                        Column(Modifier.weight(1f).tap { pick(t, code) }, horizontalAlignment = Alignment.CenterHorizontally) {
                                            Box { FxThumb(t, Modifier.fillMaxWidth().aspectRatio(1f))
                                                if (id in FxPrefs.favs) Text("★", color = GOLD, fontSize = 13.sp, modifier = Modifier.align(Alignment.TopEnd).padding(3.dp)) }
                                            Text(pr?.name ?: m.name, fontSize = 11.sp, color = C.dText, maxLines = 2, textAlign = TextAlign.Center, lineHeight = 13.sp, modifier = Modifier.padding(top = 4.dp))
                                        }
                                    }
                                    repeat(4 - row.size) { Spacer(Modifier.weight(1f)) }
                                }
                            }
                        }
                    }
                    if (pages.size > 1) Row(Modifier.fillMaxWidth().padding(top = 8.dp), horizontalArrangement = Arrangement.Center) {
                        repeat(pages.size) { i -> Box(Modifier.padding(3.dp).size(6.dp).clip(CircleShape).background(if (i == ps.currentPage) C.turq else C.dDim)) }
                    }
                }
                // Kategoriler
                Text("Kategoriler", fontSize = 13.sp, fontWeight = FontWeight.Bold, color = C.dText2, modifier = Modifier.padding(start = 14.dp, top = 20.dp, bottom = 8.dp))
                Column(Modifier.padding(horizontal = 10.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    order.chunked(2).forEach { row ->
                        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                            row.forEach { (name, ci) ->
                                val cover = remember(ci) { FX.firstOrNull { it.catIndex == ci && it.type in FEATURED } ?: FX.firstOrNull { it.catIndex == ci } }
                                val n = remember(ci) { FX.count { it.catIndex == ci } }
                                Box(Modifier.weight(1f).height(96.dp).clip(RoundedCornerShape(10.dp)).target("fxcat:$name") { cat = ci }.tap { cat = ci }) {
                                    if (cover != null) FxThumb(cover.type, Modifier.matchParentSize(), 10)
                                    Box(Modifier.matchParentSize().background(Brush.verticalGradient(listOf(Color(0x330B1430), Color(0xCC0B1430)))))
                                    Column(Modifier.align(Alignment.BottomStart).padding(10.dp)) {
                                        Text(name, fontSize = 16.sp, fontWeight = FontWeight.ExtraBold, color = Color(0xFFF7F8FA))
                                        Text("$n efekt", fontSize = 11.sp, color = Color(0xFFC9D3E3))
                                    }
                                }
                            }
                            if (row.size == 1) Spacer(Modifier.weight(1f))
                        }
                    }
                }
            }
        }
    }
    card?.let { (list, i) -> FxCard(list, i, onIndex = { card = list to it }, onTag = { tg -> card = null; search = true; q = tg }, onClose = { card = null }) { t, pr -> card = null; pick(t, pr) } }
}

@OptIn(ExperimentalFoundationApi::class)
@Composable
private fun FxCell(m: FxMeta, onOpen: () -> Unit) {
    Column(Modifier.target("fxb:${m.name}") { onOpen() }.combinedClickable(onClick = onOpen, onLongClick = onOpen), horizontalAlignment = Alignment.CenterHorizontally) {
        FxThumb(m.type, Modifier.fillMaxWidth().aspectRatio(1f))
        Text(m.name, fontSize = 11.5.sp, color = C.dText, maxLines = 2, textAlign = TextAlign.Center, lineHeight = 14.sp, modifier = Modifier.padding(top = 5.dp))
    }
}

/** Efekt detay kartı: önizleme, ad, açıklama, etiketler, Standart Ayarlar + hazır ayarlar (⭐). Yana kaydırınca sonraki efekt. */
@Composable
private fun FxCard(list: List<FxMeta>, index: Int, onIndex: (Int) -> Unit, onTag: (String) -> Unit, onClose: () -> Unit, onPick: (String, String?) -> Unit) {
    val ctx = LocalContext.current
    val m = list[index]
    var drag by remember { mutableStateOf(0f) }
    val off by animateFloatAsState(drag, label = "kart")
    Box(Modifier.fillMaxSize().background(Color(0xB0050A1E)).tap(onClick = onClose), contentAlignment = Alignment.Center) {
        Column(Modifier.fillMaxWidth(0.9f).fillMaxHeight(0.86f).graphicsLayer { translationX = off; alpha = 1f - kotlin.math.min(0.6f, kotlin.math.abs(off) / 900f) }
            .clip(RoundedCornerShape(14.dp)).background(FB_CARD).tap { }
            .pointerInput(index) {
                detectHorizontalDragGestures(onDragEnd = {
                    if (drag < -140 && index < list.size - 1) onIndex(index + 1) else if (drag > 140 && index > 0) onIndex(index - 1)
                    drag = 0f
                }) { _, d -> drag += d }
            }) {
            Box(Modifier.fillMaxWidth().aspectRatio(1.25f)) {
                FxThumb(m.type, Modifier.fillMaxSize(), 0)
                Box(Modifier.matchParentSize().background(Brush.verticalGradient(0.55f to Color.Transparent, 1f to Color(0xEE1E2A55))))
                Box(Modifier.padding(6.dp).size(40.dp).clip(CircleShape).tap(onClick = onClose), contentAlignment = Alignment.Center) { Ico("close", Color.White, 22.dp, 2.2f) }
                Text("WardenCB Öğret", fontSize = 12.sp, fontWeight = FontWeight.SemiBold, color = Color.White, modifier = Modifier.align(Alignment.TopEnd).padding(10.dp).clip(RoundedCornerShape(14.dp)).background(Color(0x991F68E0)).tap { onClose(); fxTeach(m.type) }.padding(horizontal = 10.dp, vertical = 5.dp))
                Column(Modifier.align(Alignment.BottomStart).padding(14.dp)) {
                    Text(m.name, fontSize = 20.sp, fontWeight = FontWeight.Bold, color = Color.White)
                    Text(m.desc, fontSize = 12.5.sp, color = Color(0xFFDCE9FF), lineHeight = 16.sp)
                }
            }
            Row(Modifier.fillMaxWidth().horizontalScroll(rememberScrollState()).padding(horizontal = 12.dp, vertical = 8.dp), horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                (listOf(FxCatalog.cats.getOrElse(m.catIndex) { "" }) + m.tags).distinct().forEach { tg ->
                    Text(tg, fontSize = 11.5.sp, color = C.dText, modifier = Modifier.clip(RoundedCornerShape(12.dp)).border(1.dp, C.dLine, RoundedCornerShape(12.dp)).tap { onTag(tg) }.padding(horizontal = 10.dp, vertical = 4.dp))
                }
            }
            m.info?.let { Text("ⓘ $it", fontSize = 11.5.sp, color = C.dText2, modifier = Modifier.padding(horizontal = 14.dp, vertical = 2.dp)) }
            Column(Modifier.weight(1f).verticalScroll(rememberScrollState())) {
                val rows = listOf<FxPreset?>(null) + m.presets
                rows.forEach { pr ->
                    val id = if (pr == null) m.type else "${m.type}:${pr.code}"
                    val fav = id in FxPrefs.favs
                    Row(Modifier.fillMaxWidth().height(58.dp).drawBehind { drawLine(FB_SEL, Offset(0f, size.height), Offset(size.width, size.height), 1f) }.tap { onPick(m.type, pr?.code) }.padding(horizontal = 14.dp), verticalAlignment = Alignment.CenterVertically) {
                        Text("+", fontSize = 22.sp, color = C.dText2, modifier = Modifier.padding(end = 12.dp))
                        Column(Modifier.weight(1f)) {
                            if (pr != null) Text("HAZIR AYAR: ${pr.code}", fontSize = 9.5.sp, color = C.dText2, letterSpacing = 0.6.sp)
                            Text(pr?.name ?: "Standart Ayarlar", fontSize = 15.sp, color = C.dText)
                        }
                        Box(Modifier.size(44.dp).tap { FxPrefs.toggleFav(ctx, id) }, contentAlignment = Alignment.Center) { Text(if (fav) "★" else "☆", fontSize = 22.sp, color = if (fav) GOLD else C.dText2) }
                    }
                }
            }
            Row(Modifier.fillMaxWidth().padding(8.dp), horizontalArrangement = Arrangement.Center) { Text("${index + 1} / ${list.size}  ·  yana kaydır", fontSize = 11.sp, color = C.dDim) }
        }
    }
}

// ---------------------------------------------------------------------------------------------
// Efekt ayar paneli
// ---------------------------------------------------------------------------------------------
private val P_HEAD = Color(0xFF2A3560)
private val P_ROW = Color(0xFF262F5C)

fun unitText(pr: FxParam): String = when (pr.unit) { "box%" -> "%"; "°" -> "°"; "%" -> "%"; "" -> ""; else -> " " + pr.unit }

fun fmtV(n: Double, pr: FxParam): String {
    val s = when { pr.int || pr.step >= 1 -> Math.round(n).toString(); pr.step >= 0.1 -> "%.1f".format(n); else -> "%.2f".format(n) }
    return s.replace('.', ',') + unitText(pr)
}

@Composable
fun EffectsPanel(s: EditorState, layer: Layer, onClose: () -> Unit) {
    val ctx = LocalContext.current
    var browse by remember { mutableStateOf(false) }
    var menuFx by remember { mutableStateOf<String?>(null) }
    var colorFor by remember { mutableStateOf<Triple<String, String, Int>?>(null) } // efekt, ayar, durak (-1: düz renk)
    var numFor by remember { mutableStateOf<Triple<String, String, Int>?>(null) }  // efekt, ayar, eksen
    var closedGroups by remember { mutableStateOf(setOf<String>()) }
    val sel = s.fxParam
    LaunchedEffect(sel) { s.kfFocus = listOf(if (sel != null) "fx:${sel.first}:${sel.second}" else "fx:none") }
    DisposableEffect(Unit) { onDispose { s.kfFocus = null; s.fxParam = null } }
    LaunchedEffect(layer.effects.size) {
        if (sel != null && layer.effects.any { it.id == sel.first }) return@LaunchedEffect
        val e = layer.effects.lastOrNull { fxMeta(it.type).params.any { p -> p.isNumeric() } }
        s.fxParam = e?.let { it.id to fxMeta(it.type).params.first { p -> p.isNumeric() }.key }
    }
    val t = s.time
    val selFx = layer.effects.find { it.id == sel?.first }
    val selPr = selFx?.let { fxMeta(it.type).params.find { p -> p.key == sel?.second } ?: if (sel?.second == "_mix") MIX_P else null }
    val selKeys = selPr?.let { paramKeys(it) } ?: emptyList()
    val hasKey = selFx != null && selKeys.any { selFx.v?.get(it)?.keyAt(t) != null }
    val canKey = selPr != null && selPr.anim != "no" && selPr.isNumeric()
    val toggleK = {
        if (selFx != null && canKey) s.updateLayer(layer.id) { l -> l.copy(effects = l.effects.map { e ->
            if (e.id != selFx.id) e else {
                val v = (e.v ?: emptyMap()).toMutableMap()
                for (k in selKeys) { val a0 = v[k] ?: Anim(if (k == "_mix") 100.0 else e.value(k, s.time)); if ((a0.keyAt(s.time) != null) == hasKey) v[k] = a0.toggleKey(s.time) }
                e.copy(v = v)
            }
        }) }
    }
    fun upd(e: Effect, f: (Effect) -> Effect) = s.updateLayer(layer.id) { l -> l.copy(effects = l.effects.map { if (it.id == e.id) f(it) else it }) }
    Row(Modifier.fillMaxSize()) {
        Column(Modifier.width(48.dp).fillMaxHeight().drawBehind { drawLine(C.dLine, Offset(size.width, 0f), Offset(size.width, size.height), 1.dp.toPx()) }.padding(top = 6.dp), horizontalAlignment = Alignment.CenterHorizontally) {
            Box(Modifier.size(44.dp).tap(onClick = onClose), contentAlignment = Alignment.Center) { Ico("back", C.dText, 22.dp) }
            Box(Modifier.size(44.dp).target("kf-btn").tap(canKey, toggleK), contentAlignment = Alignment.Center) { KfIcon(hasKey, canKey) }
            // Önceki / sonraki keyframe
            val ks = selFx?.let { e -> selKeys.flatMap { e.v?.get(it)?.k?.map { k -> k.t } ?: emptyList() }.distinct().sorted() } ?: emptyList()
            Box(Modifier.size(44.dp, 34.dp).tap(ks.any { it < t - 1e-3 }) { s.time = ks.last { it < t - 1e-3 } }, contentAlignment = Alignment.Center) { Text("‹◆", fontSize = 12.sp, color = if (ks.any { it < t - 1e-3 }) C.dText else C.dDim) }
            Box(Modifier.size(44.dp, 34.dp).tap(ks.any { it > t + 1e-3 }) { s.time = ks.first { it > t + 1e-3 } }, contentAlignment = Alignment.Center) { Text("◆›", fontSize = 12.sp, color = if (ks.any { it > t + 1e-3 }) C.dText else C.dDim) }
        }
        Column(Modifier.weight(1f).fillMaxHeight().verticalScroll(rememberScrollState()).padding(6.dp)) {
            if (layer.effects.isEmpty()) Text("Bu katmanda efekt yok. Aşağıdan ekleyebilirsin.", fontSize = 12.5.sp, color = C.dText2, modifier = Modifier.padding(8.dp))
            layer.effects.forEach { e ->
                val m = fxMeta(e.type)
                val off = e.on == false
                Column(Modifier.fillMaxWidth().padding(bottom = 6.dp).clip(RoundedCornerShape(6.dp)).background(P_HEAD)) {
                    Row(Modifier.fillMaxWidth().height(42.dp).padding(start = 2.dp).drawBehind { drawLine(Color(0xFF222C55), Offset(0f, size.height), Offset(size.width, size.height), 1.dp.toPx()) }, verticalAlignment = Alignment.CenterVertically) {
                        Box(Modifier.size(32.dp).tap { upd(e) { it.copy(closed = !(it.closed ?: false)) } }, contentAlignment = Alignment.Center) { Text("▼", fontSize = 10.sp, color = C.dText, modifier = Modifier.rotate(if (e.closed == true) -90f else 0f)) }
                        Box(Modifier.size(32.dp).tap { upd(e) { it.copy(on = if (off) null else false) } }, contentAlignment = Alignment.Center) { Ico(if (off) "eyeOff" else "eye", if (off) C.dDim else C.dText, 18.dp) }
                        Text(m.name, fontSize = 14.sp, color = if (off) C.dDim else C.dText, maxLines = 1, overflow = TextOverflow.Ellipsis, modifier = Modifier.weight(1f).tap { upd(e) { it.copy(closed = !(it.closed ?: false)) } }.padding(start = 4.dp))
                        Box(Modifier.size(38.dp).tap { menuFx = if (menuFx == e.id) null else e.id }, contentAlignment = Alignment.Center) { Ico("more", C.dText, 20.dp, 3f) }
                        Box(Modifier.size(38.dp).tap { s.updateLayer(layer.id) { l -> l.copy(effects = l.effects.filter { it.id != e.id }) } }, contentAlignment = Alignment.Center) { Ico("trash", C.dText, 18.dp) }
                    }
                    if (menuFx == e.id) Column(Modifier.fillMaxWidth().background(Color(0xFF222C55)).padding(6.dp), verticalArrangement = Arrangement.spacedBy(4.dp)) {
                        val mv = { d: Int -> s.updateLayer(layer.id) { l -> val i = l.effects.indexOfFirst { it.id == e.id }; val ef = l.effects.toMutableList(); val j = i + d; if (j in ef.indices) { val tmp = ef[i]; ef[i] = ef[j]; ef[j] = tmp }; l.copy(effects = ef) }; menuFx = null }
                        listOf(listOf("Yukarı taşı" to { mv(-1) }, "Aşağı taşı" to { mv(1) }), listOf(
                            "Çoğalt" to { s.updateLayer(layer.id) { l -> val i = l.effects.indexOfFirst { it.id == e.id }; l.copy(effects = l.effects.toMutableList().apply { add(i + 1, e.copy(id = uid())) }) }; menuFx = null },
                            "Sıfırla" to { upd(e) { makeEffect(e.type).copy(id = e.id) }; menuFx = null }),
                            listOf("WardenCB ile Öğret" to { menuFx = null; fxTeach(e.type) })).forEach { row ->
                            Row(horizontalArrangement = Arrangement.spacedBy(4.dp)) { row.forEach { (lb, fn) -> Box(Modifier.weight(1f).height(34.dp).clip(RoundedCornerShape(6.dp)).background(Color(0xFF34417A)).tap(onClick = fn), contentAlignment = Alignment.Center) { Text(lb, fontSize = 12.5.sp, color = C.dText) } } }
                        }
                    }
                    if (e.closed != true) {
                        m.info?.let { Row(Modifier.padding(8.dp), horizontalArrangement = Arrangement.spacedBy(6.dp)) { Ico("info", C.dText2, 14.dp); Text(it, fontSize = 11.5.sp, color = C.dText2) } }
                        if (m.kind !in GlFx.GPU_KINDS && !m.ready && m.kind !in MOTION_KINDS) Text("Bu efektin telefon motoru sonraki sürümde tamamlanacak; ayarları şimdiden kaydedilir.", fontSize = 11.sp, color = Color(0xFFF2C230), modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp))
                        // Hazır ayarlar
                        if (m.presets.isNotEmpty()) Row(Modifier.fillMaxWidth().horizontalScroll(rememberScrollState()).padding(horizontal = 6.dp, vertical = 6.dp), horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                            Text("Standart", fontSize = 11.5.sp, color = C.dText, modifier = Modifier.clip(RoundedCornerShape(12.dp)).background(Color(0xFF34417A)).tap { upd(e) { makeEffect(e.type).copy(id = e.id) } }.padding(horizontal = 10.dp, vertical = 5.dp))
                            m.presets.filter { it.alias == null }.forEach { pr ->
                                Text(pr.name, fontSize = 11.5.sp, color = C.dText, modifier = Modifier.clip(RoundedCornerShape(12.dp)).background(if (e.preset == pr.code) C.blue else Color(0xFF34417A))
                                    .tap { upd(e) { applyPreset(makeEffect(e.type).copy(id = e.id), pr, layer.start, layer.end).copy(preset = pr.code) } }.padding(horizontal = 10.dp, vertical = 5.dp))
                            }
                        }
                        val params = (if (m.kind in GlFx.GPU_KINDS) listOf(MIX_P) else emptyList()) + m.params.filter { it.kind != "info" && (it.visKey == null || (e.value(it.visKey, t).roundToInt() in (it.visIn ?: emptyList()))) }
                        var lastG: String? = null
                        params.forEachIndexed { pi, pr ->
                            val g = pr.group
                            if (g != null && g != lastG) {
                                val closed = "${e.id}:$g" in closedGroups
                                Row(Modifier.fillMaxWidth().height(34.dp).background(Color(0xFF222C55)).tap { closedGroups = if (closed) closedGroups - "${e.id}:$g" else closedGroups + "${e.id}:$g" }.padding(horizontal = 10.dp), verticalAlignment = Alignment.CenterVertically) {
                                    Text(if (closed) "▸" else "▾", fontSize = 11.sp, color = C.dText2); Spacer(Modifier.width(8.dp)); Text(g.uppercase(java.util.Locale("tr")), fontSize = 11.5.sp, fontWeight = FontWeight.Bold, color = C.dText2, letterSpacing = 0.6.sp)
                                }
                            }
                            lastG = g
                            if (g != null && "${e.id}:$g" in closedGroups) return@forEachIndexed
                            ParamRow(s, layer, e, pr, pi > 0, sel?.first == e.id && sel.second == pr.key,
                                onSel = { s.fxParam = e.id to pr.key }, onColor = { stop -> s.checkpoint(); colorFor = Triple(e.id, pr.key, stop) },
                                onNum = { axis -> numFor = Triple(e.id, pr.key, axis) })
                        }
                    }
                }
            }
            Row(Modifier.fillMaxWidth().height(44.dp).target("addfx") { browse = true }.clip(RoundedCornerShape(8.dp)).background(Color(0xFF2E3F7E)).tap { browse = true }, horizontalArrangement = Arrangement.Center, verticalAlignment = Alignment.CenterVertically) {
                Ico("plus", C.dText, 18.dp, 2.2f); Spacer(Modifier.width(8.dp)); Text("Efekt Ekle", color = C.dText, fontWeight = FontWeight.SemiBold)
            }
        }
    }
    colorFor?.let { (fid, key, stop) ->
        val e = layer.effects.find { it.id == fid }
        val pr = e?.let { fxMeta(it.type).params.find { p -> p.key == key } }
        if (e == null || pr == null) { colorFor = null; return@let }
        val cur = if (stop < 0) e.c?.get(key) ?: pr.defStr ?: "#FFFFFF" else stopsOf(e, pr).getOrNull(stop)?.first ?: "#FFFFFF"
        ColorPickerDialog(cur, dark = true, onDismiss = { colorFor = null }) { c ->
            s.updateLayer(layer.id, false) { l -> l.copy(effects = l.effects.map { x ->
                if (x.id != fid) x else if (stop < 0) x.copy(c = (x.c ?: emptyMap()) + (key to c))
                else { val st = stopsOf(x, pr).toMutableList(); if (stop in st.indices) st[stop] = c to st[stop].second; x.copy(c = (x.c ?: emptyMap()) + (key to stopsJson(st))) }
            }) }
            colorFor = null
        }
    }
    numFor?.let { (fid, key, axis) ->
        val e = layer.effects.find { it.id == fid }
        val pr = e?.let { fxMeta(it.type).params.find { p -> p.key == key } ?: if (key == "_mix") MIX_P else null }
        if (e == null || pr == null) { numFor = null; return@let }
        val k = paramKeys(pr)[axis]
        NumberDialog(pr.label + if (pr.two || pr.three) " (${"XYZ"[axis]})" else "", if (k == "_mix") (e.v?.get("_mix")?.at(t) ?: 100.0) else e.value(k, t), pr, onDismiss = { numFor = null }) { v ->
            s.checkpoint(); s.updateLayer(layer.id, false) { setFxParams(it, fid, mapOf(k to v.coerceIn(pr.min, pr.max)), s.time) }; numFor = null
        }
    }
    if (browse) Overlay {
        EffectBrowser(onClose = { browse = false }) { ty, code ->
            var ne = makeEffect(ty)
            val m = fxMeta(ty)
            code?.let { c -> m.presets.find { it.code == c } }?.let { pr ->
                ne = if (pr.alias != null) makeEffect(ty).let { applyPreset(it, pr, layer.start, layer.end) } else applyPreset(ne, pr, layer.start, layer.end).copy(preset = pr.code)
            }
            s.updateLayer(layer.id) { it.copy(effects = it.effects + ne) }
            s.fxParam = m.params.firstOrNull { it.isNumeric() }?.let { ne.id to it.key }
            browse = false
        }
    }
}

val MIX_P = FxParam("_mix", "Karışım", 0.0, 100.0, 100.0, 0.1, 0.1, unit = "%")
val MOTION_KINDS = setOf("xform", "opacity", "time", "special")

fun stopsOf(e: Effect, pr: FxParam): List<Pair<String, Double>> = runCatching {
    kotlinx.serialization.json.Json.parseToJsonElement(e.c?.get(pr.key) ?: pr.defStr ?: "[]").let { it as kotlinx.serialization.json.JsonArray }.map { st ->
        val a = st as kotlinx.serialization.json.JsonArray
        (a[0] as kotlinx.serialization.json.JsonPrimitive).content to ((a[1] as kotlinx.serialization.json.JsonPrimitive).content.toDoubleOrNull() ?: 0.0)
    }
}.getOrDefault(emptyList())
fun stopsJson(st: List<Pair<String, Double>>) = st.joinToString(",", "[", "]") { "[\"${it.first}\",${it.second}]" }

@Composable
private fun ParamRow(s: EditorState, layer: Layer, e: Effect, pr: FxParam, line: Boolean, on: Boolean, onSel: () -> Unit, onColor: (Int) -> Unit, onNum: (Int) -> Unit) {
    val t = s.time
    val keys = paramKeys(pr)
    fun cur(k: String) = if (k == "_mix") (e.v?.get("_mix")?.at(t) ?: 100.0) else e.value(k, t)
    fun set(vals: Map<String, Double>, chk: Boolean = true) = s.updateLayer(layer.id, chk) { setFxParams(it, e.id, vals, s.time) }
    fun setC(v: String) = s.updateLayer(layer.id) { l -> l.copy(effects = l.effects.map { if (it.id == e.id) it.copy(c = (it.c ?: emptyMap()) + (pr.key to v)) else it }) }
    val animated = keys.any { (e.v?.get(it)?.k?.size ?: 0) > 0 }
    Row(Modifier.fillMaxWidth().heightIn(min = 46.dp).then(if (line) Modifier.drawBehind { drawLine(P_ROW, Offset(0f, 0f), Offset(size.width, 0f), 1.dp.toPx()) } else Modifier).padding(horizontal = 6.dp, vertical = 3.dp),
        verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(6.dp)) {
        val labelMod = Modifier.width(92.dp).heightIn(min = 32.dp).clip(RoundedCornerShape(4.dp)).background(if (on) Color(0xFF16203F) else Color(0xFF1E2850)).tap { onSel() }.padding(horizontal = 5.dp, vertical = 3.dp)
        @Composable fun Label() = Row(labelMod, verticalAlignment = Alignment.CenterVertically) {
            Text(pr.label, fontSize = 11.sp, lineHeight = 13.sp, color = if (on) C.turq else C.dText2, modifier = Modifier.weight(1f))
            if (animated) Box(Modifier.size(6.dp).rotate(45f).background(C.turq))
        }
        when (pr.kind) {
            "toggle" -> {
                val v = cur(pr.key) >= 0.5
                Label(); Spacer(Modifier.weight(1f))
                Box(Modifier.size(42.dp, 24.dp).clip(RoundedCornerShape(12.dp)).background(if (v) C.turq else C.dDim).tap { onSel(); set(mapOf(pr.key to if (v) 0.0 else 1.0)) }) {
                    Box(Modifier.align(if (v) Alignment.CenterEnd else Alignment.CenterStart).padding(2.dp).size(20.dp).clip(CircleShape).background(Color(0xFFF7F8FA)))
                }
            }
            "choice" -> {
                val opts = pr.opts ?: emptyList(); val i = cur(pr.key).toInt().coerceIn(0, (opts.size - 1).coerceAtLeast(0))
                Label()
                if (opts.size <= 3 && opts.sumOf { it.length } <= 22) Row(Modifier.weight(1f), horizontalArrangement = Arrangement.spacedBy(3.dp)) {
                    opts.forEachIndexed { j, o -> Text(o, fontSize = 11.sp, color = if (j == i) C.dDeep else C.dText, textAlign = TextAlign.Center, maxLines = 1,
                        modifier = Modifier.weight(1f).clip(RoundedCornerShape(6.dp)).background(if (j == i) C.turq else Color(0xFF34417A)).tap { onSel(); set(mapOf(pr.key to j.toDouble())) }.padding(vertical = 7.dp)) }
                } else {
                    var open by remember { mutableStateOf(false) }
                    Box(Modifier.weight(1f)) {
                        Row(Modifier.fillMaxWidth().height(34.dp).clip(RoundedCornerShape(6.dp)).background(Color(0xFF34417A)).tap { onSel(); open = true }.padding(horizontal = 10.dp), verticalAlignment = Alignment.CenterVertically) {
                            Text(opts.getOrElse(i) { "" }, fontSize = 12.5.sp, color = C.dText, modifier = Modifier.weight(1f), maxLines = 1, overflow = TextOverflow.Ellipsis); Ico("chevD", C.dText2, 16.dp)
                        }
                        androidx.compose.material3.DropdownMenu(open, { open = false }, Modifier.background(C.dPanel)) {
                            opts.forEachIndexed { j, o -> androidx.compose.material3.DropdownMenuItem(text = { Text(o, color = if (j == i) C.turq else C.dText, fontSize = 14.sp) }, onClick = { set(mapOf(pr.key to j.toDouble())); open = false }) }
                        }
                    }
                }
            }
            "color" -> {
                Label(); Spacer(Modifier.weight(1f))
                Text((e.c?.get(pr.key) ?: pr.defStr ?: "").uppercase(), fontSize = 11.sp, color = C.dText2)
                Box(Modifier.size(42.dp, 28.dp).clip(RoundedCornerShape(6.dp)).background(colorOf(e.c?.get(pr.key) ?: pr.defStr)).border(1.dp, C.dLine, RoundedCornerShape(6.dp)).tap { onColor(-1) })
            }
            "gradient", "palette" -> {
                Label()
                val st = stopsOf(e, pr)
                Row(Modifier.weight(1f).horizontalScroll(rememberScrollState()), horizontalArrangement = Arrangement.spacedBy(4.dp), verticalAlignment = Alignment.CenterVertically) {
                    st.forEachIndexed { j, (c, _) -> Box(Modifier.size(26.dp).clip(RoundedCornerShape(5.dp)).background(colorOf(c)).border(1.dp, C.dLine, RoundedCornerShape(5.dp)).tap { onColor(j) }) }
                    if (st.size < 8) Box(Modifier.size(26.dp).clip(RoundedCornerShape(5.dp)).background(Color(0xFF34417A)).tap {
                        val n = (st + ((st.lastOrNull()?.first ?: "#FFFFFF") to 100.0)); val re = n.mapIndexed { k, x -> x.first to Math.round(100.0 * k / (n.size - 1)).toDouble() }; setC(stopsJson(re))
                    }, contentAlignment = Alignment.Center) { Text("+", color = C.dText, fontSize = 15.sp) }
                    if (st.size > 2) Box(Modifier.size(26.dp).clip(RoundedCornerShape(5.dp)).background(Color(0xFF34417A)).tap {
                        val n = st.dropLast(1); val re = n.mapIndexed { k, x -> x.first to Math.round(100.0 * k / (n.size - 1)).toDouble() }; setC(stopsJson(re))
                    }, contentAlignment = Alignment.Center) { Text("−", color = C.dText, fontSize = 15.sp) }
                }
            }
            "source" -> {
                Label()
                var open by remember { mutableStateOf(false) }
                val id = e.c?.get(pr.key)
                val others = s.project.layers.filter { it.id != layer.id && it.type != "audio" || (pr.label.contains("Ses") && it.type == "audio") }
                Box(Modifier.weight(1f)) {
                    Row(Modifier.fillMaxWidth().height(34.dp).clip(RoundedCornerShape(6.dp)).background(Color(0xFF34417A)).tap { open = true }.padding(horizontal = 10.dp), verticalAlignment = Alignment.CenterVertically) {
                        Text(others.find { it.id == id }?.name ?: "Seçilmedi", fontSize = 12.5.sp, color = if (id == null) C.dText2 else C.dText, modifier = Modifier.weight(1f), maxLines = 1, overflow = TextOverflow.Ellipsis); Ico("chevD", C.dText2, 16.dp)
                    }
                    androidx.compose.material3.DropdownMenu(open, { open = false }, Modifier.background(C.dPanel)) {
                        androidx.compose.material3.DropdownMenuItem(text = { Text("Seçilmedi", color = C.dText2) }, onClick = { s.updateLayer(layer.id) { l -> l.copy(effects = l.effects.map { if (it.id == e.id) it.copy(c = (it.c ?: emptyMap()) - pr.key) else it }) }; open = false })
                        others.forEach { o -> androidx.compose.material3.DropdownMenuItem(text = { Text(o.name, color = if (o.id == id) C.turq else C.dText) }, onClick = { setC(o.id); open = false }) }
                    }
                }
            }
            "text" -> {
                Label()
                var started by remember { mutableStateOf(false) }
                BasicTextField(e.c?.get(pr.key) ?: pr.defStr ?: "", { v -> if (!started) { s.checkpoint(); started = true }; s.updateLayer(layer.id, false) { l -> l.copy(effects = l.effects.map { if (it.id == e.id) it.copy(c = (it.c ?: emptyMap()) + (pr.key to v)) else it }) } },
                    singleLine = true, textStyle = TextStyle(color = C.dText, fontSize = 14.sp, fontFamily = Inter), cursorBrush = androidx.compose.ui.graphics.SolidColor(C.turq),
                    modifier = Modifier.weight(1f).height(34.dp).clip(RoundedCornerShape(6.dp)).background(C.dDeep).padding(horizontal = 10.dp, vertical = 8.dp))
            }
            "button" -> { Spacer(Modifier.weight(1f)); Text(pr.label, fontSize = 12.5.sp, color = C.dText, modifier = Modifier.clip(RoundedCornerShape(6.dp)).background(Color(0xFF34417A)).tap { s.updateLayer(layer.id) { l -> l.copy(effects = l.effects.map { if (it.id == e.id) makeEffect(e.type).copy(id = e.id) else it }) } }.padding(horizontal = 14.dp, vertical = 8.dp)) }
            "curve", "editor" -> { Label(); Text(if (pr.kind == "curve") "Yumuşak eğri (varsayılan)" else "Katmanın kendi şekli kullanılır", fontSize = 11.5.sp, color = C.dText2, modifier = Modifier.weight(1f)) }
            else -> {
                // Sayısal: cetvel (2B: yatay X, dikey Y)
                Label()
                Column(Modifier.weight(1f)) {
                    if (pr.three) keys.forEachIndexed { ai, k ->
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Text("XYZ"[ai].toString(), fontSize = 10.sp, color = C.dDim, modifier = Modifier.width(12.dp))
                            Jog2(cur(k), pr, Modifier.weight(1f).height(26.dp), init = { listOf(cur(k), 0.0) }, onStart = { onSel(); s.checkpoint() }) { v0, dx, _ ->
                                set(mapOf(k to clampP(v0[0] + dx * jogSens(pr), pr)), false)
                            }
                            Text(fmtV(cur(k), pr), fontSize = 11.5.sp, color = if (on) C.turq else C.dText, modifier = Modifier.width(58.dp).tap { onNum(ai) }, textAlign = TextAlign.End)
                        }
                    } else Row(verticalAlignment = Alignment.CenterVertically) {
                        Jog2(cur(keys[0]), pr, Modifier.weight(1f).height(38.dp), init = { keys.map { cur(it) } }, onStart = { onSel(); s.checkpoint() }) { v0, dx, dy ->
                            val sens = jogSens(pr)
                            val vals = if (pr.two) mapOf(keys[0] to clampP(v0[0] + dx * sens, pr), keys[1] to clampP(v0[1] + dy * sens, pr)) else mapOf(keys[0] to clampP(v0[0] + dx * sens, pr))
                            set(vals, false)
                        }
                        Column(Modifier.width(62.dp), horizontalAlignment = Alignment.End) {
                            keys.forEachIndexed { i, k ->
                                Row(verticalAlignment = Alignment.Bottom, modifier = Modifier.tap { onNum(i) }) {
                                    if (pr.two) Text(if (i == 1) "y " else "x ", fontSize = 10.sp, color = C.dDim)
                                    Text(fmtV(cur(k), pr), fontSize = 12.sp, color = if (on) C.turq else C.dText)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

/** Cetvelde 1 dp kaydırmanın değeri */
fun jogSens(pr: FxParam): Double = if (pr.unit == "box%") 0.15 else if (pr.int && pr.max - pr.min <= 64) 0.08 else ((pr.max - pr.min) / 600).coerceIn(maxOf(pr.step, 0.002), 20.0)

private fun clampP(v: Double, pr: FxParam): Double { val st = if (pr.int) 1.0 else pr.step; return (Math.round(v / st) * st).coerceIn(pr.min, pr.max) }

/** Kaydırma cetveli */
@Composable
private fun Jog2(v: Double, pr: FxParam, modifier: Modifier, init: () -> List<Double>, onStart: () -> Unit, onMove: (List<Double>, Double, Double) -> Unit) {
    val dens = androidx.compose.ui.platform.LocalDensity.current.density
    androidx.compose.foundation.Canvas(modifier.pointerInput(pr.key) {
        awaitEachGesture {
            val d = awaitFirstDown(); d.consume()
            onStart(); val v0 = init()
            while (true) {
                val ev = awaitPointerEvent(); val c = ev.changes.first(); c.consume()
                if (!c.pressed) break
                onMove(v0, ((c.position.x - d.position.x) / dens).toDouble(), ((c.position.y - d.position.y) / dens).toDouble())
            }
        }
    }) {
        val step = 10 * density
        val off = (((v / jogSens(pr)) % 10) * density).toFloat()
        var x = -off % step; if (x < 0) x += step
        var i = 0
        while (x < size.width) { drawLine(C.dDim, Offset(x, size.height * (if (i % 5 == 0) .15f else .3f)), Offset(x, size.height * (if (i % 5 == 0) .85f else .7f)), 1f); x += step; i++ }
        drawLine(C.turq.copy(alpha = .8f), Offset(size.width / 2, 2 * density), Offset(size.width / 2, size.height - 2 * density), 2 * density)
    }
}

@Composable
private fun NumberDialog(title: String, v: Double, pr: FxParam, onDismiss: () -> Unit, onOk: (Double) -> Unit) {
    var txt by remember { mutableStateOf(fmtV(v, pr).removeSuffix(unitText(pr)).trim()) }
    Overlay {
        Box(Modifier.fillMaxSize().background(Color(0x99050A1E)).tap(onClick = onDismiss), contentAlignment = Alignment.Center) {
            Column(Modifier.width(280.dp).clip(RoundedCornerShape(14.dp)).background(C.dPanel).tap { }.padding(16.dp)) {
                Text(title, fontSize = 15.sp, fontWeight = FontWeight.SemiBold, color = C.dText)
                Text("Aralık: ${fmtV(pr.min, pr)} … ${fmtV(pr.max, pr)}", fontSize = 11.5.sp, color = C.dText2, modifier = Modifier.padding(top = 4.dp, bottom = 10.dp))
                BasicTextField(txt, { txt = it }, singleLine = true, keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                    textStyle = TextStyle(color = C.dText, fontSize = 18.sp, fontFamily = Inter), cursorBrush = androidx.compose.ui.graphics.SolidColor(C.turq),
                    modifier = Modifier.fillMaxWidth().clip(RoundedCornerShape(8.dp)).background(C.dDeep).padding(12.dp))
                Row(Modifier.fillMaxWidth().padding(top = 12.dp), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    Box(Modifier.weight(1f).height(40.dp).clip(RoundedCornerShape(8.dp)).background(Color(0xFF34417A)).tap(onClick = onDismiss), contentAlignment = Alignment.Center) { Text("Vazgeç", color = C.dText) }
                    Box(Modifier.weight(1f).height(40.dp).clip(RoundedCornerShape(8.dp)).background(C.blue).tap { txt.replace(',', '.').replace("−", "-").toDoubleOrNull()?.let(onOk) }, contentAlignment = Alignment.Center) { Text("Tamam", color = Color.White, fontWeight = FontWeight.SemiBold) }
                }
            }
        }
    }
}
