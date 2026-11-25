package com.warden.motion.app

import android.graphics.Bitmap
import android.graphics.Canvas
import androidx.compose.ui.graphics.asAndroidBitmap
import androidx.compose.ui.test.captureToImage
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onRoot
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.onAllNodesWithText
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.onNodeWithContentDescription
import androidx.compose.ui.test.performTouchInput
import androidx.compose.ui.test.click
import androidx.test.core.app.ApplicationProvider
import com.warden.motion.app.data.Store
import com.warden.motion.app.model.*
import com.warden.motion.app.render.Renderer
import com.warden.motion.app.model.TEMPLATES
import kotlinx.coroutines.runBlocking
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import java.io.File

/** Ekran görüntüleri: native/shots klasörüne PNG olarak */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [33], qualifiers = "w393dp-h852dp-xxhdpi")
class ShotsTest {
    @get:Rule val rule = createAndroidComposeRule<MainActivity>()
    private val dir = File(System.getProperty("shots.dir") ?: "shots").apply { mkdirs() }
    private fun save(b: Bitmap, name: String) = File(dir, "$name.png").outputStream().use { b.compress(Bitmap.CompressFormat.PNG, 100, it) }

    private fun sample(): Project {
        val p = newProject("Deneme Projesi", 720, 900, 30, "#FFFFFF")
        val a = { v: Double -> Anim(v) }
        return p.copy(layers = listOf(
            Layer(uid(), "Daire", "shape", 0.0, 3.0, x = a(220.0), y = a(260.0), w = 260.0, h = 260.0, fill = "#22D3C5", shape = "circle"),
            Layer(uid(), "Yıldız", "shape", 0.0, 3.0, x = Anim(500.0, listOf(Key(0.0, 500.0), Key(2.0, 300.0))), y = a(300.0), w = 240.0, h = 240.0, fill = "#F2C94C", shape = "star"),
            Layer(uid(), "Hilal", "shape", 0.0, 3.0, x = a(360.0), y = a(560.0), w = 220.0, h = 220.0, fill = "#E2342D", shape = "crescent", rotation = a(-20.0)),
            Layer(uid(), "Metin", "text", 0.0, 3.0, x = a(360.0), y = a(800.0), w = 500.0, h = 100.0, fill = "#0D1631", text = "Warden Motion: Glow", fontSize = 56.0),
            Layer(uid(), "Kalp", "shape", 0.0, 3.0, x = a(150.0), y = a(620.0), w = 160.0, h = 150.0, fill = "#8F7CF0", fill2 = "#FF5BA7", grad = Grad(-0.5, -0.5, 0.5, 0.5), shape = "heart"),
        ))
    }

    /** Pencerenin tamamını çizer (Robolectric'te captureToImage yerine) */
    private fun shot(): Bitmap {
        val v = rule.activity.window.decorView
        val b = Bitmap.createBitmap(v.width, v.height, Bitmap.Config.ARGB_8888)
        rule.runOnUiThread { v.draw(Canvas(b)) }
        return b
    }

    private fun androidx.compose.ui.test.junit4.AndroidComposeTestRule<*, *>.onNodeWithContentDescriptionCompat(d: String) {
        // + düğmesinin yazısı yok: sağ alttaki turkuaz düğmeye dokun
        val v = activity.window.decorView
        onRoot().performTouchInput { click(androidx.compose.ui.geometry.Offset(width - 60f * density, height - 70f * density)) }
        v.hashCode(); d.hashCode()
    }

    @Test fun home() {
        val ctx = ApplicationProvider.getApplicationContext<android.content.Context>()
        val store = Store.get(ctx)
        runBlocking { store.save(sample()); store.save(newProject("Boş Proje", 1080, 1920, 60, "#0B1430")) }
        fun settle() { repeat(4) { rule.mainClock.advanceTimeBy(400); rule.waitForIdle(); Thread.sleep(150) } }
        rule.mainClock.autoAdvance = false
        settle(); save(shot(), "home")
        rule.onNodeWithText("Öğreticiler").performClick(); settle(); save(shot(), "tut")
        rule.onAllNodesWithText("Hesap")[0].performClick(); settle(); save(shot(), "acc")
        rule.onAllNodesWithText("Ana Sayfa")[0].performClick(); settle()
        rule.onAllNodesWithText("Yeni Proje Oluştur")[0].performClick(); settle(); save(shot(), "new")
    }

