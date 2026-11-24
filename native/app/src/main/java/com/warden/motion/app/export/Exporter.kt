package com.warden.motion.app.export

import android.content.ContentValues
import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.media.MediaCodec
import android.media.MediaCodecInfo
import android.media.MediaFormat
import android.media.MediaMuxer
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import com.warden.motion.app.model.Project
import com.warden.motion.app.render.AudioDecode
import com.warden.motion.app.render.Renderer
import java.io.File
import java.io.OutputStream
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.util.zip.ZipEntry
import java.util.zip.ZipOutputStream
import kotlin.math.max
import kotlin.math.min
import kotlin.math.roundToInt

/** İlerleme: f 0..1, kalan süre (sn, bilinmiyorsa null) */
data class Progress(val f: Double, val eta: Double?)

/**
 * Dışa aktarma: kareler tam kalitede (asıl dosyalar, bütün efektler) çizilir,
 * telefonun donanım kodlayıcısıyla H.264 + AAC MP4'e yazılır.
 */
class Exporter(private val ctx: Context) {
    @Volatile var cancelled = false

    private fun renderer(fxQuality: Double) = Renderer(ctx, maxSide = 4096, sync = true, cacheMb = 96).apply { exporting = true; this.fxQuality = fxQuality }

    /** Kısa kenar = res (asıl oran korunur), çift sayılara yuvarlanır */
    fun size(p: Project, res: Int): Pair<Int, Int> {
        val k = res.toDouble() / min(p.width, p.height)
        val kk = if (res <= 0) 1.0 else k
        return ((p.width * kk / 2).roundToInt() * 2).coerceAtLeast(2) to ((p.height * kk / 2).roundToInt() * 2).coerceAtLeast(2)
    }

