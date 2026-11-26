package com.warden.motion.app.ui

import android.content.Context
import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.PathEffect
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.layout.onSizeChanged
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.warden.motion.app.model.*
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import kotlin.math.abs
import kotlin.math.hypot
import kotlin.math.max
import kotlin.math.min

const val APP_VERSION = "0.20"
private const val VER = "g0.3"

// ---------------------------------------------------------------------------------------------
// Senaryolar
// ---------------------------------------------------------------------------------------------
data class Goal(
    val screen: String? = null, val tutorial: String? = null, val clean: Boolean = false, val add: String? = null,
    val sel: ((Layer) -> Boolean)? = null, val selName: String? = null, val panel: String? = null, val fxb: Boolean = false,
    val choice: String? = null, val time0: Boolean = false, val noPanel: Boolean = false,
)
data class Choice(val label: String, val act: () -> Unit)
class Step(
    val say: String, val mood: String = "idle", val need: Goal? = null, val target: (() -> String?)? = null,
    val done: (() -> Boolean)? = null, val btn: String? = null, val choices: List<Choice>? = null, val end: Boolean = false,
    val auto: (suspend (Hand) -> Unit)? = null,
)
class Script(val id: String, val title: String, val steps: List<Step>, val pid: String? = null)
/** Asistanın gösterdiği yol: hedef düğme, söz, yüz; act: "Anlamadım" deyince kendisi yapacağı */
data class WHint(val target: String?, val say: String, val mood: String = "point", val recover: Boolean = true, val act: (() -> Unit)? = null)

/** Asistanın eli: ekranda dokunur, sürükler */
interface Hand { suspend fun tap(id: String, act: (() -> Unit)? = null); suspend fun drag(from: Offset, to: Offset, ms: Int = 900, onMove: (Float) -> Unit); suspend fun wait(ms: Long) }

object Assistant {
    var run by mutableStateOf<Run?>(null)
    var min by mutableStateOf(false)
    data class Run(val script: Script, val step: Int, val pid: String?, val demo: Boolean)
    lateinit var ctx: Context
    private val prefs get() = ctx.getSharedPreferences("wm-assist", Context.MODE_PRIVATE)
    var pendingDemo: String? = null

    fun start(s: Script, step: Int = 0, demo: Boolean = false) { run = Run(s, min(step, s.steps.size - 1), s.pid, demo); min = false }
    fun go(step: Int) {
        val r = run ?: return
        if (step >= r.script.steps.size) { stop(true); return }
        r.pid?.let { prefs.edit().putInt("tut:$it", step).apply() }
        run = r.copy(step = max(0, step))
    }
    fun stop(finished: Boolean = false) {
        val r = run
        if (r != null) {
            val e = prefs.edit()
            if (r.script.id == "intro") e.putBoolean("intro", true).putString("ver", VER)
            if (r.script.id == "whatsnew") e.putString("ver", VER)
            if (r.script.id == "editor") e.putBoolean("editor", true)
            r.pid?.let { e.putInt("tut:$it", if (finished) 999 else r.step) }
            e.apply()
        }
        run = null; min = false
    }
    fun replayIntro() { prefs.edit().putBoolean("editor", false).apply(); start(introScript()) }
    fun tutAt(pid: String) = prefs.getInt("tut:$pid", 0)
    fun introSeen() = prefs.getBoolean("intro", false)
    fun ver() = prefs.getString("ver", null)
    fun markVer() = prefs.edit().putString("ver", VER).apply()
}

private val ed get() = UiState.editor
private fun layers() = ed?.project?.layers ?: emptyList()
private fun isCircle(l: Layer) = l.type == "shape" && l.shape == "circle"
private fun isCBLine(l: Layer) = l.parent == null && Regex("govdeler/.*-cizgi").containsMatchIn(l.src ?: "")
private val finish = { Assistant.stop(true) }

fun openTutorial(id: String) {
    val tu = TUTORIALS.find { it.id == id } ?: return
    finish()
    UiState.openNew(newProject(tu.title, tu.w, tu.h, 30, tu.bg).copy(tutorial = tu.id))
}
private fun tourEditor() {
    finish()
    if (UiState.screen != "editor") UiState.openNew(newProject("Deneme Projesi", 720, 900, 30, "#FFFFFF"))
    Assistant.start(Script("editor", "Editör turu", EDITOR_TOUR()))
}
private fun pickTutorial() = Step("Hangisini yapalım? İkisinde de her adımda nereye basacağını göstereceğim.", "excited", choices =
    TUTORIALS.filter { it.ready }.map { t -> Choice("${t.title} (${t.kind})") { openTutorial(t.id) } } + Choice("Şimdilik yeter", finish))
private fun whatNow(inEditor: Boolean) = Step("Şimdi ne yapalım?", "curious", choices =
    (if (inEditor) emptyList() else listOf(Choice("Proje arayüzünü tanıt") { tourEditor() })) +
        Choice("Bir öğretici proje yapalım") { Assistant.run?.let { Assistant.go(it.step + 1) } } + Choice("Şimdilik yeter", finish))

