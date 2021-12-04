import 'package:annix/metadata/metadata_source.dart';
import 'package:annix/services/annil.dart';
import 'package:annix/services/audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:stash_memory/stash_memory.dart';

class Global {
  static late SharedPreferences _preferences;
  static final cacheStore = newMemoryStore();

  static late AnnilClient annil;
  static late AnniAudioService audioService = AnniAudioService();

  static late BaseMetadataSource metadataSource;
  static late List<String> catalogs;

  static bool get needSetup => !(_preferences.getBool("initialized") ?? false);

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();

    annil = AnnilClient(
      // TODO: let user input annil config
      baseUrl: 'http://localhost:3614',
      authorization:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjAsInR5cGUiOiJ1c2VyIiwidXNlcm5hbWUiOiJ0ZXN0IiwiYWxsb3dTaGFyZSI6dHJ1ZX0.7CH27OBvUnJhKxBdtZbJSXA-JIwQ4MWqI5JsZ46NoKk',
    );
    catalogs = await annil.getAlbums();

    // Database
    sqfliteFfiInit();
  }
}
