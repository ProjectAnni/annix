import 'package:annix/controllers/annil_controller.dart';
import 'package:annix/controllers/player_controller.dart';
import 'package:annix/widgets/cover_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlayingMusicCover extends StatelessWidget {
  final AnnilController annil = Get.find();

  final BoxFit? fit;
  final FilterQuality filterQuality;

  PlayingMusicCover({
    super.key,
    this.fit,
    this.filterQuality = FilterQuality.medium,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: "playing",
      child: GetBuilder<PlayerController>(
        builder: (player) {
          final playing = player.playing;
          if (playing == null) {
            // not playing
            return Container();
          }

          // is playing
          return ThemedImage(
            CoverReverseProxy()
                .url(
                  CoverItem(
                    albumId: playing.albumId,
                    discId: playing.discId,
                    uri: annil.clients.value.getCoverUrl(
                      albumId: playing.albumId,
                      discId: playing.discId,
                    ),
                  ),
                )
                .toString(),
            fit: fit,
            filterQuality: filterQuality,
            cacheHeight: 800,
            gaplessPlayback: true,
            cache: false,
          );
        },
      ),
    );
  }
}

class MusicCover extends StatelessWidget {
  final AnnilController annil = Get.find();

  final String albumId;
  final int? discId;

  final BoxFit? fit;
  final FilterQuality filterQuality;
  final String? tag;

  MusicCover({
    super.key,
    required this.albumId,
    this.discId,
    this.fit,
    this.filterQuality = FilterQuality.low,
    this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: "${tag ?? ""}/$albumId/$discId",
      child: ThemedImage(
        CoverReverseProxy()
            .url(
              CoverItem(
                albumId: albumId,
                discId: discId,
                uri: annil.clients.value.getCoverUrl(
                  albumId: albumId,
                  discId: discId,
                ),
              ),
            )
            .toString(),
        fit: fit,
        filterQuality: filterQuality,
        cacheHeight: 800,
        gaplessPlayback: true,
        cache: false,
      ),
    );
  }
}

class DummyMusicCover extends StatelessWidget {
  const DummyMusicCover({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Icon(Icons.music_note, color: Colors.white, size: 32),
      ),
    );
  }
}
