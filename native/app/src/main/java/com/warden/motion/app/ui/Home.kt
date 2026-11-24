package com.warden.motion.app.ui

import android.net.Uri
import androidx.activity.compose.BackHandler
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.PathEffect
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.layout.layout
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Constraints
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import com.warden.motion.app.R
import com.warden.motion.app.data.Share
import com.warden.motion.app.data.Store
import com.warden.motion.app.model.LEVELS
import com.warden.motion.app.model.Project
import com.warden.motion.app.model.TEMPLATES
import com.warden.motion.app.model.TUTORIALS
import com.warden.motion.app.model.Tutorial
import com.warden.motion.app.model.fmtTime
import com.warden.motion.app.model.newProject
import kotlinx.coroutines.launch
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

enum class Tab { HOME, TUTORIALS, ACCOUNT }

@Composable
fun HomeScreen(store: Store, tab: Tab, setTab: (Tab) -> Unit, onOpen: (Project) -> Unit) {
    val projects by store.projects.collectAsState()
    val lite by store.lite.collectAsState()
    val profile by store.profile.collectAsState()
    var sheet by remember { mutableStateOf(false) }
    var drawer by remember { mutableStateOf(false) }
    var selecting by remember { mutableStateOf(false) }

    BackHandler(enabled = sheet || drawer || tab != Tab.HOME) {
        when { sheet -> sheet = false; drawer -> drawer = false; else -> setTab(Tab.HOME) }
    }
    val startTutorial = { tu: Tutorial -> onOpen(newProject(tu.title, tu.w, tu.h, 30, tu.bg).copy(tutorial = tu.id)) }
    val tpls = remember { TEMPLATES.map { it to it.make() } }

    Box(Modifier.fillMaxSize().background(C.bg).statusBarsPadding()) {
        Column(Modifier.fillMaxSize()) {
            Box(Modifier.fillMaxWidth().padding(start = 12.dp, end = 12.dp, top = 12.dp, bottom = 6.dp).height(44.dp)) {
                Box(Modifier.align(Alignment.CenterStart).size(44.dp).tap { drawer = true }, contentAlignment = Alignment.Center) { Ico("menu", C.text, 26.dp, 2f) }
                Brand(lite, Modifier.align(Alignment.Center))
                Box(Modifier.align(Alignment.CenterEnd).size(44.dp).tap { setTab(Tab.ACCOUNT) }, contentAlignment = Alignment.Center) { AccountAvatar(34.dp, profile) }
            }
            Column(Modifier.fillMaxSize().verticalScroll(rememberScrollState()).padding(horizontal = 20.dp).padding(bottom = 110.dp)) {
                when (tab) {
                    Tab.ACCOUNT -> AccountScreen(store)
                    Tab.TUTORIALS -> {
                        SecHead("Öğreticiler", "8 proje · 3 CB · 5 genel")
                        TUTORIALS.forEach { tu -> TutCard(tu) { startTutorial(tu) }; Spacer(Modifier.height(12.dp)) }
                    }
                    Tab.HOME -> {
                        SecHead("Yeni Şablonlar", "Dokun ve aç")
                        Row(Modifier.fillMaxWidth().horizontalScroll(rememberScrollState()).padding(bottom = 4.dp), horizontalArrangement = Arrangement.spacedBy(14.dp)) {
                            tpls.forEach { (t, p) -> TplItem(t.name, { onOpen(t.make()) }) { Thumb(p, 1.6, Modifier.fillMaxSize().clip(CircleShape), cover = true, px = 160) } }
                            TUTORIALS.filter { it.ready }.forEach { tu ->
                                TplItem(tu.title, { startTutorial(tu) }) {
                                    Box(Modifier.fillMaxSize().clip(CircleShape).background(Color(0xFFDCE6F5)), contentAlignment = Alignment.Center) { Ico("cap", C.primary, 30.dp) }
                                }
                            }
                        }
                        SecHead("Son projeler", "${projects.size} proje")
                        NewCard { sheet = true }
                        ProjectImport(store)
                        ProjectList(store, projects, onOpen) { selecting = it }
                        if (projects.isEmpty()) Text("Henüz proje yok. Yukarıdaki şablonlardan birini aç ya da yeni proje oluştur.", color = C.text2, fontSize = 14.sp, modifier = Modifier.padding(vertical = 18.dp, horizontal = 4.dp))
                    }
                }
            }
        }
        if (!selecting) BottomNav(Modifier.align(Alignment.BottomCenter), tab, setTab, profile) { sheet = true }
        if (drawer) { Scrim(Color(0x990D1631)) { drawer = false }; SettingsDrawer(store) { drawer = false } }
        if (sheet) NewProjectSheet(projects.size, onClose = { sheet = false }) { p -> sheet = false; onOpen(p) }
        Hint.Host()
    }
}

