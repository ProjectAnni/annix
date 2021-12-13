import 'package:annix/models/song.dart';
import 'package:annix/services/audio.dart';
import 'package:annix/services/global.dart';
import 'package:annix/services/platform.dart';
import 'package:annix/widgets/square_icon_button.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show Icons, GridTile, Colors;
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

typedef PlaylistCallback = Future<List<Song>?> Function(String catalog);

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
    // TODO: use somewhat more native-look than GridTile
    return GridTile(
      child: MouseRegion(
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
        child: Stack(children: [
          AspectRatio(
            aspectRatio: 1,
            child: widget.cover,
          ),
          AnniPlatform.isDesktop
              ? Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration:
                        BoxDecoration(color: Colors.black.withAlpha(100)),
                    child: Text(widget.id),
                  ),
                )
              : Container(),
          // Display on hover / on mobile
          AnniPlatform.isMobile || hover
              ? Align(
                  alignment: Alignment.bottomRight,
                  child: SizedBox.square(
                    dimension: 48,
                    child: SquareIconButton(
                      child: Icon(Icons.play_circle),
                      onPressed: () async {
                        // Play current playlist instead of the current one
                        var songs = await widget.playlistCallback(widget.id);
                        if (songs != null) {
                          await Global.audioService.pause();
                          Global.audioService.playlist =
                              ConcatenatingAudioSource(
                            useLazyPreparation: true,
                            children: await Future.wait(
                                songs.map<Future<AudioSource>>(
                              (s) => Global.annil.getAudio(
                                catalog: s.discCatalog ?? s.catalog,
                                trackId: s.trackId,
                              ),
                            )),
                          );
                          await Global.audioService.init(force: true);
                          Provider.of<AnnilPlaylist>(context, listen: false)
                              .resetPlaylist();
                          await Global.audioService.play();
                        }
                      },
                    ),
                  ),
                )
              : Container(),
        ]),
      ),
    );
  }
}
