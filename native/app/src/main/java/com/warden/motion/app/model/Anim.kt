package com.warden.motion.app.model

import kotlin.math.abs
import kotlin.math.floor
import kotlin.math.pow
import kotlin.math.max
import kotlin.math.min

/** cubic-bezier(x1,y1,x2,y2) eğrisinde x=p için y (CSS ile aynı) */
fun bezier(e: List<Double>?, p: Double): Double {
    if (e == null || e.size < 4) return p
    val (x1, y1, x2, y2) = e
    fun bx(u: Double) = 3 * x1 * u * (1 - u).pow(2) + 3 * x2 * u * u * (1 - u) + u.pow(3)
    fun by(u: Double) = 3 * y1 * u * (1 - u).pow(2) + 3 * y2 * u * u * (1 - u) + u.pow(3)
    var lo = 0.0; var hi = 1.0; var u = p
    repeat(24) { u = (lo + hi) / 2; if (bx(u) < p) lo = u else hi = u }
    return by(u)
}

data class Ease(val id: String, val name: String, val e: List<Double>?)
val EASES = listOf(
    Ease("linear", "Doğrusal", null),
    Ease("in", "Yavaş başla", listOf(0.42, 0.0, 1.0, 1.0)),
    Ease("out", "Yavaş bitir", listOf(0.0, 0.0, 0.58, 1.0)),
    Ease("inout", "Yavaş başla ve bitir", listOf(0.42, 0.0, 0.58, 1.0)),
    Ease("back", "Geri sekme", listOf(0.34, 1.56, 0.64, 1.0)),
)

const val EPS = 1.0 / 120

fun Anim.at(t: Double): Double {
    val k = k
    if (k.isNullOrEmpty()) return v
    if (t <= k[0].t) return k[0].v
    val last = k.last()
    if (t >= last.t) return last.v
    for (i in 0 until k.size - 1) {
        val a0 = k[i]; val a1 = k[i + 1]
        if (t >= a0.t && t <= a1.t) {
            val p = (t - a0.t) / (if (a1.t - a0.t == 0.0) 1.0 else a1.t - a0.t)
            return a0.v + (a1.v - a0.v) * bezier(a0.e, p)
        }
    }
    return last.v
}

fun Anim.keyAt(t: Double): Key? = k?.find { abs(it.t - t) < EPS }

/** Değeri yazar: keyframe'li ise o anda keyframe oluşturur/günceller */
fun Anim.set(t: Double, value: Double): Anim {
    val k = k
    if (k.isNullOrEmpty()) return Anim(value)
    val old = k.find { abs(it.t - t) < EPS }
    val rest = k.filter { abs(it.t - t) >= EPS } + Key(t, value, old?.e)
    return Anim(value, rest.sortedBy { it.t })
}

/** Keyframe aç/kapat */
fun Anim.toggleKey(t: Double): Anim {
    val cur = at(t)
    if (keyAt(t) != null) {
        val rest = k!!.filter { abs(it.t - t) >= EPS }
        return if (rest.isEmpty()) Anim(cur) else Anim(cur, rest)
    }
    return Anim(cur, ((k ?: emptyList()) + Key(t, cur)).sortedBy { it.t })
}

fun fmtTime(t: Double, fps: Int = 30): String {
    val s = floor(t).toInt()
    val f = floor((t - s) * fps).toInt()
    return "%02d:%02d:%02d".format(s / 60, s % 60, f)
}

/** Efekt parametresi (keyframe'li olabilir; eski projelerdeki amount/speed da okunur) */
fun Effect.value(key: String, t: Double): Double {
    v?.get(key)?.let { return it.at(t) }
    if (key == "amount") return amount
    if (key == "speed" && speed != null) return speed
    val pr = fxMeta(type).params.find { it.key == key || it.key + "X" == key || it.key + "Y" == key } ?: return 0.0
    return if (key.endsWith("Y") && pr.two) (pr.defY ?: pr.def) else pr.def
}

/** Ses ve video: kaynağı zamanla akan katmanlar */
fun Layer.isTimed() = (type == "audio" || type == "video") && src != null

/**
 * Katmanın başını t'ye taşır. Ses/videoda kaynak da kayar (kesilen kısım atlanır, gerisi aynı yerde kalır);
 * kaynağın başından öteye uzatılamaz.
 */
fun Layer.trimStart(t: Double): Layer {
    if (!isTimed()) return copy(start = t)
    val inn = srcIn ?: 0.0
    val nt = max(t, start - inn)
    return copy(start = nt, srcIn = (inn + nt - start).coerceAtLeast(0.0))
}

/** Ses/videoda şeridin sonu, kaynağın bittiği yeri geçemez */
fun Layer.maxEnd(e: Double): Double {
    val d = srcDur ?: return e
    if (!isTimed()) return e
    return min(e, start + d - (srcIn ?: 0.0)).coerceAtLeast(start + 0.1)
}
