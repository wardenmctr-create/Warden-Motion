package com.warden.motion.app.render

import com.warden.motion.app.model.Effect
import com.warden.motion.app.model.Layer
import com.warden.motion.app.model.value
import kotlin.math.*

/** Zamansal efektlerin istediği anlar (kare şeridindeki sırayla). Shader tarafı aynı sırayı bilir. */
object History {
    private fun h1(x: Double): Double { val v = sin(x * 12.9898) * 43758.5453; return v - floor(v) }
    fun times(e: Effect, l: Layer, t: Double, fps: Double, export: Boolean): List<Double>? {
        if (e.on == false) return null
        val dt = 1.0 / max(1.0, fps); val cap = if (export) 16 else 10
        fun v(k: String) = e.value(k, t)
        return when (e.type) {
            "feedbackloop" -> (0 until min(cap, 12)).map { t - it * dt }
            "frameshuffle" -> { val w = max(2, v("pencere").roundToInt()); val f = floor((t - l.start) / dt).toInt(); val base = f - f % w; val idx = f % w
                val pick = if (h1(base * 0.37 + idx + v("tohum")) < v("karistir") / 100) (h1(base + idx * 1.7 + v("tohum") * 3.1) * w).toInt() else idx; listOf(l.start + (base + pick) * dt) }
            "temporalmedian", "temporaldenoise" -> { val k = min(cap - 1, (if (e.type == "temporalmedian") v("karePenc") else v("kareSayi")).roundToInt()).coerceAtLeast(1); (0 until k).map { t + (it - k / 2) * dt } }
            "brightaccum", "darkaccum" -> { val n = v("kareSayi").coerceAtLeast(1.0); val k = min(cap, n.roundToInt()); (0 until k).map { t - it * (n / k) * dt } }
            "timemosaic" -> { val g = v("satirSutu").roundToInt().coerceIn(1, 4); (0 until g * g).map { t - it * v("zamanAral") } }
            "timemap" -> { val m = v("azamiFark"); (0 until 9).map { t + (it - 4) / 4.0 * m } }
            "motioncomposite" -> { val k = min(cap, v("ornek").roundToInt().coerceAtLeast(2)); (0 until k).map { l.start + (l.end - l.start) * it / (k - 1).toDouble() } }
            "temporalfreq" -> { val k = min(cap, 16); val win = v("pencere") * dt; (0 until k).map { t - win * it / k } }
            "colortrail" -> { val k = min(cap, v("ornek").roundToInt().coerceAtLeast(1)); (0 until k).map { t - it * v("zamanAral") * 0.1 } }
            "movingmatte" -> { val g = v("gecmis").coerceAtLeast(1.0); val k = min(cap, 9); listOf(t) + (1 until k).map { t - it * g / (k - 1) * dt } }
            "motiondirmatte", "motionmagnify", "framerepair" -> listOf(t, t - dt, t + dt)
            "cinemagraph" -> listOf(l.start + v("sabitKareZama"))
            "timediff" -> listOf(t - max(dt, v("zamanFark")))
            "medianbg" -> { val k = min(cap, v("ornek").roundToInt().coerceAtLeast(3)); val span = max(dt, v("analizSure")); (0 until k).map { l.start + span * it / (k - 1) } }
            "flowconfidence" -> listOf(t, t - dt, t + dt)
            "fluidtrail" -> { val k = min(cap, 12); val span = max(dt, v("sonme")); (0 until k).map { t - span * it / (k - 1) } }
            "diffmatte" -> if (e.c?.get("temizKareKatm").isNullOrBlank()) listOf(l.start + v("referansZama")) else null
            "timedisplace" -> { val k = min(cap, v("ornekSayi").roundToInt().coerceAtLeast(2)); val m = v("maksimumZama"); val d = max(dt, l.end - l.start); val mode = v("zamanSini").roundToInt()
                (0 until k).map { i -> val tt = t - m * i / (k - 1); val r = tt - l.start
                    when { r >= 0 || mode == 0 -> tt; mode == 1 -> l.start + ((r % d) + d) % d; else -> l.start + kotlin.math.abs(r).let { a -> val q = a % (2 * d); if (q > d) 2 * d - q else q } } } }
            "stabilize" -> listOf(if (v("bilincliKameKaym") >= 0.5) max(l.start, t - v("yumusatmSure")) else l.start)
            else -> null
        }
    }
}