private val HOME = Goal(screen = "home")
private fun INTRO() = listOf(
    Step("Selam! Ben WardenCB, Warden Motion'ın asistanıyım. Sana uygulamayı gezdireceğim; öğreticilerde de nereye basacağını ben göstereceğim.", "wave", HOME),
    Step("Yeni bir proje buradan açılır: oranı, çözünürlüğü ve kare hızını seçersin.", need = HOME, target = { "new-card" }),
    Step("Hazır şablonlar burada. Birine dokun, açılsın, istediğin gibi değiştir.", need = HOME, target = { "tpl-row" }),
    Step("Projelerin burada saklanır, hepsi bu cihazda kalır.", need = HOME, target = { if (Targets.has("pcard-first")) "pcard-first" else "empty" }),
    Step("Adım adım öğreticiler burada: 3 CB, 5 genel animasyon. Onlarda da ben yanındayım.", need = HOME, target = { "nav-tut" }),
    Step("Ayarlar burada: zayıf telefonlar için Lite modu ve beni tekrar çağırmak için \"WardenCB ile tanış\".", need = HOME, target = { "menu-btn" }),
)
/** Uygulamanın yenilikleri (tanışmada) */
private val NEWS = listOf(
    Step("Warden Motion baştan sona telefonun kendi diliyle yazıldı. Çok daha hızlı, galeri ve sesler doğrudan telefondan geliyor.", "excited"),
    Step("Eski Warden Motion'daki projelerini getirmek için: eski uygulamada Hesap → \"Şimdi yedekle\", sonra burada Hesap → \"Yedek dosyası seç\".", "happy", target = { "nav-acc" }),
    Step("Dışa Aktar ekranı da yenilendi: Video (MP4 + ses), Proje Paketi, PNG kare, Görüntü Dizisi ve GIF.", "proud"),
)
/** Bu güncellemenin yenilikleri */
private val UPDATE = listOf(
    Step("Artık adım sadece Warden Motion, yeni simgemle birlikte!", "proud"),
    Step("Ben de canlandım: göz kırpıyorum, gösterdiğim yere bakıyorum. Yazım hızlandı ve konuşurken sesim var; sesi kartımdaki 🔊 düğmesiyle kapatabilirsin.", "joy"),
    Step("Şeritlerdeki kırpma tutamaçları artık şeridin dışında, iki yanda ‹ › olarak duruyor.", "point"),
    Step("Ses ve videoyu baştan kırpınca ya da bölünce ses kaldığı yerden devam ediyor; şerit sesin uzunluğunu geçmiyor. Süresi yanlış okunmuş eski ses şeritleri sesin tamamına uzatıldı.", "happy"),
    Step("Metni Düzenle ve CB Ayarları eskisi gibi alttan açılan sayfa oldu; Lite ayarlarındaki kare hızı ve görsel boyutu artık gerçekten uygulanıyor.", "think"),
)
fun introScript() = Script("intro", "Tanışma", INTRO() + NEWS + listOf(whatNow(false), pickTutorial()))

private fun EDITOR_TOUR() = listOf(
    Step("Burası editör! Önizlemede katmanları parmağınla sürükle; iki parmakla büyüt ve döndür.", "wave", Goal(screen = "editor"), target = { "stage" }),
    Step("Oynat / duraklat. Yanındakiler başa ve sona gider.", need = Goal(screen = "editor"), target = { "play" }),
    Step("Zaman çizelgesi: kaydırınca kare kare ilerler, iki parmakla yakınlaştırırsın. Ortadaki çizgi o anki kare.", need = Goal(screen = "editor"), target = { "tl" }),
    Step("Katman eklemek için +: şekil, medya, ses, metin, CB araçları ve bayraklar.", need = Goal(clean = true), target = { "fab" }),
    Step("Bir katmanı seçince altta araçlar çıkar: Taşı ve Çevir, Efektler… ◆+ ile keyframe eklersin, ◆− ile silersin.", "think", Goal(screen = "editor"), target = { "tl" }),
    Step("Bitince videonu buradan dışa aktar.", "joy", Goal(clean = true), target = { "export" }),
    Step("Seçili katmanda köşelerdeki noktalardan tutup büyütürsün; kenarlardan şekilleri genişletir, görselleri kırparsın. Uygulamanın şekillerinde turkuaz tutamaçlar ve \"Şekli Düzenle\" ayarları da var.", "think", target = { "stage" }),
    whatNow(true), pickTutorial(),
)

private fun startDemo(id: String) {
    val tu = TUTORIALS.find { it.id == id } ?: return
    finish()
    val p = newProject("${tu.title} (WardenCB gösteriyor)", tu.w, tu.h, 30, tu.bg).copy(tutorial = tu.id)
    Assistant.pendingDemo = p.id
    UiState.openNew(p)
}
private fun jump(d: Int): () -> Unit = { Assistant.run?.let { Assistant.go(it.step + d) } }
private fun tutEnd(id: String, say: String, sg: Boolean = false): List<Step> = if (!sg) listOf(
    Step(say, "joy", choices = listOf(Choice("Anladım", finish), Choice("Anlamadım") { startDemo(id) })),
) else listOf(
    Step(say, "joy", choices = listOf(Choice("Anlamadım") { startDemo(id) }, Choice("Tamam sg", jump(1)))),
    Step("\"sg\" derken \"sonra görüşürüz\" mü demek istedin?", "suspicious", choices = listOf(Choice("Evet", jump(1)), Choice("Hayır", jump(2)))),
    Step("Haa tamam! Sonraki projede görüşürüz.", "happy", btn = "Görüşürüz", end = true),
    Step("Şerefsiz!", "furious", btn = "Pardon", end = true),
)
private fun tips(t: List<String>) = t.mapIndexed { i, s -> Step("Taktik ${i + 1}: $s", "smug") }

/** Proje noktasını ekran noktasına çevirir */
private fun projToScreen(x: Double, y: Double): Offset {
    val r = Targets.rect("stage") ?: return Offset.Zero
    val p = ed?.project ?: return Offset.Zero
    return Offset(r.left + (x / p.width * r.width).toFloat(), r.top + (y / p.height * r.height).toFloat())
}

