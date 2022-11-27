import 'package:annix/global.dart';
import 'package:annix/services/annil/annil.dart';
import 'package:annix/services/annil/audio_source.dart';
import 'package:annix/services/anniv/anniv.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/services/local/database.dart';
import 'package:annix/services/metadata/metadata_model.dart';
import 'package:annix/services/playback/playback.dart';
import 'package:annix/ui/page/playlist/playlist_base.dart';
import 'package:annix/ui/widgets/artist_text.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:flutter/material.dart';
import 'package:annix/i18n/strings.g.dart';
import 'package:provider/provider.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({Key? key}) : super(key: key);

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  bool showTracks = true;

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            pinned: true,
            floating: true,
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
                      label: Text(t.track),
                      value: true,
                    ),
                    ButtonSegment(
                      icon: const Icon(Icons.album),
                      label: Text(t.albums),
                      value: false,
                    ),
                  ],
                  selected: {showTracks},
                  showSelectedIcon: false,
                  onSelectionChanged: (value) {
                    setState(() {
                      showTracks = value.first;
                    });
                  },
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () async {
                  await context.read<AnnivService>().syncFavorite();
                },
              ),
            ],
          ),
        ];
      },
      body: AnimatedCrossFade(
        crossFadeState:
            showTracks ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        firstChild: _favoriteTracks(),
        secondChild: _favoriteAlbums(),
        duration: const Duration(milliseconds: 300),
        layoutBuilder: (topChild, topChildKey, bottomChild, bottomChildKey) {
          return Stack(
            children: [
              Positioned(
                key: bottomChildKey,
                child: bottomChild,
              ),
              Positioned(
                key: topChildKey,
                child: topChild,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _favoriteTracks() {
    final AnnilService annil = context.read();
    final PlaybackService player = context.read();
    final List<LocalFavorite> favorites = context.watch();
    final reversedFavorite = favorites.reversed;

    return ListView.builder(
      itemCount: reversedFavorite.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final favorite = reversedFavorite.elementAt(index);
        return ListTile(
          leading: MusicCover(albumId: favorite.albumId),
          title: Text(
            favorite.title ?? '--',
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: ArtistText(
            favorite.artist ?? '--',
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text('${index + 1}'),
          enabled: annil.isAvailable(
            TrackIdentifier(
              albumId: favorite.albumId,
              discId: favorite.discId,
              trackId: favorite.trackId,
            ),
          ),
          onTap: () async {
            final tracks = getTracks(favorites);
            playFullList(
              player: player,
              tracks: tracks,
              initialIndex: index,
            );
          },
        );
      },
    );
  }

  Widget _favoriteAlbums() {
    return const Center(child: Text('Favorite Albums'));
  }

  List<AnnilAudioSource> getTracks(List<LocalFavorite> favorites) {
    final annil = Global.context.read<AnnilService>();

    return favorites.reversed
        .map(
          (fav) {
            final id = TrackIdentifier(
              albumId: fav.albumId,
              discId: fav.discId,
              trackId: fav.trackId,
            );

            if (annil.isAvailable(id)) {
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
        .map((track) => AnnilAudioSource(track: track))
        .toList();
  }
}
