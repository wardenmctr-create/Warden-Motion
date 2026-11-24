package com.warden.motion.app.ui

import android.content.Context
import android.content.Intent
import android.media.MediaPlayer
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
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.GridItemSpan
import androidx.compose.foundation.lazy.grid.LazyGridState
import androidx.compose.foundation.lazy.grid.LazyHorizontalGrid
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.rememberLazyGridState
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
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.viewinterop.AndroidView
import com.warden.motion.app.data.GItem
import com.warden.motion.app.data.MediaQuery
import com.warden.motion.app.data.Store
import kotlinx.coroutines.launch
import org.json.JSONArray
import org.json.JSONObject

// ---------------------------------------------------------------------------------------------
// Ön dinleme: aynı anda tek ses (dosya kopyalanmadan, yerinden çalar)
// ---------------------------------------------------------------------------------------------
object Listen {
    var playing by mutableStateOf("")
    private var mp: MediaPlayer? = null
    fun toggle(ctx: Context, key: String, uri: Uri) {
        if (playing == key) { stop(); return }
        stop()
        runCatching {
            val m = MediaPlayer()
            m.setDataSource(ctx, uri)
            m.setOnCompletionListener { if (playing == key) stop() }
            m.setOnPreparedListener { it.start() }
            m.prepareAsync()
            mp = m; playing = key
        }.onFailure { Hint.show("Ses açılamadı: ${it.message}") }
    }
    fun stop() { runCatching { mp?.stop() }; runCatching { mp?.release() }; mp = null; playing = "" }
}

// ---------------------------------------------------------------------------------------------
// Kullanıcının eklediği klasörler ("+ Klasör ekle")
// ---------------------------------------------------------------------------------------------
data class UserFolder(val uri: String, val name: String)
private fun fprefs(ctx: Context) = ctx.getSharedPreferences("wm-folders", Context.MODE_PRIVATE)
fun userFolders(ctx: Context, audio: Boolean): List<UserFolder> = runCatching {
    val a = JSONArray(fprefs(ctx).getString(if (audio) "audio" else "media", "[]")); List(a.length()) { val o = a.getJSONObject(it); UserFolder(o.getString("uri"), o.getString("name")) }
}.getOrDefault(emptyList())
fun saveUserFolders(ctx: Context, audio: Boolean, f: List<UserFolder>) = fprefs(ctx).edit().putString(if (audio) "audio" else "media", JSONArray(f.map { JSONObject().put("uri", it.uri).put("name", it.name) }).toString()).apply()

/** Albüm anahtarı: "dir:<uri>" ise eklenen klasör, değilse telefondaki albüm adı */
suspend fun listAlbum(ctx: Context, kind: String, album: String, offset: Int, limit: Int): List<GItem> = when {
    album.startsWith("dir:") -> MediaQuery.folder(ctx, Uri.parse(album.removePrefix("dir:")), kind, offset, limit)
    kind == "audio" -> MediaQuery.audio(ctx, album, offset, limit)
    else -> MediaQuery.visual(ctx, kind, album, offset, limit)
}
fun albumLabel(ctx: Context, album: String, audio: Boolean) = when {
    album.isEmpty() -> if (audio) "Bütün sesler" else "Her şey"
    album.startsWith("dir:") -> userFolders(ctx, audio).find { "dir:" + it.uri == album }?.name ?: "Klasör"
    else -> album
}

