import 'dart:async';

import 'package:annix/global.dart';
import 'package:annix/services/anniv/anniv.dart';
import 'package:annix/services/annil/audio_source.dart';
import 'package:annix/services/metadata/metadata.dart';
import 'package:annix/services/metadata/metadata_model.dart';
import 'package:annix/services/playback/playback.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/services/anniv/anniv_client.dart';
import 'package:annix/services/settings.dart';
import 'package:annix/ui/dialogs/tag.dart';
import 'package:annix/ui/route/delegate.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:annix/ui/widgets/artist_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:annix/i18n/strings.g.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  SearchResult? _result;
  bool isLoading = false;

  Future<void> search(AnnivClient anniv, String keyword) async {
    primaryFocus?.unfocus(disposition: UnfocusDisposition.scope);
    setState(() {
      _result = null;
      isLoading = true;
    });

    try {
      final result = await anniv.search(
        keyword,
        searchTracks: true,
        searchAlbums: true,
        searchPlaylists: true,
      );
      _result = result;
    } catch (e) {
      rethrow;
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Set<TagEntry> tags = {};

  @override
  Widget build(BuildContext context) {
    final anniv = context.read<AnnivService>();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: InputDecoration(hintText: t.search),
          onSubmitted: (keyword) => search(anniv.client!, keyword),
        ),
      ),
      body: Column(
        children: [
          ButtonBar(
            alignment: MainAxisAlignment.start,
            children: [
              ActionChip(
                avatar: const Icon(Icons.filter_list_outlined),
                label: const Text('Tag filters'),
                padding: EdgeInsets.zero,
                elevation: 12,
                onPressed: () async {
                  final tag = await showTagListDialog(context);
                  if (tag != null) {
                    setState(() {
                      tags.add(tag);
                    });
                  }
                },
              ),
              ...tags.map(
                (tag) {
                  if (tag.type == TagType.Category) {
                    return InputChip(
                      label: Text(tag.name),
                      selected: true,
                      onDeleted: () {
                        setState(() {
                          tags.remove(tag);
                        });
                      },
                    );
                  } else {
                    return InputChip(
                      label: Text(tag.name),
                      onDeleted: () {
                        setState(() {
                          tags.remove(tag);
                        });
                      },
                    );
                  }
                },
              ),
            ],
          ),
          Expanded(
            child: _result == null
                ? Center(
                    child: isLoading
                        ? const CircularProgressIndicator(strokeWidth: 2)
                        : const Text('Search results would display here'),
                  )
                : _SearchResult(result: _result!),
          ),
        ],
      ),
    );
  }
}

class _SearchResult extends StatelessWidget {
  final SearchResult result;

  const _SearchResult({required this.result});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TabBar(
            labelColor: context.textTheme.titleMedium?.color,
            indicatorColor: context.colorScheme.primary,
            indicatorSize: TabBarIndicatorSize.tab,
            labelPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            tabs: [
              Tab(child: Text('${t.track} (${result.tracks?.length ?? 0})')),
              Tab(child: Text('${t.albums} (${result.albums?.length ?? 0})')),
              Tab(
                child:
                    Text('${t.playlists} (${result.playlists?.length ?? 0})'),
              ),
            ],
          ),
          Expanded(
            flex: 1,
            child: TabBarView(
              children: [
                // Tracks
                ListView.builder(
                  itemBuilder: (context, index) {
                    final e = result.tracks![index];

                    return ValueListenableBuilder<SearchTrackDisplayType>(
                      valueListenable: Global.settings.searchTrackDisplayType,
                      builder: (context, type, _) {
                        return ListTile(
                          isThreeLine: type.isThreeLine,
                          leading: CoverCard(
                              child: MusicCover(albumId: e.id.albumId)),
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
                            final player = context.read<PlaybackService>();
                            final metadata = context.read<MetadataService>();
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
                  itemCount: result.tracks?.length ?? 0,
                ),
                // Albums
                ListView.builder(
                  itemBuilder: (context, index) {
                    final album = result.albums![index];
                    return ListTile(
                      leading:
                          CoverCard(child: MusicCover(albumId: album.albumId)),
                      title: Text(
                        album.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: ArtistText(album.artist),
                      onTap: () {
                        AnnixRouterDelegate.of(context)
                            .to(name: '/album', arguments: album);
                      },
                    );
                  },
                  itemCount: result.albums?.length ?? 0,
                ),
                // Playlists
                ListView.builder(
                  itemBuilder: (context, index) {
                    final item = result.playlists![index];
                    final coverAlbumId = item.cover?.albumId;
                    return ListTile(
                      leading: coverAlbumId != null
                          ? MusicCover(albumId: coverAlbumId)
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
                  itemCount: result.playlists?.length ?? 0,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
