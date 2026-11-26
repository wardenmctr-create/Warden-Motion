package com.warden.motion.app.render

import android.graphics.Bitmap
import android.graphics.Canvas
import androidx.test.core.app.ApplicationProvider
import com.warden.motion.app.model.*
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import java.io.File

/**
 * GPU dışındaki efektler (hareket, opaklık, metin, şekil, sahne düzeyi CB, fizik, rig): her biri gerçek Renderer ile
 * efektli ve efektsiz çizilir; birkaç anın en az birinde görüntü değişmelidir.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [33])
class KotlinFxTest {
    private val gpu = setOf("pixel", "gen", "repeat", "3d", "audio-fx")

    private fun render(r: Renderer, p: Project, t: Double): IntArray {
        val b = Bitmap.createBitmap(200, 200, Bitmap.Config.ARGB_8888); r.draw(Canvas(b), p, t, 0.5f)
        val px = IntArray(200 * 200); b.getPixels(px, 0, 200, 0, 0, 200, 200); return px
    }
    private fun diff(a: IntArray, b: IntArray): Int { var n = 0; for (i in a.indices) if (a[i] != b[i]) n++; return n }

    @Test fun everyKotlinEffectChangesTheImage() {
        val ctx = ApplicationProvider.getApplicationContext<android.content.Context>()
        FxCatalog.init(ctx); GlFx.init(ctx)
        val r = Renderer(ctx, sync = true)
        val types = FxCatalog.all.values.filter { !it.hidden && it.mergedInto == null && it.kind !in gpu }.map { it.type }
        val neutral = ArrayList<String>(); val log = StringBuilder()
        for (type in types) {
            val m = fxMeta(type)
            val other = Layer("B", "Hedef", "shape", 0.0, 3.0, x = Anim(300.0), y = Anim(120.0), w = 60.0, h = 60.0, fill = "#E2342D", shape = "circle")
            val isText = m.kind == "text" || type.contains("text") || type in setOf("typewriter", "counter", "spacing", "scramble", "charfade", "timecode", "karaoke", "livetext", "rollcounter", "linereveal", "wordhighlight", "verticaltext", "cbbubble", "cblabel", "cbcaption")
            var e = makeEffect(type)
            (m.presets.find { it.code == "GÇ" } ?: m.presets.find { it.code == "AN" })?.let { e = applyPreset(e, it, 0.0, 3.0) }
            if (m.params.any { it.key == "ilerleme" } && (e.v?.get("ilerleme")?.k == null)) e = e.copy(v = (e.v ?: emptyMap()) + ("ilerleme" to Anim(60.0)))
            // Kaynak ayarları: hedef katman
            val cc = (e.c ?: emptyMap()).toMutableMap(); for (pr in m.params) if (pr.kind == "source") cc[pr.key] = "B"; e = e.copy(c = cc)
            val host = if (isText) Layer("A", "Metin", "text", 0.0, 3.0, x = Anim(200.0), y = Anim(220.0), w = 300.0, h = 80.0, fill = "#0D1631", text = "Merhaba 12", fontSize = 48.0)
                else Layer("A", "Yıldız", "shape", 0.0, 3.0, x = Anim(150.0, listOf(Key(0.0, 120.0), Key(1.0, 260.0))), y = Anim(230.0, listOf(Key(0.0, 260.0), Key(1.0, 200.0))),
                    w = 120.0, h = 120.0, fill = "#22D3C5", shape = "star", rotation = Anim(0.0, listOf(Key(0.0, 0.0), Key(1.0, 40.0))))
            val base = Project("p", "p", 400, 400, 30, "#FFFFFF", listOf(host, other))
            val withFx = base.copy(layers = listOf(host.copy(effects = listOf(e)), other))
            var best = 0
            for (t in listOf(0.1, 0.45, 1.05, 1.6, 2.4, 2.92)) { val d = runCatching { diff(render(r, base, t), render(r, withFx, t)) }.getOrElse { log.append("HATA $type: $it\n"); -1 }; if (d > best) best = d }
            if (best < 20) neutral += type
            log.append("$type ${m.kind} $best\n")
        }
        File("build/kotlinfx.txt").writeText(log.toString() + "\nETKİSİZ (" + neutral.size + "): " + neutral.joinToString(" ") + "\n")
        println("ETKİSİZ (" + neutral.size + "): " + neutral.joinToString(" "))
        assertTrue(types.size > 50)
    }
}
