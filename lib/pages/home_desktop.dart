import 'package:annix/models/song.dart';
import 'package:annix/services/global.dart';
import 'package:annix/services/platform.dart';
import 'package:annix/widgets/bottom_playbar.dart';
import 'package:annix/widgets/draggable_appbar.dart';
import 'package:annix/widgets/navigator.dart';
import 'package:annix/widgets/playable_grid.dart';
import 'package:annix/widgets/square_icon_button.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

class HomePageDesktop extends StatefulWidget {
  @override
  _HomePageDesktopState createState() => _HomePageDesktopState();
}

class _HomePageDesktopState extends State<HomePageDesktop> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DraggableAppBar(
        appBar: AppBar(
          title: Text("Annix"),
          actions: AnniPlatform.isDesktop
              ? [
                  SquareIconButton(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 8,
                        ),
                        Icon(
                          Icons.minimize,
                        )
                      ],
                    ),
                    onPressed: () {
                      appWindow.minimize();
                    },
                  ),
                  // TODO: Window <-> Full
                  SquareIconButton(
                    child: Icon(Icons.close),
                    onPressed: () {
                      appWindow.close();
                    },
                  )
                ]
              : [],
        ),
      ),
      body: Row(
        children: [
          // TODO: This is Desktop layout, we need another mobile layout
          AnnilNavigator(),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: GridView.custom(
                    padding: EdgeInsets.all(32.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: AnniPlatform.isDesktop ? 4 : 2,
                      mainAxisSpacing: 32,
                      crossAxisSpacing: 32,
                    ),
                    childrenDelegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == Global.catalogs.length) {
                          return null;
                        }

                        var catalog = Global.catalogs.keys.elementAt(index);
                        return PlayableGrid(
                          id: catalog,
                          cover: Global.annil.getCover(
                            catalog: catalog,
                          ),
                          playlistCallback: (catalog) async {
                            var album = await Global.metadataSource
                                .getAlbum(catalog: catalog);
                            if (album == null) {
                              return null;
                            } else {
                              print(catalog);
                              List<Song> songs = [];
                              album.discs.forEach((disc) {
                                var trackId = 1;
                                disc.tracks.forEach((element) {
                                  songs.add(Song(
                                    catalog: disc.catalog,
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
                  ),
                ),
                // bottom play bar
                // Use persistentFooterButtons if this issue has been resolved
                // https://github.com/flutter/flutter/issues/46061
                Align(
                  alignment: Alignment.bottomCenter,
                  child: AnniPlatform.isDesktop
                      ? BottomPlayBarDesktop()
                      : BottomPlayerMobile(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
