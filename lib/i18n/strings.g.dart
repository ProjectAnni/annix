/// Generated file. Do not edit.
///
/// Locales: 2
/// Strings: 78 (39 per locale)
///
/// Built on 2022-11-06 at 16:39 UTC

// coverage:ignore-file
// ignore_for_file: type=lint

import 'package:flutter/widgets.dart';
import 'package:slang/builder/model/node.dart';
import 'package:slang_flutter/slang_flutter.dart';
export 'package:slang_flutter/slang_flutter.dart';

const AppLocale _baseLocale = AppLocale.en;

/// Supported locales, see extension methods below.
///
/// Usage:
/// - LocaleSettings.setLocale(AppLocale.en) // set locale
/// - Locale locale = AppLocale.en.flutterLocale // get flutter locale from enum
/// - if (LocaleSettings.currentLocale == AppLocale.en) // locale check
enum AppLocale with BaseAppLocale<AppLocale, _StringsEn> {
	en(languageCode: 'en', build: _StringsEn.build),
	zhCn(languageCode: 'zh', countryCode: 'CN', build: _StringsZhCn.build);

	const AppLocale({required this.languageCode, this.scriptCode, this.countryCode, required this.build}); // ignore: unused_element

	@override final String languageCode;
	@override final String? scriptCode;
	@override final String? countryCode;
	@override final TranslationBuilder<AppLocale, _StringsEn> build;

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

	static _StringsEn of(BuildContext context) => InheritedLocaleData.of<AppLocale, _StringsEn>(context).translations;
}

/// The provider for method B
class TranslationProvider extends BaseTranslationProvider<AppLocale, _StringsEn> {
	TranslationProvider({required super.child}) : super(
		initLocale: LocaleSettings.instance.currentLocale,
		initTranslations: LocaleSettings.instance.currentTranslations,
	);

	static InheritedLocaleData<AppLocale, _StringsEn> of(BuildContext context) => InheritedLocaleData.of<AppLocale, _StringsEn>(context);
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
	LocaleSettings._() : super(locales: AppLocale.values, baseLocale: _baseLocale, utils: AppLocaleUtils.instance);

	static final instance = LocaleSettings._();

	// static aliases (checkout base methods for documentation)
	static AppLocale get currentLocale => instance.currentLocale;
	static Stream<AppLocale> getLocaleStream() => instance.getLocaleStream();
	static AppLocale setLocale(AppLocale locale) => instance.setLocale(locale);
	static AppLocale setLocaleRaw(String rawLocale) => instance.setLocaleRaw(rawLocale);
	static AppLocale useDeviceLocale() => instance.useDeviceLocale();
	static List<Locale> get supportedLocales => instance.supportedLocales;
	static List<String> get supportedLocalesRaw => instance.supportedLocalesRaw;
	static void setPluralResolver({String? language, AppLocale? locale, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver}) => instance.setPluralResolver(
		language: language,
		locale: locale,
		cardinalResolver: cardinalResolver,
		ordinalResolver: ordinalResolver,
	);
}

/// Provides utility functions without any side effects.
class AppLocaleUtils extends BaseAppLocaleUtils<AppLocale, _StringsEn> {
	AppLocaleUtils._() : super(baseLocale: _baseLocale, locales: AppLocale.values);

	static final instance = AppLocaleUtils._();

	// static aliases (checkout base methods for documentation)
	static AppLocale parse(String rawLocale) => instance.parse(rawLocale);
	static AppLocale parseLocaleParts({required String languageCode, String? scriptCode, String? countryCode}) => instance.parseLocaleParts(languageCode: languageCode, scriptCode: scriptCode, countryCode: countryCode);
	static AppLocale findDeviceLocale() => instance.findDeviceLocale();
}

// translations

