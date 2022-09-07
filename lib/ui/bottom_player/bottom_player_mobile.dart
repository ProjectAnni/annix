import 'package:annix/services/player.dart';
import 'package:annix/services/settings_controller.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/ui/widgets/buttons/play_pause_button.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ContextExtensionss;
import 'package:provider/provider.dart';

class MobileBottomPlayer extends StatelessWidget {
  final double height;

  const MobileBottomPlayer({Key? key, this.height = 60}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SettingsController settings = Get.find();

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        color: ElevationOverlay.colorWithOverlay(
            context.colorScheme.surface, context.colorScheme.primary, 3.0),
      ),
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            child: const PlayingMusicCover(card: true, animated: false),
          ),
          Expanded(
            flex: 1,
            child: Consumer<PlayerService>(
              builder: (context, player, child) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.playing?.track.title ?? "",
                    style: context.textTheme.titleSmall,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                  Obx(() {
                    if (settings.mobileShowArtistInBottomPlayer.value) {
                      return Text(
                        player.playing?.track.artist ?? "",
                        style: context.textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  }),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: PlayPauseButton.small(),
          ),
        ],
      ),
    );
  }
}
