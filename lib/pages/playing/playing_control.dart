import 'package:annix/controllers/player_controller.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/widgets/artist_text.dart';
import 'package:annix/widgets/buttons/favorite_button.dart';
import 'package:annix/widgets/buttons/loop_mode_button.dart';
import 'package:annix/widgets/buttons/play_pause_button.dart';
import 'package:annix/third_party/marquee_widget/marquee_widget.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlayingControl extends StatelessWidget {
  const PlayingControl({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PlayerController player = Get.find();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          PlayingMusicCover(card: true),
          Column(
            children: [
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
                  style: context.textTheme.subtitle1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Column(
            children: [
              ButtonBar(
                alignment: MainAxisAlignment.spaceBetween,
                children: [
                  FavoriteButton(),
                  LoopModeButton(),
                ],
              ),
              Obx(() {
                return ProgressBar(
                  progress: player.progress.value,
                  total: player.duration.value,
                  onSeek: (position) {
                    player.seek(position);
                  },
                  barHeight: 2.0,
                  thumbRadius: 5.0,
                  thumbCanPaintOutsideBar: false,
                );
              }),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: Icon(Icons.skip_previous),
                    iconSize: 32,
                    onPressed: () => player.previous(),
                  ),
                  PlayPauseButton(iconSize: 48),
                  IconButton(
                    icon: Icon(Icons.skip_next),
                    iconSize: 32,
                    onPressed: () => player.next(),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
