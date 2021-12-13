import 'package:annix/services/annil.dart';
import 'package:annix/services/audio.dart';
import 'package:flutter/cupertino.dart' show CupertinoTheme;
import 'package:flutter/widgets.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';

class AnnixPlaylist extends StatelessWidget {
  const AnnixPlaylist({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AnnilPlaylist>(
      builder: (context, playlist, child) {
        if (playlist.playing == null) {
          return Container();
        }

        var active = playlist.playing;
        return SingleChildScrollView(
          child: Column(
            children: playlist.playlist.children.map(
              (e) {
                var audio = e as AnnilAudioSource;
                MediaItem info = audio.tag;
                return GestureDetector(
                  onTap: () {
                    playlist.goto(audio);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Center(
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              // TODO: better way to show active song
                              children: [
                                Text(
                                  info.title,
                                  style: TextStyle(
                                    color: audio == active
                                        ? CupertinoTheme.of(context)
                                            .primaryColor
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            info.artist ?? '',
                            style: TextStyle(
                              fontSize: 0.8 *
                                  (CupertinoTheme.of(context)
                                          .textTheme
                                          .textStyle
                                          .fontSize ??
                                      0),
                              color: audio == active
                                  ? CupertinoTheme.of(context).primaryColor
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ).toList(),
          ),
        );
      },
    );
  }
}
