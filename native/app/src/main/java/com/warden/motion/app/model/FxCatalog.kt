package com.warden.motion.app.model

import android.content.Context
import kotlinx.serialization.json.*

/**
 * Efekt kataloğu (assets/fx/catalog.json): 430 efekt, 17 kategori.
 * Katalog fxlab/catalog.py ile üretilir; aynı dosya önizleme üreticisinde (WebGL2) de kullanılır.
 */
data class FxPreset(val code: String, val name: String, val vals: Map<String, Double>, val keys: Map<String, List<Pair<Double, Double>>>,
                    val cols: Map<String, String>, val atEnd: Boolean, val alias: String?)
data class FxPass(val fs: String?, val blur: String?, val blurK: String?, val blurMul: Double, val blurAdd: Double, val input: String?, val out: String?,
                  val aux: Map<String, String>, val set: Map<String, List<Double>>)
data class FxPad(val k: String?, val mul: Double, val add: Double, val max: List<String>?, val box: Double = 0.0, val sum: List<String>? = null)

object FxCatalog {
    var cats: List<String> = emptyList(); private set
    var catOrder: List<Int> = emptyList(); private set
    var featured: List<String> = emptyList(); private set
    val all = LinkedHashMap<String, FxMeta>()
    @Volatile private var loaded = false
    private var appCtx: Context? = null

    fun init(ctx: Context) { appCtx = ctx.applicationContext; ensure() }

    @Synchronized fun ensure() {
        if (loaded) return
        val ctx = appCtx ?: return
        val txt = runCatching { ctx.assets.open("fx/catalog.json").bufferedReader().use { it.readText() } }.getOrNull() ?: return
        parse(txt); loaded = true
    }

    fun parse(txt: String) {
        val root = Json.parseToJsonElement(txt).jsonObject
        cats = root["cats"]!!.jsonArray.map { it.jsonPrimitive.content }
        catOrder = root["catOrder"]?.jsonArray?.map { it.jsonPrimitive.int } ?: cats.indices.toList()
        featured = root["featured"]?.jsonArray?.map { it.jsonPrimitive.content } ?: emptyList()
        all.clear()
        for (el in root["effects"]!!.jsonArray) { val m = meta(el.jsonObject); all[m.type] = m }
    }

    private fun JsonObject.s(k: String) = this[k]?.takeIf { it !is JsonNull }?.jsonPrimitive?.contentOrNull
    private fun JsonObject.d(k: String) = this[k]?.takeIf { it !is JsonNull }?.jsonPrimitive?.doubleOrNull
    private fun JsonObject.b(k: String) = this[k]?.takeIf { it !is JsonNull }?.jsonPrimitive?.booleanOrNull ?: false

    private fun param(o: JsonObject): FxParam {
        val kind = o.s("kind") ?: "jog"
        val defEl = o["def"]
        val defNum = (defEl as? JsonPrimitive)?.doubleOrNull ?: 0.0
        val defStr = when {
            kind == "color" -> (defEl as? JsonPrimitive)?.contentOrNull
            kind == "gradient" || kind == "palette" -> defEl?.toString()
            kind == "text" || kind == "editor" -> (defEl as? JsonPrimitive)?.contentOrNull
            else -> null
        }
        return FxParam(o.s("k")!!, o.s("l") ?: "", o.d("min") ?: 0.0, o.d("max") ?: 0.0, defNum, o.d("step") ?: 1.0, o.d("jog") ?: (o.d("step") ?: 1.0),
            kind = kind, two = o.b("two"), defY = o.d("defY"), three = o.b("three"), defZ = o.d("defZ"), unit = o.s("unit") ?: "",
            opts = o["opts"]?.jsonArray?.map { it.jsonPrimitive.content }, anim = o.s("anim") ?: "yes", defStr = defStr, int = o.b("int"),
            reseed = o.b("reseed"), hint = o.s("hint"), multi = o.b("multi"), group = o.s("g"),
            visKey = (o["vis"] as? JsonObject)?.s("k"), visIn = (o["vis"] as? JsonObject)?.get("in")?.jsonArray?.map { it.jsonPrimitive.int })
    }

    private fun pass(o: JsonObject): FxPass {
        val r = o["r"] as? JsonObject
        return FxPass(o.s("fs"), o.s("blur"), r?.s("k"), r?.d("mul") ?: 1.0, r?.d("add") ?: 0.0, o.s("in"), o.s("out"),
            (o["aux"] as? JsonObject)?.mapValues { it.value.jsonPrimitive.content } ?: emptyMap(),
            (o["set"] as? JsonObject)?.mapValues { e -> (e.value as? JsonArray)?.map { it.jsonPrimitive.double } ?: listOf(e.value.jsonPrimitive.double) } ?: emptyMap())
    }

    private fun meta(o: JsonObject): FxMeta {
        val presets = (o["presets"] as? JsonArray)?.map { pe ->
            val p = pe.jsonObject
            FxPreset(p.s("code") ?: "", p.s("name") ?: "",
                (p["vals"] as? JsonObject)?.mapNotNull { (k, v) -> (v as? JsonPrimitive)?.doubleOrNull?.let { k to it } }?.toMap() ?: emptyMap(),
                (p["keys"] as? JsonObject)?.mapValues { (_, v) -> v.jsonArray.map { kv -> kv.jsonArray.let { it[0].jsonPrimitive.double to it[1].jsonPrimitive.double } } } ?: emptyMap(),
                (p["cols"] as? JsonObject)?.mapValues { it.value.jsonPrimitive.content } ?: emptyMap(),
                p.s("at") == "end", p.s("alias"))
        } ?: emptyList()
        val padO = o["pad"] as? JsonObject
        val pad = padO?.let { FxPad(it.s("k"), it.d("mul") ?: 1.0, it.d("add") ?: 0.0, (it["max"] as? JsonArray)?.map { x -> x.jsonPrimitive.content }, it.d("box") ?: 0.0, (it["sum"] as? JsonArray)?.map { x -> x.jsonPrimitive.content }) }
        val cat = o["cat"]!!.jsonPrimitive.int
        return FxMeta(o.s("type")!!, o.s("name") ?: "", cats.getOrElse(cat) { "" }, (o["params"] as? JsonArray)?.map { param(it.jsonObject) } ?: emptyList(),
            info = o.s("info"), en = o.s("en") ?: "", catIndex = cat, kind = o.s("kind") ?: "pixel", desc = o.s("desc") ?: "",
            tags = (o["tags"] as? JsonArray)?.map { it.jsonPrimitive.content } ?: emptyList(), presets = presets, pad = pad,
            passes = (o["passes"] as? JsonArray)?.map { pass(it.jsonObject) }, heavy = o.b("heavy"), hidden = o.b("hidden"),
            mergedInto = o.s("mergedInto"), teach = o.s("teach"), n = o["n"]?.jsonPrimitive?.intOrNull ?: 0, ready = o.b("ready"))
    }
}
