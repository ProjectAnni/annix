///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations implements BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver})
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
	late final TranslationsPlayingEn playing = TranslationsPlayingEn._(_root);
	late final TranslationsPlaybackEn playback = TranslationsPlaybackEn._(_root);
	late final TranslationsPlaylistEn playlist = TranslationsPlaylistEn._(_root);
	late final TranslationsServerEn server = TranslationsServerEn._(_root);
	late final TranslationsSettingsEn settings = TranslationsSettingsEn._(_root);
	String get search => 'Search';
	late final TranslationsTrackEn track = TranslationsTrackEn._(_root);
	String get tracks => 'Tracks';
	String get recent_played => 'Recently played';
	String get no_lyric_found => 'No lyric found';
	String get download => 'Download';
	String get download_manager => 'Download manager';
	late final TranslationsIntroEn intro = TranslationsIntroEn._(_root);
}

// Path: playing
class TranslationsPlayingEn {
	TranslationsPlayingEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get is_playing => 'Playing';
	String get view_album => 'View Album';
}

// Path: playback
class TranslationsPlaybackEn {
	TranslationsPlaybackEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get play_all => 'Play All';
	String get shuffle => 'Shuffle';
}

// Path: playlist
class TranslationsPlaylistEn {
	TranslationsPlaylistEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get edit => 'Edit';
	String get title => 'Title';
	String get description => 'Description';
	String get create_new => 'Create New Playlist';
	String get created => 'Playlist created';
}

// Path: server
class TranslationsServerEn {
	TranslationsServerEn._(this._root);

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
class TranslationsSettingsEn {
	TranslationsSettingsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get settings => 'Settings';
	String get skip_cert => 'Skip SSL Certificate Verification';
	String get default_audio_quality => 'Default Audio Quality';
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
class TranslationsTrackEn {
	TranslationsTrackEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get add_to_playlist => 'Add to playlist';
	String get remove_from_playlist => 'Remove from playlist';
	String get add_to_queue => 'Add to queue';
	String get share => 'Share track';
}

// Path: intro
class TranslationsIntroEn {
	TranslationsIntroEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsIntroWelcomeEn welcome = TranslationsIntroWelcomeEn._(_root);
	late final TranslationsIntroEnjoyMusicEn enjoy_music = TranslationsIntroEnjoyMusicEn._(_root);
	late final TranslationsIntroHostRemotelyEn host_remotely = TranslationsIntroHostRemotelyEn._(_root);
	late final TranslationsIntroFullyFeaturedEn fully_featured = TranslationsIntroFullyFeaturedEn._(_root);
	late final TranslationsIntroLoginEn login = TranslationsIntroLoginEn._(_root);
	late final TranslationsIntroAboutAnnivEn about_anniv = TranslationsIntroAboutAnnivEn._(_root);
	late final TranslationsIntroActionEn action = TranslationsIntroActionEn._(_root);
}

// Path: intro.welcome
class TranslationsIntroWelcomeEn {
	TranslationsIntroWelcomeEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get heading => 'Welcome!';
	String get description => 'This is Annix, a full-featured music player designed for You.';
}

// Path: intro.enjoy_music
class TranslationsIntroEnjoyMusicEn {
	TranslationsIntroEnjoyMusicEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get heading => 'Enjoy Music';
	String get description => 'Annix supports two primary audio formats: FLAC for lossless audio and OPUS for lossy audio. Additionally, it offers gapless playback, ensuring smooth transitions between tracks.';
}

// Path: intro.host_remotely
class TranslationsIntroHostRemotelyEn {
	TranslationsIntroHostRemotelyEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get heading => 'Host remotely';
	String get description => 'Host your own Annil instance to manage your personal music collection and enjoy it from anywhere by streaming the tracks on demand.';
}

// Path: intro.fully_featured
class TranslationsIntroFullyFeaturedEn {
	TranslationsIntroFullyFeaturedEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get heading => 'Fully featured';
	String get description => 'Lyric, playlist, statistics, ..., and everything you think a music player should have!';
}

// Path: intro.login
class TranslationsIntroLoginEn {
	TranslationsIntroLoginEn._(this._root);

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
class TranslationsIntroAboutAnnivEn {
	TranslationsIntroAboutAnnivEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get heading => 'About Anniv';
	String get ribbon_features => 'Project Anni provides an official instance of Anniv called Ribbon. This server is free to use and provides features like playlist, lyric, and statistics.';
	String get how_to_self_host => 'If you want to host your own instance of Anniv, check out the project at https://anni.rs and follow the instructions to set up your own server.';
	String get confirm => 'Got it';
}

// Path: intro.action
class TranslationsIntroActionEn {
	TranslationsIntroActionEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get skip => 'Skip';
	String get next => 'Next';
	String get login => 'Login';
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

