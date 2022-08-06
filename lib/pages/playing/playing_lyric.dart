import 'package:annix/controllers/anniv_controller.dart';
import 'package:annix/controllers/player_controller.dart';
import 'package:annix/lyric/lyric_provider.dart';
import 'package:annix/lyric/lyric_provider_netease.dart';
import 'package:annix/lyric/lyric_provider_petitlyrics.dart';
import 'package:annix/models/anniv.dart';
import 'package:annix/models/metadata.dart';
import 'package:annix/services/annil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:get/get.dart';

extension on LyricAlign {
  TextAlign get textAlign {
    switch (this) {
      case LyricAlign.LEFT:
        return TextAlign.left;
      case LyricAlign.RIGHT:
        return TextAlign.right;
      case LyricAlign.CENTER:
        return TextAlign.center;
    }
  }
}

class PlayingLyricUI extends LyricUI {
  final LyricAlign align;

  PlayingLyricUI({this.align = LyricAlign.CENTER});

  @override
  TextStyle getPlayingMainTextStyle() {
    return Get.textTheme.bodyText1!;
  }

  @override
  TextStyle getOtherMainTextStyle() {
    return Get.textTheme.bodyText2!
        .copyWith(color: Get.textTheme.bodyText2?.color?.withOpacity(0.5));
  }

  @override
  double getInlineSpace() => 20;

  @override
  double getLineSpace() => 20;

  @override
  LyricAlign getLyricHorizontalAlign() {
    return this.align;
  }

  @override
  TextStyle getPlayingExtTextStyle() {
    // TODO: custom style
    return TextStyle(color: Colors.grey[300], fontSize: 14);
  }

  @override
  TextStyle getOtherExtTextStyle() {
    // TODO: custom style
    return TextStyle(color: Colors.grey[300], fontSize: 14);
  }

  @override
  double getPlayingLineBias() {
    return 0.5;
  }

  @override
  Color getLyricHightlightColor() {
    return Get.theme.colorScheme.primary;
  }
}

class PlayingLyric extends StatelessWidget {
  final LyricAlign alignment;

  const PlayingLyric({Key? key, this.alignment = LyricAlign.CENTER})
      : super(key: key);

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
      LyricProvider provider = LyricProviderPetitLyrics();
      final songs = await provider.search(item.track);
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
    return GetBuilder<PlayerController>(
      builder: (player) => player.playing?.track.type == TrackType.Normal
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
                          // .bindLyricToExt(lyric) // TODO: translation
                          .getModel();
                      return Obx(() {
                        return LyricsReader(
                          model: model,
                          lyricUi: PlayingLyricUI(align: alignment),
                          position: player.progress.value
                              .inMilliseconds /* + 500 as offset */,
                          // don't know why only playing = false has highlight
                          playing: false,
                        );
                      });
                    } else {
                      return SingleChildScrollView(
                        child: Text(
                          lyric.data,
                          textAlign: alignment.textAlign,
                          style: context.textTheme.bodyText1!
                              .copyWith(height: 1.5),
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
