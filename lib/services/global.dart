import 'package:annix/metadata/metadata_source.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class Global {
  static late SharedPreferences preferences;

  static BaseMetadataSource? metadataSource;

  static late String storageRoot;

  static Future<void> init() async {
    preferences = await SharedPreferences.getInstance();
    // FIXME: iOS
    storageRoot = (await getExternalStorageDirectory())!.path;
  }
}
