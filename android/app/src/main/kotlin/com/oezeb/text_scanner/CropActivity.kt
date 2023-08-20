package com.oezeb.text_scanner

import android.os.Bundle
import android.view.Menu
import android.view.MenuInflater
import android.view.MenuItem
import android.widget.Button
import androidx.appcompat.app.AppCompatActivity


class CropActivity : AppCompatActivity() {
    private var mFragment: RectFragment? = null

    fun setCurrentFragment(fragment: RectFragment?) {
        mFragment = fragment
        mFragment?.setImageUri(intent.data)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_crop)
        title = "Crop Image"
        supportFragmentManager
            .beginTransaction()
            .replace(R.id.container, RectFragment())
            .commit()

        findViewById<Button>(R.id.save_crop).apply {
            setOnClickListener() {
                mFragment?.saveCropped()
            }
        }

        findViewById<Button>(R.id.cancel_crop).apply {
            setOnClickListener() {
                finish()
            }
        }
    }

    override fun onCreateOptionsMenu(menu: Menu?): Boolean {
        val inflater: MenuInflater = menuInflater
        inflater.inflate(R.menu.main, menu)
        return true
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        return if (mFragment?.onOptionsItemSelected(item) == true) {
            true
        } else super.onOptionsItemSelected(item)
    }
}