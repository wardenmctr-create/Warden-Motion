package com.warden.motion.app.data

import android.Manifest
import android.content.ContentResolver
import android.content.ContentUris
import android.content.Context
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.DocumentsContract
import android.provider.MediaStore
import android.util.LruCache
import android.util.Size
import androidx.core.content.ContextCompat
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

/** Telefondaki bir fotoğraf / video / ses */
data class GItem(val id: Long, val uri: Uri, val video: Boolean, val audio: Boolean, val mime: String, val name: String, val album: String, val durationMs: Long) {
    val key get() = uri.toString()
}

/** Telefonun medya dizini (MediaStore): AM gibi doğrudan okunur, kopyalanmaz */
object MediaQuery {
    fun visualPerms(): Array<String> = when {
        Build.VERSION.SDK_INT >= 34 -> arrayOf(Manifest.permission.READ_MEDIA_IMAGES, Manifest.permission.READ_MEDIA_VIDEO, Manifest.permission.READ_MEDIA_VISUAL_USER_SELECTED)
        Build.VERSION.SDK_INT >= 33 -> arrayOf(Manifest.permission.READ_MEDIA_IMAGES, Manifest.permission.READ_MEDIA_VIDEO)
        else -> arrayOf(Manifest.permission.READ_EXTERNAL_STORAGE)
    }
    fun audioPerms(): Array<String> = if (Build.VERSION.SDK_INT >= 33) arrayOf(Manifest.permission.READ_MEDIA_AUDIO) else arrayOf(Manifest.permission.READ_EXTERNAL_STORAGE)
    private fun granted(ctx: Context, p: String) = ContextCompat.checkSelfPermission(ctx, p) == PackageManager.PERMISSION_GRANTED

    /** "full", "partial" (sadece seçtikleri) ya da "none" */
    fun visualAccess(ctx: Context): String = when {
        Build.VERSION.SDK_INT >= 33 && (granted(ctx, Manifest.permission.READ_MEDIA_IMAGES) || granted(ctx, Manifest.permission.READ_MEDIA_VIDEO)) -> "full"
        Build.VERSION.SDK_INT >= 34 && granted(ctx, Manifest.permission.READ_MEDIA_VISUAL_USER_SELECTED) -> "partial"
        Build.VERSION.SDK_INT < 33 && granted(ctx, Manifest.permission.READ_EXTERNAL_STORAGE) -> "full"
        else -> "none"
    }
    fun audioAccess(ctx: Context) = audioPerms().all { granted(ctx, it) }

    private fun query(ctx: Context, base: Uri, cols: Array<String>, sel: String, args: Array<String>?, order: String, offset: Int, limit: Int) =
        if (Build.VERSION.SDK_INT >= 26) ctx.contentResolver.query(base, cols, Bundle().apply {
            putString(ContentResolver.QUERY_ARG_SQL_SELECTION, sel)
            if (args != null) putStringArray(ContentResolver.QUERY_ARG_SQL_SELECTION_ARGS, args)
            putString(ContentResolver.QUERY_ARG_SQL_SORT_ORDER, order)
            putInt(ContentResolver.QUERY_ARG_LIMIT, limit); putInt(ContentResolver.QUERY_ARG_OFFSET, offset)
        }, null)
        else ctx.contentResolver.query(base, cols, sel, args, "$order LIMIT $limit OFFSET $offset")