@Composable
fun SecHead(title: String, sub: String) {
    Row(Modifier.fillMaxWidth().padding(top = 18.dp, bottom = 12.dp), verticalAlignment = Alignment.Bottom) {
        Text(title, fontSize = 19.sp, fontWeight = FontWeight.SemiBold, color = C.text, modifier = Modifier.weight(1f))
        Text(sub, fontSize = 13.sp, color = C.text2)
    }
}

/** Logo + "Warden Motion" (+ Lite). Logo yer kaplamaz; "Wa" en büyük karenin üstünde duruyor gibi */
@Composable
fun Brand(lite: Boolean, modifier: Modifier = Modifier) {
    Row(modifier, verticalAlignment = Alignment.CenterVertically) {
        Box {
            Image(painterResource(R.drawable.logo_mark), null, contentScale = ContentScale.FillWidth,
                modifier = Modifier.layout { m, _ ->
                    val pl = m.measure(Constraints.fixed(52.5.dp.roundToPx(), (52.5f * 680 / 516).dp.roundToPx()))
                    layout(0, 0) { pl.place((-23.5).dp.roundToPx(), (-13.9).dp.roundToPx()) }
                })
            Text("Warden Motion", fontSize = 21.sp, lineHeight = 25.sp, fontWeight = FontWeight.SemiBold, color = C.text)
        }
        if (lite) { Spacer(Modifier.width(8.dp)); LiteBadge() }
    }
}

@Composable
private fun TplItem(name: String, onClick: () -> Unit, content: @Composable () -> Unit) {
    Column(Modifier.width(80.dp).tap(onClick = onClick), horizontalAlignment = Alignment.CenterHorizontally) {
        Box(Modifier.size(74.dp).border(3.dp, C.primary, CircleShape).padding(6.dp)) { content() }
        Spacer(Modifier.height(8.dp))
        Text(name, fontSize = 12.sp, fontWeight = FontWeight.Medium, textAlign = TextAlign.Center, maxLines = 2, color = C.text)
    }
}

@Composable
private fun TutCard(tu: Tutorial, onClick: () -> Unit) {
    val n = LEVELS.indexOf(tu.level) + 1
    val a = if (tu.ready) 1f else 0.75f
    Column(
        Modifier.fillMaxWidth().clip(RoundedCornerShape(16.dp)).background(C.card).border(1.dp, C.line, RoundedCornerShape(16.dp))
            .tap(enabled = tu.ready, onClick = onClick).padding(14.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
            Badge(tu.kind, if (tu.kind == "CB") Color(0xFFD3F4F1) else Color(0xFFDCE6F5), if (tu.kind == "CB") Color(0xFF0E7C74) else C.primary)
            if (!tu.ready) Badge("Yakında", C.soft, C.text2)
        }
        Text(tu.title, fontSize = 17.sp, fontWeight = FontWeight.Bold, color = C.text.copy(alpha = a))
        Row(horizontalArrangement = Arrangement.spacedBy(4.dp)) { repeat(5) { i -> Box(Modifier.size(18.dp, 5.dp).clip(RoundedCornerShape(3.dp)).background(if (i < n) C.primary else C.line)) } }
        Text(tu.summary, fontSize = 13.sp, color = C.text2.copy(alpha = a))
    }
}