private fun TUT_G1(): List<Step> {
    val g = { panel: String? -> Goal(tutorial = "g1", sel = ::isCircle, selName = "Daire", panel = panel, noPanel = panel == null) }
    return listOf(
        Step("Temel Animasyon'a hoş geldin! Önce bir daire ekleyelim: \"Daire\"ye dokun.", "wave", Goal(tutorial = "g1", add = "Şekil"), target = { "cell:Daire" }, done = { layers().any(::isCircle) }),
        Step("Daire geldi! Şimdi alttan \"Taşı ve Çevir\"e dokun.", need = g(null), target = { "tbig:Taşı ve Çevir" }, done = { UiState.panel == "Taşı ve Çevir" }),
        Step("Zaman en başta. Elmas + düğmesine bas: ilk keyframe buraya konur.", need = Goal(tutorial = "g1", sel = ::isCircle, selName = "Daire", panel = "Taşı ve Çevir", time0 = true), target = { "kf-btn" },
            done = { layers().any { isCircle(it) && !it.x.k.isNullOrEmpty() } }),
        Step("Şimdi zaman çizelgesini parmağınla sola kaydır ve yaklaşık 1. saniyeye git.", need = g("Taşı ve Çevir"), target = { "tl" }, done = { (ed?.time ?: 0.0) >= 0.5 },
            auto = { h -> val r = Targets.rect("tl") ?: return@Step; val y = r.top + r.height * .6f; h.drag(Offset(r.left + r.width * .75f, y), Offset(r.left + r.width * .25f, y), 1100) { k -> ed?.time = Math.round(k * 30) / 30.0 } }),
        Step("Daireyi önizlemede başka bir yere sürükle. İkinci keyframe kendiliğinden oluşur.", "excited", g("Taşı ve Çevir"), target = { "stage" },
            done = { layers().any { isCircle(it) && ((it.x.k?.size ?: 0) >= 2 || (it.y.k?.size ?: 0) >= 2) } },
            auto = { h ->
                val s = ed ?: return@Step; val l = layers().firstOrNull(::isCircle) ?: return@Step; val t = s.time; val p = s.project
                val x0 = l.x.at(t); val y0 = l.y.at(t); val x1 = x0 + p.width * .25; val y1 = y0 - p.height * .15
                s.checkpoint()
                h.drag(projToScreen(x0, y0), projToScreen(x1, y1), 900) { k -> s.updateLayer(l.id, false) { it.copy(x = it.x.set(t, Math.round(x0 + (x1 - x0) * k).toDouble()), y = it.y.set(t, Math.round(y0 + (y1 - y0) * k).toDouble())) } }
            }),
        Step("Süper! Şimdi ▶ ile oynat ve izle.", need = Goal(tutorial = "g1"), target = { "play" }, done = { ed?.playing == true }),
        Step("Tebrikler, ilk animasyonun hazır!", "proud"),
    )
}

private fun TUT_CB1(): List<Step> {
    val line = { panel: String? -> Goal(tutorial = "cb1", sel = ::isCBLine, selName = "CB Çizgi", panel = panel, noPanel = panel == null) }
    return listOf(
        Step("Temel CB'ye hoş geldin! İlk countryball'unu yapacağız. Bayrak sekmesinden bir ülke seç.", "wave", Goal(tutorial = "cb1", add = "Bayrak"), target = { "flags-grid" },
            done = { Targets.has("choice:Yumuşak CB olarak ekle") || layers().any(::isCBLine) }, auto = { h -> h.tap("flag:tr") }),
        Step("\"Yumuşak CB olarak ekle\"ye dokun: çizgi, beyaz iç, içe kırpılmış bayrak ve gözler kurulur.", need = Goal(tutorial = "cb1", add = "Bayrak", choice = "Yumuşak"),
            target = { if (Targets.has("choice:Yumuşak CB olarak ekle")) "choice:Yumuşak CB olarak ekle" else "flags-grid" }, done = { layers().any(::isCBLine) }),
        Step("CB hazır! Çizgi katmanı seçili: onu taşıyınca hepsi birlikte gider. Önizlemede biraz sürükleyip dene.", "happy", target = { "stage" }),
        Step("Şimdi şapka: CB sekmesinde \"Şapkalar\" klasörüne dokun.", need = Goal(tutorial = "cb1", add = "CB"), target = { "chip:Şapkalar" },
            done = { PackUi.folder == "Şapkalar" || layers().any { Regex("sapkalar/").containsMatchIn(it.src ?: "") } }),
        Step("İstediğin şapkayı seç. Ushanka seçersen arka kulağı CB'nin arkasına kendisi geçer.", need = Goal(tutorial = "cb1", add = "CB"), target = { "pack-grid" },
            done = { layers().any { Regex("sapkalar/").containsMatchIn(it.src ?: "") } }, auto = { h -> h.tap("pack:Ushanka") }),
        Step("Şapkayı önizlemede CB'nin başına sürükle. Boyut için Taşı ve Çevir → Ölçek.", target = { "stage" },
            auto = { h ->
                val s = ed ?: return@Step
                val hat = layers().firstOrNull { it.parent == null && Regex("sapkalar/").containsMatchIn(it.src ?: "") } ?: return@Step
                val cb = layers().firstOrNull(::isCBLine) ?: return@Step
                val t = s.time; val x0 = hat.x.at(t); val y0 = hat.y.at(t); val x1 = cb.x.at(t); val y1 = cb.y.at(t) - cb.h * .42
                s.selectedId = hat.id; s.checkpoint()
                h.drag(projToScreen(x0, y0), projToScreen(x1, y1), 900) { k -> s.updateLayer(hat.id, false) { it.copy(x = it.x.set(t, Math.round(x0 + (x1 - x0) * k).toDouble()), y = it.y.set(t, Math.round(y0 + (y1 - y0) * k).toDouble())) } }
            }),
        Step("Biraz hareket katalım: CB'nin çizgisi seçiliyken alttan \"Efektler\"e dokun.", need = line(null), target = { "tbig:Efektler" }, done = { UiState.panel == "Efektler" }),
        Step("\"Efekt Ekle\"ye dokun.", need = line("Efektler"), target = { "addfx" }, done = { UiState.fxb || layers().any { isCBLine(it) && it.effects.any { e -> e.type == "sway" } } }),
        Step("\"Oto-Sallanma\"yı seç: CB hafifçe sağa sola sallanır.", need = line("Efektler").copy(fxb = true), target = { "fxb:Oto-Sallanma" }, done = { layers().any { isCBLine(it) && it.effects.any { e -> e.type == "sway" } } }),
        Step("Şimdi ▶ ile oynat!", need = Goal(tutorial = "cb1"), target = { "play" }, done = { ed?.playing == true }),
        Step("Harika! Beğendiysen sağ üstteki düğmeyle videonu dışa aktar.", "proud", Goal(tutorial = "cb1", clean = true), target = { "export" }),
    )
}

