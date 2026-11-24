package com.warden.motion.app.ui

import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.PickVisualMediaRequest
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.focus.onFocusChanged
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.warden.motion.app.data.Store
import kotlinx.coroutines.launch
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

@Composable
fun AccountScreen(store: Store) {
    val scope = rememberCoroutineScope()
    val profile by store.profile.collectAsState()
    val projects by store.projects.collectAsState()
    var name by remember(profile.name) { mutableStateOf(profile.name) }
    var busy by remember { mutableStateOf("") }
    var msg by remember { mutableStateOf("") }
    val focus = LocalFocusManager.current
    val photo = rememberLauncherForActivityResult(ActivityResultContracts.PickVisualMedia()) { uri -> if (uri != null) scope.launch { store.setPhoto(uri) } }
    val backup = rememberLauncherForActivityResult(ActivityResultContracts.CreateDocument("application/json")) { uri ->
        if (uri == null) return@rememberLauncherForActivityResult
        busy = "Yedek hazırlanıyor…"; msg = ""
        scope.launch {
            msg = runCatching { "${store.exportBackup(uri)} proje yedeklendi. Dosyayı Drive'a ya da istediğin yere kaydettin." }.getOrElse { "Yedek alınamadı. Tekrar dene." }
            busy = ""
        }
    }
    var restoreUri by remember { mutableStateOf<android.net.Uri?>(null) }
    val restore = rememberLauncherForActivityResult(ActivityResultContracts.OpenDocument()) { uri -> restoreUri = uri }

    Column(Modifier.fillMaxWidth().padding(top = 6.dp), verticalArrangement = Arrangement.spacedBy(14.dp)) {
        Column(Modifier.fillMaxWidth().padding(top = 14.dp, bottom = 4.dp), horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(8.dp)) {
            Box(Modifier.padding(6.dp).tap { photo.launch(PickVisualMediaRequest(ActivityResultContracts.PickVisualMedia.ImageOnly)) }) {
                AccountAvatar(104.dp, profile)
                Box(Modifier.align(Alignment.BottomEnd).offset(x = (-2).dp, y = 0.dp).size(32.dp).clip(CircleShape).background(C.bg).padding(3.dp).clip(CircleShape).background(C.primary), contentAlignment = Alignment.Center) {
                    Ico("image", C.onPrimary, 16.dp)
                }
            }
            BasicTextField(name, { name = it.take(30) }, singleLine = true,
                textStyle = TextStyle(fontSize = 22.sp, fontWeight = FontWeight.ExtraBold, color = C.text, textAlign = TextAlign.Center, fontFamily = Inter),
                keyboardOptions = KeyboardOptions(imeAction = ImeAction.Done), keyboardActions = KeyboardActions(onDone = { focus.clearFocus() }),
                modifier = Modifier.fillMaxWidth(0.8f).onFocusChanged { if (!it.isFocused && name.trim() != profile.name) store.setProfile(profile.copy(name = name.trim())) },
                decorationBox = { inner -> Box(contentAlignment = Alignment.Center) { if (name.isEmpty()) Text("Adını yaz", fontSize = 22.sp, fontWeight = FontWeight.ExtraBold, color = C.text.copy(alpha = .45f)); inner() } })
            Text("${projects.size} proje · 0 pack öğesi · 0 bayrak", fontSize = 13.sp, color = C.text2)
        }
        AccCard {
            AccRow("export", "Google Drive'a yedekle", "Bütün projelerin, yüklediğin pack ve bayraklar tek dosyada. Açılan pencerede Drive'ı ya da istediğin yeri seç.")
            Btn(busy.ifEmpty { "Şimdi yedekle" }, Color(0xFF3B8BF0), Color.White, enabled = busy.isEmpty()) {
                val d = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())
                backup.launch("WardenMotion-yedek-$d.json")
            }
            Text("Son yedek: " + if (profile.lastBackup > 0) SimpleDateFormat("d MMMM HH:mm", Locale("tr")).format(Date(profile.lastBackup)) else "hiç yedeklenmedi", fontSize = 12.sp, color = C.text2)
        }
        AccCard {
            AccRow("undo", "Yedekten geri yükle", "Yeni telefona geçince ya da uygulamayı silip yükleyince yedeğini Drive'dan seç. Eski Warden Motion'ın yedekleri de açılır.")
            Btn("Yedek dosyası seç", C.text, C.onPrimary, enabled = busy.isEmpty()) { restore.launch(arrayOf("*/*")) }
        }
        if (msg.isNotEmpty()) Text(msg, fontSize = 13.5.sp, fontWeight = FontWeight.SemiBold, color = Color(0xFF0B4F4A), modifier = Modifier.fillMaxWidth().clip(RoundedCornerShape(14.dp)).background(Color(0xFFDDF6F3)).padding(horizontal = 12.dp, vertical = 10.dp))
        Column(Modifier.fillMaxWidth().clip(RoundedCornerShape(18.dp)).background(C.soft).border(1.dp, C.line, RoundedCornerShape(18.dp)).padding(14.dp)) {
            Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                Box(Modifier.size(26.dp).border(2.dp, C.primary, CircleShape), contentAlignment = Alignment.Center) { Text("G", fontWeight = FontWeight.ExtraBold, fontSize = 14.sp, color = C.primary) }
                Column(verticalArrangement = Arrangement.spacedBy(3.dp)) {
                    Text("Google ile giriş", fontSize = 16.sp, fontWeight = FontWeight.Bold, color = C.text)
                    Text("Yakında: giriş yapınca Gmail fotoğrafın otomatik gelecek, projelerin Google hesabında kendiliğinden saklanacak. Şimdilik yukarıdan elle yedekleyebilirsin.", fontSize = 13.sp, color = C.text2, lineHeight = 18.sp)
                }
            }
        }
        if (profile.photo != null) Text("Profil fotoğrafını kaldır", fontSize = 13.sp, color = C.text2, textDecoration = TextDecoration.Underline,
            modifier = Modifier.align(Alignment.CenterHorizontally).tap { scope.launch { store.setPhoto(null) } })
    }
    restoreUri?.let { uri ->
        ConfirmDialog("Yedekten geri yüklensin mi?", "Yedekteki projeler bu cihaza eklenir. Diğer projelerin silinmez.", "Geri yükle", danger = false,
            onYes = {
                restoreUri = null; busy = "Geri yükleniyor…"; msg = ""
                scope.launch { msg = runCatching { store.importBackup(uri).let { "${it.projects} proje geri yüklendi." } }.getOrElse { it.message?.takeIf { m -> "Warden" in m } ?: "Bu dosya okunamadı." }; busy = "" }
            }, onNo = { restoreUri = null })
    }
}

