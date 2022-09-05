import 'package:flutter/material.dart';
import 'package:text_scanner/utils.dart';

class LangWidget extends StatefulWidget {
  final String name;
  final String code;
  const LangWidget({
    super.key,
    required this.name,
    required this.code,
  });

  @override
  State<LangWidget> createState() => _LangWidgetState();
}

class _LangWidgetState extends State<LangWidget> {
  final _langManager = LangManager();
  var _downloading = false;

  @override
  void initState() {
    super.initState();
    _langManager.addListener(() async {
      if (mounted) {
        if (_langManager.done || _langManager.error) {
          if (_langManager.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text(_langManager.errorMessage),
              ),
            );
          }
          setState(() {
            _downloading = false;
          });
        } else {
          setState(() {});
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.name),
      trailing: _downloading
          ? SizedBox(
              height: 48,
              width: 48,
              child: Center(
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    value: _langManager.total == null
                        ? null
                        : _langManager.downloaded / _langManager.total!,
                  ),
                ),
              ),
            )
          : FutureBuilder(
              future: LangManager.existLocalData(widget.code),
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
                              "Are you sure you want to delete ${widget.name} data?",
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
                                  await LangManager.delete(widget.code);
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
                      onPressed: () {
                        _langManager.downloadDataWithProgress(widget.code);
                        setState(() {
                          _downloading = true;
                        });
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
