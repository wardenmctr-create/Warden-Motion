package com.warden.motion.app.ui

import android.net.Uri
import android.os.StatFs
import androidx.activity.compose.BackHandler
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Slider
import androidx.compose.material3.SliderDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.warden.motion.app.data.Share
import com.warden.motion.app.data.Store
import com.warden.motion.app.export.Exporter
import com.warden.motion.app.export.Progress
import com.warden.motion.app.model.fmtTime
import com.warden.motion.app.model.heavyEffects
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File
import kotlin.math.roundToInt

private fun fmtSize(b: Double): String = when { b >= 1e9 -> "%.1fGB".format(b / 1e9); b >= 1e6 -> "%.1fMB".format(b / 1e6); else -> "%.0fKB".format(b / 1e3) }
private fun fmtEta(sn: Double) = if (sn < 60) "${maxOf(1, sn.roundToInt())} sn" else "${(sn / 60).toInt()} dk ${(sn % 60).roundToInt()} sn"
private val QLABELS = listOf("Düşük", "Orta", "Yüksek", "Çok yüksek", "En yüksek")

/** AM'deki gibi "Dışa Aktar ve Paylaş" ekranı */
@Composable
fun ExportDialog(s: EditorState, onClose: () -> Unit, toast: (String) -> Unit) {
    val ctx = LocalContext.current
    val store = remember { Store.get(ctx) }
    val scope = rememberCoroutineScope()
    val prefs = remember { ctx.getSharedPreferences("wm", android.content.Context.MODE_PRIVATE) }
    val p = s.project
    val dur = p.duration
    var kind by remember { mutableStateOf("video") }
    var res by remember { mutableIntStateOf(prefs.getInt("exRes", 720)) }
    var fps by remember { mutableIntStateOf(prefs.getInt("exFps", p.fps)) }
    var q by remember { mutableFloatStateOf(prefs.getFloat("fxq", 0.5f)) }
    var resOpen by remember { mutableStateOf(false) }
    var prog by remember { mutableStateOf<Progress?>(null) }
    var exporter by remember { mutableStateOf<Exporter?>(null) }
    var done by remember { mutableStateOf<Pair<File, String>?>(null) }
    val heavy = heavyEffects(p)
    val ex = remember { Exporter(ctx) }
    val (W, H) = ex.size(p, res)
    val free = remember { runCatching { StatFs(ctx.filesDir.absolutePath).availableBytes.toDouble() }.getOrDefault(0.0) }
    val est = when (kind) {
        "video" -> (maxOf(2_000_000.0, W * H * fps * 0.15) + 160_000) / 8 * dur
        "png" -> W * H * 1.2
        "seq" -> W * H * 1.2 * dur * fps
        "gif" -> { val (gw, gh) = ex.size(p, minOf(res, 360)); gw * gh * 0.4 * dur * minOf(fps, 15) }
        else -> 200_000.0
    }
    BackHandler { if (prog != null) { exporter?.cancelled = true } else onClose() }

    // Kaydetme yerleri (ZIP ve proje dosyası)
    var pending by remember { mutableStateOf<String?>(null) }
    val createDoc = rememberLauncherForActivityResult(ActivityResultContracts.CreateDocument("application/octet-stream")) { uri: Uri? ->
        val what = pending; pending = null
        if (uri == null || what == null) return@rememberLauncherForActivityResult
        scope.launch {
            if (what == "proj") { store.exportBackup(uri, setOf(p.id)); toast("Proje paketi kaydedildi."); onClose(); return@launch }
            val e = Exporter(ctx); exporter = e; prog = Progress(0.0, null)
            runCatching { withContext(Dispatchers.Default) { ctx.contentResolver.openOutputStream(uri)!!.use { o -> e.sequence(s.project, o, res, fps) { prog = it } } } }
                .onFailure { toast("Dışa aktarılamadı: ${it.message}") }
            prog = null; exporter = null
            if (!e.cancelled) { toast("Görüntü dizisi kaydedildi."); onClose() }
        }
    }
    val safe = p.name.replace(Regex("[^\\p{L}\\p{N} _-]"), "").ifBlank { "warden" }

    val start = {
        prefs.edit().putInt("exRes", res).putInt("exFps", fps).putFloat("fxq", q).apply()
        s.playing = false; s.selectedId = null
        when (kind) {
            "proj" -> { pending = "proj"; createDoc.launch("$safe.wmproje") }
            "seq" -> { pending = "seq"; createDoc.launch("$safe-kareler.zip") }
            else -> scope.launch {
                val e = Exporter(ctx); exporter = e; prog = Progress(0.0, null)
                val dir = Share.shareDir(ctx)
                val r = runCatching {
                    withContext(Dispatchers.Default) {
                        when (kind) {
                            "video" -> File(dir, "$safe.mp4").also { f -> e.video(s.project, f, res, fps, q.toDouble()) { prog = it } } to "video/mp4"
                            "png" -> File(dir, "$safe.png").also { f -> f.outputStream().use { o -> e.png(s.project, s.time, res).compress(android.graphics.Bitmap.CompressFormat.PNG, 100, o) } } to "image/png"
                            else -> File(dir, "$safe.gif").also { f -> f.outputStream().use { o -> e.gif(s.project, o, minOf(res, 360), minOf(fps, 15)) { prog = it } } } to "image/gif"
                        }
                    }
                }
                prog = null; exporter = null
                r.onSuccess { (f, mime) ->
                    if (e.cancelled) return@onSuccess
                    val u = withContext(Dispatchers.IO) { Exporter.saveToGallery(ctx, f, f.name, mime) }
                    toast(if (u != null) "Galeriye kaydedildi (Warden Motion klasörü)." else "Kaydedildi.")
                    done = f to mime
                }.onFailure { toast("Dışa aktarma başarısız: ${it.message}") }
            }
        }
    }

    Overlay {
        Column(Modifier.fillMaxSize().background(C.card).systemBarsPadding()) {
            Row(Modifier.fillMaxWidth().height(60.dp).padding(horizontal = 8.dp), verticalAlignment = Alignment.CenterVertically) {
                Box(Modifier.size(48.dp).tap(onClick = onClose), contentAlignment = Alignment.Center) { Ico("close", C.text, 26.dp, 2f) }
                Text("Dışa Aktar ve Paylaş", fontSize = 19.sp, fontWeight = FontWeight.Bold, color = C.text, textAlign = TextAlign.Center, modifier = Modifier.weight(1f))
                Spacer(Modifier.width(48.dp))
            }
            Box(Modifier.fillMaxWidth().height(1.dp).background(C.line))
            Column(Modifier.fillMaxWidth().background(C.card).padding(horizontal = 16.dp, vertical = 12.dp), verticalArrangement = Arrangement.spacedBy(18.dp)) {
                Row { Text("Kullanılabilir Alan", fontSize = 16.sp, color = C.text, modifier = Modifier.weight(1f)); Text(fmtSize(free), fontSize = 16.sp, color = C.text) }
                Row { Text("Dosya boyutu (tahmini)", fontSize = 16.sp, color = C.text, modifier = Modifier.weight(1f)); Text(fmtSize(est), fontSize = 16.sp, color = C.text) }
            }
            Column(Modifier.fillMaxWidth().weight(1f).background(Color(0xFFE6EAF0)).verticalScroll(rememberScrollState()).padding(14.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
                ExOpt(kind == "video", "film", "Video", "MP4 ${if (res >= 1080) "1080p (Full HD)" else if (res >= 720) "720p (HD)" else "480p"} ${fps}fps", chevron = true, onClick = { kind = "video" }) {
                    if (kind == "video") Column {
                        Box(Modifier.fillMaxWidth().height(1.dp).background(C.line))
                        Row(Modifier.fillMaxWidth().tap { resOpen = !resOpen }.padding(horizontal = 16.dp, vertical = 14.dp), verticalAlignment = Alignment.CenterVertically) {
                            Text(if (res >= 1080) "1080p (Full HD)" else if (res >= 720) "720p (HD)" else "480p", fontSize = 15.sp, color = C.text, modifier = Modifier.weight(1f))
                            Ico("chevD", C.text, 20.dp)
                        }
                        if (resOpen) Column {
                            listOf(480 to "480p", 720 to "720p (HD)", 1080 to "1080p (Full HD)").forEach { (v, l) ->
                                Text(l, fontSize = 15.sp, color = if (res == v) C.primary else C.text, fontWeight = if (res == v) FontWeight.Bold else FontWeight.Normal, modifier = Modifier.fillMaxWidth().tap { res = v; resOpen = false }.padding(horizontal = 24.dp, vertical = 10.dp))
                            }
                        }
                        Row(Modifier.fillMaxWidth().padding(horizontal = 16.dp, vertical = 6.dp), horizontalArrangement = Arrangement.spacedBy(8.dp), verticalAlignment = Alignment.CenterVertically) {
                            Text("Kare hızı", fontSize = 14.sp, color = C.text2, modifier = Modifier.weight(1f))
                            listOf(24, 30, 60).forEach { f -> Text("$f", fontSize = 14.sp, fontWeight = FontWeight.SemiBold, color = if (fps == f) C.onPrimary else C.text, modifier = Modifier.clip(RoundedCornerShape(14.dp)).background(if (fps == f) C.primary else C.soft).tap { fps = f }.padding(horizontal = 14.dp, vertical = 6.dp)) }
                        }
                        if (heavy.isNotEmpty()) Column(Modifier.padding(horizontal = 16.dp, vertical = 6.dp)) {
                            Row { Text("Efekt kalitesi", fontSize = 14.sp, color = C.text, modifier = Modifier.weight(1f)); Text(QLABELS[(q * 4).roundToInt()], fontSize = 14.sp, fontWeight = FontWeight.Bold, color = C.primary) }
                            Slider(q, { q = it }, colors = SliderDefaults.colors(thumbColor = C.primary, activeTrackColor = C.primary, inactiveTrackColor = C.line))
                            Row { Text("Hızlı", fontSize = 11.sp, color = C.text2, modifier = Modifier.weight(1f)); Text("En güzel", fontSize = 11.sp, color = C.text2) }
                            Text("Bu projede ${heavy.joinToString(" ve ")} var. Kaliteyi yükselttikçe efektler daha pürüzsüz olur ama aktarma daha uzun sürer.", fontSize = 12.sp, color = C.text2, modifier = Modifier.padding(top = 4.dp, bottom = 8.dp))
                        }
                    }
                }
                ExOpt(kind == "proj", "layers", "Proje Paketi", "Orijinal Medya ile", onClick = { kind = "proj" })
                ExOpt(kind == "png", "image", "PNG Olarak Geçerli Çerçeve", "${W}×${H} · ${fmtTime(s.time, p.fps)}", onClick = { kind = "png" })
                ExOpt(kind == "seq", "copy", "Görüntü Dizisi", "PNG ${minOf(W, H)}p ${fps}fps · ZIP", chevron = true, onClick = { kind = "seq" })
                val (gw, gh) = ex.size(p, minOf(res, 360))
                ExOpt(kind == "gif", "gif", "GIF", "${gw}x${gh} ${minOf(fps, 15)}fps", chevron = true, onClick = { kind = "gif" })
            }
            Box(Modifier.fillMaxWidth().background(C.card).padding(16.dp)) {
                Box(Modifier.fillMaxWidth().height(56.dp).shadow(4.dp, RoundedCornerShape(8.dp)).clip(RoundedCornerShape(8.dp)).background(Color(0xFF1B2550)).tap { start() }, contentAlignment = Alignment.Center) {
                    Text("Dışa Aktar", fontSize = 22.sp, fontWeight = FontWeight.Medium, color = C.turq)
                }
            }
        }
        prog?.let { pr ->
            Box(Modifier.fillMaxSize().background(Color(0xBF03081A)).tap { }, contentAlignment = Alignment.Center) {
                Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(14.dp)) {
                    Text("Hazırlanıyor… %${(pr.f * 100).roundToInt()}", color = C.dText, fontSize = 17.sp, fontWeight = FontWeight.Bold)
                    Box(Modifier.width(240.dp).height(8.dp).clip(RoundedCornerShape(4.dp)).background(C.dPanel)) { Box(Modifier.fillMaxHeight().fillMaxWidth(pr.f.toFloat().coerceIn(0f, 1f)).background(C.turq)) }
                    Text(pr.eta?.let { "Kalan süre: yaklaşık ${fmtEta(it)}" } ?: "Süre hesaplanıyor…", color = C.dText2, fontSize = 13.sp)
                    if (heavy.isNotEmpty()) Text("${heavy.joinToString(" ve ")} yüksek kalitede hesaplandığı için aktarma normalden uzun sürebilir. Uygulamayı kapatmadan bekle.", color = C.dText2, fontSize = 12.sp, textAlign = TextAlign.Center, modifier = Modifier.widthIn(max = 280.dp))
                    DBtn("Vazgeç", ghost = true, modifier = Modifier.width(140.dp)) { exporter?.cancelled = true }
                }
            }
        }
        done?.let { (f, mime) ->
            Box(Modifier.fillMaxSize().background(Color(0x9903081A)).tap { done = null; onClose() }, contentAlignment = Alignment.Center) {
                Column(Modifier.width(300.dp).clip(RoundedCornerShape(18.dp)).background(C.card).tap { }.padding(20.dp), verticalArrangement = Arrangement.spacedBy(12.dp), horizontalAlignment = Alignment.CenterHorizontally) {
                    Box(Modifier.size(56.dp).clip(CircleShape).background(Color(0xFFDDF6F3)), contentAlignment = Alignment.Center) { Ico("check", Color(0xFF0E7C74), 30.dp, 2.4f) }
                    Text("Hazır!", fontSize = 19.sp, fontWeight = FontWeight.Bold, color = C.text)
                    Text("Galeride \"Warden Motion\" klasörüne kaydedildi.", fontSize = 14.sp, color = C.text2, textAlign = TextAlign.Center)
                    Btn("Paylaş", C.primary, C.onPrimary) { Share.send(ctx, f, mime, title = "Paylaş") }
                    Text("Tamam", fontSize = 15.sp, fontWeight = FontWeight.SemiBold, color = C.text2, modifier = Modifier.tap { done = null; onClose() }.padding(8.dp))
                }
            }
        }
    }
}

