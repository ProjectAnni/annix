import 'dart:async';

import 'package:annix/controllers/anniv_controller.dart';
import 'package:annix/controllers/player_controller.dart';
import 'package:annix/i18n/i18n.dart';
import 'package:annix/models/anniv.dart';
import 'package:annix/pages/playlist/playlist_album.dart';
import 'package:annix/pages/playlist/playlist_list.dart';
import 'package:annix/services/annil.dart';
import 'package:annix/services/anniv.dart';
import 'package:annix/ui/route/route.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:annix/widgets/artist_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
            label: Icon(Icons.tune_outlined),
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
    final PlayerController playing = Get.find();

    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TabBar(
            labelColor: context.textTheme.titleMedium?.color,
            indicatorColor: context.colorScheme.primary,
            indicatorSize: TabBarIndicatorSize.tab,
            labelPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
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
                        await playing.setPlayingQueue([
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
                      AnnixBodyPageRouter.to(
                        () => AlbumDetailScreen(
                          album: result.albums![index],
                        ),
                      );
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
                        final playlist =
                            await PlaylistDetailScreen.remote(item.id);
                        if (playlist != null) {
                          AnnixBodyPageRouter.to(() => playlist);
                        }
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
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
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
    final AnnivController anniv = Get.find();

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
              padding: EdgeInsets.only(top: 8),
              child: isLoading
                  ? CircularProgressIndicator(strokeWidth: 2)
                  : Text("Search results would display here"),
            )
          : _SearchResult(result: _result!),
    );
  }
}
