import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
            : context.theme.colorScheme.primary,
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
