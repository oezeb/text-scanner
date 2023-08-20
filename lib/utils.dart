import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart';
import 'package:text_scanner/database.dart';
import 'package:text_scanner/models.dart';

final itemsdb = ItemsDatabase(path: ItemsDatabase.FILE_NAME);
final scanLangDownloaders = <String, LangManager>{};
late Map<String, Lang> scanLanguages;
late UserData userData;
late final String? versionName;
late final InterstitialAd interstitialAd;
const PLAY_STORE_URL =
    'https://play.google.com/store/apps/details?id=com.oezeb.text_scanner';

const BANNER_AD_UNIT_ID = 'ca-app-pub-6093428284595418/5496293393';
const INTERSTITIAL_AD_UNIT_ID = 'ca-app-pub-6093428284595418/1597674311';

Future<void> init() async {
  scanLanguages = {};
  for (var e in await LangManager.languages) {
    scanLanguages[e.code] = e;
  }
  userData = UserData();
  await userData.init();
  versionName = await Channel.versionName;

  await InterstitialAd.load(
    adUnitId: INTERSTITIAL_AD_UNIT_ID,
    request: const AdRequest(),
    adLoadCallback: InterstitialAdLoadCallback(
      onAdLoaded: (InterstitialAd ad) {
        // Keep a reference to the ad so you can show it later.
        interstitialAd = ad;
      },
      onAdFailedToLoad: (LoadAdError error) {
        if (kDebugMode) {
          print('InterstitialAd failed to load: $error');
        }
      },
    ),
  );
}

String formatDate(DateTime date) {
  final year = date.year;
  final month = date.month < 10 ? "0${date.month}" : date.month;
  final day = date.day < 10 ? "0${date.day}" : date.day;
  final hour = date.hour % 12 < 10 ? "0${date.hour % 12}" : date.hour % 12;
  final minute = date.minute < 10 ? "0${date.minute}" : date.minute;
  final second = date.second < 10 ? "0${date.second}" : date.second;

  return "$year-$month-$day $hour:$minute:$second ${date.hour < 12 ? 'AM' : 'PM'}";
}

BannerAd get bannerAd => BannerAd(
      adUnitId: BANNER_AD_UNIT_ID,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    );

class UserData {
  static const String SCAN_LANG = "scan_lang";

  late final File _file;
  late final Map<String, dynamic> _data;
  Lang? _scanLang;

  Lang? get scanLang => _scanLang;

  set scanLang(Lang? value) {
    _data[SCAN_LANG] = value?.toMap();
    _scanLang = value;
    _saveUserData(_data);
  }

  Future<void> init() async {
    var path = await Channel.getExternalStorageDirectory;
    _file = File("$path/userdata");

    _data = _getuserData();
    if (_data.containsKey(SCAN_LANG)) {
      _scanLang = Lang.fromMap(_data[SCAN_LANG]);
      _scanLang!.hasLocalData = await LangManager.existLocalData(
        _scanLang!.code,
      );
    }
  }

  Map<String, dynamic> _getuserData() {
    if (_file.existsSync() == false) {
      _file.createSync(recursive: true);
      _file.writeAsStringSync("{}");
    }

    var data = _file.readAsStringSync();
    return jsonDecode(data) as Map<String, dynamic>;
  }

  void _saveUserData(Map<String, dynamic> data) {
    if (_file.existsSync() == false) {
      _file.createSync(recursive: true);
    }

    var content = jsonEncode(data);
    _file.writeAsStringSync(content);
  }
}

enum ImageSource { camera, gallery }

class Channel {
  static const ANDROID_CHANNEL = MethodChannel(
    'com.oezeb.text_scanner/channel',
  );

  // static Future<void> test() async {
  //   await ANDROID_CHANNEL.invokeMethod("test");
  // }

  static Future<Uint8List> getImageByteArray(Map<String, dynamic> data) async {
    return await ANDROID_CHANNEL.invokeMethod("getImageByteArray", {
      "data": data,
    });
  }

  static Future<Map<String, dynamic>?> getImagePixels(Uint8List bytes) async {
    return await ANDROID_CHANNEL.invokeMapMethod("getImagePixels", {
      "bytes": bytes,
    });
  }

  static Future<String> get versionName async {
    return await ANDROID_CHANNEL.invokeMethod("versionName");
  }

  static Future<String?> pickImage(ImageSource source) async {
    switch (source) {
      case ImageSource.camera:
        return await ANDROID_CHANNEL.invokeMethod("captureImage");
      case ImageSource.gallery:
        return await ANDROID_CHANNEL.invokeMethod("pickImage");
      default:
        return null;
    }
  }

  static Future<String> imageToString(String path, String lang) async {
    return await ANDROID_CHANNEL.invokeMethod('imageToString', {
      "path": path,
      "lang": lang,
    });
  }

  static Future<String> get getExternalStorageDirectory async {
    return await ANDROID_CHANNEL.invokeMethod('getExternalStorageDirectory');
  }

  static Future<String> get getExternalCacheDirectory async {
    return await ANDROID_CHANNEL.invokeMethod('getExternalCacheDirectory');
  }

  static openUrl(String url) async {
    return await ANDROID_CHANNEL.invokeMethod('openUrl', {"url": url});
  }

  static shareText(String content) async {
    return await ANDROID_CHANNEL.invokeMethod('shareText', {
      "content": content,
    });
  }
}

class DownloadStatus {
  bool done, error;
  int? downloaded, total; // downloaded != null means downloading
  String errorMessage;