    fun video(p: Project, out: File, res: Int, fps: Int, fxQuality: Double, onProgress: (Progress) -> Unit) {
        val (W, H) = size(p, res)
        val dur = p.duration
        val frames = max(1, (dur * fps).roundToInt())
        val r = renderer(fxQuality)
        val enc = MediaCodec.createEncoderByType(MediaFormat.MIMETYPE_VIDEO_AVC)
        val vf = MediaFormat.createVideoFormat(MediaFormat.MIMETYPE_VIDEO_AVC, W, H).apply {
            setInteger(MediaFormat.KEY_COLOR_FORMAT, MediaCodecInfo.CodecCapabilities.COLOR_FormatYUV420Flexible)
            setInteger(MediaFormat.KEY_BIT_RATE, max(2_000_000, (W * H * fps * 0.15).toInt()))
            setInteger(MediaFormat.KEY_FRAME_RATE, fps)
            setInteger(MediaFormat.KEY_I_FRAME_INTERVAL, 2)
        }
        enc.configure(vf, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE)
        enc.start()
        // Ses: bütün sesler asıl kalitede karıştırılır
        val mix = runCatching { AudioDecode.mix(ctx, p, dur, 44100) }.getOrNull()
        val aenc = mix?.let {
            MediaCodec.createEncoderByType(MediaFormat.MIMETYPE_AUDIO_AAC).apply {
                configure(MediaFormat.createAudioFormat(MediaFormat.MIMETYPE_AUDIO_AAC, 44100, 2).apply {
                    setInteger(MediaFormat.KEY_AAC_PROFILE, MediaCodecInfo.CodecProfileLevel.AACObjectLC)
                    setInteger(MediaFormat.KEY_BIT_RATE, 160_000); setInteger(MediaFormat.KEY_MAX_INPUT_SIZE, 16384)
                }, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE)
                start()
            }
        }
        val mux = MediaMuxer(out.absolutePath, MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4)
        var vTrack = -1; var aTrack = -1; var started = false
        val pendingV = ArrayList<Pair<ByteBuffer, MediaCodec.BufferInfo>>(); val pendingA = ArrayList<Pair<ByteBuffer, MediaCodec.BufferInfo>>()
        fun tryStart() {
            if (started || vTrack < 0 || (aenc != null && aTrack < 0)) return
            mux.start(); started = true
            pendingV.forEach { mux.writeSampleData(vTrack, it.first, it.second) }; pendingV.clear()
            pendingA.forEach { mux.writeSampleData(aTrack, it.first, it.second) }; pendingA.clear()
        }
        val info = MediaCodec.BufferInfo()
        fun drain(c: MediaCodec, video: Boolean, end: Boolean) {
            while (true) {
                val oi = c.dequeueOutputBuffer(info, if (end) 10000 else 0)
                when {
                    oi == MediaCodec.INFO_TRY_AGAIN_LATER -> if (!end) return else continue
                    oi == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED -> { if (video) vTrack = mux.addTrack(c.outputFormat) else aTrack = mux.addTrack(c.outputFormat); tryStart() }
                    oi >= 0 -> {
                        val b = c.getOutputBuffer(oi)!!
                        if (info.flags and MediaCodec.BUFFER_FLAG_CODEC_CONFIG != 0) info.size = 0
                        if (info.size > 0) {
                            b.position(info.offset); b.limit(info.offset + info.size)
                            if (started) mux.writeSampleData(if (video) vTrack else aTrack, b, info)
                            else { val copy = ByteBuffer.allocateDirect(info.size); copy.put(b); copy.flip(); val bi = MediaCodec.BufferInfo().apply { set(0, info.size, info.presentationTimeUs, info.flags) }; (if (video) pendingV else pendingA) += copy to bi }
                        }
                        val eos = info.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0
                        c.releaseOutputBuffer(oi, false)
                        if (eos) return
                    }
                }
            }
        }
        // Ses önce kodlanır (küçük)
        if (aenc != null && mix != null) {
            var pos = 0; val total = mix.size / 2; var done = false
            while (!done) {
                val ii = aenc.dequeueInputBuffer(10000)
                if (ii >= 0) {
                    val buf = aenc.getInputBuffer(ii)!!.order(ByteOrder.LITTLE_ENDIAN)
                    val n = min(total - pos, buf.capacity() / 4)
                    if (n <= 0) { aenc.queueInputBuffer(ii, 0, 0, pos * 1_000_000L / 44100, MediaCodec.BUFFER_FLAG_END_OF_STREAM); done = true }
                    else {
                        for (i in 0 until n) { buf.putShort((mix[(pos + i) * 2] * 32767).toInt().toShort()); buf.putShort((mix[(pos + i) * 2 + 1] * 32767).toInt().toShort()) }
                        aenc.queueInputBuffer(ii, 0, n * 4, pos * 1_000_000L / 44100, 0); pos += n
                    }
                }
                drain(aenc, false, false)
            }
            drain(aenc, false, true)
        }
        // Kareler
        val bmp = Bitmap.createBitmap(W, H, Bitmap.Config.ARGB_8888)
        val cv = Canvas(bmp)
        val px = IntArray(W * H)
        val t0 = System.currentTimeMillis()
        for (i in 0..frames) {
            if (cancelled) break
            val last = i == frames
            var ii: Int
            do { ii = enc.dequeueInputBuffer(10000); drain(enc, true, false) } while (ii < 0 && !cancelled)
            if (ii < 0) break
            if (last) { enc.queueInputBuffer(ii, 0, 0, i * 1_000_000L / fps, MediaCodec.BUFFER_FLAG_END_OF_STREAM); break }
            bmp.eraseColor(0)
            r.draw(cv, p, min(i.toDouble() / fps, dur - 0.0001), W.toFloat() / p.width)
            bmp.getPixels(px, 0, W, 0, 0, W, H)
            val img = enc.getInputImage(ii)!!
            writeYuv(px, W, H, img)
            enc.queueInputBuffer(ii, 0, W * H * 3 / 2, i * 1_000_000L / fps, 0)
            drain(enc, true, false)
            if (i % 2 == 1) {
                val per = (System.currentTimeMillis() - t0) / 1000.0 / (i + 1)
                onProgress(Progress((i + 1).toDouble() / frames, if (i >= 4) per * (frames - i - 1) else null))
            }
        }
        drain(enc, true, true)
        runCatching { enc.stop() }; enc.release()
        aenc?.let { runCatching { it.stop() }; it.release() }
        if (started) runCatching { mux.stop() }
        mux.release()
        r.releaseVideos()
        bmp.recycle()
        if (cancelled) out.delete()
    }

