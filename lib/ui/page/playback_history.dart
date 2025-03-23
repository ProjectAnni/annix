import 'package:annix/providers.dart';
import 'package:annix/services/annil/audio_source.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/services/playback/playback.dart';
import 'package:annix/ui/widgets/artist_text.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/ui/widgets/text/text.dart';
import 'package:flutter/material.dart';
import 'package:annix/i18n/strings.g.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class PlaybackHistoryPage extends ConsumerWidget {
  const PlaybackHistoryPage({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final annil = ref.read(annilProvider);
    final anniv = ref.read(annivProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.recent_played),
      ),
      body: FutureBuilder<List<SongPlayRecordResult>>(
        future: anniv.client?.getUserPlaybackStats(),
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
                    title: TrackTitleText(identifier: record.track),
                    subtitle: TrackArtistText(identifier: record.track),
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
                          .map((final record) =>
                              AnnilAudioSource(identifier: record.track))
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

class SliverPlaybackHistoryList extends StatefulHookConsumerWidget {
  const SliverPlaybackHistoryList({super.key});

  @override
  ConsumerState<SliverPlaybackHistoryList> createState() =>
      _SliverPlaybackHistoryListState();
}

class _SliverPlaybackHistoryListState
    extends ConsumerState<SliverPlaybackHistoryList> {
  static const _pageSize = 20;

  final PagingController<int, HistoryRecord> _pagingController =
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
      final data = newItems.toList();

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
    return PagedSliverList<int, HistoryRecord>(
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate(
        itemBuilder: (context, item, index) {
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CoverCard(
              child: MusicCover.fromAlbum(
                albumId: item.track.albumId,
                fit: BoxFit.cover,
              ),
            ),
            title: TrackTitleText(identifier: item.track),
            subtitle: ArtistText(
              DateTime.fromMillisecondsSinceEpoch(item.at * 1000)
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
