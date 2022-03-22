import 'package:annix/services/annil.dart';
import 'package:annix/services/audio.dart';
import 'package:annix/widgets/favorite_button.dart';
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
            children: playlist.playlist.map(
              (e) {
                var audio = e as AnnilAudioSource;
                MediaItem info = audio.tag;
                return Row(
                  children: [
                    SizedBox(
                      width: 32,
                      // TODO: update
                      child: FavoriteButton(id: info.id),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          playlist.goto(audio);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Center(
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 6,
                                  child: Text(
                                    info.title,
                                    style: TextStyle(
                                      color: audio == active
                                          ? CupertinoTheme.of(context)
                                              .primaryColor
                                          : null,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Align(
                                    // FIXME: marquee align
                                    // child: Marquee(
                                    //   text: info.artist ?? '',
                                    //   scrollToEnd: true,
                                    //   marqueeShortText: false,
                                    //   style: TextStyle(
                                    //     fontSize: 0.8 *
                                    //         (CupertinoTheme.of(context)
                                    //                 .textTheme
                                    //                 .textStyle
                                    //                 .fontSize ??
                                    //             0),
                                    //     color: audio == active
                                    //         ? CupertinoTheme.of(context)
                                    //             .primaryColor
                                    //         : null,
                                    //   ),
                                    // ),
                                    child: Text("TODO"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ).toList(),
          ),
        );
      },
    );
  }
}