@Composable
fun Badge(t: String, bg: Color, fg: Color) {
    Text(t, fontSize = 11.sp, fontWeight = FontWeight.Bold, color = fg, modifier = Modifier.clip(RoundedCornerShape(6.dp)).background(bg).padding(horizontal = 8.dp, vertical = 3.dp))
}

@Composable
private fun NewCard(onClick: () -> Unit) {
    Box(Modifier.fillMaxWidth().height(68.dp).clip(RoundedCornerShape(16.dp)).background(C.card).tap(onClick = onClick), contentAlignment = Alignment.Center) {
        Canvas(Modifier.matchParentSize()) {
            val w = 2.dp.toPx()
            drawRoundRect(Color(0xFFA9B6C9), topLeft = Offset(w / 2, w / 2), size = Size(size.width - w, size.height - w),
                cornerRadius = CornerRadius(16.dp.toPx()), style = Stroke(w, pathEffect = PathEffect.dashPathEffect(floatArrayOf(6.dp.toPx(), 4.dp.toPx()))))
        }
        Row(verticalAlignment = Alignment.CenterVertically) {
            Box(Modifier.size(32.dp).clip(CircleShape).background(C.primary), contentAlignment = Alignment.Center) { Ico("plus", C.onPrimary, 18.dp, 2.4f) }
            Spacer(Modifier.width(16.dp))
            Text("Yeni Proje Oluştur", fontSize = 18.sp, fontWeight = FontWeight.Medium, color = C.text)
        }
    }
}

/** Proje dosyası (.wmproje) ya da yedek aç */
@Composable
private fun ProjectImport(store: Store) {
    val scope = rememberCoroutineScope()
    val pick = rememberLauncherForActivityResult(ActivityResultContracts.OpenDocument()) { uri ->
        if (uri == null) return@rememberLauncherForActivityResult
        scope.launch {
            runCatching { store.importBackup(uri) }.fold(
                { Hint.show(if (it.projects == 1) "\"${it.names[0]}\" projelerine eklendi." else "${it.projects} proje eklendi.") },
                { Hint.show(if (it.message?.contains("Warden") == true) "Bu bir Warden Motion proje dosyası değil." else "Dosya açılamadı.") },
            )
        }
    }
    Row(
        Modifier.fillMaxWidth().padding(top = 10.dp).height(44.dp).clip(RoundedCornerShape(14.dp)).background(C.card).border(1.dp, C.line, RoundedCornerShape(14.dp))
            .tap { pick.launch(arrayOf("*/*")) },
        horizontalArrangement = Arrangement.Center, verticalAlignment = Alignment.CenterVertically,
    ) {
        Ico("upload", C.primary, 18.dp)
        Spacer(Modifier.width(8.dp))
        Text("Proje dosyası aç", color = C.primary, fontSize = 15.sp, fontWeight = FontWeight.SemiBold)
    }
}

private enum class Dest { DRIVE, FILES, OTHER }

