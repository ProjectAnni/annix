import 'dart:async';

import 'package:flutter/material.dart';

class Debouncer<Args> {
  final int milliseconds;
  final VoidCallback action;

  Timer? _timer;

  Debouncer({required this.milliseconds, required this.action});

  run() {
    if (_timer?.isActive == true) {
      return;
    }

    _timer = Timer(Duration(milliseconds: milliseconds), () {
      _timer = null;
      action();
    });
  }
}