fun buildTut(id: String, pid: String): Script? {
    if (id.startsWith("fx:")) return fxTeachScript(id.removePrefix("fx:"), pid)
    val tu = TUTORIALS.find { it.id == id } ?: return null
    return when (id) {
        "g1" -> Script("tut:g1", tu.title, TUT_G1() + tips(tu.tips) + tutEnd("g1", "Öğretici bitti! Anladın mı? Anlamadıysan bütün projeyi ben baştan yapıp anlatayım."), pid)
        "cb1" -> Script("tut:cb1", tu.title, TUT_CB1() + tips(tu.tips) + tutEnd("cb1", "Öğretici bitti! Anladın mı? Anlamadıysan bütün projeyi ben baştan yapıp anlatayım.", true), pid)
        else -> null
    }
}

/** CB sekmesindeki seçili klasör (asistan okur) */
object PackUi { var folder by mutableStateOf("Tümü") }

// ---------------------------------------------------------------------------------------------
// Yol bulma: kullanıcı yanlış yerdeyse önce oradan çıkış yolunu gösterir
// ---------------------------------------------------------------------------------------------
private fun H(t: String?, say: String, mood: String = "point", recover: Boolean = true, act: (() -> Unit)? = null) = WHint(t, say, mood, recover, act)

private fun closeTop(keep: Goal = Goal()): WHint? {
    if (Targets.rects.keys.any { it.startsWith("choice:") } && keep.choice == null) return H("choice:Vazgeç", "Önce bu pencereyi kapatalım: \"Vazgeç\"e dokun.", "think")
    if (UiState.fxb && !keep.fxb) return H("fxb-close", "Efekt tarayıcısından çıkalım: soldaki düğmeye dokun.", "think")
    if (UiState.menu) return H(if (ed?.sel != null) "more" else "projmenu", "Açık menüyü kapatmak için aynı düğmeye tekrar dokun.", "think")
    if (UiState.multi) return H("multi-close", "Çoklu seçimdesin. Önce çoklu seçimi bitir.", "think")
    return null
}

fun route(g: Goal): WHint? {
    val needEditor = g.screen == "editor" || g.tutorial != null || g.clean || g.add != null || g.sel != null || g.panel != null || g.fxb || g.time0
    if (UiState.screen != "editor") {
        if (UiState.drawer) return H("drawer", "Ayarlar menüsü açık. Menünün dışına (sağdaki boşluğa) dokunup kapat.", "think")
        if (UiState.sheet && !(g.screen == "home" && !needEditor)) return H("sheet-close", "Yeni proje penceresini kapatalım.", "think")
        if (g.screen == "tutorials" && UiState.screen != "tutorials") return H("nav-tut", "Alttaki \"Öğreticiler\"e dokun.", "point", false)
        if (g.screen == "home" && UiState.screen != "home") return H("nav-home", "Ana sayfaya dön: alttaki \"Ana Sayfa\"ya dokun.")
        if (needEditor) {
            if (g.tutorial != null) {
                val pid = Assistant.run?.pid
                if (UiState.screen != "home") return H("nav-home", "Öğretici projen ana sayfada duruyor. \"Ana Sayfa\"ya dokun.")
                if (pid != null && Targets.has("pcard:$pid")) return H("pcard:$pid", "Öğreticiden çıktın. Devam etmek için projeye geri dön: buraya dokun.", "worried")
                return H(null, "Öğretici projesi bulunamadı. Öğreticiler'den yeniden başlatabilirsin.", "sad")
            }
            return H("new-card", "Önce bir proje açalım.", "point", false)
        }
        return null
    }
    val s = ed ?: return null
    val sel = s.sel
    if (g.screen == "home" || g.screen == "tutorials") {
        closeTop()?.let { return it }
        if (UiState.panel != null && UiState.panel != "add") return H("back", "Bu panelden çıkalım: sol üstteki geri okuna dokun.", "think")
        if (UiState.panel == "add") return H("add-close", "Ekleme kartını kapat.", "think")
        if (sel != null) return H("desel", "Önce katmanın seçimini kaldır: sol üstteki ok.", "think")
        return H("exit", "Projeden çıkalım: sol üstteki çıkış düğmesi.")
    }
    if (g.tutorial != null && s.project.tutorial != g.tutorial) return H(if (Targets.has("exit")) "exit" else if (Targets.has("desel")) "desel" else "back", "Başka bir projedesin. Öğreticiye dönmek için önce buradan çık.", "worried")
    closeTop(g)?.let { return it }
    if (g.add != null) {
        if (UiState.panel == "add") return if (UiState.addTab != g.add) H("atab:${g.add}", "Üstten \"${g.add}\" sekmesine dokun.", "point", false) else null
        if (UiState.panel != null) return H("back", "Önce bu panelden çık.", "think")
        if (sel != null) return H("desel", "Önce seçimi kaldır (sol üstteki ok), sonra + ile ekleriz.", "point", false)
        return H("fab", "Sağ alttaki + düğmesine dokun.", "point", false)
    }
    if (g.clean) {
        if (UiState.panel == "add") return H("add-close", "Ekleme kartını kapat.", "think")
        if (UiState.panel != null) return H("back", "Önce bu panelden çık.", "think")
        if (sel != null) return H("desel", "Önce katmanın seçimini kaldır: sol üstteki ok.", "think")
    }
    if (g.sel != null) {
        val ok = sel != null && g.sel.invoke(sel)
        if (!ok) {
            if (UiState.panel == "add") return H("add-close", "Ekleme kartını kapat.", "think")
            if (sel != null && UiState.panel != null) return H("back", "Yanlış katmandasın. Önce panelden çık.", "think")
            if (sel != null) return H("desel", "Şu an \"${sel.name}\" seçili. Önce seçimi kaldır (sol üstteki ok).", "point", false)
            val l = s.project.layers.reversed().firstOrNull(g.sel) ?: return H("undo", "Gereken katman silinmiş gibi. Geri al ile geri getir.", "worried")
            return H("pill:${l.id}", "\"${g.selName ?: l.name}\" katmanını seç: buna dokun.", "point", false) { s.selectedId = l.id }
        }
    }
    if (g.panel != null && UiState.panel != g.panel) {
        if (UiState.panel == "add") return H("add-close", "Ekleme kartını kapat.", "think")
        if (UiState.panel != null) return H("back", "Burası \"${UiState.panel}\". Geri çıkıp \"${g.panel}\"ı açalım.", "think")
        return H("tbig:${g.panel}", "Alttan \"${g.panel}\"a dokun.", "point", false)
    }
    if (g.noPanel && UiState.panel != null) {
        if (UiState.panel == "add") return H("add-close", "Ekleme kartını kapat.", "think")
        return H("back", "Yanlış yere girdin: burası \"${UiState.panel}\". Önce sol üstteki geri okuyla çık.", "worried")
    }
    if (g.fxb && !UiState.fxb) return H("addfx", "\"Efekt Ekle\"ye dokun.", "point", false)
    if (g.time0 && Math.round(s.time * 1000) != 0L) return H("toStart", "Önce zamanı en başa al: bu düğme.", "point", false)
    return null
}

