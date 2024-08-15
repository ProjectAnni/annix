import 'package:flutter/material.dart';

Future<String?> showInputDialog(
    final BuildContext context, final String title, final String hint,
    [final String? initialValue]) async {
  final controller = TextEditingController(text: initialValue);

  return showDialog<String>(
    context: context,
    builder: (final context) {
      return AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: hint),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(controller.text);
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
