import 'dart:async';

import 'package:annix/services/metadata/metadata_model.dart';
import 'package:annix/ui/page/tag/tag_list.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';

Future<TagEntry?> showTagListDialog(BuildContext context) async {
  TagEntry? result;

  await showDialog(
    context: context,
    // if it's not desktop, we expect to show the dialog with the actual full screen
    useRootNavigator: !context.isDesktopOrLandscape,
    builder: (context) {
      return Dialog.fullscreen(
        child: Scaffold(
          appBar: AppBar(),
          body: TagList(
            onSelected: (tag) {
              result = tag;
              Navigator.of(context).pop();
            },
          ),
        ),
      );
    },
  );

  return result;
}