/** Telefondaki klasörler + eklenen klasörler; en altta "+ Klasör ekle" (kaydırılabilir) */
@Composable
fun AlbumMenu(albums: List<Pair<String, Int>>, album: String, audio: Boolean, modifier: Modifier, onPick: (String) -> Unit) {
    val ctx = LocalContext.current
    var mine by remember { mutableStateOf(userFolders(ctx, audio)) }
    val tree = rememberLauncherForActivityResult(ActivityResultContracts.OpenDocumentTree()) { u ->
        if (u != null) {
            runCatching { ctx.contentResolver.takePersistableUriPermission(u, Intent.FLAG_GRANT_READ_URI_PERMISSION) }
            val f = UserFolder(u.toString(), MediaQuery.folderName(ctx, u))
            saveUserFolders(ctx, audio, userFolders(ctx, audio).filter { it.uri != f.uri } + f)
            mine = userFolders(ctx, audio); onPick("dir:" + f.uri)
        }
    }
    Column(modifier.shadow(12.dp, RoundedCornerShape(10.dp)).clip(RoundedCornerShape(10.dp)).background(Color(0xFF2A3560)).verticalScroll(rememberScrollState()).tap { }) {
        val row = @Composable { label: String, count: Int?, on: Boolean, icon: String?, onClick: () -> Unit, x: (() -> Unit)? ->
            Row(Modifier.fillMaxWidth().height(48.dp).tap(onClick = onClick).padding(start = 18.dp), verticalAlignment = Alignment.CenterVertically) {
                if (icon != null) { Ico(icon, if (on) C.turq else C.dText, 18.dp); Spacer(Modifier.width(10.dp)) }
                Text(label, fontSize = 16.sp, color = if (on) C.turq else Color(0xFFEEF4FF), maxLines = 1, overflow = TextOverflow.Ellipsis, modifier = Modifier.weight(1f))
                if (count != null && count > 0) Text("$count", fontSize = 12.sp, color = C.dText2, modifier = Modifier.padding(end = 18.dp))
                if (x != null) Box(Modifier.size(48.dp).tap(onClick = x), contentAlignment = Alignment.Center) { Ico("close", C.dText2, 16.dp) }
            }
            Box(Modifier.fillMaxWidth().height(1.dp).background(Color(0x12FFFFFF)))
        }
        row(if (audio) "Bütün sesler" else "Her şey", null, album.isEmpty(), null, { onPick("") }, null)
        albums.forEach { (n, c) -> row(n, c, album == n, null, { onPick(n) }, null) }
        mine.forEach { f -> row(f.name, null, album == "dir:" + f.uri, "folder", { onPick("dir:" + f.uri) }) {
            saveUserFolders(ctx, audio, mine.filter { it.uri != f.uri }); mine = userFolders(ctx, audio); if (album == "dir:" + f.uri) onPick("")
        } }
        Row(Modifier.fillMaxWidth().height(48.dp).tap { tree.launch(null) }.padding(start = 18.dp), verticalAlignment = Alignment.CenterVertically) {
            Ico("plus", C.turq, 20.dp, 2.4f); Spacer(Modifier.width(10.dp)); Text("Klasör ekle", fontSize = 16.sp, fontWeight = FontWeight.SemiBold, color = C.turq)
        }
    }
}

/** Galeri karesi: küçük resim (+ video süresi, seçim numarası). Basılı tutunca onLong */
@OptIn(ExperimentalFoundationApi::class)
@Composable
fun Tile(it: GItem, num: Int = 0, cur: Boolean = false, onLong: (() -> Unit)? = null, onClick: () -> Unit) {
    val ctx = LocalContext.current
    var b by remember(it.key) { mutableStateOf(MediaQuery.cachedThumb(it)) }
    LaunchedEffect(it.key) { if (b == null) b = MediaQuery.thumb(ctx, it) }
    Box(Modifier.fillMaxSize().background(if (num > 0) C.turq else Color(0xFF1E2A55))
        .combinedClickable(interactionSource = remember { MutableInteractionSource() }, indication = null, onClick = onClick, onLongClick = onLong)
        .then(if (cur) Modifier.border(3.dp, C.turq) else Modifier)) {
        b?.let { bm -> Image(bm.asImageBitmap(), null, Modifier.fillMaxSize().then(if (num > 0) Modifier.padding(8.dp).clip(RoundedCornerShape(8.dp)) else Modifier), contentScale = ContentScale.Crop, alpha = if (cur) .85f else 1f) }
        if (it.video) Row(Modifier.align(Alignment.BottomEnd).padding(4.dp).clip(RoundedCornerShape(6.dp)).background(Color(0x990B1430)).padding(horizontal = 5.dp, vertical = 1.dp), verticalAlignment = Alignment.CenterVertically) {
            Ico("play", Color(0xFFEEF4FF), 10.dp); Text(fmtMs(it.durationMs), fontSize = 11.sp, fontWeight = FontWeight.Bold, color = Color(0xFFEEF4FF))
        }
        if (num > 0) Box(Modifier.align(Alignment.TopEnd).padding(5.dp).size(22.dp).clip(CircleShape).background(C.turq).border(2.dp, Color(0xFF121D40), CircleShape), contentAlignment = Alignment.Center) {
            Text("$num", fontSize = 12.sp, fontWeight = FontWeight.ExtraBold, color = C.dDeep)
        }
    }
}
fun fmtMs(ms: Long): String { val s = (ms / 1000.0).let { Math.round(it) }; return "${s / 60}:${"%02d".format(s % 60)}" }
fun fmtSec(s: Double): String { val n = Math.round(s); return "%02d:%02d".format(n / 60, n % 60) }

/** Medya izni (gerekirse sor) */
@Composable
fun rememberPermission(perms: Array<String>, onResult: (Boolean) -> Unit): () -> Unit {
    val l = rememberLauncherForActivityResult(ActivityResultContracts.RequestMultiplePermissions()) { r -> onResult(r.values.any { it }) }
    return { l.launch(perms) }
}

