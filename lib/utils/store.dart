import 'dart:convert';

import 'package:annix/services/global.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class AnnixStore {
  static final AnnixStore _instance = AnnixStore._();

  factory AnnixStore() {
    return _instance;
  }

  Future<Database> _database;

  AnnixStore._()
      : _database = openDatabase(
          p.join(Global.dataRoot, "store.db"),
          version: 1,
          onCreate: ((db, version) async {
            await db.execute('''
CREATE TABLE store(
  id       INTEGER PRIMARY KEY,
  category TEXT NOT NULL,
  key      TEXT NOT NULL,
  value    TEXT NOT NULL,
  UNIQUE("category", "key", "value")
);
            ''');
          }),
        );

  AnnixStoreCategory category(String category) {
    return AnnixStoreCategory(this, category);
  }

  Future<void> clear([String? category]) {
    return _database.then((db) async {
      if (category == null) {
        await db.delete('store');
      } else {
        await db.delete('store', where: 'category = ?', whereArgs: [category]);
      }
    });
  }
}

class AnnixStoreCategory {
  final AnnixStore _store;
  final String _category;

  AnnixStoreCategory(AnnixStore store, String category)
      : _store = store,
        _category = category;

  Future<dynamic> get(String key) async {
    final db = await _store._database;
    List<Map<String, Object?>> values = await db.rawQuery(
        "SELECT value FROM store WHERE category = ? AND key = ?",
        [_category, key]);
    if (values.isEmpty) {
      return null;
    } else if (values[0]['value'] != null) {
      return jsonDecode(values[0]['value'] as String);
    } else {
      return null;
    }
  }

  Future<bool> contains(String key) async {
    return (await get(key)) != null;
  }

  Future<void> set(String key, dynamic value) async {
    final db = await _store._database;
    await db.insert(
      "store",
      {
        'category': _category,
        'key': key,
        'value': jsonEncode(value),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> clear() async {
    final db = await _store._database;
    await db.delete(
      "store",
      where: "category = ?",
      whereArgs: [_category],
    );
  }
}