// ---------------------------------------------------------------------------------------------
// Görünüm: konuşma kartı, halka, ok, el ve WardenCB
// ---------------------------------------------------------------------------------------------
@Composable
fun AssistantLayer() {
    val ctx = LocalContext.current
    Assistant.ctx = ctx.applicationContext
    val run = Assistant.run
    val dens = LocalDensity.current.density
    // Otomatik başlatma: ilk açılışta tanışma, güncellemede yenilikler, öğretici projesinde öğretici
    val ed0 = UiState.editor
    LaunchedEffect(UiState.screen, ed0?.project?.id, run == null) {
        val p = UiState.editor?.project
        if (UiState.screen == "editor" && p?.tutorial != null) {
            if (Assistant.run?.pid == p.id) return@LaunchedEffect
            val at = Assistant.tutAt(p.id)
            val demo = Assistant.pendingDemo == p.id
            if (at >= 999 && !demo) return@LaunchedEffect
            val sc = buildTut(p.tutorial, p.id) ?: return@LaunchedEffect
            if (demo) Assistant.pendingDemo = null
            Assistant.start(sc, if (demo) 0 else at, demo)
            return@LaunchedEffect
        }
        if (Assistant.run != null) return@LaunchedEffect
        delay(700)
        if (Assistant.run != null || UiState.screen != "home") return@LaunchedEffect
        if (!Assistant.introSeen()) Assistant.start(introScript())
        else if (Assistant.ver() != VER) Assistant.start(Script("whatsnew", "Yeni neler var", listOf(Step("Selam! Uygulama güncellendi, yenilikleri anlatayım.", "wave")) + UPDATE + Step("Bu kadar, iyi eğlenceler!", "happy", btn = "Bitir")))
    }
    if (run == null) return
    if (Assistant.min) {
        Box(Modifier.fillMaxSize()) {
            Box(Modifier.align(Alignment.CenterStart).padding(start = 6.dp).size(66.dp, 58.dp).shadow(8.dp, RoundedCornerShape(20.dp)).clip(RoundedCornerShape(20.dp)).background(C.dPanel2).border(1.5.dp, Color(0xFF2C6FD8), RoundedCornerShape(20.dp)).tap { Assistant.min = false }, contentAlignment = Alignment.Center) {
                WardenCBImg("idle", 54.dp)
            }
        }
        return
    }
    val step = run.script.steps[run.step]
    // Adımın durumu (120 ms'de bir okunur)
    var hint by remember(run.script, run.step) { mutableStateOf<WHint?>(null) }
    var tgt by remember(run.script, run.step) { mutableStateOf<String?>(null) }
    LaunchedEffect(run.script, run.step) {
        var doneAt = 0L
        while (isActive) {
            val st = step
            if (st.done?.invoke() == true) {
                if (doneAt == 0L) doneAt = System.currentTimeMillis() else if (System.currentTimeMillis() - doneAt > 350) { Assistant.go(run.step + 1); break }
            } else doneAt = 0
            val h = st.need?.let { route(it) }
            hint = h
            tgt = if (h != null) h.target else st.target?.invoke()
            delay(120)
        }
    }
    val rect = tgt?.let { Targets.rects[it] }
    val say = if (hint?.recover == true) hint!!.say else step.say
    val sub = if (hint != null && !hint!!.recover) hint!!.say else ""
    val mood = hint?.mood ?: if (rect != null && step.mood == "idle") "point" else step.mood
    // Yazı harf harf
    val full = say + if (sub.isNotEmpty()) "\n$sub" else ""
    var shown by remember(full) { mutableIntStateOf(0) }
    // Zamana göre ilerler (telefon yavaşlasa bile yazı yavaşlamaz); her iki harfte bir ses
    LaunchedEffect(full) {
        Voice.init(ctx)
        val t0 = withFrameMillis { it }
        while (shown < full.length) {
            val now = withFrameMillis { it }
            val n = minOf(full.length, ((now - t0) / 20).toInt() + 1)
            for (i in shown until n) if (i % 2 == 0) Voice.blip(ctx, full[i])
            shown = n
        }
    }
    var voiceOn by remember { mutableStateOf(Voice.on(ctx)) }

    // El (gösterim / Anlamadım)
    var handPos by remember { mutableStateOf<Offset?>(null) }
    var press by remember { mutableStateOf(false) }
    var autoReq by remember(run.script, run.step) { mutableStateOf(false) }
    val hand = remember {
        object : Hand {
            override suspend fun wait(ms: Long) = delay(ms)
            override suspend fun tap(id: String, act: (() -> Unit)?) {
                val r = Targets.rect(id) ?: return
                handPos = r.center; delay(650); press = true; delay(170)
                (act ?: { Targets.tap(id) })(); press = false; delay(260)
            }
            override suspend fun drag(from: Offset, to: Offset, ms: Int, onMove: (Float) -> Unit) {
                handPos = from; delay(650); press = true
                val a = Animatable(0f)
                a.animateTo(1f, tween(ms, easing = FastOutSlowInEasing)) { handPos = Offset(from.x + (to.x - from.x) * value, from.y + (to.y - from.y) * value); onMove(value) }
                press = false; ed?.checkpoint(); delay(250)
            }
        }
    }
    LaunchedEffect(run.script, run.step, run.demo, autoReq) {
        if (!(run.demo || autoReq)) { handPos = null; return@LaunchedEffect }
        if (step.choices != null) { Assistant.run = run.copy(demo = false); return@LaunchedEffect }
        delay(if (run.demo) min(4200L, 700L + step.say.length * 30L) else 250L)
        for (i in 0 until 14) {
            if (step.done?.invoke() == true) break
            val h = step.need?.let { route(it) }
            if (h != null) { if (h.target != null) hand.tap(h.target, h.act) else delay(500); delay(400); continue }
            if (step.auto != null) { step.auto.invoke(hand); delay(500); if (step.done == null) break; continue }
            val t = step.target?.invoke()
            if (step.done != null && t != null) { hand.tap(t); delay(500); continue }
            break
        }
        handPos = null
        if (step.done == null && run.demo) { delay(700); Assistant.go(run.step + 1) }
    }

    BoxWithConstraints(Modifier.fillMaxSize()) {
        val vw = constraints.maxWidth.toFloat(); val vh = constraints.maxHeight.toFloat()
        var cardH by remember { mutableIntStateOf((150 * dens).toInt()) }
        val warnC = Color(0xFFF2C230); val ringC = Color(0xFF22D3E6)
        val inf = rememberInfiniteTransition(label = "wa")
        val pulse by inf.animateFloat(0f, 1f, infiniteRepeatable(tween(650), RepeatMode.Reverse), label = "p")
        val dash by inf.animateFloat(0f, 16f, infiniteRepeatable(tween(700, easing = androidx.compose.animation.core.LinearEasing)), label = "d")
        val bob by inf.animateFloat(-3f, 3f, infiniteRepeatable(tween(1300), RepeatMode.Reverse), label = "b")
        val editorScreen = UiState.screen == "editor"
        val cw = min(380 * dens, vw - 20 * dens)
        val topY = (if (editorScreen) 58 else 66) * dens + 24 * dens
        val botY = vh - cardH - (if (editorScreen) 14 else 78) * dens
        fun overlap(y: Float) = if (rect == null) 0f else max(0f, min(y + cardH, rect.bottom) - max(y, rect.top))
        val atTop = rect != null && (if (overlap(topY) == overlap(botY)) rect.center.y > vh / 2 else overlap(topY) < overlap(botY))
        val cy = if (atTop) topY else botY
        val cx = (vw - cw) / 2
        val tx = rect?.center?.x ?: (vw / 2); val ty = rect?.center?.y ?: (vh / 2)
        val onLeft = rect != null && tx > vw / 2
        val ms = 84 * dens
        val mx = if (onLeft) cx + 4 * dens else cx + cw - ms - 4 * dens; val my = cy + cardH / 2 - ms * .42f
        // Halka + ok
        Canvas(Modifier.fillMaxSize()) {
            if (rect != null) {
                val col = if (hint?.recover == true) warnC else ringC
                val r = Rect(rect.left - 6 * dens, rect.top - 6 * dens, rect.right + 6 * dens, rect.bottom + 6 * dens)
                drawRoundRect(col.copy(alpha = .22f + .2f * pulse), r.topLeft - Offset(4 * dens, 4 * dens), androidx.compose.ui.geometry.Size(r.width + 8 * dens, r.height + 8 * dens), androidx.compose.ui.geometry.CornerRadius(16 * dens), style = Stroke(6 * dens))
                drawRoundRect(col, r.topLeft, r.size, androidx.compose.ui.geometry.CornerRadius(14 * dens), style = Stroke(3 * dens))
                if (rect.width * rect.height < vw * vh * .35f) {
                    val sx = mx + ms / 2 + (if (onLeft) 14 else -14) * dens; val sy = if (atTop) cy + cardH + 4 * dens else cy - 4 * dens
                    val ddx = tx - sx; val ddy = ty - sy
                    val tt = min(if (abs(ddx) > .1f) (rect.width / 2 + 12 * dens) / abs(ddx) else 9f, if (abs(ddy) > .1f) (rect.height / 2 + 12 * dens) / abs(ddy) else 9f)
                    if (tt < .92f && hypot(ddx, ddy) > 30 * dens) {
                        val ex = tx - ddx * tt; val ey = ty - ddy * tt
                        val mxp = (sx + ex) / 2 + (if (onLeft) -1 else 1) * min(60 * dens, abs(ey - sy) * .25f); val myp = (sy + ey) / 2
                        val path = Path().apply { moveTo(sx, sy); quadraticBezierTo(mxp, myp, ex, ey) }
                        drawPath(path, col, style = Stroke(4 * dens, cap = StrokeCap.Round, pathEffect = PathEffect.dashPathEffect(floatArrayOf(9 * dens, 7 * dens), -dash * dens)))
                        val ang = kotlin.math.atan2(ey - myp, ex - mxp)
                        val hd = Path().apply { moveTo(ex + kotlin.math.cos(ang) * 8 * dens, ey + kotlin.math.sin(ang) * 8 * dens); lineTo(ex + kotlin.math.cos(ang + 2.4f) * 9 * dens, ey + kotlin.math.sin(ang + 2.4f) * 9 * dens); lineTo(ex + kotlin.math.cos(ang - 2.4f) * 9 * dens, ey + kotlin.math.sin(ang - 2.4f) * 9 * dens); close() }
                        drawPath(hd, col)
                    }
                }
            }
        }
        // Kart
        Column(Modifier.offset { androidx.compose.ui.unit.IntOffset(cx.toInt(), cy.toInt()) }.width(with(LocalDensity.current) { cw.toDp() }).onSizeChanged { cardH = it.height }
            .shadow(14.dp, RoundedCornerShape(18.dp)).clip(RoundedCornerShape(18.dp)).background(Brush.verticalGradient(listOf(Color(0xFF1E2A55), Color(0xFF17224A))))
            .border(1.5.dp, Color(0xFF2C6FD8), RoundedCornerShape(18.dp)).tap { shown = full.length }
            .padding(start = if (onLeft) 96.dp else 12.dp, end = if (onLeft) 12.dp else 96.dp, top = 8.dp, bottom = 10.dp)) {
            val n = run.script.steps.size
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text("${run.script.title} · ${min(run.step + 1, n)}/$n", fontSize = 11.sp, fontWeight = FontWeight.Bold, color = C.dText2, modifier = Modifier.weight(1f))
                Box(Modifier.size(30.dp).tap { voiceOn = !voiceOn; Voice.set(ctx, voiceOn) }, contentAlignment = Alignment.Center) { Text(if (voiceOn) "🔊" else "🔇", fontSize = 14.sp) }
                Box(Modifier.size(30.dp).tap { Assistant.min = true }, contentAlignment = Alignment.Center) { Ico("chevD", C.dText2, 18.dp) }
                Box(Modifier.size(30.dp).tap { Assistant.stop(false) }, contentAlignment = Alignment.Center) { Ico("close", C.dText2, 18.dp) }
            }
            Box {
                Text(say, fontSize = 14.sp, lineHeight = 20.sp, color = Color.Transparent, modifier = Modifier.padding(top = 2.dp, bottom = 8.dp))
                Text(say.take(shown), fontSize = 14.sp, lineHeight = 20.sp, color = if (hint?.recover == true) Color(0xFFF7D774) else C.dText, modifier = Modifier.padding(top = 2.dp, bottom = 8.dp))
            }
            if (sub.isNotEmpty()) Text("👉 " + sub.take(max(0, shown - say.length - 1)), fontSize = 13.sp, fontWeight = FontWeight.Bold, color = Color(0xFF7EE8F0), modifier = Modifier.padding(bottom = 8.dp))
            if (step.choices != null && hint?.recover != true && sub.isEmpty()) Column(Modifier.padding(bottom = 6.dp), verticalArrangement = Arrangement.spacedBy(6.dp)) {
                step.choices.forEach { c ->
                    Text(c.label, fontSize = 13.5.sp, fontWeight = FontWeight.Bold, color = C.dText, modifier = Modifier.fillMaxWidth().heightIn(min = 38.dp).clip(RoundedCornerShape(12.dp))
                        .border(1.5.dp, Color(0xFF2C6FD8), RoundedCornerShape(12.dp)).background(Color(0xFF0F1834)).tap(onClick = c.act).padding(horizontal = 12.dp, vertical = 9.dp))
                }
            }
            Row(verticalAlignment = Alignment.CenterVertically) {
                if (run.step > 0 && hint?.recover != true && !run.demo) Text("Geri", fontSize = 13.sp, fontWeight = FontWeight.Bold, color = C.dText2, modifier = Modifier.tap { Assistant.go(run.step - 1) }.padding(horizontal = 10.dp, vertical = 8.dp))
                Spacer(Modifier.weight(1f))
                if (run.demo) Text("Durdur", fontSize = 13.sp, fontWeight = FontWeight.Bold, color = C.dText2, modifier = Modifier.tap { Assistant.run = run.copy(demo = false) }.padding(horizontal = 10.dp, vertical = 8.dp))
                else if ((step.done != null || step.auto != null) && !autoReq) Text("Anlamadım", fontSize = 13.sp, fontWeight = FontWeight.Bold, color = C.dText2, modifier = Modifier.tap { autoReq = true }.padding(horizontal = 10.dp, vertical = 8.dp))
                if (step.choices == null) Text(step.btn ?: "Geç", fontSize = 13.sp, fontWeight = FontWeight.Bold, color = C.dDeep, modifier = Modifier.height(34.dp).clip(RoundedCornerShape(17.dp)).background(C.turq).tap { if (step.end) Assistant.stop(true) else Assistant.go(run.step + 1) }.padding(horizontal = 16.dp, vertical = 8.dp))
            }
        }
        // WardenCB
        Box(Modifier.offset { androidx.compose.ui.unit.IntOffset(mx.toInt(), (my + bob * dens).toInt()) }.size(with(LocalDensity.current) { ms.toDp() })
            .graphicsLayer { scaleX = if (onLeft) -1f else 1f }) {
            // Hedefe bakar (eski uygulamadaki gibi); aynalanınca bakış da ters çevrilir
            val mcx = mx + ms / 2; val mcy = my + ms * .42f
            val lx = ((tx - mcx) / (140 * dens)).coerceIn(-1f, 1f); val ly = ((ty - mcy) / (220 * dens)).coerceIn(-1f, 1f)
            WardenCBImg(mood, with(LocalDensity.current) { ms.toDp() }, look = (if (onLeft) -lx else lx) to ly)
        }
        // El
        handPos?.let { hp ->
            Canvas(Modifier.offset { androidx.compose.ui.unit.IntOffset((hp.x - 4 * dens).toInt(), (hp.y - 2 * dens).toInt()) }.size(34.dp, 40.dp).graphicsLayer { scaleX = if (press) .88f else 1f; scaleY = if (press) .88f else 1f }) {
                val k = size.width / 34f
                val p = Path().apply { moveTo(4 * k, 2 * k); lineTo(4 * k, 30 * k); lineTo(11 * k, 23 * k); lineTo(16 * k, 35 * k); lineTo(21 * k, 33 * k); lineTo(16 * k, 21 * k); lineTo(26 * k, 21 * k); close() }
                drawPath(p, Color(0xFF22D3E6)); drawPath(p, Color(0xFF0B1430), style = Stroke(2.5f * k))
            }
        }
    }
}


