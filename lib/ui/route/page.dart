import 'package:animations/animations.dart';
import 'package:annix/ui/route/route.dart';
import 'package:flutter/material.dart';

typedef AnnixRoutePageBuilder = Widget Function(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
);

Widget fadeThroughTransitionBuilder(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeThroughTransition(
    animation: animation,
    secondaryAnimation: secondaryAnimation,
    child: child,
  );
}

class AnnixPage extends Page {
  final bool disableAppBarDismissal;
  final Widget child;
  final AnnixRoutePageBuilder? pageBuilder;

  const AnnixPage({
    this.disableAppBarDismissal = false,
    required this.child,
    super.key,
    super.name,
    super.arguments,
    this.pageBuilder,
  });

  @override
  Route createRoute(BuildContext context) {
    return AnnixRoute(
      disableAppBarDismissal: disableAppBarDismissal,
      settings: this,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return (pageBuilder ?? fadeThroughTransitionBuilder)(
          context,
          animation,
          secondaryAnimation,
          child,
        );
      },
    );
  }
}