    /** kind: image | video | any ; album: klasör adı ("" = hepsi) */
    suspend fun visual(ctx: Context, kind: String, album: String, offset: Int, limit: Int): List<GItem> = withContext(Dispatchers.IO) {
        val img = MediaStore.Files.FileColumns.MEDIA_TYPE_IMAGE; val vid = MediaStore.Files.FileColumns.MEDIA_TYPE_VIDEO
        var sel = when (kind) { "image" -> "media_type=$img"; "video" -> "media_type=$vid"; else -> "media_type IN ($img,$vid)" }
        var args: Array<String>? = null
        if (album.isNotEmpty()) { sel += " AND bucket_display_name=?"; args = arrayOf(album) }
        val cols = arrayOf(MediaStore.Files.FileColumns._ID, MediaStore.Files.FileColumns.MEDIA_TYPE, MediaStore.Files.FileColumns.MIME_TYPE, MediaStore.Files.FileColumns.DISPLAY_NAME, "bucket_display_name", "duration")
        val out = ArrayList<GItem>()
        runCatching {
            query(ctx, MediaStore.Files.getContentUri("external"), cols, sel, args, MediaStore.Files.FileColumns.DATE_ADDED + " DESC", offset, limit)?.use { c ->
                val di = c.getColumnIndex("duration")
                while (c.moveToNext()) {
                    val id = c.getLong(0); val isVid = c.getInt(1) == vid
                    val uri = ContentUris.withAppendedId(if (isVid) MediaStore.Video.Media.EXTERNAL_CONTENT_URI else MediaStore.Images.Media.EXTERNAL_CONTENT_URI, id)
                    out += GItem(id, uri, isVid, false, c.getString(2) ?: "", c.getString(3) ?: "", c.getString(4) ?: "", if (di >= 0) c.getLong(di) else 0)
                }
            }
        }
        out
    }

    suspend fun audio(ctx: Context, album: String, offset: Int, limit: Int): List<GItem> = withContext(Dispatchers.IO) {
        var sel = MediaStore.Audio.Media.SIZE + ">0"
        var args: Array<String>? = null
        if (album.isNotEmpty() && Build.VERSION.SDK_INT >= 29) { sel += " AND bucket_display_name=?"; args = arrayOf(album) }
        val cols = arrayOf(MediaStore.Audio.Media._ID, MediaStore.Audio.Media.MIME_TYPE, MediaStore.Audio.Media.DISPLAY_NAME, "duration")
        val out = ArrayList<GItem>()
        runCatching {
            query(ctx, MediaStore.Audio.Media.EXTERNAL_CONTENT_URI, cols, sel, args, MediaStore.Audio.Media.DATE_ADDED + " DESC", offset, limit)?.use { c ->
                while (c.moveToNext()) {
                    val id = c.getLong(0)
                    out += GItem(id, ContentUris.withAppendedId(MediaStore.Audio.Media.EXTERNAL_CONTENT_URI, id), false, true, c.getString(1) ?: "", c.getString(2) ?: "", "", c.getLong(3))
                }
            }
        }
        out
    }

    /** Klasörler (Camera, WhatsApp Images, Download…) ve içlerindeki dosya sayısı */
    suspend fun albums(ctx: Context, audio: Boolean): List<Pair<String, Int>> = withContext(Dispatchers.IO) {
        if (audio && Build.VERSION.SDK_INT < 29) return@withContext emptyList()
        val m = LinkedHashMap<String, Int>()
        val (uri, sel) = if (audio) MediaStore.Audio.Media.EXTERNAL_CONTENT_URI to (MediaStore.Audio.Media.SIZE + ">0")
        else MediaStore.Files.getContentUri("external") to "media_type IN (${MediaStore.Files.FileColumns.MEDIA_TYPE_IMAGE},${MediaStore.Files.FileColumns.MEDIA_TYPE_VIDEO})"
        runCatching {
            ctx.contentResolver.query(uri, arrayOf("bucket_display_name"), sel, null, "date_added DESC")?.use { c ->
                while (c.moveToNext()) { val b = c.getString(0) ?: continue; m[b] = (m[b] ?: 0) + 1 }
            }
        }
        m.toList()
    }

