import 'package:annix/services/annil/annil.dart';
import 'package:annix/services/annil/audio_source.dart';
import 'package:annix/services/anniv/anniv.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/services/metadata/metadata.dart';
import 'package:annix/services/playback/playback.dart';
import 'package:annix/ui/widgets/artist_text.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:annix/i18n/strings.g.dart';

class _SongPlayRecordResultWithMetadata {
  final SongPlayRecordResult record;
  final TrackInfoWithAlbum metadata;

  _SongPlayRecordResultWithMetadata({
    required this.record,
    required this.metadata,
  });

  TrackIdentifier get track => record.track;
  int get count => record.count;
}

class PlaybackHistoryPage extends StatelessWidget {
  const PlaybackHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final annil = context.read<AnnilService>();
    final anniv = context.read<AnnivService>();
    final metadata = context.read<MetadataService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(t.recent_played),
      ),
      body: FutureBuilder<List<_SongPlayRecordResultWithMetadata>>(
        future: anniv.client?.getUserPlaybackStats().then((data) {
          final tracks = data.map((t) => t.track).toList();
          return metadata.getTracks(tracks).then((meta) {
            return data.map((record) {
              return _SongPlayRecordResultWithMetadata(
                record: record,
                metadata:
                    meta[record.track]!, // FIXME: metadata might not exist
              );
            }).toList();
          });
        }),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            final data = snapshot.data!;
            return ListView(
              children: [
                for (final record in data)
                  ListTile(
                    leading: CoverCard(
                      child: MusicCover(
                        albumId: record.track.albumId,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      record.metadata.title,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: ArtistText(
                      record.metadata.artist,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text('${record.count}'),
                    enabled: annil.isTrackAvailable(
                      TrackIdentifier(
                        albumId: record.track.albumId,
                        discId: record.track.discId,
                        trackId: record.track.trackId,
                      ),
                    ),
                    onTap: () async {
                      final player = context.read<PlaybackService>();
                      final sources = data
                          .map((track) =>
                              AnnilAudioSource(track: record.metadata))
                          .toList();

                      playFullList(
                        player: player,
                        tracks: sources,
                        initialIndex: data.indexOf(record),
                      );
                    },
                  )
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            );
          }
        },
      ),
    );
  }
}
