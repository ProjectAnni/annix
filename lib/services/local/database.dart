import 'dart:io';

import 'package:annix/global.dart';
import 'package:annix/services/annil/client.dart';
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

  static StreamProvider<List<LocalFavorite>> favoritesProvider = StreamProvider(
    create: (context) {
      final database = context.read<LocalDatabase>();
      return database.localFavorites.select().watch();
    },
    initialData: const [],
  );

  static StreamProvider<List<LocalAnnilServer>> annilProvider = StreamProvider(
    create: (context) {
      final database = context.read<LocalDatabase>();
      final stream = database.sortedAnnilServers().watch();
      stream.listen((event) {
        try {
          final annil = Global.context.read<AnnilService>();
          annil.reloadClients();
        } catch (e) {}
      });
      return stream;
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
