import 'dart:convert';

import 'package:annix/bridge/bridge.dart';
import 'package:annix/services/path.dart';

class AnnixStore {
  static final AnnixStore _instance = AnnixStore._();

  factory AnnixStore() {
    return _instance;
  }

  Future<LocalStore> _database;

  AnnixStore._()
      : _database = api.newStaticMethodLocalStore(root: PathService.dataRoot);

  AnnixStoreCategory category(final String category) {
    return AnnixStoreCategory(this, category);
  }

  Future<void> clear(final String category) async {
    final db = await _database;
    await db.clear(category: category);
  }
}

class AnnixStoreCategory {
  final AnnixStore _store;
  final String _category;
  final Map<String, dynamic> _cache = {};

  AnnixStoreCategory(final AnnixStore store, final String category)
      : _store = store,
        _category = category;

  Future<dynamic> get(final String key) async {
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

  Future<bool> contains(final String key) async {
    return _cache.containsKey(key) || await get(key) != null;
  }

  Future<void> set(final String key, final value) async {
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
