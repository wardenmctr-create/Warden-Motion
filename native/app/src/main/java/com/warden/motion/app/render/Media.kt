package com.warden.motion.app.render

import android.content.Context
import android.graphics.Bitmap
import android.media.AudioFormat
import android.media.MediaCodec
import android.media.MediaExtractor
import android.media.MediaFormat
import android.media.MediaMetadataRetriever
import android.media.MediaPlayer
import android.media.audiofx.LoudnessEnhancer
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.LruCache
import com.warden.motion.app.data.Store
import com.warden.motion.app.model.Layer
import com.warden.motion.app.model.Project
import java.io.File
import java.nio.ByteOrder
import java.util.concurrent.Executors
import kotlin.math.abs
import kotlin.math.max
import kotlin.math.min
import kotlin.math.roundToInt

/**
 * Video kareleri: telefonun donanım video çözücüsüyle (MediaCodec) SIRAYLA çözülür.
 * Oynatırken kareler akar (her karede baştan arama yok, donma yok); geri sarınca ya da uzağa atlayınca
 * en yakın anahtar kareye gidilip oradan ileri çözülür. Kareler YUV'den kendimiz çeviriyoruz
 * (bazı telefonların hazır "kare ver" aracı tek renk kare döndürüyor).
 */
class VideoSource(private val file: File, private val maxSide: Int, private val onFrame: () -> Unit) {
    private val ex = MediaExtractor().apply { setDataSource(file.absolutePath) }
    private val track = (0 until ex.trackCount).first { ex.getTrackFormat(it).getString(MediaFormat.KEY_MIME)?.startsWith("video/") == true }
    private val fmt = ex.getTrackFormat(track)
    val durationS: Double
    val fps: Double
    private val rot: Int
    init {
        ex.selectTrack(track)
        val r = MediaMetadataRetriever()
        var d = 0.0; var rr = 0; var cnt = 0
        runCatching {
            r.setDataSource(file.absolutePath)
            d = (r.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)?.toDoubleOrNull() ?: 0.0) / 1000
            rr = r.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_ROTATION)?.toIntOrNull() ?: 0
            if (Build.VERSION.SDK_INT >= 28) cnt = r.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_FRAME_COUNT)?.toIntOrNull() ?: 0
        }
        runCatching { r.release() }
        if (d <= 0 && fmt.containsKey(MediaFormat.KEY_DURATION)) d = fmt.getLong(MediaFormat.KEY_DURATION) / 1e6
        durationS = d
        val fr = runCatching { if (fmt.containsKey(MediaFormat.KEY_FRAME_RATE)) fmt.getInteger(MediaFormat.KEY_FRAME_RATE).toDouble() else 0.0 }.getOrDefault(0.0)
        fps = if (cnt > 0 && d > 0) cnt / d else if (fr > 0) fr else 30.0
        rot = ((if (fmt.containsKey("rotation-degrees")) fmt.getInteger("rotation-degrees") else rr) % 360 + 360) % 360
    }
    // Çözücü açılamazsa (desteklenmeyen tür) her kare yedek yoldan alınır
    private val codec: MediaCodec? = runCatching {
        MediaCodec.createDecoderByType(fmt.getString(MediaFormat.KEY_MIME)!!).apply {
            fmt.setInteger(MediaFormat.KEY_COLOR_FORMAT, android.media.MediaCodecInfo.CodecCapabilities.COLOR_FormatYUV420Flexible)
            configure(fmt, null, null, 0); start()
        }
    }.getOrNull()
    private val frameDur get() = 1.0 / fps

    private val lock = Object()
    @Volatile private var want = -1.0
    @Volatile private var alive = true
    /** En son çözülen kare ve gösterdiği an (kaynak saniyesi) */
    @Volatile private var latest: Bitmap? = null
    @Volatile private var latestT = -1.0
    private var lastPts = -1.0      // çözücünün en son verdiği kare
    private var inEos = false
    /** En son tamamlanan istek */
    @Volatile private var done = -1.0
    private val pool = ArrayDeque<Bitmap>()
    private val thread = Thread({ loop() }, "video-" + file.name).apply { isDaemon = true; start() }

    private fun covers(ft: Double, t: Double) = t >= ft - 1e-4 && t < ft + frameDur - 1e-4

    private fun loop() {
        while (alive) {
            val t: Double
            synchronized(lock) {
                // Aynı istek ikinci kez çözülmez (video bittiyse ya da kare yoksa boşuna dönmesin)
                while (alive && (want < 0 || want == done || (latestT >= 0 && covers(latestT, want.coerceAtMost(max(0.0, durationS - frameDur * 0.5)))))) lock.wait(200)
                t = want
            }
            if (!alive) break
            runCatching { decodeTo(t) }.onFailure { runCatching { seek(t) } }
            done = t
            synchronized(lock) { lock.notifyAll() }
        }
        runCatching { codec?.stop() }; runCatching { codec?.release() }; runCatching { ex.release() }; runCatching { retr?.release() }
        synchronized(pool) { pool.clear() }
    }

    private fun seek(t: Double) {
        codec?.flush(); inEos = false; lastPts = -1.0
        ex.seekTo((t * 1e6).toLong(), MediaExtractor.SEEK_TO_PREVIOUS_SYNC)
    }

    /** t anını gösteren kareye kadar çöz (ileriyse sırayla devam, geriyse / çok uzaksa anahtar kareden) */
    private fun decodeTo(t0: Double) {
        val t = t0.coerceIn(0.0, max(0.0, durationS - frameDur * 0.5))
        val codec = codec ?: run {
            val ft = ((t * fps).toInt() / fps)
            fallback(ft)?.let { publish(it, ft) }
            return
        }
        if (lastPts < 0 || t < lastPts - 1e-4 || t > lastPts + 2.0 || (inEos && t > lastPts + frameDur)) seek(t)
        val info = MediaCodec.BufferInfo()
        var guard = 0
        while (alive && guard++ < 4000) {
            if (want >= 0 && abs(want - t0) > 1e-6 && (want < t0 || want > t0 + 2.0)) return // yeni istek: uzağa atlandı, baştan
            if (!inEos) {
                val ii = codec.dequeueInputBuffer(2000)
                if (ii >= 0) {
                    val buf = codec.getInputBuffer(ii)!!
                    val n = ex.readSampleData(buf, 0)
                    if (n < 0) { codec.queueInputBuffer(ii, 0, 0, 0, MediaCodec.BUFFER_FLAG_END_OF_STREAM); inEos = true }
                    else { codec.queueInputBuffer(ii, 0, n, ex.sampleTime, 0); ex.advance() }
                }
            }
            val oi = codec.dequeueOutputBuffer(info, 4000)
            if (oi >= 0) {
                val eos = info.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0
                val pts = info.presentationTimeUs / 1e6
                val hit = info.size > 0 && (pts + frameDur - 1e-4 > t || eos)
                if (info.size > 0) lastPts = pts
                if (hit && info.size > 0) {
                    val img = runCatching { codec.getOutputImage(oi) }.getOrNull()
                    var bmp = img?.let { runCatching { convert(it) }.getOrNull() }
                    img?.close()
                    codec.releaseOutputBuffer(oi, false)
                    if (bmp == null) bmp = fallback(pts)
                    if (bmp != null) publish(bmp, pts)
                    return
                }
                codec.releaseOutputBuffer(oi, false)
                if (eos) return
            }
        }
    }

    /** YUV_420_888 → RGB, hedef boyuta küçülterek ve videonun dönüklüğüne göre çevirerek */
    private fun convert(img: android.media.Image): Bitmap? {
        val cr = img.cropRect
        val sw = cr.width(); val sh = cr.height()
        if (sw <= 0 || sh <= 0) return null
        val rw = if (rot == 90 || rot == 270) sh else sw; val rh = if (rot == 90 || rot == 270) sw else sh
        val k = if (maxSide > 0) min(1.0, maxSide.toDouble() / max(rw, rh)) else 1.0
        val ow = max(1, (rw * k).roundToInt()); val oh = max(1, (rh * k).roundToInt())
        val py = img.planes[0]; val pu = img.planes[1]; val pv = img.planes[2]
        // Düzlemler bir kerede diziye alınır (piksel piksel tampondan okumaktan çok daha hızlı)
        val yb = py.buffer.let { b -> ByteArray(b.remaining()).also { b.get(it) } }
        val ub = pu.buffer.let { b -> ByteArray(b.remaining()).also { b.get(it) } }
        val vb = pv.buffer.let { b -> ByteArray(b.remaining()).also { b.get(it) } }
        val yRow = py.rowStride; val yPix = py.pixelStride
        val uRow = pu.rowStride; val uPix = pu.pixelStride; val vRow = pv.rowStride; val vPix = pv.pixelStride
        val out = yuvToArgb(yb, yRow, yPix, ub, uRow, uPix, vb, vRow, vPix, cr.left, cr.top, sw, sh, rot, ow, oh)
        val bmp = synchronized(pool) { pool.firstOrNull { it.width == ow && it.height == oh }?.also { pool.remove(it) } } ?: Bitmap.createBitmap(ow, oh, Bitmap.Config.ARGB_8888)
        bmp.setPixels(out, 0, ow, 0, 0, ow, oh)
        return bmp
    }

    private fun publish(bmp: Bitmap, t: Double) {
        val old = latest
        latest = bmp; latestT = t
        if (old != null && old !== bmp) synchronized(pool) { if (pool.size < 3) pool.addLast(old) }
        synchronized(lock) { lock.notifyAll() }
        onFrame()
    }

    /** Çözücü kareyi veremezse: o tek kare telefonun kare çıkarma aracıyla */
    private var retr: MediaMetadataRetriever? = null
    private fun fallback(t: Double): Bitmap? = runCatching {
        val r = retr ?: MediaMetadataRetriever().also { it.setDataSource(file.absolutePath); retr = it }
        val b = r.getFrameAtTime((t * 1e6).toLong(), MediaMetadataRetriever.OPTION_CLOSEST) ?: return null
        val k = if (maxSide > 0) min(1.0, maxSide.toDouble() / max(b.width, b.height)) else 1.0
        if (k < 1) Bitmap.createScaledBitmap(b, max(1, (b.width * k).toInt()), max(1, (b.height * k).toInt()), true).also { if (it !== b) b.recycle() } else b
    }.getOrNull()

    private fun request(t: Double) = synchronized(lock) { if (want != t) { want = t; lock.notifyAll() } }

    /** Çizim için kare: hazır olan en son kare hemen döner (bekleme yok), istenen kare arka planda çözülür */
    fun frame(t: Double, playing: Boolean): Bitmap? { request(t); return latest }

    /** Dışa aktarma: tam o kare (beklenir) */
    fun frameSync(t: Double): Bitmap? {
        request(t)
        val end = System.currentTimeMillis() + 5000
        synchronized(lock) {
            while (alive && done != t && !(latestT >= 0 && (covers(latestT, t.coerceAtMost(max(0.0, durationS - frameDur * 0.5))) || latestT >= durationS - frameDur * 1.5 && t >= latestT)) && System.currentTimeMillis() < end) {
                lock.wait(5)
            }
        }
        return latest
    }

    fun release() { alive = false; synchronized(lock) { lock.notifyAll() } }
}

