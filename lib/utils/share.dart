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

void shareNowPlayingTrack(TrackInfoWithAlbum track, Rect? sharePositionOrigin) {
  final id = track.id;
  Share.shareXFiles(
    [XFile(getCoverCachePath(id.albumId))],
    text: '#NowPlaying ${track.title} - ${track.artist}',
    subject: 'Now Playing',
    sharePositionOrigin: sharePositionOrigin,
  );
}
