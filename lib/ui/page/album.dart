import 'package:annix/providers.dart';
import 'package:annix/services/metadata/metadata_model.dart';
import 'package:annix/services/playback/playback.dart';
import 'package:annix/ui/widgets/artist_text.dart';
import 'package:annix/ui/widgets/buttons/favorite_button.dart';
import 'package:annix/ui/widgets/buttons/play_shuffle_button_group.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/ui/widgets/shimmer/shimmer_playlist_page.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final albumFamily = FutureProvider.family<Album, String>((ref, albumId) {
  final metadata = ref.read(metadataProvider);
  return metadata.getAlbum(albumId: albumId).then(
    (final album) {
      if (album == null) throw 'Album not found';
      return album;
    },
  );
});

class LoadingAlbumPage extends ConsumerWidget {
  final String albumId;

  const LoadingAlbumPage({super.key, required this.albumId});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final playlist = ref.watch(albumFamily(albumId));

    return playlist.when(
      data: (album) => AlbumPage(album: album),
      error: (error, stacktrace) => const Text('Error'),
      loading: () => const ShimmerPlaylistPage(),
    );
  }
}

class AlbumPage extends ConsumerWidget {
  final Album album;
  const AlbumPage({super.key, required this.album});

  void _onPlay(
    final WidgetRef ref, {
    final int index = 0,
    final bool shuffle = false,
  }) {
    final player = ref.read(playbackProvider);
    playFullList(
      player: player,
      tracks: album.getTracks(),
      initialIndex: index,
      shuffle: shuffle,
    );
  }

  Widget _buildTrackList(final BuildContext context) {
    final List<Widget> list = [];

    bool needDiscId = false;
    if (album.discs.length > 1) {
      needDiscId = true;
    }

    int trackIndex = 0;
    int discId = 1;
    for (final disc in album.discs) {
      if (needDiscId) {
        list.add(DiscTitleListTile(title: disc.title, index: discId));
      }

      list.addAll(disc.tracks.map(
          (final track) => TrackListTile(track: track, index: trackIndex++)));
      discId++;
    }

    return SliverList(delegate: SliverChildListDelegate(list));
  }

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          FavoriteAlbumButton(albumId: album.albumId),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: CustomScrollView(
          slivers: [
            if (context.isMobileOrPortrait)
              SliverToBoxAdapter(
                child: LayoutBuilder(
                  builder: (final context, final constraints) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: constraints.maxWidth / 6),
                      child: MusicCover.fromAlbum(albumId: album.albumId),
                    );
                  },
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (context.isMobileOrPortrait)
                      CircleAvatar(
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: context.colorScheme.outline,
                            ),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(24)),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: MusicCover.fromAlbum(albumId: album.albumId),
                        ),
                      ),
                    if (context.isDesktopOrLandscape)
                      SizedBox(
                        height: 240,
                        child: MusicCover.fromAlbum(albumId: album.albumId),
                      ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            album.title,
                            style: context.textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          ArtistText(
                            album.artist,
                            style: context.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: PlayShuffleButtonGroup(
                stretch: context.isMobileOrPortrait,
                onPlay: () => _onPlay(ref),
                onShufflePlay: () => _onPlay(ref, shuffle: true),
              ),
            ),
            _buildTrackList(context),
          ],
        ),
      ),
    );
  }
}

class DiscTitleListTile extends StatelessWidget {
  final String title;
  final int index;

  const DiscTitleListTile(
      {super.key, required this.title, required this.index});

  @override
  Widget build(final BuildContext context) {
    return ListTile(
      textColor: context.colorScheme.primary,
      iconColor: context.colorScheme.primary,
      leading: const Icon(Icons.album_outlined),
      title: SelectableText(title, maxLines: 1),
      trailing: Text('$index'),
      minLeadingWidth: 12,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      visualDensity: VisualDensity.compact,
    );
  }
}

class TrackListTile extends ConsumerWidget {
  final int index;
  final Track track;

  const TrackListTile({super.key, required this.track, required this.index});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final annil = ref.read(annilProvider);

    return ListTile(
      leading: Text('${track.id.trackId}'),
      // dense: true,
      title: Text(
        track.title,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      subtitle: ArtistText(track.artist),
      enabled: annil.isTrackAvailable(track.id),
      minLeadingWidth: 12,
      onTap: () async {
        final player = ref.read(playbackProvider);
        final tracks = track.disc.album.getTracks();
        playFullList(
          player: player,
          tracks: tracks,
          initialIndex: index,
        );
      },
      // selected: TODO: indicate playing track,
    );
  }
}
