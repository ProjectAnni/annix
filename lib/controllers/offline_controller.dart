import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class NetworkController extends GetxController {
  RxBool isMobile = false.obs;
  RxBool isOnline = false.obs;

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription _streamSubscription;
  Future<void> init() async {
    try {
      final connectivityResult = await (_connectivity.checkConnectivity());
      _updateState(connectivityResult);

      _streamSubscription =
          _connectivity.onConnectivityChanged.listen(_updateState);
    } on PlatformException catch (e) {
      print(e);
    }
  }

  void _updateState(ConnectivityResult result) {
    switch (result) {
      // wireless or wired
      case ConnectivityResult.wifi:
      case ConnectivityResult.ethernet:
        isOnline.value = true;
        isMobile.value = false;
        break;
      // mobile network, need to save traffic
      case ConnectivityResult.mobile:
        isOnline.value = true;
        isMobile.value = true;
        break;
      // no network
      case ConnectivityResult.none:
      // bluetooth connection is slow, treat as no network
      case ConnectivityResult.bluetooth:
        isOnline.value = false;
        isMobile.value = false;
        break;
    }
  }

  @override
  void onClose() {
    _streamSubscription.cancel();
    super.onClose();
  }
}