// ---------------------------------------------------------------------------------------------
// Medya sekmesi: telefonun galerisi doğrudan burada; ilk kare ikiye bölünmüş (üst: Tümünü görüntüle, alt: klasör)
// ---------------------------------------------------------------------------------------------
@Composable
fun MediaTab(s: EditorState, onAudio: () -> Unit, toast: (String) -> Unit, onPick: (String, String, String) -> Unit) {
    val ctx = LocalContext.current
    val scope = rememberCoroutineScope()
    var access by remember { mutableStateOf(MediaQuery.visualAccess(ctx)) }
    var items by remember { mutableStateOf(listOf<GItem>()) }
    var albums by remember { mutableStateOf(listOf<Pair<String, Int>>()) }
    var album by remember { mutableStateOf("") }
    var albMenu by remember { mutableStateOf(false) }
    var sheet by remember { mutableStateOf(false) }
    var busy by remember { mutableStateOf(false) }
    val ask = rememberPermission(MediaQuery.visualPerms()) { access = MediaQuery.visualAccess(ctx) }
    LaunchedEffect(access) { if (access != "none") albums = MediaQuery.albums(ctx, false) }
    LaunchedEffect(access, album) { if (access != "none") items = listAlbum(ctx, "any", album, 0, 90) }
    val add = { list: List<Pair<Uri, Boolean>> ->
        if (!busy) scope.launch {
            busy = true
            for ((u, vid) in list) runCatching {
                val src = Store.get(ctx).putMedia(u)
                val name = runCatching { ctx.contentResolver.query(u, arrayOf(android.provider.OpenableColumns.DISPLAY_NAME), null, null, null)?.use { c -> if (c.moveToFirst()) c.getString(0) else null } }.getOrNull()?.substringBeforeLast('.') ?: "Görsel"
                onPick(src, name, if (vid) "video" else "image")
            }.onFailure { toast("Dosya okunamadı: ${it.message}") }
            busy = false
        }
    }
    Box(Modifier.fillMaxWidth().height(260.dp)) {
        LazyVerticalGrid(GridCells.Fixed(3), Modifier.fillMaxSize(), horizontalArrangement = Arrangement.spacedBy(2.dp), verticalArrangement = Arrangement.spacedBy(2.dp)) {
            item {
                Column(Modifier.aspectRatio(1f), verticalArrangement = Arrangement.spacedBy(2.dp)) {
                    Box(Modifier.weight(1f).fillMaxWidth().clip(RoundedCornerShape(topStart = 4.dp)).background(Color(0xFF1D2A55)).tap { if (access == "none") ask() else sheet = true }, contentAlignment = Alignment.Center) { Ico("apps", C.dText, 22.dp) }
                    if (access != "none") Row(Modifier.weight(1f).fillMaxWidth().background(Color(0xFF1D2A55)).tap { albMenu = true }.padding(horizontal = 6.dp), horizontalArrangement = Arrangement.Center, verticalAlignment = Alignment.CenterVertically) {
                        Text(albumLabel(ctx, album, false), fontSize = 12.5.sp, color = C.dText, maxLines = 1, overflow = TextOverflow.Ellipsis, modifier = Modifier.weight(1f, false))
                        Ico("chevD", C.dText, 14.dp)
                    }
                }
            }
            if (access == "none") item(span = { GridItemSpan(2) }) {
                Column(Modifier.padding(6.dp), horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(10.dp)) {
                    Text("Projende görsel ve video kullanmak için galerine erişim gerekir.", fontSize = 13.sp, color = C.dText, textAlign = TextAlign.Center)
                    Text("ERİŞİME İZİN VER", fontSize = 14.sp, fontWeight = FontWeight.SemiBold, color = C.dText, modifier = Modifier.clip(RoundedCornerShape(6.dp)).background(Color(0xFF2E3F7E)).tap { ask() }.padding(horizontal = 18.dp, vertical = 10.dp))
                }
            } else items(items.size, key = { items[it].key }) { i -> Box(Modifier.aspectRatio(1f)) { Tile(items[i]) { add(listOf(items[i].uri to items[i].video)) } } }
        }
        if (busy) Box(Modifier.matchParentSize().background(Color(0x8C121D40)), contentAlignment = Alignment.Center) { Text("Hazırlanıyor…", color = C.dText, fontWeight = FontWeight.Bold) }
    }
    if (albMenu) Overlay {
        Box(Modifier.fillMaxSize().tap { albMenu = false }) {
            AlbumMenu(albums, album, false, Modifier.align(Alignment.BottomStart).navigationBarsPadding().padding(start = 8.dp, bottom = 280.dp).widthIn(max = 300.dp).fillMaxWidth(0.8f).heightIn(max = 460.dp)) { album = it; albMenu = false }
        }
    }
    if (sheet) Overlay { MediaSheet("any", true, "Görsel ya da video ekle", onClose = { sheet = false }) { list -> sheet = false; add(list.map { it.uri to it.video }) } }
}

