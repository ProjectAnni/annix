import 'dart:async';
import 'package:annix/providers.dart';
import 'package:annix/services/annil/audio_source.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/services/anniv/anniv_client.dart';
import 'package:annix/services/settings.dart';
import 'package:annix/ui/widgets/album/album_wall.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/ui/widgets/artist_text.dart';
import 'package:flutter/material.dart';
import 'package:annix/i18n/strings.g.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class _SearchResultWidget extends HookConsumerWidget {
  final ValueNotifier<SearchResult?> result;
  final ValueNotifier<bool> isLoading;

  const _SearchResultWidget({
    super.key,
    required this.result,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context, final WidgetRef ref) {
    final categoryState = useState(0);

    if (isLoading.value) {
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (result.value == null) {
      return const Center(child: Text('Search results would display here'));
    }

    return Column(
      children: [
        ButtonBar(
          alignment: MainAxisAlignment.start,
          children: [
            if ((result.value?.tracks?.length ?? 0) > 0)
              FilterChip(
                label: Text(t.track),
                onSelected: (selected) {
                  if (selected) {
                    categoryState.value = 0;
                  }
                },
                selected: categoryState.value == 0,
              ),
            if ((result.value?.albums?.length ?? 0) > 0)
              FilterChip(
                label: Text(t.albums),
                onSelected: (selected) {
                  if (selected) {
                    categoryState.value = 1;
                  }
                },
                selected: categoryState.value == 1,
              ),
            if ((result.value?.playlists?.length ?? 0) > 0)
              FilterChip(
                label: Text(t.playlists),
                onSelected: (selected) {
                  if (selected) {
                    categoryState.value = 2;
                  }
                },
                selected: categoryState.value == 2,
              ),
          ],
        ),
        if (categoryState.value == 0)
          Expanded(
            child: ListView.builder(
              itemBuilder: (final context, final index) {
                final e = result.value!.tracks![index];

                return ValueListenableBuilder<SearchTrackDisplayType>(
                  valueListenable:
                      ref.read(settingsProvider).searchTrackDisplayType,
                  builder: (final context, final type, final _) {
                    return ListTile(
                      isThreeLine: type.isThreeLine,
                      leading: CoverCard(
                          child: MusicCover.fromAlbum(albumId: e.id.albumId)),
                      title: Text(
                        e.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (type.showArtist) ArtistText(e.artist),
                          if (type.showAlbumTitle)
                            Text(
                              e.albumTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                      onTap: () async {
                        final player = ref.read(playbackProvider);
                        final metadata = ref.read(metadataProvider);
                        final audio = await AnnilAudioSource.from(
                          id: e.id,
                          metadata: metadata,
                        );
                        if (audio != null) {
                          await player.setPlayingQueue([audio]);
                        }
                      },
                    );
                  },
                );
              },
              itemCount: result.value!.tracks?.length ?? 0,
            ),
          ),
        if (categoryState.value == 1)
          Expanded(
            child: AlbumWall(
              albumIds:
                  result.value!.albums?.map((e) => e.albumId).toList() ?? [],
            ),
          ),
        if (categoryState.value == 2)
          Expanded(
            child: ListView.builder(
              itemBuilder: (final context, final index) {
                final item = result.value!.playlists![index];
                final coverAlbumId = item.cover?.albumId;
                return ListTile(
                  leading: coverAlbumId != null
                      ? MusicCover.fromAlbum(albumId: coverAlbumId)
                      : const DummyMusicCover(),
                  title: Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(item.owner),
                  onTap: () async {
                    // TODO: get playlist and save
                    // final delegate = AnnixRouterDelegate.of(context);
                    // delegate.to(name: '/playlist', arguments: item.id);
                  },
                );
              },
              itemCount: result.value!.playlists?.length ?? 0,
            ),
          ),
      ],
    );
  }
}

class SearchPage extends HookConsumerWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context, final WidgetRef ref) {
    final anniv = ref.read(annivProvider);

    final ValueNotifier<SearchResult?> resultState = useState(null);
    final ValueNotifier<bool> isLoadingState = useState(false);

    Future<void> search(final AnnivClient anniv, final String keyword) async {
      primaryFocus?.unfocus(disposition: UnfocusDisposition.scope);
      resultState.value = null;
      isLoadingState.value = true;

      try {
        final result = await anniv.search(
          keyword,
          searchTracks: true,
          searchAlbums: true,
          searchPlaylists: true,
        );
        resultState.value = result;
      } catch (e) {
        rethrow;
      } finally {
        isLoadingState.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              // autofocus: true,
              decoration: InputDecoration(hintText: t.search),
              onSubmitted: (final keyword) => search(anniv.client!, keyword),
            ),
            Expanded(
              child: _SearchResultWidget(
                isLoading: isLoadingState,
                result: resultState,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
