import 'dart:async';

import 'package:annix/services/annil.dart';
import 'package:annix/services/cover.dart';
import 'package:annix/services/global.dart';
import 'package:annix/services/theme.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_color_utilities/quantize/quantizer_celebi.dart';
import 'package:material_color_utilities/score/score.dart';
import 'package:annix/controllers/annil_controller.dart';
import 'package:annix/services/player.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class PlayingMusicCover extends StatelessWidget {
  final AnnilController annil = Get.find();

  final bool card;
  final BoxFit? fit;
  final FilterQuality filterQuality;

  PlayingMusicCover({
    super.key,
    this.card = true,
    this.fit,
    this.filterQuality = FilterQuality.medium,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<PlayerService, AnnilAudioSource?>(
      selector: (context, player) => player.playing,
      builder: (context, playing, child) {
        if (playing == null) {
          // not playing
          return Container();
        }

        // is playing
        return MusicCover(
          albumId: playing.albumId,
          card: card,
          fit: fit,
          filterQuality: filterQuality,
          onColor: (color) {
            Provider.of<AnnixTheme>(Global.context, listen: false)
                .setTheme(color);
          },
        );
      },
    );
  }
}

class MusicCover extends StatelessWidget {
  static Map<String, Future<Color>> colors = {};

  final AnnilController annil = Get.find();

  final String albumId;
  final int? discId;

  final bool card;
  final BoxFit? fit;
  final FilterQuality filterQuality;
  final String? tag;

  final void Function(Color)? onColor;

  MusicCover({
    super.key,
    required this.albumId,
    this.discId,
    this.card = true,
    this.fit,
    this.filterQuality = FilterQuality.low,
    this.tag,
    this.onColor,
  });

  @override
  Widget build(BuildContext context) {
    final id = "$albumId/$discId";

    final cover = Hero(
      tag: "$tag/$albumId/$discId",
      child: ExtendedImage.network(
        CoverReverseProxy()
            .url(
              CoverItem(
                albumId: albumId,
                discId: discId,
                uri: annil.clients.value.getCoverUrl(
                  albumId: albumId,
                  // discId: discId,
                ),
              ),
            )
            .toString(),
        fit: fit,
        filterQuality: filterQuality,
        cacheHeight: 800,
        cache: false,
        loadStateChanged: (state) {
          switch (state.extendedImageLoadState) {
            case LoadState.completed:
              final image = state.extendedImageInfo!.image;
              if (onColor != null) {
                colors.putIfAbsent(
                  id,
                  () => image.toByteData().then(
                        (bytes) => compute(getColorFromImage, bytes!),
                      ),
                );
                colors[id]?.then((color) => onColor!(color));
              }

              return ExtendedRawImage(image: image);
            default:
              return const DummyMusicCover();
          }
        },
      ),
    );

    if (!card) {
      return cover;
    } else {
      return _CoverCard(child: cover);
    }
  }
}

class _CoverCard extends StatelessWidget {
  final Widget child;
  const _CoverCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: AspectRatio(
        aspectRatio: 1,
        child: child,
      ),
    );
  }
}

class DummyMusicCover extends StatelessWidget {
  final bool card;

  const DummyMusicCover({super.key, this.card = true});

  @override
  Widget build(BuildContext context) {
    final cover = Container(
      color: Colors.black87,
      child: const Center(
        child: Icon(Icons.music_note, color: Colors.white, size: 32),
      ),
    );

    if (!card) {
      return cover;
    } else {
      return _CoverCard(child: cover);
    }
  }
}

int argbFromRgb(int red, int green, int blue) {
  return (255 << 24 | (red & 255) << 16 | (green & 255) << 8 | blue & 255) >>>
      0;
}

Future<Color> getColorFromImage(ByteData bytes) async {
  final List<int> pixels = [];
  for (var i = 0; i < bytes.lengthInBytes; i += 4) {
    final r = bytes.getUint8(i);
    final g = bytes.getUint8(i + 1);
    final b = bytes.getUint8(i + 2);
    final a = bytes.getUint8(i + 3);
    if (a < 255) {
      continue;
    }
    final argb = argbFromRgb(r, g, b);
    pixels.add(argb);
  }
  final result = await QuantizerCelebi().quantize(pixels, 128);
  final ranked = Score.score(result.colorToCount);
  final top = ranked[0];
  return Color(top);
}
