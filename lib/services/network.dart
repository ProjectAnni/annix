import 'dart:io';

import 'package:annix/global.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class NetworkService extends ChangeNotifier {
  static bool isMobile = false;
  static bool isOnline = true;

  final Connectivity _connectivity = Connectivity();

  NetworkService() {
    _connectivity.onConnectivityChanged.listen(_updateState);
    _connectivity.checkConnectivity().then(_updateState);
  }

  void _updateState(ConnectivityResult result) {
    switch (result) {
    // wireless or wired
      case ConnectivityResult.wifi:
      case ConnectivityResult.ethernet:
        isOnline = true;
        isMobile = false;
        break;
      // mobile network, need to save traffic
      case ConnectivityResult.mobile:
      case ConnectivityResult.bluetooth:
        isOnline = true;
        isMobile = true;
        break;
      default:
        // no network
        isOnline = false;
        isMobile = false;

        if (Global.isApple) {
          // on apple devices, VPN connection may result in ConnectivityResult.none
          // so add an polyfill to check internet accessibility
          // https://github.com/fluttercommunity/plus_plugins/issues/857
          _canVisitInternet().then((value) {
            if (value) {
              isOnline = value;
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
}
