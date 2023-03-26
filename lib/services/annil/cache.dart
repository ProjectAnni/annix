import 'package:annix/global.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:path/path.dart' as p;

String getAudioCachePath(TrackIdentifier id) {
  return p.join(
    Global.storageRoot,
    'audio',
    id.albumId,
    /* extension is required on macOS for playback */
    "${id.discId}_${id.trackId}${Global.isApple ? ".flac" : ""}",
  );
}

String getAudioDurationPath(TrackIdentifier id) {
  return p.join(
    Global.storageRoot,
    'duration',
    id.albumId,
    '${id.discId}_${id.trackId}',
  );
}

String getCoverCachePath(String albumId, [int? discId]) {
  final fileName = "${discId == null ? albumId : "${albumId}_$discId"}.jpg";
  return p.join(Global.storageRoot, 'cover', fileName);
}
