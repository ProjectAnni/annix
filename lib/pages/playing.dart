import 'package:annix/controllers/annil_controller.dart';
import 'package:annix/controllers/playing_controller.dart';
import 'package:annix/controllers/playlist_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlayingScreen extends StatefulWidget {
  PlayingScreen({Key? key}) : super(key: key);

  @override
  _PlayingScreenState createState() => _PlayingScreenState();
}

class _PlayingScreenState extends State<PlayingScreen> {
  @override
  Widget build(BuildContext context) {
    final PlayingController playing = Get.find();
    final PlaylistController playlist = Get.find();
    final AnnilController annil = Get.find();

    var inner = Material(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Card(
              elevation: 16,
              child: Hero(
                tag: "playing-cover",
                child: Obx(() {
                  final index = playlist.playingIndex.value;
                  if (playlist.playlist.length <= index) {
                    return Container();
                  } else {
                    var playingItem = playlist.playlist[index];
                    return annil.cover(albumId: playingItem.id.split('/')[0]);
                  }
                }),
              ),
            ),
          ),
          Obx(
            () {
              final index = playlist.playingIndex.value;
              var text = "";
              if (playlist.playlist.length > index) {
                var playingItem = playlist.playlist[index];
                text = "${playingItem.title}";
              }
              return Text(
                text,
                style: context.textTheme.titleLarge,
              );
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.skip_previous),
                iconSize: 48,
                onPressed: () => playing.previous(),
              ),
              Obx(
                () => IconButton(
                  icon: Icon(
                    playing.isPlaying.value ? Icons.pause : Icons.play_arrow,
                  ),
                  iconSize: 48,
                  onPressed: () => playing.playOrPause(),
                ),
              ),
              IconButton(
                icon: Icon(Icons.skip_next),
                iconSize: 48,
                onPressed: () => playing.next(),
              ),
            ],
          ),
        ],
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
