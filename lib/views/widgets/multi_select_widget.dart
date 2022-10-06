import 'dart:io';

import 'package:flutter/material.dart';
import 'package:text_scanner/models.dart';
import 'package:text_scanner/utils.dart';
import 'package:text_scanner/views/widgets/item_widget.dart';

class MultiSelectWidget extends StatefulWidget {
  final List<Item> all;
  final Set<String> selected;
  final void Function()? onEmptyList;
  const MultiSelectWidget({
    super.key,
    required this.all,
    this.selected = const {},
    this.onEmptyList,
  });

  @override
  State<MultiSelectWidget> createState() => _MultiSelectWidgetState();
}

class _MultiSelectWidgetState extends State<MultiSelectWidget> {
  late final _selected = widget.selected;
  late Selection _selection = widget.selected.isEmpty
      ? Selection.none
      : widget.selected.length == widget.all.length
          ? Selection.all
          : Selection.multiple;
  late final _all = Map<String, Item>.fromIterable(
    widget.all,
    key: (e) => e.id,
  );

  _onTap(Item item, bool? selected) {
    if (selected == true) {
      _selected.add(item.id);
      if (_selected.length == _all.length) {
        setState(() {
          _selection = Selection.all;
        });
      } else if (_selected.length == 1) {
        setState(() {
          _selection = Selection.multiple;
        });
      }
    } else {
      _selected.remove(item.id);
      if (_selected.length == _all.length - 1) {
        setState(() {
          _selection = Selection.multiple;
        });
      } else if (_selected.isEmpty) {
        setState(() {
          _selection = Selection.none;
        });
      }
    }
  }

  _onTapDelete() async {
    if (_selected.isNotEmpty) {
      var res = await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text(
            "Are you sure you want to delete all selected items?",
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
                await itemsdb.delete(_selected.toList());
                for (var e in _selected) {
                  var file = File(_all[e]!.image);

                  if (await file.exists()) {
                    await file.delete();
                  }
                }

                if (!mounted) return;
                Navigator.pop(context, true);
              },
              child: const Text("Confirm"),
            )
          ],
        ),
      );
      if (res == true) {
        setState(() {
          _selection = Selection.none;
          for (var e in _selected) {
            _all.remove(e);
          }
          _selected.clear();
          if (_all.isEmpty && widget.onEmptyList != null) {
            widget.onEmptyList!();
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: _onTapDelete,
              icon: const Icon(Icons.delete_forever),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  if (_selected.length == _all.length) {
                    _selected.clear();
                    _selection = Selection.none;
                  } else {
                    _selected.addAll(_all.values.map((e) => e.id));
                    _selection = Selection.all;
                  }
                });
              },
              icon: _selected.length == _all.length
                  ? Stack(
                      alignment: AlignmentDirectional.center,
                      children: const [
                        Icon(Icons.circle_outlined, size: 18.0),
                        Icon(Icons.circle_rounded, size: 12.0),
                      ],
                    )
                  : const Icon(Icons.circle_outlined, size: 18.0),
            )
          ],
        ),
        const Divider(),
        Expanded(
          child: ListView.builder(
            itemCount: _all.length,
            itemBuilder: (context, index) => ItemWidget(
              item: _all.values.elementAt(index),
              selection: _selection,
              selected: _selected.contains(_all.values.elementAt(index).id),
              onTap: _onTap,
            ),
          ),
        ),
      ],
    );
  }
}
