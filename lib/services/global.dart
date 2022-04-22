import 'package:annix/metadata/metadata_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Global {
  static late SharedPreferences preferences;

  static BaseMetadataSource? metadataSource;

  static Map<String, Duration?> durations = new Map();

  static Future<void> init() async {
    preferences = await SharedPreferences.getInstance();
  }
}
