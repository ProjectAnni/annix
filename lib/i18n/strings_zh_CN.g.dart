///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'strings.g.dart';

// Path: <root>
class TranslationsZhCn implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsZhCn({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver})
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

	late final TranslationsZhCn _root = this; // ignore: unused_field

	// Translations
	@override String get progress => '进度';
	@override String get home => '首页';
	@override String get category => '分类';
	@override String get albums => '专辑';
	@override String get playlists => '播放列表';
	@override String get shuffle_mode => '随机模式';
	@override String get my_favorite => '我的收藏';
	@override String get music => '音乐';
	@override late final _TranslationsPlayingZhCn playing = _TranslationsPlayingZhCn._(_root);
	@override late final _TranslationsPlaybackZhCn playback = _TranslationsPlaybackZhCn._(_root);
	@override late final _TranslationsPlaylistZhCn playlist = _TranslationsPlaylistZhCn._(_root);
	@override late final _TranslationsServerZhCn server = _TranslationsServerZhCn._(_root);
	@override late final _TranslationsSettingsZhCn settings = _TranslationsSettingsZhCn._(_root);
	@override String get search => '搜索';
	@override late final _TranslationsTrackZhCn track = _TranslationsTrackZhCn._(_root);
	@override String get tracks => '单曲';
	@override String get recent_played => '最近播放';
	@override String get no_lyric_found => '未找到歌词';
	@override String get download => '下载';
	@override String get download_manager => '下载管理';
	@override late final _TranslationsIntroZhCn intro = _TranslationsIntroZhCn._(_root);
}

// Path: playing
class _TranslationsPlayingZhCn implements TranslationsPlayingEn {
	_TranslationsPlayingZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get is_playing => '正在播放';
	@override String get view_album => '查看专辑';
}

// Path: playback
class _TranslationsPlaybackZhCn implements TranslationsPlaybackEn {
	_TranslationsPlaybackZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get play_all => '播放全部';
	@override String get shuffle => '随机播放';
}

// Path: playlist
class _TranslationsPlaylistZhCn implements TranslationsPlaylistEn {
	_TranslationsPlaylistZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get edit => '编辑';
	@override String get title => '标题';
	@override String get description => '描述';
	@override String get create_new => '创建新播放列表';
	@override String get created => '播放列表已创建';
}

// Path: server
class _TranslationsServerZhCn implements TranslationsServerEn {
	_TranslationsServerZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

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
class _TranslationsSettingsZhCn implements TranslationsSettingsEn {
	_TranslationsSettingsZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get settings => '设置';
	@override String get skip_cert => '忽略证书验证';
	@override String get default_audio_quality => '默认音质';
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
class _TranslationsTrackZhCn implements TranslationsTrackEn {
	_TranslationsTrackZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get add_to_playlist => '保存到播放列表';
	@override String get remove_from_playlist => '从播放列表删除';
	@override String get add_to_queue => '添加到待播列表';
	@override String get share => '分享歌曲';
}

// Path: intro
class _TranslationsIntroZhCn implements TranslationsIntroEn {
	_TranslationsIntroZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsIntroWelcomeZhCn welcome = _TranslationsIntroWelcomeZhCn._(_root);
	@override late final _TranslationsIntroEnjoyMusicZhCn enjoy_music = _TranslationsIntroEnjoyMusicZhCn._(_root);
	@override late final _TranslationsIntroHostRemotelyZhCn host_remotely = _TranslationsIntroHostRemotelyZhCn._(_root);
	@override late final _TranslationsIntroFullyFeaturedZhCn fully_featured = _TranslationsIntroFullyFeaturedZhCn._(_root);
	@override late final _TranslationsIntroLoginZhCn login = _TranslationsIntroLoginZhCn._(_root);
	@override late final _TranslationsIntroAboutAnnivZhCn about_anniv = _TranslationsIntroAboutAnnivZhCn._(_root);
	@override late final _TranslationsIntroActionZhCn action = _TranslationsIntroActionZhCn._(_root);
}

// Path: intro.welcome
class _TranslationsIntroWelcomeZhCn implements TranslationsIntroWelcomeEn {
	_TranslationsIntroWelcomeZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get heading => '欢迎使用';
	@override String get description => 'Annix，一款为音频整理者设计的全功能音乐播放器。';
}

// Path: intro.enjoy_music
class _TranslationsIntroEnjoyMusicZhCn implements TranslationsIntroEnjoyMusicEn {
	_TranslationsIntroEnjoyMusicZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get heading => '聆听';
	@override String get description => 'Annix 支持两种主流音频格式：FLAC 用于无损音频；OPUS 用于有损音频。此外，它还支持无缝播放，确保曲目之间的平滑过渡。';
}

// Path: intro.host_remotely
class _TranslationsIntroHostRemotelyZhCn implements TranslationsIntroHostRemotelyEn {
	_TranslationsIntroHostRemotelyZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get heading => '自建云曲库';
	@override String get description => '通过自建 Annil 实例管理个人音乐收藏，在任何设备上享受你的曲库！';
}

// Path: intro.fully_featured
class _TranslationsIntroFullyFeaturedZhCn implements TranslationsIntroFullyFeaturedEn {
	_TranslationsIntroFullyFeaturedZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get heading => '功能齐全';
	@override String get description => '包括歌词、播放列表、统计分析等在内的全面功能，应有尽有，满足您对音乐播放器的所有需求！';
}

// Path: intro.login
class _TranslationsIntroLoginZhCn implements TranslationsIntroLoginEn {
	_TranslationsIntroLoginZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get heading => '最后……';
	@override String get description => '登录 Anniv 服务器，畅享精彩功能！';
	@override String get self_host => '使用自托管实例';
	@override String get email => '邮箱';
	@override String get password => '密码';
	@override String get server => 'Anniv 服务器地址';
}

// Path: intro.about_anniv
class _TranslationsIntroAboutAnnivZhCn implements TranslationsIntroAboutAnnivEn {
	_TranslationsIntroAboutAnnivZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get heading => '关于 Anniv';
	@override String get ribbon_features => 'Project Anni 提供了官方 Anniv 实例 Ribbon，用户可免费使用。支持播放列表、歌词、统计等功能。';
	@override String get how_to_self_host => '如果您想自行部署 Anniv 实例，请访问 https://anni.rs 并按照说明进行设置。';
	@override String get confirm => '我知道了';
}

// Path: intro.action
class _TranslationsIntroActionZhCn implements TranslationsIntroActionEn {
	_TranslationsIntroActionZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get skip => '跳过';
	@override String get next => '下一步';
	@override String get login => '登录';
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.
extension on TranslationsZhCn {
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

