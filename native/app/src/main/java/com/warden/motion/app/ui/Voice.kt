package com.warden.motion.app.ui

import android.content.Context
import android.media.AudioAttributes
import android.media.SoundPool
import java.io.File
import java.nio.ByteBuffer
import java.nio.ByteOrder
import kotlin.math.exp
import kotlin.math.ln
import kotlin.math.sin

/**
 * WardenCB'nin konuşma sesi: yazı harf harf çıkarken kısa "blip"ler (oyunlardaki diyalog sesi gibi).
 * Eski uygulamadakiyle aynı: kare dalga, harfe göre hafif değişen perde (330 + 0..5 × 18 Hz), 55 ms.
 */
object Voice {
    private var pool: SoundPool? = null
    private val ids = IntArray(6)
    private var ready = 0
    private fun prefs(ctx: Context) = ctx.getSharedPreferences("wm-assist", Context.MODE_PRIVATE)
    fun on(ctx: Context) = prefs(ctx).getBoolean("voice", true)
    fun set(ctx: Context, v: Boolean) = prefs(ctx).edit().putBoolean("voice", v).apply()

    fun init(ctx: Context) {
        if (pool != null) return
        val p = SoundPool.Builder().setMaxStreams(4).setAudioAttributes(AudioAttributes.Builder().setUsage(AudioAttributes.USAGE_GAME).setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION).build()).build()
        pool = p
        p.setOnLoadCompleteListener { _, _, st -> if (st == 0) ready++ }
        val dir = File(ctx.cacheDir, "voice").apply { mkdirs() }
        for (i in 0 until 6) {
            val f = File(dir, "blip$i.wav")
            if (!f.exists()) f.writeBytes(wav(330.0 + i * 18))
            ids[i] = p.load(f.absolutePath, 1)
        }
    }

    /** Tek harf sesi (harf ve rakamlarda) */
    fun blip(ctx: Context, ch: Char) {
        if (!ch.isLetterOrDigit() || !on(ctx) || ready < 6) return
        val code = ch.lowercaseChar().code
        pool?.play(ids[code % 6], 1f, 1f, 1, 0, 1f)
    }

    /** 55 ms kare dalga, yumuşak açılıp kapanan, alçak geçiren süzgeçli (2400 Hz) */
    private fun wav(freq: Double): ByteArray {
        val rate = 22050; val n = (rate * 0.06).toInt()
        val pcm = ShortArray(n)
        val rc = 1.0 / (2 * Math.PI * 2400); val dt = 1.0 / rate; val a = dt / (rc + dt)
        var y = 0.0
        for (i in 0 until n) {
            val t = i.toDouble() / rate
            val sq = if (sin(2 * Math.PI * freq * t) >= 0) 1.0 else -1.0
            y += a * (sq - y)
            // 5 ms'de 0.05'e çık, 55 ms'de sön (üstel)
            val env = if (t < 0.005) 0.0001 * exp(ln(0.05 / 0.0001) * t / 0.005) else 0.05 * exp(ln(0.0001 / 0.05) * (t - 0.005) / 0.05)
            pcm[i] = (y * env * 3.2 * 32767).toInt().coerceIn(-32768, 32767).toShort()
        }
        val b = ByteBuffer.allocate(44 + n * 2).order(ByteOrder.LITTLE_ENDIAN)
        b.put("RIFF".toByteArray()); b.putInt(36 + n * 2); b.put("WAVE".toByteArray())
        b.put("fmt ".toByteArray()); b.putInt(16); b.putShort(1); b.putShort(1); b.putInt(rate); b.putInt(rate * 2); b.putShort(2); b.putShort(16)
        b.put("data".toByteArray()); b.putInt(n * 2)
        for (s in pcm) b.putShort(s)
        return b.array()
    }
}
