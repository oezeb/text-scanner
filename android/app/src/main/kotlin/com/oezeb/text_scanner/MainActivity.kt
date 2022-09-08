package com.oezeb.text_scanner

import android.content.ActivityNotFoundException
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.ImageDecoder
import android.net.Uri
import android.provider.MediaStore
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import kotlin.concurrent.thread


class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.oezeb.text_scanner/channel"

    private var pickedImage: String? = null
    private var capturedImage: String? = null

    object RequestCode {
        const val PICK_IMAGE = 1
        const val CAPTURE_IMAGE = 2
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val tess = Tesseract(getExternalFilesDir(null)?.absolutePath)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "pickImage" -> pickImage(call, result)
                "captureImage" -> captureImage(call, result)
                "imageToString" -> imageToString(call, result, tess)
                "getExternalStorageDirectory" -> getExternalStorageDirectory(call, result)
                "getExternalCacheDirectory" -> getExternalCacheDirectory(call, result)
                "openUrl" -> openUrl(call, result)
                "shareText" -> shareText(call, result)
                else -> result.notImplemented()
            }
        }
    }

    override fun onResume() {
        super.onResume()
        if (capturedImage == "*") {
            capturedImage = null
        }
        if (pickedImage == "*") {
            pickedImage = null
        }
    }

    override fun onActivityReenter(resultCode: Int, data: Intent?) {
        super.onActivityReenter(resultCode, data)
        when (resultCode) {
            RequestCode.CAPTURE_IMAGE -> capturedImage = null
            RequestCode.PICK_IMAGE -> pickedImage = null
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, imageReturnedIntent: Intent?) {
        super.onActivityResult(requestCode, resultCode, imageReturnedIntent)
//        Log.v("[Request Code]: ", "$requestCode")
        when (requestCode) {
            RequestCode.CAPTURE_IMAGE -> if (resultCode == RESULT_OK) {
                val bp = imageReturnedIntent?.extras?.get("data") as Bitmap
                val file = File.createTempFile("capture_", ".jpg")
                capturedImage = try {
                    val out = FileOutputStream(file)
                    bp.compress(Bitmap.CompressFormat.JPEG, 100, out)
                    out.flush()
                    out.close()
                    file.absolutePath
                } catch (e: Exception) {
                    e.printStackTrace()
                    null
                }
            }
            RequestCode.PICK_IMAGE -> if (resultCode == RESULT_OK) {
                val uri = imageReturnedIntent?.data
                val bp = MediaStore.Images.Media.getBitmap(this.contentResolver, uri)
                val file = File.createTempFile("pick_", ".jpg")
                pickedImage = try {
                    val out = FileOutputStream(file)
                    bp.compress(Bitmap.CompressFormat.JPEG, 100, out)
                    out.flush()
                    out.close()
                    file.absolutePath
                } catch (e: Exception) {
                    e.printStackTrace()
                    null
                }
            }
        }
    }

    private fun pickImage(call: MethodCall, result: MethodChannel.Result) {
        pickedImage = "*"
        val intent = Intent(Intent.ACTION_GET_CONTENT, MediaStore.Images.Media.EXTERNAL_CONTENT_URI)
        intent.type = "image/*"
        startActivityForResult(intent, RequestCode.PICK_IMAGE)
        thread(start = true) {
            while (pickedImage == "*") {
                Thread.sleep(100)
            }
            result.success(pickedImage)
        }
    }

    private fun captureImage(call: MethodCall, result: MethodChannel.Result)  {
        capturedImage = "*"
        val intent = Intent(MediaStore.ACTION_IMAGE_CAPTURE_SECURE)
        startActivityForResult(intent, RequestCode.CAPTURE_IMAGE)
        thread(start = true) {
            while (capturedImage == "*") {
                Thread.sleep(100)
            }
            result.success(capturedImage)
        }
    }

    private fun getExternalStorageDirectory(call: MethodCall, result: MethodChannel.Result) {
        result.success(getExternalFilesDir(null)?.absolutePath)
    }

    private fun getExternalCacheDirectory(call: MethodCall, result: MethodChannel.Result) {
        result.success(externalCacheDir?.absolutePath)
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

