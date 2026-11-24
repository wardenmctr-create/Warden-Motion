package com.warden.motion.app.ui

import androidx.activity.compose.BackHandler
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.Slider
import androidx.compose.material3.SliderDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.warden.motion.app.data.Store
import com.warden.motion.app.model.Project
import com.warden.motion.app.model.newProject
import kotlinx.coroutines.launch
import kotlin.math.abs
import kotlin.math.roundToInt

private data class Ratio(val k: String, val w: Int, val h: Int, val bw: Int, val bh: Int)
private val RATIOS = listOf(Ratio("16:9", 16, 9, 56, 30), Ratio("9:16", 9, 16, 31, 54), Ratio("4:5", 4, 5, 31, 38), Ratio("1:1", 1, 1, 31, 31), Ratio("4:3", 4, 3, 41, 31))

/** Alttan açılan açık panel (eski uygulamadaki .sheet) */
@Composable
fun LightSheet(onClose: () -> Unit, content: @Composable ColumnScope.() -> Unit) {
    Box(Modifier.fillMaxSize()) {
        Scrim { onClose() }
        Column(
            Modifier.align(Alignment.BottomCenter).fillMaxWidth().heightIn(max = 720.dp).clip(RoundedCornerShape(topStart = 22.dp, topEnd = 22.dp)).background(C.bg)
                .tap { }.verticalScroll(rememberScrollState()).navigationBarsPadding().padding(start = 26.dp, end = 26.dp, top = 26.dp, bottom = 18.dp),
            content = content,
        )
    }
}

