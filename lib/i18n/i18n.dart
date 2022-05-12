import 'package:annix/i18n/i18n_en_US.dart';
import 'package:annix/i18n/i18n_zh_CN.dart';
import 'package:get/get.dart';

class I18n extends Translations {
  static const PROGRESS = "progress";

  static const HOME = "home";
  static const ALBUMS = "albums";
  static const PLAYLISTS = "playlists";

  static const SERVER = "server";
  static const LOGIN = "login";
  static const LOGOUT = "logout";
  static const ANNIL_LIBRARIES = "annil_library";

  static const SETTINGS = "settings";
  static const SETTINGS_CLEAR_METADATA_CACHE = "settings_clear_metadata_cache";
  static const SETTINGS_CLEAR_METADATA_CACHE_DESC =
      "settings_clear_metadata_cache_desc";
  static const SETTINGS_CLEAR_LYRIC_CACHE = "settings_clear_lyric_cache";
  static const SETTINGS_CLEAR_LYRIC_CACHE_DESC =
      "settings_clear_lyric_cache_desc";

  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': I18N_en_US,
        'zh_CN': I18N_zh_CN,
      };
}
