import 'package:annix/global.dart';
import 'package:annix/services/playback/playback.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlayingMusicCover extends StatelessWidget {
  final bool card;
  final BoxFit? fit;
  final FilterQuality filterQuality;
  final bool animated;

  const PlayingMusicCover({
    super.key,
    this.card = true,
    this.fit,
    this.filterQuality = FilterQuality.medium,
    this.animated = true,
  });

  @override
  Widget build(BuildContext context) {
    final child = Selector<PlaybackService, PlayingTrack?>(
      selector: (context, player) => player.playing,
      builder: (context, playing, child) {
        if (playing == null) {
          // not playing
          return const DummyMusicCover();
        }

        // is playing
        Widget child = MusicCover.fromAlbum(
          key: ValueKey(playing.identifier.albumId),
          albumId: playing.identifier.albumId,
          provider: playing.source.coverProvider,
          fit: fit,
          filterQuality: filterQuality,
          onImage: (provider) async {
            final scheme =
                await ColorScheme.fromImageProvider(provider: provider);
            final darkScheme = await ColorScheme.fromImageProvider(
                provider: provider, brightness: Brightness.dark);
            Global.theme.setScheme(scheme, darkScheme);
          },
        );

        if (animated) {
          child = AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: child,
          );
        }
        return child;
      },
    );

    if (card) {
      return CoverCard(
        child: child,
      );
    } else {
      return child;
    }
  }
}

class MusicCover extends StatelessWidget {
  final ImageProvider image;

  final BoxFit? fit;
  final FilterQuality filterQuality;
  final String? tag;

  final double? width;
  final double? height;

  final void Function(ImageProvider)? onImage;

  factory MusicCover.fromAlbum({
    required String albumId,
    int? discId,
    ImageProvider? provider,
    Key? key,
    BoxFit? fit,
    FilterQuality filterQuality = FilterQuality.low,
    String? tag,
    void Function(ImageProvider)? onImage,
    double? width,
    double? height,
  }) {
    final image = provider ??
        ExtendedNetworkImageProvider(
          Global.proxy.coverUrl(albumId, discId),
        );
    return MusicCover(
      key: key,
      image: image,
      fit: fit,
      filterQuality: filterQuality,
      tag: tag,
      onImage: onImage,
      width: width,
      height: height,
    );
  }

  MusicCover({
    super.key,
    required this.image,
    this.fit,
    this.filterQuality = FilterQuality.low,
    this.tag,
    this.onImage,
    this.width,
    this.height,
  }) {
    onImage?.call(image);
  }

  Widget? _loadStateChanged(ExtendedImageState state) {
    switch (state.extendedImageLoadState) {
      case LoadState.completed:
        final image = state.extendedImageInfo!.image;

        return ExtendedRawImage(
          image: image,
          fit: fit,
          filterQuality: filterQuality,
          width: width,
          height: height,
        );
      default:
        return const DummyMusicCover();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExtendedImage(
      image: image,
      fit: fit,
      loadStateChanged: _loadStateChanged,
    );
  }
}

class CoverCard extends StatelessWidget {
  final Widget child;

  const CoverCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      elevation: 1,
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
  const DummyMusicCover({super.key});

  @override
  Widget build(BuildContext context) {
    final cover = AspectRatio(
      aspectRatio: 1,
      child: Container(
        color: Colors.black87,
        child: const Center(
          child: Icon(Icons.music_note, color: Colors.white, size: 32),
        ),
      ),
    );

    return cover;
  }
}
