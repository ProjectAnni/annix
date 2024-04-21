import 'package:annix/ui/page/playing/playing_mobile_widgets.dart';
import 'package:annix/ui/route/delegate.dart';
import 'package:annix/ui/widgets/buttons/favorite_button.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';

import 'dart:math' as math;

class PlayingScreenMobile extends StatefulWidget {
  const PlayingScreenMobile({super.key});

  @override
  State<PlayingScreenMobile> createState() => _PlayingScreenMobileState();
}

class _PlayingScreenMobileState extends State<PlayingScreenMobile> {
  final ValueNotifier<bool> showLyric = ValueNotifier(false);

  Widget _mainPlayingWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        MusicCoverOrLyric(
          showLyric: showLyric,
          fillColor: context.colorScheme.secondaryContainer,
        ),
        const Column(
          children: [
            Row(
              children: [
                Expanded(child: PlayingScreenMobileTrackInfo()),
                FavoriteButton(),
              ],
            ),
            SizedBox(height: 32),
            PlayingScreenMobileControl(),
          ],
        )
      ],
    );
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Transform.rotate(
            angle: -math.pi / 2,
            child: const Icon(Icons.arrow_back_ios_new),
          ),
          onPressed: () {
            AnnixRouterDelegate.of(context).panelController.close();
          },
        ),
        backgroundColor: context.colorScheme.secondaryContainer,
        // title: const Text(''),
      ),
      body: Container(
        color: context.colorScheme.secondaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: _mainPlayingWidget(),
      ),
      bottomNavigationBar: BottomAppBar(
        color: context.colorScheme.secondaryContainer,
        elevation: 0,
        child: PlayingScreenMobileBottomBar(showLyrics: showLyric),
      ),
    );
  }
}
