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

    return SliverToBoxAdapter(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 200),
        child: CarouselView.weighted(
          flexWeights: const [3, 2, 1],
          elevation: 2,
          children: playlists.map((p) {
            final playlist = PlaylistInfo.fromData(p);
            final albumId = playlist.cover?.albumId;
            final cover = albumId == null
                ? const DummyMusicCover()
                : MusicCover.fromAlbum(
                    albumId: albumId,
                    fit: BoxFit.cover,
                  );
            return Stack(
              fit: StackFit.passthrough,
              children: [
                Hero(
                  tag: 'playlist:cover:${playlist.id}',
                  child: cover,
                ),
                Container(
                  padding: const EdgeInsets.all(4.0),
                  alignment: Alignment.bottomLeft,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0),
                        Colors.black.withValues(alpha: 0.5),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Hero(
                      tag: 'playlist:name:${playlist.id}',
                      child: Text(
                        playlist.name,
                        style: context.textTheme.titleMedium
                            ?.copyWith(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        softWrap: false,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
          onTap: (index) {
            final playlist = PlaylistInfo.fromData(playlists[index]);
            context.push('/playlist', extra: playlist);
          },
        ),
      ),
    );
  }
}
