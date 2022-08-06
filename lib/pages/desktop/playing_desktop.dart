import 'package:annix/controllers/player_controller.dart';
import 'package:annix/pages/playing/playing_lyric.dart';
import 'package:annix/pages/playing/playing_queue.dart';
import 'package:annix/third_party/marquee_widget/marquee_widget.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/widgets/artist_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_lyric/lyric_ui/lyric_ui.dart';

class PlayingDesktopScreen extends StatelessWidget {
  PlayingDesktopScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Expanded(
          //   flex: 4,
          //   child: Column(
          //     mainAxisAlignment: MainAxisAlignment.start,
          //     children: [
          //       Expanded(
          //         child: Padding(
          //           padding: EdgeInsets.symmetric(horizontal: 8),
          //           child: PlayingQueue(),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          Column(
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
                    child: PlayingMusicCover(),
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
            ],
          ),
          Container(
            child: PlayingLyric(alignment: LyricAlign.LEFT),
          ),
        ],
      ),
    );
  }
}
