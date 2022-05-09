import 'package:annix/controllers/anniv_controller.dart';
import 'package:annix/controllers/playing_controller.dart';
import 'package:annix/models/anniv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:get/get.dart';

class PlayingLyric extends StatelessWidget {
  const PlayingLyric({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PlayingController playing = Get.find();
    final AnnivController anniv = Get.find();

    return Obx(() {
      return FutureBuilder<LyricResponse?>(
        future: anniv.client!.getLyric(playing.currentPlaying.value!.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data == null) {
              return Center(child: Text("No lyrics"));
            } else {
              final lyric = snapshot.data!.source;
              if (lyric.type == "lrc") {
                return LyricsReader(
                  model: LyricsModelBuilder.create()
                      .bindLyricToMain(lyric.data)
                      .getModel(),
                );
              } else {
                return SingleChildScrollView(
                  child: Text(
                    lyric.data,
                    textAlign: TextAlign.center,
                  ),
                );
              }
            }
          } else {
            return Center(child: Text("Loading..."));
          }
        },
      );
    });
  }
}
