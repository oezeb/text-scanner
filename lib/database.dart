import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:text_scanner/item.dart';

final itemsdb = ItemsDatabase(path: ItemsDatabase.FILE_NAME);

class ItemsDatabase extends ChangeNotifier {
  static const FILE_NAME = 'items.db';
  static const TABLE_NAME = 'items';
  static const VERSION = 1;

  final _database;

  ItemsDatabase({
    required String path,
  }) : _database = openDatabase(path, version: VERSION, onCreate: _onCreate);

  static Future<void> _onCreate(
    Database db,
    int version,
  ) async {
    await db.execute('''
      CREATE TABLE $TABLE_NAME (
        id TEXT PRIMARY KEY,
        title TEXT,
        date TEXT,
        image BLOB,
        text TEXT
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

  // Future<List<Item>> get({
  //   String? id,
  //   String? title,
  //   String? date,
  // }) async {
  //   final Database db = await _database;
  //   final args = <String, dynamic>{};
  //   if (id != null) args['id'] = id;
  //   if (title != null) args['title'] = title;
  //   if (date != null) args['date'] = date;

  //   final List<Map<String, dynamic>> maps = await db.query(
  //     TABLE_NAME,
  //     where: args.keys.map((key) => '$key = ?').join(' LIKE '),
  //     whereArgs: args.values.toList(),
  //     orderBy: 'date DESC',
  //   );
  //   return List.generate(maps.length, (i) {
  //     return Note.fromJson(maps[i]);
  //   });
  // }
}
