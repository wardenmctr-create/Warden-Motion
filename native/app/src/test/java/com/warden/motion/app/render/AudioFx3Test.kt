package com.warden.motion.app.render

import androidx.test.core.app.ApplicationProvider
import com.warden.motion.app.model.*
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import kotlin.math.*

/** 1000 rehberi ses işlemcileri: sentetik stereo sinyalde çıktı sonlu ve sinyalden farklı olmalı */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [33])
class AudioFx3Test {
    @Test fun processorsChangeTheSignal() {
        FxCatalog.init(ApplicationProvider.getApplicationContext())
        val rate = 22050; val n = rate * 2
        // sol: 220 Hz + 0.6 sn sonra darbeler; sağ: aynı ton, 3 ms gecikmeli ve hafif farklı karışım; 1.2–1.6 sn arası sessiz
        val src = FloatArray(n * 2) { k -> val i = k / 2; val c = k % 2; val t = (i - if (c == 1) 66 else 0).toDouble() / rate
            if (i in (rate * 1.2).toInt() until (rate * 1.6).toInt()) (0.003 * sin(i * 1.7)).toFloat() else (0.4 * sin(2 * PI * 220 * t) + 0.2 * sin(2 * PI * 330 * t) * (if (c == 0) 1.0 else 0.3) + (if (i % (rate / 4) < 40) 0.6 else 0.0)).toFloat() }
        val fails = ArrayList<String>()
        for (type in AudioFx3.TYPES) {
            if (type == "parallelchain" || type == "specmatch" || type == "jlcut") continue // başka katman gerektirir
            var e = makeEffect(type); if (type == "silencegap") e = e.copy(v = (e.v ?: emptyMap()) + ("yalnizAnal" to Anim(0.0)))
            val l = Layer("A", "ses", "audio", 0.0, 2.0, effects = listOf(e)); val buf = src.copyOf()
            AudioFx.apply(l, buf, rate)
            var diff = 0.0; var finite = true; var eo = 0.0; var ei = 0.0; for (i in buf.indices) { if (!buf[i].isFinite()) finite = false; diff += abs(buf[i] - src[i]); eo += buf[i] * buf[i]; ei += src[i] * src[i] }
            println("SES $type fark=${"%.2f".format(diff)} enerji=${"%.2f".format(eo / ei)} sonlu=$finite"); if (!finite || diff < 1.0 || eo / ei < 0.005) fails += type
        }
        assertTrue("etkisiz/bozuk ses işlemcileri: $fails", fails.isEmpty())
    }
}
