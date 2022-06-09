import 'package:annix/controllers/annil_controller.dart';
import 'package:annix/controllers/playing_controller.dart';
import 'package:annix/third_party/marquee_widget/marquee_widget.dart';
import 'package:annix/widgets/artist_text.dart';
import 'package:annix/widgets/buttons/favorite_button.dart';
import 'package:annix/widgets/buttons/loop_mode_button.dart';
import 'package:annix/widgets/buttons/play_pause_button.dart';
import 'package:annix/widgets/buttons/shuffle_button.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlayingDesktopScreen extends StatelessWidget {
  PlayingDesktopScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PlayingController playing = Get.find();
    final AnnilController annil = Get.find();

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              flex: 1,
              child: Card(
                elevation: 4,
                clipBehavior: Clip.hardEdge,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SizedBox(
                  // height: 200,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Obx(() {
                      final item = playing.currentPlaying.value;
                      if (item == null) {
                        return Container();
                      } else {
                        return annil.cover(
                            albumId: item.id.split('/')[0], tag: "playing");
                      }
                    }),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Obx(
                    () => Marquee(
                      child: Text(
                        playing.currentPlaying.value?.title ?? "",
                        style: context.textTheme.titleLarge,
                      ),
                    ),
                  ),
                  Obx(
                    () => ArtistText(
                      playing.currentPlaying.value?.artist ?? "",
                      style: context.textTheme.subtitle1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  ButtonBar(
                    alignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(
                        () => FavoriteButton(
                            id: playing.currentPlaying.value!.id),
                      ),
                      LoopModeButton(),
                      ShuffleButton(),
                    ],
                  ),
                  Obx(
                    () {
                      var position = playing.progress.value;
                      final total = playing.getDuration(
                        playing.currentPlaying.value!.id,
                      );
                      if (position.compareTo(total) > 0) {
                        // seek to next
                        playing
                            .pause()
                            .then((value) => playing.next())
                            .then((value) => playing.play());
                        // limit progress to total
                        position = total;
                      }

                      var buffered = playing.buffered.value;
                      if (position.compareTo(total) > 0) {
                        buffered = total;
                      }
                      return ProgressBar(
                        progress: position,
                        buffered: buffered,
                        total: total,
                        onSeek: (position) {
                          playing.seek(position);
                        },
                        barHeight: 2.0,
                        thumbRadius: 5.0,
                        thumbCanPaintOutsideBar: false,
                      );
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        icon: Icon(Icons.skip_previous),
                        iconSize: 32,
                        onPressed: () => playing.previous(),
                      ),
                      PlayPauseButton(iconSize: 48),
                      IconButton(
                        icon: Icon(Icons.skip_next),
                        iconSize: 32,
                        onPressed: () => playing.next(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
