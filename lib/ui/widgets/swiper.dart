import 'package:annix/providers.dart';
import 'package:annix/ui/page/album.dart';
import 'package:annix/ui/widgets/artist_text.dart';
import 'package:annix/ui/widgets/shimmer/shimmer_text.dart';
import 'package:annix/ui/widgets/slide_up.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HarderScrollPhysics extends ScrollPhysics {
  const HarderScrollPhysics({super.parent});

  @override
  HarderScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return HarderScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    return offset * 0.7;
  }
}

class PlayingTrackSwiper extends HookConsumerWidget {
  const PlayingTrackSwiper({super.key});

  @override
  Widget build(BuildContext context, final ref) {
    final player = ref.watch(playbackProvider);
    final queue = player.queue;
    final playingIndex = player.playingIndex;
    final controller = usePageController(initialPage: playingIndex ?? 0);

    useEffect(() {
      if (playingIndex != null && controller.hasClients) {
        controller.animateToPage(
          playingIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
      return null;
    }, [queue, playingIndex]);

    return HorizontalScrollableWidget(
      child: PageView.builder(
        // if we need to add option to disable swipe
        // physics: const NeverScrollableScrollPhysics(),
        physics: const HarderScrollPhysics(),
        controller: controller,
        onPageChanged: (index) {
          // if (playingIndex != null && index != playingIndex) {
          //   WidgetsBinding.instance.addPostFrameCallback((final _) {
          //     player.jump(index);
          //   });
          // }
        },
        itemCount: queue.length,
        itemBuilder: (_, index) {
          return Consumer(
            builder: (context, ref, child) {
              final track = ref.watch(trackFamily(queue[index].identifier));

              return track.when(
                data: (track) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title,
                      style: context.textTheme.titleSmall,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                    ArtistText(
                      track.artist,
                      style: context.textTheme.bodySmall,
                    ),
                  ],
                ),
                error: (error, stacktrace) => const Text('Error'),
                loading: () => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerText(length: 8),
                    ShimmerText(length: 20),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
