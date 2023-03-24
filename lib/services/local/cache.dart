import 'dart:convert';

import 'package:annix/bridge/bridge.dart';
import 'package:annix/global.dart';

class AnnixStore {
  static final AnnixStore _instance = AnnixStore._();

  factory AnnixStore() {
    return _instance;
  }

  Future<LocalStore> _database;

  AnnixStore._()
      : _database = api.newStaticMethodLocalStore(root: Global.dataRoot);

  AnnixStoreCategory category(String category) {
    return AnnixStoreCategory(this, category);
  }

  Future<void> clear(String category) async {
    final db = await _database;
    await db.clear(category: category);
  }
}

class AnnixStoreCategory {
  final AnnixStore _store;
  final String _category;
  final Map<String, dynamic> _cache = {};

  AnnixStoreCategory(AnnixStore store, String category)
      : _store = store,
        _category = category;

  Future<dynamic> get(String key) async {
    if (_cache.containsKey(key)) {
      return _cache[key];
    }

    final db = await _store._database;
    final value = await db.get(category: _category, key: key);
    if (value == null) {
      return null;
    }

    return jsonDecode(value);
  }

  Future<bool> contains(String key) async {
    return _cache.containsKey(key) || await get(key) != null;
  }

  Future<void> set(String key, value) async {
    _cache[key] = value;
    final db = await _store._database;
    await db.insert(category: _category, key: key, value: jsonEncode(value));
  }

  Future<void> clear() async {
    _cache.clear();
    final db = await _store._database;
    await db.clear(category: _category);
  }
}
