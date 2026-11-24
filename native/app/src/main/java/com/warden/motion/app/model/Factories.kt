package com.warden.motion.app.model

import kotlin.math.min
import kotlin.math.roundToInt

private fun A(v: Double) = Anim(v)

/** Yeni katman: projenin ortasında, kısa kenarın %35'i boyutunda */
fun makeLayer(p: Project, start: Double, dur: Double, type: String, name: String, f: (Layer) -> Layer = { it }): Layer {
    val size = (min(p.width, p.height) * 0.35).roundToInt().toDouble()
    return f(Layer(id = uid(), name = name, type = type, start = start, end = start + dur,
        x = A(p.width / 2.0), y = A(p.height / 2.0), w = size, h = size))
}

data class ShapeDef(val kind: String, val name: String, val w: Double? = null, val h: Double? = null, val pts: List<List<Double>>? = null)
val SHAPES = listOf(
    ShapeDef("circle", "Daire"), ShapeDef("roundrect", "Yuvarlatılmış Dikdörtgen", w = 260.0),
    ShapeDef("plus", "Artı"), ShapeDef("triangle", "Üçgen"), ShapeDef("hexagon", "Altıgen"),
    ShapeDef("star", "Yıldız"), ShapeDef("rect", "Kare", w = 260.0), ShapeDef("heart", "Kalp"),
    ShapeDef("bar", "Çubuk", w = 320.0, h = 44.0), ShapeDef("crescent", "Hilal"),
    ShapeDef("polygon", "Çokgen"), ShapeDef("custom", "Serbest Çokgen", pts = regularPts(5)),
)

val EASE_INOUT = listOf(0.42, 0.0, 0.58, 1.0)

/** Şablon keyframe'lerine yumuşak geçiş */
private fun soft(l: Layer): Layer {
    fun f(a: Anim) = if (a.k != null) a.copy(k = a.k.map { it.copy(e = EASE_INOUT) }) else a
    return l.copy(x = f(l.x), y = f(l.y), scale = f(l.scale), rotation = f(l.rotation), opacity = f(l.opacity))
}

data class Template(val id: String, val name: String, val make: () -> Project)

private fun keys(vararg kv: Pair<Double, Double>) = kv.map { Key(it.first, it.second) }

val TEMPLATES = listOf(
    Template("top", "Zıplayan Top") {
        val p = newProject("Zıplayan Top", 720, 900, 30, "#FFFFFF")
        val ball = makeLayer(p, 0.0, 3.0, "shape", "Top") {
            it.copy(shape = "circle", fill = "#2F7BF6", w = 180.0, h = 180.0,
                y = Anim(200.0, keys(0.0 to 200.0, 0.75 to 700.0, 1.5 to 200.0, 2.25 to 700.0, 3.0 to 200.0)),
                scale = Anim(1.0, keys(0.6 to 1.0, 0.75 to 0.85, 0.9 to 1.0, 2.1 to 1.0, 2.25 to 0.85, 2.4 to 1.0)))
        }
        val shadow = makeLayer(p, 0.0, 3.0, "shape", "Gölge") {
            it.copy(shape = "circle", fill = "#9AA6B8", w = 200.0, h = 40.0, y = A(800.0),
                opacity = Anim(0.4, keys(0.0 to 0.2, 0.75 to 0.6, 1.5 to 0.2, 2.25 to 0.6, 3.0 to 0.2)))
        }
        p.copy(layers = listOf(shadow, ball).map(::soft))
    },
    Template("cb", "CB Selam") {
        val p = newProject("CB Selam", 720, 900, 30, "#EAF4FF")
        val cb = makeLayer(p, 0.0, 4.0, "cb", "Türkiyeball") {
            it.copy(src = "flags/tr.svg", w = 360.0, h = 360.0, cb = CbOpts(10.0, "packs/hazir/gozler/normal.png"),
                effects = listOf(Effect(uid(), "sway", 6.0, speed = 0.8)), y = Anim(520.0, keys(0.0 to 1150.0, 0.8 to 520.0)))
        }
        val bubble = makeLayer(p, 1.0, 3.0, "image", "Konuşma Balonu") {
            it.copy(src = "packs/hazir/esyalar/konusma-balonu.png", w = 420.0, h = 420.0, y = A(220.0), scale = Anim(1.0, keys(1.0 to 0.0, 1.3 to 1.0)))
        }
        val text = makeLayer(p, 1.2, 2.8, "text", "Selam") { it.copy(text = "Selam!", fontSize = 72.0, fill = "#0D1631", w = 300.0, h = 90.0, y = A(205.0)) }
        p.copy(layers = listOf(cb, bubble, text).map(::soft))
    },
    Template("yazi", "Yazı Girişi") {
        val p = newProject("Yazı Girişi", 1280, 720, 30, "#0B1430")
        val t = makeLayer(p, 0.0, 3.0, "text", "Başlık") {
            it.copy(text = "WARDEN", fontSize = 150.0, fill = "#3FD0F0", w = 700.0, h = 170.0,
                scale = Anim(1.0, keys(0.0 to 0.4, 0.6 to 1.0)), opacity = Anim(1.0, keys(0.0 to 0.0, 0.6 to 1.0)),
                effects = listOf(Effect(uid(), "glow", 18.0, color = "#22D3C5")))
        }
        val bar = makeLayer(p, 0.4, 2.6, "shape", "Çizgi") { it.copy(shape = "rect", fill = "#2F7BF6", w = 600.0, h = 12.0, y = A(470.0), scale = Anim(1.0, keys(0.4 to 0.0, 1.0 to 1.0))) }
        p.copy(layers = listOf(bar, t).map(::soft))
    },
)

