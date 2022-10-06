import 'package:annix/services/annil/audio_source.dart';
import 'package:annix/services/anniv/anniv.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/services/local/database.dart';
import 'package:annix/services/annil/annil.dart';
import 'package:annix/services/playback/playback.dart';
import 'package:annix/ui/page/playlist/playlist_base.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/ui/widgets/artist_text.dart';
import 'package:annix/ui/widgets/utils/display_or_lazy_screen.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Playlist {
  final PlaylistData intro;
  final List<AnnivPlaylistItem> items;

  const Playlist({required this.intro, required this.items});
}

class LazyPlaylistDetailScreen extends StatelessWidget {
  final int id;

  const LazyPlaylistDetailScreen({required this.id, super.key});

  @override
  Widget build(BuildContext context) {
    return DisplayOrLazyLoadScreen(
      future: (() async {
        final db = context.read<LocalDatabase>();
        final anniv = context.read<AnnivService>();

        final intro = await (db.playlist.select()
              ..where((tbl) => tbl.id.equals(id)))
            .getSingle();

        final items = await anniv.getPlaylistItems(intro);
        if (items == null) {
          throw Exception('Failed to load playlist items');
        }
        return Playlist(intro: intro, items: items);
      })(),
      builder: (Playlist playlist) => PlaylistDetailScreen(playlist: playlist),
    );
  }
}

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
        final tracks = getTracks();
        playFullList(
          player: player,
          tracks: tracks,
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
              final tracks = getTracks();
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

  Widget _cover(BuildContext context) {
    String? coverIdentifier = playlist.intro.cover;
    if (coverIdentifier == null ||
        coverIdentifier == '' ||
        coverIdentifier.startsWith('/')) {
      coverIdentifier = _firstAvailableCover();

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

  List<AnnilAudioSource> getTracks() {
    return playlist.items
        .map<TrackInfoWithAlbum?>(
          (item) {
            if (item is AnnivPlaylistItemTrack) {
              return item.info;
            } else {
              return null;
            }
          },
        )
        .whereType<TrackInfoWithAlbum>()
        .map((track) => AnnilAudioSource(track: track))
        .toList();
  }

  String? _firstAvailableCover() {
    for (final item in playlist.items) {
      if (item is AnnivPlaylistItemTrack) {
        return item.info.id.albumId;
      } else if (item is AnnivPlaylistItemAlbum) {
        return item.albumId;
      } else {
        continue;
      }
    }

    return null;
  }
}
