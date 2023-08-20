package com.oezeb.text_scanner

import android.app.Activity
import android.content.Intent
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Bundle
import android.util.AttributeSet
import android.util.Log
import android.view.LayoutInflater
import android.view.MenuItem
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.fragment.app.Fragment
import com.theartofdev.edmodo.cropper.CropImageView
import com.theartofdev.edmodo.cropper.CropImageView.*

/** The fragment that will show the Image Cropping UI by requested preset.  */
class RectFragment : Fragment(), OnSetImageUriCompleteListener, OnCropImageCompleteListener {
    private var mCropImageView: CropImageView? = null

    /** Set the image to show for cropping.  */
    fun setImageUri(imageUri: Uri?) {
        mCropImageView?.setImageBitmap(BitmapFactory.decodeFile(imageUri?.path))
        mCropImageView?.cropRect = mCropImageView?.wholeImageRect
    }

    fun saveCropped() {
        mCropImageView?.getCroppedImageAsync()
    }

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?
    ): View? {
        return inflater.inflate(R.layout.fragment_rect, container, false)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        mCropImageView = CropImageView(view.context)
        mCropImageView = view.findViewById(R.id.cropImageView)
        mCropImageView?.setOnSetImageUriCompleteListener(this)
        mCropImageView?.setOnCropImageCompleteListener(this)
        (activity as CropActivity).setCurrentFragment(this)
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        return when (item.itemId) {
            R.id.main_action_rotate -> {
                mCropImageView!!.rotateImage(90)
                true
            }
            else -> super.onOptionsItemSelected(item)
        }
    }

    override fun onDetach() {
        super.onDetach()
        if (mCropImageView != null) {
            mCropImageView!!.setOnSetImageUriCompleteListener(null)
            mCropImageView!!.setOnCropImageCompleteListener(null)
        }
    }

    override fun onSetImageUriComplete(view: CropImageView, uri: Uri, error: Exception?) {
        if (error == null) {
            Toast.makeText(activity, "Image load successful", Toast.LENGTH_SHORT).show()
        } else {
            Log.e("AIC", "Failed to load image by URI", error)
            Toast.makeText(activity, "Image load failed: " + error.message, Toast.LENGTH_LONG)
                .show()
        }
    }

    override fun onCropImageComplete(view: CropImageView, result: CropResult) {
        val file = saveBitmapTemp(result.bitmap, "cropped_")
        val data = Intent().apply {
            data = Uri.parse(file?.absolutePath)
        }
        (activity as CropActivity).setResult(Activity.RESULT_OK, data)
        // close the activity
        (activity as CropActivity).finish()
    }
}