data class Tutorial(
    val id: String, val title: String, val kind: String, val level: String, val ready: Boolean,
    val summary: String, val steps: List<String> = emptyList(), val tips: List<String> = emptyList(),
    val w: Int = 720, val h: Int = 900, val bg: String = "#FFFFFF",
)

val LEVELS = listOf("Temel", "Temel-Orta", "Orta", "Orta-Ayrıntılı", "Ayrıntılı")

val TUTORIALS = listOf(
    Tutorial("cb1", "Temel CB", "CB", "Temel", true, "İlk countryball'unu yap: bayrak, göz, ağız, şapka ve hafif sallanma.",
        listOf(
            "Sağ alttaki + butonuna bas, Bayraklar sekmesinden bir ülke seç ve \"CB olarak ekle\"ye dokun.",
            "CB seçiliyken alttaki \"CB Ayarları\"na gir. Bir göz seç ve kontur kalınlığını ayarla.",
            "+ → CB Araçları → Hazır Pack → Ağızlar'dan bir ağız ekle. Önizlemede sürükleyip CB'nin üstüne yerleştir.",
            "Şapkalar klasöründen bir şapka ekle. \"Taşı ve Çevir\" → Ölçek ile boyutunu ayarla.",
            "CB'yi tekrar seç, Efektler'den \"Oto-Sallanma\" ekle. Küçük bir açı (4–8°) yeterli.",
            "▶ ile oynat. Beğendiysen sağ üstteki dışa aktar butonuyla videonu kaydet!",
        ),
        listOf(
            "Klasik countryball'larda göz bebeği yoktur; ifadeyi göz kapağının açısı verir (Kızgın / Üzgün).",
            "Ağzı çoğu sahnede hiç koyma; sadece konuşurken eklemek daha \"CB\" durur.",
            "Şapkayı topun biraz yan tarafına eğik koymak karaktere kişilik katar.",
        ), bg = "#EAF4FF"),
    Tutorial("cb2", "Orta CB", "CB", "Orta", false, "Yüz ifadeleri, göz kırpma, konuşma balonu ve iki CB'nin konuşması.", w = 1280, h = 720, bg = "#EAF4FF"),
    Tutorial("cb3", "Ayrıntılı CB", "CB", "Ayrıntılı", false, "Gölge ve parlaklık, aksesuarlar, kamera hareketi, çok karakterli sahne.", w = 1280, h = 720, bg = "#EAF4FF"),
    Tutorial("g1", "Temel Animasyon", "Genel", "Temel", true, "Şekil ekle, ilk keyframe'lerini koy ve hareket ettir.",
        listOf(
            "Sağ alttaki + butonuna bas, Şekil sekmesinden bir daire ekle.",
            "Daire seçiliyken alttaki \"Taşı ve Çevir\"e dokun.",
            "Zaman çizelgesi en baştayken (00:00:00) soldaki ◆ butonuna basarak ilk keyframe'i ekle.",
            "Zaman çizelgesini parmağınla sola kaydırarak 1. saniyeye git.",
            "Daireyi önizlemede sürükle ya da X/Y değerlerini değiştir. İkinci keyframe kendiliğinden oluşur.",
            "▶ ile oynat. Tebrikler, ilk animasyonun hazır!",
        ),
        listOf(
            "İki keyframe arası yumuşak geçiş otomatik; çok fazla keyframe koymana gerek yok.",
            "Hareketin sonunda küçük bir \"geri sekme\" keyframe'i eklemek animasyonu canlandırır.",
            "Önce kaba hareketi kur, ince ayarları en sona bırak.",
        )),
    Tutorial("g2", "Temel-Orta Animasyon", "Genel", "Temel-Orta", false, "Ölçek, döndürme, opaklık, metin ve yumuşak geçişler."),
    Tutorial("g3", "Orta Animasyon", "Genel", "Orta", false, "Gruplama, maske, efektler ve katman düzeni."),
    Tutorial("g4", "Orta-Ayrıntılı Animasyon", "Genel", "Orta-Ayrıntılı", false, "Hareket yolu, easing eğrileri ve geçişler."),
    Tutorial("g5", "Ayrıntılı Animasyon", "Genel", "Ayrıntılı", false, "Kamera ve 3B, karmaşık sahneler, dışa aktarma taktikleri.", w = 1280, h = 720),
)

