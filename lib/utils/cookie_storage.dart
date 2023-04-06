import 'package:annix/services/local/preferences.dart';
import 'package:cookie_jar/cookie_jar.dart';

class CookieStorage implements Storage {
  final PreferencesStore preferences;

  CookieStorage(this.preferences);

  @override
  Future<void> init(
      final bool persistSession, final bool ignoreExpires) async {}

  @override
  Future<String?> read(final String key) async {
    return preferences.getString(getKey(key));
  }

  @override
  Future<void> write(final String key, final String value) async {
    preferences.set(getKey(key), value);
  }

  @override
  Future<void> delete(final String key) async {
    preferences.remove(getKey(key));
  }

  @override
  Future<void> deleteAll(final List<String> keys) async {
    preferences.removePrefix('cookie_');
  }

  String getKey(final String key) => 'cookie_$key';
}
