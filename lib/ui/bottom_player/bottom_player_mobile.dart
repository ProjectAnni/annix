import 'package:annix/providers.dart';
import 'package:annix/ui/widgets/buttons/favorite_button.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/ui/widgets/buttons/play_pause_button.dart';
import 'package:annix/ui/widgets/swiper.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MobileBottomPlayer extends StatelessWidget {
  /// Height of the mobile player bar
  static const double height = 60;

  const MobileBottomPlayer({super.key});

  @override
  Widget build(final BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        color: ElevationOverlay.applySurfaceTint(
          context.colorScheme.surface,
          context.colorScheme.surfaceTint,
          4.0,
        ),
      ),
      height: height,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                child: const PlayingMusicCover(card: true, animated: false),
              ),
              const Expanded(
                flex: 1,
                child: PlayingTrackSwiper(),
              ),
              const FavoriteButton(),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: PlayPauseButton.small(),
              ),
            ],
          ),
          Consumer(builder: (context, ref, child) {
            final playing = ref.watch(playingProvider);
            return LinearProgressIndicator(
              value: playing.progress,
              minHeight: 2,
            );
          }),
        ],
      ),
    );
  }
}
