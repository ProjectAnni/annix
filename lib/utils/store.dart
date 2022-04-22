import 'dart:convert';

import 'package:sqflite/sqflite.dart';

class AnnixStore {
  static AnnixStore instance = AnnixStore();

  Future<Database> _database;

  AnnixStore()
      : _database = openDatabase(
          "store.db",
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
}

class AnnixStoreCategory<V> {
  AnnixStore _store;
  String _category;

  AnnixStoreCategory(AnnixStore store, String category)
      : _store = store,
        _category = category;

  Future<dynamic> get(String key) async {
    final db = await _store._database;
    List<Map<String, Object?>> values = await db.rawQuery(
        "SELECT value FROM store WHERE category = ? AND key = ?",
        [this._category, key]);
    if (values.isEmpty) {
      return null;
    } else {
      return jsonDecode(values[0]['value'] as String);
    }
  }

  Future<bool> contains(String key) async {
    return (await this.get(key)) != null;
  }

  Future<void> set(String key, dynamic value) async {
    final db = await _store._database;
    await db.insert(
      "store",
      {
        'category': this._category,
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
      whereArgs: [this._category],
    );
  }
}
