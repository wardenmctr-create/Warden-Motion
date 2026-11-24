package com.warden.motion.app.ui

import androidx.activity.compose.BackHandler
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Slider
import androidx.compose.material3.SliderDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.drawscope.drawIntoCanvas
import androidx.compose.ui.graphics.nativeCanvas
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.warden.motion.app.model.Project
import com.warden.motion.app.model.fmtTime
import kotlinx.coroutines.isActive
import kotlin.math.min

/** Editör (Glow 2'de tam hâli gelecek): şimdilik önizleme + oynatma */
@Composable
fun EditorScreen(project: Project, onClose: () -> Unit) {
    BackHandler(onBack = onClose)
    val r = LocalRenderer.current
    val ver by r.version.collectAsState()
    var t by remember { mutableDoubleStateOf(0.0) }
    var playing by remember { mutableStateOf(false) }
    val dur = project.duration
    LaunchedEffect(playing) {
        if (!playing) return@LaunchedEffect
        var last = withFrameNanos { it }
        while (isActive && playing) {
            val now = withFrameNanos { it }
            t += (now - last) / 1e9
            last = now
            if (t >= dur) t = 0.0
        }
    }
    Column(Modifier.fillMaxSize().background(C.dBg).systemBarsPadding()) {
        Row(Modifier.fillMaxWidth().height(52.dp), verticalAlignment = Alignment.CenterVertically) {
            IconButton(onClick = onClose) { Icon(Icons.Filled.ArrowBack, "Projeden çık", tint = C.dText) }
            Text(project.name, color = C.dText, fontSize = 18.sp, fontWeight = FontWeight.SemiBold)
        }
        Canvas(Modifier.fillMaxWidth().weight(1f).padding(8.dp)) {
            ver.hashCode()
            val k = min(size.width / project.width, size.height / project.height)
            val ox = (size.width - project.width * k) / 2; val oy = (size.height - project.height * k) / 2
            drawIntoCanvas { cv -> val nc = cv.nativeCanvas; nc.save(); nc.translate(ox, oy); r.draw(nc, project, t, k); nc.restore() }
        }
        Row(Modifier.fillMaxWidth().padding(horizontal = 12.dp), verticalAlignment = Alignment.CenterVertically) {
            IconButton(onClick = { playing = !playing }) { Icon(Icons.Filled.PlayArrow, if (playing) "Duraklat" else "Oynat", tint = C.dText) }
            Text(fmtTime(t, project.fps), color = C.dText, fontSize = 14.sp)
            Slider(value = t.toFloat(), onValueChange = { playing = false; t = it.toDouble() }, valueRange = 0f..dur.toFloat(), modifier = Modifier.weight(1f).padding(start = 10.dp),
                colors = SliderDefaults.colors(thumbColor = C.turq, activeTrackColor = C.turq))
        }
        Text("Glow: editörün tamamı (katman ekleme, zaman çizelgesi, keyframe) bir sonraki adımda geliyor.", color = C.dText2, fontSize = 12.sp, modifier = Modifier.padding(16.dp))
    }
}
