import 'package:annix/providers.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PlaylistView extends ConsumerWidget {
  const PlaylistView({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final playlistsRaw = ref.watch(playlistProvider);
    final playlists = playlistsRaw.value ?? [];

    return DecoratedSliver(
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      sliver: SliverList.separated(
        itemCount: playlists.length,
        separatorBuilder: (context, index) => Divider(
          height: 4,
          thickness: 2,
          color: context.colorScheme.surface,
        ),
        itemBuilder: (context, index) {
          final playlist = playlists[index];
          final coverAlbumId = playlist.cover?.split('/').first;
          return ListTile(
            title: Text(
              playlist.name,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            leading: coverAlbumId == null
                ? const DummyMusicCover()
                : Hero(
                    tag: 'playlist:cover:${playlist.id}',
                    child: MusicCover.fromAlbum(
                      albumId: coverAlbumId,
                      discId: 0,
                      // fit: BoxFit.cover,
                    ),
                  ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            onTap: () {
              final playlist = PlaylistInfo.fromData(playlists[index]);
              context.push('/playlist', extra: playlist);
            },
          );
        },
      ),
    );
  }
}
