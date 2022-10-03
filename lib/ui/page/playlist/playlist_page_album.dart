import 'package:annix/services/annil/audio_source.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/services/metadata/metadata.dart';
import 'package:annix/services/playback/playback.dart';
import 'package:annix/ui/page/playlist/playlist_base.dart';
import 'package:annix/services/annil/client.dart';
import 'package:annix/services/metadata/metadata_model.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/ui/widgets/artist_text.dart';
import 'package:annix/ui/widgets/utils/display_or_lazy_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:annix/i18n/strings.g.dart';

class LazyAlbumDetailScreen extends StatelessWidget {
  final String albumId;

  const LazyAlbumDetailScreen({required this.albumId, super.key});

  @override
  Widget build(BuildContext context) {
    return DisplayOrLazyLoadScreen<Album>(
      future: context
          .read<MetadataService>()
          .getAlbum(albumId: albumId)
          .then((album) {
        if (album == null) throw "Album not found";
        return album;
      }),
      builder: (album) => AlbumDetailScreen(album: album),
    );
  }
}

class AlbumDetailScreen extends StatelessWidget {
  final Album album;

  const AlbumDetailScreen({required this.album, super.key});

  @override
  Widget build(BuildContext context) {
    return BasePlaylistScreen(
      pageTitle: Text(t.albums),
      title: album.fullTitle,
      cover: MusicCover(albumId: album.albumId),
      intro: [
        Text(album.date.toString()),
        // TODO: Add some action buttons
        // Row(
        //   children: [
        //     InkWell(
        //       child: Container(
        //         child: const Icon(
        //           Icons.add_box_outlined,
        //           size: 32.0,
        //         ),
        //       ),
        //       onTap: () {},
        //     ),
        //   ],
        // ),
      ],
      onTracks: () => onTracks(context),
      child: _getAlbumTracks(context),
    );
  }

  Future<List<TrackInfoWithAlbum>> onTracks(BuildContext context) async {
    final AnnilService annil = context.read();

    List<TrackInfoWithAlbum> songs = [];

    for (final disc in album.discs) {
      for (final track in disc.tracks) {
        // check if available
        final trackId = track.id;
        if (annil.isAvailable(trackId)) {
          songs.add(TrackInfoWithAlbum.fromTrack(track));
        }
      }
    }

    return songs;
  }

  ListView _getAlbumTracks(BuildContext context) {
    final AnnilService annil = context.read();
    final List<Widget> list = [];

    bool needDiscId = false;
    if (album.discs.length > 1) {
      needDiscId = true;
    }

    var totalTrackId = 0;

    var discId = 1;
    for (final disc in album.discs) {
      if (needDiscId) {
        var discTitle = 'Disc $discId';
        if (disc.title != "") {
          discTitle += ' - ${disc.title}';
        }
        list.add(ListTile(title: Text(discTitle)));
      }

      var trackId = 1;
      list.addAll(
        disc.tracks.map(
          (track) {
            final trackIndex = trackId;
            trackId++;

            final totalTrackIndex = totalTrackId;
            totalTrackId++;
            return ListTile(
              leading: Text("$trackIndex"),
              minLeadingWidth: 16,
              dense: true,
              visualDensity: VisualDensity.compact,
              title: Text(track.title, overflow: TextOverflow.ellipsis),
              subtitle: ArtistText(track.artist),
              enabled: annil.isAvailable(
                TrackIdentifier(
                  albumId: album.albumId,
                  discId: discId,
                  trackId: trackIndex,
                ),
              ),
              onTap: () async {
                final player = context.read<PlaybackService>();
                final tracks = await onTracks(context);
                playFullList(
                  player: player,
                  tracks: tracks
                      .map((track) => AnnilAudioSource(track: track))
                      .toList(),
                  initialIndex: totalTrackIndex,
                );
              },
              // selected: TODO: indicate playing track,
            );
          },
        ),
      );
      discId++;
    }

    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        return list[index];
      },
    );
  }
}
