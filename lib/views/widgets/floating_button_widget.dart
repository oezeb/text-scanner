import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:text_scanner/views/text_scanner_view.dart';

class FloatingButton extends StatefulWidget {
  const FloatingButton({super.key});

  @override
  State<FloatingButton> createState() => _FloatingButtonState();
}

class _FloatingButtonState extends State<FloatingButton> {
  bool _expandedFloatingBtn = false;
  final _picker = ImagePicker();

  _scanImage(String path) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TextScannerView(
          file: File(path),
        ),
      ),
    );
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
                    final img = await _picker.pickImage(
                      source: ImageSource.camera,
                    );
                    if (img != null) {
                      _scanImage(img.path);
                    }
                  },
                  child: const Icon(Icons.camera_alt),
                ),
              ),
              Expanded(
                child: FloatingActionButton(
                  heroTag: "from gallery",
                  onPressed: () async {
                    final img = await _picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (img != null) {
                      _scanImage(img.path);
                    }
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
