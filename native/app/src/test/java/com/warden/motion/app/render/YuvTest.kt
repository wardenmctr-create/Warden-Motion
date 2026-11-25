package com.warden.motion.app.render

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

/** Video karesi çevirisi: renk ve dikey video döndürmesi */
class YuvTest {
    // 4×2 kaynak: sol yarı kırmızı, sağ yarı mavi (NV12 gibi: U/V iç içe, pixelStride 2)
    private val sw = 4; private val sh = 2
    private fun yuv(r: Int, g: Int, b: Int) = Triple(
        (16 + (65.738 * r + 129.057 * g + 25.064 * b) / 256).toInt(),
        (128 + (-37.945 * r - 74.494 * g + 112.439 * b) / 256).toInt(),
        (128 + (112.439 * r - 94.154 * g - 18.285 * b) / 256).toInt())
    private val red = yuv(255, 0, 0); private val blue = yuv(0, 0, 255)
    private val Y = ByteArray(sw * sh) { i -> (if (i % sw < 2) red.first else blue.first).toByte() }
    private val UV = ByteArray(sw) { i -> val c = if (i / 2 < 1) red else blue; (if (i % 2 == 0) c.second else c.third).toByte() }
    private val V = UV.copyOfRange(1, UV.size)

    private fun isRed(p: Int) = (p shr 16 and 255) > 200 && (p and 255) < 60
    private fun isBlue(p: Int) = (p and 255) > 200 && (p shr 16 and 255) < 60

    @Test fun colorsAndRotation() {
        val o0 = yuvToArgb(Y, sw, 1, UV, sw, 2, V, sw, 2, 0, 0, sw, sh, 0, 4, 2)
        assertTrue("sol kırmızı ${Integer.toHexString(o0[0])}", isRed(o0[0])); assertTrue("sağ mavi ${Integer.toHexString(o0[3])}", isBlue(o0[3]))
        // 90° (telefonla dikey çekilmiş): 2×4 çıktı, kaynağın solu üste gelir
        val o90 = yuvToArgb(Y, sw, 1, UV, sw, 2, V, sw, 2, 0, 0, sw, sh, 90, 2, 4)
        assertEquals(8, o90.size)
        assertTrue("90: üst kırmızı", isRed(o90[0]) && isRed(o90[1])); assertTrue("90: alt mavi", isBlue(o90[6]) && isBlue(o90[7]))
        val o270 = yuvToArgb(Y, sw, 1, UV, sw, 2, V, sw, 2, 0, 0, sw, sh, 270, 2, 4)
        assertTrue("270: üst mavi", isBlue(o270[0])); assertTrue("270: alt kırmızı", isRed(o270[7]))
        val o180 = yuvToArgb(Y, sw, 1, UV, sw, 2, V, sw, 2, 0, 0, sw, sh, 180, 4, 2)
        assertTrue("180: sol mavi", isBlue(o180[0])); assertTrue("180: sağ kırmızı", isRed(o180[3]))
        // Küçültme: 2×1
        val small = yuvToArgb(Y, sw, 1, UV, sw, 2, V, sw, 2, 0, 0, sw, sh, 0, 2, 1)
        assertTrue(isRed(small[0]) && isBlue(small[1]))
    }
}
