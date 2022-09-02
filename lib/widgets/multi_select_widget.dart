import 'package:flutter/material.dart';
import 'package:text_scanner/data.dart';
import 'package:text_scanner/item.dart';
import 'package:text_scanner/widgets/item_widget.dart';
import 'package:text_scanner/widgets/multi_select_widget.dart';

class MultiSelectWidget extends StatefulWidget {
  final List<Item> all;
  final Set<String> selected;
  const MultiSelectWidget({
    super.key,
    required this.all,
    this.selected = const {},
  });

  @override
  State<MultiSelectWidget> createState() => _MultiSelectWidgetState();
}

class _MultiSelectWidgetState extends State<MultiSelectWidget> {
  late Set<String> _selected = widget.selected;
  late Selection _selection = widget.selected.isEmpty
      ? Selection.none
      : widget.selected.length == widget.all.length
          ? Selection.all
          : Selection.multiple;

  _onTap(Item item, bool? selected) {
    if (selected == true) {
      _selected.add(item.id);
      if (_selected.length == widget.all.length) {
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
      if (_selected.length == widget.all.length - 1) {
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.delete_forever),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  if (_selected.length == widget.all.length) {
                    _selected.clear();
                    _selection = Selection.none;
                  } else {
                    _selected.addAll(widget.all.map((e) => e.id));
                    _selection = Selection.all;
                  }
                });
              },
              icon: _selected.length == widget.all.length
                  ? Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        Icon(Icons.circle_outlined, size: 18.0),
                        Icon(Icons.circle_rounded, size: 12.0),
                      ],
                    )
                  : Icon(Icons.circle_outlined, size: 18.0),
            )
          ],
          mainAxisAlignment: MainAxisAlignment.end,
        ),
        Divider(),
        Expanded(
          child: ListView.builder(
            itemCount: widget.all.length,
            itemBuilder: (context, index) => ItemWidget(
              item: widget.all[index],
              selection: _selection,
              selected: _selected.contains(widget.all[index].id),
              onTap: _onTap,
            ),
          ),
        ),
      ],
    );
  }
}
