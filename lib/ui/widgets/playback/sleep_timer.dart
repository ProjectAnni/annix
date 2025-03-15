import 'dart:async';

import 'package:annix/providers.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SleepTimerController extends ChangeNotifier {
  final Ref ref;
  Timer? _timer;

  bool get enabled => _timer != null && _timer!.isActive;

  SleepTimerController(this.ref);

  void setTimer(Duration duration) async {
    if (_timer != null) {
      _timer!.cancel();
    }

    _timer = Timer(duration, () {
      ref.read(playbackProvider).pause();
    });
    notifyListeners();
  }

  void cancel() async {
    if (_timer != null) {
      _timer!.cancel();
    }
    notifyListeners();
  }

  Future<void> toggle(BuildContext context) async {
    if (enabled) {
      cancel();
    } else {
      final duration = await _showSleepTimerDialog(context);
      if (duration != null) {
        setTimer(duration);
      }
    }
  }
}

Future<Duration?> _showSleepTimerDialog(BuildContext context) async {
  final until =
      await showTimePicker(context: context, initialTime: TimeOfDay.now());
  if (until == null) {
    return null;
  }

  final now = TimeOfDay.now();
  int nowMinute = now.hour * 60 + now.minute;
  final untilMinute = until.hour * 60 + until.minute;
  if (nowMinute > untilMinute) {
    nowMinute += 24 * 60;
  }
  final duration = Duration(minutes: untilMinute - nowMinute);
  return duration;
}
