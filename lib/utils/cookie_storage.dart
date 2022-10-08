import 'package:annix/global.dart';
import 'package:cookie_jar/cookie_jar.dart';

class CookieStorage implements Storage {
  @override
  Future<void> init(bool persistSession, bool ignoreExpires) async {}

  @override
  Future<String?> read(String key) async {
    return Global.preferences.getString(getKey(key));
  }

  @override
  Future<void> write(String key, String value) async {
    await Global.preferences.setString(getKey(key), value);
  }

  @override
  Future<void> delete(String key) async {
    await Global.preferences.remove(getKey(key));
  }

  @override
  Future<void> deleteAll(List<String> keys) async {
    final keys = Global.preferences.getKeys();
    for (final key in keys) {
      if (key.startsWith('cookie_')) {
        await Global.preferences.remove(key);
      }
    }
  }

  String getKey(String key) => 'cookie_$key';
}
