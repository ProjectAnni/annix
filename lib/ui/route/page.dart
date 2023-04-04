import 'package:animations/animations.dart';
import 'package:annix/ui/route/route.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';

typedef AnnixRoutePageBuilder = Widget Function(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
);

Widget fadeThroughTransitionBuilder(
  final BuildContext context,
  final Animation<double> animation,
  final Animation<double> secondaryAnimation,
  final Widget child,
) {
  return FadeThroughTransition(
    animation: animation,
    secondaryAnimation: secondaryAnimation,
    child: child,
  );
}

Widget fadeTransitionBuilder(
  final BuildContext context,
  final Animation<double> animation,
  final Animation<double> secondaryAnimation,
  final Widget child,
) {
  return FadeTransition(
    opacity: animation,
    child: child,
  );
}

class AnnixPage extends Page {
  final bool disableAppBarDismissal;
  final Widget child;
  final AnnixRoutePageBuilder? pageBuilder;
  final Duration? transitionDuration;

  const AnnixPage({
    this.disableAppBarDismissal = false,
    required this.child,
    super.key,
    super.name,
    super.arguments,
    this.pageBuilder,
    this.transitionDuration,
  });

  @override
  Route createRoute(final BuildContext context) {
    return AnnixRoute(
      disableAppBarDismissal: disableAppBarDismissal,
      settings: this,
      transitionDuration:
          transitionDuration ?? const Duration(milliseconds: 300),
      pageBuilder: (final context, final animation, final secondaryAnimation) {
        return (pageBuilder ??
            (context.isDesktopOrLandscape
                ? fadeTransitionBuilder
                : fadeThroughTransitionBuilder))(
          context,
          animation,
          secondaryAnimation,
          child,
        );
      },
    );
  }
}