/** Projeler: ⋯ menüsü ve basılı tutarak çoklu seçim */
@OptIn(ExperimentalFoundationApi::class)
@Composable
private fun ProjectList(store: Store, projects: List<Project>, onOpen: (Project) -> Unit, onSelecting: (Boolean) -> Unit) {
    val ctx = LocalContext.current
    val scope = rememberCoroutineScope()
    var sel by remember { mutableStateOf<Set<String>?>(null) }
    var menu by remember { mutableStateOf<Project?>(null) }
    var saveFor by remember { mutableStateOf<List<Project>?>(null) }
    var confirm by remember { mutableStateOf<List<Project>?>(null) }
    var pendingFiles by remember { mutableStateOf<List<Project>?>(null) }
    LaunchedEffect(sel != null) { onSelecting(sel != null) }
    BackHandler(enabled = sel != null) { sel = null }

    val toggle = { id: String -> sel = (sel.orEmpty().let { if (id in it) it - id else it + id }).ifEmpty { null } }
    val fileName = { ps: List<Project> -> (if (ps.size == 1) ps[0].name else "${ps.size}-proje").replace(Regex("[^\\p{L}\\p{N}]+"), "-").take(30) + ".wmproje" }
    val createDoc = rememberLauncherForActivityResult(ActivityResultContracts.CreateDocument("application/json")) { uri ->
        val ps = pendingFiles; pendingFiles = null
        if (uri != null && ps != null) scope.launch { store.exportBackup(uri, ps.map { it.id }.toSet()); Hint.show("Kaydedildi.") }
    }
    val upload = { ps: List<Project>, dest: Dest ->
        if (dest == Dest.FILES) { pendingFiles = ps; createDoc.launch(fileName(ps)) }
        else scope.launch {
            Hint.show("Hazırlanıyor…")
            val f = File(Share.shareDir(ctx), fileName(ps))
            store.exportBackup(Uri.fromFile(f), ps.map { it.id }.toSet())
            Share.send(ctx, f, "application/json", if (dest == Dest.DRIVE) Share.DRIVE else null)
        }
    }

    Column(Modifier.padding(top = 12.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
        projects.forEach { p ->
            val on = sel?.contains(p.id) == true
            Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                if (sel != null) {
                    Box(Modifier.padding(end = 10.dp).size(24.dp).border(2.dp, C.text, CircleShape).tap { toggle(p.id) }, contentAlignment = Alignment.Center) {
                        if (on) Box(Modifier.size(14.dp).clip(CircleShape).background(C.text))
                    }
                }
                Row(
                    Modifier.weight(1f).clip(RoundedCornerShape(14.dp)).background(if (on) Color(0xFFDCE6F5) else C.card)
                        .combinedClickable(interactionSource = remember { MutableInteractionSource() }, indication = null,
                            onClick = { if (sel != null) toggle(p.id) else onOpen(p) }, onLongClick = { toggle(p.id) })
                        .padding(8.dp),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    Box(Modifier.size(80.dp).clip(RoundedCornerShape(8.dp)).background(Color(0xFFE3E9F2)).border(1.dp, C.line, RoundedCornerShape(8.dp))) {
                        Thumb(p, 0.6, Modifier.fillMaxSize(), px = 220)
                        Text(fmtTime(p.duration, p.fps), color = C.dText, fontSize = 10.sp, fontWeight = FontWeight.SemiBold,
                            modifier = Modifier.align(Alignment.BottomStart).padding(4.dp).clip(RoundedCornerShape(4.dp)).background(C.text).padding(horizontal = 4.dp, vertical = 2.dp))
                    }
                    Spacer(Modifier.width(14.dp))
                    Column(Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(4.dp)) {
                        Text(p.name, fontSize = 16.sp, fontWeight = FontWeight.SemiBold, color = C.text, maxLines = 1, overflow = TextOverflow.Ellipsis)
                        Text("${p.width}x${p.height} · ${p.fps}fps", fontSize = 12.sp, color = Color(0xFF6A7891))
                        Text("${p.layers.size} katman · ${SimpleDateFormat("d.MM.yyyy", Locale("tr")).format(Date(p.updatedAt))}", fontSize = 12.sp, color = Color(0xFF6A7891))
                    }
                    if (sel == null) Box(Modifier.size(44.dp).tap { menu = p }, contentAlignment = Alignment.Center) { Ico("more", C.text, 24.dp, 3f) }
                }
            }
        }
    }

    val chosen = projects.filter { sel?.contains(it.id) == true }
    if (sel != null) Overlay {
        Box(Modifier.fillMaxSize()) {
            Row(Modifier.fillMaxWidth().background(C.bg).statusBarsPadding().height(60.dp).padding(start = 16.dp, end = 12.dp), verticalAlignment = Alignment.CenterVertically) {
                Text("${sel!!.size} seçildi", fontSize = 20.sp, fontWeight = FontWeight.ExtraBold, color = C.text, modifier = Modifier.weight(1f))
                Text("İptal", fontSize = 16.sp, fontWeight = FontWeight.SemiBold, color = C.primary, modifier = Modifier.tap { sel = null }.padding(8.dp))
            }
            Row(Modifier.align(Alignment.BottomCenter).fillMaxWidth().background(Color(0xFF2E3459)).navigationBarsPadding().height(68.dp),
                horizontalArrangement = Arrangement.SpaceAround, verticalAlignment = Alignment.CenterVertically) {
                SelAct("cloudUp", "Hesaba Ekle") { saveFor = chosen }
                SelAct("copy", "Çoğalt") { scope.launch { chosen.forEach { store.duplicate(it) }; Hint.show(if (chosen.size > 1) "${chosen.size} proje çoğaltıldı." else "Proje çoğaltıldı.") } }
                SelAct("trash", "Sil") { confirm = chosen }
            }
        }
    }
    menu?.let { p ->
        PMenu(onDismiss = { menu = null }) {
            MenuItem("Seç", "hand") { menu = null; sel = setOf(p.id) }
            MenuItem("Dışa Aktar", "share") { menu = null; onOpen(p) }
            MenuItem("Çoğalt", "copy") { menu = null; scope.launch { store.duplicate(p); Hint.show("Proje çoğaltıldı.") } }
            MenuItem("Hesaba Ekle", "cloudUp") { menu = null; saveFor = listOf(p) }
            MenuItem("Sil", "trash") { menu = null; confirm = listOf(p) }
        }
    }
    saveFor?.let { ps ->
        PMenu(onDismiss = { saveFor = null }, title = "Hesaba Ekle") {
            if (Share.has(ctx, Share.DRIVE)) MenuItem("Google Drive", "drive") { saveFor = null; upload(ps, Dest.DRIVE) }
            MenuItem("Google Files", "folder") { saveFor = null; upload(ps, Dest.FILES) }
            MenuItem("Diğer uygulamalar", "share") { saveFor = null; upload(ps, Dest.OTHER) }
        }
    }
    confirm?.let { ps ->
        val one = ps.size == 1
        ConfirmDialog(if (one) "Proje silinsin mi?" else "${ps.size} proje silinsin mi?", if (one) "\"${ps[0].name}\" kalıcı olarak silinecek." else "Seçilen projeler kalıcı olarak silinecek.", "Sil",
            onYes = { confirm = null; scope.launch { ps.forEach { store.delete(it.id) }; sel = null } }, onNo = { confirm = null })
    }
}

