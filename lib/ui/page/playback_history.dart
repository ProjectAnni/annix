import 'package:annix/providers.dart';
import 'package:annix/services/annil/audio_source.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/services/playback/playback.dart';
import 'package:annix/ui/widgets/artist_text.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:flutter/material.dart';
import 'package:annix/i18n/strings.g.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

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

class _HistoryRecordWithMetadata {
  final HistoryRecord record;
  final TrackInfoWithAlbum? metadata;

  _HistoryRecordWithMetadata({
    required this.record,
    this.metadata,
  });

  TrackIdentifier get track => record.track;
}

class SliverPlaybackHistoryList extends StatefulHookConsumerWidget {
  const SliverPlaybackHistoryList({super.key});

  @override
  ConsumerState<SliverPlaybackHistoryList> createState() =>
      _SliverPlaybackHistoryListState();
}

class _SliverPlaybackHistoryListState
    extends ConsumerState<SliverPlaybackHistoryList> {
  static const _pageSize = 20;

  final PagingController<int, _HistoryRecordWithMetadata> _pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await ref
          .read(annivProvider)
          .client!
          .getUserPlaybackHistory(offset: pageKey, limit: _pageSize);
      final tracks = newItems.map((final t) => t.track).toList();
      final metadata = await ref.read(metadataProvider).getTracks(tracks);
      final data = newItems
          .map(
            (p) => _HistoryRecordWithMetadata(
              record: p,
              metadata: metadata[p.track],
            ),
          )
          .toList();

      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(data);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(data, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PagedSliverList<int, _HistoryRecordWithMetadata>(
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate(
        itemBuilder: (context, item, index) {
          return ListTile(
            leading: CoverCard(
              child: MusicCover.fromAlbum(
                albumId: item.track.albumId,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(item.metadata?.title ?? 'Unknown'),
            subtitle: ArtistText(
              DateTime.fromMillisecondsSinceEpoch(item.record.at * 1000)
                  .toLocal()
                  .toString(),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}