    @Test fun editor() {
        val ctx = ApplicationProvider.getApplicationContext<android.content.Context>()
        val store = Store.get(ctx)
        var p = TEMPLATES[1].make()
        // CB gövdesi + bayrak (maske) + şekil
        val (body, _) = cbBodyLayers(p, 0.0, 3.0, "yumusak-top", "flags/tr.svg", "Türkiye")
        p = p.copy(layers = p.layers + body.map { it.copy(x = if (it.parent == null) Anim(200.0) else it.x, y = if (it.parent == null) Anim(650.0) else it.y) } +
            makeLayer(p, 0.0, 3.0, "shape", "Yıldız") { it.copy(shape = "star", fill = "#F2C94C", x = Anim(560.0, listOf(Key(0.0, 560.0), Key(2.0, 400.0))), y = Anim(700.0), w = 160.0, h = 160.0) })
        runBlocking { store.save(p) }
        fun settle() { repeat(5) { rule.mainClock.advanceTimeBy(400); rule.waitForIdle(); Thread.sleep(200) } }
        rule.mainClock.autoAdvance = false
        settle()
        rule.onAllNodesWithText("CB Selam")[1].performClick(); settle(); save(shot(), "ed_open")
        rule.onAllNodesWithText("Yıldız")[0].performClick(); settle(); save(shot(), "ed_sel")
        rule.onAllNodesWithText("Taşı ve Çevir")[0].performClick(); settle(); save(shot(), "ed_move")
    }

    @Test fun addTabs() {
        val ctx = ApplicationProvider.getApplicationContext<android.content.Context>()
        runBlocking { Store.get(ctx).save(newProject("Boş", 720, 900, 30, "#FFFFFF")) }
        fun settle() { repeat(5) { rule.mainClock.advanceTimeBy(400); rule.waitForIdle(); Thread.sleep(200) } }
        rule.mainClock.autoAdvance = false
        settle()
        rule.runOnUiThread { com.warden.motion.app.ui.Assistant.stop(true) }; settle()
        rule.onAllNodesWithText("Boş")[0].performClick(); settle()
        rule.onNodeWithContentDescription("Katman ekle").performClick(); settle()
        for (tab in listOf("Şekil", "Medya", "Ses", "CB", "Bayrak")) { rule.onAllNodesWithText(tab)[0].performClick(); settle(); save(shot(), "add_" + tab.replace("Ş","S")) }
    }

    @Test fun assistant() {
        fun settle(n: Int = 5) { repeat(n) { rule.mainClock.advanceTimeBy(400); rule.waitForIdle(); Thread.sleep(150) } }
        rule.mainClock.autoAdvance = false
        settle(8); save(shot(), "wa_1")
        rule.onAllNodesWithText("Geç")[0].performClick(); settle(); save(shot(), "wa_2")
        // Öğretici: Temel Animasyon
        com.warden.motion.app.ui.openTutorial("g1"); settle(10); save(shot(), "wa_3")
        rule.onAllNodesWithText("Anlamadım")[0].performClick(); settle(12); save(shot(), "wa_4")
        settle(12); save(shot(), "wa_5")
    }

    @Test fun importOld() {
        val ctx = ApplicationProvider.getApplicationContext<android.content.Context>()
        val store = Store.get(ctx)
        // Eski uygulamanın yedek biçimi: projeler + media (data URL)
        val png = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8DwHwAFBQIAX8jx0gAAAABJRU5ErkJggg=="
        val json = "{\"app\":\"warden-motion\",\"v\":1,\"projects\":[{\"id\":\"abc\",\"name\":\"Eski Proje\",\"width\":720,\"height\":900,\"fps\":30,\"background\":\"#FFFFFF\",\"updatedAt\":1,\"layers\":[{\"id\":\"l1\",\"name\":\"G\",\"type\":\"image\",\"start\":0,\"end\":2,\"x\":{\"v\":360},\"y\":{\"v\":450},\"scale\":{\"v\":1},\"rotation\":{\"v\":0},\"opacity\":{\"v\":1},\"w\":300,\"h\":300,\"fill\":\"#000\",\"src\":\"media:m1\",\"effects\":[{\"id\":\"e\",\"type\":\"blur\",\"amount\":4,\"v\":{\"amount\":{\"v\":4}}}],\"unknownField\":5}]}],\"media\":{\"m1\":\"$png\"},\"pack\":{\"index\":[],\"folders\":[]},\"flags\":[]}"
        val f = File(ctx.cacheDir, "yedek.json").apply { writeText(json) }
        val r = runBlocking { store.importBackup(android.net.Uri.fromFile(f)) }
        org.junit.Assert.assertEquals(1, r.projects)
        org.junit.Assert.assertEquals(1, r.media)
        org.junit.Assert.assertTrue(store.mediaFile("m1").length() > 0)
        org.junit.Assert.assertEquals("Eski Proje", store.projects.value.first { it.id == "abc" }.name)
    }

