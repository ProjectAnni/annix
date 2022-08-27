import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class NetworkService extends ChangeNotifier {
  static bool isMobile = false;
  static bool isOnline = false;

  final Connectivity _connectivity = Connectivity();

  NetworkService() {
    _connectivity.onConnectivityChanged.listen(_updateState);
    _connectivity.checkConnectivity().then(_updateState);
  }

  void _updateState(ConnectivityResult result) {
    // switch (result) {
    //   // wireless or wired
    //   case ConnectivityResult.wifi:
    //   case ConnectivityResult.ethernet:
    //     isOnline = true;
    //     isMobile = false;
    //     break;
    //   // mobile network, need to save traffic
    //   case ConnectivityResult.mobile:
    //     isOnline = true;
    //     isMobile = true;
    //     break;
    //   // no network
    //   case ConnectivityResult.none:
    //   // bluetooth connection is slow, treat as no network
    //   case ConnectivityResult.bluetooth:
    //     isOnline = false;
    //     isMobile = false;
    //     break;
    // }
    // notifyListeners();
  }
}
