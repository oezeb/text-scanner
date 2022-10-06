import 'package:flutter/material.dart';
import 'package:text_scanner/models.dart';
import 'package:text_scanner/utils.dart';

class LangWidget extends StatefulWidget {
  final Lang lang;
  const LangWidget({
    super.key,
    required this.lang,
  });

  @override
  State<LangWidget> createState() => _LangWidgetState();
}

class _LangWidgetState extends State<LangWidget> {
  late Lang _lang;
  late LangManager _langManager;

  @override
  void initState() {
    super.initState();
    _lang = widget.lang;
    if (scanLangDownloaders.containsKey(_lang.code) == false) {
      scanLangDownloaders[_lang.code] = LangManager();
    }

    _langManager = scanLangDownloaders[_lang.code]!;
    _langManager.addListener(() async {
      if (mounted) {
        if (_langManager.status.done || _langManager.status.error) {
          if (_langManager.status.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text(_langManager.status.errorMessage),
              ),
            );
          }
        }
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(_lang.name),
      trailing: _langManager.downloading
          ? Stack(
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: CircularProgressIndicator(
                          value: _langManager.status.total == null
                              ? null
                              : _langManager.status.downloaded! /
                                  _langManager.status.total!,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _langManager.cancelDownload();
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            )
          : FutureBuilder(
              future: LangManager.existLocalData(_lang.code),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  bool exist = snapshot.data as bool;
                  if (exist) {
                    return IconButton(
                      onPressed: () async {
                        await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Confirm delete"),
                            content: Text(
                              "Are you sure you want to delete ${_lang.name} data?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await LangManager.delete(_lang.code);
                                  setState(() {});
                                  if (!mounted) return;
                                  Navigator.pop(context);
                                },
                                child: const Text("Delete"),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.delete_outlined),
                    );
                  } else {
                    return IconButton(
                      onPressed: () async {
                        await _langManager.downloadDataWithProgress(_lang.code);
                      },
                      icon: const Icon(Icons.download_outlined),
                    );
                  }
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
    );
  }
}
