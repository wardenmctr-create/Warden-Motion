package com.warden.motion.app.render

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.util.LruCache
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import com.warden.motion.app.model.Layer
import com.warden.motion.app.model.visBox
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlinx.coroutines.withContext

/** Katmanın kendisinin küçük resmi (efektsiz, kırpılmışsa kırpılmış hâli): zaman çizelgesi için, arka planda */
object LayerThumbs {
    private const val H = 72
    private val cache = LruCache<String, Bitmap>(200)
    private val lock = Mutex()
    @Volatile private var r: Renderer? = null

    private fun key(l: Layer) = listOf(l.type, l.src, l.crop, l.shape, l.sp, l.pts, l.fill, l.fill2, l.grad, l.gtype, l.noFill, l.w, l.h, l.text, l.fontSize, l.cb, l.flipX, l.flipY).toString()

    @Composable
    fun rememberThumb(ctx: Context, l: Layer): Bitmap? {
        if (l.type == "audio") return null
        val k = key(l)
        var b by remember(k) { mutableStateOf(cache.get(k)) }
        LaunchedEffect(k) { if (b == null) b = make(ctx, l, k) }
        return b
    }

    private suspend fun make(ctx: Context, l: Layer, k: String): Bitmap? = withContext(Dispatchers.Default) {
        lock.withLock {
            cache.get(k)?.let { return@withLock it }
            val rr = r ?: Renderer(ctx.applicationContext, maxSide = 256, sync = true, cacheMb = 16).also { r = it }
            val media = l.type == "image" || l.type == "cb" || l.type == "video"
            val b = if (l.crop != null && media) l.visBox() else android.graphics.RectF((-l.w / 2).toFloat(), (-l.h / 2).toFloat(), (l.w / 2).toFloat(), (l.h / 2).toFloat())
            val bw = maxOf(1f, b.width()); val bh = maxOf(1f, b.height())
            val sc = H / bh
            val w = (bw * sc).toInt().coerceIn(4, H * 4)
            val bmp = Bitmap.createBitmap(w, H, Bitmap.Config.ARGB_8888)
            val c = Canvas(bmp)
            c.translate(w / 2f, H / 2f)
            c.scale(sc * (if (l.flipX == true) -1 else 1), sc * (if (l.flipY == true) -1 else 1))
            c.translate(-b.centerX(), -b.centerY())
            runCatching { rr.drawLayer(c, l.copy(effects = emptyList())) }
            cache.put(k, bmp)
            bmp
        }
    }
}
