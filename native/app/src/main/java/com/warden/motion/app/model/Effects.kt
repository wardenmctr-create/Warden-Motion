package com.warden.motion.app.model

/**
 * Efekt ayarı. kind: jog (kaydırma cetveli) | slider | toggle | choice | color | gradient | palette | curve | source | text | info | button | editor
 * unit: "%", "px", "°", "Hz", "s", "dB", "box%" (katman kutusunun yüzdesi; 50 = merkez) …
 */
data class FxParam(val key: String, val label: String, val min: Double, val max: Double, val def: Double, val step: Double = 1.0, val jog: Double = step,
                   val kind: String = "jog", val two: Boolean = false, val defY: Double? = null, val three: Boolean = false, val defZ: Double? = null,
                   val unit: String = "", val opts: List<String>? = null, val anim: String = "yes", val defStr: String? = null, val int: Boolean = false,
                   val reseed: Boolean = false, val hint: String? = null, val multi: Boolean = false,
                   /** Panel grubu; visKey/visIn: yalnız o seçim değerlerinde görünür */
                   val group: String? = null, val visKey: String? = null, val visIn: List<Int>? = null,
                   /** renk çarkı: ton ve güç ayarları; düğme: sıfırlanacak ayarlar; link: eksen zinciri; hideUi: panelde gösterme */
                   val hk: String? = null, val sk: String? = null, val reset: List<String>? = null, val link: Boolean = false, val hideUi: Boolean = false)
data class FxMeta(val type: String, val name: String, val cat: String, val params: List<FxParam>, val color: String? = null, val info: String? = null,
                  val en: String = "", val catIndex: Int = 0, val kind: String = "pixel", val desc: String = "", val tags: List<String> = emptyList(),
                  val presets: List<FxPreset> = emptyList(), val pad: FxPad? = null, val passes: List<FxPass>? = null, val heavy: Boolean = false,
                  val hidden: Boolean = false, val mergedInto: String? = null, val teach: String? = null, val n: Int = 0, val ready: Boolean = false)

/** Tarayıcıda görünen efektler (birleşmiş olanlar hariç), katalog sırasıyla */
val FX: List<FxMeta> get() { FxCatalog.ensure(); return FxCatalog.all.values.filter { !it.hidden } }
val FX_CATS: List<Pair<String, Int>> get() { FxCatalog.ensure(); return FxCatalog.catOrder.map { FxCatalog.cats[it] to it } }
val FEATURED: List<String> get() { FxCatalog.ensure(); return FxCatalog.featured }

fun fxMeta(t: String): FxMeta { FxCatalog.ensure(); return FxCatalog.all[t] ?: FxMeta(t, t, "", emptyList()) }
fun paramKeys(pr: FxParam) = when { pr.three -> listOf(pr.key + "X", pr.key + "Y", pr.key + "Z"); pr.two -> listOf(pr.key + "X", pr.key + "Y"); else -> listOf(pr.key) }
fun FxParam.isNumeric() = kind == "jog" || kind == "slider" || kind == "toggle" || kind == "choice"

fun makeEffect(t: String): Effect {
    val m = fxMeta(t)
    val v = HashMap<String, Anim>(); val c = HashMap<String, String>()
    for (pr in m.params) {
        when {
            pr.three -> { v[pr.key + "X"] = Anim(pr.def); v[pr.key + "Y"] = Anim(pr.defY ?: 0.0); v[pr.key + "Z"] = Anim(pr.defZ ?: 0.0) }
            pr.two -> { v[pr.key + "X"] = Anim(pr.def); v[pr.key + "Y"] = Anim(pr.defY ?: pr.def) }
            pr.isNumeric() -> v[pr.key] = Anim(pr.def)
            pr.defStr != null -> c[pr.key] = pr.defStr
        }
    }
    return Effect(uid(), t, 0.0, v = v, c = c.ifEmpty { null })
}

/** Hazır ayarı uygular (t0: katman başı, t1: katman sonu; keyframe zamanları buna göre) */
fun applyPreset(e: Effect, p: FxPreset, t0: Double, t1: Double): Effect {
    val m = fxMeta(e.type)
    val v = (e.v ?: emptyMap()).toMutableMap(); val c = (e.c ?: emptyMap()).toMutableMap()
    for ((k, x) in p.vals) v[k] = Anim(x)
    for ((k, ks) in p.keys) v[k] = Anim(ks.firstOrNull()?.second ?: 0.0, ks.map { (tt, x) -> Key(if (p.atEnd) t1 + tt else t0 + tt, x, listOf(0.42, 0.0, 0.58, 1.0)) })
    for ((k, x) in p.cols) c[k] = x
    if (m.params.isEmpty()) return e
    return e.copy(v = v, c = c.ifEmpty { null })
}

/** Eski sürümlerin efektlerini (tek "amount" ayarlı) yeni katalog ayarlarına çevirir */
fun migrateEffect(e: Effect): Effect {
    val m = fxMeta(e.type)
    val keys = m.params.flatMap { paramKeys(it) }.toSet()
    val old = e.v ?: emptyMap()
    if (old.keys.all { it in keys } && (old.isNotEmpty() || m.params.isEmpty())) return e
    fun a(k: String, def: Double) = old[k] ?: Anim(if (k == "amount") e.amount else def)
    fun sc(x: Anim, f: (Double) -> Double) = Anim(f(x.v), x.k?.map { it.copy(v = f(it.v)) })
    val base = makeEffect(when (e.type) { "brightness", "contrast" -> "bricon"; "saturate" -> "vibrance"; else -> e.type })
    val nv = (base.v ?: emptyMap()).toMutableMap(); val nc = (base.c ?: emptyMap()).toMutableMap()
    fun put(k: String, x: Anim) { if (nv.containsKey(k)) nv[k] = x }
    when (e.type) {
        "blur" -> put("yaricap", a("amount", 8.0))
        "glow" -> { put("yaricap", a("amount", 16.0)); e.color?.let { nc["renk"] = it } }
        "shadow" -> { put("bulanikl", a("amount", 14.0)); e.color?.let { nc["renk"] = it } }
        "brightness" -> put("parlakli", sc(a("amount", 100.0)) { (it - 100).coerceIn(-100.0, 100.0) })
        "contrast" -> put("kontrast", sc(a("amount", 100.0)) { (it - 100).coerceIn(-100.0, 100.0) })
        "saturate" -> put("doygunlu", sc(a("amount", 100.0)) { (it - 100).coerceIn(-100.0, 100.0) })
        "hue" -> put("tonAcis", a("amount", 0.0))
        "grayscale", "sepia", "invert" -> put("guc", a("amount", 100.0))
        "fractal" -> { put("bukmeMikt", sc(a("mag", 0.2)) { it * 130 }); put("ayrinti", sc(a("det", 1.0)) { it + 1 }); put("olcek", sc(a("scl", 1.0)) { it * 120 }) }
        "motionblur" -> put("deklansoAcis", sc(a("tune", 1.0)) { it * 180 })
        "sway" -> { put("salinimAcis", a("amount", 6.0)); put("frekans", a("speed", 0.8)) }
        "shake" -> { put("konumSidd", a("amount", 8.0)); put("frekans", sc(a("speed", 1.5)) { it * 4 }) }
    }
    return base.copy(id = e.id, v = nv, c = nc.ifEmpty { null }, closed = e.closed)
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
    for (l in p.layers) for (e in l.effects) { val m = fxMeta(e.type); if (m.heavy || e.type == "motionblur") s += m.name.lowercase(java.util.Locale("tr")) }
    return s.toList()
}
