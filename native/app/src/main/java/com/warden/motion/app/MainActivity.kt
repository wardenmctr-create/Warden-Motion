package com.warden.motion.app

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.runtime.*
import com.warden.motion.app.data.Store
import com.warden.motion.app.model.Project
import com.warden.motion.app.render.Renderer
import com.warden.motion.app.ui.EditorScreen
import com.warden.motion.app.ui.GlowTheme
import com.warden.motion.app.ui.HomeScreen
import com.warden.motion.app.ui.LocalRenderer

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        val store = Store.get(this)
        val renderer = Renderer(this)
        setContent {
            GlowTheme {
                CompositionLocalProvider(LocalRenderer provides renderer) {
                    LaunchedEffect(Unit) { store.load() }
                    var open by remember { mutableStateOf<Project?>(null) }
                    val cur = open
                    if (cur == null) HomeScreen(store) { open = it }
                    else EditorScreen(cur) { open = null }
                }
            }
        }
    }
}
