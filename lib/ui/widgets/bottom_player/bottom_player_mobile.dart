import 'package:annix/services/global.dart';
import 'package:annix/services/player.dart';
import 'package:annix/ui/route/delegate.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/widgets/buttons/play_pause_button.dart';
import 'package:annix/third_party/marquee_widget/marquee_widget.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MobileBottomPlayer extends StatelessWidget {
  final double height;

  const MobileBottomPlayer({Key? key, this.height = 56}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AnnixRouterDelegate.of(Global.context).to(name: '/playing');
      },
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: ElevationOverlay.colorWithOverlay(
              context.colorScheme.surface, context.colorScheme.primary, 3.0),
        ),
        height: height,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: height,
              width: height,
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: PlayingMusicCover(card: false),
            ),
            Expanded(
              flex: 1,
              child: Consumer<PlayerService>(
                builder: (context, player, child) => Marquee(
                  child: Text(player.playing?.track.title ?? ""),
                ),
              ),
            ),
            const PlayPauseButton(),
          ],
        ),
      ),
    );
  }
}
