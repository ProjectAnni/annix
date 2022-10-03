import 'package:annix/global.dart';
import 'package:annix/services/annil/audio_source.dart';
import 'package:annix/services/annil/client.dart';
import 'package:annix/services/anniv/anniv.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/services/local/database.dart';
import 'package:annix/services/metadata/metadata_model.dart';
import 'package:annix/services/playback/playback.dart';
import 'package:annix/ui/page/playlist/playlist_base.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/ui/widgets/artist_text.dart';
import 'package:flutter/material.dart';
import 'package:annix/i18n/strings.g.dart';
import 'package:provider/provider.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AnnivService anniv = context.read();
    final PlaybackService player = context.read();
    final AnnilService annil = context.read();

    final List<Favorite> favorites = context.watch();
    final reversedFavorite = favorites.reversed;

    final cover = favorites.isNotEmpty
        ? MusicCover(albumId: favorites.last.albumId)
        : const DummyMusicCover();

    return BasePlaylistScreen(
      title: t.my_favorite,
      cover: cover,
      intro: [Text('${favorites.length} songs')],
      onRefresh: () async {
        await anniv.syncFavorite();
      },
      onPlay: (shuffle) {
        final tracks = getTracks(favorites);
        playFullList(
          player: player,
          tracks: tracks,
          shuffle: shuffle,
        );
      },
      child: ListView.builder(
        itemCount: reversedFavorite.length,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          final favorite = reversedFavorite.elementAt(index);
          return ListTile(
            leading: Text('${index + 1}'),
            minLeadingWidth: 16,
            dense: true,
            visualDensity: VisualDensity.compact,
            title: Text(
              favorite.title ?? '--',
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: ArtistText(
              favorite.artist ?? '--',
              overflow: TextOverflow.ellipsis,
            ),
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
      ),
    );
  }

  List<AnnilAudioSource> getTracks(List<Favorite> favorites) {
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
