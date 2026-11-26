package com.warden.motion.app.render

import android.content.Context
import android.graphics.Bitmap
import android.opengl.EGL14
import android.opengl.EGLConfig
import android.opengl.EGLContext
import android.opengl.EGLDisplay
import android.opengl.EGLSurface
import android.opengl.GLES30
import android.opengl.GLUtils
import android.util.Log
import com.warden.motion.app.model.Effect
import com.warden.motion.app.model.FxMeta
import com.warden.motion.app.model.FxParam
import com.warden.motion.app.model.FxPass
import com.warden.motion.app.model.value
import com.warden.motion.app.model.at
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.util.concurrent.Executors
import kotlin.math.max

/**
 * GPU efekt motoru (OpenGL ES 3.0, ekransız).
 * Katman ara resmi (pad dahil) dokuya yüklenir, efekt zinciri assets/fx/<tür>.glsl shader'larıyla uygulanır, sonuç geri okunur.
 * Önizleme üreticisi (tools/fxlab, WebGL2) birebir aynı shader'ları ve aynı uniform kurallarını kullanır.
 */
object GlFx {
    /** Bu türlerin shader'ı vardır (katalogdaki pixel / gen / repeat / 3d) */
    val GPU_KINDS = setOf("pixel", "gen", "repeat", "3d")

    private val exec = Executors.newSingleThreadExecutor { r -> Thread(r, "GlFx").apply { priority = Thread.NORM_PRIORITY + 1 } }
    private var ctx: Context? = null
    private var dpy: EGLDisplay = EGL14.EGL_NO_DISPLAY
    private var eglCtx: EGLContext = EGL14.EGL_NO_CONTEXT
    private var surf: EGLSurface = EGL14.EGL_NO_SURFACE
    @Volatile var failed = false; private set
    private var common = ""
    private val progs = HashMap<String, Int>()
    private val bad = HashSet<String>()
    private var vbo = 0

    fun init(c: Context) { ctx = c.applicationContext }

    private val VS = """#version 300 es
in vec2 a_pos; out vec2 v_uv; uniform mat3 u_m;
void main(){ v_uv = a_pos; vec3 p = u_m * vec3(a_pos, 1.0); gl_Position = vec4(p.xy, 0.0, 1.0); }"""

    private fun setup(): Boolean {
        if (eglCtx != EGL14.EGL_NO_CONTEXT) return true
        if (failed) return false
        try {
            dpy = EGL14.eglGetDisplay(EGL14.EGL_DEFAULT_DISPLAY)
            val ver = IntArray(2); check(EGL14.eglInitialize(dpy, ver, 0, ver, 1))
            val attr = intArrayOf(EGL14.EGL_RENDERABLE_TYPE, 0x40 /* EGL_OPENGL_ES3_BIT */, EGL14.EGL_SURFACE_TYPE, EGL14.EGL_PBUFFER_BIT,
                EGL14.EGL_RED_SIZE, 8, EGL14.EGL_GREEN_SIZE, 8, EGL14.EGL_BLUE_SIZE, 8, EGL14.EGL_ALPHA_SIZE, 8, EGL14.EGL_NONE)
            val cfg = arrayOfNulls<EGLConfig>(1); val n = IntArray(1)
            check(EGL14.eglChooseConfig(dpy, attr, 0, cfg, 0, 1, n, 0) && n[0] > 0)
            eglCtx = EGL14.eglCreateContext(dpy, cfg[0], EGL14.EGL_NO_CONTEXT, intArrayOf(EGL14.EGL_CONTEXT_CLIENT_VERSION, 3, EGL14.EGL_NONE), 0)
            check(eglCtx != EGL14.EGL_NO_CONTEXT)
            surf = EGL14.eglCreatePbufferSurface(dpy, cfg[0], intArrayOf(EGL14.EGL_WIDTH, 1, EGL14.EGL_HEIGHT, 1, EGL14.EGL_NONE), 0)
            check(EGL14.eglMakeCurrent(dpy, surf, surf, eglCtx))
            common = asset("fx/common.glsl") ?: error("common.glsl yok")
            val b = IntArray(1); GLES30.glGenBuffers(1, b, 0); vbo = b[0]
            GLES30.glBindBuffer(GLES30.GL_ARRAY_BUFFER, vbo)
            val q = ByteBuffer.allocateDirect(32).order(ByteOrder.nativeOrder()).asFloatBuffer().put(floatArrayOf(0f, 0f, 1f, 0f, 0f, 1f, 1f, 1f)); q.position(0)
            GLES30.glBufferData(GLES30.GL_ARRAY_BUFFER, 32, q, GLES30.GL_STATIC_DRAW)
            return true
        } catch (e: Throwable) { Log.w("GlFx", "GPU hazırlanamadı", e); failed = true; return false }
    }

