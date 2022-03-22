import 'package:annix/models/anniv.dart';
import 'package:annix/models/song.dart';
import 'package:annix/services/annil.dart';
import 'package:annix/services/global.dart';
import 'package:annix/widgets/draggable_appbar.dart';
import 'package:annix/widgets/third_party/marquee_widget/marquee_widget.dart';
import 'package:flutter/material.dart';

class AnnixAlbumInfo extends StatelessWidget {
  final AlbumInfo albumInfo;

  const AnnixAlbumInfo({Key? key, required this.albumInfo}) : super(key: key);

  List<Widget> getAlbumTracks(double width) {
    final List<Widget> list = [];

    bool needDiscId = false;
    if (albumInfo.discs.length > 1) {
      needDiscId = true;
    }

    var discId = 1;
    albumInfo.discs.forEach((disc) {
      if (needDiscId) {
        list.add(ListTile(title: Text('Disc $discId')));
      }

      var trackId = 1;
      list.addAll(disc.tracks.map((track) => ListTile(
            title: Text('${trackId++}. ${track.title}'),
            subtitle: Marquee(width: width * 0.97, child: Text(track.artist)),
            visualDensity: VisualDensity(horizontal: -4, vertical: -4),
          )));
      discId++;
    });
    return list;
  }

  void playAlbum() async {
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

    await Global.audioService.setPlaylist(
      await Future.wait(
        songs.map<Future<AnnilAudioSource>>(
          (s) => Global.annil.getAudio(
            albumId: s.albumId,
            discId: s.discId,
            trackId: s.trackId,
          ),
        ),
      ),
    );
    await Global.audioService.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferSizedMoveWindow(
        child: AppBar(
          title: Marquee(child: Text(albumInfo.title)),
        ),
      ),
      body: Container(
        child: LayoutBuilder(builder: (context, constriants) {
          return ListView(
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: getCover(),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  child: Text("Play"),
                  onPressed: playAlbum,
                ),
              ),
              ...getAlbumTracks(constriants.maxWidth),
              // suffix white space
              SizedBox(height: 64),
            ],
          );
        }),
      ),
    );
  }

  Widget getCover() {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Global.annil.cover(albumId: albumInfo.albumId),
        Align(
          alignment: Alignment.bottomRight,
          child: Text(albumInfo.artist),
        ),
      ],
    );
  }
}
