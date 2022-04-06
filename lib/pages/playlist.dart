import 'package:annix/controllers/playing_controller.dart';
import 'package:annix/controllers/playlist_controller.dart';
import 'package:annix/services/annil.dart';
import 'package:annix/widgets/favorite_button.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:just_audio_background/just_audio_background.dart';

class AnnixPlaylist extends StatelessWidget {
  const AnnixPlaylist({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    PlayingController playing = Get.find();
    PlaylistController playlist = Get.find();

    if (playing.state.value.track == null) {
      return Container();
    }

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
                            // Expanded(
                            //   flex: 6,
                            //   child: Text(
                            //     info.title,
                            //     style: TextStyle(
                            //       color: audio == active
                            //           ? Get.theme.primaryColor
                            //           : null,
                            //     ),
                            //   ),
                            // ),
                            Expanded(
                              flex: 4,
                              child: Align(
                                child: Text(info.artist ?? ''),
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
  }
}
