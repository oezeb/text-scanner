import 'package:flutter/foundation.dart';

class Item {
  String id;
  String title;
  DateTime date;
  Uint8List image;
  String? text;

  Item({
    required this.id,
    required this.title,
    required this.date,
    required this.image,
    this.text,
  });

  Item.fromMap(Map<String, dynamic> map)
      : id = map["id"],
        title = map["title"],
        date = map["date"],
        image = map["image"],
        text = map.containsKey("text") ? map["text"] : null;

  Map<String, dynamic> toMap() => {
        "id": id,
        "title": title,
        "date": date,
        "image": image,
        "text": text,
      };
}
