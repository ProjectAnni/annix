import 'package:flutter/material.dart';

class IconCard extends StatelessWidget {
  final Icon icon;
  final Widget child;
  final double gap;
  final void Function()? onTap;

  const IconCard({
    Key? key,
    required this.icon,
    required this.child,
    this.gap = 16,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final card = Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(gap),
            child: icon,
          ),
          child,
        ],
      ),
    );
    if (onTap == null) {
      return card;
    } else {
      return InkWell(
        onTap: onTap!,
        child: card,
      );
    }
  }
}
