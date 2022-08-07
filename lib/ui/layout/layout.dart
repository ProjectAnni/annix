import 'package:annix/services/global.dart';
import 'package:annix/ui/layout/layout_desktop.dart';
import 'package:annix/ui/layout/layout_mobile.dart';
import 'package:flutter/material.dart';

abstract class AnnixLayout extends StatelessWidget {
  const AnnixLayout({super.key});

  factory AnnixLayout.build({required Widget child}) {
    if (Global.isDesktop) {
      return AnnixLayoutDesktop(child: child);
    } else {
      return AnnixLayoutMobile(child: child);
    }
  }
}
