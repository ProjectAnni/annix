import 'dart:io';

import 'package:flutter/services.dart';

class FontService {
  static int _fontId = 0;

  static Future<String?> load(final String? path) async {
    if (path == null) {
      _fontId = 0;
      return null;
    }

    try {
      final data = await File(path).readAsBytes();

      _fontId++;
      final familyName = getFontFamilyName()!;
      final loader = FontLoader(familyName);
      loader.addFont(Future.value(data.buffer.asByteData()));
      await loader.load();
      return familyName;
    } catch (e) {
      return null;
    }
  }

  static String? getFontFamilyName() {
    if (_fontId == 0) {
      return null;
    } else {
      return 'font_$_fontId';
    }
  }
}
