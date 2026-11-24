package com.warden.motion.app.ui

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

/** Eski uygulamadaki renkler (açık ana ekran, koyu editör) */
object C {
    val bg = Color(0xFFEEF1F5)
    val card = Color(0xFFF7F8FA)
    val soft = Color(0xFFE9EDF3)
    val line = Color(0xFFD3DBE6)
    val text = Color(0xFF0D1631)
    val text2 = Color(0xFF56657E)
    val primary = Color(0xFF1F68E0)
    val onPrimary = Color(0xFFEEF4FF)
    val turq = Color(0xFF22D3C5)
    val cyan = Color(0xFF3FE0F0)
    val liteBlue = Color(0xFF2E8BFF)

    // Editör (koyu)
    val dBg = Color(0xFF0B1430)
    val dPanel = Color(0xFF16214A)
    val dText = Color(0xFFDCE9FF)
    val dText2 = Color(0xFF8FA6D6)
}

@Composable
fun GlowTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = lightColorScheme(primary = C.primary, onPrimary = C.onPrimary, background = C.bg, surface = C.card, onSurface = C.text),
        content = content,
    )
}
