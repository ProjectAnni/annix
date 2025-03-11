/// Generated file. Do not edit.
///
/// Original: lib/i18n
/// To regenerate, run: `dart run slang`
///
/// Locales: 2
/// Strings: 144 (72 per locale)
///
/// Built on 2025-03-11 at 13:25 UTC

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
enum AppLocale with BaseAppLocale<AppLocale, Translations> {
	en(languageCode: 'en', build: Translations.build),
	zhCn(languageCode: 'zh', countryCode: 'CN', build: _StringsZhCn.build);

	const AppLocale({required this.languageCode, this.scriptCode, this.countryCode, required this.build}); // ignore: unused_element

	@override final String languageCode;
	@override final String? scriptCode;
	@override final String? countryCode;
	@override final TranslationBuilder<AppLocale, Translations> build;

	/// Gets current instance managed by [LocaleSettings].
	Translations get translations => LocaleSettings.instance.translationMap[this]!;
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
Translations get t => LocaleSettings.instance.currentTranslations;

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
class TranslationProvider extends BaseTranslationProvider<AppLocale, Translations> {
	TranslationProvider({required super.child}) : super(settings: LocaleSettings.instance);

	static InheritedLocaleData<AppLocale, Translations> of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context);
}

/// Method B shorthand via [BuildContext] extension method.
/// Configurable via 'translate_var'.
///
/// Usage (e.g. in a widget's build method):
/// context.t.someKey.anotherKey
extension BuildContextTranslationsExtension on BuildContext {
	Translations get t => TranslationProvider.of(this).translations;
}

/// Manages all translation instances and the current locale
class LocaleSettings extends BaseFlutterLocaleSettings<AppLocale, Translations> {
	LocaleSettings._() : super(utils: AppLocaleUtils.instance);

	static final instance = LocaleSettings._();

	// static aliases (checkout base methods for documentation)
	static AppLocale get currentLocale => instance.currentLocale;
	static Stream<AppLocale> getLocaleStream() => instance.getLocaleStream();
	static AppLocale setLocale(AppLocale locale, {bool? listenToDeviceLocale = false}) => instance.setLocale(locale, listenToDeviceLocale: listenToDeviceLocale);
	static AppLocale setLocaleRaw(String rawLocale, {bool? listenToDeviceLocale = false}) => instance.setLocaleRaw(rawLocale, listenToDeviceLocale: listenToDeviceLocale);
	static AppLocale useDeviceLocale() => instance.useDeviceLocale();
	@Deprecated('Use [AppLocaleUtils.supportedLocales]') static List<Locale> get supportedLocales => instance.supportedLocales;
	@Deprecated('Use [AppLocaleUtils.supportedLocalesRaw]') static List<String> get supportedLocalesRaw => instance.supportedLocalesRaw;
	static void setPluralResolver({String? language, AppLocale? locale, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver}) => instance.setPluralResolver(
		language: language,
		locale: locale,
		cardinalResolver: cardinalResolver,
		ordinalResolver: ordinalResolver,
	);
}

/// Provides utility functions without any side effects.
class AppLocaleUtils extends BaseAppLocaleUtils<AppLocale, Translations> {
	AppLocaleUtils._() : super(baseLocale: _baseLocale, locales: AppLocale.values);

	static final instance = AppLocaleUtils._();

	// static aliases (checkout base methods for documentation)
	static AppLocale parse(String rawLocale) => instance.parse(rawLocale);
	static AppLocale parseLocaleParts({required String languageCode, String? scriptCode, String? countryCode}) => instance.parseLocaleParts(languageCode: languageCode, scriptCode: scriptCode, countryCode: countryCode);
	static AppLocale findDeviceLocale() => instance.findDeviceLocale();
	static List<Locale> get supportedLocales => instance.supportedLocales;
	static List<String> get supportedLocalesRaw => instance.supportedLocalesRaw;
}

// translations

