import 'package:annix/i18n/strings.g.dart';
import 'package:annix/router.dart';
import 'package:annix/services/annil/annil.dart';
import 'package:annix/services/anniv/anniv.dart';
import 'package:annix/services/audio_handler.dart';
import 'package:annix/services/local/database.dart';
import 'package:annix/services/local/preferences.dart';
import 'package:annix/services/metadata/metadata.dart';
import 'package:annix/services/network/network.dart';
import 'package:annix/services/network/proxy.dart';
import 'package:annix/services/playback/playback.dart';
import 'package:annix/services/settings.dart';
import 'package:annix/services/theme.dart';
import 'package:annix/ui/route/delegate.dart';
import 'package:annix/ui/widgets/playback/endless_mode.dart';
import 'package:annix/ui/widgets/playback/sleep_timer.dart';
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
final routerProvider = Provider((final ref) => AnnixRouterDelegate());
final goRouterProvider = Provider(buildRouter);
final proxyProvider = Provider((final ref) => AnnixProxy(ref));
final settingsProvider = Provider((final ref) => SettingsService(ref));
final preferencesProvider = Provider((final ref) => PreferencesStore(ref));
final audioServiceProvider =
    FutureProvider((final ref) => AnnixAudioHandler.init(ref));

final endlessModeProvider =
    ChangeNotifierProvider((ref) => EndlessModeController(ref));
final sleepTimerProvider =
    ChangeNotifierProvider((ref) => SleepTimerController(ref));

// db
@Riverpod(keepAlive: true)
LocalDatabase localDatabase(final Ref ref) => LocalDatabase();
final playlistProvider = StreamProvider((final ref) {
  final info = ref.watch(annivProvider.select((final p) => p.info));
  final db = ref.read(localDatabaseProvider);
  final playlist = db.playlist.select()
    ..where((tbl) => tbl.owner
        .equals(info?.user.userId ?? '__ANNIV_PLACEHOLDER_SHOULD_NOT_EXIST__'))
    ..orderBy([
      (u) => OrderingTerm(expression: u.lastModified, mode: OrderingMode.desc)
    ]);
  return playlist.watch();
});
final favoriteTracksProvider = StreamProvider((final ref) =>
    ref.read(localDatabaseProvider).localFavoriteTracks.select().watch());
final favoriteAlbumsProvider = StreamProvider((final ref) =>
    ref.read(localDatabaseProvider).localFavoriteAlbums.select().watch());

// anni
final metadataProvider = Provider((final _) => MetadataService());
final annilProvider = ChangeNotifierProvider((final ref) => AnnilService(ref));
final annivProvider = ChangeNotifierProvider((final ref) => AnnivService(ref));
final playbackProvider =
    ChangeNotifierProvider((final ref) => PlaybackService(ref));
final playingProvider =
    ChangeNotifierProvider((final ref) => ref.read(playbackProvider).playing);