@Composable
fun NewProjectSheet(count: Int, onClose: () -> Unit, onCreate: (Project) -> Unit) {
    val store = Store.get(LocalContext.current)
    val scope = rememberCoroutineScope()
    var name by remember { mutableStateOf("Yeni Proje ${count + 1}") }
    var ratio by remember { mutableStateOf(RATIOS[2]) }
    var res by remember { mutableIntStateOf(720) }
    var fps by remember { mutableIntStateOf(30) }
    var bg by remember { mutableStateOf("#FFFFFF") }
    var picker by remember { mutableStateOf(false) }
    BackHandler(onBack = onClose)
    // Kısa kenar = seçilen çözünürlük
    val dims = if (ratio.w >= ratio.h) listOf((res * ratio.w / ratio.h / 2f).roundToInt() * 2, res) else listOf(res, (res * ratio.h / ratio.w / 2f).roundToInt() * 2)
    LightSheet(onClose) {
        Row(Modifier.fillMaxWidth().clip(RoundedCornerShape(8.dp)).background(C.card).padding(3.dp), horizontalArrangement = Arrangement.spacedBy(2.dp)) {
            Box(Modifier.weight(1f).height(40.dp).clip(RoundedCornerShape(6.dp)).background(C.text), contentAlignment = Alignment.Center) { Text("PROJE", color = C.cyan, fontWeight = FontWeight.SemiBold, fontSize = 14.sp) }
            Box(Modifier.weight(1f).height(40.dp), contentAlignment = Alignment.Center) { Text("ELEMENT", color = C.text, fontWeight = FontWeight.SemiBold, fontSize = 14.sp) }
        }
        Spacer(Modifier.height(28.dp))
        Row(Modifier.fillMaxWidth().height(42.dp), verticalAlignment = Alignment.CenterVertically) {
            BasicTextField(name, { name = it.take(40) }, Modifier.weight(1f), singleLine = true, textStyle = TextStyle(fontSize = 16.sp, color = C.text, fontFamily = Inter))
            Box(Modifier.size(32.dp).tap { name = "" }, contentAlignment = Alignment.Center) { Ico("close", C.text, 16.dp) }
        }
        Box(Modifier.fillMaxWidth().height(1.dp).background(C.text2))
        Spacer(Modifier.height(24.dp))
        Row(Modifier.fillMaxWidth().height(64.dp), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
            RATIOS.forEach { r ->
                val on = r == ratio
                Box(Modifier.size(r.bw.dp, r.bh.dp).clip(RoundedCornerShape(2.dp)).background(if (on) C.primary else C.card).tap { ratio = r }, contentAlignment = Alignment.Center) {
                    if (!on) Canvas(Modifier.matchParentSize()) {
                        // Köşe parantezleri
                        val l = 8.dp.toPx(); val t = 1.5.dp.toPx(); val w = size.width; val h = size.height
                        for ((x, y, dx, dy) in listOf(listOf(0f, 0f, 1f, 1f), listOf(w, 0f, -1f, 1f), listOf(0f, h, 1f, -1f), listOf(w, h, -1f, -1f))) {
                            drawLine(C.text, Offset(x, y + dy * t / 2), Offset(x + dx * l, y + dy * t / 2), t)
                            drawLine(C.text, Offset(x + dx * t / 2, y), Offset(x + dx * t / 2, y + dy * l), t)
                        }
                    }
                    Text(r.k, fontSize = 11.sp, color = if (on) C.onPrimary else C.text)
                }
            }
        }
        Spacer(Modifier.height(26.dp))
        FormRow({ Column { Text("Çözünürlük", fontSize = 16.sp, color = C.text); Text("Kompozisyon Boyutu", fontSize = 10.sp, color = C.text2); Text("${dims[0]} × ${dims[1]}", fontSize = 10.sp, color = C.text2) } }) {
            Select(listOf(480 to "480p", 720 to "720p (HD)", 1080 to "1080p (Full HD)"), res) { res = it }
        }
        FormRow({ Text("Kare Hızı", fontSize = 16.sp, color = C.text) }) { Select(listOf(24 to "24 fps", 30 to "30 fps", 60 to "60 fps"), fps) { fps = it } }
        FormRow({ Text("Arka Fon", fontSize = 16.sp, color = C.text) }) {
            Row(Modifier.fillMaxWidth().height(46.dp).clip(RoundedCornerShape(8.dp)).background(C.card).tap { picker = true }.padding(horizontal = 12.dp), verticalAlignment = Alignment.CenterVertically) {
                Box(Modifier.size(30.dp).clip(RoundedCornerShape(6.dp)).background(colorOf(bg)).border(1.dp, Color(0xFF8C9AB1), RoundedCornerShape(6.dp)))
                Spacer(Modifier.width(10.dp))
                Text(if (bg == "#FFFFFF") "Beyaz" else bg, fontSize = 15.sp, color = C.text)
            }
        }
        Row(Modifier.fillMaxWidth().padding(top = 22.dp), horizontalArrangement = Arrangement.End) {
            Text("PROJE OLUŞTUR", fontWeight = FontWeight.Bold, fontSize = 15.sp, color = C.text, letterSpacing = 0.2.sp, modifier = Modifier.tap {
                val p = newProject(name.ifBlank { "Adsız Proje" }, dims[0], dims[1], fps, bg)
                scope.launch { store.save(p); onCreate(p) }
            }.padding(start = 16.dp, top = 12.dp, bottom = 12.dp))
        }
        Box(Modifier.fillMaxWidth().padding(top = 18.dp), contentAlignment = Alignment.Center) { Box(Modifier.size(44.dp).target("sheet-close", onClose).tap(onClick = onClose), contentAlignment = Alignment.Center) { Ico("close", C.text, 24.dp, 2f) } }
    }
    if (picker) ColorPickerDialog(bg, onDismiss = { picker = false }) { bg = it; picker = false }
}

@Composable
private fun FormRow(label: @Composable () -> Unit, value: @Composable () -> Unit) {
    Row(Modifier.fillMaxWidth().padding(vertical = 7.dp), verticalAlignment = Alignment.CenterVertically) {
        Box(Modifier.width(120.dp)) { label() }
        Box(Modifier.weight(1f)) { value() }
    }
}

/** Açılır seçim kutusu (eski uygulamadaki select.sel) */
@Composable
fun <T> Select(opts: List<Pair<T, String>>, value: T, height: Int = 46, dark: Boolean = false, onPick: (T) -> Unit) {
    var open by remember { mutableStateOf(false) }
    Box {
        Row(Modifier.fillMaxWidth().height(height.dp).clip(RoundedCornerShape(8.dp)).background(if (dark) C.dPanel2 else C.card).tap { open = true }.padding(horizontal = 12.dp), verticalAlignment = Alignment.CenterVertically) {
            Text(opts.firstOrNull { it.first == value }?.second ?: "", fontSize = 15.sp, color = if (dark) C.dText else C.text, modifier = Modifier.weight(1f))
            Ico("chevD", if (dark) C.dText else C.text, 18.dp)
        }
        DropdownMenu(open, onDismissRequest = { open = false }, modifier = Modifier.background(if (dark) C.dPanel else C.card)) {
            opts.forEach { (v, l) -> DropdownMenuItem(text = { Text(l, color = if (dark) C.dText else C.text) }, onClick = { onPick(v); open = false }) }
        }
    }
}