// ---------------------------------------------------------------------------------------------
// "WardenCB ile Öğret": açık projeye dokunmadan, efekte uygun malzemeli küçük bir deneme projesi açar ve adım adım anlatır
// ---------------------------------------------------------------------------------------------
fun fxTeach(type: String) {
    val m = fxMeta(type)
    Assistant.stop()
    var p = newProject("${m.name} · WardenCB Öğretiyor", 720, 720, 30, "#16224A").copy(tutorial = "fx:$type")
    val dur = 4.0
    val bg = makeLayer(p, 0.0, dur, "shape", "Zemin") { it.copy(shape = "rect", w = 720.0, h = 720.0, fill = "#1F3270", fill2 = "#0B1430", grad = Grad(0.5, 0.0, 0.5, 1.0)) }
    val layers = ArrayList<Layer>(); layers += bg
    var target: String
    when {
        m.kind == "text" || m.catIndex == 10 -> {
            val tx = makeLayer(p, 0.0, dur, "text", "Yazı") { it.copy(text = "MERHABA", fill = "#F7F8FA", fontSize = 110.0, w = 600.0, h = 143.0) }
            layers += tx; target = tx.id
        }
        m.kind == "audio-fx" -> {
            val tx = makeLayer(p, 0.0, dur, "text", "Not") { it.copy(text = "Ses efekti: bir ses\nkatmanı ekleyip dene", fill = "#F7F8FA", fontSize = 44.0, w = 620.0, h = 120.0) }
            layers += tx; target = tx.id
        }
        else -> {
            val (cb, lineId) = cbBodyLayers(p, 0.0, dur, "yumusak-top", "flags/tr.svg", "Türkiye", 380.0)
            layers += cb; target = lineId
            // Görüntü efektleri bütün CB'ye (çizgiye) uygulanır; gerekirse ikinci katman: altta yazı
            if (m.kind in setOf("pixel", "gen", "3d", "repeat")) {
                val tx = makeLayer(p, 0.0, dur, "text", "Yazı") { it.copy(text = "WARDEN MOTION", fill = "#22D3C5", fontSize = 54.0, w = 560.0, h = 70.0, y = Anim(640.0)) }
                layers += tx
            }
        }
    }
    val anim = m.presets.find { it.code == "AN" } ?: m.presets.firstOrNull { it.alias == null }
    var fx = makeEffect(type)
    if (anim != null) fx = applyPreset(fx, anim, 0.0, dur).copy(preset = anim.code)
    p = p.copy(layers = layers.map { if (it.id == target) it.copy(effects = it.effects + fx) else it })
    Assistant.pendingDemo = p.id
    UiState.openNew(p)
}

