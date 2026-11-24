package com.warden.motion.app.data

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import androidx.core.content.FileProvider
import java.io.File

/** Dosya paylaşma: Google Drive'a, ya da paylaşım menüsüyle başka uygulamalara */
object Share {
    const val DRIVE = "com.google.android.apps.docs"
    fun has(ctx: Context, pkg: String) = runCatching { ctx.packageManager.getPackageInfo(pkg, 0); true }.getOrDefault(false)

    fun shareDir(ctx: Context) = File(ctx.cacheDir, "share").apply { mkdirs() }

    /** f: cacheDir/share içindeki dosya. pkg verilirse doğrudan o uygulamaya (ör. Drive) */
    fun send(ctx: Context, f: File, mime: String, pkg: String? = null, title: String = "Gönder") {
        val uri = FileProvider.getUriForFile(ctx, ctx.packageName + ".files", f)
        val i = Intent(Intent.ACTION_SEND).apply {
            type = mime
            putExtra(Intent.EXTRA_STREAM, uri)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            if (pkg != null) setPackage(pkg)
        }
        val start = if (pkg != null) i else Intent.createChooser(i, title)
        start.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        ctx.startActivity(start)
    }

    @Suppress("unused") private fun pm(ctx: Context): PackageManager = ctx.packageManager
}
