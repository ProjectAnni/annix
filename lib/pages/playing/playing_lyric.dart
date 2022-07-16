import 'package:annix/controllers/anniv_controller.dart';
import 'package:annix/controllers/player_controller.dart';
import 'package:annix/lyric/lyric_provider.dart';
import 'package:annix/lyric/lyric_provider_netease.dart';
import 'package:annix/models/anniv.dart';
import 'package:annix/models/metadata.dart';
import 'package:annix/services/annil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:get/get.dart';

class PlayingLyricUI extends UINetease {
  @override
  TextStyle getPlayingMainTextStyle() {
    return Get.textTheme.bodyText1!;
  }

  @override
  TextStyle getOtherMainTextStyle() {
    return Get.textTheme.bodyText2!
        .copyWith(color: Get.textTheme.bodyText2?.color?.withOpacity(0.5));
  }
}

class PlayingLyric extends StatelessWidget {
  const PlayingLyric({Key? key}) : super(key: key);

  Future<LyricLanguage?> getLyric(AnnilAudioSource item) async {
    final AnnivController anniv = Get.find();
    final id = item.id;

    // 1. local cache
    var lyric = await LyricProvider.getLocal(id);

    // 2. anniv
    if (lyric == null) {
      final lyricResult = await anniv.client!.getLyric(id);
      lyric = lyricResult?.source;
    }

    // 3. lyric provider
    if (lyric == null) {
      LyricProvider provider = LyricProviderNetease();
      final songs = await provider.search(item);
      if (songs.isNotEmpty) {
        lyric = await songs.first.lyric;
      }
    }

    // 4. save to local cache
    if (lyric != null) {
      LyricProvider.saveLocal(item.id, lyric);
    }
    return lyric;
  }

  @override
  Widget build(BuildContext context) {
    final PlayerController player = Get.find();

    return Obx(
      () => player.playing?.track.type == TrackType.Normal
          ? FutureBuilder<LyricLanguage?>(
              future: getLyric(player.playing!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  final lyric = snapshot.data;
                  if (lyric == null) {
                    return Center(child: Text("No lyrics"));
                  } else {
                    if (lyric.type == "lrc") {
                      final model = LyricsModelBuilder.create()
                          .bindLyricToMain(lyric.data)
                          .getModel();
                      return Obx(() {
                        return LyricsReader(
                          model: model,
                          lyricUi: PlayingLyricUI(),
                          position: player.progress.value.inMilliseconds,
                        );
                      });
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
            )
          : Center(
              child:
                  Text(player.playing?.track.type.toString() ?? "Unknown type"),
            ),
    );
  }
}
