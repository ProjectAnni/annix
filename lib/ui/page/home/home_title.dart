import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';

class HomeTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool sliver;
  final EdgeInsets? padding;

  const HomeTitle({
    required this.icon,
    required this.title,
    this.sliver = false,
    this.padding,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = Row(
      children: [
        Icon(icon, size: 28),
        const SizedBox(width: 8),
        Text(
          title,
          style: context.textTheme.headline5,
        ),
      ],
    );

    if (padding != null) {
      child = Padding(
        padding: padding!,
        child: child,
      );
    }

    if (sliver) {
      child = SliverToBoxAdapter(child: child);
    }

    return child;
  }
}