/** Soldan açılan Ayarlar (eski uygulamadaki .drawer) */
@OptIn(ExperimentalFoundationApi::class)
@Composable
fun SettingsDrawer(store: Store, onClose: () -> Unit) {
    val lite by store.lite.collectAsState()
    val src by store.liteSource.collectAsState()
    val dur by store.defaultDuration.collectAsState()
    var liteOpen by remember { mutableStateOf(false) }
    val haptic = LocalHapticFeedback.current
    Column(
        Modifier.fillMaxHeight().widthIn(max = 320.dp).fillMaxWidth(0.82f).target("drawer", onClose).background(C.card).tap { }.statusBarsPadding()
            .verticalScroll(rememberScrollState()).padding(start = 10.dp, end = 10.dp, top = 18.dp, bottom = 14.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        Text("Ayarlar", fontSize = 22.sp, fontWeight = FontWeight.Bold, color = C.text, modifier = Modifier.padding(horizontal = 8.dp, vertical = 6.dp))
        Column(Modifier.fillMaxWidth().clip(RoundedCornerShape(10.dp)).background(C.soft).padding(start = 14.dp, end = 14.dp, top = 4.dp, bottom = 12.dp)) {
            Row(Modifier.fillMaxWidth().padding(top = 12.dp), verticalAlignment = Alignment.Top) {
                Column(Modifier.weight(1f)) {
                    Text("Warden Motion Lite", fontSize = 14.sp, fontWeight = FontWeight.Bold, color = C.text)
                    Text(buildString {
                        append("Zayıf telefonlarda kasmayı önler: önizleme daha hafif çizilir, ağır efektler sınırlanır. Dışa aktarılan video her zaman tam kalitededir.")
                    }, fontSize = 12.sp, color = C.text2, modifier = Modifier.padding(top = 4.dp))
                    Text("Basılı tut: Lite ayarları." + if (src == "auto") (if (lite) " Cihazın için otomatik açıldı." else " Cihazın güçlü görünüyor, otomatik kapalı.") else "",
                        fontSize = 12.sp, fontWeight = FontWeight.Bold, color = C.primary)
                }
                Spacer(Modifier.width(10.dp))
                // Lite: dokununca aç/kapat, basılı tutunca Lite ayarları
                WSwitch(lite, Modifier.padding(top = 4.dp).combinedClickable(interactionSource = remember { MutableInteractionSource() }, indication = null,
                    onClick = { store.setLite(!lite) }, onLongClick = { haptic.performHapticFeedback(HapticFeedbackType.LongPress); liteOpen = true }))
            }
            if (src == "user") {
                Box(Modifier.fillMaxWidth().padding(top = 12.dp).height(1.dp).background(C.line))
                Row(Modifier.fillMaxWidth().heightIn(min = 52.dp), verticalAlignment = Alignment.CenterVertically) {
                    Text("Lite'ı yine cihaza göre otomatik seç", fontSize = 13.sp, color = C.text, modifier = Modifier.weight(1f))
                    Text("Otomatik", fontSize = 13.sp, fontWeight = FontWeight.SemiBold, color = C.primary, modifier = Modifier.clip(RoundedCornerShape(16.dp)).background(C.card).tap { store.setLiteAuto() }.padding(horizontal = 12.dp, vertical = 8.dp))
                }
            }
            Box(Modifier.fillMaxWidth().height(1.dp).background(C.line))
            Row(Modifier.fillMaxWidth().heightIn(min = 52.dp), verticalAlignment = Alignment.CenterVertically) {
                Text("Varsayılan Katman Süresi", fontSize = 14.sp, fontWeight = FontWeight.Bold, color = C.text, modifier = Modifier.weight(1f))
                Box(Modifier.width(90.dp)) { Select(listOf(1.0, 2.0, 3.0, 5.0, 10.0).map { it to "${it.toInt()}s" }, dur, 40) { store.setDefaultDuration(it) } }
            }
        }
        Row(Modifier.fillMaxWidth().clip(RoundedCornerShape(8.dp)).background(C.soft).tap { onClose(); Assistant.replayIntro() }.padding(horizontal = 14.dp, vertical = 10.dp),
            verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            WardenCBImg("wave", 54.dp)
            Column(verticalArrangement = Arrangement.spacedBy(3.dp)) {
                Text("WardenCB ile tanış", fontSize = 14.sp, fontWeight = FontWeight.Bold, color = C.text)
                Text("Asistanı ve uygulama turunu yeniden başlat", fontSize = 12.sp, color = C.text2)
            }
        }
        InfoCard("Hakkında", "Warden Motion: Glow ${APP_VERSION} · Deneme sürümü. Projelerin ve yüklediğin pack'ler bu cihazda saklanır.")
        InfoCard("Açık Kaynak Kütüphaneleri", "Jetpack Compose, Kotlin, AndroidSVG, Inter yazı tipi (OFL), flag-icons (MIT)")
    }
    if (liteOpen) LiteSheet(store) { liteOpen = false }
}

@Composable
private fun InfoCard(title: String, body: String) {
    Column(Modifier.fillMaxWidth().clip(RoundedCornerShape(8.dp)).background(C.soft).padding(14.dp), verticalArrangement = Arrangement.spacedBy(6.dp)) {
        Text(title, fontSize = 14.sp, fontWeight = FontWeight.Bold, color = C.text)
        Text(body, fontSize = 13.sp, color = C.text2)
    }
}

// ---------- Lite ayarları: Lite neyi ne kadar kısıtlasın (çubuklarla) ----------
private data class LRow(val key: String, val label: String, val info: String, val stops: List<Double>, val text: (Double) -> String)
private val LITE_ROWS = listOf(
    LRow("res", "Önizleme çözünürlüğü", "Düşükse önizleme biraz bulanık ama çok daha akıcı olur.", listOf(0.25, 0.3, 0.4, 0.5, 0.6, 0.75, 0.9, 1.0)) { "%${(it * 100).roundToInt()}" },
    LRow("fps", "Önizleme kare hızı", "Oynatırken saniyede en fazla kaç kare çizilsin.", listOf(15.0, 24.0, 30.0, 60.0)) { "${it.toInt()} kare/sn" },
    LRow("img", "Görseller", "Düzenlerken görsellerin en uzun kenarı. Dışa aktarmada asıl boyutu kullanılır.", listOf(480.0, 720.0, 1280.0, 2048.0, 0.0)) { if (it > 0) "${it.toInt()} px" else "Asıl boyut" },
    LRow("vid", "Videolar", "Düzenlerken videoların çözünürlüğü. Dışa aktarmada asıl video kullanılır.", listOf(360.0, 480.0, 720.0, 1080.0, 0.0)) { if (it > 0) "${it.toInt()}p" else "Asıl boyut" },
    LRow("aud", "Sesler", "Düzenlerken seslerin kalitesi (düşükse bellek az dolar). Videoların içindeki ses de buna dahil. Dışa aktarmada asıl kalitesi kullanılır.", listOf(16000.0, 22050.0, 32000.0, 0.0)) { if (it > 0) "${(it / 100).roundToInt() / 10.0} kHz" else "Asıl kalite" },
)
private val FX_ROWS = listOf(
    LRow("blur", "Bulanıklık", "Gauss bulanıklığı ve hareket bulanıklığı.", listOf(0.0, 1.0, 2.0, 3.0)) { listOf("Kapalı", "Düşük", "Orta", "Tam")[it.toInt()] },
    LRow("warp", "Bükme", "Fraktal bükme.", listOf(0.0, 1.0, 2.0)) { listOf("Kapalı", "Düşük", "Tam")[it.toInt()] },
    LRow("light", "Işık ve Gölge", "Parlama ve gölge.", listOf(0.0, 1.0)) { if (it > 0) "Açık" else "Kapalı" },
    LRow("color", "Renk ve Işık", "Parlaklık, kontrast, doygunluk, ton, siyah beyaz…", listOf(0.0, 1.0)) { if (it > 0) "Açık" else "Kapalı" },
)
val LITE_DEFAULT = mapOf("res" to 0.4, "fps" to 30.0, "blur" to 1.0, "warp" to 1.0, "light" to 1.0, "color" to 1.0, "img" to 1280.0, "vid" to 480.0, "aud" to 22050.0)
val FULL_QUALITY = mapOf("res" to 1.0, "fps" to 60.0, "blur" to 3.0, "warp" to 2.0, "light" to 1.0, "color" to 1.0, "img" to 2048.0, "vid" to 0.0, "aud" to 0.0)

@Composable
fun LiteSheet(store: Store, onClose: () -> Unit) {
    val lite by store.lite.collectAsState()
    val user by store.liteCfg.collectAsState()
    var page by remember { mutableStateOf("main") }
    val cfg = LITE_DEFAULT + user
    BackHandler { if (page == "fx") page = "main" else onClose() }
    fun near(stops: List<Double>, v: Double) = stops.indices.minBy { abs(stops[it] - v) }
    @Composable fun row(r: LRow) {
        val i = near(r.stops, cfg[r.key] ?: 0.0)
        Column(Modifier.fillMaxWidth().padding(vertical = 8.dp)) {
            Row { Text(r.label, fontSize = 14.sp, fontWeight = FontWeight.SemiBold, color = C.text, modifier = Modifier.weight(1f)); Text(r.text(r.stops[i]), fontSize = 14.sp, fontWeight = FontWeight.Bold, color = C.primary) }
            Slider(i.toFloat(), { store.setLiteCfg(user + (r.key to r.stops[it.roundToInt()])) }, valueRange = 0f..(r.stops.size - 1).toFloat(), steps = (r.stops.size - 2).coerceAtLeast(0),
                colors = SliderDefaults.colors(thumbColor = C.primary, activeTrackColor = C.primary, inactiveTrackColor = C.line, activeTickColor = Color.Transparent, inactiveTickColor = Color.Transparent))
            Text(r.info, fontSize = 12.sp, color = C.text2)
        }
    }
    Overlay {
        LightSheet(onClose) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                if (page == "fx") Box(Modifier.size(44.dp).tap { page = "main" }, contentAlignment = Alignment.Center) { Ico("back", C.text, 22.dp) }
                Text(if (page == "fx") "Efektler" else "Lite ayarları", fontSize = 19.sp, fontWeight = FontWeight.Bold, color = C.text, modifier = Modifier.weight(1f))
                Box(Modifier.size(44.dp).tap(onClick = onClose), contentAlignment = Alignment.Center) { Ico("close", C.text, 22.dp) }
            }
            if (page == "main") {
                Text((if (lite) "Lite açık: aşağıdaki kısıtlamalar uygulanıyor." else "Lite şu an kapalı. Bu ayarlar Lite açılınca uygulanır.") + " Dışa aktarılan video her zaman tam kalitede olur.", fontSize = 13.sp, color = C.text2, modifier = Modifier.padding(vertical = 8.dp))
                LITE_ROWS.take(2).forEach { row(it) }
                val sum = FX_ROWS.joinToString(" · ") { "${it.label} ${it.text(it.stops[near(it.stops, cfg[it.key] ?: 0.0)]).lowercase(java.util.Locale("tr"))}" }
                Row(Modifier.fillMaxWidth().padding(vertical = 8.dp).clip(RoundedCornerShape(12.dp)).background(C.card).tap { page = "fx" }.padding(14.dp), verticalAlignment = Alignment.CenterVertically) {
                    Column(Modifier.weight(1f)) { Text("Efektler", fontSize = 15.sp, fontWeight = FontWeight.Bold, color = C.text); Text(sum, fontSize = 12.sp, color = C.text2) }
                    Ico("chevR", C.text, 22.dp)
                }
                Text("Dosya sıkıştırma (düzenlerken)", fontSize = 13.sp, fontWeight = FontWeight.Bold, color = C.text2, modifier = Modifier.padding(top = 10.dp))
                LITE_ROWS.drop(2).forEach { row(it) }
            } else {
                Text("Lite açıkken önizlemede hangi efekt grubunun ne kadar gösterileceğini seç. Dışa aktarılan videoda hepsi tam kalitededir.", fontSize = 13.sp, color = C.text2, modifier = Modifier.padding(vertical = 8.dp))
                FX_ROWS.forEach { row(it) }
            }
            Row(Modifier.fillMaxWidth().padding(top = 14.dp), horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                Box(Modifier.weight(1f).height(46.dp).clip(RoundedCornerShape(12.dp)).border(1.dp, C.line, RoundedCornerShape(12.dp)).tap {
                    store.setLiteCfg(if (page == "fx") user - FX_ROWS.map { it.key }.toSet() else emptyMap())
                }, contentAlignment = Alignment.Center) { Text("Varsayılana dön", fontWeight = FontWeight.SemiBold, color = C.text) }
                Box(Modifier.weight(1f).height(46.dp).clip(RoundedCornerShape(12.dp)).background(C.primary).tap { if (page == "fx") page = "main" else onClose() }, contentAlignment = Alignment.Center) {
                    Text("Tamam", fontWeight = FontWeight.Bold, color = C.onPrimary)
                }
            }
        }
    }
}