// Path: <root>
class _StringsEn implements BaseTranslations<AppLocale, _StringsEn> {

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	_StringsEn.build({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, _StringsEn> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

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
	String get anniv_features => 'Login to Anniv for playlist, statistics and more features!';
}

// Path: settings
class _StringsSettingsEn {
	_StringsSettingsEn._(this._root);

  final _StringsEn _root; // ignore: unused_field

  // Translations
  String get settings => 'Settings';

  String get skip_cert => 'Skip SSL Certificate Verification';

  String get default_audio_quality => 'Default Audio Quality';

  String get auto_scale_ui => 'Auto scale UI';

  String get blur_playing_page => 'Blur playing page';

  String get use_mobile_network => 'Play under mobile network';

  String get view_logs => 'Logs';

  String get view_logs_desc => 'View Logs';

  String get clear_metadata_cache => 'Clear metadata cache';

  String get clear_metadata_cache_desc =>
      'You might need to re-fetch metadata from metadata source for local playback.';

  String get clear_lyric_cache => 'Clear lyric cache';

  String get clear_lyric_cache_desc => 'Delete all lyric cache.';

  String get clear_database => 'Clear database';

  String get clear_database_desc =>
      'Delete main database. You need to restart the app.';

  String get show_artist_in_bottom_player => 'Show artist in bottom player';

  String get show_artist_in_bottom_player_desc => 'Mobile only';

  String get enable_http2_for_annil => 'Enable HTTP/2 for Annil';

  String get enable_http2_for_annil_desc =>
      'HTTP/2 implemented by flutter/dart is problematic which may lead to slow download speed. Use it at your own risk.';

  String get custom_font_path => 'Custom Font Path';

  String get custom_font_not_specified => 'Not specified';
}

// Path: <root>
class _StringsZhCn implements _StringsEn {

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	_StringsZhCn.build({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = TranslationMetadata(
		    locale: AppLocale.zhCn,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <zh-CN>.
	@override final TranslationMetadata<AppLocale, _StringsEn> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key);

	@override late final _StringsZhCn _root = this; // ignore: unused_field

	// Translations
	@override String get playing => '播放';
	@override String get progress => '进度';
	@override String get home => '首页';
	@override String get category => '分类';
	@override String get albums => '专辑';
	@override String get playlists => '播放列表';
	@override String get shuffle_mode => '随机模式';
	@override String get my_favorite => '我的收藏';
	@override late final _StringsServerZhCn server = _StringsServerZhCn._(_root);
	@override late final _StringsSettingsZhCn settings = _StringsSettingsZhCn._(_root);
	@override String get search => '搜索';
	@override String get track => '单曲';
	@override String get recent_played => '最近播放';
	@override String get no_lyric_found => '未找到歌词';
	@override String get download_manager => '下载管理';
}

// Path: server
class _StringsServerZhCn implements _StringsServerEn {
	_StringsServerZhCn._(this._root);

	@override final _StringsZhCn _root; // ignore: unused_field

	// Translations
	@override String get server => '服务器';
	@override String get login => '登录';
	@override String get logout => '退出登录';
	@override String get not_logged_in => '未登录';
	@override String get libraries => '音频仓库';
	@override String get anniv_features => '登录 Anniv 以启用播放列表、播放统计等诸多功能。';
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
  String get default_audio_quality => '默认音质';

  @override
  String get auto_scale_ui => '自动 UI 缩放';

  @override
  String get blur_playing_page => '播放界面使用模糊背景';

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
  String get clear_database => '清除主数据库';

  @override
  String get clear_database_desc => '删除主数据库。你需要重新启动应用以重新创建数据库。';

  @override
  String get show_artist_in_bottom_player => '在播放条中显示艺术家';

  @override
  String get show_artist_in_bottom_player_desc => '移动端设置，桌面端无效。';

  @override
  String get enable_http2_for_annil => '为 Annil 启用 HTTP/2';

  @override
  String get enable_http2_for_annil_desc =>
      'Flutter/Dart 的 HTTP2 实现存在一些问题，会显著降低下载速度。';

  @override
  String get custom_font_path => '自定义字体路径';

  @override
  String get custom_font_not_specified => '默认字体';
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.

extension on _StringsEn {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'playing': return 'Playing';
			case 'progress': return 'Progress';
			case 'home': return 'Home';
			case 'category': return 'Categories';
			case 'albums': return 'Albums';
			case 'playlists': return 'Playlists';
      case 'shuffle_mode':
        return 'Shuffle Mode';
      case 'my_favorite':
        return 'My Favorite';
      case 'server.server':
        return 'Server';
      case 'server.login':
        return 'Login';
      case 'server.logout':
        return 'Logout';
      case 'server.not_logged_in':
        return 'Not logged in';
      case 'server.libraries':
        return 'Libraries';
      case 'server.anniv_features':
        return 'Login to Anniv for playlist, statistics and more features!';
      case 'settings.settings':
        return 'Settings';
      case 'settings.skip_cert':
        return 'Skip SSL Certificate Verification';
      case 'settings.default_audio_quality':
        return 'Default Audio Quality';
      case 'settings.auto_scale_ui':
        return 'Auto scale UI';
      case 'settings.blur_playing_page':
        return 'Blur playing page';
      case 'settings.use_mobile_network':
        return 'Play under mobile network';
      case 'settings.view_logs':
        return 'Logs';
      case 'settings.view_logs_desc':
        return 'View Logs';
      case 'settings.clear_metadata_cache':
        return 'Clear metadata cache';
      case 'settings.clear_metadata_cache_desc':
        return 'You might need to re-fetch metadata from metadata source for local playback.';
      case 'settings.clear_lyric_cache':
        return 'Clear lyric cache';
      case 'settings.clear_lyric_cache_desc':
        return 'Delete all lyric cache.';
      case 'settings.clear_database':
        return 'Clear database';
      case 'settings.clear_database_desc':
        return 'Delete main database. You need to restart the app.';
      case 'settings.show_artist_in_bottom_player':
        return 'Show artist in bottom player';
      case 'settings.show_artist_in_bottom_player_desc':
        return 'Mobile only';
      case 'settings.enable_http2_for_annil':
        return 'Enable HTTP/2 for Annil';
      case 'settings.enable_http2_for_annil_desc':
        return 'HTTP/2 implemented by flutter/dart is problematic which may lead to slow download speed. Use it at your own risk.';
      case 'settings.custom_font_path':
        return 'Custom Font Path';
      case 'settings.custom_font_not_specified':
        return 'Not specified';
      case 'search':
        return 'Search';
      case 'track':
        return 'Track';
      case 'recent_played':
        return 'Recently played';
      case 'no_lyric_found':
        return 'No lyric found';
      case 'download_manager':
        return 'Download manager';
      default:
        return null;
    }
  }
}

extension on _StringsZhCn {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'playing': return '播放';
			case 'progress': return '进度';
			case 'home': return '首页';
			case 'category': return '分类';
			case 'albums': return '专辑';
			case 'playlists': return '播放列表';
      case 'shuffle_mode':
        return '随机模式';
      case 'my_favorite':
        return '我的收藏';
      case 'server.server':
        return '服务器';
      case 'server.login':
        return '登录';
      case 'server.logout':
        return '退出登录';
      case 'server.not_logged_in':
        return '未登录';
      case 'server.libraries':
        return '音频仓库';
      case 'server.anniv_features':
        return '登录 Anniv 以启用播放列表、播放统计等诸多功能。';
      case 'settings.settings':
        return '设置';
      case 'settings.skip_cert':
        return '忽略证书验证';
      case 'settings.default_audio_quality':
        return '默认音质';
      case 'settings.auto_scale_ui':
        return '自动 UI 缩放';
      case 'settings.blur_playing_page':
        return '播放界面使用模糊背景';
      case 'settings.use_mobile_network':
        return '使用移动网络播放';
      case 'settings.view_logs':
        return '应用日志';
      case 'settings.view_logs_desc':
        return '查看应用日志。';
      case 'settings.clear_metadata_cache':
        return '清除元数据缓存';
      case 'settings.clear_metadata_cache_desc':
        return '当你使用的元数据来源为远程时，可能需要从远程重新获取本地音频缓存对应的元数据。';
      case 'settings.clear_lyric_cache':
        return '清除歌词缓存';
      case 'settings.clear_lyric_cache_desc':
        return '删除本地缓存的所有歌词。';
      case 'settings.clear_database':
        return '清除主数据库';
      case 'settings.clear_database_desc':
        return '删除主数据库。你需要重新启动应用以重新创建数据库。';
      case 'settings.show_artist_in_bottom_player':
        return '在播放条中显示艺术家';
      case 'settings.show_artist_in_bottom_player_desc':
        return '移动端设置，桌面端无效。';
      case 'settings.enable_http2_for_annil':
        return '为 Annil 启用 HTTP/2';
      case 'settings.enable_http2_for_annil_desc':
        return 'Flutter/Dart 的 HTTP2 实现存在一些问题，会显著降低下载速度。';
      case 'settings.custom_font_path':
        return '自定义字体路径';
      case 'settings.custom_font_not_specified':
        return '默认字体';
      case 'search':
        return '搜索';
      case 'track':
        return '单曲';
      case 'recent_played':
        return '最近播放';
      case 'no_lyric_found':
        return '未找到歌词';
      case 'download_manager':
        return '下载管理';
      default:
        return null;
    }
  }
}