    private fun asset(p: String) = runCatching { ctx!!.assets.open(p).bufferedReader().use { it.readText() } }.getOrNull()

    private fun shader(type: Int, src: String): Int {
        val s = GLES30.glCreateShader(type); GLES30.glShaderSource(s, src); GLES30.glCompileShader(s)
        val ok = IntArray(1); GLES30.glGetShaderiv(s, GLES30.GL_COMPILE_STATUS, ok, 0)
        if (ok[0] == 0) { Log.w("GlFx", GLES30.glGetShaderInfoLog(s)); GLES30.glDeleteShader(s); return 0 }
        return s
    }

    private fun prog(name: String): Int {
        progs[name]?.let { return it }
        if (name in bad) return 0
        val src = asset("fx/$name.glsl") ?: run { bad += name; return 0 }
        val vs = shader(GLES30.GL_VERTEX_SHADER, VS); val fs = shader(GLES30.GL_FRAGMENT_SHADER, "#version 300 es\n$common\n${gradientExpand(src)}")
        if (vs == 0 || fs == 0) { bad += name; return 0 }
        val p = GLES30.glCreateProgram(); GLES30.glAttachShader(p, vs); GLES30.glAttachShader(p, fs)
        GLES30.glBindAttribLocation(p, 0, "a_pos"); GLES30.glLinkProgram(p)
        val ok = IntArray(1); GLES30.glGetProgramiv(p, GLES30.GL_LINK_STATUS, ok, 0)
        if (ok[0] == 0) { Log.w("GlFx", "$name: " + GLES30.glGetProgramInfoLog(p)); bad += name; return 0 }
        progs[name] = p; return p
    }

    /** "GRADIENT(k)" satırı → renk geçişi uniform'ları ve grad_k / paln_k / palc_k (GLSL ES'te ## yok) */
    fun gradientExpand(src: String): String = Regex("^GRADIENT\\((\\w+)\\)\\s*$", RegexOption.MULTILINE).replace(src) { m ->
        val k = m.groupValues[1]
        val c = (0..7).joinToString(", ") { "c_$k$it" }; val q = (0..7).joinToString(", ") { "p_${k}P$it" }
        """uniform float p_${k}N; uniform vec3 $c; uniform float $q;
vec3 grad_$k(float x) { vec3 c[8] = vec3[8]($c); float q[8] = float[8]($q); int n = int(max(1.0, p_${k}N));
  vec3 r = c[0]; if (x <= q[0]) return c[0]; for (int i = 1; i < 8; i++) { if (i >= n) break; if (x <= q[i]) return mix(c[i - 1], c[i], clamp((x - q[i - 1]) / max(1e-4, q[i] - q[i - 1]), 0.0, 1.0)); r = c[i]; } return r; }
int paln_$k() { return int(clamp(p_${k}N, 1.0, 8.0)); }
vec3 palc_$k(int i) { vec3 c[8] = vec3[8]($c); return c[clamp(i, 0, 7)]; }"""
    }

    private class Tex(val t: Int, val fb: Int, val w: Int, val h: Int)
    private fun tex(w: Int, h: Int, bmp: Bitmap? = null): Tex {
        val a = IntArray(1); GLES30.glGenTextures(1, a, 0); val t = a[0]
        GLES30.glBindTexture(GLES30.GL_TEXTURE_2D, t)
        if (bmp != null) GLUtils.texImage2D(GLES30.GL_TEXTURE_2D, 0, bmp, 0)
        else GLES30.glTexImage2D(GLES30.GL_TEXTURE_2D, 0, GLES30.GL_RGBA8, w, h, 0, GLES30.GL_RGBA, GLES30.GL_UNSIGNED_BYTE, null)
        GLES30.glTexParameteri(GLES30.GL_TEXTURE_2D, GLES30.GL_TEXTURE_MIN_FILTER, GLES30.GL_LINEAR)
        GLES30.glTexParameteri(GLES30.GL_TEXTURE_2D, GLES30.GL_TEXTURE_MAG_FILTER, GLES30.GL_LINEAR)
        GLES30.glTexParameteri(GLES30.GL_TEXTURE_2D, GLES30.GL_TEXTURE_WRAP_S, GLES30.GL_CLAMP_TO_EDGE)
        GLES30.glTexParameteri(GLES30.GL_TEXTURE_2D, GLES30.GL_TEXTURE_WRAP_T, GLES30.GL_CLAMP_TO_EDGE)
        val f = IntArray(1); GLES30.glGenFramebuffers(1, f, 0)
        GLES30.glBindFramebuffer(GLES30.GL_FRAMEBUFFER, f[0])
        GLES30.glFramebufferTexture2D(GLES30.GL_FRAMEBUFFER, GLES30.GL_COLOR_ATTACHMENT0, GLES30.GL_TEXTURE_2D, t, 0)
        return Tex(t, f[0], w, h)
    }
    private fun free(x: Tex) { GLES30.glDeleteTextures(1, intArrayOf(x.t), 0); GLES30.glDeleteFramebuffers(1, intArrayOf(x.fb), 0) }

