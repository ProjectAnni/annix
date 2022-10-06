import 'package:annix/ui/layout/layout_desktop.dart';
import 'package:annix/ui/layout/layout_mobile.dart';
import 'package:annix/ui/route/delegate.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';

abstract class AnnixLayout extends StatelessWidget {
  const AnnixLayout({super.key});

  factory AnnixLayout.build(
    BuildContext context, {
    required Widget child,
    required AnnixRouterDelegate router,
  }) {
    if (context.isDesktopOrLandscape) {
      return AnnixLayoutDesktop(
        router: router,
        child: child,
      );
    } else {
      return AnnixLayoutMobile(
        router: router,
        child: child,
      );
    }
  }
}
