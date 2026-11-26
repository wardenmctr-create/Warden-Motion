package com.warden.motion.app.data

import android.content.Context
import android.net.Uri
import android.util.Base64
import com.warden.motion.app.model.Backup
import com.warden.motion.app.model.JSON
import com.warden.motion.app.model.Project
import com.warden.motion.app.model.uid
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.withContext
import java.io.File

/**
 * Projeler ve medya telefonun kendi hafızasında dosya olarak durur:
 *  projects/<id>.json  ve  media/<id>  (görsel, video, ses — asıl hâliyle)
 */
class Store(private val ctx: Context) {
    private val projDir = File(ctx.filesDir, "projects").apply { mkdirs() }
    val mediaDir = File(ctx.filesDir, "media").apply { mkdirs() }
    private val prefs = ctx.getSharedPreferences("wm", Context.MODE_PRIVATE)

    private val _projects = MutableStateFlow<List<Project>>(emptyList())
    val projects: StateFlow<List<Project>> = _projects

    private val _lite = MutableStateFlow(prefs.getBoolean("lite", false))
    val lite: StateFlow<Boolean> = _lite
    fun setLite(on: Boolean) { prefs.edit().putBoolean("lite", on).putString("liteSource", "user").apply(); _lite.value = on; _liteSource.value = "user" }
    /** 'user' ya da 'auto' (cihaza göre) */
    private val _liteSource = MutableStateFlow(prefs.getString("liteSource", "auto") ?: "auto")
    val liteSource: StateFlow<String> = _liteSource
    fun setLiteAuto() { val on = weakDevice(); prefs.edit().putBoolean("lite", on).putString("liteSource", "auto").apply(); _lite.value = on; _liteSource.value = "auto" }
    /** Zayıf cihaz: az bellek ya da az çekirdek */
    fun weakDevice(): Boolean {
        val am = ctx.getSystemService(Context.ACTIVITY_SERVICE) as android.app.ActivityManager
        val mi = android.app.ActivityManager.MemoryInfo().also { am.getMemoryInfo(it) }
        return am.isLowRamDevice || mi.totalMem < 3L * 1024 * 1024 * 1024 || Runtime.getRuntime().availableProcessors() < 6
    }

    /** Lite ayarları (çubuklar): res, fps, blur, warp, light, color, img, vid, aud */
    private val _liteCfg = MutableStateFlow(readCfg())
    val liteCfg: StateFlow<Map<String, Double>> = _liteCfg
    private fun readCfg(): Map<String, Double> = runCatching {
        val o = org.json.JSONObject(prefs.getString("liteCfg", "{}")!!); o.keys().asSequence().associateWith { o.getDouble(it) }
    }.getOrDefault(emptyMap())
    fun setLiteCfg(m: Map<String, Double>) { prefs.edit().putString("liteCfg", org.json.JSONObject(m).toString()).apply(); _liteCfg.value = m }

    private val _defDur = MutableStateFlow(prefs.getFloat("defDur", 2f).toDouble())
    val defaultDuration: StateFlow<Double> = _defDur
    fun setDefaultDuration(v: Double) { prefs.edit().putFloat("defDur", v.toFloat()).apply(); _defDur.value = v }

