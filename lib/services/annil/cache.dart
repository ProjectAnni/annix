import 'package:annix/services/global.dart';
import 'package:path/path.dart' as p;

String getAudioCachePath(String albumId, int discId, int trackId) {
  return p.join(
    Global.storageRoot,
    'audio',
    albumId,
    /* extension is required on macOS for playback */
    "${discId}_$trackId${Global.isApple ? ".flac" : ""}",
  );
}

String getCoverCachePath(String albumId, int? discId) {
  final fileName = "${discId == null ? albumId : "${albumId}_$discId"}.jpg";
  return p.join(Global.storageRoot, "cover", fileName);
}
