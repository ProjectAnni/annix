import 'dart:ui';

import 'package:annix/ui/page/playing/playing_mobile_widgets.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';

class PlayingScreenMobileBlur extends StatefulWidget {
  const PlayingScreenMobileBlur({super.key});

  @override
  State<PlayingScreenMobileBlur> createState() =>
      _PlayingScreenMobileBlurState();
}

class _PlayingScreenMobileBlurState extends State<PlayingScreenMobileBlur> {
  final ValueNotifier<bool> showLyric = ValueNotifier(false);

  Widget _mainPlayingWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(height: 0),
        MusicCoverOrLyric(showLyric: showLyric),
        const PlayingScreenMobileTrackInfo(),
        const PlayingScreenMobileControl(),
        PlayingScreenMobileBottomBar(showLyrics: showLyric),
      ],
    );
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints.expand(),
            child: const PlayingMusicCover(
              animated: false,
              card: false,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox.expand(
            child: ColoredBox(
              color:
                  context.colorScheme.secondaryContainer.withValues(alpha: 0.6),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.only(left: 24, right: 24),
              child: _mainPlayingWidget(),
            ),
          ),
        ],
      ),
    );
  }
}
