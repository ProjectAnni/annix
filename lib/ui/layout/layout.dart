import 'package:annix/services/global.dart';
import 'package:annix/ui/layout/layout_desktop.dart';
import 'package:annix/ui/layout/layout_mobile.dart';
import 'package:flutter/material.dart';

abstract class AnnixLayout extends StatelessWidget {
  const AnnixLayout({super.key});

  factory AnnixLayout.build() {
    if (Global.isDesktop) {
      return AnnixLayoutDesktop();
    } else {
      return AnnixLayoutMobile();
    }
  }
}
