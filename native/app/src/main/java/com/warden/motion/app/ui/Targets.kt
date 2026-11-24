package com.warden.motion.app.ui

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateMapOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.composed
import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.layout.boundsInWindow
import androidx.compose.ui.layout.onGloballyPositioned

/**
 * Asistanın ekranı "okuması": önemli düğmeler bir kimlikle kaydedilir (yeri + dokununca ne yapacağı).
 * WardenCB gerçek düğmeyi bu sayede bulur, halkayla gösterir, "Anlamadım" deyince ona kendisi dokunur.
 */
object Targets {
    val rects = mutableStateMapOf<String, Rect>()
    val taps = HashMap<String, () -> Unit>()
    fun rect(id: String): Rect? = rects[id]?.takeIf { it.width > 0 && it.height > 0 }
    fun has(id: String) = rect(id) != null
    fun tap(id: String) { taps[id]?.invoke() }
}

fun Modifier.target(id: String, onTap: (() -> Unit)? = null): Modifier = composed {
    val tap by rememberUpdatedState(onTap)
    DisposableEffect(id) {
        if (tap != null) Targets.taps[id] = { tap?.invoke() }
        onDispose { Targets.rects.remove(id); Targets.taps.remove(id) }
    }
    this.onGloballyPositioned { c -> val r = c.boundsInWindow(); if (Targets.rects[id] != r) Targets.rects[id] = r }
}

/** Uygulamanın o anki hâli (asistan için) */
object UiState {
    var screen by mutableStateOf("home") // home | tutorials | account | editor
    var drawer by mutableStateOf(false)
    var sheet by mutableStateOf(false)
    var editor by mutableStateOf<EditorState?>(null)
    /** Açık panel başlığı (Taşı ve Çevir, Efektler…) ya da "add" */
    var panel by mutableStateOf<String?>(null)
    var addTab by mutableStateOf<String?>(null)
    var fxb by mutableStateOf(false)
    var menu by mutableStateOf(false)
    var multi by mutableStateOf(false)
    /** Açık seçim penceresindeki düğmeler */
    var choice by mutableStateOf<List<String>?>(null)
    /** Ana ekrandaki eylemler (proje aç, sekme) */
    var openProject: (String) -> Unit = {}
    var openNew: (com.warden.motion.app.model.Project) -> Unit = {}
    var setTab: (Tab) -> Unit = {}
}

// ---------------------------------------------------------------------------------------------
// Pencere katmanı: açılan pencereler ana ağacın en üstünde çizilir (asistan hepsinin de üstünde)
// ---------------------------------------------------------------------------------------------
object Overlays {
    val items = mutableStateListOf<Pair<Any, @Composable () -> Unit>>()
}

@Composable
fun Overlay(content: @Composable () -> Unit) {
    val key = remember { Any() }
    val c by rememberUpdatedState(content)
    DisposableEffect(key) {
        val entry: Pair<Any, @Composable () -> Unit> = key to { c() }
        Overlays.items.add(entry)
        onDispose { Overlays.items.removeAll { it.first === key } }
    }
}

@Composable
fun OverlayHost() {
    for ((k, c) in Overlays.items.toList()) androidx.compose.runtime.key(k) { Box(Modifier.fillMaxSize()) { c() } }
}
