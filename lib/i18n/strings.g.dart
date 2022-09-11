/// Generated file. Do not edit.
///
/// Locales: 2
/// Strings: 62 (31 per locale)
///
/// Built on 2022-09-11 at 14:13 UTC

// coverage:ignore-file
// ignore_for_file: type=lint

import 'package:flutter/widgets.dart';
import 'package:slang_flutter/slang_flutter.dart';
export 'package:slang_flutter/slang_flutter.dart';

const AppLocale _baseLocale = AppLocale.en;

/// Supported locales, see extension methods below.
///
/// Usage:
/// - LocaleSettings.setLocale(AppLocale.en) // set locale
/// - Locale locale = AppLocale.en.flutterLocale // get flutter locale from enum
/// - if (LocaleSettings.currentLocale == AppLocale.en) // locale check
enum AppLocale with BaseAppLocale<_StringsEn> {
  en(languageCode: 'en', build: _StringsEn.build),
  zhCn(languageCode: 'zh', countryCode: 'CN', build: _StringsZhCn.build);

  const AppLocale(
      {required this.languageCode,
      this.scriptCode,
      this.countryCode,
      required this.build}); // ignore: unused_element

  @override
  final String languageCode;
  @override
  final String? scriptCode;
  @override
  final String? countryCode;
  @override
  final TranslationBuilder<_StringsEn> build;

  /// Gets current instance managed by [LocaleSettings].
  _StringsEn get translations => LocaleSettings.instance.translationMap[this]!;
}

/// Method A: Simple
///
/// No rebuild after locale change.
/// Translation happens during initialization of the widget (call of t).
/// Configurable via 'translate_var'.
///
/// Usage:
/// String a = t.someKey.anotherKey;
/// String b = t['someKey.anotherKey']; // Only for edge cases!
_StringsEn get t => LocaleSettings.instance.currentTranslations;

/// Method B: Advanced
///
/// All widgets using this method will trigger a rebuild when locale changes.
/// Use this if you have e.g. a settings page where the user can select the locale during runtime.
///
/// Step 1:
/// wrap your App with
/// TranslationProvider(
/// 	child: MyApp()
/// );
///
/// Step 2:
/// final t = Translations.of(context); // Get t variable.
/// String a = t.someKey.anotherKey; // Use t variable.
/// String b = t['someKey.anotherKey']; // Only for edge cases!
class Translations {
	Translations._(); // no constructor

	static _StringsEn of(BuildContext context) =>
      InheritedLocaleData.of<AppLocale, _StringsEn>(context).translations;
}

/// The provider for method B
class TranslationProvider
    extends BaseTranslationProvider<AppLocale, _StringsEn> {
  TranslationProvider({required super.child})
      : super(
          initLocale: LocaleSettings.instance.currentLocale,
          initTranslations: LocaleSettings.instance.currentTranslations,
        );

  static InheritedLocaleData<AppLocale, _StringsEn> of(BuildContext context) =>
      InheritedLocaleData.of<AppLocale, _StringsEn>(context);
}

/// Method B shorthand via [BuildContext] extension method.
/// Configurable via 'translate_var'.
///
/// Usage (e.g. in a widget's build method):
/// context.t.someKey.anotherKey
extension BuildContextTranslationsExtension on BuildContext {
	_StringsEn get t => TranslationProvider.of(this).translations;
}

/// Manages all translation instances and the current locale
class LocaleSettings extends BaseFlutterLocaleSettings<AppLocale, _StringsEn> {
  LocaleSettings._()
      : super(
          locales: AppLocale.values,
          baseLocale: _baseLocale,
          utils: AppLocaleUtils.instance,
        );

  static final instance = LocaleSettings._();

  // static aliases (checkout base methods for documentation)
  static AppLocale get currentLocale => instance.currentLocale;

  static Stream<AppLocale> getLocaleStream() => instance.getLocaleStream();

  static AppLocale setLocale(AppLocale locale) => instance.setLocale(locale);

  static AppLocale setLocaleRaw(String rawLocale) =>
      instance.setLocaleRaw(rawLocale);

  static AppLocale useDeviceLocale() => instance.useDeviceLocale();

  static List<Locale> get supportedLocales => instance.supportedLocales;

  static List<String> get supportedLocalesRaw => instance.supportedLocalesRaw;

  static void setPluralResolver(
          {String? language,
          AppLocale? locale,
          PluralResolver? cardinalResolver,
          PluralResolver? ordinalResolver}) =>
      instance.setPluralResolver(
        language: language,
        locale: locale,
        cardinalResolver: cardinalResolver,
        ordinalResolver: ordinalResolver,
      );
}

/// Provides utility functions without any side effects.
class AppLocaleUtils extends BaseAppLocaleUtils<AppLocale, _StringsEn> {
	AppLocaleUtils._()
      : super(baseLocale: _baseLocale, locales: AppLocale.values);