/** YUV 4:2:0 düzlemlerinden ARGB: (ow × oh) boyuta küçültür, rot derece (saat yönü) döndürür. BT.601 sınırlı aralık */
internal fun yuvToArgb(yb: ByteArray, yRow: Int, yPix: Int, ub: ByteArray, uRow: Int, uPix: Int, vb: ByteArray, vRow: Int, vPix: Int,
                       left: Int, top: Int, sw: Int, sh: Int, rot: Int, ow: Int, oh: Int): IntArray {
    val rw = if (rot == 90 || rot == 270) sh else sw; val rh = if (rot == 90 || rot == 270) sw else sh
    val out = IntArray(ow * oh)
    val kx = rw.toDouble() / ow; val ky = rh.toDouble() / oh
    for (oy in 0 until oh) {
        val dy = (oy * ky).toInt()
        for (ox in 0 until ow) {
            val dx = (ox * kx).toInt()
            // Ekrandaki (döndürülmüş) pikselin kaynaktaki yeri
            val ux: Int; val uy: Int
            when (rot) {
                90 -> { ux = dy; uy = sh - 1 - dx }
                180 -> { ux = sw - 1 - dx; uy = sh - 1 - dy }
                270 -> { ux = sw - 1 - dy; uy = dx }
                else -> { ux = dx; uy = dy }
            }
            val x = ux.coerceIn(0, sw - 1) + left; val y = uy.coerceIn(0, sh - 1) + top
            val Y = (yb[min(yb.size - 1, y * yRow + x * yPix)].toInt() and 0xFF) - 16
            val cx = x / 2; val cy = y / 2
            val U = (ub[min(ub.size - 1, cy * uRow + cx * uPix)].toInt() and 0xFF) - 128
            val V = (vb[min(vb.size - 1, cy * vRow + cx * vPix)].toInt() and 0xFF) - 128
            val y1 = 1192 * max(0, Y)
            val r = ((y1 + 1634 * V) shr 10).coerceIn(0, 255)
            val g = ((y1 - 833 * V - 400 * U) shr 10).coerceIn(0, 255)
            val b = ((y1 + 2066 * U) shr 10).coerceIn(0, 255)
            out[oy * ow + ox] = (0xFF shl 24) or (r shl 16) or (g shl 8) or b
        }
    }
    return out
}

