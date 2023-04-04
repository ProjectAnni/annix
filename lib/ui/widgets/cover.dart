import 'package:annix/global.dart';
import 'package:annix/providers.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
    final playing = ref.watch(playingProvider);
    Widget child;

    if (playing == null) {
      // not playing
      child = const DummyMusicCover();
    } else {
      // is playing
      child = MusicCover.fromAlbum(
        key: ValueKey(playing.identifier.albumId),
        albumId: playing.identifier.albumId,
        provider: playing.source.coverProvider,
        fit: fit,
        filterQuality: filterQuality,
        onImage: (final provider) async {
          final scheme =
              await ColorScheme.fromImageProvider(provider: provider);
          final darkScheme = await ColorScheme.fromImageProvider(
              provider: provider, brightness: Brightness.dark);
          ref.read(themeProvider).setScheme(scheme, darkScheme);
        },
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

class MusicCover extends StatelessWidget {
  final ImageProvider image;

  final BoxFit? fit;
  final FilterQuality filterQuality;
  final String? tag;

  final double? width;
  final double? height;

  final void Function(ImageProvider)? onImage;

  factory MusicCover.fromAlbum({
    required final String albumId,
    final int? discId,
    final ImageProvider? provider,
    final Key? key,
    final BoxFit? fit,
    final FilterQuality filterQuality = FilterQuality.low,
    final String? tag,
    final void Function(ImageProvider)? onImage,
    final double? width,
    final double? height,
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

  Widget? _loadStateChanged(final ExtendedImageState state) {
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
  Widget build(final BuildContext context) {
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
  const DummyMusicCover({super.key});

  @override
  Widget build(final BuildContext context) {
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
