import 'package:annix/ui/widgets/shimmer/shimmer_text.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerTrackListTile extends StatelessWidget {
  final Widget cover;

  const ShimmerTrackListTile({
    super.key,
    required this.cover,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.colorScheme.surfaceContainer,
      highlightColor: context.colorScheme.surfaceContainerHigh,
      child: ListTile(
        leading: cover,
        title: const ShimmerText(length: 8),
        subtitle: const ShimmerText(length: 20),
      ),
    );
  }
}