// Path: <root>
class Translations implements BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations.build({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver})
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
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	// Translations
	String get progress => 'Progress';
	String get home => 'Home';
	String get category => 'Categories';
	String get albums => 'Albums';
	String get playlists => 'Playlists';
	String get shuffle_mode => 'Shuffle Mode';
	String get my_favorite => 'My Favorite';
	String get music => 'Music';
	late final _StringsPlayingEn playing = _StringsPlayingEn._(_root);
	late final _StringsPlaybackEn playback = _StringsPlaybackEn._(_root);
	late final _StringsPlaylistEn playlist = _StringsPlaylistEn._(_root);
	late final _StringsServerEn server = _StringsServerEn._(_root);
	late final _StringsSettingsEn settings = _StringsSettingsEn._(_root);
	String get search => 'Search';
	late final _StringsTrackEn track = _StringsTrackEn._(_root);
	String get tracks => 'Tracks';
	String get recent_played => 'Recently played';
	String get no_lyric_found => 'No lyric found';
	String get download => 'Download';
	String get download_manager => 'Download manager';
	late final _StringsIntroEn intro = _StringsIntroEn._(_root);
}

// Path: playing
class _StringsPlayingEn {
	_StringsPlayingEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get is_playing => 'Playing';
	String get view_album => 'View Album';
}

// Path: playback
class _StringsPlaybackEn {
	_StringsPlaybackEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get play_all => 'Play All';
	String get shuffle => 'Shuffle';
}

// Path: playlist
class _StringsPlaylistEn {
	_StringsPlaylistEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get edit => 'Edit';
	String get title => 'Title';
	String get description => 'Description';
	String get create_new => 'Create New Playlist';
	String get created => 'Playlist created';
}

// Path: server
class _StringsServerEn {
	_StringsServerEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get server => 'Server';
	String get login => 'Login';
	String get logout => 'Logout';
	String get not_logged_in => 'Not logged in';
	String get libraries => 'Libraries';
	String get login_to_anniv => 'Login to Anniv';
	String get anniv_features => 'Login to Anniv for playlist, statistics and more features!';
}

// Path: settings
class _StringsSettingsEn {
	_StringsSettingsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get settings => 'Settings';
	String get skip_cert => 'Skip SSL Certificate Verification';
	String get default_audio_quality => 'Default Audio Quality';
	String get blur_playing_page => 'Blur playing page';
	String get use_mobile_network => 'Play under mobile network';
	String get view_logs => 'Logs';
	String get view_logs_desc => 'View Logs';
	String get clear_metadata_cache => 'Clear metadata cache';
	String get clear_metadata_cache_desc => 'You might need to re-fetch metadata from metadata source for local playback.';
	String get clear_lyric_cache => 'Clear lyric cache';
	String get clear_lyric_cache_desc => 'Delete all lyric cache.';
	String get clear_database => 'Clear database';
	String get clear_database_desc => 'Delete main database. You need to restart the app.';
	String get show_artist_in_bottom_player => 'Show artist in mini player';
	String get show_artist_in_bottom_player_desc => 'Only works on mobile devices.';
	String get custom_font_path => 'Custom Font Path';
	String get custom_font_not_specified => 'Not specified';
}

// Path: track
class _StringsTrackEn {
	_StringsTrackEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get add_to_playlist => 'Add to playlist';
	String get remove_from_playlist => 'Remove from playlist';
	String get add_to_queue => 'Add to queue';
	String get share => 'Share track';
}

// Path: intro
class _StringsIntroEn {
	_StringsIntroEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final _StringsIntroWelcomeEn welcome = _StringsIntroWelcomeEn._(_root);
	late final _StringsIntroEnjoyMusicEn enjoy_music = _StringsIntroEnjoyMusicEn._(_root);
	late final _StringsIntroHostRemotelyEn host_remotely = _StringsIntroHostRemotelyEn._(_root);
	late final _StringsIntroFullyFeaturedEn fully_featured = _StringsIntroFullyFeaturedEn._(_root);
	late final _StringsIntroLoginEn login = _StringsIntroLoginEn._(_root);
	late final _StringsIntroAboutAnnivEn about_anniv = _StringsIntroAboutAnnivEn._(_root);
	late final _StringsIntroActionEn action = _StringsIntroActionEn._(_root);
}

