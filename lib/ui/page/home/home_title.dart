import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  });

  @override
  Widget build(BuildContext context) {
    Widget child = Row(
      children: [
        Icon(icon, size: 28),
        SizedBox(width: 8),
        Text(
          this.title,
          style: context.textTheme.headline5,
        ),
      ],
    );

    if (this.padding != null) {
      child = Padding(
        padding: this.padding!,
        child: child,
      );
    }

    if (this.sliver) {
      child = SliverToBoxAdapter(child: child);
    }

    return child;
  }
}
