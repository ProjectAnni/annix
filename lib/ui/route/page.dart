import 'package:animations/animations.dart';
import 'package:annix/ui/route/route.dart';
import 'package:flutter/material.dart';

class AnnixPage extends Page {
  final bool disableAppBarDismissal;
  final Widget child;

  const AnnixPage({
    this.disableAppBarDismissal = false,
    required this.child,
    super.key,
    super.name,
    super.arguments,
  });

  @override
  Route createRoute(BuildContext context) {
    return AnnixRoute(
      disableAppBarDismissal: disableAppBarDismissal,
      settings: this,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return FadeThroughTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
    );
  }
}
