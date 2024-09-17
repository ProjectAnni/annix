import 'package:annix/ui/widgets/slide_up.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AnnixRouterDelegate with ChangeNotifier {
  final _panelController = PanelController();
  PanelController get panelController => _panelController;
  get isPanelOpen =>
      _panelController.isAttached &&
      (_panelController.isPanelOpen ||
          _panelController.isPanelAnimating ||
          _panelController.panelPosition > 0.9);
  get isPanelClosed => !isPanelOpen;

  void openPanel() {
    if (!_panelController.isPanelOpen) {
      _panelController.open();
      notifyListeners();
    }
  }

  void closePanel() {
    if (isPanelOpen) {
      _panelController.close();
      notifyListeners();
    }
  }

  final Ref ref;

  AnnixRouterDelegate(this.ref);
}
