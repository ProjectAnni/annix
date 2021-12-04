import 'dart:typed_data';

import 'package:annix/models/song.dart';
import 'package:annix/services/audio.dart';
import 'package:annix/services/global.dart';
import 'package:annix/services/platform.dart';
import 'package:annix/widgets/square_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

typedef PlaylistCallback = Future<List<Song>?> Function(String catalog);

class PlayableGrid extends StatefulWidget {
  final String id;
  final Future<Uint8List> cover;
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
            child: FutureBuilder<Uint8List>(
              future: widget.cover,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Image.memory(
                    snapshot.data!,
                    fit: BoxFit.scaleDown,
                    filterQuality: FilterQuality.medium,
                  );
                } else {
                  return SizedBox.square(
                    dimension: 64,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
              },
            ),
          ),
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
                            children: songs
                                .map<AudioSource>(
                                  (s) => Global.annil.getAudio(
                                    catalog: s.catalog,
                                    trackId: s.trackId,
                                  ),
                                )
                                .toList(),
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
