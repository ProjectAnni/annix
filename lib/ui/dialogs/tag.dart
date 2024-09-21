import 'dart:async';

import 'package:annix/services/metadata/metadata_model.dart';
import 'package:annix/ui/page/tag/tag_list.dart';
import 'package:flutter/material.dart';

Future<TagEntry?> showTagListDialog(final BuildContext context) async {
  TagEntry? result;

  await showDialog(
    context: context,
    builder: (final context) {
      return Dialog.fullscreen(
        child: Scaffold(
          appBar: AppBar(),
          body: TagList(
            onSelected: (final ref, final tag) {
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
