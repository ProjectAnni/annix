import 'package:annix/controllers/annil_controller.dart';
import 'package:annix/controllers/playing_controller.dart';
import 'package:annix/models/anniv.dart';
import 'package:annix/models/song.dart';
import 'package:annix/services/annil.dart';
import 'package:annix/widgets/third_party/marquee_widget/marquee_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AlbumDetailScreen extends StatelessWidget {
  final String tag;
  final AlbumInfo albumInfo;

  const AlbumDetailScreen(
      {Key? key, required this.albumInfo, required this.tag})
      : super(key: key);

  List<Widget> getAlbumTracks() {
    final List<Widget> list = [];

    bool needDiscId = false;
    if (albumInfo.discs.length > 1) {
      needDiscId = true;
    }

    var discId = 1;
    albumInfo.discs.forEach((disc) {
      if (needDiscId) {
        var discTitle = 'Disc $discId';
        if (disc.title != "") {
          discTitle += ' - ${disc.title}';
        }
        list.add(ListTile(title: Marquee(child: Text(discTitle))));
      }

      var trackId = 1;
      list.addAll(
        disc.tracks.map(
          (track) => ListTile(
            leading: Text("${trackId++}"),
            title: Text('${track.title}'),
            subtitle: Marquee(child: Text(track.artist)),
          ),
        ),
      );
      discId++;
    });
    return list;
  }

  void playAlbum(AnnilController annil) async {
    List<Song> songs = [];
    var discId = 1;
    albumInfo.discs.forEach((disc) {
      var trackId = 1;
      disc.tracks.forEach((element) {
        songs.add(Song(
          albumId: albumInfo.albumId,
          discId: discId,
          trackId: trackId++,
        ));
      });
      discId++;
    });

    final PlayingController playing = Get.find();

    await playing.setPlayingQueue(
      await Future.wait(
        songs.map<Future<AnnilAudioSource>>(
          (s) => annil.getAudio(
            albumId: s.albumId,
            discId: s.discId,
            trackId: s.trackId,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AnnilController annil = Get.find();
    var tracks = getAlbumTracks();

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverAppBar(
                pinned: true,
                snap: true,
                floating: true,
                expandedHeight: context.mediaQuerySize.width * 0.8,
                automaticallyImplyLeading: true,
                flexibleSpace: FlexibleSpaceBar(
                  expandedTitleScale: 1.2,
                  title: Marquee(
                    child: Text(
                      albumInfo.title,
                      style: TextStyle(
                        shadows: [
                          Shadow(
                            blurRadius: 12.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                  background: Hero(
                    tag: this.tag,
                    child: annil.cover(
                      albumId: albumInfo.albumId,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
              ),
            )
          ];
        },
        body: Builder(builder: (context) {
          return CustomScrollView(
            slivers: [
              SliverOverlapInjector(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => tracks[index],
                  childCount: tracks.length,
                ),
              ),
            ],
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.play_arrow),
        onPressed: () => playAlbum(annil),
      ),
    );
  }
}
