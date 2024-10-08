import 'package:flutter/material.dart';

void showLoadingDialog(final BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (final context) {
      return const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  strokeWidth: 2,
                ),
                SizedBox(width: 12),
                Text('Loading...'),
              ],
            ),
          ),
        ),
      );
    },
  );
}