    // ---------- Profil (bu cihazda) ----------
    data class Profile(val name: String = "", val photo: String? = null, val lastBackup: Long = 0)
    private val _profile = MutableStateFlow(Profile(prefs.getString("pName", "") ?: "", prefs.getString("pPhoto", null), prefs.getLong("pBackup", 0)))
    val profile: StateFlow<Profile> = _profile
    fun setProfile(p: Profile) {
        prefs.edit().putString("pName", p.name).putString("pPhoto", p.photo).putLong("pBackup", p.lastBackup).apply(); _profile.value = p
    }
    /** Profil fotoğrafı: 256 px'e küçültülüp kaydedilir */
    suspend fun setPhoto(uri: Uri?) = withContext(Dispatchers.IO) {
        if (uri == null) { setProfile(_profile.value.copy(photo = null)); return@withContext }
        val src = ctx.contentResolver.openInputStream(uri)!!.use { android.graphics.BitmapFactory.decodeStream(it) } ?: return@withContext
        val k = 256f / maxOf(src.width, src.height)
        val b = if (k < 1) android.graphics.Bitmap.createScaledBitmap(src, (src.width * k).toInt(), (src.height * k).toInt(), true) else src
        val f = File(ctx.filesDir, "profile_${System.currentTimeMillis()}.jpg")
        f.outputStream().use { b.compress(android.graphics.Bitmap.CompressFormat.JPEG, 88, it) }
        _profile.value.photo?.let { File(it).delete() }
        setProfile(_profile.value.copy(photo = f.absolutePath))
    }

    /** Yedek: eski uygulamayla aynı biçim (projeler + medya data URL olarak). onlyIds verilirse sadece o projeler */
    suspend fun exportBackup(out: Uri, onlyIds: Set<String>? = null): Int = withContext(Dispatchers.IO) {
        val ps = _projects.value.filter { onlyIds == null || it.id in onlyIds }
        val used = ps.flatMap { p -> p.layers.mapNotNull { it.src } }.filter { it.startsWith("media:") }.map { it.removePrefix("media:") }.toSet()
        ctx.contentResolver.openOutputStream(out, "wt")!!.bufferedWriter().use { w ->
            w.write("{\"app\":\"warden-motion\",\"v\":1,\"date\":${System.currentTimeMillis()},\"projects\":")
            w.write(JSON.encodeToString(kotlinx.serialization.builtins.ListSerializer(Project.serializer()), ps))
            w.write(",\"media\":{")
            var first = true
            for (id in used) {
                val f = mediaFile(id)
                if (!f.exists()) continue
                if (!first) w.write(",")
                first = false
                val mime = sniffMime(f)
                w.write("\"$id\":\"data:$mime;base64,")
                w.write(Base64.encodeToString(f.readBytes(), Base64.NO_WRAP))
                w.write("\"")
            }
            w.write("},\"pack\":{\"index\":[],\"folders\":[]},\"flags\":[]")
            if (onlyIds == null) w.write(",\"profile\":{\"name\":${org.json.JSONObject.quote(_profile.value.name)}}")
            w.write("}")
        }
        if (onlyIds == null) setProfile(_profile.value.copy(lastBackup = System.currentTimeMillis()))
        ps.size
    }

    /** Dosyanın türü (ilk baytlarından) */
    fun sniffMime(f: File): String {
        val h = ByteArray(12); f.inputStream().use { it.read(h) }
        fun at(i: Int, vararg b: Int) = b.withIndex().all { (j, v) -> h[i + j].toInt() and 0xFF == v }
        return when {
            at(0, 0x89, 0x50, 0x4E, 0x47) -> "image/png"
            at(0, 0xFF, 0xD8) -> "image/jpeg"
            at(0, 0x47, 0x49, 0x46) -> "image/gif"
            at(0, 0x52, 0x49, 0x46, 0x46) && at(8, 0x57, 0x45, 0x42, 0x50) -> "image/webp"
            at(0, 0x52, 0x49, 0x46, 0x46) -> "audio/wav"
            at(4, 0x66, 0x74, 0x79, 0x70) -> if (at(8, 0x4D, 0x34, 0x41)) "audio/mp4" else "video/mp4"
            at(0, 0x49, 0x44, 0x33) || (h[0].toInt() and 0xFF == 0xFF && (h[1].toInt() and 0xE0) == 0xE0 && (h[1].toInt() and 0x06) != 0) -> "audio/mpeg"
            at(0, 0xFF, 0xF1) || at(0, 0xFF, 0xF9) -> "audio/aac"
            at(0, 0x66, 0x4C, 0x61, 0x43) -> "audio/flac"
            at(0, 0x23, 0x21, 0x41, 0x4D, 0x52) -> "audio/amr"
            at(0, 0x4F, 0x67, 0x67) -> "audio/ogg"
            at(0, 0x1A, 0x45, 0xDF, 0xA3) -> "video/webm"
            else -> "application/octet-stream"
        }
    }