// ---------------------------------------------------------------------------------------------
// 3/4'lük galeri penceresi: üstte önizleme, basılı tut = çoklu seç, + ile ekle
// ---------------------------------------------------------------------------------------------
@Composable
fun MediaSheet(kind: String, multiple: Boolean, title: String, onClose: () -> Unit, onDone: (List<GItem>) -> Unit) {
    val ctx = LocalContext.current
    val haptic = LocalHapticFeedback.current
    val aud = kind == "audio"
    var access by remember { mutableStateOf(if (aud) (if (MediaQuery.audioAccess(ctx)) "full" else "none") else MediaQuery.visualAccess(ctx)) }
    var items by remember { mutableStateOf(listOf<GItem>()) }
    var end by remember { mutableStateOf(false) }
    var albums by remember { mutableStateOf(listOf<Pair<String, Int>>()) }
    var album by remember { mutableStateOf("") }
    var albMenu by remember { mutableStateOf(false) }
    var multi by remember { mutableStateOf(false) }
    var sel by remember { mutableStateOf(listOf<GItem>()) }
    var prev by remember { mutableStateOf<GItem?>(null) }
    val grid = rememberLazyGridState()
    val ask = rememberPermission(if (aud) MediaQuery.audioPerms() else MediaQuery.visualPerms()) { access = if (aud) (if (MediaQuery.audioAccess(ctx)) "full" else "none") else MediaQuery.visualAccess(ctx) }
    val files = rememberLauncherForActivityResult(ActivityResultContracts.OpenMultipleDocuments()) { us ->
        if (us.isNotEmpty()) onDone(us.map { u -> val m = ctx.contentResolver.getType(u) ?: ""; GItem(0, u, m.startsWith("video/"), m.startsWith("audio/"), m, "", "", 0) })
    }
    val photos = rememberLauncherForActivityResult(ActivityResultContracts.StartActivityForResult()) { r ->
        val d = r.data ?: return@rememberLauncherForActivityResult
        val us = d.clipData?.let { c -> List(c.itemCount) { c.getItemAt(it).uri } } ?: listOfNotNull(d.data)
        if (us.isNotEmpty()) onDone(us.map { u -> val m = ctx.contentResolver.getType(u) ?: ""; GItem(0, u, m.startsWith("video/"), false, m, "", "", 0) })
    }
    BackHandler { if (albMenu) albMenu = false else { Listen.stop(); onClose() } }
    DisposableEffect(Unit) { onDispose { Listen.stop() } }
    LaunchedEffect(access) { if (access != "none") albums = MediaQuery.albums(ctx, aud) }
    LaunchedEffect(access, album) {
        if (access == "none") return@LaunchedEffect
        val r = listAlbum(ctx, kind, album, 0, 60); items = r; end = r.size < 60
        if (!aud) prev = r.firstOrNull()
    }
    // Aşağı kaydırınca devamı
    LaunchedEffect(grid, items.size) {
        snapshotFlow { grid.layoutInfo.visibleItemsInfo.lastOrNull()?.index ?: 0 }.collect { last ->
            if (!end && items.isNotEmpty() && last > items.size - 20) { val r = listAlbum(ctx, kind, album, items.size, 60); if (r.isEmpty()) end = true else items = items + r; if (r.size < 60) end = true }
        }
    }
    val keyOf = { g: GItem -> g.key }
    val toggleSel = { g: GItem -> sel = if (sel.any { keyOf(it) == keyOf(g) }) sel.filter { keyOf(it) != keyOf(g) } else sel + g }
    Box(Modifier.fillMaxSize().background(Color(0x730B1430)).tap { Listen.stop(); onClose() }) {
        Column(Modifier.align(Alignment.BottomCenter).fillMaxWidth().fillMaxHeight(0.75f).clip(RoundedCornerShape(topStart = 20.dp, topEnd = 20.dp)).background(Color(0xFF121D40)).tap { }.navigationBarsPadding()) {
            Box(Modifier.padding(top = 8.dp).size(42.dp, 5.dp).clip(RoundedCornerShape(3.dp)).background(Color(0xFF2C3E78)).align(Alignment.CenterHorizontally))
            Row(Modifier.fillMaxWidth().height(48.dp).padding(horizontal = 6.dp), verticalAlignment = Alignment.CenterVertically) {
                Box(Modifier.size(44.dp).tap { Listen.stop(); onClose() }, contentAlignment = Alignment.Center) { Ico("close", C.dText2, 24.dp) }
                if (access != "none") Row(Modifier.weight(1f, false).height(40.dp).tap { albMenu = true }.padding(horizontal = 8.dp), verticalAlignment = Alignment.CenterVertically) {
                    Text(albumLabel(ctx, album, aud), fontSize = 19.sp, fontWeight = FontWeight.SemiBold, color = C.dText, maxLines = 1, overflow = TextOverflow.Ellipsis, modifier = Modifier.weight(1f, false))
                    Ico("chevD", C.dText2, 18.dp)
                } else Text(title, fontSize = 18.sp, fontWeight = FontWeight.Bold, color = C.dText, modifier = Modifier.padding(start = 8.dp))
                Spacer(Modifier.weight(1f))
                if (!aud && access != "none" && multiple) Box(Modifier.size(44.dp).tap { multi = !multi; sel = emptyList() }, contentAlignment = Alignment.Center) { Ico("copy", if (multi) C.turq else C.dText2, 22.dp) }
                if (!aud && access != "none") {
                    val can = if (multi) sel.isNotEmpty() else prev != null
                    Box(Modifier.size(44.dp).tap(can) { onDone(if (multi) sel else listOf(prev!!)) }, contentAlignment = Alignment.Center) {
                        Ico("plus", C.dText.copy(alpha = if (can) 1f else .35f), 26.dp, 2.4f)
                        if (multi && sel.isNotEmpty()) Box(Modifier.align(Alignment.TopEnd).padding(top = 2.dp).size(18.dp).clip(CircleShape).background(C.turq), contentAlignment = Alignment.Center) { Text("${sel.size}", fontSize = 11.sp, fontWeight = FontWeight.ExtraBold, color = C.dDeep) }
                    }
                }
            }
            if (!aud && access != "none") prev?.let { Preview(it) }
            Row(Modifier.fillMaxWidth().padding(start = 10.dp, end = 10.dp, bottom = 6.dp), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                val btn = @Composable { m: Modifier, label: String, icon: @Composable () -> Unit, on: () -> Unit ->
                    Row(m.height(36.dp).clip(RoundedCornerShape(10.dp)).background(Color(0xFF1E2A55)).border(1.5.dp, Color(0xFF2C3E78), RoundedCornerShape(10.dp)).tap(onClick = on),
                        horizontalArrangement = Arrangement.Center, verticalAlignment = Alignment.CenterVertically) { icon(); Spacer(Modifier.width(8.dp)); Text(label, fontSize = 13.sp, fontWeight = FontWeight.Bold, color = C.dText, maxLines = 1) }
                }
                btn(Modifier.weight(1f), "Dosyalar", { Ico("folder", C.dText, 20.dp) }) { files.launch(arrayOf(if (aud) "audio/*" else if (kind == "image") "image/*" else "*/*")) }
                if (!aud && com.warden.motion.app.data.Share.has(ctx, "com.google.android.apps.photos")) btn(Modifier.weight(1f), "Google Fotoğraflar", {
                    Box(Modifier.size(20.dp).clip(CircleShape).background(Brush.sweepGradient(listOf(Color(0xFFEA4335), Color(0xFFFBBC05), Color(0xFF34A853), Color(0xFF4285F4), Color(0xFFEA4335)))))
                }) {
                    photos.launch(Intent(Intent.ACTION_PICK).apply {
                        setPackage("com.google.android.apps.photos"); type = if (kind == "image") "image/*" else "*/*"
                        if (kind != "image") putExtra(Intent.EXTRA_MIME_TYPES, arrayOf("image/*", "video/*"))
                        if (multiple) putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true)
                    })
                }
            }
            if (access != "none") Text(if (aud) "Karta basınca dinlersin, + ile projeye eklersin." else if (multiple && !multi) "Dokun: üstte önizle · +: ekle · Basılı tut: çoklu seç" else "",
                fontSize = 12.sp, color = C.dText2, modifier = Modifier.padding(start = 16.dp, bottom = 6.dp))
            if (access == "none") Column(Modifier.fillMaxWidth().weight(1f).padding(24.dp), horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(10.dp, Alignment.CenterVertically)) {
                Ico(if (aud) "music" else "image", C.dText2, 36.dp)
                Text(if (aud) "Seslerini burada göster" else "Galerini burada göster", fontSize = 17.sp, fontWeight = FontWeight.Bold, color = C.dText)
                Text(if (aud) "Müziklerini ve ses kayıtlarını Warden Motion'dan çıkmadan seçebilmek için izin ver." else "Fotoğraf ve videolarını Warden Motion'dan çıkmadan seçebilmek için izin ver.", fontSize = 13.5.sp, color = C.dText2, textAlign = TextAlign.Center)
                DBtn("İzin ver", modifier = Modifier.width(160.dp)) { ask() }
            } else if (aud) LazyVerticalGrid(GridCells.Fixed(3), Modifier.fillMaxWidth().weight(1f).padding(horizontal = 10.dp), state = grid, horizontalArrangement = Arrangement.spacedBy(8.dp), verticalArrangement = Arrangement.spacedBy(8.dp), contentPadding = PaddingValues(bottom = 80.dp)) {
                items(items.size, key = { items[it].key }) { i ->
                    val g = items[i]
                    AudioCard(g.name, g.durationMs / 1000.0, false, Listen.playing == g.key, Modifier.aspectRatio(1f), onListen = { Listen.toggle(ctx, g.key, g.uri) }) { Listen.stop(); onDone(listOf(g)) }
                }
                if (items.isEmpty() && end) item(span = { GridItemSpan(3) }) { Text("Telefonda ses dosyası bulunamadı.", color = C.dText2, fontSize = 13.sp, textAlign = TextAlign.Center, modifier = Modifier.padding(30.dp)) }
            } else LazyVerticalGrid(GridCells.Fixed(4), Modifier.fillMaxWidth().weight(1f).padding(horizontal = 2.dp), state = grid, horizontalArrangement = Arrangement.spacedBy(2.dp), verticalArrangement = Arrangement.spacedBy(2.dp), contentPadding = PaddingValues(bottom = 80.dp)) {
                items(items.size, key = { items[it].key }) { i ->
                    val g = items[i]
                    Box(Modifier.aspectRatio(1f)) {
                        Tile(g, if (multi) sel.indexOfFirst { keyOf(it) == keyOf(g) } + 1 else 0, prev?.let { keyOf(it) == keyOf(g) } == true,
                            onLong = { haptic.performHapticFeedback(HapticFeedbackType.LongPress); prev = g; if (multiple) { multi = true; if (sel.none { keyOf(it) == keyOf(g) }) sel = sel + g } }) { prev = g; if (multi) toggleSel(g) }
                    }
                }
                if (items.isEmpty() && end) item(span = { GridItemSpan(4) }) { Text("Burada fotoğraf yok.", color = C.dText2, fontSize = 13.sp, textAlign = TextAlign.Center, modifier = Modifier.padding(30.dp)) }
            }
        }
        if (albMenu) Box(Modifier.fillMaxSize().tap { albMenu = false }) {
            AlbumMenu(albums, album, aud, Modifier.align(Alignment.BottomStart).padding(start = 10.dp).fillMaxHeight(0.65f).widthIn(max = 300.dp).fillMaxWidth(0.8f).navigationBarsPadding()) { album = it; albMenu = false }
        }
    }
}

