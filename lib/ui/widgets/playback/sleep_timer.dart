import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SleepTimerController extends ChangeNotifier {
  final Ref ref;

  SleepTimerController(this.ref);
}