    /** Uniform değeri: Float, FloatArray (2/3/4) */
    private fun draw(name: String, out: Tex, inputs: Map<String, Tex>, uni: Map<String, Any>): Boolean {
        val p = prog(name); if (p == 0) return false
        GLES30.glUseProgram(p)
        GLES30.glBindFramebuffer(GLES30.GL_FRAMEBUFFER, out.fb); GLES30.glViewport(0, 0, out.w, out.h)
        GLES30.glDisable(GLES30.GL_BLEND)
        var unit = 0
        for ((k, T) in inputs) {
            val loc = GLES30.glGetUniformLocation(p, k); if (loc < 0) continue
            GLES30.glActiveTexture(GLES30.GL_TEXTURE0 + unit); GLES30.glBindTexture(GLES30.GL_TEXTURE_2D, T.t); GLES30.glUniform1i(loc, unit); unit++
        }
        for ((k, v) in uni) {
            val loc = GLES30.glGetUniformLocation(p, k); if (loc < 0) continue
            when (v) {
                is Float -> GLES30.glUniform1f(loc, v)
                is FloatArray -> when (v.size) { 2 -> GLES30.glUniform2fv(loc, 1, v, 0); 3 -> GLES30.glUniform3fv(loc, 1, v, 0); 4 -> GLES30.glUniform4fv(loc, 1, v, 0) }
            }
        }
        GLES30.glUniformMatrix3fv(GLES30.glGetUniformLocation(p, "u_m"), 1, false, floatArrayOf(2f, 0f, 0f, 0f, 2f, 0f, -1f, -1f, 1f), 0)
        GLES30.glBindBuffer(GLES30.GL_ARRAY_BUFFER, vbo)
        GLES30.glEnableVertexAttribArray(0); GLES30.glVertexAttribPointer(0, 2, GLES30.GL_FLOAT, false, 0, 0)
        GLES30.glDrawArrays(GLES30.GL_TRIANGLE_STRIP, 0, 4)
        return true
    }

    data class Job(val effects: List<Pair<Effect, FxMeta>>, val t: Double, val lt: Double, val dur: Double, val box: FloatArray, val s: Float,
                   val sources: Map<String, Bitmap> = emptyMap())

    /** Efekt zincirini uygular; sonuç yeni bir Bitmap (aynı boyut) ya da GPU yoksa null */
    fun apply(bmp: Bitmap, job: Job): Bitmap? = try { exec.submit<Bitmap?> { run(bmp, job) }.get() } catch (e: Throwable) { Log.w("GlFx", "uygulanamadı", e); null }

    private fun run(bmp: Bitmap, job: Job): Bitmap? {
        if (!setup()) return null
        val w = bmp.width; val h = bmp.height
        val base = tex(w, h, bmp)
        val owned = ArrayList<Tex>(); owned += base
        val srcTex = HashMap<String, Tex>()
        for ((k, b) in job.sources) tex(b.width, b.height, b).also { srcTex["s_$k"] = it; owned += it }
        var cur = base
        for ((e, m) in job.effects) {
            val uni = HashMap<String, Any>()
            uni["u_res"] = floatArrayOf(w.toFloat(), h.toFloat()); uni["u_box"] = job.box; uni["u_t"] = job.lt.toFloat(); uni["u_s"] = job.s; uni["u_dur"] = job.dur.toFloat()
            uniforms(e, m, job.t, job.box, job.s, uni)
            val bufs = HashMap<String, Tex>(); bufs["src"] = cur
            val passes = m.passes ?: listOf(FxPass(m.type, null, null, 1.0, 0.0, null, null, emptyMap(), emptyMap()))
            var last = cur; var ok = true
            for (ps in passes) {
                if (ps.blur != null) {
                    var sig = ps.blurAdd + (ps.blurK?.let { k -> e.value(k, job.t) } ?: 0.0) * ps.blurMul
                    sig = max(0.0, sig) * job.s
                    val a = tex(w, h); val b = tex(w, h); owned += a; owned += b
                    val inp = bufs[ps.blur] ?: last
                    ok = draw("_blur", a, mapOf("u_tex" to inp) + srcTex, uni + mapOf("u_dir" to floatArrayOf(1f, 0f), "u_sigma" to sig.toFloat())) &&
                         draw("_blur", b, mapOf("u_tex" to a), uni + mapOf("u_dir" to floatArrayOf(0f, 1f), "u_sigma" to sig.toFloat()))
                    bufs[ps.out ?: "_last"] = b; last = b
                } else {
                    val inp = bufs[ps.input ?: if (last === cur) "src" else "_last"] ?: last
                    val o = tex(w, h); owned += o
                    val ins = HashMap<String, Tex>(); ins["u_tex"] = inp; ins["u_src"] = cur; ins.putAll(srcTex)
                    for ((k, v) in ps.aux) bufs[v]?.let { ins[k] = it }
                    val u2 = if (ps.set.isEmpty()) uni else uni + ps.set.mapValues { (_, v) -> if (v.size == 1) v[0].toFloat() else v.map { it.toFloat() }.toFloatArray() }
                    ok = draw(ps.fs ?: m.type, o, ins, u2)
                    bufs[ps.out ?: "_last"] = o; bufs["_last"] = o; last = o
                }
                if (!ok) break
            }
            if (!ok) continue // shader'ı olmayan / derlenemeyen efekt atlanır
            // Ortak "Karışım": efektin sonucunu girişle karıştır
            val mix = e.v?.get("_mix")?.at(job.t) ?: 100.0
            if (mix < 99.9) {
                val o = tex(w, h); owned += o
                if (draw("_mix", o, mapOf("u_tex" to last, "u_src" to cur), mapOf("u_mix" to (mix / 100).toFloat()))) last = o
            }
            cur = last
        }
        GLES30.glBindFramebuffer(GLES30.GL_FRAMEBUFFER, cur.fb)
        val buf = ByteBuffer.allocateDirect(w * h * 4).order(ByteOrder.nativeOrder())
        GLES30.glReadPixels(0, 0, w, h, GLES30.GL_RGBA, GLES30.GL_UNSIGNED_BYTE, buf)
        owned.forEach { free(it) }
        val out = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
        buf.position(0); out.copyPixelsFromBuffer(buf)
        return out
    }

