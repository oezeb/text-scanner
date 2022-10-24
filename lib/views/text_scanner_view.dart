import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:text_scanner/models.dart';
import 'package:text_scanner/utils.dart';
import 'package:text_scanner/views/item_view.dart';
import 'package:text_scanner/views/widgets/ad_banner_widget.dart';
import 'package:uuid/uuid.dart';

class TextScannerView extends StatefulWidget {
  const TextScannerView({
    super.key,
    required this.file,
    required this.languages,
    this.selected,
  });

  final File file;
  final List<Lang> languages;
  final Lang? selected;

  @override
  State<TextScannerView> createState() => _TextScannerViewState();
}

class _TextScannerViewState extends State<TextScannerView> {
  late Lang _lang;
  late final Item _item;
  bool _savingItem = false;

  _onTapEdit() async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: _item.title);
        return AlertDialog(
          title: const Text("Modify Document name"),
          content: TextField(controller: controller),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _item.title = controller.text;
                });
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveItem(void Function(Item item) callback) async {
    _item.text = await Channel.imageToString(
      widget.file.path,
      _lang.code,
    );
    var path = await Channel.getExternalStorageDirectory;
    var file = widget.file.copySync("$path/${_item.id}");
    _item.image = file.path;
    await itemsdb.insert([_item]);
    userData.scanLang = _lang;
    await FirebaseAnalytics.instance.logEvent(
      name: "scanned_image",
      parameters: {"lang": _lang.name},
    );
    callback(_item);
  }

  @override
  void initState() {
    super.initState();
    _lang = widget.selected ?? widget.languages.first;

    final date = DateTime.now();
    final title = "Text Scan ${formatDate(date).replaceAll(":", ".")}";
    _item = Item(
      id: const Uuid().v4(),
      title: title,
      date: date,
      image: "",
      text: "",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        title: Row(
          children: [
            Expanded(
              child: Text(
                _item.title,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _onTapEdit,
            icon: const Icon(Icons.edit),
          )
        ],
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: Colors.grey[900],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 4.0, right: 4.0),
              child: Column(children: [
                const Divider(),
                Expanded(
                  child: InteractiveViewer(child: Image.file(widget.file)),
                ),
                const Divider(),
              ]),
            ),
          ),
          BottomAppBar(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DropdownButton<Lang>(
                          items: widget.languages
                              .map((e) => DropdownMenuItem<Lang>(
                                    value: e,
                                    child: SizedBox(
                                      width: 200,
                                      child: Text(
                                        e.name,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ))
                              .toList(),
                          value: _lang,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _lang = value;
                              });
                            }
                          },
                          isDense: true,
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _savingItem == true
                        ? null
                        : () async {
                            setState(() {
                              _savingItem = true;
                            });
                            _saveItem((item) async {
                              await Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ItemView(item: item),
                                ),
                                (route) => route.isFirst,
                              );
                              try {
                                await interstitialAd.show();
                              } catch (e) {
                                if (kDebugMode) {
                                  print(e);
                                }
                              }
                            });
                          },
                    child: _savingItem
                        ? const CircularProgressIndicator()
                        : const Text("OK"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}