@Composable
private fun ExOpt(on: Boolean, icon: String, title: String, sub: String, chevron: Boolean = false, onClick: () -> Unit, extra: @Composable () -> Unit = {}) {
    Column(Modifier.fillMaxWidth().clip(RoundedCornerShape(8.dp)).background(C.card)) {
        Row(Modifier.fillMaxWidth().tap(onClick = onClick).padding(horizontal = 16.dp, vertical = 18.dp), verticalAlignment = Alignment.CenterVertically) {
            Box(Modifier.size(28.dp).border(2.5.dp, C.text, CircleShape).padding(5.dp).clip(CircleShape).background(if (on) C.turq else Color.Transparent))
            Spacer(Modifier.width(20.dp))
            if (icon == "gif") Box(Modifier.size(24.dp).border(1.5.dp, C.text, CircleShape), contentAlignment = Alignment.Center) { Text("GIF", fontSize = 7.sp, fontWeight = FontWeight.Bold, color = C.text) }
            else Ico(icon, C.text, 24.dp)
            Spacer(Modifier.width(18.dp))
            Column(Modifier.weight(1f)) {
                Text(title, fontSize = 18.sp, fontWeight = FontWeight.Bold, color = C.text)
                Text(sub, fontSize = 13.sp, color = C.text2.copy(alpha = .6f))
            }
            if (chevron) Ico("chevR", C.text2, 20.dp)
        }
        extra()
    }
}
