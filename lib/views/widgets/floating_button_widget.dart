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
          title: const Text("Download language data"),
          content: const Text(
            "There is no data available for any language. Would you like to download now?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text("Yes"),
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

// class ImagePainter extends CustomPainter {
//   final ui.Image image;
//   final Rect? rect;
//   ImagePainter({required this.image, this.rect});
//   @override
//   void paint(Canvas canvas, Size size) {
//     canvas.drawImage(image, const Offset(0, 0), Paint());
//     // var path = Path()
//     //   ..moveTo(rect.left, rect.top)
//     //   ..lineTo(rect.right, rect.top)
//     //   ..lineTo(rect.right, rect.bottom)
//     //   ..lineTo(rect.left, rect.bottom)
//     //   ..lineTo(rect.left, rect.top);

//     // Paint paint = Paint()
//     //   ..color = Colors.blue
//     //   ..strokeWidth = 2.0
//     //   ..style = PaintingStyle.stroke
//     //   ..strokeJoin = StrokeJoin.round;

//     // canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return false;
//   }
// }

// class Demo extends StatefulWidget {
//   final String imagePath;
//   const Demo({super.key, required this.imagePath});

//   @override
//   State<Demo> createState() => _DemoState();
// }

// class _DemoState extends State<Demo> {
//   late Uint8List _imageBytes;
//   Rect? _rect;

//   @override
//   void initState() {
//     super.initState();
//     _imageBytes = File(widget.imagePath).readAsBytesSync();
//   }

//   Future<Uint8List> _rotate(Uint8List bytes) async {
//     var data = await Channel.getImagePixels(bytes);

//     if (data != null) {
//       var width = data["width"] as int, height = data["height"] as int;
//       var pixels = Int32List(width * height);

//       int m = height, n = width;

//       for (int i = m - 1; i >= 0; i--) {
//         for (int j = 0; j < n; j++) {
//           pixels[j * height + m - i - 1] = data["pixels"][i * width + j];
//         }
//       }

//       return await Channel.getImageByteArray(
//         {"pixels": pixels, "width": height, "height": width},
//       );
//     }
//     throw Exception("Could not get image data for channel");
//   }

//   Future<ui.Image> get UIImage async {
//     var codec = await ui.instantiateImageCodec(_imageBytes);
//     return (await codec.getNextFrame()).image;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(),
//       body: Center(
//         child: Column(
//           children: [
//             InteractiveViewer(child: Image.memory(_imageBytes)),
//             ElevatedButton(
//               onPressed: () async {
//                 try {
//                   var bytes = await _rotate(_imageBytes);
//                   setState(() {
//                     _imageBytes = bytes;
//                   });
//                 } catch (e) {
//                   print(e);
//                 }
//               },
//               child: Text("Click me"),
//             ),
//             FutureBuilder(
//               future: UIImage,
//               builder: ((context, snapshot) {
//                 if (snapshot.hasData) {
//                   var image = snapshot.data as ui.Image;
//                   _rect ??= const Offset(0, 0) &
//                       Size(image.width.toDouble(), image.height.toDouble());
//                   return CustomPaint(
//                     painter: ImagePainter(image: image),
//                     size: _rect == null ? Size.zero : _rect!.size,
//                     child: Container(
//                       decoration: BoxDecoration(
//                         border: Border.all(
//                           width: 2,
//                           color: Colors.blue,
//                         ),
//                       ),
//                       width: _rect!.width,
//                       height: _rect!.height,
//                       child: Column(children: [
//                         Row(children: [
//                           GestureDetector(
//                             child: Icon(
//                               Icons.circle,
//                               color: Colors.blue,
//                             ),
//                             onVerticalDragDown: (details) {
//                               setState(() {
//                                 _rect = Offset(0, 0) &
//                                     Size(
//                                       _rect!.width - details.localPosition.dx,
//                                       _rect!.height - details.localPosition.dy,
//                                     );
//                               });
//                             },
//                           ),
//                           Expanded(child: Container()),
//                           GestureDetector(
//                             child: Icon(
//                               Icons.circle,
//                               color: Colors.blue,
//                             ),
//                           ),
//                         ]),
//                         Expanded(child: Container()),
//                         Row(children: [
//                           GestureDetector(
//                             child: Icon(
//                               Icons.circle,
//                               color: Colors.blue,
//                             ),
//                           ),
//                           Expanded(child: Container()),
//                           GestureDetector(
//                             child: Icon(
//                               Icons.circle,
//                               color: Colors.blue,
//                             ),
//                           ),
//                         ]),
//                       ]),
//                     ),
//                   );
//                 } else {
//                   return LinearProgressIndicator();
//                 }
//               }),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
