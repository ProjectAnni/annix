import 'package:annix/services/global.dart';
import 'package:annix/widgets/bottom_playbar.dart';
import 'package:annix/widgets/draggable_appbar.dart';
import 'package:annix/widgets/navigator.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DraggableAppBar(
        appBar: AppBar(
          title: Text("Annix"),
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
                      crossAxisCount: 4,
                      mainAxisSpacing: 32,
                      crossAxisSpacing: 32,
                    ),
                    childrenDelegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == Global.catalogs.length) {
                          return null;
                        }

                        var catalog = Global.catalogs[index];
                        return GridTile(
                          child: InkWell(
                            onDoubleTap: () async {
                              var album = await Global.metadataSource
                                  .getAlbum(catalog: catalog);
                              if (album != null) {
                                var i = 0;
                                Global.audioService.playlist.addAll(
                                  album.discs[0].tracks
                                      .map<AudioSource>(
                                        (e) => Global.annil.getAudio(
                                          catalog: catalog,
                                          trackId: ++i,
                                        ),
                                      )
                                      .toList(),
                                );
                              }
                            },
                            child: Image.network(
                              Global.annil.getCoverUrl(
                                catalog: catalog,
                              ),
                              filterQuality: FilterQuality.high,
                              height: 200,
                              width: 200,
                              isAntiAlias: true,
                            ),
                          ),
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
                  child: BottomPlayBar(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
