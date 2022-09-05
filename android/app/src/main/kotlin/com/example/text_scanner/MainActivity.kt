package com.example.text_scanner

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.oezeb.notepad/ocr_offline"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val tess = Tesseract(getExternalFilesDir(null)?.absolutePath)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "imageToString" -> imageToString(call, result, tess)
                "getExternalStorageDirectory" -> getExternalStorageDirectory(call, result)
                "openUrl" -> openUrl(call, result)
                "shareText" -> shareText(call, result)
                else -> result.notImplemented()
            }
        }
    }

    private fun getExternalStorageDirectory(call: MethodCall, result: MethodChannel.Result) {
        val dir = getExternalFilesDir(null)
        if (dir != null) {
            result.success(dir.absolutePath)
        } else {
            result.error("getExternalFilesDir error", "getExternalFilesDir error", null)
        }
    }

    private fun imageToString(call: MethodCall, result: MethodChannel.Result, tess: Tesseract) {
        val path = call.argument<String>("path")
        val lang = call.argument<String>("lang")
        val file = File(path)
        try {
            tess.setLang(lang)
            result.success(tess.imageToString(file))
        } catch (e: Exception) {
            result.error("ERROR", e.message, null)
        }
    }

    private fun openUrl(call: MethodCall, result: MethodChannel.Result) {
        val url = call.argument<String>("url")
        val intent: Intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
        try {
            startActivity(intent)
            result.success(true)
        } catch (e: ActivityNotFoundException) {
            // Define what your app should do if no activity can handle the intent.
            result.error("ERROR", e.message, null)
        }
    }

    private fun shareText(call: MethodCall, result: MethodChannel.Result) {
        val content = call.argument<String>("content")

        val intent: Intent = Intent().apply {
            action = Intent.ACTION_SEND
            putExtra(Intent.EXTRA_TEXT, content)
            type = "text/plain"
        }

        val chooser = Intent.createChooser(intent, null)

        try {
            startActivity(chooser)
            result.success(true)
        } catch (e: ActivityNotFoundException) {
            // Define what your app should do if no activity can handle the intent.
            result.error("ERROR", e.message, null)
        }

    }
}