// Path: intro.welcome
class _StringsIntroWelcomeEn {
	_StringsIntroWelcomeEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get heading => 'Welcome!';
	String get description => 'This is Annix, a full-featured music player designed for You.';
}

// Path: intro.enjoy_music
class _StringsIntroEnjoyMusicEn {
	_StringsIntroEnjoyMusicEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get heading => 'Enjoy Music';
	String get description => 'Annix supports two primary audio formats: FLAC for lossless audio and OPUS for lossy audio. Additionally, it offers gapless playback, ensuring smooth transitions between tracks.';
}

// Path: intro.host_remotely
class _StringsIntroHostRemotelyEn {
	_StringsIntroHostRemotelyEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get heading => 'Host remotely';
	String get description => 'Host your own Annil instance to manage your personal music collection and enjoy it from anywhere by streaming the tracks on demand.';
}

// Path: intro.fully_featured
class _StringsIntroFullyFeaturedEn {
	_StringsIntroFullyFeaturedEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get heading => 'Fully featured';
	String get description => 'Lyric, playlist, statistics, ..., and everything you think a music player should have!';
}

// Path: intro.login
class _StringsIntroLoginEn {
	_StringsIntroLoginEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get heading => 'And...';
	String get description => 'Log in to the Anniv server and take advantage of all these amazing features!';
	String get self_host => 'Use self-hosted Anniv instance';
	String get email => 'Email';
	String get password => 'Password';
	String get server => 'Anniv Server';
}

// Path: intro.about_anniv
class _StringsIntroAboutAnnivEn {
	_StringsIntroAboutAnnivEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get heading => 'About Anniv';
	String get ribbon_features => 'Project Anni provides an official instance of Anniv called Ribbon. This server is free to use and provides features like playlist, lyric, and statistics.';
	String get how_to_self_host => 'If you want to host your own instance of Anniv, check out the project at https://anni.rs and follow the instructions to set up your own server.';
	String get confirm => 'Got it';
}

// Path: intro.action
class _StringsIntroActionEn {
	_StringsIntroActionEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get skip => 'Skip';
	String get next => 'Next';
	String get login => 'Login';
}

// Path: <root>
class _StringsZhCn implements Translations {
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
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key);

	@override late final _StringsZhCn _root = this; // ignore: unused_field

	// Translations
	@override String get progress => '进度';
	@override String get home => '首页';
	@override String get category => '分类';
	@override String get albums => '专辑';
	@override String get playlists => '播放列表';
	@override String get shuffle_mode => '随机模式';
	@override String get my_favorite => '我的收藏';
	@override String get music => '音乐';
	@override late final _StringsPlayingZhCn playing = _StringsPlayingZhCn._(_root);
	@override late final _StringsPlaybackZhCn playback = _StringsPlaybackZhCn._(_root);
	@override late final _StringsPlaylistZhCn playlist = _StringsPlaylistZhCn._(_root);
	@override late final _StringsServerZhCn server = _StringsServerZhCn._(_root);
	@override late final _StringsSettingsZhCn settings = _StringsSettingsZhCn._(_root);
	@override String get search => '搜索';
	@override late final _StringsTrackZhCn track = _StringsTrackZhCn._(_root);
	@override String get tracks => '单曲';
	@override String get recent_played => '最近播放';
	@override String get no_lyric_found => '未找到歌词';
	@override String get download => '下载';
	@override String get download_manager => '下载管理';
	@override late final _StringsIntroZhCn intro = _StringsIntroZhCn._(_root);
}

// Path: playing
class _StringsPlayingZhCn implements _StringsPlayingEn {
	_StringsPlayingZhCn._(this._root);

	@override final _StringsZhCn _root; // ignore: unused_field

	// Translations
	@override String get is_playing => '正在播放';
	@override String get view_album => '查看专辑';
}

// Path: playback
class _StringsPlaybackZhCn implements _StringsPlaybackEn {
	_StringsPlaybackZhCn._(this._root);

	@override final _StringsZhCn _root; // ignore: unused_field

	// Translations
	@override String get play_all => '播放全部';
	@override String get shuffle => '随机播放';
}

