package com.example.recalie

import android.content.ActivityNotFoundException
import android.content.Intent
import android.webkit.MimeTypeMap
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.example.recalie/attachments",
        ).setMethodCallHandler { call, result ->
            if (call.method != "openFile") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            val path = call.argument<String>("path")
            if (path.isNullOrBlank()) {
                result.error("missing_path", "The attachment path is missing.", null)
                return@setMethodCallHandler
            }
            openAttachment(path, result)
        }
    }

    private fun openAttachment(path: String, result: MethodChannel.Result) {
        val file = File(path)
        if (!file.exists()) {
            result.error("missing_file", "The attachment could not be prepared.", null)
            return
        }
        val extension = file.extension.lowercase()
        val mimeType = MimeTypeMap.getSingleton()
            .getMimeTypeFromExtension(extension)
            ?: "application/octet-stream"
        val uri = FileProvider.getUriForFile(
            this,
            "${applicationContext.packageName}.recalie_file_provider",
            file,
        )
        val intent = Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(uri, mimeType)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        try {
            startActivity(Intent.createChooser(intent, "Open attachment"))
            result.success(null)
        } catch (_: ActivityNotFoundException) {
            result.error(
                "no_compatible_app",
                "No compatible app is installed for this file type.",
                null,
            )
        } catch (error: Exception) {
            result.error("open_failed", error.message ?: "Could not open attachment.", null)
        }
    }
}
