package com.warden.motion.app

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.runtime.*
import androidx.compose.runtime.saveable.rememberSaveable
import com.warden.motion.app.data.Store
import com.warden.motion.app.model.Project
import com.warden.motion.app.render.Renderer
import com.warden.motion.app.ui.EditorScreen
import com.warden.motion.app.ui.GlowTheme
import com.warden.motion.app.ui.HomeScreen
import com.warden.motion.app.ui.LocalRenderer
import com.warden.motion.app.ui.Tab
import com.warden.motion.app.ui.UiState
import com.warden.motion.app.ui.OverlayHost
import com.warden.motion.app.ui.AssistantLayer
import androidx.compose.foundation.layout.fillMaxSize
import kotlinx.coroutines.launch

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        com.warden.motion.app.model.FxCatalog.init(this)
        com.warden.motion.app.render.GlFx.init(this)
        val store = Store.get(this)
        val renderer = Renderer(this)
        setContent {
            GlowTheme {
                CompositionLocalProvider(LocalRenderer provides renderer) {
                    val scope = rememberCoroutineScope()
                    LaunchedEffect(Unit) { store.load() }
                    var tab by rememberSaveable { mutableStateOf(Tab.HOME) }
                    var open by remember { mutableStateOf<Project?>(null) }
                    val cur = open
                    androidx.compose.foundation.layout.Box(androidx.compose.ui.Modifier.fillMaxSize()) {
                        if (cur == null) HomeScreen(store, tab, { tab = it }) { p -> scope.launch { if (store.projects.value.none { it.id == p.id }) store.save(p) }; open = p }
                        else androidx.compose.runtime.key(cur.id) { EditorScreen(cur) { open = null; UiState.screen = when (tab) { Tab.HOME -> "home"; Tab.TUTORIALS -> "tutorials"; Tab.ACCOUNT -> "account" } } }
                        // Açılan pencereler ve WardenCB her şeyin üstünde
                        OverlayHost()
                        AssistantLayer()
                    }
                }
            }
        }
    }
}
