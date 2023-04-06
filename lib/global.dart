import 'dart:async';
import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Global {
  static late SharedPreferences preferences;

  static Future<void> init() async {
    preferences = await SharedPreferences.getInstance();

    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      doWhenWindowReady(() {
        const initialSize = Size(1280, 800);
        appWindow.minSize = initialSize;
        appWindow.alignment = Alignment.center;
        appWindow.show();
      });
    }
  }
}