    suspend fun load() = withContext(Dispatchers.IO) {
        val list = projDir.listFiles { f -> f.extension == "json" }.orEmpty().mapNotNull { f ->
            runCatching { migrateProject(JSON.decodeFromString(Project.serializer(), f.readText())) }.getOrNull()
        }
        _projects.value = list.sortedByDescending { it.updatedAt }
    }

    suspend fun save(p: Project, touch: Boolean = true) = withContext(Dispatchers.IO) {
        val q = if (touch) p.copy(updatedAt = System.currentTimeMillis()) else p
        val tmp = File(projDir, "${q.id}.json.tmp")
        tmp.writeText(JSON.encodeToString(Project.serializer(), q))
        tmp.renameTo(File(projDir, "${q.id}.json"))
        _projects.value = (listOf(q) + _projects.value.filter { it.id != q.id }).sortedByDescending { it.updatedAt }
    }

    suspend fun delete(id: String) = withContext(Dispatchers.IO) {
        File(projDir, "$id.json").delete()
        _projects.value = _projects.value.filter { it.id != id }
    }

    suspend fun duplicate(p: Project) = save(p.copy(id = uid(), name = "${p.name} (kopya)".take(40)))

    fun mediaFile(id: String) = File(mediaDir, id)

    /** Dosyayı (galeriden, dosyalardan) projeye alır: asıl hâli saklanır, 'media:<id>' döner */
    suspend fun putMedia(uri: Uri): String = withContext(Dispatchers.IO) {
        val id = uid()
        ctx.contentResolver.openInputStream(uri)!!.use { inp -> mediaFile(id).outputStream().use { inp.copyTo(it) } }
        "media:$id"
    }

    data class ImportResult(val projects: Int, val media: Int, val names: List<String>)

    /** Eski uygulamanın yedeğini (Hesap > Yedekle ya da proje dosyası) içe aktarır */
    suspend fun importBackup(uri: Uri): ImportResult = withContext(Dispatchers.IO) {
        val text = ctx.contentResolver.openInputStream(uri)!!.use { it.readBytes().decodeToString() }
        val b = JSON.decodeFromString(Backup.serializer(), text)
        require(b.app == "warden-motion") { "Bu bir Warden Motion yedeği değil." }
        var media = 0
        for ((k, dataUrl) in b.media) {
            val comma = dataUrl.indexOf(',')
            if (comma < 0) continue
            runCatching {
                mediaFile(k).writeBytes(Base64.decode(dataUrl.substring(comma + 1), Base64.DEFAULT))
                media++
            }
        }
        val have = _projects.value.map { it.id }.toSet()
        for (p0 in b.projects) { val p = migrateProject(p0); save(if (p.id in have) p.copy(id = uid(), name = "${p.name} (dosyadan)".take(40)) else p, touch = false) }
        runCatching { b.profile?.let { pr -> val n = (pr as kotlinx.serialization.json.JsonObject)["name"]?.toString()?.trim('"'); if (!n.isNullOrBlank() && _profile.value.name.isBlank()) setProfile(_profile.value.copy(name = n)) } }
        ImportResult(b.projects.size, media, b.projects.map { it.name })
    }

    /** Eski efekt ayarlarını yeni kataloğa çevirir */
    private fun migrateProject(p: Project): Project { com.warden.motion.app.model.FxCatalog.init(ctx); return p.copy(layers = p.layers.map { l -> if (l.effects.isEmpty()) l else l.copy(effects = l.effects.map { com.warden.motion.app.model.migrateEffect(it) }) }) }

    companion object {
        @Volatile private var inst: Store? = null
        fun get(ctx: Context) = inst ?: synchronized(this) { inst ?: Store(ctx.applicationContext).also { inst = it } }
    }
}