@Composable
private fun AccCard(content: @Composable ColumnScope.() -> Unit) {
    Column(Modifier.fillMaxWidth().clip(RoundedCornerShape(18.dp)).background(C.card).border(1.dp, C.line, RoundedCornerShape(18.dp)).padding(14.dp), verticalArrangement = Arrangement.spacedBy(10.dp), content = content)
}

@Composable
private fun AccRow(icon: String, title: String, body: String) {
    Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
        Ico(icon, C.primary, 22.dp)
        Column(verticalArrangement = Arrangement.spacedBy(3.dp)) {
            Text(title, fontSize = 16.sp, fontWeight = FontWeight.Bold, color = C.text)
            Text(body, fontSize = 13.sp, color = C.text2, lineHeight = 18.sp)
        }
    }
}

@Composable
fun Btn(label: String, bg: Color, fg: Color, enabled: Boolean = true, modifier: Modifier = Modifier.fillMaxWidth(), onClick: () -> Unit) {
    Box(modifier.height(42.dp).clip(RoundedCornerShape(10.dp)).background(if (enabled) bg else bg.copy(alpha = .5f)).tap(enabled, onClick), contentAlignment = Alignment.Center) {
        Text(label, fontSize = 15.sp, fontWeight = FontWeight.Bold, color = fg)
    }
}
