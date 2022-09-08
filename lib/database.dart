import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:text_scanner/models.dart';

class ItemsDatabase extends ChangeNotifier {
  static const FILE_NAME = 'items.db';
  static const TABLE_NAME = 'items';
  static const VERSION = 1;

  final Future<Database> _database;

  ItemsDatabase({
    required String path,
  }) : _database = openDatabase(path, version: VERSION, onCreate: _onCreate);

  static Future<void> _onCreate(
    Database db,
    int version,
  ) async {
    await db.execute('''
      CREATE TABLE $TABLE_NAME (
        id    TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        date  TEXT NOT NULL,
        image TEXT NOT NULL,
        text  TEXT NOT NULL
      )
    ''');
  }

  Future<void> insert(List<Item> items) async {
    final Database db = await _database;
    await db.transaction((txn) async {
      for (final item in items) {
        await txn.insert(
          TABLE_NAME,
          item.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
    notifyListeners();
  }

  Future<void> delete(List<String> ids) async {
    final Database db = await _database;
    await db.transaction((txn) async {
      for (final id in ids) {
        await txn.delete(
          TABLE_NAME,
          where: 'id = ?',
          whereArgs: [id],
        );
      }
    });
    notifyListeners();
  }

  Future<List<Item>> get({String? id}) async {
    final Database db = await _database;

    final List<Map<String, dynamic>> maps = await db.query(
      TABLE_NAME,
      where: id == null ? null : "id == '$id'",
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) {
      return Item.fromMap(maps[i]);
    });
  }

  Future<List<Item>> search(String query) async {
    if (query == "") return get();

    final Database db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      TABLE_NAME,
      where: "title LIKE '%$query%'",
      orderBy: 'date DESC',
    );
    return List.generate(
      maps.length,
      (i) {
        return Item.fromMap(maps[i]);
      },
    );
  }
}
