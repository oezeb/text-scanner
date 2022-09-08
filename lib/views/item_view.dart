import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:text_scanner/models.dart';
import 'package:text_scanner/utils.dart';

class ItemView extends StatefulWidget {
  final Item item;
  const ItemView({super.key, required this.item});

  @override
  State<ItemView> createState() => _ItemViewState();
}

class _ItemViewState extends State<ItemView> {
  late final _itemVM = ItemViewModel(widget.item);

  _onTapCopy() async {
    await Clipboard.setData(ClipboardData(text: _itemVM.text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Copied to clipboard")),
    );
  }

  _onTapEdit() async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: _itemVM.title);
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
                  _itemVM.title = controller.text;
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

  _onTapDelete() async {
    final confirm = await showDialog<bool>(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm delete"),
        content: const Text("Are you sure you want to delete permanently?"),
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

    if (confirm == true) {
      await _itemVM.delete();
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _itemVM.save();
        if (mounted) {
          Navigator.pop(context);
        }
        return true;
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            titleSpacing: 0.0,
            leading: IconButton(
              onPressed: () async {
                await _itemVM.save();
                if (!mounted) return;
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back),
            ),
            title: Text(
              _itemVM.title,
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              IconButton(
                onPressed: _onTapEdit,
                icon: const Icon(Icons.edit),
              ),
              IconButton(
                onPressed: _onTapDelete,
                icon: const Icon(Icons.delete_forever),
              ),
            ],
            bottom: TabBar(
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Text"),
                      IconButton(
                        onPressed: _onTapCopy,
                        icon: const Icon(Icons.content_copy),
                      )
                    ],
                  ),
                ),
                const Tab(text: "Image")
              ],
              labelColor: Colors.grey[900],
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            foregroundColor: Colors.grey[900],
          ),
          body: TabBarView(children: [
            TextField(
              controller: _itemVM.textCtrl,
              maxLines: null,
              expands: true,
            ),
            InteractiveViewer(
              child: Image.file(File(_itemVM.image)),
            ),
          ]),
        ),
      ),
    );
  }
}

class ItemViewModel extends ChangeNotifier {
  final Item _item;
  final TextEditingController textCtrl;
  ItemViewModel(Item item)
      : _item = item,
        textCtrl = TextEditingController(text: item.text);

  String get title => _item.title;
  String get text => textCtrl.text;
  String get image => _item.image;

  set title(String title) {
    _item.title = title;
  }

  delete() async {
    await itemsdb.delete([_item.id]);
    var file = File(_item.image);
    if (await file.exists()) {
      await file.delete();
    }
  }

  save() async {
    _item.text = textCtrl.text;
    await itemsdb.insert([_item]);
  }
}