// ---------------------------------------------------------------------------------------------
// Ses: önizlemede çalma (dosyanın yerinden), dalga şekli ve dışa aktarma için çözme
// ---------------------------------------------------------------------------------------------
fun hasAudio(l: Layer) = (l.type == "audio" || l.type == "video") && l.src != null && l.hidden != true && l.muted != true && (l.volume ?: 1.0) > 0

object Player {
    private val players = ArrayList<MediaPlayer>()
    private val fx = ArrayList<LoudnessEnhancer>()
    private val h = Handler(Looper.getMainLooper())

    /** t anından itibaren bütün sesleri çal */
    fun play(ctx: Context, p: Project, t: Double) {
        stop()
        val store = Store.get(ctx)
        for (l in p.layers) {
            if (!hasAudio(l) || l.end <= t) continue
            val f = store.mediaFile(l.src!!.removePrefix("media:"))
            if (!f.exists()) continue
            val off = (l.srcIn ?: 0.0) + max(0.0, t - l.start); val wait = max(0.0, l.start - t)
            runCatching {
                val m = MediaPlayer()
                m.setDataSource(f.absolutePath)
                m.prepare()
                if (off * 1000 >= m.duration) { m.release(); return@runCatching }
                val vol = (l.volume ?: 1.0)
                m.setVolume(min(1.0, vol).toFloat(), min(1.0, vol).toFloat())
                if (vol > 1.0) runCatching { LoudnessEnhancer(m.audioSessionId).apply { setTargetGain(((vol - 1) * 1200).toInt()); enabled = true }.also { fx += it } }
                if (Build.VERSION.SDK_INT >= 26) m.seekTo((off * 1000).toLong(), MediaPlayer.SEEK_CLOSEST) else m.seekTo((off * 1000).toInt())
                players += m
                val stopAt = ((l.end - max(t, l.start)) * 1000).toLong()
                h.postDelayed({ if (m in players) { runCatching { m.start() }; h.postDelayed({ if (m in players) runCatching { m.pause() } }, stopAt) } }, (wait * 1000).toLong())
            }
        }
    }
    fun stop() {
        h.removeCallbacksAndMessages(null)
        players.forEach { runCatching { it.stop() }; runCatching { it.release() } }
        players.clear()
        fx.forEach { runCatching { it.release() } }; fx.clear()
    }
}