@Composable
private fun SelAct(icon: String, label: String, onClick: () -> Unit) {
    Column(Modifier.widthIn(min = 76.dp).tap(onClick = onClick), horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(4.dp)) {
        Ico(icon, C.bg, 24.dp, 1.7f)
        Text(label, fontSize = 12.sp, color = C.bg)
    }
}

/** Ekranın tamamını kaplayan katman (web'deki position:fixed gibi) */
@Composable
fun Overlay(content: @Composable () -> Unit) {
    androidx.compose.ui.window.Popup(properties = androidx.compose.ui.window.PopupProperties(focusable = false, clippingEnabled = false)) {
        Box(Modifier.fillMaxSize()) { content() }
    }
}

/** Menü (eski uygulamadaki .pmenu): yuvarlak köşeli kart, ikonlar sağda */
@Composable
fun PMenu(onDismiss: () -> Unit, title: String? = null, content: @Composable ColumnScope.() -> Unit) {
    Dialog(onDismissRequest = onDismiss, properties = DialogProperties(usePlatformDefaultWidth = false)) {
        Box(Modifier.fillMaxSize().tap(onClick = onDismiss), contentAlignment = Alignment.Center) {
            Column(Modifier.width(280.dp).shadow(16.dp, RoundedCornerShape(18.dp)).clip(RoundedCornerShape(18.dp)).background(C.card).tap { }.padding(vertical = 6.dp)) {
                if (title != null) {
                    Text(title, fontSize = 16.sp, fontWeight = FontWeight.Bold, color = C.text, modifier = Modifier.padding(start = 20.dp, top = 12.dp, bottom = 12.dp))
                    Box(Modifier.fillMaxWidth().height(1.dp).background(C.line))
                }
                content()
            }
        }
    }
}

