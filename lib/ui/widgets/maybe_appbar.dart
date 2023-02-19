import 'package:annix/global.dart';
import 'package:flutter/material.dart';

PreferredSizeWidget? maybeAppBar(PreferredSizeWidget? appBar) {
  if (Global.isDesktop) {
    return null;
  } else {
    return appBar;
  }
}

class MaybeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MaybeAppBar({super.key, required this.appBar});
  final PreferredSizeWidget appBar;

  @override
  Widget build(BuildContext context) {
    if (Global.isDesktop) {
      return Container();
    } else {
      return appBar;
    }
  }

  @override
  Size get preferredSize => appBar.preferredSize;
}
