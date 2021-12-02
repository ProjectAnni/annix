import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart' as window_size;

class AnnilWindow {
  static late Rect _pos;

  static init() async {
    var window = await window_size.getWindowInfo();
    if (window.screen != null) {
      _pos = window.frame;
    }
  }

  static updatePositionDelta(Offset offset) async {
    _pos = Rect.fromLTWH(
      _pos.left + offset.dx,
      _pos.top + offset.dy,
      _pos.width,
      _pos.height,
    );
    window_size.setWindowFrame(_pos);
  }

  static updatePosition(Offset offset) async {
    print(offset);
    _pos = Rect.fromLTWH(
      offset.dx,
      offset.dy,
      _pos.width,
      _pos.height,
    );
    window_size.setWindowFrame(_pos);
  }
}
