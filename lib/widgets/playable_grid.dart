import 'package:annix/models/metadata.dart';
import 'package:annix/models/song.dart';
import 'package:annix/services/annil.dart';
import 'package:annix/services/global.dart';
import 'package:annix/services/platform.dart';
import 'package:annix/utils/platform_icons.dart';
import 'package:annix/widgets/square_icon_button.dart';
import 'package:flutter/widgets.dart';
import 'package:marquee/marquee.dart';

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
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MouseRegion(
          onEnter: (_) {
            setState(() {
              hover = true;
            });
          },
          onExit: (_) {
            setState(() {
              hover = false;
            });
          },
          child: Stack(
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: widget.cover,
              ),
              // Display on hover / on mobile
              AnniPlatform.isMobile || hover
                  ? Align(
                      alignment: Alignment.bottomRight,
                      child: SizedBox.square(
                        dimension: 48,
                        child: SquareIconButton(
                          child: Icon(context.icons.play_circle),
                          onPressed: () async {
                            // Play current playlist instead of the current one
                            var songs =
                                await widget.playlistCallback(widget.id);
                            if (songs != null) {
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
                          },
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: FutureBuilder<Album?>(
              future: Global.metadataSource!.getAlbum(albumId: widget.id),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Marquee(
                    text: ' ${snapshot.data?.title ?? 'Unknown Title'} ',
                    pauseAfterRound: Duration(seconds: 2),
                    scrollToEnd: true,
                    marqueeShortText: false,
                  );
                } else {
                  return Container();
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
