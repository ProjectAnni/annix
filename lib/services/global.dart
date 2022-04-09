import 'package:annix/metadata/metadata_source.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_memory/stash_memory.dart';

class Global {
  static late SharedPreferences preferences;
  static final cacheStore = newMemoryCacheStore();

  static BaseMetadataSource? metadataSource;

  static Map<String, Duration?> durations = new Map();

  static Future<void> init() async {
    preferences = await SharedPreferences.getInstance();
  }
}