  static final instance = AppLocaleUtils._();

  // static aliases (checkout base methods for documentation)
  static AppLocale parse(String rawLocale) => instance.parse(rawLocale);

  static AppLocale findDeviceLocale() => instance.findDeviceLocale();
}

// translations

// Path: <root>
class _StringsEn implements BaseTranslations {
  /// You can call this constructor and build your own translation instance of this locale.
  /// Constructing via the enum [AppLocale.build] is preferred.
  _StringsEn.build(
      {PluralResolver? cardinalResolver, PluralResolver? ordinalResolver})
      : _cardinalResolver = cardinalResolver,
        _ordinalResolver = ordinalResolver;

  /// Access flat map
  dynamic operator [](String key) => _flatMap[key];

  // Internal flat map initialized lazily
  late final Map<String, dynamic> _flatMap = _buildFlatMap();

  final PluralResolver? _cardinalResolver; // ignore: unused_field
  final PluralResolver? _ordinalResolver; // ignore: unused_field

  late final _StringsEn _root = this; // ignore: unused_field

  // Translations
  String get playing => 'Playing';

  String get progress => 'Progress';

  String get home => 'Home';

  String get category => 'Categories';

  String get albums => 'Albums';

  String get playlists => 'Playlists';

  String get shuffle_mode => 'Shuffle Mode';

  String get my_favorite => 'My Favorite';
  late final _StringsServerEn server = _StringsServerEn._(_root);
  late final _StringsSettingsEn settings = _StringsSettingsEn._(_root);

  String get search => 'Search';

  String get track => 'Track';

  String get recent_played => 'Recently played';

  String get no_lyric_found => 'No lyric found';

  String get download_manager => 'Download manager';
}

// Path: server
class _StringsServerEn {
	_StringsServerEn._(this._root);

  final _StringsEn _root; // ignore: unused_field

  // Translations
  String get server => 'Server';

  String get login => 'Login';

  String get logout => 'Logout';

  String get not_logged_in => 'Not logged in';

  String get libraries => 'Libraries';

  String get anniv_features =>
      'Login to Anniv for playlist, statistics and more features!';
}

// Path: settings
class _StringsSettingsEn {
	_StringsSettingsEn._(this._root);

  final _StringsEn _root; // ignore: unused_field

  // Translations
  String get settings => 'Settings';

  String get skip_cert => 'Skip SSL Certificate Verification';

  String get auto_scale_ui => 'Auto scale UI';

  String get use_mobile_network => 'Play under mobile network';

  String get view_logs => 'Logs';

  String get view_logs_desc => 'View Logs';

  String get clear_metadata_cache => 'Clear metadata cache';

  String get clear_metadata_cache_desc =>
      'You might need to re-fetch metadata from metadata source for local playback.';

  String get clear_lyric_cache => 'Clear lyric cache';

  String get clear_lyric_cache_desc => 'Delete all lyric cache.';

  String get show_artist_in_bottom_player => 'Show artist in bottom player';

  String get show_artist_in_bottom_player_desc => 'Mobile only';
}

// Path: <root>
class _StringsZhCn implements _StringsEn {
  /// You can call this constructor and build your own translation instance of this locale.
  /// Constructing via the enum [AppLocale.build] is preferred.
  _StringsZhCn.build(
      {PluralResolver? cardinalResolver, PluralResolver? ordinalResolver})
      : _cardinalResolver = cardinalResolver,
        _ordinalResolver = ordinalResolver;

  /// Access flat map
  @override
  dynamic operator [](String key) => _flatMap[key];

  // Internal flat map initialized lazily
  @override
  late final Map<String, dynamic> _flatMap = _buildFlatMap();

  @override
  final PluralResolver? _cardinalResolver; // ignore: unused_field
  @override
  final PluralResolver? _ordinalResolver; // ignore: unused_field

  @override
  late final _StringsZhCn _root = this; // ignore: unused_field

  // Translations
  @override
  String get playing => '播放';

  @override
  String get progress => '进度';

  @override
  String get home => '首页';

  @override
  String get category => '分类';

  @override
  String get albums => '专辑';

  @override
  String get playlists => '播放列表';

  @override
  String get shuffle_mode => '随机模式';

  @override
  String get my_favorite => '我的收藏';
  @override
  late final _StringsServerZhCn server = _StringsServerZhCn._(_root);
  @override
  late final _StringsSettingsZhCn settings = _StringsSettingsZhCn._(_root);

  @override
  String get search => '搜索';

  @override
  String get track => '单曲';

  @override
  String get recent_played => '最近播放';

  @override
  String get no_lyric_found => '未找到歌词';

  @override
  String get download_manager => '下载管理';
}

// Path: server
class _StringsServerZhCn implements _StringsServerEn {
	_StringsServerZhCn._(this._root);

  @override
  final _StringsZhCn _root; // ignore: unused_field

