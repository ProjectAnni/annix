import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/ui/widgets/shimmer/shimmer_text.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerAlbumGrid extends StatelessWidget {
  final String albumId;
  const ShimmerAlbumGrid({super.key, required this.albumId});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.colorScheme.surfaceContainer,
      highlightColor: context.colorScheme.surfaceContainerHigh,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CoverCard(child: DummyMusicCover()),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 26,
                  child: ShimmerText(length: 8),
                ),
                SizedBox(
                  height: 17,
                  child: ShimmerText(length: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ShimmerAlbumStackGrid extends StatelessWidget {
  const ShimmerAlbumStackGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.colorScheme.surfaceContainer,
      highlightColor: context.colorScheme.surfaceContainerHigh,
      child: const CoverCard(child: DummyMusicCover()),
    );
  }
}
