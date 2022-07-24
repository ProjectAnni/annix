import 'package:annix/controllers/anniv_controller.dart';
import 'package:annix/controllers/player_controller.dart';
import 'package:annix/models/anniv.dart';
import 'package:annix/pages/playlist/playlist_album.dart';
import 'package:annix/services/annil.dart';
import 'package:annix/services/anniv.dart';
import 'package:annix/ui/route/route.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:annix/widgets/artist_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController _controller;
  SearchResult? _result;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController();
  }

  Future<void> search(AnnivClient anniv) async {
    // primaryFocus?.unfocus(disposition: UnfocusDisposition.scope);
    setState(() {
      _result = null;
      isLoading = true;
    });

    try {
      final result = await anniv.search(_controller.text,
          searchAlbums: true, searchTracks: true);
      _result = result;
    } catch (e) {
      rethrow;
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildSearchResult() {
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
              Tab(child: Text("Tracks (${_result?.tracks?.length ?? 0})")),
              Tab(child: Text("Albums (${_result?.albums?.length ?? 0})")),
              Tab(
                child: Text("Playlists (${_result?.playlists?.length ?? 0})"),
              ),
            ],
          ),
          Expanded(
            flex: 1,
            child: TabBarView(
              children: [
                ListView.builder(
                  itemBuilder: (context, index) {
                    var e = _result!.tracks![index];
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
                  itemCount: _result?.tracks?.length ?? 0,
                ),
                ListView.builder(
                  itemBuilder: (context, index) => ListTile(
                    title: Text(_result!.albums![index].title),
                    subtitle: ArtistText(_result!.albums![index].artist),
                    onTap: () {
                      AnnixBodyPageRouter.to(
                        () => AlbumDetailScreen(
                          album: _result!.albums![index].toAlbum(),
                        ),
                      );
                    },
                  ),
                  itemCount: _result?.albums?.length ?? 0,
                ),
                ListView(),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AnnivController anniv = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: TextField(
            // autofocus: true,
            controller: _controller,
            decoration: InputDecoration(
              hintText: "Search",
              contentPadding:
                  EdgeInsets.only(left: 8, right: 0, top: 8, bottom: 8),
              border: InputBorder.none,
              isDense: true,
            ),
            onSubmitted: (_) => search(anniv.client!),
          ),
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
          : buildSearchResult(),
    );
  }
}
