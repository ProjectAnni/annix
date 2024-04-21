import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';

class AnnixRoute extends PageRouteBuilder {
  final bool disableAppBarDismissal;
  final PageTransitionsBuilder _applePageTransition =
      const CupertinoPageTransitionsBuilder();

  AnnixRoute({
    this.disableAppBarDismissal = false,
    super.settings,
    super.transitionDuration,
    super.reverseTransitionDuration,
    required super.pageBuilder,
  });

  @override
  bool get canPop {
    if (disableAppBarDismissal) {
      return false;
    } else {
      return super.canPop;
    }
  }

  @override
  bool get impliesAppBarDismissal {
    if (disableAppBarDismissal) {
      return false;
    } else {
      return super.canPop;
    }
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (context.isApple) {
      return _applePageTransition.buildTransitions(
          this, context, animation, secondaryAnimation, child);
    } else {
      return super
          .buildTransitions(context, animation, secondaryAnimation, child);
    }
  }
}
