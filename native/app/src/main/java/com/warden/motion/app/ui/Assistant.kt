package com.warden.motion.app.ui

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.setValue

const val APP_VERSION = "Glow 0.2"

/** WardenCB asistanı (tanışma, turlar, öğreticiler). */
object Assistant {
    var replay by mutableIntStateOf(0)
    fun replayIntro() { replay++ }
}
