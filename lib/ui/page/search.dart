import 'dart:async';
import 'package:annix/providers.dart';
import 'package:annix/services/annil/audio_source.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/services/anniv/anniv_client.dart';
import 'package:annix/services/settings.dart';
import 'package:annix/ui/widgets/album/album_wall.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/ui/widgets/artist_text.dart';
import 'package:annix/ui/widgets/fade_indexed_stack.dart';
import 'package:flutter/material.dart';
import 'package:annix/i18n/strings.g.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SearchPage extends HookConsumerWidget {
  final String? keyword;

  const SearchPage({super.key, this.keyword});

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

    useEffect(() {
      if (keyword != null) {
        search(anniv.client!, keyword!);
      }
      return null;
    }, [keyword]);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              TextField(
                // autofocus: true,
                decoration: InputDecoration(
                  icon: const Icon(Icons.search),
                  hintText: t.search,
                ),
                controller: TextEditingController(text: keyword),
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
      ),
    );
  }
}

class _SearchResultWidget extends HookConsumerWidget {
  final ValueNotifier<SearchResult?> result;
  final ValueNotifier<bool> isLoading;

  const _SearchResultWidget({
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
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: OverflowBar(
            alignment: MainAxisAlignment.start,
            spacing: 8.0,
            children: [
              if ((result.value?.tracks?.length ?? 0) > 0)
                FilterChip(
                  avatar: categoryState.value == 0
                      ? null
                      : const Icon(Icons.music_note),
                  label: Text(t.tracks),
                  onSelected: (selected) {
                    if (selected) {
                      categoryState.value = 0;
                    }
                  },
                  selected: categoryState.value == 0,
                ),
              if ((result.value?.albums?.length ?? 0) > 0)
                FilterChip(
                  avatar: categoryState.value == 1
                      ? null
                      : const Icon(Icons.album_outlined),
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
        ),
        Expanded(
          child: FadeIndexedStack(
            index: categoryState.value,
            children: [
              ListView.builder(
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
              AlbumWall(
                albums: result.value?.albums ?? [],
              ),
              ListView.builder(
                itemBuilder: (final context, final index) {
                  final playlistInfo = result.value!.playlists![index];
                  final coverAlbumId = playlistInfo.cover?.albumId;
                  return ListTile(
                    leading: coverAlbumId != null
                        ? MusicCover.fromAlbum(albumId: coverAlbumId)
                        : const DummyMusicCover(),
                    title: Text(
                      playlistInfo.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(playlistInfo.owner),
                    onTap: () async {
                      ref
                          .read(routerProvider)
                          .to(name: '/playlist', arguments: playlistInfo);
                    },
                  );
                },
                itemCount: result.value!.playlists?.length ?? 0,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