/** Çözülmüş ses: aralıklı (interleaved) stereo float, örnekleme hızı */
class Pcm(val data: FloatArray, val rate: Int) { val frames get() = data.size / 2 }

object AudioDecode {
    private val peaks = LruCache<String, FloatArray>(40)
    private val pcms = LruCache<String, Pcm>(4)

    /** Dosyanın sesini çöz (videonun sesi de olur). Sesi yoksa null */
    fun decode(file: File, maxSeconds: Double = 600.0): Pcm? {
        val key = file.absolutePath
        pcms.get(key)?.let { return it }
        val ex = MediaExtractor()
        try {
            ex.setDataSource(file.absolutePath)
            val ti = (0 until ex.trackCount).firstOrNull { ex.getTrackFormat(it).getString(MediaFormat.KEY_MIME)?.startsWith("audio/") == true } ?: return null
            ex.selectTrack(ti)
            val fmt = ex.getTrackFormat(ti)
            val mime = fmt.getString(MediaFormat.KEY_MIME)!!
            val codec = MediaCodec.createDecoderByType(mime)
            codec.configure(fmt, null, null, 0)
            codec.start()
            var rate = fmt.getInteger(MediaFormat.KEY_SAMPLE_RATE); var ch = fmt.getInteger(MediaFormat.KEY_CHANNEL_COUNT)
            var enc = AudioFormat.ENCODING_PCM_16BIT
            val out = FloatList()
            val info = MediaCodec.BufferInfo()
            var inDone = false; var outDone = false
            val maxFrames = (maxSeconds * rate).toLong()
            while (!outDone) {
                if (!inDone) {
                    val ii = codec.dequeueInputBuffer(10000)
                    if (ii >= 0) {
                        val buf = codec.getInputBuffer(ii)!!
                        val n = ex.readSampleData(buf, 0)
                        if (n < 0) { codec.queueInputBuffer(ii, 0, 0, 0, MediaCodec.BUFFER_FLAG_END_OF_STREAM); inDone = true }
                        else { codec.queueInputBuffer(ii, 0, n, ex.sampleTime, 0); ex.advance() }
                    }
                }
                val oi = codec.dequeueOutputBuffer(info, 10000)
                if (oi == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED) {
                    val f = codec.outputFormat
                    rate = f.getInteger(MediaFormat.KEY_SAMPLE_RATE); ch = f.getInteger(MediaFormat.KEY_CHANNEL_COUNT)
                    if (Build.VERSION.SDK_INT >= 24 && f.containsKey(MediaFormat.KEY_PCM_ENCODING)) enc = f.getInteger(MediaFormat.KEY_PCM_ENCODING)
                } else if (oi >= 0) {
                    val b = codec.getOutputBuffer(oi)!!.order(ByteOrder.nativeOrder())
                    b.position(info.offset); b.limit(info.offset + info.size)
                    if (enc == AudioFormat.ENCODING_PCM_FLOAT) {
                        val fb = b.asFloatBuffer(); val n = fb.remaining() / ch
                        for (i in 0 until n) { val l = fb.get(i * ch); val r = if (ch > 1) fb.get(i * ch + 1) else l; out.add(l); out.add(r) }
                    } else {
                        val sb = b.asShortBuffer(); val n = sb.remaining() / ch
                        for (i in 0 until n) { val l = sb.get(i * ch) / 32768f; val r = if (ch > 1) sb.get(i * ch + 1) / 32768f else l; out.add(l); out.add(r) }
                    }
                    codec.releaseOutputBuffer(oi, false)
                    if (info.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0 || out.size / 2 > maxFrames) outDone = true
                } else if (inDone && oi == MediaCodec.INFO_TRY_AGAIN_LATER && info.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) outDone = true
            }
            codec.stop(); codec.release()
            return Pcm(out.toArray(), rate).also { pcms.put(key, it) }
        } catch (e: Exception) {
            return null
        } finally { ex.release() }
    }