// Path: playlist
class _StringsPlaylistZhCn implements _StringsPlaylistEn {
	_StringsPlaylistZhCn._(this._root);

	@override final _StringsZhCn _root; // ignore: unused_field

	// Translations
	@override String get edit => '编辑';
	@override String get title => '标题';
	@override String get description => '描述';
	@override String get create_new => '创建新播放列表';
	@override String get created => '播放列表已创建';
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
	@override String get login_to_anniv => '登录 Anniv';
	@override String get anniv_features => '登录 Anniv 以启用播放列表、播放统计等诸多功能。';
}

// Path: settings
class _StringsSettingsZhCn implements _StringsSettingsEn {
	_StringsSettingsZhCn._(this._root);

	@override final _StringsZhCn _root; // ignore: unused_field

	// Translations
	@override String get settings => '设置';
	@override String get skip_cert => '忽略证书验证';
	@override String get default_audio_quality => '默认音质';
	@override String get blur_playing_page => '播放界面使用模糊背景';
	@override String get use_mobile_network => '使用移动网络播放';
	@override String get view_logs => '应用日志';
	@override String get view_logs_desc => '查看应用日志。';
	@override String get clear_metadata_cache => '清除元数据缓存';
	@override String get clear_metadata_cache_desc => '当你使用的元数据来源为远程时，可能需要从远程重新获取本地音频缓存对应的元数据。';
	@override String get clear_lyric_cache => '清除歌词缓存';
	@override String get clear_lyric_cache_desc => '删除本地缓存的所有歌词。';
	@override String get clear_database => '清除主数据库';
	@override String get clear_database_desc => '删除主数据库。你需要重新启动应用以重新创建数据库。';
	@override String get show_artist_in_bottom_player => '在播放条中显示艺术家';
	@override String get show_artist_in_bottom_player_desc => '移动端设置，桌面端无效。';
	@override String get custom_font_path => '自定义字体路径';
	@override String get custom_font_not_specified => '默认字体';
}

// Path: track
class _StringsTrackZhCn implements _StringsTrackEn {
	_StringsTrackZhCn._(this._root);

	@override final _StringsZhCn _root; // ignore: unused_field

	// Translations
	@override String get add_to_playlist => '保存到播放列表';
	@override String get remove_from_playlist => '从播放列表删除';
	@override String get add_to_queue => '添加到待播列表';
	@override String get share => '分享歌曲';
}

// Path: intro
class _StringsIntroZhCn implements _StringsIntroEn {
	_StringsIntroZhCn._(this._root);

	@override final _StringsZhCn _root; // ignore: unused_field

	// Translations
	@override late final _StringsIntroWelcomeZhCn welcome = _StringsIntroWelcomeZhCn._(_root);
	@override late final _StringsIntroEnjoyMusicZhCn enjoy_music = _StringsIntroEnjoyMusicZhCn._(_root);
	@override late final _StringsIntroHostRemotelyZhCn host_remotely = _StringsIntroHostRemotelyZhCn._(_root);
	@override late final _StringsIntroFullyFeaturedZhCn fully_featured = _StringsIntroFullyFeaturedZhCn._(_root);
	@override late final _StringsIntroLoginZhCn login = _StringsIntroLoginZhCn._(_root);
	@override late final _StringsIntroAboutAnnivZhCn about_anniv = _StringsIntroAboutAnnivZhCn._(_root);
	@override late final _StringsIntroActionZhCn action = _StringsIntroActionZhCn._(_root);
}

// Path: intro.welcome
class _StringsIntroWelcomeZhCn implements _StringsIntroWelcomeEn {
	_StringsIntroWelcomeZhCn._(this._root);

	@override final _StringsZhCn _root; // ignore: unused_field

	// Translations
	@override String get heading => '欢迎使用';
	@override String get description => 'Annix，一款为音频整理者设计的全功能音乐播放器。';
}

// Path: intro.enjoy_music
class _StringsIntroEnjoyMusicZhCn implements _StringsIntroEnjoyMusicEn {
	_StringsIntroEnjoyMusicZhCn._(this._root);

