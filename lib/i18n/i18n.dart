import 'package:annix/i18n/i18n_en_US.dart';
import 'package:annix/i18n/i18n_zh_CN.dart';
import 'package:get/get.dart';

class I18n extends Translations {
  static const PROGRESS = "progress";

  static const PLAYING = "playing";
  static const HOME = "home";
  static const CATEGORY = "category";
  static const ALBUMS = "albums";
  static const PLAYLISTS = "playlists";

  static const SHUFFLE_MODE = "shuffle_mode";
  static const MY_FAVORITE = "my_favorite";

  static const SERVER = "server";
  static const LOGIN = "login";
  static const LOGOUT = "logout";
  static const ANNIL_LIBRARIES = "annil_library";

  static const SETTINGS = "settings";
  static const SETTINGS_SKIP_CERT = "settings_skip_cert";
  static const SETTINGS_AUTOSCALE_UI = "settings_autoscale_ui";
  static const SETTINGS_USE_MOBILE_NETWORK = "settings_use_mobile_network";
  static const SETTINGS_LOGS = "settings_logs";
  static const SETTINGS_LOGS_DESC = "settings_logs_desc";
  static const SETTINGS_CLEAR_METADATA_CACHE = "settings_clear_metadata_cache";
  static const SETTINGS_CLEAR_METADATA_CACHE_DESC =
      "settings_clear_metadata_cache_desc";
  static const SETTINGS_CLEAR_LYRIC_CACHE = "settings_clear_lyric_cache";
  static const SETTINGS_CLEAR_LYRIC_CACHE_DESC =
      "settings_clear_lyric_cache_desc";

  static const SEARCH = "search";
  static const TRACKS = "tracks";
  static const PLAYED_RECENTLY = "played_recently";

  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': I18N_en_US,
        'zh_CN': I18N_zh_CN,
      };
}
