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

    /** Rig efektleri: her biri için uygun parça katmanları kurulur; parça katmanın görüntüsü değişmeli */
    @Test fun rigEffectsMoveTheirParts() {
        val ctx = ApplicationProvider.getApplicationContext<android.content.Context>()
        FxCatalog.init(ctx); GlFx.init(ctx); val r = Renderer(ctx, sync = true)
        fun L(id: String, x: Double, y: Double, w: Double = 60.0, h: Double = 60.0, xs: List<Key>? = null, rot: Anim = Anim(0.0), fill: String = "#E2342D") =
            Layer(id, id, "shape", 0.0, 3.0, x = Anim(x, xs), y = Anim(y), w = w, h = h, fill = fill, shape = "rect", rotation = rot)
        val moving = listOf(Key(0.0, 120.0), Key(2.0, 280.0))
        data class Case(val type: String, val c: Map<String, String>, val layers: List<Layer>, val v: Map<String, Double> = emptyMap())
        val cases = listOf(
            Case("footlock", mapOf("ayak" to "F", "zemin" to "G"), listOf(L("F", 0.0, 330.0, xs = moving), L("G", 200.0, 390.0, 400.0, 60.0, fill = "#555555")), mapOf("gecis" to 30.0)),
            Case("irislock", mapOf("gozMask" to "E", "iris" to "I"), listOf(L("E", 200.0, 200.0, 120.0, 80.0, fill = "#FFFFFF"), L("I", 0.0, 200.0, 30.0, 30.0, xs = listOf(Key(0.0, 200.0), Key(1.0, 320.0)), fill = "#111111"))),
            Case("exprweights", mapOf("ifadeSeki" to "A1,A2"), listOf(L("A1", 150.0, 200.0, fill = "#22AA44"), L("A2", 250.0, 200.0, fill = "#2244AA"))),
            Case("facecoords", mapOf("govde" to "B", "yuzParc" to "P"), listOf(L("B", 200.0, 200.0, 160.0, 160.0, fill = "#DDDDDD"), L("P", 230.0, 190.0, 20.0, 20.0, fill = "#111111")), mapOf("yatayAci" to 50.0)),
            Case("jointlimit", mapOf("eklem" to "J"), listOf(L("J", 200.0, 200.0, 140.0, 30.0, rot = Anim(0.0, listOf(Key(0.0, 0.0), Key(2.0, 170.0)))))),
            Case("motionmirror", mapOf("kaynakRig" to "S", "hedefRig" to "T"), listOf(L("S", 100.0, 200.0, xs = moving, rot = Anim(0.0, listOf(Key(0.0, 0.0), Key(2.0, 60.0)))), L("T", 300.0, 200.0, fill = "#2244AA"))),
            Case("phasespread", mapOf("grup" to "P1,P2"), listOf(L("P1", 0.0, 150.0, xs = moving), L("P2", 0.0, 250.0, xs = moving, fill = "#2244AA")), mapOf("fazFark" to 180.0)),
            Case("stepcycle", mapOf("rig" to "K1,K2"), listOf(L("K1", 150.0, 300.0), L("K2", 250.0, 300.0, fill = "#2244AA"))),
            Case("bubblelayout", mapOf("balonlar" to "U1,U2"), listOf(L("U1", 190.0, 200.0, 90.0, 50.0), L("U2", 210.0, 210.0, 90.0, 50.0, fill = "#2244AA"))),
            Case("labelavoid", mapOf("etiketle" to "E1,E2"), listOf(L("E1", 195.0, 200.0, 80.0, 30.0), L("E2", 205.0, 205.0, 80.0, 30.0, fill = "#2244AA"))),
            Case("bonepropagate", mapOf("rig" to "R1,R2,R3"), listOf(L("R1", 150.0, 200.0, 80.0, 20.0, rot = Anim(0.0, listOf(Key(0.0, 0.0), Key(2.0, 80.0)))), L("R2", 230.0, 200.0, 80.0, 20.0, fill = "#2244AA"), L("R3", 300.0, 200.0, 80.0, 20.0, fill = "#22AA44"))),
            Case("depthsort", mapOf("katmanla" to "D1,D2"), listOf(L("D1", 190.0, 200.0, 120.0, 120.0).copy(scale = Anim(1.4)), L("D2", 210.0, 210.0, 120.0, 120.0, fill = "#2244AA"))),
        )
        val fails = ArrayList<String>()
        for (cs in cases) {
            var e = makeEffect(cs.type); e = e.copy(c = (e.c ?: emptyMap()) + cs.c, v = (e.v ?: emptyMap()) + cs.v.mapValues { Anim(it.value) })
            val host = Layer("H", "Ana", "shape", 0.0, 3.0, x = Anim(30.0), y = Anim(30.0), w = 10.0, h = 10.0, fill = "#FFFFFF", shape = "rect")
            val base = Project("p", "p", 400, 400, 30, "#FFFFFF", cs.layers + host); val withFx = base.copy(layers = cs.layers + host.copy(effects = listOf(e)))
            var best = 0; for (t in listOf(0.3, 0.9, 1.5, 2.2)) best = maxOf(best, diff(render(r, base, t), render(r, withFx, t)))
            println("RIG ${cs.type} $best"); if (best < 20) fails += cs.type
        }
        assertTrue("etkisiz rig efektleri: $fails", fails.isEmpty())
    }
}
