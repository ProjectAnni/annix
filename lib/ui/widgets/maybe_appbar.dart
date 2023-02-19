import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';

PreferredSizeWidget? maybeAppBar(
    BuildContext context, PreferredSizeWidget? appBar) {
  if (context.isDesktopOrLandscape) {
    return null;
  } else {
    return appBar;
  }
}
