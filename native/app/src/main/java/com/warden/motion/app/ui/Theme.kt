package com.warden.motion.app.ui

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Typography
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.Font
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import com.warden.motion.app.R

/** Eski uygulamadaki renkler (saf beyaz / saf siyah yok) */
object C {
    val bg = Color(0xFFEEF1F5); val card = Color(0xFFF7F8FA); val soft = Color(0xFFE9EDF3); val line = Color(0xFFD3DBE6)
    val text = Color(0xFF0D1631); val text2 = Color(0xFF56657E); val primary = Color(0xFF1F68E0); val onPrimary = Color(0xFFEEF4FF)
    val dBg = Color(0xFF0F1834); val dDeep = Color(0xFF0B1430); val dBar = Color(0xFF121D40); val dPanel = Color(0xFF1E2A55); val dPanel2 = Color(0xFF17224A)
    val dLine = Color(0xFF2C3E78); val dText = Color(0xFFDCE9FF); val dText2 = Color(0xFF8FA6D6); val dDim = Color(0xFF4A5E8C)
    val blue = Color(0xFF3B9BFF); val turq = Color(0xFF22D3C5); val cyan = Color(0xFF3FD0F0)
    val danger = Color(0xFFD23B3B)
}

val Inter = FontFamily(
    Font(R.font.inter_regular, FontWeight.Normal), Font(R.font.inter_medium, FontWeight.Medium),
    Font(R.font.inter_semibold, FontWeight.SemiBold), Font(R.font.inter_bold, FontWeight.Bold), Font(R.font.inter_extrabold, FontWeight.ExtraBold),
)

@Composable
fun GlowTheme(content: @Composable () -> Unit) {
    val base = Typography()
    val t = TextStyle(fontFamily = Inter)
    MaterialTheme(
        colorScheme = lightColorScheme(primary = C.primary, onPrimary = C.onPrimary, background = C.bg, surface = C.card, onSurface = C.text),
        typography = Typography(
            bodyLarge = base.bodyLarge.merge(t), bodyMedium = base.bodyMedium.merge(t), bodySmall = base.bodySmall.merge(t),
            labelLarge = base.labelLarge.merge(t), labelMedium = base.labelMedium.merge(t), labelSmall = base.labelSmall.merge(t),
            titleLarge = base.titleLarge.merge(t), titleMedium = base.titleMedium.merge(t), titleSmall = base.titleSmall.merge(t),
            headlineSmall = base.headlineSmall.merge(t), headlineMedium = base.headlineMedium.merge(t),
        ),
    ) { androidx.compose.material3.ProvideTextStyle(TextStyle(fontFamily = Inter, color = C.text), content) }
}