private fun unitWord(pr: FxParam) = when (pr.unit) {
    "%" -> "yüzde olarak"; "px" -> "piksel cinsinden"; "°" -> "derece olarak"; "Hz" -> "saniyedeki tekrar sayısıyla"; "s" -> "saniye cinsinden"; "box%" -> "katmanın üstünde bir nokta olarak"; "dB" -> "desibel olarak"; else -> ""
}

fun fxTeachScript(type: String, pid: String): Script {
    val m = fxMeta(type)
    val st = ArrayList<Step>()
    st += Step("Bu, ${m.name} efekti! ${m.desc}", "wave")
    st += Step("Senin projene dokunmadım: bu küçük deneme projesini senin için kurdum ve efekti ekledim. Önce ▶ ile oynatıp izle.", "happy", target = { "play" }, done = { ed?.playing == true })
    m.teach?.split(Regex("(?<=[.;])\\s+"))?.filter { it.length > 8 }?.take(4)?.forEach { st += Step(it.replaceFirstChar { c -> c.uppercase() }, "point") }
    val main = m.params.filter { it.isNumeric() && it.kind != "toggle" }.take(4)
    if (main.isNotEmpty()) st += Step("Şimdi ayarlara bakalım. Katmanı seçip alttan \"Efektler\"e dokun; ${m.name} panelinde bütün ayarlar var.", "point", target = { "tbig:Efektler" }, done = { UiState.panel == "Efektler" })
    main.forEachIndexed { i, pr ->
        val what = when (pr.kind) {
            "choice" -> "farklı biçimler arasında seçim yapar: ${pr.opts?.take(4)?.joinToString(", ")}"
            else -> "değeri ${unitWord(pr)} belirler (${fmtV(pr.min, pr)} ile ${fmtV(pr.max, pr)} arası)"
        }
        st += Step("${i + 1}. ayar \"${pr.label}\": $what. Cetveli parmağınla sağa sola kaydır, değişimi önizlemede gör.", if (i % 2 == 0) "point" else "curious")
    }
    st += Step("İpucu: Bir ayarın adına dokunup soldaki ◆ ile keyframe koyarsan, değer zamanla değişir. Değerin üstüne dokunursan sayıyı elle yazabilirsin.", "smug")
    if (m.presets.any { it.alias == null }) st += Step("Hazır ayarlar da var: ${m.presets.filter { it.alias == null }.take(4).joinToString(", ") { it.name }}. Panelin üstündeki düğmelerle tek dokunuşta dene.", "excited")
    st += Step("${m.name} bu kadar! Beğendiğin efektleri Efekt Ekle'de ⭐ ile favorilerine ekleyebilirsin.", "proud", btn = "Bitir", end = true)
    return Script("fx:$type", m.name, st, pid)
}