    /** ARGB → YUV420 (kodlayıcının istediği düzlemlere) */
    private fun writeYuv(px: IntArray, w: Int, h: Int, img: android.media.Image) {
        val pl = img.planes
        val yb = pl[0].buffer; val ys = pl[0].rowStride; val yp = pl[0].pixelStride
        val ub = pl[1].buffer; val us = pl[1].rowStride; val up = pl[1].pixelStride
        val vb = pl[2].buffer; val vs = pl[2].rowStride; val vp = pl[2].pixelStride
        for (y in 0 until h) {
            val row = y * w
            for (x in 0 until w) {
                val c = px[row + x]; val r = (c shr 16) and 255; val g = (c shr 8) and 255; val b = c and 255
                yb.put(y * ys + x * yp, (((66 * r + 129 * g + 25 * b + 128) shr 8) + 16).toByte())
            }
        }
        for (y in 0 until h / 2) for (x in 0 until w / 2) {
            // 2×2 bloğun ortalaması
            var r = 0; var g = 0; var b = 0
            for (dy in 0..1) for (dx in 0..1) { val c = px[(y * 2 + dy) * w + x * 2 + dx]; r += (c shr 16) and 255; g += (c shr 8) and 255; b += c and 255 }
            r /= 4; g /= 4; b /= 4
            ub.put(y * us + x * up, (((-38 * r - 74 * g + 112 * b + 128) shr 8) + 128).toByte())
            vb.put(y * vs + x * vp, (((112 * r - 94 * g - 18 * b + 128) shr 8) + 128).toByte())
        }
    }

    /** Geçerli kare PNG */
    fun png(p: Project, t: Double, res: Int): Bitmap {
        val (W, H) = size(p, res)
        val b = Bitmap.createBitmap(W, H, Bitmap.Config.ARGB_8888)
        val r = renderer(1.0)
        r.draw(Canvas(b), p, t, W.toFloat() / p.width)
        r.releaseVideos()
        return b
    }

    /** Görüntü dizisi: her kare ayrı PNG, tek ZIP dosyasında */
    fun sequence(p: Project, out: OutputStream, res: Int, fps: Int, onProgress: (Progress) -> Unit) {
        val (W, H) = size(p, res)
        val frames = max(1, (p.duration * fps).roundToInt())
        val r = renderer(0.6)
        val b = Bitmap.createBitmap(W, H, Bitmap.Config.ARGB_8888); val cv = Canvas(b)
        ZipOutputStream(out).use { z ->
            for (i in 0 until frames) {
                if (cancelled) break
                b.eraseColor(0)
                r.draw(cv, p, min(i.toDouble() / fps, p.duration - 0.0001), W.toFloat() / p.width)
                z.putNextEntry(ZipEntry("kare_%05d.png".format(i)))
                b.compress(Bitmap.CompressFormat.PNG, 100, z)
                z.closeEntry()
                onProgress(Progress((i + 1).toDouble() / frames, null))
            }
        }
        r.releaseVideos()
    }

    /** GIF (en fazla 256 renk, titreşimli renk dağıtma) */
    fun gif(p: Project, out: OutputStream, res: Int, fps: Int, onProgress: (Progress) -> Unit) {
        val (W, H) = size(p, res)
        val frames = max(1, (p.duration * fps).roundToInt())
        val r = renderer(0.4)
        val b = Bitmap.createBitmap(W, H, Bitmap.Config.ARGB_8888); val cv = Canvas(b)
        val g = GifWriter(out, W, H, (100.0 / fps).roundToInt())
        val px = IntArray(W * H)
        for (i in 0 until frames) {
            if (cancelled) break
            b.eraseColor(android.graphics.Color.parseColor(p.background.takeIf { it.startsWith("#") } ?: "#FFFFFF"))
            r.draw(cv, p, min(i.toDouble() / fps, p.duration - 0.0001), W.toFloat() / p.width)
            b.getPixels(px, 0, W, 0, 0, W, H)
            g.frame(px)
            onProgress(Progress((i + 1).toDouble() / frames, null))
        }
        g.finish()
        r.releaseVideos()
    }

    companion object {
        /** Dosyayı Galeri'ye (Filmler/Resimler) kaydeder, adresini döndürür */
        fun saveToGallery(ctx: Context, src: File, name: String, mime: String): Uri? {
            val video = mime.startsWith("video/")
            val cv = ContentValues().apply {
                put(MediaStore.MediaColumns.DISPLAY_NAME, name); put(MediaStore.MediaColumns.MIME_TYPE, mime)
                if (Build.VERSION.SDK_INT >= 29) put(MediaStore.MediaColumns.RELATIVE_PATH, (if (video) Environment.DIRECTORY_MOVIES else Environment.DIRECTORY_PICTURES) + "/Warden Motion")
            }
            val coll = if (video) MediaStore.Video.Media.EXTERNAL_CONTENT_URI else MediaStore.Images.Media.EXTERNAL_CONTENT_URI
            val uri = runCatching { ctx.contentResolver.insert(coll, cv) }.getOrNull() ?: return null
            ctx.contentResolver.openOutputStream(uri)?.use { o -> src.inputStream().use { it.copyTo(o) } }
            return uri
        }
    }
}
