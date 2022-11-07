import 'package:flutter/material.dart';

Future<T> showEnumSelectDialog<T extends Enum>(
    BuildContext context, Map<T, Widget> widgets, T defaultValue) async {
  T result = defaultValue;

  final child = ListView.builder(
    shrinkWrap: true,
    itemBuilder: (context, index) => RadioListTile<T>(
      title: widgets.values.elementAt(index),
      value: widgets.keys.elementAt(index),
      groupValue: result,
      onChanged: (value) {
        result = value ?? result;
        Navigator.of(context).pop();
      },
    ),
    itemCount: widgets.length,
  );

  await showDialog(
    context: context,
    useRootNavigator: true,
    builder: (context) {
      return Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: child,
          ),
        ),
      );
    },
  );

  return result;
}
