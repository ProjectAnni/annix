import 'package:flutter/material.dart';

extension AnnixContextExtension on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}
