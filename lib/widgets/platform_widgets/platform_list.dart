import 'package:annix/widgets/third_party/cupertino_list/list_section.dart';
import 'package:annix/widgets/third_party/cupertino_list/list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class PlatformListView extends StatelessWidget {
  final List<Widget> children;

  const PlatformListView({Key? key, required this.children}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      material: (context, _) => ListView(
        children: children,
      ),
      cupertino: (context, _) => CupertinoListSection(children: children),
    );
  }
}

class PlatformListTile extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;
  final Future<void> Function()? onTap;
  const PlatformListTile(
      {Key? key, required this.title, this.subtitle, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      material: (context, _) => ListTile(
        title: title,
        subtitle: subtitle,
        onTap: onTap,
      ),
      cupertino: (context, _) => CupertinoListTile(
        title: title,
        subtitle: subtitle,
        onTap: onTap,
      ),
    );
  }
}
