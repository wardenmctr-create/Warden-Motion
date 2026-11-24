package com.warden.motion.app.ui

import androidx.compose.runtime.Composable

@Composable fun MediaTab(s: EditorState, onAudio: () -> Unit, toast: (String) -> Unit, onPick: (String, String, String) -> Unit) {}
@Composable fun AudioTab(s: EditorState, toast: (String) -> Unit, onPick: (String, String) -> Unit) {}
@Composable fun ExportDialog(s: EditorState, onClose: () -> Unit, toast: (String) -> Unit) {}
@Composable fun TutorialOverlay(s: EditorState) {}
