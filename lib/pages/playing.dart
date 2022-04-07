import 'package:annix/controllers/annil_controller.dart';
import 'package:annix/controllers/playing_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlayingScreen extends StatefulWidget {
  PlayingScreen({Key? key}) : super(key: key);

  @override
  _PlayingScreenState createState() => _PlayingScreenState();
}

class _PlayingScreenState extends State<PlayingScreen> {
  double dragY = 0.0;

  @override
  Widget build(BuildContext context) {
    final PlayingController playing = Get.find();
    final AnnilController annil = Get.find();

    var inner = Expanded(
      flex: 1,
      child: Material(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Card(
                elevation: 16,
                child: Hero(
                  tag: "playing-cover",
                  child: annil.cover(
                    albumId: playing.state.value.track?.track.albumId ?? "TODO",
                  ),
                ),
              ),
            ),
            Obx(
              () => Text(
                "${playing.state.value.track?.info.title}",
                style: context.textTheme.titleLarge,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(Icons.skip_previous),
                  iconSize: 48,
                  onPressed: () {
                    playing.service.previous();
                  },
                ),
                Obx(
                  () => playing.status.value == PlayingStatus.loading
                      ? CircularProgressIndicator()
                      : IconButton(
                          icon: Icon(
                            playing.status.value == PlayingStatus.playing
                                ? Icons.pause
                                : Icons.play_arrow,
                          ),
                          iconSize: 48,
                          onPressed: () async {
                            if (playing.status.value == PlayingStatus.playing) {
                              playing.service.pause();
                            } else {
                              playing.service.play();
                            }
                          },
                        ),
                ),
                IconButton(
                  icon: Icon(Icons.skip_next),
                  iconSize: 48,
                  onPressed: () {
                    playing.service.next();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return GestureDetector(
      onVerticalDragEnd: (details) {
        if ((details.primaryVelocity ?? 0) > 300) {
          Get.back();
        }
      },
      child: inner,
    );
  }
}