/**
 * CB gövdesi: çizgi (kök) + beyaz iç (takip eder) [+ içe kırpılmış bayrak + gözler]. Sıra alttan üste.
 */
fun cbBodyLayers(p: Project, t: Double, dur: Double, shape: String, flagSrc: String? = null, flagName: String? = null, size0: Double? = null): Pair<List<Layer>, String> {
    val size = Math.round(size0 ?: (min(p.width, p.height) * 0.5)).toDouble()
    val lineId = uid(); val innerId = uid()
    val line = makeLayer(p, t, dur, "image", "${flagName ?: "Gövde"} Çizgi") { it.copy(id = lineId, src = "packs/hazir/govdeler/$shape-cizgi.png", w = size, h = size) }
    val inner = makeLayer(p, t, dur, "image", "${flagName ?: "Gövde"} İç") { it.copy(id = innerId, src = "packs/hazir/govdeler/$shape-ic.png", w = size, h = size, parent = lineId, x = A(0.0), y = A(0.0)) }
    val extra = ArrayList<Layer>()
    if (flagSrc != null) {
        // Basık gövde: bayrak alt kısımda (üstü beyaz), gözler kendi göz setinden ve gövdeye göre ölçülü yerinde
        val wb = shape == "wardencb"
        extra += makeLayer(p, t, dur, "image", "$flagName Bayrak") { it.copy(src = flagSrc, w = Math.round(size * (if (wb) 1.0 else 1.34)).toDouble(), h = Math.round(size * (if (wb) 0.68 else 1.0)).toDouble(), parent = lineId, mask = innerId, x = A(0.0), y = A(if (wb) Math.round(size * 0.1).toDouble() else 0.0)) }
        extra += makeLayer(p, t, dur, "image", "$flagName Gözler") {
            val s2 = Math.round(size * (if (wb) 0.95 else 0.62)).toDouble()
            it.copy(src = if (wb) "packs/hazir/gozler/wardencb-bakan.png" else "packs/hazir/gozler/normal.png", w = s2, h = s2, parent = lineId,
                x = A(if (wb) -Math.round(size * 0.0375).toDouble() else 0.0), y = A(if (wb) Math.round(size * 0.1125).toDouble() else -Math.round(size * 0.06).toDouble()))
        }
    }
    return (listOf(inner) + extra.take(1) + line + extra.drop(1)) to lineId
}
