import 'package:annix/providers.dart';
import 'package:annix/services/playback/playback.dart';
import 'package:annix/ui/route/delegate.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PlaylistView extends ConsumerWidget {
  const PlaylistView({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final playlistsRaw = ref.watch(playlistProvider);
    final playlists = playlistsRaw.value ?? [];
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (final context, final index) {
          final playlist = playlists[index];

          final albumId =
              playlist.cover == null ? null : playlist.cover!.split('/')[0];

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: AspectRatio(
              aspectRatio: 1,
              child: albumId == null
                  ? const DummyMusicCover()
                  : MusicCover.fromAlbum(albumId: albumId),
            ),
            title: Text(
              playlist.name,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () async {
              final delegate = AnnixRouterDelegate.of(context);
              final list = await Playlist.load(
                id: playlist.id,
                db: ref.read(localDatabaseProvider),
                anniv: ref.read(annivProvider),
              );
              delegate.to(name: '/playlist', arguments: list);
            },
          );
        },
        childCount: playlists.length,
      ),
    );
  }
}