  DownloadStatus({
    this.done = false,
    this.error = false,
    this.downloaded,
    this.total,
    this.errorMessage = "",
  });
}

class Downloader extends ChangeNotifier {
  StreamSubscription<List<int>>? _subscription;
  var _status = DownloadStatus();

  DownloadStatus get status => _status;

  Future<void> startDownloading(String url, String filepath) async {
    _status = DownloadStatus();
    _status.downloaded = 0;
    notifyListeners();

    final request = Request('GET', Uri.parse(url));
    final StreamedResponse response = await Client().send(request);

    _status.total = response.contentLength;
    notifyListeners();

    List<int> bytes = [];

    final file = await File(filepath).create(recursive: true);
    _subscription = response.stream.listen(
      (List<int> newBytes) {
        bytes.addAll(newBytes);
        _status.downloaded = bytes.length;
        notifyListeners();
      },
      onDone: () {
        _status.total = null;
        notifyListeners();

        file.writeAsBytesSync(bytes);

        _status.done = true;
        _status.downloaded = null;
        notifyListeners();
      },
      onError: (e) {
        _status.errorMessage = e.toString();
        _status.downloaded = null;
        _status.total = null;
        _status.error = true;
        notifyListeners();
      },
      cancelOnError: true,
    );
  }

  Future<void> cancelDownload() async {
    if (_subscription != null) {
      await _subscription!.cancel();
      _subscription = null;
    }
    _status = DownloadStatus();
    notifyListeners();
  }

  static Future<File> downloadFile(String url, String filepath) async {
    var request = await HttpClient().getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    final file = await File(filepath).create(recursive: true);
    await file.writeAsBytes(bytes);
    return file;
  }
}

class LangManager extends ChangeNotifier {
  var _downloader = Downloader();
  var _cache = "";

  DownloadStatus get status => _downloader.status;

  bool get downloading => status.downloaded != null && status.downloaded! >= 0;

  Future<void> downloadDataWithProgress(String code) async {
    _downloader = Downloader();

    final filename = "$code.traineddata";
    final path = await localDataPath;
    final url = getUrl(filename);

    final cachePath = await Channel.getExternalCacheDirectory;
    _cache = "$cachePath/$filename";

    _downloader.addListener(() {
      if (status.done) {
        scanLanguages[code]?.hasLocalData = true;
        final file = File(_cache);
        file.copySync("$path/$filename");
        if (file.existsSync()) {
          file.deleteSync();
        }
      } else if (status.error) {
        final file = File(_cache);
        if (file.existsSync()) {
          file.deleteSync();
        }
      }

      notifyListeners();
    });

    try {
      await _downloader.startDownloading(url, _cache);
    } catch (e) {
      final file = File(_cache);
      if (file.existsSync()) {
        file.deleteSync();
      }
      notifyListeners();
    }
  }

  Future<void> cancelDownload() async {
    _downloader.cancelDownload();
    final file = File(_cache);
    if (file.existsSync()) {
      file.deleteSync();
    }
    notifyListeners();
  }

  static String getUrl(String filename) {
    return "https://github.com/oezeb/tessdata-v4.0.0/raw/main/$filename";
    // return "https://github.com/tesseract-ocr/tessdata/raw/4.0.0/$filename";
  }

  static Future<File> downloadData(String code) async {
    final filename = "$code.traineddata";
    final url = getUrl(filename);
    final path = await localDataPath;
    final cachePath = await Channel.getExternalCacheDirectory;
    final cache = "$cachePath/$filename";
    await Downloader.downloadFile(url, cache);
    final file = File(cache);
    var res = file.copy("$path/$filename");
    if (file.existsSync()) {
      file.deleteSync();
    }
    return res;
  }

  static Future<void> delete(String code) async {
    final path = await localDataPath;
    final file = File("$path/$code.traineddata");
    if (file.existsSync()) {
      file.deleteSync();
    }
    scanLanguages[code]?.hasLocalData = false;
  }

  static Future<List<Lang>> get languages async {
    final content = await rootBundle.loadString("assets/langs.json");
    List<Lang> langs = [];
    for (var map in jsonDecode(content)) {
      map["hasLocalData"] = await existLocalData(map["code"]);
      langs.add(Lang.fromMap(map));
    }

    langs.sort((lang1, lang2) {
      if (lang1.hasLocalData && !lang2.hasLocalData) {
        return -1;
      } else if (lang2.hasLocalData && !lang1.hasLocalData) {
        return 1;
      } else {
        var lang1Downloading = scanLangDownloaders.containsKey(lang1.code) &&
            scanLangDownloaders[lang1.code]!.downloading;
        var lang2Downloading = scanLangDownloaders.containsKey(lang2.code) &&
            scanLangDownloaders[lang2.code]!.downloading;

        if (lang1Downloading && !lang2Downloading) {
          return -1;
        } else if (lang2Downloading && !lang1Downloading) {
          return 1;
        } else {
          var c = lang1.name.compareTo(lang2.name);
          if (c == 0) {
            return lang1.code.compareTo(lang2.code);
          } else {
            return c;
          }
        }
      }
    });
    return langs;
  }

  static List<Lang> search(String query, List<Lang> langList) {
    langList.retainWhere(
      (e) => e.name.toLowerCase().contains(query.toLowerCase()),
    );

    return langList;
  }

  static Future<String> get localDataPath async {
    final path = await Channel.getExternalStorageDirectory;
    return "$path/tesseract/tessdata";
  }

  static Future<bool> existLocalData(String code) async {
    final path = await localDataPath;
    final file = File("$path/$code.traineddata");
    return file.existsSync();
  }
}
