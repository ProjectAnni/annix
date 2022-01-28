import 'package:annix/metadata/metadata_source.dart';
import 'package:annix/metadata/metadata_source_anniv.dart';
import 'package:annix/services/annil.dart';
import 'package:annix/services/anniv.dart';
import 'package:annix/services/audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_memory/stash_memory.dart';

class Global {
  static late SharedPreferences preferences;
  static final cacheStore = newMemoryStore();

  static AnniAudioService audioService = AnniAudioService();
  static AnnivClient? anniv;
  static late CombinedAnnilClient annil;

  static BaseMetadataSource? metadataSource;

  // TODO: offline mode
  static bool get needSetup => anniv == null || metadataSource == null;

  static Map<String, Duration?> durations = new Map();

  static Future<void> init() async {
    preferences = await SharedPreferences.getInstance();
    annil = await CombinedAnnilClient.load();
    anniv = await AnnivClient.load();

    if (metadataSource == null && anniv != null) {
      metadataSource = AnnivMetadataSource(anniv: anniv!);
    }
  }
}
