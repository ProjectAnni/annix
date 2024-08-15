import 'package:annix/providers.dart';
import 'package:annix/services/local/database.dart';
import 'package:annix/ui/page/annil/annil_card.dart';
import 'package:annix/ui/widgets/album/album_wall.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LocalAnnilInfo {
  final LocalAnnilCache cache;
  final List<String> albums;

  LocalAnnilInfo(this.cache, this.albums);
}

final annilCacheFamily = FutureProvider.autoDispose
    .family<LocalAnnilInfo, int>((ref, annilId) async {
  final db = ref.read(localDatabaseProvider);

  final cacheQuery = db.localAnnilCaches.select()
    ..where((tbl) => tbl.annilId.equals(annilId));
  final cache = await cacheQuery.getSingle();

  final albumsQuery = db.localAnnilAlbums.select()
    ..where((tbl) => tbl.annilId.equals(annilId));
  final albums = await albumsQuery.get();

  return LocalAnnilInfo(cache, albums.map((a) => a.albumId).toList());
});

class AnnilDetailPage extends ConsumerWidget {
  final LocalAnnilServer annil;

  const AnnilDetailPage({required this.annil, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final annilCache = ref.watch(annilCacheFamily(annil.id));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: annilCache.when(
        data: (cache) => CustomScrollView(
          slivers: [
            const SliverAppBar(pinned: true),
            SliverToBoxAdapter(
              child: AnnilCard(annil: annil, cache: cache),
            ),
            LazySliverAlbumWall(albumIds: cache.albums)
          ],
        ),
        error: (error, stacktrace) => const Text('Error'),
        loading: () => Scaffold(
          appBar: AppBar(),
          body: const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
