import 'package:annix/controllers/annil_controller.dart';
import 'package:annix/controllers/player_controller.dart';
import 'package:annix/pages/playing/playing_lyric.dart';
import 'package:annix/pages/playing/playing_queue.dart';
import 'package:annix/third_party/marquee_widget/marquee_widget.dart';
import 'package:annix/widgets/artist_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlayingDesktopScreen extends StatelessWidget {
  PlayingDesktopScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AnnilController annil = Get.find();

    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: PlayingQueue(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 6,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 256,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Card(
                      elevation: 4,
                      clipBehavior: Clip.hardEdge,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: GetBuilder<PlayerController>(
                        builder: (player) {
                          final item = player.playing;
                          if (item == null) {
                            return Container();
                          } else {
                            return annil.cover(
                                albumId: item.albumId, tag: "playing");
                          }
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                GetBuilder<PlayerController>(
                  builder: (player) => Marquee(
                    child: Text(
                      player.playing?.track.title ?? "",
                      style: context.textTheme.titleLarge,
                    ),
                  ),
                ),
                GetBuilder<PlayerController>(
                  builder: (player) => ArtistText(
                    player.playing?.track.artist ?? "",
                    style: context.textTheme.subtitle2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(child: PlayingLyric()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