  // Translations
  @override
  String get server => '服务器';

  @override
  String get login => '登录';

  @override
  String get logout => '退出登录';

  @override
  String get not_logged_in => '未登录';

  @override
  String get libraries => '音频仓库';

  @override
  String get anniv_features => '登录 Anniv 以启用播放列表、播放统计等诸多功能。';
}

// Path: settings
class _StringsSettingsZhCn implements _StringsSettingsEn {
	_StringsSettingsZhCn._(this._root);

  @override
  final _StringsZhCn _root; // ignore: unused_field

  // Translations
  @override
  String get settings => '设置';

  @override
  String get skip_cert => '忽略证书验证';

  @override
  String get auto_scale_ui => '自动 UI 缩放';

  @override
  String get use_mobile_network => '使用移动网络播放';

  @override
  String get view_logs => '应用日志';

  @override
  String get view_logs_desc => '查看应用日志。';

  @override
  String get clear_metadata_cache => '清除元数据缓存';

  @override
  String get clear_metadata_cache_desc =>
      '当你使用的元数据来源为远程时，可能需要从远程重新获取本地音频缓存对应的元数据。';

  @override
  String get clear_lyric_cache => '清除歌词缓存';

  @override
  String get clear_lyric_cache_desc => '删除本地缓存的所有歌词。';

  @override
  String get show_artist_in_bottom_player => '在播放条中显示艺术家';

  @override
  String get show_artist_in_bottom_player_desc => '移动端设置，桌面端无效。';
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.

extension on _StringsEn {
  Map<String, dynamic> _buildFlatMap() {
    return <String, dynamic>{
      'playing': 'Playing',
      'progress': 'Progress',
      'home': 'Home',
      'category': 'Categories',
      'albums': 'Albums',
      'playlists': 'Playlists',
      'shuffle_mode': 'Shuffle Mode',
      'my_favorite': 'My Favorite',
      'server.server': 'Server',
      'server.login': 'Login',
      'server.logout': 'Logout',
      'server.not_logged_in': 'Not logged in',
      'server.libraries': 'Libraries',
      'server.anniv_features':
          'Login to Anniv for playlist, statistics and more features!',
      'settings.settings': 'Settings',
      'settings.skip_cert': 'Skip SSL Certificate Verification',
      'settings.auto_scale_ui': 'Auto scale UI',
      'settings.use_mobile_network': 'Play under mobile network',
      'settings.view_logs': 'Logs',
      'settings.view_logs_desc': 'View Logs',
      'settings.clear_metadata_cache': 'Clear metadata cache',
      'settings.clear_metadata_cache_desc':
          'You might need to re-fetch metadata from metadata source for local playback.',
      'settings.clear_lyric_cache': 'Clear lyric cache',
      'settings.clear_lyric_cache_desc': 'Delete all lyric cache.',
      'settings.show_artist_in_bottom_player': 'Show artist in bottom player',
      'settings.show_artist_in_bottom_player_desc': 'Mobile only',
      'search': 'Search',
      'track': 'Track',
      'recent_played': 'Recently played',
      'no_lyric_found': 'No lyric found',
      'download_manager': 'Download manager',
    };
  }
}

extension on _StringsZhCn {
  Map<String, dynamic> _buildFlatMap() {
    return <String, dynamic>{
      'playing': '播放',
      'progress': '进度',
      'home': '首页',
      'category': '分类',
      'albums': '专辑',
      'playlists': '播放列表',
      'shuffle_mode': '随机模式',
      'my_favorite': '我的收藏',
      'server.server': '服务器',
      'server.login': '登录',
      'server.logout': '退出登录',
      'server.not_logged_in': '未登录',
      'server.libraries': '音频仓库',
      'server.anniv_features': '登录 Anniv 以启用播放列表、播放统计等诸多功能。',
      'settings.settings': '设置',
      'settings.skip_cert': '忽略证书验证',
      'settings.auto_scale_ui': '自动 UI 缩放',
      'settings.use_mobile_network': '使用移动网络播放',
      'settings.view_logs': '应用日志',
      'settings.view_logs_desc': '查看应用日志。',
      'settings.clear_metadata_cache': '清除元数据缓存',
      'settings.clear_metadata_cache_desc':
          '当你使用的元数据来源为远程时，可能需要从远程重新获取本地音频缓存对应的元数据。',
      'settings.clear_lyric_cache': '清除歌词缓存',
      'settings.clear_lyric_cache_desc': '删除本地缓存的所有歌词。',
      'settings.show_artist_in_bottom_player': '在播放条中显示艺术家',
      'settings.show_artist_in_bottom_player_desc': '移动端设置，桌面端无效。',
      'search': '搜索',
      'track': '单曲',
      'recent_played': '最近播放',
      'no_lyric_found': '未找到歌词',
      'download_manager': '下载管理',
    };
  }
}