	@override final _StringsZhCn _root; // ignore: unused_field

	// Translations
	@override String get heading => '聆听';
	@override String get description => 'Annix 支持两种主流音频格式：FLAC 用于无损音频；OPUS 用于有损音频。此外，它还支持无缝播放，确保曲目之间的平滑过渡。';
}

// Path: intro.host_remotely
class _StringsIntroHostRemotelyZhCn implements _StringsIntroHostRemotelyEn {
	_StringsIntroHostRemotelyZhCn._(this._root);

	@override final _StringsZhCn _root; // ignore: unused_field

	// Translations
	@override String get heading => '自建云曲库';
	@override String get description => '通过自建 Annil 实例管理个人音乐收藏，在任何设备上享受你的曲库！';
}

// Path: intro.fully_featured
class _StringsIntroFullyFeaturedZhCn implements _StringsIntroFullyFeaturedEn {
	_StringsIntroFullyFeaturedZhCn._(this._root);

	@override final _StringsZhCn _root; // ignore: unused_field

	// Translations
	@override String get heading => '功能齐全';
	@override String get description => '包括歌词、播放列表、统计分析等在内的全面功能，应有尽有，满足您对音乐播放器的所有需求！';
}

// Path: intro.login
class _StringsIntroLoginZhCn implements _StringsIntroLoginEn {
	_StringsIntroLoginZhCn._(this._root);

	@override final _StringsZhCn _root; // ignore: unused_field

	// Translations
	@override String get heading => '最后……';
	@override String get description => '登录 Anniv 服务器，畅享精彩功能！';
	@override String get self_host => '使用自托管实例';
	@override String get email => '邮箱';
	@override String get password => '密码';
	@override String get server => 'Anniv 服务器地址';
}

// Path: intro.about_anniv
class _StringsIntroAboutAnnivZhCn implements _StringsIntroAboutAnnivEn {
	_StringsIntroAboutAnnivZhCn._(this._root);

	@override final _StringsZhCn _root; // ignore: unused_field

	// Translations
	@override String get heading => '关于 Anniv';
	@override String get ribbon_features => 'Project Anni 提供了官方 Anniv 实例 Ribbon，用户可免费使用。支持播放列表、歌词、统计等功能。';
	@override String get how_to_self_host => '如果您想自行部署 Anniv 实例，请访问 https://anni.rs 并按照说明进行设置。';
	@override String get confirm => '我知道了';
}

// Path: intro.action
class _StringsIntroActionZhCn implements _StringsIntroActionEn {
	_StringsIntroActionZhCn._(this._root);

	@override final _StringsZhCn _root; // ignore: unused_field

