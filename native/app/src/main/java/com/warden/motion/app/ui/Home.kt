package com.warden.motion.app.ui

import android.widget.Toast
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInHorizontally
import androidx.compose.animation.slideOutHorizontally
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Menu
import androidx.compose.material.icons.filled.MoreVert
import androidx.compose.material.icons.filled.Person
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.layout
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.PathEffect
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.warden.motion.app.R
import com.warden.motion.app.data.Store
import com.warden.motion.app.model.Project
import com.warden.motion.app.model.newProject
import kotlinx.coroutines.launch
import androidx.compose.ui.graphics.drawscope.drawIntoCanvas
import androidx.compose.ui.graphics.nativeCanvas
import kotlin.math.min

@Composable
fun HomeScreen(store: Store, onOpen: (Project) -> Unit) {
    val projects by store.projects.collectAsState()
    val lite by store.lite.collectAsState()
    var sheet by remember { mutableStateOf(false) }
    var drawer by remember { mutableStateOf(false) }

    Box(Modifier.fillMaxSize().background(C.bg).systemBarsPadding()) {
        Column(Modifier.fillMaxSize()) {
            // Üst: menü, ortada logo + yazı, sağda hesap
            Box(Modifier.fillMaxWidth().height(72.dp).padding(horizontal = 6.dp)) {
                IconButton(onClick = { drawer = true }, Modifier.align(Alignment.CenterStart)) { Icon(Icons.Filled.Menu, "Ayarlar menüsü", tint = C.text) }
                Brand(lite, Modifier.align(Alignment.Center))
                Box(Modifier.align(Alignment.CenterEnd).padding(end = 6.dp).size(34.dp).clip(CircleShape).background(C.primary), contentAlignment = Alignment.Center) {
                    Icon(Icons.Filled.Person, "Hesap", tint = C.onPrimary, modifier = Modifier.size(20.dp))
                }
            }
            LazyColumn(Modifier.fillMaxSize(), contentPadding = PaddingValues(start = 16.dp, end = 16.dp, top = 8.dp, bottom = 110.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
                item { NewCard { sheet = true } }
                item {
                    Row(Modifier.fillMaxWidth().padding(top = 10.dp), verticalAlignment = Alignment.Bottom) {
                        Text("Son projeler", fontSize = 20.sp, fontWeight = FontWeight.Bold, color = C.text, modifier = Modifier.weight(1f))
                        Text("${projects.size} proje", fontSize = 13.sp, color = C.text2)
                    }
                }
                if (projects.isEmpty()) item {
                    Text("Henüz proje yok. Yeni proje oluştur ya da Ayarlar'dan eski uygulamadaki projelerini aktar.", color = C.text2, fontSize = 14.sp, modifier = Modifier.padding(vertical = 18.dp, horizontal = 4.dp))
                }
                items(projects, key = { it.id }) { p -> ProjectRow(store, p, onOpen) }
            }
        }
        BottomNav(Modifier.align(Alignment.BottomCenter)) { sheet = true }

        AnimatedVisibility(drawer, enter = fadeIn(), exit = fadeOut()) {
            Box(Modifier.fillMaxSize().background(Color(0x660B1430)).clickable(interactionSource = remember { androidx.compose.foundation.interaction.MutableInteractionSource() }, indication = null) { drawer = false })
        }
        AnimatedVisibility(drawer, enter = slideInHorizontally { -it }, exit = slideOutHorizontally { -it }) {
            SettingsDrawer(store) { drawer = false }
        }
        if (sheet) NewProjectSheet(projects.size, onClose = { sheet = false }) { p ->
            sheet = false
            onOpen(p)
        }
    }
}

/** Logo + "Warden Motion" (+ Lite rozeti) */
@Composable
fun Brand(lite: Boolean, modifier: Modifier = Modifier) {
    Row(modifier, verticalAlignment = Alignment.CenterVertically) {
        // Eski uygulamadaki yerleşim: logo yazının arkasında, "Wa" en büyük karenin üstünde duruyor gibi
        Box {
            // Yer kaplamaz (web'deki position:absolute gibi): yazının boyunu değiştirmez
            Image(painterResource(R.drawable.logo_mark), null, contentScale = androidx.compose.ui.layout.ContentScale.FillWidth,
                modifier = Modifier.layout { m, _ ->
                    val pl = m.measure(androidx.compose.ui.unit.Constraints.fixed(52.5.dp.roundToPx(), (52.5f * 680 / 516).dp.roundToPx()))
                    layout(0, 0) { pl.place((-23.5).dp.roundToPx(), (-13.9).dp.roundToPx()) }
                })
            Text("Warden Motion", fontSize = 21.sp, lineHeight = 25.sp, fontWeight = FontWeight.SemiBold, color = C.text)
        }
        if (lite) {
            Spacer(Modifier.width(6.dp))
            Box(Modifier.clip(RoundedCornerShape(6.dp)).background(C.liteBlue).padding(horizontal = 6.dp, vertical = 1.dp)) {
                Text("Lite", color = Color.White, fontSize = 12.sp, fontWeight = FontWeight.ExtraBold)
            }
        }
    }
}

@Composable
private fun NewCard(onClick: () -> Unit) {
    Box(
        Modifier.fillMaxWidth().height(68.dp).clip(RoundedCornerShape(16.dp)).background(C.card).clickable(onClick = onClick),
        contentAlignment = Alignment.Center,
    ) {
        Canvas(Modifier.matchParentSize()) {
            drawRoundRect(Color(0xFFA9B6C9), cornerRadius = androidx.compose.ui.geometry.CornerRadius(16.dp.toPx()),
                style = Stroke(2.dp.toPx(), pathEffect = PathEffect.dashPathEffect(floatArrayOf(10f, 8f))))
        }
        Row(verticalAlignment = Alignment.CenterVertically) {
            Box(Modifier.size(32.dp).clip(CircleShape).background(C.primary), contentAlignment = Alignment.Center) { Icon(Icons.Filled.Add, null, tint = C.onPrimary, modifier = Modifier.size(20.dp)) }
            Spacer(Modifier.width(16.dp))
            Text("Yeni Proje Oluştur", fontSize = 18.sp, fontWeight = FontWeight.Medium, color = C.text)
        }
    }
}

private fun fmtDur(s: Double): String { val n = s.toInt(); return "%d:%02d".format(n / 60, n % 60) }

@OptIn(ExperimentalFoundationApi::class)
@Composable
private fun ProjectRow(store: Store, p: Project, onOpen: (Project) -> Unit) {
    val scope = rememberCoroutineScope()
    var menu by remember { mutableStateOf(false) }
    var confirm by remember { mutableStateOf(false) }
    Row(
        Modifier.fillMaxWidth().clip(RoundedCornerShape(14.dp)).background(C.card).combinedClickable(onClick = { onOpen(p) }, onLongClick = { menu = true }).padding(8.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Box(Modifier.size(80.dp).clip(RoundedCornerShape(8.dp)).background(Color(0xFFE3E9F2)).border(1.dp, C.line, RoundedCornerShape(8.dp)), contentAlignment = Alignment.Center) {
            ProjectThumb(store, p, Modifier.fillMaxSize())
            Text(fmtDur(p.duration), color = C.dText, fontSize = 10.sp, fontWeight = FontWeight.SemiBold,
                modifier = Modifier.align(Alignment.BottomStart).padding(4.dp).clip(RoundedCornerShape(4.dp)).background(C.text).padding(horizontal = 4.dp, vertical = 1.dp))
        }
        Spacer(Modifier.width(14.dp))
        Column(Modifier.weight(1f)) {
            Text(p.name, fontSize = 16.sp, fontWeight = FontWeight.SemiBold, color = C.text, maxLines = 1, overflow = TextOverflow.Ellipsis)
            Text("${p.width}x${p.height} · ${p.fps}fps · ${p.layers.size} katman", fontSize = 12.sp, color = C.text2)
        }
        Box {
            IconButton(onClick = { menu = true }) { Icon(Icons.Filled.MoreVert, "Proje menüsü", tint = C.text2) }
            DropdownMenu(menu, onDismissRequest = { menu = false }) {
                DropdownMenuItem(text = { Text("Çoğalt") }, onClick = { menu = false; scope.launch { store.duplicate(p) } })
                DropdownMenuItem(text = { Text("Sil", color = Color(0xFFD23B3B)) }, onClick = { menu = false; confirm = true })
            }
        }
    }
    if (confirm) AlertDialog(
        onDismissRequest = { confirm = false },
        title = { Text("Proje silinsin mi?") },
        text = { Text("\"${p.name}\" kalıcı olarak silinecek.") },
        confirmButton = { TextButton(onClick = { confirm = false; scope.launch { store.delete(p.id) } }) { Text("Sil", color = Color(0xFFD23B3B)) } },
        dismissButton = { TextButton(onClick = { confirm = false }) { Text("Vazgeç") } },
    )
}

@Composable
private fun BottomNav(modifier: Modifier, onNew: () -> Unit) {
    Box(modifier.fillMaxWidth().height(96.dp)) {
        Row(
            Modifier.align(Alignment.BottomCenter).fillMaxWidth().height(72.dp).shadow(8.dp).background(C.card).padding(bottom = 6.dp),
            horizontalArrangement = Arrangement.SpaceAround, verticalAlignment = Alignment.CenterVertically,
        ) {
            NavItem(Icons.Filled.Home, "Ana Sayfa", true)
            NavItem(null, "Öğreticiler", false)
            Spacer(Modifier.width(64.dp))
            NavItem(Icons.Filled.Person, "Hesap", false)
            NavItem(null, "Şablonlar", false)
        }
        Box(
            Modifier.align(Alignment.TopCenter).size(60.dp).shadow(10.dp, CircleShape).clip(CircleShape).background(C.primary).clickable(onClick = onNew),
            contentAlignment = Alignment.Center,
        ) { Icon(Icons.Filled.Add, "Yeni proje", tint = C.onPrimary, modifier = Modifier.size(30.dp)) }
    }
}

@Composable
private fun NavItem(icon: androidx.compose.ui.graphics.vector.ImageVector?, label: String, on: Boolean) {
    Column(horizontalAlignment = Alignment.CenterHorizontally, modifier = Modifier.width(64.dp)) {
        if (icon != null) Icon(icon, null, tint = if (on) C.text else C.text2, modifier = Modifier.size(24.dp)) else Spacer(Modifier.size(24.dp))
        Text(label, fontSize = 12.sp, fontWeight = if (on) FontWeight.Bold else FontWeight.Medium, color = if (on) C.text else C.text2)
    }
}

private data class Ratio(val k: String, val w: Int, val h: Int, val bw: Int, val bh: Int)
private val RATIOS = listOf(Ratio("16:9", 16, 9, 56, 30), Ratio("9:16", 9, 16, 31, 54), Ratio("4:5", 4, 5, 31, 38), Ratio("1:1", 1, 1, 31, 31), Ratio("4:3", 4, 3, 41, 31))

@Composable
private fun NewProjectSheet(count: Int, onClose: () -> Unit, onCreate: (Project) -> Unit) {
    val store = Store.get(LocalContext.current)
    val scope = rememberCoroutineScope()
    var name by remember { mutableStateOf("Yeni Proje ${count + 1}") }
    var ratio by remember { mutableStateOf(RATIOS[2]) }
    var res by remember { mutableIntStateOf(720) }
    var fps by remember { mutableIntStateOf(30) }
    var bg by remember { mutableStateOf("#FFFFFF") }
    val dims = if (ratio.w >= ratio.h) listOf(Math.round(res * ratio.w / ratio.h / 2f) * 2, res) else listOf(res, Math.round(res * ratio.h / ratio.w / 2f) * 2)

    Box(Modifier.fillMaxSize().background(Color(0x660B1430)).clickable(interactionSource = remember { androidx.compose.foundation.interaction.MutableInteractionSource() }, indication = null, onClick = onClose)) {
        Column(
            Modifier.align(Alignment.BottomCenter).fillMaxWidth().clip(RoundedCornerShape(topStart = 22.dp, topEnd = 22.dp)).background(C.bg)
                .clickable(interactionSource = remember { androidx.compose.foundation.interaction.MutableInteractionSource() }, indication = null) {}
                .padding(horizontal = 26.dp, vertical = 22.dp),
        ) {
            Row(Modifier.fillMaxWidth().border(1.dp, C.line, RoundedCornerShape(8.dp)).padding(3.dp)) {
                Box(Modifier.weight(1f).clip(RoundedCornerShape(6.dp)).background(C.text).padding(vertical = 8.dp), contentAlignment = Alignment.Center) { Text("PROJE", color = C.cyan, fontWeight = FontWeight.Bold) }
                Box(Modifier.weight(1f).padding(vertical = 8.dp), contentAlignment = Alignment.Center) { Text("ELEMENT", color = C.text2.copy(alpha = .5f), fontWeight = FontWeight.Bold) }
            }
            Spacer(Modifier.height(24.dp))
            Row(Modifier.fillMaxWidth().height(42.dp), verticalAlignment = Alignment.CenterVertically) {
                BasicTextField(name, { name = it.take(40) }, Modifier.weight(1f), singleLine = true, textStyle = TextStyle(fontSize = 16.sp, color = C.text))
                IconButton(onClick = { name = "" }, Modifier.size(32.dp)) { Icon(Icons.Filled.Close, "Adı temizle", tint = C.text2, modifier = Modifier.size(16.dp)) }
            }
            HorizontalDivider(color = C.text2)
            Spacer(Modifier.height(22.dp))
            Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceEvenly, verticalAlignment = Alignment.Bottom) {
                RATIOS.forEach { r ->
                    val on = r == ratio
                    Box(
                        Modifier.size(r.bw.dp, r.bh.dp).clip(RoundedCornerShape(4.dp)).background(if (on) C.text else C.card).border(1.5.dp, if (on) C.text else C.line, RoundedCornerShape(4.dp)).clickable { ratio = r },
                        contentAlignment = Alignment.Center,
                    ) { Text(r.k, fontSize = 10.sp, color = if (on) C.cyan else C.text2, fontWeight = FontWeight.Bold) }
                }
            }
            Spacer(Modifier.height(20.dp))
            OptRow("Çözünürlük", "${dims[0]} × ${dims[1]}", listOf(480 to "480p", 720 to "720p (HD)", 1080 to "1080p (Full HD)"), res) { res = it }
            OptRow("Kare Hızı", null, listOf(24 to "24 fps", 30 to "30 fps", 60 to "60 fps"), fps) { fps = it }
            Row(Modifier.fillMaxWidth().padding(vertical = 8.dp), verticalAlignment = Alignment.CenterVertically) {
                Text("Arka Fon", Modifier.weight(1f), color = C.text, fontSize = 15.sp)
                listOf("#FFFFFF", "#000000", "#0B1430", "#22D3C5", "#F2C94C").forEach { c ->
                    Box(Modifier.padding(start = 6.dp).size(28.dp).clip(CircleShape).background(parseColor(c)).border(if (c == bg) 3.dp else 1.dp, if (c == bg) C.primary else C.line, CircleShape).clickable { bg = c })
                }
            }
            Row(Modifier.fillMaxWidth().padding(top = 18.dp), horizontalArrangement = Arrangement.End) {
                TextButton(onClick = {
                    val p = newProject(name.ifBlank { "Adsız Proje" }, dims[0], dims[1], fps, bg)
                    scope.launch { store.save(p); onCreate(p) }
                }) { Text("PROJE OLUŞTUR", color = C.primary, fontWeight = FontWeight.Bold, fontSize = 15.sp) }
            }
        }
    }
}

@Composable
private fun OptRow(label: String, sub: String?, opts: List<Pair<Int, String>>, value: Int, onPick: (Int) -> Unit) {
    var open by remember { mutableStateOf(false) }
    Row(Modifier.fillMaxWidth().padding(vertical = 8.dp), verticalAlignment = Alignment.CenterVertically) {
        Column(Modifier.weight(1f)) {
            Text(label, color = C.text, fontSize = 15.sp)
            if (sub != null) Text(sub, color = C.text2, fontSize = 12.sp)
        }
        Box {
            OutlinedButton(onClick = { open = true }, shape = RoundedCornerShape(8.dp), border = BorderStroke(1.dp, C.line)) { Text(opts.first { it.first == value }.second, color = C.text) }
            DropdownMenu(open, onDismissRequest = { open = false }) {
                opts.forEach { (v, l) -> DropdownMenuItem(text = { Text(l) }, onClick = { onPick(v); open = false }) }
            }
        }
    }
}

fun parseColor(hex: String): Color = runCatching { Color(android.graphics.Color.parseColor(hex)) }.getOrDefault(Color.White)

/** Soldan açılan ayarlar: Lite ve eski uygulamadan proje aktarma */
@OptIn(ExperimentalFoundationApi::class)
@Composable
private fun SettingsDrawer(store: Store, onClose: () -> Unit) {
    val ctx = LocalContext.current
    val scope = rememberCoroutineScope()
    val lite by store.lite.collectAsState()
    var busy by remember { mutableStateOf(false) }
    val pick = rememberLauncherForActivityResult(ActivityResultContracts.OpenDocument()) { uri ->
        if (uri == null) return@rememberLauncherForActivityResult
        busy = true
        scope.launch {
            val msg = runCatching { store.importBackup(uri) }.fold(
                { "${it.projects} proje aktarıldı (${it.media} medya dosyası)." },
                { "Aktarılamadı: ${it.message}" },
            )
            busy = false
            Toast.makeText(ctx, msg, Toast.LENGTH_LONG).show()
        }
    }
    Column(Modifier.fillMaxHeight().width(300.dp).background(C.bg).padding(20.dp)) {
        Text("Ayarlar", fontSize = 26.sp, fontWeight = FontWeight.ExtraBold, color = C.text)
        Spacer(Modifier.height(18.dp))
        Row(Modifier.fillMaxWidth().clip(RoundedCornerShape(12.dp)).background(C.card).combinedClickable(onClick = { store.setLite(!lite) }, onLongClick = {
            Toast.makeText(ctx, "Lite ayarları yakında Glow'a da gelecek.", Toast.LENGTH_SHORT).show()
        }).padding(14.dp), verticalAlignment = Alignment.CenterVertically) {
            Column(Modifier.weight(1f)) {
                Text("Warden Motion Lite", fontWeight = FontWeight.Bold, color = C.text)
                Text("Düşük güçlü telefonlar için daha hafif önizleme", fontSize = 12.sp, color = C.text2)
            }
            Switch(lite, onCheckedChange = { store.setLite(it) })
        }
        Spacer(Modifier.height(12.dp))
        Column(Modifier.fillMaxWidth().clip(RoundedCornerShape(12.dp)).background(C.card).padding(14.dp)) {
            Text("Eski uygulamadan projeleri aktar", fontWeight = FontWeight.Bold, color = C.text)
            Text("Eski Warden Motion'da Hesap > \"Şimdi yedekle\" ile aldığın yedek dosyasını ya da bir proje dosyasını (.wmproje) seç.", fontSize = 12.sp, color = C.text2)
            Spacer(Modifier.height(10.dp))
            Button(onClick = { pick.launch(arrayOf("*/*")) }, enabled = !busy, shape = RoundedCornerShape(10.dp)) { Text(if (busy) "Aktarılıyor…" else "Yedek dosyası seç") }
        }
        Spacer(Modifier.weight(1f))
        Text("Warden Motion: Glow", color = C.text2, fontSize = 12.sp, modifier = Modifier.clickable(onClick = onClose))
    }
}

/** Projenin küçük resmi: ilk karesi (çizim motoruyla) */
@Composable
fun ProjectThumb(store: Store, p: Project, modifier: Modifier) {
    val r = LocalRenderer.current
    val ver by r.version.collectAsState()
    Canvas(modifier) {
        ver.hashCode()
        val k = min(size.width / p.width, size.height / p.height)
        val ox = (size.width - p.width * k) / 2; val oy = (size.height - p.height * k) / 2
        drawIntoCanvas { cv ->
            val nc = cv.nativeCanvas
            nc.save(); nc.translate(ox, oy)
            r.draw(nc, p, 0.0, k)
            nc.restore()
        }
    }
}
