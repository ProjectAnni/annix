import 'dart:io';

import 'package:annix/global.dart';
import 'package:drift/drift.dart';

import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

part 'database.g.dart';

@DriftDatabase(include: {'tables.drift'})
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static Provider<LocalDatabase> provider = Provider(
    create: (_) => LocalDatabase(),
    dispose: (_, LocalDatabase database) => database.close(),
    lazy: false,
  );

  static StreamProvider<List<PlaylistData>> playlistProvider = StreamProvider(
    create: (context) {
      final database = context.read<LocalDatabase>();
      return database.playlist.select().watch();
    },
    initialData: const [],
  );

  static StreamProvider<List<LocalFavoriteTrack>> favoriteTracksProvider =
      StreamProvider(
    create: (context) {
      final database = context.read<LocalDatabase>();
      return database.localFavoriteTracks.select().watch();
    },
    initialData: const [],
  );

  static StreamProvider<List<LocalFavoriteAlbum>> favoriteAlbumsProvider =
      StreamProvider(
    create: (context) {
      final database = context.read<LocalDatabase>();
      return database.localFavoriteAlbums.select().watch();
    },
    initialData: const [],
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final file = File(p.join(Global.dataRoot, 'local.db'));
    return NativeDatabase(file);
  });
}
