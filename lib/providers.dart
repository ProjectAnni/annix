import 'package:annix/i18n/strings.g.dart';
import 'package:annix/services/annil/annil.dart';
import 'package:annix/services/anniv/anniv.dart';
import 'package:annix/services/audio_handler.dart';
import 'package:annix/services/download/download_manager.dart';
import 'package:annix/services/local/database.dart';
import 'package:annix/services/local/preferences.dart';
import 'package:annix/services/metadata/metadata.dart';
import 'package:annix/services/network/network.dart';
import 'package:annix/services/network/proxy.dart';
import 'package:annix/services/playback/playback.dart';
import 'package:annix/services/settings.dart';
import 'package:annix/services/theme.dart';
import 'package:annix/ui/route/delegate.dart';
import 'package:drift/drift.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

final localeProvider =
    StreamProvider((final ref) => LocaleSettings.getLocaleStream());
final themeProvider = ChangeNotifierProvider((final ref) => AnnixTheme(ref));
final networkProvider =
    ChangeNotifierProvider((final ref) => NetworkService(ref));
final isOnlineProvider =
    StateProvider((final ref) => ref.watch(networkProvider).isOnline);
final routerProvider = Provider((final ref) => AnnixRouterDelegate(ref));
final proxyProvider = Provider((final ref) => AnnixProxy(ref));
final settingsProvider = Provider((final ref) => SettingsService(ref));
final downloadManagerProvider =
    ChangeNotifierProvider((final ref) => DownloadManager());
final preferencesProvider = Provider((final ref) => PreferencesStore(ref));
final audioServiceProvider =
    FutureProvider((final ref) => AnnixAudioHandler.init(ref));

// db
@Riverpod(keepAlive: true)
LocalDatabase localDatabase(final LocalDatabaseRef ref) => LocalDatabase();
final playlistProvider = StreamProvider(
    (final ref) => ref.read(localDatabaseProvider).playlist.select().watch());
final favoriteTracksProvider = StreamProvider((final ref) =>
    ref.read(localDatabaseProvider).localFavoriteTracks.select().watch());
final favoriteAlbumsProvider = StreamProvider((final ref) =>
    ref.read(localDatabaseProvider).localFavoriteAlbums.select().watch());

// anni
final metadataProvider = Provider((final _) => MetadataService());
final annilProvider = Provider((final ref) => AnnilService(ref));
final annivProvider = Provider((final ref) => AnnivService(ref));
final playbackProvider =
    ChangeNotifierProvider((final ref) => PlaybackService(ref));
final playingProvider = ChangeNotifierProvider(
    (final ref) => ref.watch(playbackProvider.select((final p) => p.playing)));
final playingDownloadProgressProvider = StateProvider((final ref) =>
    ref.watch(playingProvider.select((final p) => p?.source.downloadProgress)));
