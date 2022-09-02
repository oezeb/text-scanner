import 'package:text_scanner/item.dart';
import 'package:flutter/services.dart';

Future<Uint8List> getImg() async {
  final bytes = await rootBundle.load("images/test.jpg");
  return bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
}

getItems() async {
  final img = await getImg();
  return <Item>[
    Item(id: "1", title: "item 1", date: DateTime.now(), image: img),
    Item(id: "2", title: "item 2", date: DateTime.now(), image: img),
    Item(id: "3", title: "item 3", date: DateTime.now(), image: img),
    Item(id: "4", title: "item 4", date: DateTime.now(), image: img),
    Item(id: "5", title: "item 5", date: DateTime.now(), image: img),
    Item(id: "6", title: "item 6", date: DateTime.now(), image: img),
    Item(id: "7", title: "item 7", date: DateTime.now(), image: img),
    Item(id: "8", title: "item 8", date: DateTime.now(), image: img),
    Item(id: "9", title: "item 9", date: DateTime.now(), image: img),
    Item(id: "10", title: "item 10", date: DateTime.now(), image: img),
  ];
}
