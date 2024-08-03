import 'package:annix/ui/widgets/buttons/play_shuffle_button_group.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/ui/widgets/shimmer/shimmer_text.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerPlaylistPage extends StatelessWidget {
  const ShimmerPlaylistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final shimmerCover = Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: context.colorScheme.outline,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(24)),
      ),
      clipBehavior: Clip.hardEdge,
      child: const DummyMusicCover(),
    );
    return Scaffold(
      appBar: AppBar(),
      body: Shimmer.fromColors(
        baseColor: context.colorScheme.surfaceContainer,
        highlightColor: context.colorScheme.surfaceContainerHigh,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: CustomScrollView(
            slivers: [
              if (context.isMobileOrPortrait)
                SliverToBoxAdapter(
                  child: LayoutBuilder(
                    builder: (final context, final constraints) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: constraints.maxWidth / 6,
                        ),
                        child: shimmerCover,
                      );
                    },
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (context.isMobileOrPortrait)
                        CircleAvatar(child: shimmerCover),
                      if (context.isDesktopOrLandscape)
                        SizedBox(
                          height: 240,
                          child: shimmerCover,
                        ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShimmerText(length: 8),
                            ShimmerText(length: 16),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: PlayShuffleButtonGroup(
                  stretch: context.isMobileOrPortrait,
                  onPlay: () {},
                  onShufflePlay: () {},
                ),
              ),
              SliverList.list(
                children: const [
                  ShimmerPlaylistListItem(),
                  ShimmerPlaylistListItem(),
                  ShimmerPlaylistListItem(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ShimmerPlaylistListItem extends StatelessWidget {
  const ShimmerPlaylistListItem({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      isThreeLine: false,
      contentPadding: EdgeInsets.zero,
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            alignment: Alignment.center,
            child: const ShimmerText(length: 1),
          ),
          const SizedBox(width: 8),
          const CoverCard(
            child: DummyMusicCover(),
          ),
        ],
      ),
      title: const ShimmerText(length: 1),
      subtitle: const ShimmerText(length: 16),
      trailing: const ShimmerText(length: 1, height: 32),
    );
  }
}
