package com.warden.motion.app.model

/** kind: jog (kaydırma cetveli) | slider | toggle */
data class FxParam(val key: String, val label: String, val min: Double, val max: Double, val def: Double, val step: Double = 1.0, val jog: Double = step,
                   val kind: String = "jog", val two: Boolean = false, val defY: Double? = null)
data class FxMeta(val type: String, val name: String, val cat: String, val params: List<FxParam>, val color: String? = null, val info: String? = null)

private fun P(key: String, label: String, min: Double, max: Double, def: Double, step: Double = 1.0, jog: Double = step) = FxParam(key, label, min, max, def, step, jog)

val FX = listOf(
    FxMeta("fractal", "Fraktal Bükme", "Bozulma", listOf(
        FxParam("pos", "Konum", -1e5, 1e5, 0.0, two = true, defY = 0.0),
        FxParam("par", "Paralaks", -1e5, 1e5, 0.0, two = true, defY = 0.0),
        P("mag", "Büyüklük", 0.0, 3.0, 0.2, 0.005, 0.005),
        P("det", "Ayrıntı", 0.0, 6.0, 1.0, 0.01, 0.02),
        P("scl", "Ölçek", 0.1, 10.0, 1.0, 0.01, 0.01),
    )),
    FxMeta("motionblur", "Hareket Bulanıklığı", "Bulanıklık", listOf(
        FxParam("tune", "Ayar", 0.0, 4.0, 1.0, 0.01, 0.01, kind = "slider"),
        FxParam("pos", "Konum", 0.0, 1.0, 1.0, kind = "toggle"),
        FxParam("scl", "Ölçek", 0.0, 1.0, 1.0, kind = "toggle"),
        FxParam("ang", "Açı", 0.0, 1.0, 1.0, kind = "toggle"),
    ), info = "Kullanmak için katmanı Taşı ve Çevir ile canlandır (bulanıklık kendiliğinden uygulanır)."),
    FxMeta("blur", "Gauss Bulanıklığı", "Bulanıklık", listOf(P("amount", "Miktar", 0.0, 60.0, 8.0, 0.5, 0.2))),
    FxMeta("sway", "Oto-Sallanma", "Hareket", listOf(P("amount", "Açı", 0.0, 45.0, 6.0, 0.5, 0.2), P("speed", "Hız", 0.1, 5.0, 0.8, 0.05, 0.02))),
    FxMeta("shake", "Rastgele Titreşim", "Hareket", listOf(P("amount", "Mesafe", 0.0, 60.0, 8.0, 0.5, 0.2), P("speed", "Hız", 0.1, 5.0, 1.5, 0.05, 0.02))),
    FxMeta("glow", "Parlama", "Işık ve Gölge", listOf(P("amount", "Miktar", 0.0, 60.0, 16.0, 0.5, 0.2)), color = "#3FD0F0"),
    FxMeta("shadow", "Gölge", "Işık ve Gölge", listOf(P("amount", "Miktar", 0.0, 60.0, 14.0, 0.5, 0.2)), color = "#0D1631"),
    FxMeta("brightness", "Parlaklık", "Renk ve Işık", listOf(P("amount", "Yüzde", 0.0, 300.0, 140.0, 1.0, 0.5))),
    FxMeta("contrast", "Kontrast", "Renk ve Işık", listOf(P("amount", "Yüzde", 0.0, 300.0, 150.0, 1.0, 0.5))),
    FxMeta("saturate", "Doygunluk", "Renk ve Işık", listOf(P("amount", "Yüzde", 0.0, 300.0, 180.0, 1.0, 0.5))),
    FxMeta("hue", "Ton Kaydırma", "Renk ve Işık", listOf(P("amount", "Derece", -180.0, 180.0, 90.0, 1.0, 0.5))),
    FxMeta("grayscale", "Siyah Beyaz", "Renk ve Işık", listOf(P("amount", "Yüzde", 0.0, 100.0, 100.0, 1.0, 0.5))),
    FxMeta("sepia", "Eski Fotoğraf", "Renk ve Işık", listOf(P("amount", "Yüzde", 0.0, 100.0, 100.0, 1.0, 0.5))),
    FxMeta("invert", "Ters Çevir", "Renk ve Işık", listOf(P("amount", "Yüzde", 0.0, 100.0, 100.0, 1.0, 0.5))),
    FxMeta("mirror", "Ayna", "Bozulma", emptyList()),
)

/** Kategori kartlarının renkleri (eski uygulamadaki geçişlerin yaklaşığı) */
val FX_CATS = listOf(
    "Renk ve Işık" to listOf(0xFF1B3A7A, 0xFF6B3FA0, 0xFFE84393),
    "Işık ve Gölge" to listOf(0xFF0B1430, 0xFF1F3270, 0xFF3FD0F0),
    "Bulanıklık" to listOf(0xFF8FA6D6, 0xFF2A3A72),
    "Hareket" to listOf(0xFF0E5A63, 0xFF22D3C5),
    "Bozulma" to listOf(0xFF1B3A7A, 0xFF2459B8),
)
val FEATURED = listOf("motionblur", "fractal", "blur")

