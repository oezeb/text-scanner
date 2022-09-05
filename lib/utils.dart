import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:text_scanner/models.dart';

Map<String, dynamic>? userData;

String formatDate(DateTime date) {
  final year = date.year;
  final month = date.month < 10 ? "0${date.month}" : date.month;
  final day = date.day < 10 ? "0${date.day}" : date.day;
  final hour = date.hour % 12 < 10 ? "0${date.hour % 12}" : date.hour % 12;
  final minute = date.minute < 10 ? "0${date.minute}" : date.minute;
  final second = date.second < 10 ? "0${date.second}" : date.second;

  return "$year-$month-$day $hour:$minute:$second ${date.hour < 12 ? 'AM' : 'PM'}";
}

Future<Map<String, dynamic>> getuserData() async {
  var path = await Channel.getExternalStorageDirectory();
  var file = File("$path/userdata");
  if (await file.exists() == false) {
    file = await file.create(recursive: true);
    file.writeAsString("{}");
  }

  var data = await file.readAsString();
  return jsonDecode(data) as Map<String, dynamic>;
}

Future<void> saveUserData(Map<String, dynamic> data) async {
  var path = await Channel.getExternalStorageDirectory();
  var file = File("$path/userdata");
  if (await file.exists() == false) {
    file = await file.create(recursive: true);
  }

  var content = jsonEncode(data);
  file.writeAsString(content);
}

class Channel {
  static const ANDROID_CHANNEL = MethodChannel('com.oezeb.notepad/ocr_offline');

  // static Future<void> test() async {
  //   await ANDROID_CHANNEL.invokeMethod("test");
  // }

  static Future<String?> pickImage() async {
    return await ANDROID_CHANNEL.invokeMethod("pickImage");
  }

  static Future<String?> captureImage() async {
    return await ANDROID_CHANNEL.invokeMethod("captureImage");
  }

  static Future<String> imageToString(String path, String lang) async {
    return await ANDROID_CHANNEL.invokeMethod('imageToString', {
      "path": path,
      "lang": lang,
    });
  }

  static Future<String> getExternalStorageDirectory() async {
    return await ANDROID_CHANNEL.invokeMethod('getExternalStorageDirectory');
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

class Downloader extends ChangeNotifier {
  int downloaded = 0;
  int? total;
  bool done = false;
  bool error = false;
  String errorMessage = "";

  Future<void> startDownloading(String url, String filepath) async {
    downloaded = 0;
    total = null;
    done = false;
    error = false;
    errorMessage = "";

    final request = Request('GET', Uri.parse(url));
    final StreamedResponse response = await Client().send(request);

    total = response.contentLength;

    List<int> bytes = [];

    final file = await File(filepath).create(recursive: true);
    response.stream.listen(
      (List<int> newBytes) {
        bytes.addAll(newBytes);
        downloaded = bytes.length;
        notifyListeners();
      },
      onDone: () async {
        await file.writeAsBytes(bytes);
        done = true;
        notifyListeners();
      },
      onError: (e) {
        error = true;
        errorMessage = e.toString();
        notifyListeners();
      },
      cancelOnError: true,
    );
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
  int downloaded = 0;
  int? total;
  bool done = false;
  bool error = false;
  String errorMessage = "";

  Future<void> downloadDataWithProgress(String code) async {
    final downloader = Downloader();
    downloaded = 0;
    total = null;
    done = false;
    error = false;
    errorMessage = "";

    final filename = "$code.traineddata";
    final url = "https://github.com/tesseract-ocr/tessdata/raw/4.0.0/$filename";
    final path = await localDataPath;
    final cache = "$path/cache/$filename";

    downloader.addListener(() async {
      downloaded = downloader.downloaded;
      total = downloader.total;
      done = downloader.done;
      error = downloader.error;
      errorMessage = downloader.errorMessage;
      if (downloader.done) {
        final file = File(cache);
        await file.copy("$path/$filename");
        if (await file.exists()) {
          await file.delete();
        }
      } else if (downloader.error) {
        final file = File(cache);
        if (await file.exists()) {
          await file.delete();
        }
      }
      notifyListeners();
    });

    try {
      await downloader.startDownloading(url, cache);
    } catch (e) {
      error = true;
      errorMessage = e.toString();
      final file = File(cache);
      if (await file.exists()) {
        await file.delete();
      }
      notifyListeners();
    }
  }

  static Future<File> downloadData(String code) async {
    final filename = "$code.traineddata";
    final url = "https://github.com/tesseract-ocr/tessdata/raw/4.0.0/$filename";
    final path = await localDataPath;
    final cache = "$path/cache/$filename";
    await Downloader.downloadFile(url, cache);
    final file = File(cache);
    var res = file.copy("$path/$filename");
    if (await file.exists()) {
      await file.delete();
    }
    return res;
  }

  static Future<void> delete(String code) async {
    final path = await localDataPath;
    final file = File("$path/$code.traineddata");
    if (await file.exists()) {
      await file.delete();
    }
  }

  static Future<List<Lang>> get languages async {
    final content = await rootBundle.loadString("assets/langs.json");
    List<Lang> langs = [];
    for (var map in jsonDecode(content)) {
      map["hasLocalData"] = await existLocalData(map["code"]);
      langs.add(Lang.fromMap(map));
    }

    langs.sort((lang1, lang2) {
      if (lang1.hasLocalData && lang2.hasLocalData) {
        return 0;
      } else if (lang1.hasLocalData) {
        return -1;
      } else if (lang2.hasLocalData) {
        return 1;
      } else {
        var c = lang1.name.compareTo(lang2.name);
        if (c == 0) {
          return lang1.code.compareTo(lang2.code);
        } else {
          return c;
        }
      }
    });
    return langs;
  }

  static Future<List<Lang>> search(String query) async {
    final langs = await languages;
    langs.retainWhere(
      (e) => e.name.toLowerCase().contains(query.toLowerCase()),
    );
    return langs;
  }

  static Future<String> get localDataPath async {
    final path = await Channel.getExternalStorageDirectory();
    return "$path/tesseract/tessdata";
  }

  static Future<bool> existLocalData(String code) async {
    final path = await localDataPath;
    final file = File("$path/$code.traineddata");
    return file.exists();
  }
}
