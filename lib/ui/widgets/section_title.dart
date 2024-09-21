import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final bool sliver;

  const SectionTitle({
    super.key,
    required this.title,
    this.trailing,
    this.sliver = true,
  });

  @override
  Widget build(BuildContext context) {
    final child = Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: context.textTheme.titleLarge,
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
        const SizedBox(height: 8),
      ],
    );

    if (!sliver) {
      return child;
    } else {
      return SliverToBoxAdapter(
        child: child,
      );
    }
  }
}
