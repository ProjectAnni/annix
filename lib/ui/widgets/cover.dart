import 'dart:async';

import 'package:annix/global.dart';
import 'package:annix/services/annil/audio_source.dart';
import 'package:annix/services/annil/cover.dart';
import 'package:annix/services/theme.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_color_utilities/quantize/quantizer_celebi.dart';
import 'package:material_color_utilities/score/score.dart';
import 'package:annix/services/player.dart';
import 'package:provider/provider.dart';

class PlayingMusicCover extends StatelessWidget {
  final bool card;
  final BoxFit? fit;
  final FilterQuality filterQuality;

  const PlayingMusicCover({
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
          return DummyMusicCover(card: card);
        }

        // is playing
        return MusicCover(
          albumId: playing.identifier.albumId,
          image: playing.coverProvider,
          card: card,
          fit: fit,
          filterQuality: filterQuality,
          onColor: (color) {
            Global.context.read<AnnixTheme>().setTheme(color);
          },
        );
      },
    );
  }
}

class MusicCover extends StatelessWidget {
  static Map<String, Completer<Color>> colors = {};

  final ImageProvider? image;
  final String albumId;
  final int? discId;

  final bool card;
  final BoxFit? fit;
  final FilterQuality filterQuality;
  final String? tag;

  final void Function(Color)? onColor;

  const MusicCover({
    super.key,
    required this.albumId,
    this.discId,
    this.card = true,
    this.fit,
    this.filterQuality = FilterQuality.low,
    this.tag,
    this.onColor,
    this.image,
  });

  Widget? _loadStateChanged(ExtendedImageState state) {
    final id = "$albumId/$discId";
    switch (state.extendedImageLoadState) {
      case LoadState.completed:
        final image = state.extendedImageInfo!.image;
        if (onColor != null) {
          colors
              .putIfAbsent(
                id,
                () {
                  final completer = Completer<Color>();
                  image.toByteData().then(
                    (bytes) async {
                      final color = await compute(getColorFromImage, bytes!);
                      completer.complete(color);
                    },
                  );
                  return completer;
                },
              )
              .future
              .then((color) => onColor!(color));
        }

        return ExtendedRawImage(
          image: image,
          fit: fit,
          filterQuality: filterQuality,
        );
      default:
        return const DummyMusicCover();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget image;
    if (this.image != null) {
      image = ExtendedImage(
        image: this.image!,
        loadStateChanged: _loadStateChanged,
      );
    } else {
      image = ExtendedImage.network(
        CoverReverseProxy()
            .url(CoverItem(albumId: albumId, discId: discId))
            .toString(),
        cache: true,
        cacheHeight: 800,
        loadStateChanged: _loadStateChanged,
      );
    }

    final cover = Hero(
      tag: "$tag/$albumId/$discId",
      child: image,
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
  return (255 << 24 | red << 16 | green << 8 | blue) >>> 0;
}

Future<Color> getColorFromImage(ByteData bytes) async {
  final pixels = Iterable.generate(bytes.lengthInBytes ~/ 4, (offset) {
    final index = offset * 4;
    final r = bytes.getUint8(index);
    final g = bytes.getUint8(index + 1);
    final b = bytes.getUint8(index + 2);
    // final a = bytes.getUint8(index + 3);
    final argb = argbFromRgb(r, g, b);
    return argb;
  });
  final result = await QuantizerCelebi().quantize(pixels, 128);
  final ranked = Score.score(result.colorToCount);
  final top = ranked[0];
  return Color(top);
}
