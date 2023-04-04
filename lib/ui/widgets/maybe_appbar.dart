import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';

PreferredSizeWidget? maybeAppBar(
    final BuildContext context, final PreferredSizeWidget? appBar) {
  if (context.isDesktopOrLandscape) {
    return null;
  } else {
    return appBar;
  }
}
