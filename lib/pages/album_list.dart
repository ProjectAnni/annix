import 'package:annix/models/song.dart';
import 'package:annix/services/annil.dart';
import 'package:annix/services/global.dart';
import 'package:annix/services/platform.dart';
import 'package:annix/widgets/playable_grid.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class AlbumList extends StatelessWidget {
  const AlbumList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CombinedAnnilClient>(builder: (context, annil, child) {
      return GridView.custom(
        padding: EdgeInsets.all(24.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: AnniPlatform.isDesktop ? 4 : 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 32,
          childAspectRatio: 1 / 1.13,
        ),
        childrenDelegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == annil.albums.length) {
              return null;
            }

            var albumId = annil.albums[index];
            return PlayableGrid(
              id: albumId,
              cover: annil.cover(albumId: albumId),
              playlistCallback: (theAlbumId) async {
                var album =
                    await Global.metadataSource!.getAlbum(albumId: theAlbumId);
                if (album == null) {
                  return null;
                } else {
                  List<Song> songs = [];
                  var discId = 1;
                  album.discs.forEach((disc) {
                    var trackId = 1;
                    disc.tracks.forEach((element) {
                      songs.add(Song(
                        albumId: album.albumId,
                        discId: discId,
                        trackId: trackId++,
                      ));
                    });
                    discId++;
                  });
                  return songs;
                }
              },
            );
          },
        ),
      );
    });
  }
}