	// Translations
	@override String get skip => '跳过';
	@override String get next => '下一步';
	@override String get login => '登录';
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.

extension on Translations {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'progress': return 'Progress';
			case 'home': return 'Home';
			case 'category': return 'Categories';
			case 'albums': return 'Albums';
			case 'playlists': return 'Playlists';
			case 'shuffle_mode': return 'Shuffle Mode';
			case 'my_favorite': return 'My Favorite';
			case 'music': return 'Music';
			case 'playing.is_playing': return 'Playing';
			case 'playing.view_album': return 'View Album';
			case 'playback.play_all': return 'Play All';
			case 'playback.shuffle': return 'Shuffle';
			case 'playlist.edit': return 'Edit';
			case 'playlist.title': return 'Title';
			case 'playlist.description': return 'Description';
			case 'playlist.create_new': return 'Create New Playlist';
			case 'playlist.created': return 'Playlist created';
			case 'server.server': return 'Server';
			case 'server.login': return 'Login';
			case 'server.logout': return 'Logout';
			case 'server.not_logged_in': return 'Not logged in';
			case 'server.libraries': return 'Libraries';
			case 'server.login_to_anniv': return 'Login to Anniv';
			case 'server.anniv_features': return 'Login to Anniv for playlist, statistics and more features!';
			case 'settings.settings': return 'Settings';
			case 'settings.skip_cert': return 'Skip SSL Certificate Verification';
			case 'settings.default_audio_quality': return 'Default Audio Quality';
			case 'settings.blur_playing_page': return 'Blur playing page';
			case 'settings.use_mobile_network': return 'Play under mobile network';
			case 'settings.view_logs': return 'Logs';
			case 'settings.view_logs_desc': return 'View Logs';
			case 'settings.clear_metadata_cache': return 'Clear metadata cache';
			case 'settings.clear_metadata_cache_desc': return 'You might need to re-fetch metadata from metadata source for local playback.';
			case 'settings.clear_lyric_cache': return 'Clear lyric cache';
			case 'settings.clear_lyric_cache_desc': return 'Delete all lyric cache.';
			case 'settings.clear_database': return 'Clear database';
			case 'settings.clear_database_desc': return 'Delete main database. You need to restart the app.';
			case 'settings.show_artist_in_bottom_player': return 'Show artist in mini player';
			case 'settings.show_artist_in_bottom_player_desc': return 'Only works on mobile devices.';
			case 'settings.custom_font_path': return 'Custom Font Path';
			case 'settings.custom_font_not_specified': return 'Not specified';
			case 'search': return 'Search';
			case 'track.add_to_playlist': return 'Add to playlist';
			case 'track.remove_from_playlist': return 'Remove from playlist';
			case 'track.add_to_queue': return 'Add to queue';
			case 'track.share': return 'Share track';
			case 'tracks': return 'Tracks';
			case 'recent_played': return 'Recently played';
			case 'no_lyric_found': return 'No lyric found';
			case 'download': return 'Download';
			case 'download_manager': return 'Download manager';
			case 'intro.welcome.heading': return 'Welcome!';
			case 'intro.welcome.description': return 'This is Annix, a full-featured music player designed for You.';
			case 'intro.enjoy_music.heading': return 'Enjoy Music';
			case 'intro.enjoy_music.description': return 'Annix supports two primary audio formats: FLAC for lossless audio and OPUS for lossy audio. Additionally, it offers gapless playback, ensuring smooth transitions between tracks.';
			case 'intro.host_remotely.heading': return 'Host remotely';
			case 'intro.host_remotely.description': return 'Host your own Annil instance to manage your personal music collection and enjoy it from anywhere by streaming the tracks on demand.';
			case 'intro.fully_featured.heading': return 'Fully featured';
			case 'intro.fully_featured.description': return 'Lyric, playlist, statistics, ..., and everything you think a music player should have!';
			case 'intro.login.heading': return 'And...';
			case 'intro.login.description': return 'Log in to the Anniv server and take advantage of all these amazing features!';
			case 'intro.login.self_host': return 'Use self-hosted Anniv instance';
			case 'intro.login.email': return 'Email';
			case 'intro.login.password': return 'Password';
			case 'intro.login.server': return 'Anniv Server';
			case 'intro.about_anniv.heading': return 'About Anniv';
			case 'intro.about_anniv.ribbon_features': return 'Project Anni provides an official instance of Anniv called Ribbon. This server is free to use and provides features like playlist, lyric, and statistics.';
			case 'intro.about_anniv.how_to_self_host': return 'If you want to host your own instance of Anniv, check out the project at https://anni.rs and follow the instructions to set up your own server.';
			case 'intro.about_anniv.confirm': return 'Got it';
			case 'intro.action.skip': return 'Skip';
			case 'intro.action.next': return 'Next';
			case 'intro.action.login': return 'Login';
			default: return null;
		}
	}
}

