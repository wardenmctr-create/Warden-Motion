package com.warden.motion.app.export

import java.io.OutputStream

/**
 * Basit GIF89a yazıcı: sabit 6×7×6 renk küpü (252 renk) + Floyd–Steinberg renk dağıtma, LZW sıkıştırma, sonsuz döngü.
 */
class GifWriter(private val out: OutputStream, private val w: Int, private val h: Int, private val delayCs: Int) {
    private val pal = IntArray(256).also { p ->
        var i = 0
        for (r in 0 until 6) for (g in 0 until 7) for (b in 0 until 6) p[i++] = ((r * 255 / 5) shl 16) or ((g * 255 / 6) shl 8) or (b * 255 / 5)
        while (i < 256) p[i++] = 0
    }

    init {
        out.write("GIF89a".toByteArray())
        le(w); le(h)
        out.write(0xF7) // genel renk tablosu, 256 renk
        out.write(0); out.write(0)
        for (c in pal) { out.write((c shr 16) and 255); out.write((c shr 8) and 255); out.write(c and 255) }
        // NETSCAPE döngü
        out.write(byteArrayOf(0x21, 0xFF.toByte(), 0x0B)); out.write("NETSCAPE2.0".toByteArray()); out.write(byteArrayOf(3, 1, 0, 0, 0))
    }

    private fun le(v: Int) { out.write(v and 255); out.write((v shr 8) and 255) }

    private fun nearest(r: Int, g: Int, b: Int): Int {
        val ri = ((r * 5 + 127) / 255).coerceIn(0, 5); val gi = ((g * 6 + 127) / 255).coerceIn(0, 6); val bi = ((b * 5 + 127) / 255).coerceIn(0, 5)
        return ri * 42 + gi * 6 + bi
    }

    fun frame(px: IntArray) {
        val idx = ByteArray(w * h)
        val er = IntArray(w + 2); val eg = IntArray(w + 2); val eb = IntArray(w + 2)
        val nr = IntArray(w + 2); val ng = IntArray(w + 2); val nb = IntArray(w + 2)
        for (y in 0 until h) {
            java.util.Arrays.fill(nr, 0); java.util.Arrays.fill(ng, 0); java.util.Arrays.fill(nb, 0)
            for (x in 0 until w) {
                val c = px[y * w + x]
                val r = (((c shr 16) and 255) + er[x + 1] / 16).coerceIn(0, 255)
                val g = (((c shr 8) and 255) + eg[x + 1] / 16).coerceIn(0, 255)
                val b = ((c and 255) + eb[x + 1] / 16).coerceIn(0, 255)
                val k = nearest(r, g, b); idx[y * w + x] = k.toByte()
                val p = pal[k]
                val dr = r - ((p shr 16) and 255); val dg = g - ((p shr 8) and 255); val db = b - (p and 255)
                er[x + 2] += dr * 7; eg[x + 2] += dg * 7; eb[x + 2] += db * 7
                nr[x] += dr * 3; ng[x] += dg * 3; nb[x] += db * 3
                nr[x + 1] += dr * 5; ng[x + 1] += dg * 5; nb[x + 1] += db * 5
                nr[x + 2] += dr; ng[x + 2] += dg; nb[x + 2] += db
            }
            System.arraycopy(nr, 0, er, 0, w + 2); System.arraycopy(ng, 0, eg, 0, w + 2); System.arraycopy(nb, 0, eb, 0, w + 2)
        }
        // Grafik kontrol (gecikme)
        out.write(byteArrayOf(0x21, 0xF9.toByte(), 4, 0)); le(delayCs); out.write(0); out.write(0)
        // Görüntü
        out.write(0x2C); le(0); le(0); le(w); le(h); out.write(0)
        lzw(idx)
    }

    private fun lzw(data: ByteArray) {
        val minCode = 8
        out.write(minCode)
        val clear = 1 shl minCode; val eoi = clear + 1
        var codeSize = minCode + 1
        val dict = HashMap<Long, Int>(8192)
        var next = eoi + 1
        val blk = ByteArray(255); var bn = 0
        var acc = 0L; var nbits = 0
        fun emit(code: Int) {
            acc = acc or (code.toLong() shl nbits); nbits += codeSize
            while (nbits >= 8) { blk[bn++] = (acc and 255).toByte(); acc = acc ushr 8; nbits -= 8; if (bn == 255) { out.write(255); out.write(blk, 0, 255); bn = 0 } }
        }
        emit(clear)
        var prefix = data[0].toInt() and 255
        for (i in 1 until data.size) {
            val c = data[i].toInt() and 255
            val key = (prefix.toLong() shl 8) or c.toLong()
            val found = dict[key]
            if (found != null) { prefix = found; continue }
            emit(prefix)
            // Çözücüyle aynı kural: tablo 2^codeSize'a ulaşınca kod bir bit büyür
            if (next < 4096) { if (next >= (1 shl codeSize) && codeSize < 12) codeSize++; dict[key] = next++ }
            else { emit(clear); dict.clear(); next = eoi + 1; codeSize = minCode + 1 }
            prefix = c
        }
        emit(prefix); emit(eoi)
        if (nbits > 0) { blk[bn++] = (acc and 255).toByte(); if (bn == 255) { out.write(255); out.write(blk, 0, 255); bn = 0 } }
        if (bn > 0) { out.write(bn); out.write(blk, 0, bn) }
        out.write(0)
    }

    fun finish() { out.write(0x3B); out.flush() }
}
