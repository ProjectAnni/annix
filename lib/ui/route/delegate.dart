import 'package:annix/ui/widgets/slide_up.dart';
import 'package:flutter/material.dart';

class AnnixRouterDelegate {
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
    }
  }

  void closePanel() {
    if (isPanelOpen) {
      _panelController.close();
    }
  }

  AnnixRouterDelegate();
}

class PlayerRouteObserver extends NavigatorObserver {
  final AnnixRouterDelegate delegate;

  PlayerRouteObserver(this.delegate);

  @override
  didPop(final Route<dynamic> route, final Route<dynamic>? previousRoute) {
    if (['/player'].contains(route.settings.name)) {
      delegate.closePanel();
    }
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    if (!['/player'].contains(route.settings.name)) {
      delegate.closePanel();
    }

    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    if (!['/player'].contains(newRoute?.settings.name)) {
      delegate.closePanel();
    }

    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}
