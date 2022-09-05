import 'dart:io';

import 'package:flutter/material.dart';
import 'package:text_scanner/models.dart';
import 'package:text_scanner/utils.dart';

enum Selection { none, multiple, all }

class ItemWidget extends StatefulWidget {
  final Item item;
  final Selection? selection;
  final bool? selected;
  final void Function(Item item, bool? selected)? onTap;
  final void Function(Item item, bool? selected)? onLongPress;
  const ItemWidget({
    super.key,
    required this.item,
    this.selection,
    this.selected,
    this.onTap,
    this.onLongPress,
  });

  @override
  State<ItemWidget> createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<ItemWidget> {
  late bool? _selected = widget.selected;

  @override
  Widget build(BuildContext context) {
    switch (widget.selection) {
      case Selection.all:
        _selected = true;
        break;
      case Selection.none:
        _selected = false;
        break;
      default:
    }
    return Column(
      children: [
        ListTile(
          leading: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: FileImage(File(widget.item.image)),
                fit: BoxFit.cover,
              ),
            ),
            width: 60,
          ),
          title: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      widget.item.title,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    formatDate(widget.item.date),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              )
            ],
          ),
          trailing: _selected == null
              ? null
              : _selected == true
                  ? Stack(
                      alignment: AlignmentDirectional.center,
                      children: const [
                        Icon(Icons.circle_outlined, size: 18.0),
                        Icon(Icons.circle_rounded, size: 12.0),
                      ],
                    )
                  : const Icon(Icons.circle_outlined, size: 18.0),
          onTap: () {
            setState(() {
              if (_selected != null) {
                _selected = !_selected!;
              }
            });
            if (widget.onTap != null) {
              widget.onTap!(widget.item, _selected);
            }
          },
          onLongPress: () {
            if (widget.onLongPress != null) {
              widget.onLongPress!(widget.item, _selected);
            }
          },
        ),
        const Divider(),
      ],
    );
  }
}