@Composable
fun MenuItem(label: String, icon: String, color: Color = C.text, onClick: () -> Unit) {
    Row(Modifier.fillMaxWidth().height(54.dp).tap(onClick = onClick).padding(start = 20.dp, end = 18.dp), verticalAlignment = Alignment.CenterVertically) {
        Text(label, fontSize = 17.sp, fontWeight = FontWeight.Medium, color = color, modifier = Modifier.weight(1f))
        Ico(icon, color, 26.dp, 1.6f)
    }
}

/** Onay penceresi */
@Composable
fun ConfirmDialog(title: String, body: String, yes: String, onYes: () -> Unit, onNo: () -> Unit, danger: Boolean = true) {
    Dialog(onDismissRequest = onNo) {
        Column(Modifier.clip(RoundedCornerShape(20.dp)).background(C.card).padding(22.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
            Text(title, fontSize = 18.sp, fontWeight = FontWeight.Bold, color = C.text)
            Text(body, fontSize = 14.sp, color = C.text2)
            Row(Modifier.fillMaxWidth().padding(top = 8.dp), horizontalArrangement = Arrangement.End) {
                Text("Vazgeç", fontSize = 15.sp, fontWeight = FontWeight.SemiBold, color = C.text2, modifier = Modifier.tap(onClick = onNo).padding(12.dp))
                Text(yes, fontSize = 15.sp, fontWeight = FontWeight.Bold, color = if (danger) C.danger else C.primary, modifier = Modifier.tap(onClick = onYes).padding(12.dp))
            }
        }
    }
}

@Composable
private fun BottomNav(modifier: Modifier, tab: Tab, setTab: (Tab) -> Unit, profile: Store.Profile, onNew: () -> Unit) {
    Box(modifier.fillMaxWidth()) {
        Row(
            Modifier.align(Alignment.BottomCenter).fillMaxWidth().shadow(10.dp).background(C.card).navigationBarsPadding().height(72.dp).padding(start = 4.dp, end = 4.dp, bottom = 10.dp),
            horizontalArrangement = Arrangement.SpaceAround, verticalAlignment = Alignment.Bottom,
        ) {
            NavItem("Ana Sayfa", tab == Tab.HOME, { setTab(Tab.HOME) }) { Ico("home", if (tab == Tab.HOME) C.text else C.text2, 24.dp, fill = tab == Tab.HOME) }
            NavItem("Öğreticiler", tab == Tab.TUTORIALS, { setTab(Tab.TUTORIALS) }) { Ico("cap", if (tab == Tab.TUTORIALS) C.text else C.text2, 24.dp) }
            Spacer(Modifier.width(64.dp))
            NavItem("Hesap", tab == Tab.ACCOUNT, { setTab(Tab.ACCOUNT) }) { AccountAvatar(28.dp, profile) }
            NavItem("Şablonlar", false, { setTab(Tab.HOME) }) { Ico("grid", C.text2, 24.dp) }
        }
        Box(
            Modifier.align(Alignment.BottomCenter).navigationBarsPadding().padding(bottom = 48.dp).size(60.dp)
                .shadow(12.dp, CircleShape, ambientColor = C.primary, spotColor = C.primary).clip(CircleShape).background(C.primary).tap(onClick = onNew),
            contentAlignment = Alignment.Center,
        ) { Ico("plus", C.onPrimary, 28.dp, 2.2f) }
    }
}

@Composable
private fun NavItem(label: String, on: Boolean, onClick: () -> Unit, icon: @Composable () -> Unit) {
    Column(Modifier.widthIn(min = 64.dp).tap(onClick = onClick), horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(4.dp)) {
        icon()
        Text(label, fontSize = 12.sp, fontWeight = if (on) FontWeight.Bold else FontWeight.Medium, color = if (on) C.text else C.text2)
    }
}
