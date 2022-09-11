import 'package:annix/services/network/conversion_layer_adapter.dart';
import 'package:dio/dio.dart';
import 'package:http_plus/http_plus.dart';

HttpClientAdapter createHttpPlusAdapter([bool enableHttp2 = true]) {
  return ConversionLayerAdapter(HttpPlusClient(enableHttp2: enableHttp2));
}
