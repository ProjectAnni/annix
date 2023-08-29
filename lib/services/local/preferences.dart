import 'dart:convert';

import 'package:annix/bridge/native.dart';
import 'package:annix/services/path.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PreferencesStore {
  late final NativePreferenceStore _store;

  PreferencesStore(final Ref ref)
      : _store = api.newStaticMethodNativePreferenceStore(
            root: PathService.dataRoot);

  T? get<T>(final String key) {
    final data = _store.get(key: key);
    if (data == null) {
      return null;
    }

    return jsonDecode(data) as T;
  }

  void set<T>(final String key, final T value) {
    _store.set(key: key, value: jsonEncode(value));
  }

  void remove(final String key) {
    _store.remove(key: key);
  }

  void removePrefix(final String prefix) {
    _store.removePrefix(prefix: prefix);
  }

  String? getString(final String key) => get(key);
  int? getInt(final String key) => get(key);
  double? getDouble(final String key) => get(key);
  bool? getBool(final String key) => get(key);

  List<String>? getStringList(final String key) {
    final List<dynamic>? list = get(key);
    if (list == null) {
      return null;
    }

    return list.map((final e) => e as String).toList();
  }
}
