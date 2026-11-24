package com.warden.motion.app.ui

import android.graphics.BitmapFactory
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.composed
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.material3.Text
import com.warden.motion.app.R
import com.warden.motion.app.data.Store
import kotlinx.coroutines.delay

/** Tıklama dalgası olmadan tıklama (web'deki düğmeler gibi) */
fun Modifier.tap(enabled: Boolean = true, onClick: () -> Unit): Modifier = composed {
    clickable(interactionSource = remember { MutableInteractionSource() }, indication = null, enabled = enabled, onClick = onClick)
}

/** Hesap simgesi: profil fotoğrafının çevresinde parlayan, dönen camgöbeği/lacivert şerit */
@Composable
fun AccountAvatar(size: Dp, profile: Store.Profile) {
    val inf = rememberInfiniteTransition(label = "acc")
    val a by inf.animateFloat(0f, 360f, infiniteRepeatable(tween(2600, easing = LinearEasing), RepeatMode.Restart), label = "spin")
    val letter = (profile.name.trim().firstOrNull() ?: 'W').uppercaseChar().toString().replace("I", "I")
    val photo = remember(profile.photo) { profile.photo?.let { runCatching { BitmapFactory.decodeFile(it)?.asImageBitmap() }.getOrNull() } }
    Box(Modifier.size(size), contentAlignment = Alignment.Center) {
        // Parlama
        Box(Modifier.size(size + 6.dp).drawBehind {
            val r = this.size.minDimension / 2
            drawCircle(Color(0x5922D3E6), r + 6.dp.toPx())
            drawCircle(Color(0x8822D3E6), r + 3.dp.toPx())
        })
        // Dönen şerit (konik geçiş)
        Box(Modifier.size(size + 6.dp).rotate(a).clip(CircleShape).background(Brush.sweepGradient(listOf(Color(0xFF22D3E6), Color(0xFF14214A), Color(0xFF3FD0F0), Color(0xFF14214A), Color(0xFF22D3E6)))))
        Box(
            Modifier.size(size - 2.dp).clip(CircleShape).border(2.dp, C.card, CircleShape)
                .background(Brush.linearGradient(listOf(Color(0xFF1F68E0), Color(0xFF14214A)))),
            contentAlignment = Alignment.Center,
        ) {
            if (photo != null) Image(photo, null, Modifier.fillMaxSize(), contentScale = ContentScale.Crop)
            else Text(letter, color = Color(0xFFEEF4FF), fontWeight = FontWeight.Bold, fontSize = (size.value * 0.42f).sp)
        }
    }
}

/** Lite rozeti (eski uygulamadaki çizimin birebir resmi) */
@Composable
fun LiteBadge() {
    Image(painterResource(R.drawable.lite_badge), "Lite", Modifier.size(44.dp, 22.dp))
}

/** WardenCB (eski uygulamadaki çizimin resmi, ruh hâline göre) */
@Composable
fun WardenCBImg(mood: String, size: Dp, modifier: Modifier = Modifier) {
    val ctx = androidx.compose.ui.platform.LocalContext.current
    val id = remember(mood) { ctx.resources.getIdentifier("wcb_${mood.lowercase()}", "drawable", ctx.packageName).takeIf { it != 0 } ?: R.drawable.wcb_idle }
    Image(painterResource(id), "WardenCB", modifier.size(size))
}

/** Eski uygulamadaki anahtar (switch) */
@Composable
fun WSwitch(on: Boolean, modifier: Modifier = Modifier) {
    Box(modifier.size(42.dp, 22.dp)) {
        Box(Modifier.fillMaxSize().clip(RoundedCornerShape(11.dp)).background(if (on) Color(0xFF7FB0F5) else Color(0xFFA9B4C4)))
        Box(
            Modifier.offset(x = if (on) 18.dp else (-2).dp, y = (-2).dp).size(26.dp)
                .drawBehind { drawCircle(Color(0x4D0D1631), this.size.minDimension / 2 + 1, center = center.copy(y = center.y + 1)) }
                .clip(CircleShape).background(if (on) C.primary else C.card),
        )
    }
}

/** Alttaki kısa bildirim (eski uygulamadaki .hnote) */
object Hint {
    var msg by mutableStateOf("")
    private var n = 0
    fun show(m: String) { msg = m; n++ }
    @Composable
    fun Host(bottom: Dp = 96.dp) {
        val cur = msg
        LaunchedEffect(cur, n) { if (cur.isNotEmpty()) { delay(3200); if (msg == cur) msg = "" } }
        if (cur.isNotEmpty()) Box(Modifier.fillMaxSize().padding(bottom = bottom), contentAlignment = Alignment.BottomCenter) {
            Text(cur, color = C.dText, fontSize = 14.sp, textAlign = TextAlign.Center,
                modifier = Modifier.widthIn(max = 340.dp).clip(RoundedCornerShape(14.dp)).background(Color(0xFF14214A)).padding(horizontal = 16.dp, vertical = 10.dp))
        }
    }
}

/** Projenin küçük resmi: arka planda bir kez çizilmiş resim (kaydırırken donmaz) */
@Composable
fun Thumb(p: com.warden.motion.app.model.Project, t: Double, modifier: Modifier, cover: Boolean = false, px: Int = 200) {
    val ctx = androidx.compose.ui.platform.LocalContext.current
    val key = com.warden.motion.app.render.Thumbs.key(p, t, px, cover)
    var bmp by remember(key) { mutableStateOf(com.warden.motion.app.render.Thumbs.cached(key)) }
    LaunchedEffect(key) { if (bmp == null) bmp = com.warden.motion.app.render.Thumbs.get(ctx, p, t, px, cover) }
    Box(modifier, contentAlignment = Alignment.Center) {
        bmp?.let { Image(it.asImageBitmap(), null, Modifier.fillMaxSize(), contentScale = if (cover) ContentScale.Crop else ContentScale.Fit) }
    }
}

@Composable
fun Scrim(color: Color = Color(0x8C0D1631), onClick: () -> Unit) {
    Box(Modifier.fillMaxSize().background(color).tap(onClick = onClick))
}

