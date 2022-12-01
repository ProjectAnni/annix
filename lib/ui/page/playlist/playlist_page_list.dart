import 'package:annix/services/anniv/anniv.dart';
import 'package:annix/services/anniv/anniv_model.dart' hide Playlist;
import 'package:annix/services/annil/annil.dart';
import 'package:annix/services/playback/playback.dart';
import 'package:annix/ui/page/playlist/playlist_base.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/ui/widgets/artist_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlaylistDetailScreen extends StatelessWidget {
  final Playlist playlist;

  const PlaylistDetailScreen({
    required this.playlist,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final annil = context.read<AnnilService>();
    final player = context.read<PlaybackService>();

    return BasePlaylistScreen(
      title: playlist.intro.name,
      intro: playlist.intro.description != null
          ? [
              Text(
                playlist.intro.description!,
                maxLines: 2,
              )
            ]
          : [],
      cover: _cover(context),
      onPlay: (shuffle) {
        playFullList(
          player: player,
          tracks: playlist.getTracks(),
          shuffle: shuffle,
        );
      },
      child: ListView.builder(
        itemCount: playlist.items.length,
        itemBuilder: (context, index) {
          final track = playlist.items[index];
          if (track is! AnnivPlaylistItemTrack) {
            return ListTile(
              title: const Text('TODO'),
              subtitle: Text(track.description ?? ''),
            );
          }

          final useThreeLine =
              track.description != null && track.description!.isNotEmpty;
          return ListTile(
            leading: MusicCover(albumId: track.info.id.albumId),
            isThreeLine: useThreeLine,
            title: Text(
              track.info.title,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            subtitle: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ArtistText(track.info.artist),
                if (useThreeLine)
                  Text(
                    track.description!,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  )
              ],
            ),
            trailing: Text('${index + 1}'),
            enabled: annil.isAvailable(track.info.id),
            onTap: () async {
              playFullList(
                player: player,
                tracks: playlist.getTracks(),
                initialIndex: index,
              );
            },
          );
        },
      ),
    );
  }

  Widget _cover(BuildContext context) {
    String? coverIdentifier = playlist.intro.cover;
    if (coverIdentifier == null ||
        coverIdentifier == '' ||
        coverIdentifier.startsWith('/')) {
      coverIdentifier = playlist.firstAvailableCover();

      final AnnivService anniv = context.read();
      if (coverIdentifier != null &&
          playlist.intro.remoteId != null &&
          anniv.client != null) {
        anniv.client?.updatePlaylistInfo(
          playlistId: playlist.intro.remoteId!,
          info: PatchedPlaylistInfo(
            // FIXME: do not use disc id
            cover: DiscIdentifier(albumId: coverIdentifier, discId: 1),
          ),
        );
      }
    }

    if (coverIdentifier == null) {
      return const DummyMusicCover();
    } else {
      final cover = DiscIdentifier.fromIdentifier(coverIdentifier);
      return MusicCover(albumId: cover.albumId, discId: cover.discId);
    }
  }
}
