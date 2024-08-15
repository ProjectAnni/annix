import 'package:annix/services/annil/cache.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/services/metadata/metadata_model.dart';
import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';

void shareTrack(Track track, Rect? sharePositionOrigin) {
  final id = track.id;
  Share.shareXFiles(
    [XFile(getCoverCachePath(id.albumId))],
    text: '${track.title} - ${track.artist}\n#ProjectAnni #Annix',
    subject: 'Annix',
    sharePositionOrigin: sharePositionOrigin,
  );
}

void shareTrackInfo(TrackInfoWithAlbum track, Rect? sharePositionOrigin,
    {required bool nowPlaying}) {
  final id = track.id;
  Share.shareXFiles(
    [XFile(getCoverCachePath(id.albumId))],
    text:
        '${nowPlaying ? '#NowPlaying ' : ''}${track.title} - ${track.artist}\n#ProjectAnni #Annix',
    subject: nowPlaying ? 'Now Playing' : 'Annix',
    sharePositionOrigin: sharePositionOrigin,
  );
}

void shareTrackFile(TrackInfoWithAlbum track, Rect? sharePositionOrigin) {
  final id = track.id;
  Share.shareXFiles(
    [XFile(getAudioCachePath(id))],
    subject: 'Audio File',
    sharePositionOrigin: sharePositionOrigin,
  );
}
