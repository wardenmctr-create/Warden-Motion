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
 * Videodan kare çıkarma: telefonun video çözücüsüyle (MediaMetadataRetriever).
 * Oynatırken kareler birkaç kare ileriden toplu çözülür; duraklatınca tam o kare.
 */
class VideoSource(private val file: File, private val maxSide: Int, private val onFrame: () -> Unit) {
    private val r = MediaMetadataRetriever().apply { setDataSource(file.absolutePath) }
    val durationS = (r.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)?.toDoubleOrNull() ?: 0.0) / 1000
    private val count = (if (Build.VERSION.SDK_INT >= 28) r.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_FRAME_COUNT)?.toIntOrNull() else null) ?: 0
    val fps: Double = if (count > 0 && durationS > 0) count / durationS else 30.0
    private val cache = LruCache<Int, Bitmap>(30)
    private val exec = Executors.newSingleThreadExecutor()
    @Volatile private var pending = -1

    private fun scale(b: Bitmap?): Bitmap? {
        if (b == null) return null
        val k = maxSide.toFloat() / max(b.width, b.height)
        if (maxSide <= 0 || k >= 1) return b
        val s = Bitmap.createScaledBitmap(b, max(1, (b.width * k).toInt()), max(1, (b.height * k).toInt()), true)
        if (s !== b) b.recycle()
        return s
    }

    private fun decode(idx: Int, n: Int) {
        val last = if (count > 0) count - 1 else Int.MAX_VALUE
        if (Build.VERSION.SDK_INT >= 28 && count > 0) {
            val k = min(n, last - idx + 1).coerceAtLeast(1)
            runCatching { r.getFramesAtIndex(idx.coerceIn(0, last), k) }.getOrNull()?.forEachIndexed { i, b -> scale(b)?.let { cache.put(idx + i, it) } }
                ?: runCatching { scale(r.getFrameAtTime((idx / fps * 1e6).toLong(), MediaMetadataRetriever.OPTION_CLOSEST))?.let { cache.put(idx, it) } }
        } else runCatching { scale(r.getFrameAtTime((idx / fps * 1e6).toLong(), MediaMetadataRetriever.OPTION_CLOSEST))?.let { cache.put(idx, it) } }
    }

    fun index(t: Double) = (t.coerceIn(0.0, max(0.0, durationS - 0.001)) * fps).toInt()

    /** Çizim için kare (hazır değilse en yakın hazır kare; arka planda hazırlanır) */
    fun frame(t: Double, playing: Boolean): Bitmap? {
        val idx = index(t)
        cache.get(idx)?.let { if (playing) prefetch(idx + 1, 8); return it }
        prefetch(idx, if (playing) 8 else 1)
        // Yakındaki bir kare (titremesin diye)
        for (d in 1..12) { cache.get(idx - d)?.let { return it }; cache.get(idx + d)?.let { return it } }
        return null
    }

    private fun prefetch(idx: Int, n: Int) {
        if (cache.get(idx) != null && cache.get(min(idx + n - 1, idx + 3)) != null) return
        if (pending == idx) return
        pending = idx
        exec.execute { if (pending == idx) { decode(idx, n); onFrame() } }
    }

    /** Dışa aktarma: tam o kare (beklenir) */
    fun frameSync(t: Double): Bitmap? {
        val idx = index(t)
        cache.get(idx)?.let { return it }
        decode(idx, 6)
        return cache.get(idx)
    }

    fun release() { exec.shutdownNow(); runCatching { r.release() } }
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
            val off = max(0.0, t - l.start); val wait = max(0.0, l.start - t)
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
                val src = (i - s0) * k; val j = src.toInt(); if (j + 1 >= pcm.frames) break
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
