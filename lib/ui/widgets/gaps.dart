import 'package:flutter/material.dart';

class Gap extends StatelessWidget {
  final double size;

  const Gap({super.key, this.size = 24.0});
  const Gap.betweenSections({super.key}) : size = 24.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: size);
  }
}

class SliverGap extends StatelessWidget {
  final double size;

  const SliverGap({super.key, this.size = 24.0});

  /// Below the first top widget in a sliver list.
  const SliverGap.belowTop({super.key}) : size = 16.0;
  const SliverGap.betweenSections({super.key}) : size = 16.0;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Gap(size: size),
    );
  }
}

class PagePadding extends StatelessWidget {
  final bool sliver;
  final double vertical;
  final double horizontal;
  final Widget child;

  const PagePadding({
    super.key,
    required this.child,
    this.sliver = false,
    this.vertical = 0,
    this.horizontal = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    final padding = EdgeInsets.symmetric(
      horizontal: horizontal,
      vertical: vertical,
    );

    if (sliver) {
      return SliverPadding(padding: padding, sliver: child);
    } else {
      return Padding(padding: padding, child: child);
    }
  }
}
