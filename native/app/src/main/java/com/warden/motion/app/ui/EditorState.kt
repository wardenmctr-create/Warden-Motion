package com.warden.motion.app.ui

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableDoubleStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import com.warden.motion.app.data.Store
import com.warden.motion.app.model.Anim
import com.warden.motion.app.model.Layer
import com.warden.motion.app.model.Project
import com.warden.motion.app.model.uid
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

/** Editörün durumu (eski uygulamadaki zustand deposunun karşılığı): proje, geri al/yinele, seçim, zaman */
class EditorState(initial: Project, private val store: Store, private val scope: CoroutineScope) {
    var project by mutableStateOf(initial); private set
    var past by mutableStateOf(listOf<Project>()); private set
    var future by mutableStateOf(listOf<Project>()); private set
    var selectedId by mutableStateOf<String?>(null)
    var multi by mutableStateOf<List<String>?>(null)
    /** Zaman (sn). Oynatırken her karede değişir: sadece çizim sırasında okunmalı */
    var time by mutableDoubleStateOf(0.0)
    var playing by mutableStateOf(false)
    /** Zaman çizelgesinde bir tutamaç / keyframe / satır sürükleniyor: çizelge kaymasın */
    @Volatile var tlGrab = false
    /** Açık panelin işine ait işaretleyici grupları (diğerleri soluk) */
    var kfFocus by mutableStateOf<List<String>?>(null)
    /** Efekt panelinde seçili parametre: (efekt id, anahtar) */
    var fxParam by mutableStateOf<Pair<String, String>?>(null)

    val sel: Layer? get() = project.layers.find { it.id == selectedId }

    private var saveJob: Job? = null
    private fun scheduleSave(p: Project) {
        saveJob?.cancel()
        saveJob = scope.launch { delay(400); store.save(p) }
    }
    fun flush() { saveJob?.cancel(); val p = project; scope.launch { store.save(p) } }

    fun update(commit: Boolean = true, fn: (Project) -> Project) {
        val cur = project
        val next = fn(cur).copy(updatedAt = System.currentTimeMillis())
        if (commit) { past = (past + cur).takeLast(50); future = emptyList() }
        project = next
        scheduleSave(next)
    }
    /** Sürükleme başlarken: mevcut hâli geri alma geçmişine yazar */
    fun checkpoint() { past = (past + project).takeLast(50); future = emptyList() }
    fun updateLayer(id: String, commit: Boolean = true, fn: (Layer) -> Layer) = update(commit) { p -> p.copy(layers = p.layers.map { if (it.id == id) fn(it) else it }) }
    fun addLayer(l: Layer) { val id = uid(); update { p -> p.copy(layers = p.layers + l.copy(id = id)) }; selectedId = id }
    fun addLayers(ls: List<Layer>, select: String? = null) { update { p -> p.copy(layers = p.layers + ls) }; selectedId = select ?: ls.lastOrNull()?.id }
    fun removeLayer(id: String) { update { p -> p.copy(layers = p.layers.filter { it.id != id }) }; selectedId = null }
    fun duplicateLayer(id: String) {
        val l = project.layers.find { it.id == id } ?: return
        val copy = l.copy(id = uid(), name = l.name + " Kopya", x = Anim(l.x.v + 30, l.x.k?.map { it.copy(v = it.v + 30) }))
        update { p -> p.copy(layers = p.layers + copy) }
        selectedId = copy.id
    }
    fun undo() {
        if (past.isEmpty()) return
        val prev = past.last()
        future = listOf(project) + future; past = past.dropLast(1); project = prev
        scheduleSave(prev)
    }
    fun redo() {
        if (future.isEmpty()) return
        val next = future.first()
        past = past + project; future = future.drop(1); project = next
        scheduleSave(next)
    }
    fun setTimeSnap(t: Double) { time = maxOf(0.0, t) }
}
