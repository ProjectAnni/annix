import 'package:annix/providers.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimmer/shimmer.dart';

class PlayingMusicCover extends ConsumerWidget {
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
  Widget build(final BuildContext context, final WidgetRef ref) {
    final playingId =
        ref.watch(playingProvider.select((final v) => v.source?.identifier));
    Widget child;

    if (playingId == null) {
      // not playing
      child = const DummyMusicCover();
    } else {
      // is playing
      ref.read(themeProvider).setImageProvider(playingId.albumId);
      child = MusicCover.fromAlbum(
        key: ValueKey(playingId.albumId),
        albumId: playingId.albumId,
        fit: fit,
        filterQuality: filterQuality,
      );

      if (animated) {
        child = AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder:
              (final Widget child, final Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: child,
        );
      }
    }

    if (card) {
      return CoverCard(
        child: child,
      );
    } else {
      return child;
    }
  }
}

class MusicCover extends ConsumerWidget {
  final String albumId;
  final int? discId;

  final BoxFit? fit;
  final FilterQuality filterQuality;
  final String? tag;

  final double? width;
  final double? height;

  factory MusicCover.fromAlbum({
    required final String albumId,
    final int? discId,
    final Key? key,
    final BoxFit? fit,
    final FilterQuality filterQuality = FilterQuality.low,
    final String? tag,
    final double? width,
    final double? height,
  }) {
    return MusicCover._(
      key: key,
      albumId: albumId,
      discId: discId,
      fit: fit,
      filterQuality: filterQuality,
      tag: tag,
      width: width,
      height: height,
    );
  }

  const MusicCover._({
    super.key,
    required this.albumId,
    this.discId,
    this.fit,
    required this.filterQuality,
    this.tag,
    this.width,
    this.height,
  });

  Widget? _loadStateChanged(BuildContext context, ExtendedImageState state) {
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
        return Stack(
          alignment: Alignment.center,
          children: [
            Shimmer.fromColors(
              baseColor: context.colorScheme.secondaryContainer,
              highlightColor: context.colorScheme.onPrimary,
              child: const DummyMusicCover(),
            ),
            const Icon(Icons.music_note, size: 32),
          ],
        );
    }
  }

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final image = ExtendedResizeImage.resizeIfNeeded(
      provider: ref.read(proxyProvider).coverProvider(albumId, discId),
      compressionRatio: 0.5,
    );

    return ExtendedImage(
      image: image,
      fit: fit,
      loadStateChanged: (state) => _loadStateChanged(context, state),
    );
  }
}

class CoverCard extends StatelessWidget {
  final Widget child;

  const CoverCard({super.key, required this.child});

  @override
  Widget build(final BuildContext context) {
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
  final bool square;

  const DummyMusicCover({super.key, this.square = true});

  @override
  Widget build(final BuildContext context) {
    final cover = Container(
      color: Colors.black87,
      child: const Center(
        child: Icon(Icons.music_note, color: Colors.white, size: 32),
      ),
    );

    if (square) {
      return AspectRatio(aspectRatio: 1, child: cover);
    } else {
      return cover;
    }
  }
}
