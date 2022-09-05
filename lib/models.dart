class Item {
  String id;
  String title;
  DateTime date;
  String image;
  String text;

  Item({
    required this.id,
    required this.title,
    required this.date,
    required this.image,
    required this.text,
  });

  Item.fromMap(Map<String, dynamic> map)
      : id = map["id"],
        title = map["title"],
        date = DateTime.parse(map["date"]),
        image = map["image"],
        text = map.containsKey("text") ? map["text"] : null;

  Map<String, dynamic> toMap() => {
        "id": id,
        "title": title,
        "date": date.toString(),
        "image": image,
        "text": text,
      };
}

class Lang {
  String name;
  String code;
  bool hasLocalData;

  Lang({required this.name, required this.code, required this.hasLocalData});

  Lang.fromMap(Map<String, dynamic> map)
      : name = map["name"],
        code = map["code"],
        hasLocalData = map["hasLocalData"];
}
