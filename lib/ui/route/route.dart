import 'package:flutter/material.dart';

class AnnixRoute extends PageRouteBuilder {
  final bool disableAppBarDismissal;

  AnnixRoute({
    this.disableAppBarDismissal = false,
    super.settings,
    super.transitionDuration,
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
}