    /** Dalga şekli için tepe değerleri (saniyede 100) */
    fun peaks(file: File): FloatArray? {
        peaks.get(file.absolutePath)?.let { return it }
        val p = decode(file) ?: return null
        val step = max(1, p.rate / 100)
        val n = p.frames / step
        val out = FloatArray(n)
        for (i in 0 until n) { var m = 0f; var j = i * step; val e = min(p.frames, j + step); while (j < e) { val v = abs(p.data[j * 2]); if (v > m) m = v; j += 4 }; out[i] = m }
        peaks.put(file.absolutePath, out)
        return out
    }

    /** Bütün sesleri tek bir stereo sese karıştırır (dışa aktarma) */
    fun mix(ctx: Context, p: Project, dur: Double, rate: Int = 44100): FloatArray? {
        val ls = p.layers.filter(::hasAudio)
        if (ls.isEmpty()) return null
        val n = (dur * rate).roundToInt()
        val out = FloatArray(n * 2)
        var any = false
        for (l in ls) {
            val pcm = decode(Store.get(ctx).mediaFile(l.src!!.removePrefix("media:"))) ?: continue
            any = true
            val vol = (l.volume ?: 1.0).toFloat()
            val s0 = (l.start * rate).roundToInt(); val s1 = min(n, (l.end * rate).roundToInt())
            val k = pcm.rate.toDouble() / rate
            for (i in max(0, s0) until s1) {
                val src = (i - s0) * k + (l.srcIn ?: 0.0) * pcm.rate; val j = src.toInt(); if (j + 1 >= pcm.frames) break
                val f = (src - j).toFloat()
                out[i * 2] += (pcm.data[j * 2] * (1 - f) + pcm.data[j * 2 + 2] * f) * vol
                out[i * 2 + 1] += (pcm.data[j * 2 + 1] * (1 - f) + pcm.data[j * 2 + 3] * f) * vol
            }
        }
        if (!any) return null
        for (i in out.indices) out[i] = out[i].coerceIn(-1f, 1f)
        return out
    }
}

/** Büyüyen float dizisi */
class FloatList { private var a = FloatArray(1 shl 16); var size = 0; private set
    fun add(v: Float) { if (size == a.size) a = a.copyOf(a.size * 2); a[size++] = v }
    fun toArray() = a.copyOf(size)
}