extension on _StringsZhCn {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'progress': return '进度';
			case 'home': return '首页';
			case 'category': return '分类';
			case 'albums': return '专辑';
			case 'playlists': return '播放列表';
			case 'shuffle_mode': return '随机模式';
			case 'my_favorite': return '我的收藏';
			case 'music': return '音乐';
			case 'playing.is_playing': return '正在播放';
			case 'playing.view_album': return '查看专辑';
			case 'playback.play_all': return '播放全部';
			case 'playback.shuffle': return '随机播放';
			case 'playlist.edit': return '编辑';
			case 'playlist.title': return '标题';
			case 'playlist.description': return '描述';
			case 'playlist.create_new': return '创建新播放列表';
			case 'playlist.created': return '播放列表已创建';
			case 'server.server': return '服务器';
			case 'server.login': return '登录';
			case 'server.logout': return '退出登录';
			case 'server.not_logged_in': return '未登录';
			case 'server.libraries': return '音频仓库';
			case 'server.login_to_anniv': return '登录 Anniv';
			case 'server.anniv_features': return '登录 Anniv 以启用播放列表、播放统计等诸多功能。';
			case 'settings.settings': return '设置';
			case 'settings.skip_cert': return '忽略证书验证';
			case 'settings.default_audio_quality': return '默认音质';
			case 'settings.blur_playing_page': return '播放界面使用模糊背景';
			case 'settings.use_mobile_network': return '使用移动网络播放';
			case 'settings.view_logs': return '应用日志';
			case 'settings.view_logs_desc': return '查看应用日志。';
			case 'settings.clear_metadata_cache': return '清除元数据缓存';
			case 'settings.clear_metadata_cache_desc': return '当你使用的元数据来源为远程时，可能需要从远程重新获取本地音频缓存对应的元数据。';
			case 'settings.clear_lyric_cache': return '清除歌词缓存';
			case 'settings.clear_lyric_cache_desc': return '删除本地缓存的所有歌词。';
			case 'settings.clear_database': return '清除主数据库';
			case 'settings.clear_database_desc': return '删除主数据库。你需要重新启动应用以重新创建数据库。';
			case 'settings.show_artist_in_bottom_player': return '在播放条中显示艺术家';
			case 'settings.show_artist_in_bottom_player_desc': return '移动端设置，桌面端无效。';
			case 'settings.custom_font_path': return '自定义字体路径';
			case 'settings.custom_font_not_specified': return '默认字体';
			case 'search': return '搜索';
			case 'track.add_to_playlist': return '保存到播放列表';
			case 'track.remove_from_playlist': return '从播放列表删除';
			case 'track.add_to_queue': return '添加到待播列表';
			case 'track.share': return '分享歌曲';
			case 'tracks': return '单曲';
			case 'recent_played': return '最近播放';
			case 'no_lyric_found': return '未找到歌词';
			case 'download': return '下载';
			case 'download_manager': return '下载管理';
			case 'intro.welcome.heading': return '欢迎使用';
			case 'intro.welcome.description': return 'Annix，一款为音频整理者设计的全功能音乐播放器。';
			case 'intro.enjoy_music.heading': return '聆听';
			case 'intro.enjoy_music.description': return 'Annix 支持两种主流音频格式：FLAC 用于无损音频；OPUS 用于有损音频。此外，它还支持无缝播放，确保曲目之间的平滑过渡。';
			case 'intro.host_remotely.heading': return '自建云曲库';
			case 'intro.host_remotely.description': return '通过自建 Annil 实例管理个人音乐收藏，在任何设备上享受你的曲库！';
			case 'intro.fully_featured.heading': return '功能齐全';
			case 'intro.fully_featured.description': return '包括歌词、播放列表、统计分析等在内的全面功能，应有尽有，满足您对音乐播放器的所有需求！';
			case 'intro.login.heading': return '最后……';
			case 'intro.login.description': return '登录 Anniv 服务器，畅享精彩功能！';
			case 'intro.login.self_host': return '使用自托管实例';
			case 'intro.login.email': return '邮箱';
			case 'intro.login.password': return '密码';
			case 'intro.login.server': return 'Anniv 服务器地址';
			case 'intro.about_anniv.heading': return '关于 Anniv';
			case 'intro.about_anniv.ribbon_features': return 'Project Anni 提供了官方 Anniv 实例 Ribbon，用户可免费使用。支持播放列表、歌词、统计等功能。';
			case 'intro.about_anniv.how_to_self_host': return '如果您想自行部署 Anniv 实例，请访问 https://anni.rs 并按照说明进行设置。';
			case 'intro.about_anniv.confirm': return '我知道了';
			case 'intro.action.skip': return '跳过';
			case 'intro.action.next': return '下一步';
			case 'intro.action.login': return '登录';
			default: return null;
		}
	}
}
