import 'dart:io';

import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/services/path.dart';
import 'package:path/path.dart' as p;

String getAudioCachePath(final TrackIdentifier id) {
  return p.join(
    audioCachePath(),
    id.albumId,
    /* extension is required on macOS for playback */
    "${id.discId}_${id.trackId}${Platform.isIOS || Platform.isMacOS ? ".flac" : ""}",
  );
}

String getCoverCachePath(final String albumId, [final int? discId]) {
  final fileName = "${discId == null ? albumId : "${albumId}_$discId"}.jpg";
  return p.join(coverCachePath(), fileName);
}