    // ---------- Kullanıcının eklediği klasörler (SAF ağacı) ----------
    suspend fun folder(ctx: Context, tree: Uri, kind: String, offset: Int, limit: Int): List<GItem> = withContext(Dispatchers.IO) {
        val all = ArrayList<Pair<GItem, Long>>()
        fun walk(docId: String, depth: Int) {
            if (depth > 4 || all.size > 3000) return
            val kids = DocumentsContract.buildChildDocumentsUriUsingTree(tree, docId)
            runCatching {
                ctx.contentResolver.query(kids, arrayOf(DocumentsContract.Document.COLUMN_DOCUMENT_ID, DocumentsContract.Document.COLUMN_DISPLAY_NAME, DocumentsContract.Document.COLUMN_MIME_TYPE, DocumentsContract.Document.COLUMN_LAST_MODIFIED), null, null, null)?.use { c ->
                    while (c.moveToNext()) {
                        val id = c.getString(0); val name = c.getString(1) ?: ""; val mime = c.getString(2) ?: continue
                        if (mime == DocumentsContract.Document.MIME_TYPE_DIR) { walk(id, depth + 1); continue }
                        val ok = when (kind) { "audio" -> mime.startsWith("audio/"); "image" -> mime.startsWith("image/"); "video" -> mime.startsWith("video/"); else -> mime.startsWith("image/") || mime.startsWith("video/") }
                        if (!ok) continue
                        val u = DocumentsContract.buildDocumentUriUsingTree(tree, id)
                        all += GItem(u.hashCode().toLong(), u, mime.startsWith("video/"), mime.startsWith("audio/"), mime, name, "", 0) to (if (c.isNull(3)) 0L else c.getLong(3))
                    }
                }
            }
        }
        runCatching { walk(DocumentsContract.getTreeDocumentId(tree), 0) }
        all.sortedByDescending { it.second }.drop(offset).take(limit).map { it.first }
    }

    fun folderName(ctx: Context, tree: Uri): String = runCatching {
        val doc = DocumentsContract.buildDocumentUriUsingTree(tree, DocumentsContract.getTreeDocumentId(tree))
        ctx.contentResolver.query(doc, arrayOf(DocumentsContract.Document.COLUMN_DISPLAY_NAME), null, null, null)?.use { if (it.moveToFirst()) it.getString(0) else null }
    }.getOrNull() ?: "Klasör"

    // ---------- Küçük resimler (telefonun kendi önbelleğinden) ----------
    private val thumbs = object : LruCache<String, Bitmap>(32 * 1024 * 1024) { override fun sizeOf(key: String, value: Bitmap) = value.byteCount }
    fun cachedThumb(it: GItem) = thumbs.get(it.key)
    suspend fun thumb(ctx: Context, it: GItem, px: Int = 240): Bitmap? = withContext(Dispatchers.IO) {
        thumbs.get(it.key)?.let { b -> return@withContext b }
        val b = runCatching {
            if (Build.VERSION.SDK_INT >= 29) ctx.contentResolver.loadThumbnail(it.uri, Size(px, px), null)
            else if (it.video) MediaStore.Video.Thumbnails.getThumbnail(ctx.contentResolver, it.id, MediaStore.Video.Thumbnails.MINI_KIND, null)
            else MediaStore.Images.Thumbnails.getThumbnail(ctx.contentResolver, it.id, MediaStore.Images.Thumbnails.MINI_KIND, null)
        }.getOrNull() ?: runCatching { DocumentsContract.getDocumentThumbnail(ctx.contentResolver, it.uri, android.graphics.Point(px, px), null) }.getOrNull()
        ?: runCatching {
            if (it.video) android.media.MediaMetadataRetriever().let { r -> try { r.setDataSource(ctx, it.uri); r.getFrameAtTime(0) } finally { r.release() } }
            else ctx.contentResolver.openInputStream(it.uri)?.use { s -> android.graphics.BitmapFactory.decodeStream(s, null, android.graphics.BitmapFactory.Options().apply { inSampleSize = 8 }) }
        }.getOrNull()
        if (b != null) thumbs.put(it.key, b)
        b
    }
}
