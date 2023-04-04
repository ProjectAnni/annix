import 'package:annix/global.dart';
import 'package:cookie_jar/cookie_jar.dart';

class CookieStorage implements Storage {
  @override
  Future<void> init(final bool persistSession, final bool ignoreExpires) async {}

  @override
  Future<String?> read(final String key) async {
    return Global.preferences.getString(getKey(key));
  }

  @override
  Future<void> write(final String key, final String value) async {
    await Global.preferences.setString(getKey(key), value);
  }

  @override
  Future<void> delete(final String key) async {
    await Global.preferences.remove(getKey(key));
  }

  @override
  Future<void> deleteAll(final List<String> keys) async {
    final keys = Global.preferences.getKeys();
    for (final key in keys) {
      if (key.startsWith('cookie_')) {
        await Global.preferences.remove(key);
      }
    }
  }

  String getKey(final String key) => 'cookie_$key';
}
