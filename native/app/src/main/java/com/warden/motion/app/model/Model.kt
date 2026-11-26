package com.warden.motion.app.model

import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonElement

/**
 * Proje modeli: eski (web) Warden Motion'daki JSON ile birebir aynı.
 * Böylece eski uygulamanın yedekleri (.wmproje / .json) doğrudan açılır.
 */

/** e: sonraki keyframe'e geçişin yumuşatma eğrisi (cubic-bezier). Yoksa doğrusal. */
@Serializable
data class Key(val t: Double, val v: Double, val e: List<Double>? = null)

/** Canlandırılabilir değer: keyframe yoksa sabit v, varsa k. */
@Serializable
data class Anim(val v: Double = 0.0, val k: List<Key>? = null)

@Serializable
data class Effect(
    val id: String,
    val type: String,
    val amount: Double = 0.0,
    val speed: Double? = null,
    val color: String? = null,
    val v: Map<String, Anim>? = null,
    val closed: Boolean? = null,
    /** Renk ayarları (anahtar → #RRGGBB) */
    val c: Map<String, String>? = null,
    /** Efekt gözü: false ise efekt geçici olarak kapalı */
    val on: Boolean? = null,
    /** Seçilen hazır ayarın kodu (bilgi için) */
    val preset: String? = null,
)

@Serializable
data class Crop(val l: Double = 0.0, val t: Double = 0.0, val r: Double = 0.0, val b: Double = 0.0)

@Serializable
data class Grad(val x1: Double, val y1: Double, val x2: Double, val y2: Double)

@Serializable
data class CbOpts(val outline: Double = 6.0, val eyes: String? = null)

@Serializable
data class Layer(
    val id: String,
    val name: String,
    /** shape | text | image | cb | video | audio */
    val type: String,
    val start: Double,
    val end: Double,
    val x: Anim = Anim(),
    val y: Anim = Anim(),
    val scale: Anim = Anim(1.0),
    val rotation: Anim = Anim(),
    val opacity: Anim = Anim(1.0),
    val w: Double = 100.0,
    val h: Double = 100.0,
    val fill: String = "#8F7CF0",
    val shape: String? = null,
    val sp: Map<String, Double>? = null,
    val pts: List<List<Double>>? = null,
    val crop: Crop? = null,
    val text: String? = null,
    val fontSize: Double? = null,
    /** 'packs/…', 'flags/…' gibi bir yol ya da 'media:<id>' */
    val src: String? = null,
    val cb: CbOpts? = null,
    val effects: List<Effect> = emptyList(),
    val hidden: Boolean? = null,
    val volume: Double? = null,
    /** Ses/video: kaynağın katman başına denk gelen anı (sn). Baştan kırpınca ya da bölünce ilerler */
    val srcIn: Double? = null,
    /** Ses/video: kaynağın tam süresi (sn); şerit bundan uzun olamaz */
    val srcDur: Double? = null,
    val muted: Boolean? = null,
    val parent: String? = null,
    val mask: String? = null,
    val maskInvert: Boolean? = null,
    val blend: String? = null,
    val fill2: String? = null,
    val gtype: String? = null,
    val noFill: Boolean? = null,
    val flipX: Boolean? = null,
    val flipY: Boolean? = null,
    val tag: String? = null,
    val grad: Grad? = null,
)

@Serializable
data class Project(
    val id: String,
    val name: String,
    val width: Int,
    val height: Int,
    val fps: Int,
    val background: String,
    val layers: List<Layer> = emptyList(),
    val updatedAt: Long = System.currentTimeMillis(),
    val tutorial: String? = null,
) {
    /** Projenin süresi: en geç biten katman (boşsa 5 sn) */
    val duration: Double get() = layers.maxOfOrNull { it.end } ?: 5.0
}

/** Eski uygulamanın yedek dosyası */
@Serializable
data class Backup(
    val app: String? = null,
    val v: Int? = null,
    val projects: List<Project> = emptyList(),
    val media: Map<String, String> = emptyMap(),
    val pack: JsonElement? = null,
    val flags: JsonElement? = null,
    val profile: JsonElement? = null,
)

val JSON = Json { ignoreUnknownKeys = true; encodeDefaults = false; explicitNulls = false; coerceInputValues = true }

fun uid(): String = java.util.UUID.randomUUID().toString().replace("-", "").take(8)

fun newProject(name: String, width: Int, height: Int, fps: Int, background: String) =
    Project(id = uid(), name = name, width = width, height = height, fps = fps, background = background)