/** Üstteki önizleme: görsel büyük hâliyle, video oynatılabilir (dosya kopyalanmadan) */
@Composable
private fun Preview(it: GItem) {
    val ctx = LocalContext.current
    var big by remember(it.key) { mutableStateOf<android.graphics.Bitmap?>(null) }
    var play by remember(it.key) { mutableStateOf(false) }
    LaunchedEffect(it.key) { big = MediaQuery.thumb(ctx, it, 240); if (!it.video) big = kotlinx.coroutines.withContext(kotlinx.coroutines.Dispatchers.IO) { runCatching { ctx.contentResolver.openInputStream(it.uri)?.use { s -> android.graphics.BitmapFactory.decodeStream(s, null, android.graphics.BitmapFactory.Options().apply { inSampleSize = 4 }) } }.getOrNull() } ?: big }
    Box(Modifier.fillMaxWidth().height(200.dp).padding(bottom = 8.dp).background(Color(0xFF050A1A)), contentAlignment = Alignment.Center) {
        if (it.video && play) AndroidView({ c -> android.widget.VideoView(c).apply { setVideoURI(it.uri); setMediaController(android.widget.MediaController(c).also { mc -> mc.setAnchorView(this) }); setOnPreparedListener { p -> p.start() } } }, Modifier.fillMaxSize())
        else big?.let { b -> Image(b.asImageBitmap(), null, Modifier.fillMaxSize(), contentScale = ContentScale.Fit) }
        if (it.video && !play) Box(Modifier.size(60.dp).clip(CircleShape).background(Color(0xA60B1430)).tap { play = true }, contentAlignment = Alignment.Center) { Ico("play", Color.White, 30.dp) }
        Row(Modifier.align(Alignment.TopStart).padding(horizontal = 8.dp, vertical = 6.dp), verticalAlignment = Alignment.CenterVertically) {
            Ico("info", Color(0xFFEEF4FF), 16.dp); Spacer(Modifier.width(6.dp))
            Text(it.name, fontSize = 12.5.sp, color = Color(0xFFEEF4FF), maxLines = 1, overflow = TextOverflow.Ellipsis)
        }
    }
}