fun fxMeta(t: String): FxMeta = FX.find { it.type == t } ?: FxMeta(t, t, "Bozulma", emptyList())
fun paramKeys(pr: FxParam) = if (pr.two) listOf(pr.key + "X", pr.key + "Y") else listOf(pr.key)

fun makeEffect(t: String): Effect {
    val m = fxMeta(t)
    val v = HashMap<String, Anim>()
    for (pr in m.params) { if (pr.two) { v[pr.key + "X"] = Anim(pr.def); v[pr.key + "Y"] = Anim(pr.defY ?: pr.def) } else v[pr.key] = Anim(pr.def) }
    return Effect(uid(), t, v["amount"]?.v ?: 0.0, v = v, color = m.color)
}

// ---------- Hareket işaretleyicileri (keyframe işaretleri) ----------
// Gruplar: pos (konum), rot (döndürme), scl (ölçek), op (opaklık), fx:<efektId>:<özellik>
data class Marker(val group: String, val t: Double)

val GROUP_NAME = mapOf("pos" to "Konum", "rot" to "Döndürme", "scl" to "Ölçek", "op" to "Opaklık")

private class GA(val a: Anim, val set: (Layer, Anim) -> Layer)

private fun groupAnims(l: Layer, g: String): List<GA> = when (g) {
    "pos" -> listOf(GA(l.x) { L, a -> L.copy(x = a) }, GA(l.y) { L, a -> L.copy(y = a) })
    "rot" -> listOf(GA(l.rotation) { L, a -> L.copy(rotation = a) })
    "scl" -> listOf(GA(l.scale) { L, a -> L.copy(scale = a) })
    "op" -> listOf(GA(l.opacity) { L, a -> L.copy(opacity = a) })
    else -> {
        val parts = g.split(":"); val fxId = parts.getOrNull(1); val pkey = parts.getOrNull(2)
        val e = l.effects.find { it.id == fxId }
        val pr = e?.let { fxMeta(it.type).params.find { p -> p.key == pkey } }
        if (e == null || pr == null) emptyList() else paramKeys(pr).filter { e.v?.get(it) != null }.map { k ->
            GA(e.v!![k]!!) { L, a -> L.copy(effects = L.effects.map { x -> if (x.id == fxId) x.copy(v = (x.v ?: emptyMap()) + (k to a)) else x }) }
        }
    }
}

fun layerMarkers(l: Layer): List<Marker> {
    val groups = mutableListOf("pos", "rot", "scl", "op")
    for (e in l.effects) for (pr in fxMeta(e.type).params) groups += "fx:${e.id}:${pr.key}"
    val out = ArrayList<Marker>()
    for (g in groups) {
        val ts = ArrayList<Double>()
        for (ga in groupAnims(l, g)) for (k in ga.a.k ?: emptyList()) if (ts.none { Math.abs(it - k.t) < EPS }) ts += k.t
        for (t in ts) out += Marker(g, t)
    }
    return out
}

fun moveMarker(l: Layer, g: String, t0: Double, t1: Double): Layer {
    var L = l
    for (ga in groupAnims(l, g)) {
        val k = ga.a.k ?: continue
        val moving = k.find { Math.abs(it.t - t0) < EPS } ?: continue
        val nk = (k.filter { it !== moving && Math.abs(it.t - t1) >= EPS } + moving.copy(t = t1)).sortedBy { it.t }
        L = ga.set(L, ga.a.copy(k = nk))
    }
    return L
}

fun deleteMarker(l: Layer, g: String, t: Double): Layer {
    var L = l
    for (ga in groupAnims(l, g)) {
        val k = ga.a.k ?: continue
        val nk = k.filter { Math.abs(it.t - t) >= EPS }
        L = ga.set(L, if (nk.isNotEmpty()) ga.a.copy(k = nk) else Anim(ga.a.v))
    }
    return L
}

fun groupLabel(l: Layer, g: String): String {
    GROUP_NAME[g]?.let { return it }
    val parts = g.split(":")
    val e = l.effects.find { it.id == parts.getOrNull(1) } ?: return ""
    val m = fxMeta(e.type)
    return "${m.name} · ${m.params.find { it.key == parts.getOrNull(2) }?.label ?: ""}"
}

/** Projede dışa aktarmayı yavaşlatan efektler */
fun heavyEffects(p: Project): List<String> {
    val s = LinkedHashSet<String>()
    for (l in p.layers) for (e in l.effects) when (e.type) { "motionblur" -> s += "hareket bulanıklığı"; "fractal" -> s += "fraktal bükme"; "blur" -> s += "bulanıklık" }
    return s.toList()
}