    private fun hex(s: String?): FloatArray {
        val c = runCatching { android.graphics.Color.parseColor(if (s != null && s.length == 9) "#" + s.substring(7, 9) + s.substring(1, 7) else s) }.getOrDefault(-1)
        return floatArrayOf(((c shr 16) and 255) / 255f, ((c shr 8) and 255) / 255f, (c and 255) / 255f)
    }

    /** Efekt ayarları → uniform (lab/engine.js fxUniforms ile aynı kurallar) */
    fun uniforms(e: Effect, m: FxMeta, t: Double, box: FloatArray, s: Float, u: MutableMap<String, Any>) {
        for (pr in m.params) {
            when {
                pr.kind == "color" -> u["c_" + pr.key] = hex(e.c?.get(pr.key) ?: pr.defStr)
                pr.kind == "gradient" || pr.kind == "palette" -> gradient(pr, e.c?.get(pr.key) ?: pr.defStr, u)
                pr.two -> {
                    var x = e.value(pr.key + "X", t); var y = e.value(pr.key + "Y", t)
                    if (pr.unit == "box%") { x = (x / 100 - 0.5) * box[2] / s; y = (y / 100 - 0.5) * box[3] / s }
                    u["p_" + pr.key] = floatArrayOf(x.toFloat(), y.toFloat())
                }
                pr.three -> u["p_" + pr.key] = floatArrayOf(e.value(pr.key + "X", t).toFloat(), e.value(pr.key + "Y", t).toFloat(), e.value(pr.key + "Z", t).toFloat())
                pr.kind == "jog" || pr.kind == "slider" || pr.kind == "toggle" || pr.kind == "choice" -> u["p_" + pr.key] = e.value(pr.key, t).toFloat()
                pr.kind == "source" -> u["p_" + pr.key + "On"] = if (e.c?.get(pr.key).isNullOrEmpty()) 0f else 1f
            }
        }
    }

    /** Geçiş durakları: "[[\"#RRGGBB\",konum%],...]" → p_kN, c_k0..7, p_kP0..7 */
    private fun gradient(pr: FxParam, raw: String?, u: MutableMap<String, Any>) {
        val stops = runCatching {
            kotlinx.serialization.json.Json.parseToJsonElement(raw ?: "[]").let { it as kotlinx.serialization.json.JsonArray }.map { st ->
                val a = st as kotlinx.serialization.json.JsonArray
                (a[0] as kotlinx.serialization.json.JsonPrimitive).content to ((a[1] as kotlinx.serialization.json.JsonPrimitive).content.toDoubleOrNull() ?: 0.0)
            }
        }.getOrNull().orEmpty().ifEmpty { listOf("#000000" to 0.0, "#FFFFFF" to 100.0) }
        val n = minOf(8, stops.size); u["p_" + pr.key + "N"] = n.toFloat()
        for (i in 0 until 8) { val q = stops[minOf(i, n - 1)]; u["c_" + pr.key + i] = hex(q.first); u["p_" + pr.key + "P" + i] = (q.second / 100).toFloat() }
    }
}