// ---------------------------------------------------------------------------------------------
// Ses kartları (kare): üst yarı dinle, alt yarı (+) ekle
// ---------------------------------------------------------------------------------------------
private val GRADS = listOf(listOf(0xFF5B6FB8, 0xFFC46A8E, 0xFFE8A07A), listOf(0xFF4E9E7A, 0xFFB9C76A, 0xFFE8D27A), listOf(0xFFC27A3E, 0xFFE0A85A, 0xFFE8C27A),
    listOf(0xFF7A4EB8, 0xFF4E6EC4, 0xFF3E9EC2), listOf(0xFFB84E6E, 0xFFE07A6A, 0xFFE8B27A), listOf(0xFF3E8EA8, 0xFF5AB8A0, 0xFFA8D27A))
private fun hash(s: String): Int { var h = 0; for (c in s) h = h * 31 + c.code; return kotlin.math.abs(h) }

@Composable
fun AudioCard(name: String, dur: Double?, recent: Boolean, playing: Boolean, modifier: Modifier, onListen: () -> Unit, onAdd: () -> Unit) {
    val h = hash(name); val g = GRADS[h % GRADS.size]
    val label = name.substringBeforeLast('.').ifEmpty { name }
    Box(modifier.clip(RoundedCornerShape(6.dp)).background(Brush.linearGradient(g.map { Color(it) }, Offset.Zero, Offset(300f, 420f)))
        .then(if (playing) Modifier.border(2.dp, C.turq, RoundedCornerShape(6.dp)) else Modifier)) {
        Box(Modifier.fillMaxWidth().fillMaxHeight(0.5f).align(Alignment.BottomCenter).background(Color(0x33000000)))
        Text(label, fontSize = 12.5.sp, fontWeight = FontWeight.SemiBold, color = Color.White, maxLines = 1, overflow = TextOverflow.Ellipsis, modifier = Modifier.padding(start = 6.dp, end = 6.dp, top = 5.dp))
        if (dur != null) Text(fmtSec(dur), fontSize = 11.sp, color = Color.White.copy(alpha = .9f), modifier = Modifier.padding(start = 6.dp, top = 24.dp))
        // Süs dalga (isme göre hep aynı)
        Canvas(Modifier.fillMaxWidth().fillMaxHeight(0.24f).align(Alignment.Center).padding(horizontal = 4.dp)) {
            var x = h.toLong().coerceAtLeast(1)
            val n = 34; val bw = size.width / n
            for (i in 0 until n) {
                x = (x * 1103515245 + 12345) and 0x7fffffff
                val env = kotlin.math.sin(i / 33.0 * Math.PI) * 0.7 + 0.3
                val hh = kotlin.math.max(2f, ((x % 100) / 100f) * size.height * env.toFloat())
                drawRoundRect(Color.White.copy(alpha = .75f), Offset(i * bw, (size.height - hh) / 2), androidx.compose.ui.geometry.Size(bw * .55f, hh), androidx.compose.ui.geometry.CornerRadius(bw * .3f))
            }
        }
        if (playing || recent) Box(Modifier.align(Alignment.CenterEnd).padding(end = 5.dp).offset(y = (-10).dp).size(20.dp).clip(CircleShape).background(if (playing) C.turq else Color(0x40000000)), contentAlignment = Alignment.Center) {
            Ico(if (playing) "pause" else "clock", if (playing) C.dDeep else Color.White, if (playing) 12.dp else 14.dp)
        }
        Column(Modifier.fillMaxSize()) {
            Box(Modifier.fillMaxWidth().weight(1f).tap(onClick = onListen))
            Box(Modifier.fillMaxWidth().weight(1f).tap { Listen.stop(); onAdd() }, contentAlignment = Alignment.Center) { Box(Modifier.padding(top = 10.dp)) { Ico("plus", Color.White, 24.dp, 2.4f) } }
        }
    }
}

