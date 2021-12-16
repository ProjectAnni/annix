import 'package:annix/metadata/metadata_source.dart';
import 'package:annix/services/annil.dart';
import 'package:annix/services/anniv.dart';
import 'package:annix/services/audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_memory/stash_memory.dart';

class Global {
  static late SharedPreferences preferences;
  static final cacheStore = newMemoryStore();

  static late AnnilClient annil;
  static late AnniAudioService audioService = AnniAudioService();
  static AnnivClient? anniv;

  static late BaseMetadataSource metadataSource;
  static late List<String> albumIds;

  static bool get needSetup =>
      !(preferences.getBool("initialized") ?? false) || anniv == null;

  static Map<String, Duration?> durations = new Map();

  static Future<void> init() async {
    preferences = await SharedPreferences.getInstance();

    annil = AnnilClient(
      // TODO: let user input annil config
      baseUrl: 'http://localhost:3614',
      authorization:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjAsInR5cGUiOiJ1c2VyIiwidXNlcm5hbWUiOiJ0ZXN0IiwiYWxsb3dTaGFyZSI6dHJ1ZX0.7CH27OBvUnJhKxBdtZbJSXA-JIwQ4MWqI5JsZ46NoKk',
    );
    albumIds = await annil.getAlbums();
  }
}
