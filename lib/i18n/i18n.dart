import 'package:annix/i18n/i18n_en_US.dart';
import 'package:annix/i18n/i18n_zh_CN.dart';
import 'package:get/get.dart';

class I18n extends Translations {
  static const HOME = "home";
  static const ALBUMS = "albums";
  static const PLAYLISTS = "playlists";

  static const SERVER = "server";
  static const LOGIN = "login";
  static const LOGOUT = "logout";
  static const ANNIL_LIBRARIES = "annil_library";

  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': I18N_en_US,
        'zh_CN': I18N_zh_CN,
      };
}
