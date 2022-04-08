import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BaseAppBar extends StatelessWidget {
  final Widget title;

  const BaseAppBar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title,
      centerTitle: true,
      backgroundColor: context.isDarkMode
          ? context.theme.colorScheme.surface
          : context.theme.colorScheme.onPrimary,
      foregroundColor: context.theme.colorScheme.onSurface,
    );
  }
}

class BaseSliverAppBar extends StatelessWidget {
  final Widget title;

  const BaseSliverAppBar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: title,
      primary: false,
      snap: true,
      floating: true,
      centerTitle: true,
      backgroundColor: context.isDarkMode
          ? context.theme.colorScheme.surface
          : context.theme.colorScheme.onPrimary,
      foregroundColor: context.theme.colorScheme.onSurface,
      // forceElevated: true,
    );
  }
}

class BaseView extends StatelessWidget {
  final NestedScrollViewHeaderSliversBuilder headerSliverBuilder;
  final Widget body;

  const BaseView(
      {Key? key, required this.headerSliverBuilder, required this.body})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        height: MediaQuery.of(context).padding.top,
        color: context.isDarkMode
            ? context.theme.colorScheme.surface
            : context.theme.colorScheme.onPrimary,
      ),
      Expanded(
        flex: 1,
        child: NestedScrollView(
          headerSliverBuilder: headerSliverBuilder,
          body: body,
        ),
      ),
    ]);
  }
}
