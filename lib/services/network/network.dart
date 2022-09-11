import 'dart:io';

import 'package:annix/global.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class NetworkService extends ChangeNotifier {
  static bool isMobile = false;
  static bool isConnected = true;

  final Connectivity _connectivity = Connectivity();

  NetworkService() {
    _connectivity.onConnectivityChanged.listen(_updateState);
    _connectivity.checkConnectivity().then(_updateState);
    Global.settings.useMobileNetwork.addListener(notifyListeners);
  }

  void _updateState(ConnectivityResult result) {
    switch (result) {
      // wireless or wired
      case ConnectivityResult.wifi:
      case ConnectivityResult.ethernet:
        isConnected = true;
        isMobile = false;
        break;
      // mobile network, need to save traffic
      case ConnectivityResult.mobile:
      case ConnectivityResult.bluetooth:
        isConnected = true;
        isMobile = true;
        break;
      default:
        // no network
        isConnected = false;
        isMobile = false;

        if (Global.isApple) {
          // on apple devices, VPN connection may result in ConnectivityResult.none
          // so add an polyfill to check internet accessibility
          // https://github.com/fluttercommunity/plus_plugins/issues/857
          _canVisitInternet().then((value) {
            if (value) {
              isConnected = value;
              notifyListeners();
            }
          });
        }
        break;
    }
    notifyListeners();
  }

  Future<bool> _canVisitInternet() async {
    try {
      final result = await InternetAddress.lookup('anni.rs');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } catch (_) {}
    return false;
  }

  static bool get isOnline {
    return isConnected && (!isMobile || Global.settings.useMobileNetwork.value);
  }
}
