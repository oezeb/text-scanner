import 'dart:io';

import 'package:flutter/material.dart';
import 'package:text_scanner/utils.dart';
import 'package:text_scanner/views/lang_manager_view.dart';
import 'package:text_scanner/views/text_scanner_view.dart';

class FloatingButton extends StatefulWidget {
  const FloatingButton({super.key});

  @override
  State<FloatingButton> createState() => _FloatingButtonState();
}

class _FloatingButtonState extends State<FloatingButton> {
  bool _expandedFloatingBtn = false;

  Future<void> _scanImage(ImageSource source) async {
    final langs = scanLanguages.values.where((e) => e.hasLocalData).toList();
    if (langs.isEmpty) {
      final res = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Download language data"),
          content: Text(
            "There is no data available for any language. Would you like to download now?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text("No"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text("Yes"),
            ),
          ],
        ),
      );

      if (res == true && mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: ((context) => const LangManagerView()),
          ),
        );
      }
    } else {
      final path = await Channel.pickImage(source);
      if (path != null && mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TextScannerView(
              languages: langs,
              file: File(path),
              selected: userData.scanLang == null ||
                      scanLanguages[userData.scanLang!.code]!.hasLocalData ==
                          false
                  ? null
                  : scanLanguages[userData.scanLang!.code],
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _expandedFloatingBtn
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: Container(height: 0.0)),
              Expanded(
                child: FloatingActionButton(
                  heroTag: "from camera",
                  onPressed: () async {
                    await _scanImage(ImageSource.camera);
                    // final img = await Channel.captureImage();
                    // if (img != null) {
                    //   await _scanImage(img);
                    //   final file = File(img);
                    //   if (file.existsSync()) {
                    //     file.delete();
                    //   }
                    // }
                  },
                  child: const Icon(Icons.camera_alt),
                ),
              ),
              Expanded(
                child: FloatingActionButton(
                  heroTag: "from gallery",
                  onPressed: () async {
                    await _scanImage(ImageSource.gallery);
                    // final img = await Channel.pickImage();
                    // if (img != null) {
                    //   await _scanImage(img);
                    //   final file = File(img);
                    //   if (file.existsSync()) {
                    //     file.delete();
                    //   }
                    // }
                  },
                  child: const Icon(Icons.collections),
                ),
              ),
              Expanded(child: Container(height: 0.0)),
            ],
          )
        : FloatingActionButton(
            onPressed: () {
              setState(() {
                _expandedFloatingBtn = true;
              });
              Future.delayed(const Duration(seconds: 5), () {
                setState(() {
                  _expandedFloatingBtn = false;
                });
              });
            },
            child: const Icon(
              Icons.add,
              size: 40,
            ),
          );
  }
}
