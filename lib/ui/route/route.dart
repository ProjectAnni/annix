import 'package:flutter/material.dart';

class AnnixRoute extends PageRouteBuilder {
  final bool disableAppBarDismissal;

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
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    final PageTransitionsTheme theme = Theme.of(context).pageTransitionsTheme;
    return theme.buildTransitions(
        this, context, animation, secondaryAnimation, child);
  }
}