    @Test fun fx() {
        val ctx = ApplicationProvider.getApplicationContext<android.content.Context>()
        val r = Renderer(ctx, sync = true)
        var p = newProject("Efekt", 900, 600, 30, "#FFFFFF")
        fun sh(name: String, x: Double, y: Double, fx: List<Effect>, color: String = "#2F7BF6", xa: Anim? = null) = makeLayer(p, 0.0, 3.0, "shape", name) { it.copy(shape = "star", fill = color, x = xa ?: Anim(x), y = Anim(y), w = 150.0, h = 150.0, effects = fx) }
        fun e(type: String, vararg kv: Pair<String, Double>) = makeEffect(type).let { ef -> ef.copy(v = (ef.v ?: emptyMap()) + kv.associate { it.first to Anim(it.second) }, amount = kv.toMap()["amount"] ?: ef.amount) }
        p = p.copy(layers = listOf(
            sh("blur", 120.0, 120.0, listOf(e("blur", "amount" to 10.0))),
            sh("glow", 330.0, 120.0, listOf(e("glow", "amount" to 18.0))),
            sh("shadow", 540.0, 120.0, listOf(e("shadow", "amount" to 18.0))),
            sh("gray", 750.0, 120.0, listOf(e("grayscale")), "#E2342D"),
            sh("hue", 120.0, 400.0, listOf(e("hue", "amount" to 120.0)), "#E2342D"),
            sh("mb", 0.0, 400.0, listOf(e("motionblur", "tune" to 2.0)), xa = Anim(250.0, listOf(Key(0.0, 250.0), Key(1.0, 550.0)))),
            sh("frac", 750.0, 400.0, listOf(e("fractal", "mag" to 0.15))),
        ))
        val b = Bitmap.createBitmap(900, 600, Bitmap.Config.ARGB_8888)
        r.exporting = true
        r.draw(Canvas(b), p, 0.5, 1f); save(b, "fx")
    }

    @Test fun gif() {
        val ctx = ApplicationProvider.getApplicationContext<android.content.Context>()
        val p = TEMPLATES[0].make()
        File(dir, "top.gif").outputStream().use { com.warden.motion.app.export.Exporter(ctx).gif(p, it, 240, 10) { } }
    }

    @Test fun frame() {
        val ctx = ApplicationProvider.getApplicationContext<android.content.Context>()
        val r = Renderer(ctx)
        val p = sample()
        val b = Bitmap.createBitmap(720, 900, Bitmap.Config.ARGB_8888)
        for (t in listOf(0.0, 1.0)) { r.draw(Canvas(b), p, t, 1f) ; save(b, "frame_$t") }
    }

    @Test fun cmp() {
        val ctx = ApplicationProvider.getApplicationContext<android.content.Context>()
        runBlocking { Store.get(ctx).save(TEMPLATES[1].make()) }
        fun settle() { repeat(5) { rule.mainClock.advanceTimeBy(400); rule.waitForIdle(); Thread.sleep(200) } }
        rule.mainClock.autoAdvance = false
        settle(); rule.runOnUiThread { com.warden.motion.app.ui.Assistant.stop(true) }; settle()
        rule.onAllNodesWithText("CB Selam")[1].performClick(); settle(); save(shot(), "n_ed_open")
        val back = { rule.onNodeWithContentDescription("Geri").performClick(); settle() }
        rule.onAllNodesWithText("Türkiyeball")[0].performClick(); settle(); save(shot(), "n_ed_sel")
        for (t in listOf("Taşı ve Çevir", "Karıştırma ve Opaklık", "Efektler", "CB Ayarları")) { rule.onAllNodesWithText(t)[0].performClick(); settle(); save(shot(), "n_p_" + t.split(" ")[0].replace("ş","s").replace("ı","i")); back() }
        rule.onNodeWithContentDescription("Diğer").performClick(); settle(); save(shot(), "n_menu")
        rule.onNodeWithContentDescription("Diğer").performClick(); settle()
        rule.onNodeWithContentDescription("Seçimi kaldır").performClick(); settle()
        rule.onAllNodesWithText("Selam")[0].performClick(); settle(); save(shot(), "n_txt_sel")
        for (t in listOf("Renk ve Dolgu", "Metni Düzenle")) { rule.onAllNodesWithText(t)[0].performClick(); settle(); save(shot(), "n_p_" + t.split(" ")[0].replace("ş","s").replace("ı","i")); back() }
    }

    @Test fun flags() {
        val ctx = ApplicationProvider.getApplicationContext<android.content.Context>()
        val out = File(dir, "flags").apply { mkdirs() }
        for (f in ctx.assets.list("flags")!!.filter { it.endsWith(".svg") }) {
            val svg = ctx.assets.open("flags/$f").use { com.caverock.androidsvg.SVG.getFromInputStream(it) }
            val b = Bitmap.createBitmap(160, 120, Bitmap.Config.ARGB_8888)
            svg.setDocumentWidth("100%"); svg.setDocumentHeight("100%")
            svg.renderToCanvas(Canvas(b), android.graphics.RectF(0f, 0f, 160f, 120f))
            File(out, f.removeSuffix(".svg") + ".png").outputStream().use { b.compress(Bitmap.CompressFormat.PNG, 100, it) }
        }
    }
}
