import 'package:annix/controllers/annil_controller.dart';
import 'package:annix/controllers/player_controller.dart';
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
    final AnnilController annil = Get.find();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Card(
            elevation: 4,
            clipBehavior: Clip.hardEdge,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: AspectRatio(
              aspectRatio: 1,
              child: GetBuilder<PlayerController>(
                builder: (player) {
                  final item = player.playing;
                  if (item == null) {
                    return Container();
                  } else {
                    return annil.cover(albumId: item.albumId, tag: "playing");
                  }
                },
              ),
            ),
          ),
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
                  GetBuilder<PlayerController>(
                    builder: (player) => FavoriteButton(player.playing!),
                  ),
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
