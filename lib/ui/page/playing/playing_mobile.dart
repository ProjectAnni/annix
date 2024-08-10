import 'package:annix/providers.dart';
import 'package:annix/ui/page/playing/playing_mobile_widgets.dart';
import 'package:annix/ui/widgets/buttons/favorite_button.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'dart:math' as math;

import 'package:hooks_riverpod/hooks_riverpod.dart';

class PlayingScreenMobile extends HookConsumerWidget {
  const PlayingScreenMobile({super.key});

  Widget _mainPlayingWidget(
      BuildContext context, ValueNotifier<bool> showLyric) {
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
            SizedBox(height: 32),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showLyric = useState(false);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Transform.rotate(
            angle: -math.pi / 2,
            child: const Icon(Icons.arrow_back_ios_new),
          ),
          onPressed: () {
            ref.read(routerProvider).panelController.close();
          },
        ),
        backgroundColor: context.colorScheme.secondaryContainer,
        // title: const Text(''),
      ),
      body: Container(
        color: context.colorScheme.secondaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: _mainPlayingWidget(context, showLyric),
      ),
      bottomNavigationBar: BottomAppBar(
        color: context.colorScheme.secondaryContainer,
        elevation: 0,
        child: PlayingScreenMobileBottomBar(showLyrics: showLyric),
      ),
    );
  }
}
