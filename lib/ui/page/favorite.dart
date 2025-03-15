import 'package:annix/providers.dart';
import 'package:annix/services/annil/audio_source.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/services/local/database.dart';
import 'package:annix/services/metadata/metadata_model.dart';
import 'package:annix/services/playback/playback.dart';
import 'package:annix/ui/widgets/album/album_wall.dart';
import 'package:annix/ui/widgets/artist_text.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/ui/widgets/fade_indexed_stack.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:annix/i18n/strings.g.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class FavoritePage extends HookConsumerWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context, final WidgetRef ref) {
    final selectedTab = useState(0);

    return Material(
      child: NestedScrollView(
        headerSliverBuilder: (final context, final innerBoxIsScrolled) {
          return [
            SliverAppBar(
              pinned: true,
              // always display appbar title on desktop
              floating: context.isDesktopOrLandscape ? false : true,
              // do not show elevation on desktop
              scrolledUnderElevation: context.isDesktopOrLandscape ? 0 : null,
              title: Text(t.my_favorite),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: SegmentedButton<bool>(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width / 8,
                      ),
                    ),
                    segments: [
                      ButtonSegment(
                        icon: const Icon(Icons.music_note),
                        label: Text(t.tracks),
                        value: true,
                      ),
                      ButtonSegment(
                        icon: const Icon(Icons.album),
                        label: Text(t.albums),
                        value: false,
                      ),
                    ],
                    selected: {selectedTab.value == 0},
                    showSelectedIcon: false,
                    onSelectionChanged: (final value) {
                      selectedTab.value = value.first ? 0 : 1;
                    },
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    final anniv = ref.read(annivProvider);
                    if (selectedTab.value == 0) {
                      anniv.syncFavoriteTrack();
                    } else {
                      anniv.syncFavoriteAlbum();
                    }
                  },
                ),
              ],
            ),
          ];
        },
        body: FadeIndexedStack(
          index: selectedTab.value,
          duration: context.isDesktop
              ? const Duration(milliseconds: 150)
              : const Duration(milliseconds: 300),
          children: const [FavoriteTracks(), FavoriteAlbumWall()],
        ),
      ),
    );
  }
}

class FavoriteTracks extends ConsumerWidget {
  const FavoriteTracks({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final annil = ref.read(annilProvider);
    final player = ref.read(playbackProvider);
    final favoriteTracks = ref.watch(favoriteTracksProvider);
    final favorites = favoriteTracks.value ?? [];
    final reversedFavorite = favorites.reversed;

    return DecoratedSliver(
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      sliver: SliverPadding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        sliver: SliverList.separated(
          itemCount: reversedFavorite.length,
          separatorBuilder: (context, index) => Divider(
            height: 4,
            thickness: 2,
            color: context.colorScheme.surface,
          ),
          itemBuilder: (final context, final index) {
            final favorite = reversedFavorite.elementAt(index);
            return ListTile(
              // contentPadding: EdgeInsets.zero,
              leading: CoverCard(
                child: MusicCover.fromAlbum(
                  albumId: favorite.albumId,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                favorite.title ?? '--',
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: ArtistText(
                favorite.artist ?? '--',
                overflow: TextOverflow.ellipsis,
              ),
              enabled: annil.isTrackAvailable(
                TrackIdentifier(
                  albumId: favorite.albumId,
                  discId: favorite.discId,
                  trackId: favorite.trackId,
                ),
              ),
              onTap: () async {
                final tracks = getTracks(ref, favorites);
                playFullList(
                  player: player,
                  tracks: tracks,
                  initialIndex: index,
                );
              },
            );
          },
        ),
      ),
    );
  }

  List<AnnilAudioSource> getTracks(
    WidgetRef ref,
    final List<LocalFavoriteTrack> favorites,
  ) {
    final annil = ref.read(annilProvider);

    return favorites.reversed
        .map(
          (final fav) {
            final id = TrackIdentifier(
              albumId: fav.albumId,
              discId: fav.discId,
              trackId: fav.trackId,
            );

            if (annil.isTrackAvailable(id)) {
              return TrackInfoWithAlbum(
                id: id,
                title: fav.title!,
                artist: fav.artist!,
                albumTitle: fav.albumTitle!,
                type: TrackType.fromString(fav.type),
              );
            } else {
              return null;
            }
          },
        )
        .whereType<TrackInfoWithAlbum>()
        .map((final track) => AnnilAudioSource(track: track))
        .toList();
  }
}

class FavoriteAlbumWall extends ConsumerWidget {
  const FavoriteAlbumWall({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final favoriteAlbums = ref.watch(favoriteAlbumsProvider);
    final favorites = favoriteAlbums.value ?? [];
    final reversedFavorite =
        favorites.reversed.map((final e) => e.albumId).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: LazyAlbumWall(albumIds: reversedFavorite),
    );
  }
}
