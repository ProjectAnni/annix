import 'package:annix/providers.dart';
import 'package:annix/services/annil/audio_source.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/services/playback/playback.dart';
import 'package:annix/ui/widgets/artist_text.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:flutter/material.dart';
import 'package:annix/i18n/strings.g.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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

class PlaybackHistoryPage extends ConsumerWidget {
  const PlaybackHistoryPage({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final annil = ref.read(annilProvider);
    final anniv = ref.read(annivProvider);
    final metadata = ref.read(metadataProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.recent_played),
      ),
      body: FutureBuilder<List<_SongPlayRecordResultWithMetadata>>(
        future: anniv.client?.getUserPlaybackStats().then((final data) {
          final tracks = data.map((final t) => t.track).toList();
          return metadata.getTracks(tracks).then((final meta) {
            return data.map((final record) {
              return _SongPlayRecordResultWithMetadata(
                record: record,
                metadata:
                    meta[record.track]!, // FIXME: metadata might not exist
              );
            }).toList();
          });
        }),
        builder: (final context, final snapshot) {
          if (snapshot.error != null) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }
          if (snapshot.hasData && snapshot.data != null) {
            final data = snapshot.data!;
            return ListView(
              children: [
                for (final record in data)
                  ListTile(
                    leading: CoverCard(
                      child: MusicCover.fromAlbum(
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
                      final player = ref.read(playbackProvider);
                      final sources = data
                          .map((final track) =>
                              AnnilAudioSource(track: track.metadata))
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
