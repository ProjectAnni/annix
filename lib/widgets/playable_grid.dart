import 'package:annix/models/metadata.dart';
import 'package:annix/models/song.dart';
import 'package:annix/pages/album_info.dart';
import 'package:annix/services/global.dart';
import 'package:annix/services/route.dart';
import 'package:annix/widgets/third_party/marquee_widget/marquee_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

typedef PlaylistCallback = Future<List<Song>?> Function(String id);

class PlayableGrid extends StatefulWidget {
  final String id;
  final Widget cover;
  final PlaylistCallback playlistCallback;

  const PlayableGrid(
      {Key? key,
      required this.id,
      required this.cover,
      required this.playlistCallback})
      : super(key: key);

  @override
  _PlayableGridState createState() => _PlayableGridState();
}

class _PlayableGridState extends State<PlayableGrid> {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(builder: (context, constraints) {
        return Stack(
          fit: StackFit.expand,
          children: [
            widget.cover,
            Positioned(
              bottom: 0,
              child: FutureBuilder<Album?>(
                future: Global.metadataSource!.getAlbum(albumId: widget.id),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Container(
                      width: constraints.maxWidth,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Marquee(
                          child: GestureDetector(
                            onTap: () {
                              AnnixDesktopRouter.navigator
                                  .push(platformPageRoute(
                                context: context,
                                builder: (context) => AnnixAlbumInfo(
                                  albumInfo: snapshot.data!.toAlbumInfo(),
                                ),
                              ));
                            },
                            child: Text(
                              '${snapshot.data!.title}',
                              style: TextStyle(backgroundColor: Colors.black),
                            ),
                          ),
                          pauseDuration: Duration(seconds: 1),
                        ),
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
