import 'package:annix/models/song.dart';
import 'package:annix/services/global.dart';
import 'package:annix/services/platform.dart';
import 'package:annix/widgets/playable_grid.dart';
import 'package:flutter/widgets.dart';

class AlbumList extends StatelessWidget {
  const AlbumList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          if (index == Global.catalogs.length) {
            return null;
          }

          var catalog = Global.catalogs.keys.elementAt(index);
          return PlayableGrid(
            id: catalog,
            cover: Global.annil.cover(
              catalog: catalog,
            ),
            playlistCallback: (catalog) async {
              var album =
                  await Global.metadataSource.getAlbum(catalog: catalog);
              if (album == null) {
                return null;
              } else {
                print(catalog);
                List<Song> songs = [];
                album.discs.forEach((disc) {
                  var trackId = 1;
                  disc.tracks.forEach((element) {
                    songs.add(Song(
                      catalog: album.catalog,
                      discCatalog: album.discs.length > 1 ? disc.catalog : null,
                      trackId: trackId++,
                    ));
                  });
                });
                return songs;
              }
            },
          );
        },
      ),
    );
  }
}
