import 'package:flutter/material.dart';

class DisplayOrLazyLoadScreen<T> extends StatelessWidget {
  final Widget Function(T) builder;
  final T? item;
  final Future<T>? future;

  const DisplayOrLazyLoadScreen({
    required this.builder,
    this.item,
    this.future,
    super.key,
  }) : assert((item != null) ^ (future != null));

  @override
  Widget build(final BuildContext context) {
    if (item != null) {
      return builder(item as T);
    } else {
      return FutureBuilder<T>(
        future: future,
        builder: (final context, final snapshot) {
          if (snapshot.hasData) {
            return builder(snapshot.data as T);
          } else if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          }
        },
      );
    }
  }
}
