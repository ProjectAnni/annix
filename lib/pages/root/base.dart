import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:annix/utils/context_extension.dart';

class BaseAppBar extends StatelessWidget {
  final Widget title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  const BaseAppBar({Key? key, required this.title, this.actions, this.bottom})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // if (Global.isDesktop) {
    //   return Container();
    // }

    return AppBar(
      title: title,
      centerTitle: true,
      automaticallyImplyLeading: false,
      actions: actions,
      bottom: bottom,
    );
  }
}

class BaseSliverAppBar extends StatelessWidget {
  final Widget title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  const BaseSliverAppBar(
      {Key? key, required this.title, this.actions, this.bottom})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: title,
      primary: false,
      snap: true,
      floating: true,
      centerTitle: true,
      automaticallyImplyLeading: false,
      actions: actions,
      bottom: bottom,
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
    return Container(
      color: context.theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          Container(
            height: MediaQuery.of(context).padding.top,
            color: context.isDarkMode
                ? context.colorScheme.surface
                : context.colorScheme.onPrimary,
          ),
          Expanded(
            flex: 1,
            child: NestedScrollView(
              headerSliverBuilder: headerSliverBuilder,
              body: body,
            ),
          ),
        ],
      ),
    );
  }
}
