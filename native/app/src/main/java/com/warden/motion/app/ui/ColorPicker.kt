package com.warden.motion.app.ui

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.gestures.detectDragGestures
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog

fun hexOf(c: Color): String {
    val a = android.graphics.Color.argb((c.alpha * 255).toInt(), (c.red * 255).toInt(), (c.green * 255).toInt(), (c.blue * 255).toInt())
    return "#%06X".format(a and 0xFFFFFF)
}
fun colorOf(hex: String?): Color = runCatching { Color(android.graphics.Color.parseColor(hex)) }.getOrDefault(Color(0xFF8F7CF0))

val PALETTE = listOf("#FFFFFF", "#0D1631", "#000000", "#E2342D", "#F2994A", "#F2C94C", "#27AE60", "#22D3C5", "#3FD0F0", "#2F7BF6", "#8F7CF0", "#FF5BA7", "#9AA6B8", "#8B5A2B", "#EAF4FF", "#0B1430")

/** Renk seçici: doygunluk/parlaklık karesi + ton çubuğu + hazır renkler + hex */
@Composable
fun ColorPickerDialog(initial: String, dark: Boolean = false, onDismiss: () -> Unit, onPick: (String) -> Unit) {
    val hsv = remember { FloatArray(3).also { android.graphics.Color.colorToHSV(android.graphics.Color.parseColor(runCatching { android.graphics.Color.parseColor(initial); initial }.getOrDefault("#8F7CF0")), it) } }
    var h by remember { mutableFloatStateOf(hsv[0]) }
    var s by remember { mutableFloatStateOf(hsv[1]) }
    var v by remember { mutableFloatStateOf(hsv[2]) }
    val cur = Color(android.graphics.Color.HSVToColor(floatArrayOf(h, s, v)))
    var hex by remember(cur) { mutableStateOf(hexOf(cur)) }
    val bg = if (dark) C.dPanel else C.card
    val fg = if (dark) C.dText else C.text
    val setHex = { x: String -> runCatching { val f = FloatArray(3); android.graphics.Color.colorToHSV(android.graphics.Color.parseColor(x), f); h = f[0]; s = f[1]; v = f[2] } }
    Dialog(onDismissRequest = onDismiss) {
        Column(Modifier.clip(RoundedCornerShape(20.dp)).background(bg).padding(18.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
            Text("Renk seç", color = fg, fontSize = 18.sp, fontWeight = FontWeight.Bold)
            Canvas(Modifier.fillMaxWidth().height(180.dp).clip(RoundedCornerShape(10.dp))
                .pointerInput(Unit) {
                    fun set(o: Offset) { s = (o.x / size.width).coerceIn(0f, 1f); v = 1f - (o.y / size.height).coerceIn(0f, 1f) }
                    detectTapGestures { set(it) }
                }
                .pointerInput(Unit) {
                    detectDragGestures { ch, _ -> s = (ch.position.x / size.width).coerceIn(0f, 1f); v = 1f - (ch.position.y / size.height).coerceIn(0f, 1f) }
                }) {
                drawRect(Brush.horizontalGradient(listOf(Color.White, Color(android.graphics.Color.HSVToColor(floatArrayOf(h, 1f, 1f))))))
                drawRect(Brush.verticalGradient(listOf(Color.Transparent, Color.Black)))
                drawCircle(Color.White, 9.dp.toPx(), Offset(s * size.width, (1 - v) * size.height), style = Stroke(3.dp.toPx()))
            }
            Canvas(Modifier.fillMaxWidth().height(24.dp).clip(RoundedCornerShape(12.dp))
                .pointerInput(Unit) { detectTapGestures { h = (it.x / size.width).coerceIn(0f, 1f) * 360f } }
                .pointerInput(Unit) { detectDragGestures { ch, _ -> h = (ch.position.x / size.width).coerceIn(0f, 1f) * 360f } }) {
                drawRect(Brush.horizontalGradient((0..6).map { Color(android.graphics.Color.HSVToColor(floatArrayOf(it * 60f, 1f, 1f))) }))
                drawCircle(Color.White, 10.dp.toPx(), Offset(h / 360f * size.width, size.height / 2), style = Stroke(3.dp.toPx()))
            }
            // Hazır renkler
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                PALETTE.chunked(8).forEach { row ->
                    Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                        row.forEach { c -> Box(Modifier.size(28.dp).clip(CircleShape).background(colorOf(c)).border(1.dp, if (dark) C.dLine else C.line, CircleShape).tap { setHex(c) }) }
                    }
                }
            }
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                Box(Modifier.size(36.dp).clip(RoundedCornerShape(8.dp)).background(cur).border(1.dp, if (dark) C.dLine else C.line, RoundedCornerShape(8.dp)))
                BasicTextField(hex, { hex = it.take(7); if (Regex("^#[0-9a-fA-F]{6}$").matches(hex)) setHex(hex) }, singleLine = true,
                    textStyle = TextStyle(color = fg, fontSize = 16.sp, fontFamily = Inter),
                    modifier = Modifier.weight(1f).clip(RoundedCornerShape(8.dp)).background(if (dark) C.dPanel2 else C.bg).padding(horizontal = 12.dp, vertical = 10.dp))
            }
            Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.End) {
                Text("Vazgeç", color = if (dark) C.dText2 else C.text2, fontWeight = FontWeight.SemiBold, modifier = Modifier.tap(onClick = onDismiss).padding(12.dp))
                Text("Tamam", color = if (dark) C.turq else C.primary, fontWeight = FontWeight.Bold, modifier = Modifier.tap { onPick(hexOf(cur)) }.padding(12.dp))
            }
        }
    }
}
