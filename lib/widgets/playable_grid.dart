import 'dart:typed_data';

import 'package:annix/models/song.dart';
import 'package:annix/services/audio.dart';
import 'package:annix/services/global.dart';
import 'package:annix/services/platform.dart';
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
          Center(
            child: FutureBuilder<Uint8List>(
              future: widget.cover,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Image.memory(
                    snapshot.data!,
                    filterQuality: FilterQuality.high,
                    isAntiAlias: true,
                  );
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
          ),
          // Display on hover / on mobile
          AnniPlatform.isMobile || hover
              ? Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                    icon: Icon(Icons.play_arrow),
                    padding: EdgeInsets.all(16),
                    onPressed: () async {
                      // Play current playlist instead of the current one
                      await Global.audioService.pause();

                      var songs = await widget.playlistCallback(widget.id);
                      if (songs != null) {
                        Global.audioService.playlist = ConcatenatingAudioSource(
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
                            .triggerChange();
                        await Global.audioService.play();
                      }
                    },
                  ),
                )
              : Container(),
        ]),
      ),
    );
  }
}
