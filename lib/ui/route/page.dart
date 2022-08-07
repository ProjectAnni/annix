import 'package:annix/services/global.dart';
import 'package:flutter/material.dart';

class AnnixPage extends Page {
  final Widget child;

  AnnixPage({
    required this.child,
    super.key,
    super.name,
    super.arguments,
  });

  @override
  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
      settings: this,
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        Global.context = context;

        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }
}
