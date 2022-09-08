package com.oezeb.text_scanner;

import com.googlecode.tesseract.android.TessBaseAPI;

import java.io.File;

public class Tesseract {
    String lang;
    TessBaseAPI tess;
    String dataPath;

    public Tesseract(String dataPath) {
        this(dataPath,"eng");
    }

    public Tesseract(String dataPath, String lang) {
        this.lang = lang;
        this.dataPath = new File(dataPath, "tesseract").getAbsolutePath();
        new File(this.dataPath, "tessdata").mkdirs();
    }

    public void setLang(String lang) throws Exception {
        if (this.lang != lang || tess == null) {
            tess = new TessBaseAPI();
            if (!tess.init(dataPath, lang)) {
                tess.recycle();
                tess = null;
                throw new Exception("Error: Tesseract could not initialize");
            } else {
                this.lang = lang;
            }
        }
    }

    public String imageToString(File img) throws Exception {
        setLang(lang);
        tess.setImage(img);
        String text = tess.getUTF8Text();
        tess.recycle();
        return text;
    }
}
