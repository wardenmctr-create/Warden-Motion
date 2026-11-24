package com.warden.motion.app.render

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.util.LruCache
import com.warden.motion.app.model.Project
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlinx.coroutines.withContext

/**
 * Proje küçük resimleri: arka planda, küçük boyutlu görsellerle bir kez çizilir ve saklanır.
 * Ana ekran kaydırılırken hiçbir şey yeniden çizilmez (donma olmaz).
 */
object Thumbs {
    private val cache = LruCache<String, Bitmap>(60)
    private val lock = Mutex()
    @Volatile private var r: Renderer? = null

    fun cached(key: String): Bitmap? = cache.get(key)

    fun key(p: Project, t: Double, px: Int, cover: Boolean) = "${p.id}|${p.updatedAt}|${p.layers.size}|$t|$px|$cover"

    suspend fun get(ctx: Context, p: Project, t: Double, px: Int, cover: Boolean): Bitmap = withContext(Dispatchers.Default) {
        val k = key(p, t, px, cover)
        cache.get(k)?.let { return@withContext it }
        lock.withLock {
            cache.get(k)?.let { return@withLock it }
            val rr = r ?: Renderer(ctx.applicationContext, maxSide = 320, sync = true, cacheMb = 24).also { r = it }
            val s = if (cover) px.toFloat() / minOf(p.width, p.height) else px.toFloat() / maxOf(p.width, p.height)
            val w = if (cover) px else (p.width * s).toInt().coerceAtLeast(1)
            val h = if (cover) px else (p.height * s).toInt().coerceAtLeast(1)
            val b = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
            val c = Canvas(b)
            if (cover) c.translate((px - p.width * s) / 2, (px - p.height * s) / 2)
            rr.draw(c, p, minOf(t, p.duration - 0.01), s)
            cache.put(k, b)
            b
        }
    }
}
