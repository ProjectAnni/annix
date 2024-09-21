import 'package:annix/ui/page/playing/playing_mobile_widgets.dart';
import 'package:annix/ui/widgets/buttons/favorite_button.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PlayingScreenMobile extends HookConsumerWidget {
  const PlayingScreenMobile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showLyric = useState(false);

    return Scaffold(
      body: Container(
        color: context.colorScheme.secondaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: SafeArea(
          top: true,
          left: false,
          right: false,
          bottom: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              MusicCoverOrLyric(showLyric: showLyric),
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
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: context.colorScheme.secondaryContainer,
        child: PlayingScreenMobileBottomBar(showLyrics: showLyric),
      ),
    );
  }
}
