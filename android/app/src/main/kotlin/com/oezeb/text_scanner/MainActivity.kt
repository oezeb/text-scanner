package com.oezeb.text_scanner

import android.content.ActivityNotFoundException
import android.content.Intent
import android.graphics.Bitmap
import android.net.Uri
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import kotlin.concurrent.thread

fun saveBitmap(bitmap: Bitmap, file: File) {
    val out = FileOutputStream(file)
    bitmap.compress(Bitmap.CompressFormat.JPEG, 100, out)
    out.flush()
    out.close()
}

fun saveBitmapTemp(bitmap: Bitmap, name_prefix: String = "file_") : File? {
    val file = File.createTempFile(name_prefix, ".jpg")
    return try {
        saveBitmap(bitmap, file)
        file
    } catch (e: Exception) {
        e.printStackTrace()
        null
    }
}

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.oezeb.text_scanner/channel"

    private var pickedImage: String? = null
    private var capturedImage: String? = null
    private var croppedImage: String? = null

    object RequestCode {
        const val PICK_IMAGE = 1
        const val CAPTURE_IMAGE = 2
        const val CROP_IMAGE = 3
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val versionName = try {
            val info = context.packageManager.getPackageInfo(context.packageName, 0)
            info.versionName
        } catch (e: Exception) {
            null
        }
        val tess = Tesseract(getExternalFilesDir(null)?.absolutePath)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "pickImage" -> pickImage(result)
                "captureImage" -> captureImage(result)
                "imageToString" -> imageToString(call, result, tess)
                "getExternalStorageDirectory" -> getExternalStorageDirectory(result)
                "getExternalCacheDirectory" -> getExternalCacheDirectory(result)
                "openUrl" -> openUrl(call, result)
                "shareText" -> shareText(call, result)
                "versionName" -> result.success(versionName)
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
        if (croppedImage == "*") {
            pickedImage = null
        }
    }

    override fun onActivityReenter(resultCode: Int, data: Intent?) {
        super.onActivityReenter(resultCode, data)
        when (resultCode) {
            RequestCode.CAPTURE_IMAGE -> capturedImage = null
            RequestCode.PICK_IMAGE -> pickedImage = null
            RequestCode.CROP_IMAGE -> croppedImage = null
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, intent: Intent?) {
        super.onActivityResult(requestCode, resultCode, intent)
        if (resultCode == RESULT_OK) {
            // Log.v("[Request Code]: ", "$requestCode")
            when (requestCode) {
                RequestCode.CAPTURE_IMAGE -> {
                    val bp = intent?.extras?.get("data") as Bitmap
                    val file = saveBitmapTemp(bp, "capture")
                    if (file != null) {
                        cropImage(file.absolutePath)
                        capturedImage = file.absolutePath
                    } else  {
                        capturedImage = null
                        croppedImage = null
                    }
                }
                RequestCode.PICK_IMAGE -> {
                    val bp = MediaStore.Images.Media.getBitmap(this.contentResolver, intent?.data)
                    val file = saveBitmapTemp(bp, "pick_")
                    if (file != null) {
                        cropImage(file.absolutePath)
                        pickedImage = file.absolutePath
                    } else  {
                        pickedImage = null
                        croppedImage = null
                    }
                }
                RequestCode.CROP_IMAGE -> {
                    croppedImage = intent?.data?.path
                }
            }
        }
    }

    private fun pickImage(result: MethodChannel.Result) {
        pickedImage = "*"
        val intent = Intent().apply {
            action = Intent.ACTION_GET_CONTENT
            setDataAndType(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, "image/*")
        }
        startActivityForResult(intent, RequestCode.PICK_IMAGE)
        thread(start = true) {
            while (pickedImage == "*" || croppedImage == "*") {
                Thread.sleep(100)
            }
            if (croppedImage != null) result.success(croppedImage)
            else result.success(pickedImage)
        }
    }

    private fun captureImage(result: MethodChannel.Result)  {
        capturedImage = "*"
        val intent = Intent(MediaStore.ACTION_IMAGE_CAPTURE_SECURE)
        startActivityForResult(intent, RequestCode.CAPTURE_IMAGE)
        thread(start = true) {
            while (capturedImage == "*" || croppedImage == "*") {
                Thread.sleep(100)
            }
            if (croppedImage != null) result.success(croppedImage)
            else result.success(capturedImage)
        }
    }

    private fun cropImage(imagePath: String) {
        croppedImage = "*"
        val intent = Intent(this@MainActivity, CropActivity::class.java).apply {
            data = Uri.parse(imagePath)
        }
        startActivityForResult(intent, RequestCode.CROP_IMAGE)
    }

    private fun getExternalStorageDirectory(result: MethodChannel.Result) {
        result.success(getExternalFilesDir(null)?.absolutePath)
    }

    private fun getExternalCacheDirectory(result: MethodChannel.Result) {
        result.success(externalCacheDir?.absolutePath)
    }

    private fun imageToString(call: MethodCall, result: MethodChannel.Result, tess: Tesseract) {
        val path = call.argument<String>("path")
        val lang = call.argument<String>("lang")
        if (path != null) {
            val file = File(path)
            try {
                tess.setLang(lang)
                result.success(tess.imageToString(file))
            } catch (e: Exception) {
                result.error("ERROR", e.message, null)
            }
        } else {
            result.error("ERROR", "No Image provided", null)
        }
    }

    private fun openUrl(call: MethodCall, result: MethodChannel.Result) {
        val url = call.argument<String>("url")
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
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

