import 'package:annix/ui/page/playing/playing_mobile_widgets.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';

class PlayingScreenMobile extends StatefulWidget {
  const PlayingScreenMobile({super.key});

  @override
  State<PlayingScreenMobile> createState() => _PlayingScreenMobileState();
}

class _PlayingScreenMobileState extends State<PlayingScreenMobile> {
  final ValueNotifier<bool> showLyric = ValueNotifier(false);

  Widget _mainPlayingWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(height: 0),
        MusicCoverOrLyric(
          showLyric: showLyric,
          fillColor: context.colorScheme.secondaryContainer,
        ),
        const PlayingScreenMobileTrackInfo(),
        const PlayingScreenMobileControl(),
        PlayingScreenMobileBottomBar(showLyrics: showLyric),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: context.colorScheme.secondaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: _mainPlayingWidget(),
      ),
    );
  }
}
