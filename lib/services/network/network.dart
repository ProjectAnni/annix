import 'package:annix/global.dart';
import 'package:annix/providers.dart';
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

  void _updateState(final ConnectivityResult result) {
    switch (result) {
      // wireless or wired
      case ConnectivityResult.wifi:
      case ConnectivityResult.ethernet:
        isConnected = true;
        isMobileNetwork = false;
        break;
      // mobile network, need to save traffic
      case ConnectivityResult.mobile:
      case ConnectivityResult.bluetooth:
        isConnected = true;
        isMobileNetwork = true;
        break;
      default:
        // no network or vpn
        if (Global.isApple || result == ConnectivityResult.vpn) {
          // on apple devices, VPN connection may result in ConnectivityResult.none
          // so add an polyfill to check internet accessibility
          // https://github.com/fluttercommunity/plus_plugins/issues/857
          _canVisitInternet().then((final value) {
            // keep `isMobileNetwork` property and set isConnected
            isConnected = value;
            notifyListeners();
          });
          // early return, do not notify listeners here
          return;
        }

        // not vpn, ConnectivityResult.none
        isConnected = false;
        isMobileNetwork = false;
        break;
    }
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