private data class RecentAudio(val src: String, val name: String, val dur: Double)
private fun recentAudio(ctx: Context): List<RecentAudio> = runCatching {
    val a = JSONArray(ctx.getSharedPreferences("wm", Context.MODE_PRIVATE).getString("recentAudio", "[]")); List(a.length()) { val o = a.getJSONObject(it); RecentAudio(o.getString("src"), o.getString("name"), o.optDouble("dur", 0.0)) }
}.getOrDefault(emptyList())
private fun pushRecentAudio(ctx: Context, r: RecentAudio) {
    val l = (listOf(r) + recentAudio(ctx).filter { it.src != r.src }).take(12)
    ctx.getSharedPreferences("wm", Context.MODE_PRIVATE).edit().putString("recentAudio", JSONArray(l.map { JSONObject().put("src", it.src).put("name", it.name).put("dur", it.dur) }).toString()).apply()
}

/** Ses sekmesi: kare kartlar, 2 satır, yana kaydırılır; en başta "Tümünü görüntüle" */
@Composable
fun AudioTab(s: EditorState, toast: (String) -> Unit, onPick: (String, String) -> Unit) {
    val ctx = LocalContext.current
    val scope = rememberCoroutineScope()
    var access by remember { mutableStateOf(MediaQuery.audioAccess(ctx)) }
    var items by remember { mutableStateOf(listOf<GItem>()) }
    val recent = remember { recentAudio(ctx) }
    var sheet by remember { mutableStateOf(false) }
    var busy by remember { mutableStateOf(false) }
    val ask = rememberPermission(MediaQuery.audioPerms()) { access = MediaQuery.audioAccess(ctx); if (!access) toast("İzin verilmedi. İstersen \"Tümünü görüntüle\" > Dosyalar ile ekleyebilirsin.") }
    LaunchedEffect(access) { if (access) items = MediaQuery.audio(ctx, "", 0, 15) }
    DisposableEffect(Unit) { onDispose { Listen.stop() } }
    val add = { g: GItem ->
        if (!busy) scope.launch {
            busy = true
            runCatching {
                val src = Store.get(ctx).putMedia(g.uri)
                val name = g.name.substringBeforeLast('.').ifEmpty { runCatching { ctx.contentResolver.query(g.uri, arrayOf(android.provider.OpenableColumns.DISPLAY_NAME), null, null, null)?.use { c -> if (c.moveToFirst()) c.getString(0) else null } }.getOrNull()?.substringBeforeLast('.') ?: "Ses" }
                pushRecentAudio(ctx, RecentAudio(src, name, mediaInfo(ctx, src).dur))
                onPick(src, name)
            }.onFailure { toast("Ses dosyası okunamadı: ${it.message}") }
            busy = false
        }
    }
    if (!access) {
        Column(Modifier.fillMaxWidth().padding(start = 12.dp, end = 12.dp, top = 18.dp, bottom = 10.dp), horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(14.dp)) {
            Text("Projende müzik ve ses kullanmak için seslerine erişim gerekir.", fontSize = 15.sp, color = C.dText, textAlign = TextAlign.Center)
            Text("ERİŞİME İZİN VER", fontSize = 15.sp, fontWeight = FontWeight.SemiBold, color = C.dText, letterSpacing = 0.3.sp, modifier = Modifier.clip(RoundedCornerShape(6.dp)).background(Color(0xFF2E3F7E)).tap { ask() }.padding(horizontal = 26.dp, vertical = 12.dp))
            Text("Dosyalardan seç", fontSize = 13.sp, color = C.turq, modifier = Modifier.tap { sheet = true })
        }
    } else {
        val seen = recent.map { it.name }.toSet()
        val dev = items.filter { it.name.substringBeforeLast('.') !in seen }
        val cs = 104.dp
        Box {
            LazyHorizontalGrid(GridCells.Fixed(2), Modifier.fillMaxWidth().height(cs * 2 + 8.dp), horizontalArrangement = Arrangement.spacedBy(8.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                item {
                    Column(Modifier.size(cs).clip(RoundedCornerShape(6.dp)).background(Color(0xFF1D2A55)).tap { Listen.stop(); sheet = true }, horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.Center) {
                        Ico("apps", C.dText, 26.dp); Spacer(Modifier.height(6.dp)); Text("Tümünü görüntüle", fontSize = 13.sp, fontWeight = FontWeight.SemiBold, color = C.dText, textAlign = TextAlign.Center)
                    }
                }
                items(recent.size) { i ->
                    val r = recent[i]
                    AudioCard(r.name, r.dur, true, Listen.playing == r.src, Modifier.size(cs), onListen = {
                        val f = Store.get(ctx).mediaFile(r.src.removePrefix("media:")); Listen.toggle(ctx, r.src, Uri.fromFile(f))
                    }) { onPick(r.src, r.name) }
                }
                items(dev.size, key = { dev[it].key }) { i ->
                    val g = dev[i]
                    AudioCard(g.name, g.durationMs / 1000.0, false, Listen.playing == g.key, Modifier.size(cs), onListen = { Listen.toggle(ctx, g.key, g.uri) }) { add(g) }
                }
            }
            if (busy) Box(Modifier.matchParentSize().background(Color(0x8C121D40)), contentAlignment = Alignment.Center) { Text("Hazırlanıyor…", color = C.dText, fontWeight = FontWeight.Bold) }
        }
    }
    if (sheet) Overlay { MediaSheet("audio", false, "Sesler", onClose = { sheet = false }) { l -> sheet = false; l.firstOrNull()?.let { add(it) } } }
}

