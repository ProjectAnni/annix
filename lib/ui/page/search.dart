import 'dart:async';

import 'package:annix/services/anniv/anniv.dart';
import 'package:annix/services/annil/audio_source.dart';
import 'package:annix/services/player.dart';
import 'package:annix/i18n/i18n.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/services/anniv/anniv_client.dart';
import 'package:annix/ui/route/delegate.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:annix/ui/widgets/artist_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ContextExtensionss;
import 'package:provider/provider.dart';

class CategoryChip extends StatelessWidget {
  final String name;
  final RxBool selected = false.obs;

  CategoryChip({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => FilterChip(
        label: Text(name),
        selected: selected.value,
        onSelected: (value) {
          selected.value = value;
        },
      ),
    );
  }
}

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: InputDecoration(hintText: I18n.SEARCH.tr),
          onSubmitted: (value) {},
        ),
        automaticallyImplyLeading: false,
      ),
      body: ButtonBar(
        alignment: MainAxisAlignment.start,
        children: [
          ActionChip(
            label: const Icon(Icons.tune_outlined),
            padding: EdgeInsets.zero,
            onPressed: () {
              //
            },
          ),
          CategoryChip(name: "OP"),
          CategoryChip(name: "ED"),
          CategoryChip(name: "OST"),
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
              Tab(
                  child: Text(
                      "${I18n.TRACKS.tr} (${result.tracks?.length ?? 0})")),
              Tab(
                  child: Text(
                      "${I18n.ALBUMS.tr} (${result.albums?.length ?? 0})")),
              Tab(
                child: Text(
                    "${I18n.PLAYLISTS.tr} (${result.playlists?.length ?? 0})"),
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
                    var e = result.tracks![index];
                    return ListTile(
                      title: Text(e.title),
                      subtitle: ArtistText(e.artist),
                      onTap: () async {
                        final player =
                            Provider.of<PlayerService>(context, listen: false);
                        await player.setPlayingQueue([
                          await AnnilAudioSource.from(
                            albumId: e.track.albumId,
                            discId: e.track.discId,
                            trackId: e.track.trackId,
                          )
                        ]);
                      },
                    );
                  },
                  itemCount: result.tracks?.length ?? 0,
                ),
                // Albums
                ListView.builder(
                  itemBuilder: (context, index) => ListTile(
                    title: Text(result.albums![index].title),
                    subtitle: ArtistText(result.albums![index].artist),
                    onTap: () {
                      AnnixRouterDelegate.of(context)
                          .to(name: '/album', arguments: result.albums![index]);
                    },
                  ),
                  itemCount: result.albums?.length ?? 0,
                ),
                // Playlists
                ListView.builder(
                  itemBuilder: (context, index) {
                    final item = result.playlists![index];
                    return ListTile(
                      title: Text(item.name),
                      subtitle: Text(item.owner),
                      onTap: () async {
                        // FIXME: jump to playlist in search
                        //   final playlist =
                        //       await PlaylistDetailScreen.remote(item.id);
                        // AnnixRouterDelegate.of(context)
                        //     .to(name: '/playlist/:id', arguments: playlist);
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

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
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

  @override
  Widget build(BuildContext context) {
    final anniv = Provider.of<AnnivService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: I18n.SEARCH.tr,
          ),
          onSubmitted: (keyword) => search(anniv.client!, keyword),
        ),
      ),
      body: _result == null
          ? Container(
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.only(top: 8),
              child: isLoading
                  ? const CircularProgressIndicator(strokeWidth: 2)
                  : const Text("Search results would display here"),
            )
          : _SearchResult(result: _result!),
    );
  }
}
