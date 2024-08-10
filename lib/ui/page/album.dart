import 'package:annix/i18n/strings.g.dart';
import 'package:annix/providers.dart';
import 'package:annix/services/metadata/metadata_model.dart';
import 'package:annix/services/playback/playback.dart';
import 'package:annix/ui/dialogs/playlist_dialog.dart';
import 'package:annix/ui/widgets/artist_text.dart';
import 'package:annix/ui/widgets/buttons/favorite_button.dart';
import 'package:annix/ui/widgets/buttons/play_shuffle_button_group.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/ui/widgets/shimmer/shimmer_playlist_page.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:annix/utils/share.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final albumFamily =
    FutureProvider.autoDispose.family<Album, String>((ref, albumId) {
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
    final needDiscId = album.discs.length > 1;
    final totalTracks = album.discs.fold<int>(
        needDiscId ? album.discs.length : 0,
        (sum, disc) => sum + disc.tracks.length);
    final prefixSumList = createPrefixSum(album.discs
        .map((e) => e.tracks.length + (needDiscId ? 1 : 0))
        .toList());

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        childCount: totalTracks,
        (context, index) {
          final [discNumber, trackNumber] =
              findDiscAndTrack(prefixSumList, index);
          if (needDiscId && trackNumber == 0) {
            return DiscTitleListTile(
              title: album.discs[discNumber].title,
              index: discNumber + 1,
            );
          } else {
            return TrackListTile(
              track: album.discs[discNumber]
                  .tracks[needDiscId ? trackNumber - 1 : trackNumber],
              index: index,
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        actions: const [],
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
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
                          FavoriteAlbumButton(albumId: album.albumId),
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
    final annil = ref.watch(annilProvider);
    showMoreMenu() {
      showModalBottomSheet(
        useRootNavigator: true,
        context: context,
        isScrollControlled: true,
        clipBehavior: Clip.antiAlias,
        showDragHandle: true,
        builder: (final context) {
          return DraggableScrollableSheet(
            expand: false,
            builder: (final context, final scrollController) {
              return ListView(
                controller: scrollController,
                children: [
                  ListTile(
                    title: Text(t.track.add_to_playlist),
                    leading: const Icon(Icons.playlist_add),
                    onTap: () {
                      showPlaylistDialog(context, ref, track.id);
                    },
                  ),
                  ListTile(
                    title: Text(t.track.share),
                    leading: const Icon(Icons.share),
                    onTap: () {
                      final box = context.findRenderObject() as RenderBox?;
                      shareTrack(
                          track, box!.localToGlobal(Offset.zero) & box.size);
                    },
                  )
                ],
              );
            },
          );
        },
      );
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: Container(
        width: 24,
        alignment: Alignment.center,
        child: Text(
          '${track.id.trackId}',
          style: context.textTheme.labelLarge,
        ),
      ),
      title: Text(
        track.title,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      subtitle: ArtistText(track.artist),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: showMoreMenu,
      ),
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
      onLongPress: showMoreMenu,
      // selected: TODO: indicate playing track,
    );
  }
}

List<int> createPrefixSum(List<int> arr) {
  final prefixSum = List<int>.filled(arr.length, 0);
  prefixSum[0] = arr[0];
  for (int i = 1; i < arr.length; i++) {
    prefixSum[i] = prefixSum[i - 1] + arr[i];
  }
  return prefixSum;
}

List<int> findDiscAndTrack(List<int> prefixSum, int n) {
  final index = lowerBound(prefixSum, n + 1);
  final trackNumber = index == 0 ? n : n - prefixSum[index - 1];
  return [index, trackNumber];
}
