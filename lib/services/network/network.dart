import 'package:annix/providers.dart';
import 'package:annix/native/api/network.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class NetworkService extends ChangeNotifier {
  final Ref ref;

  bool isMobileNetwork = false;
  bool isConnected = true;

  final Connectivity _connectivity = Connectivity();
  final Dio _client = Dio();

  NetworkService(this.ref) {
    _connectivity.onConnectivityChanged.listen(_updateState);
    _connectivity.checkConnectivity().then(_updateState);
    ref.read(settingsProvider).useMobileNetwork.addListener(notifyListeners);
  }

  void _updateState(final List<ConnectivityResult> connectivityResult) {
    if (connectivityResult.contains(ConnectivityResult.mobile)) {
      // Mobile network available.
      isConnected = true;
      isMobileNetwork = true;
    } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
      // Wi-fi is available.
      // Note for Android:
      // When both mobile and Wi-Fi are turned on system will return Wi-Fi only as active network type
      isConnected = true;
      isMobileNetwork = false;
    } else if (connectivityResult.contains(ConnectivityResult.ethernet)) {
      // Ethernet connection available.
      isConnected = true;
      isMobileNetwork = false;
    } else if (connectivityResult.contains(ConnectivityResult.bluetooth)) {
      // Bluetooth connection available.
      isConnected = true;
      isMobileNetwork = true;
    } else if (connectivityResult.contains(ConnectivityResult.vpn) ||
        connectivityResult.contains(ConnectivityResult.other)) {
      // Vpn connection active.
      // Note for iOS and macOS:
      // There is no separate network interface type for [vpn].
      // It returns [other] on any device (also simulator)
      // Connected to a network which is not in the above mentioned networks.
      _canVisitInternet().then((final value) {
        // keep `isMobileNetwork` property and set isConnected
        isMobileNetwork = false;
        isConnected = value;
        updateAndNotify();
      });
      // early return, do not notify listeners here
      return;
    } else if (connectivityResult.contains(ConnectivityResult.none)) {
      // No available network types
      isConnected = false;
      isMobileNetwork = false;
    }

    updateAndNotify();
  }

  /// Update network status both in NetworkService and
  void updateAndNotify() {
    updateNetworkStatus(isOnline: isOnline);
    notifyListeners();
  }

  Future<bool> _canVisitInternet() async {
    try {
      // Check network connection
      // We used `InternetAddress.lookup` before, but it could be influenced by fakeip
      final response =
          await _client.getUri(Uri.parse('http://g.cn/generate_204'));
      if (response.statusCode == 204) {
        return true;
      }
    } catch (_) {}
    return false;
  }

  bool get isOnline {
    return isConnected &&
        (!isMobileNetwork || ref.read(settingsProvider).useMobileNetwork.value);
  }
}
