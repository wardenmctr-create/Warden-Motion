package com.warden.motion.app.ui

import androidx.compose.runtime.staticCompositionLocalOf
import com.warden.motion.app.render.Renderer

/** Uygulama genelinde tek çizim motoru (görsel önbelleği paylaşılır) */
val LocalRenderer = staticCompositionLocalOf<Renderer> { error("Renderer yok") }
