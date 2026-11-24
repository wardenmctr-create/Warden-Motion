package com.warden.motion.app.ui

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.StrokeJoin
import androidx.compose.ui.graphics.drawscope.Fill
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.drawscope.scale
import androidx.compose.ui.graphics.vector.PathParser
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

/** Eski uygulamadaki ikonların aynısı (24×24, çizgi ikonlar) */
val ICON_PATHS: Map<String, String> = mapOf(
    "menu" to "M4 6h16M4 12h16M4 18h16",
    "plus" to "M12 5v14M5 12h14",
    "close" to "M6 6l12 12M18 6L6 18",
    "back" to "M19 12H5M11 6l-6 6 6 6",
    "exit" to "M14 4h5v16h-5M3 12h11M7 8l-4 4 4 4",
    "chevR" to "M9 6l6 6-6 6",
    "chevD" to "M6 9l6 6 6-6",
    "gear" to "M12 2l2 3 3.5-.5.9 3.4 3.1 1.6-1.4 3.2 1.4 3.2-3.1 1.6-.9 3.4L14 19l-2 3-2-3-3.5.5-.9-3.4-3.1-1.6 1.4-3.2-1.4-3.2 3.1-1.6.9-3.4L10 5zM12 9a3 3 0 1 0 0 6 3 3 0 0 0 0-6z",
    "export" to "M20 14v5a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1V5a1 1 0 0 1 1-1h5M14 4h6v6M20 4l-9 9",
    "undo" to "M9 14L4 9l5-5M4 9h11a5 5 0 0 1 0 10h-3",
    "redo" to "M15 14l5-5-5-5M20 9H9a5 5 0 0 0 0 10h3",
    "toStart" to "M5 5v14M20 12H9M13 8l-4 4 4 4",
    "toEnd" to "M19 5v14M4 12h11M11 8l4 4-4 4",
    "copy" to "M9 4h11v11H9zM6 9H4v11h11v-2",
    "trash" to "M4 7h16M9 7V4h6v3M6 7l1 13h10l1-13",
    "more" to "M5 12h.01M12 12h.01M19 12h.01",
    "home" to "M3 11l9-7 9 7v9a1 1 0 0 1-1 1h-5v-6h-6v6H4a1 1 0 0 1-1-1z",
    "cap" to "M2 9l10-5 10 5-10 5zM6 11v5c3 2 9 2 12 0v-5",
    "film" to "M5 3h15v15H5zM3 7v12a2 2 0 0 0 2 2h12M11 8l4 2.5-4 2.5z",
    "grid" to "M3 3h18v18H3zM3 9h18M10 21V9",
    "clock" to "M12 22a10 10 0 1 0 0-20 10 10 0 0 0 0 20zM12 6v6l4 2",
    "apps" to "M4 4h4v4H4zM10 4h4v4h-4zM16 4h4v4h-4zM4 10h4v4H4zM10 10h4v4h-4zM16 10h4v4h-4zM4 16h4v4H4zM10 16h4v4h-4zM16 16h4v4h-4z",
    "move" to "M12 3v18M3 12h18M9 6l3-3 3 3M9 18l3 3 3-3M6 9l-3 3 3 3M18 9l3 3-3 3",
    "rotate" to "M20 11a8 8 0 1 0-2.3 5.7M20 4v7h-7",
    "scale" to "M4 10h10v10H4zM14 4h6v6M20 4l-8 8",
    "bucket" to "M5 11l7-7 7 7-7 7zM19 15s2 2.5 2 4a2 2 0 0 1-4 0c0-1.5 2-4 2-4z",
    "opacity" to "M12 3a9 9 0 1 0 0 18zM12 3a9 9 0 0 1 0 18",
    "sparkle" to "M12 3l2 6 6 2-6 2-2 6-2-6-6-2 6-2z",
    "ball" to "M12 3a9 9 0 1 0 0 18 9 9 0 0 0 0-18zM8.5 10.5v1M15.5 10.5v1",
    "text" to "M5 6h14M12 6v13",
    "image" to "M3 5h18v14H3zM8 11a2 2 0 1 0 0-4 2 2 0 0 0 0 4zM21 16l-5-5-9 8",
    "flag" to "M5 21V4M5 4h12l-2 4 2 4H5",
    "shapes" to "M7 3a4 4 0 1 0 0 8 4 4 0 0 0 0-8zM14 3l4 7h-8zM3 14h7v7H3zM17.5 21s-4-2.5-4-5a2 2 0 0 1 4-1 2 2 0 0 1 4 1c0 2.5-4 5-4 5z",
    "folder" to "M3 7a2 2 0 0 1 2-2h4l2 2h8a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z",
    "upload" to "M12 16V4M7 9l5-5 5 5M4 16v3a1 1 0 0 0 1 1h14a1 1 0 0 0 1-1v-3",
    "search" to "M11 4a7 7 0 1 0 0 14 7 7 0 0 0 0-14zM20 20l-4-4",
    "star" to "M12 3l2.8 5.8 6.2.9-4.5 4.4 1 6.2L12 17.4 6.5 20.3l1-6.2L3 9.7l6.2-.9z",
    "trimL" to "M10 4v16M14 8l-4 4 4 4M20 8v8",
    "trimR" to "M14 4v16M10 8l4 4-4 4M4 8v8",
    "split" to "M12 3v18M8 8l-4 4 4 4M16 8l4 4-4 4",
    "eye" to "M2 12s4-7 10-7 10 7 10 7-4 7-10 7S2 12 2 12zM12 9a3 3 0 1 0 0 6 3 3 0 0 0 0-6z",
    "eyeOff" to "M3 3l18 18M10.6 6.1A10 10 0 0 1 12 6c6 0 10 6 10 6a17 17 0 0 1-3.2 3.7M6.6 6.6C3.8 8.4 2 12 2 12s4 7 10 7c1.6 0 3-.4 4.3-1",
    "check" to "M5 12l5 5 9-10",
    "fit" to "M4 8V4h4M16 4h4v4M20 16v4h-4M8 20H4v-4",
    "key" to "M12 3l9 9-9 9-9-9z",
    "border" to "M4 4h16v16H4zM8 8h8v8H8z",
    "info" to "M12 3a9 9 0 1 0 0 18 9 9 0 0 0 0-18zM12 11v6M12 7.5v.5",
    "nofill" to "M12 3a9 9 0 1 0 0 18 9 9 0 0 0 0-18zM5.6 18.4L18.4 5.6",
    "music" to "M9 18V5l11-2v13M6 21a3 3 0 1 0 0-6 3 3 0 0 0 0 6zM17 19a3 3 0 1 0 0-6 3 3 0 0 0 0 6z",
    "volOff" to "M11 5 6 9H2v6h4l5 4V5zM23 9l-6 6M17 9l6 6",
    "curve" to "M4 4h16v16H4zM6 18C12 18 12 6 18 6",
    "skew" to "M8 5h13l-5 14H3z",
    "link" to "M10 14a4 4 0 0 0 5.7 0l3-3a4 4 0 0 0-5.7-5.7l-1 1M14 10a4 4 0 0 0-5.7 0l-3 3a4 4 0 0 0 5.7 5.7l1-1",
    "loop" to "M17 2l4 4-4 4M3 11V9a3 3 0 0 1 3-3h15M7 22l-4-4 4-4M21 13v2a3 3 0 0 1-3 3H3",
    "pen" to "M4 20l4-1 11-11-3-3L5 16z",
    "layers" to "M12 3l9 5-9 5-9-5zM3 13l9 5 9-5",
    "hand" to "M9 12V5.5a1.5 1.5 0 0 1 3 0V11M12 10.5V4.5a1.5 1.5 0 0 1 3 0V11M15 10.5V6.5a1.5 1.5 0 0 1 3 0V14a6 6 0 0 1-6 6h-1.2a5 5 0 0 1-4-2l-3-4.2a1.5 1.5 0 0 1 2.4-1.8L9 14",
    "share" to "M12 15V3M8 7l4-4 4 4M5 11v9h14v-9",
    "drive" to "M8.5 3.5h7l6.5 11-3.5 6h-13L2 14.5zM8.5 3.5l7 11M2 14.5h13.5M15.5 3.5L9 14.5",
    "cloudUp" to "M7 18.5a4.5 4.5 0 0 1-.5-9 6 6 0 0 1 11.5-1.6A4.5 4.5 0 0 1 17.5 18.5M12 12v9M9 15l3-3 3 3"
)

private val pathCache = HashMap<String, Path>()
private fun iconPath(name: String): Path = pathCache.getOrPut(name) { PathParser().parsePathString(ICON_PATHS[name] ?: "").toPath() }

@Composable
fun Ico(name: String, tint: Color, size: Dp = 22.dp, stroke: Float = 1.8f, fill: Boolean = false, modifier: Modifier = Modifier) {
    Canvas(modifier.size(size)) {
        val k = this.size.minDimension / 24f
        scale(k, k, pivot = Offset.Zero) {
            when (name) {
                "play" -> drawPath(Path().apply { moveTo(7f, 4.5f); lineTo(20f, 12f); lineTo(7f, 19.5f); close() }, tint)
                "pause" -> {
                    drawRoundRect(tint, Offset(6f, 4.5f), Size(4f, 15f), CornerRadius(1f))
                    drawRoundRect(tint, Offset(14f, 4.5f), Size(4f, 15f), CornerRadius(1f))
                }
                else -> {
                    val p = iconPath(name)
                    if (fill) drawPath(p, tint, style = Fill)
                    drawPath(p, tint, style = Stroke(width = stroke, cap = StrokeCap.Round, join = StrokeJoin.Round))
                }
            }
        }
    }
}
