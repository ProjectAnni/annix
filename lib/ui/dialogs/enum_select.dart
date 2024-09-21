import 'package:flutter/material.dart';

Future<T> showEnumSelectDialog<T extends Enum>(final BuildContext context,
    final Map<T, Widget> widgets, final T defaultValue) async {
  T result = defaultValue;

  final child = ListView.builder(
    shrinkWrap: true,
    itemBuilder: (final context, final index) => RadioListTile<T>(
      title: widgets.values.elementAt(index),
      value: widgets.keys.elementAt(index),
      groupValue: result,
      onChanged: (final value) {
        result = value ?? result;
        Navigator.of(context).pop();
      },
    ),
    itemCount: widgets.length,
  );

  await showDialog(
    context: context,
    builder: (final context) {
      return Center(
        child: Card(child: child),
      );
    },
  );

  return result;
}
