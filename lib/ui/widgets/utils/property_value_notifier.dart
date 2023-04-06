// https://github.com/flutter/flutter/issues/29958#issuecomment-707007360

import 'package:flutter/material.dart';

class PropertyValueNotifier<T> extends ValueNotifier<T> {
  PropertyValueNotifier(final T value) : super(value);

  void update(final void Function(T) callback) {
    callback(value);
    super.notifyListeners();
  }
}
