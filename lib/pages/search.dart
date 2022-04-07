import 'package:annix/controllers/anniv_controller.dart';
import 'package:annix/models/anniv.dart';
import 'package:annix/pages/album_detail.dart';
import 'package:annix/services/global.dart';
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
    print(_controller.text);
    primaryFocus?.unfocus(disposition: UnfocusDisposition.scope);
    setState(() {
      isLoading = true;
      _result = null;
    });

    final result = await anniv.search(_controller.text,
        searchAlbums: true, searchTracks: true);
    setState(() {
      isLoading = false;
      _result = result;
    });
  }

  Widget buildSearchResult() {
    print(_result);
    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            child: TabBar(
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
          ),
          Expanded(
            flex: 1,
            child: TabBarView(
              children: [
                ListView.builder(
                  itemBuilder: (context, index) {
                    var e = _result!.tracks![index];
                    return ListTile(
                      title: Text(e.info.title),
                      subtitle: Text(e.info.artist),
                      onTap: () async {
                        await Global.audioService.setPlaylist([
                          await Global.annil.getAudio(
                            albumId: e.track.albumId,
                            discId: e.track.discId,
                            trackId: e.track.trackId,
                          )
                        ]);
                        await Global.audioService.play();
                      },
                    );
                  },
                  itemCount: _result?.tracks?.length ?? 0,
                ),
                ListView.builder(
                  itemBuilder: (context, index) => ListTile(
                    title: Text(_result!.albums![index].title),
                    subtitle: Text(_result!.albums![index].artist),
                    onTap: () {
                      Get.to(
                        () => AlbumDetailScreen(
                          albumInfo: _result!.albums![index],
                          // FIXME
                          tag: 'no-tag',
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
      // appBar: AppBar(
      //   title: Container(
      //     // color: Theme.of(context).scaffoldBackgroundColor,
      //     child:
      //   ),
      // ),
      body: CustomScrollView(slivers: [
        SliverAppBar(
          title: TextField(
            autofocus: true,
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
        // _result == null
        //   ? Container(
        //       alignment: Alignment.topCenter,
        //       padding: EdgeInsets.only(top: 8),
        //       child: isLoading
        //           ? CircularProgressIndicator()
        //           : Text("Search results would display here"),
        //     )
        //   : buildSearchResult()
      ]),
    );
  }
}
