import 'dart:io';

import 'package:flutter/material.dart';
import 'package:text_scanner/database.dart';
import 'package:text_scanner/models.dart';
import 'package:text_scanner/utils.dart';
import 'package:uuid/uuid.dart';

class TextScannerView extends StatefulWidget {
  const TextScannerView({super.key, required this.file});

  final File file;

  @override
  State<TextScannerView> createState() => _TextScannerViewState();
}

class _TextScannerViewState extends State<TextScannerView> {
  String? _lang;
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

  Future<List<Lang>> get _future async {
    var languages = await LangManager.languages;
    userData ??= await getuserData();

    Map<String, Lang> localLangs = {};
    for (var lang in languages) {
      if (lang.hasLocalData) {
        localLangs[lang.code] = lang;
      }
    }

    if (userData!.containsKey("scan_lang") == false || localLangs.isEmpty) {
      if (localLangs.isEmpty) {
        _lang = "eng";
        await LangManager.downloadData("eng");
        localLangs["eng"] = Lang.fromMap({
          "code": "eng",
          "name": "English",
          "hasLocalData": true,
        });
      } else {
        _lang = localLangs.keys.first;
      }

      userData!["scan_lang"] = _lang;
    } else if (localLangs.containsKey(userData!["scan_lang"]) == false) {
      _lang = localLangs.keys.first;

      userData!["scan_lang"] = _lang;
    } else {
      _lang = userData!["scan_lang"];
    }

    return localLangs.values.toList();
  }

  _langDropMenuWidget(List<Lang> langs) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DropdownButton<String>(
          items: langs
              .map((e) => DropdownMenuItem<String>(
                    value: e.code,
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
                userData!["scan_lang"] = value;
              });
            }
          },
          isDense: true,
        ),
      ],
    );
  }

  _saveItem(void Function() callback) async {
    _item.text = await Channel.imageToString(
      widget.file.path,
      _lang!,
    );
    var path = await Channel.getExternalStorageDirectory();
    var file = widget.file.copySync("$path/${_item.id}");
    _item.image = file.path;
    await itemsdb.insert([_item]);
    userData!["scan_lang"] = _lang;
    await saveUserData(userData!);
    callback();
  }

  @override
  void initState() {
    super.initState();
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
      body: Padding(
        padding: const EdgeInsets.only(left: 4.0, right: 4.0),
        child: Column(children: [
          const Divider(),
          Expanded(child: Image.file(widget.file)),
          const Divider(),
        ]),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          child: FutureBuilder(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var langs = snapshot.data as List<Lang>;
                return Row(
                  children: [
                    Expanded(
                      child: _langDropMenuWidget(langs),
                    ),
                    ElevatedButton(
                      onPressed: _lang == null || _savingItem == true
                          ? null
                          : () async {
                              setState(() {
                                _savingItem = true;
                              });
                              _saveItem(() {
                                setState(() {
                                  Navigator.pop(context, true);
                                });
                              });
                            },
                      child: _savingItem
                          ? const CircularProgressIndicator()
                          : const Text("OK"),
                    ),
                  ],
                );
              } else {
                return SizedBox(
                  height: 35,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [LinearProgressIndicator()],
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
