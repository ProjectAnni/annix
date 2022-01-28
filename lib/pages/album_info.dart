import 'package:annix/models/anniv.dart';
import 'package:annix/models/song.dart';
import 'package:annix/services/annil.dart';
import 'package:annix/services/global.dart';
import 'package:annix/services/route.dart';
import 'package:annix/widgets/platform_widgets/platform_list.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

class AnnixAlbumInfo extends StatelessWidget {
  final AlbumInfo albumInfo;

  const AnnixAlbumInfo({Key? key, required this.albumInfo}) : super(key: key);

  List<Widget> getAlbumTracks() {
    final List<Widget> list = [];

    bool needDiscId = false;
    if (albumInfo.discs.length > 1) {
      needDiscId = true;
    }

    var discId = 1;
    albumInfo.discs.forEach((disc) {
      if (needDiscId) {
        list.add(PlatformListTile(title: Text('Disc $discId')));
      }

      var trackId = 1;
      list.addAll(disc.tracks.map((track) => PlatformListTile(
            title: Text('${trackId++}. ${track.title}'),
            subtitle: Text(track.artist),
          )));
      discId++;
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AnnixDesktopRouter>(builder: (context, router, child) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Global.annil.cover(albumId: albumInfo.albumId),
                ),
                Expanded(flex: 1, child: Container()),
                Expanded(
                  flex: 7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PlatformText(
                        albumInfo.title,
                        style: TextStyle(fontSize: 24),
                      ),
                      Text(albumInfo.artist),
                      PlatformTextButton(
                        padding: EdgeInsets.zero,
                        child: Text("Play"),
                        onPressed: () async {
                          // TODO: reuse
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
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: PlatformListView(
              children: getAlbumTracks(),
            ),
          ),
        ],
      );
    });
  }
}
