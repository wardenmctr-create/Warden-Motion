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
    fun setLite(on: Boolean) { prefs.edit().putBoolean("lite", on).apply(); _lite.value = on }

    suspend fun load() = withContext(Dispatchers.IO) {
        val list = projDir.listFiles { f -> f.extension == "json" }.orEmpty().mapNotNull { f ->
            runCatching { JSON.decodeFromString(Project.serializer(), f.readText()) }.getOrNull()
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
        for (p in b.projects) save(if (p.id in have) p.copy(id = uid(), name = "${p.name} (yedekten)".take(40)) else p, touch = false)
        ImportResult(b.projects.size, media, b.projects.map { it.name })
    }

    companion object {
        @Volatile private var inst: Store? = null
        fun get(ctx: Context) = inst ?: synchronized(this) { inst ?: Store(ctx.applicationContext).also { inst = it } }
    }
}
