import 'package:flutter/material.dart';
import 'package:text_scanner/item.dart';

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
                image: MemoryImage(widget.item.image),
                fit: BoxFit.cover,
              ),
            ),
            width: 50,
          ),
          title: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    widget.item.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    widget.item.date.toString(),
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
                      children: [
                        Icon(Icons.circle_outlined, size: 18.0),
                        Icon(Icons.circle_rounded, size: 12.0),
                      ],
                    )
                  : Icon(Icons.circle_outlined, size: 18.0),
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
        Divider(),
      ],
    );
  }
}
