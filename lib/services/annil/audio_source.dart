import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/services/annil/annil.dart';
import 'package:annix/services/metadata/metadata.dart';

class AnnilAudioSource {
  final PreferQuality? quality;
  final TrackInfoWithAlbum track;

  TrackIdentifier get identifier => track.id;

  AnnilAudioSource({
    required this.track,
    this.quality,
  });

  static Future<AnnilAudioSource?> from({
    required final MetadataService metadata,
    required final TrackIdentifier id,
    final PreferQuality? quality,
  }) async {
    final track = await metadata.getTrack(id);
    if (track != null) {
      return AnnilAudioSource(
        quality: quality,
        track: TrackInfoWithAlbum.fromTrack(track),
      );
    }

    return null;
  }

  String get id => track.id.toString();

  bool preloaded = false;

  /////// Serialization ///////
  static AnnilAudioSource fromJson(final Map<String, dynamic> json) {
    return AnnilAudioSource(
      track: TrackInfoWithAlbum.fromJson(json['track']),
      quality: PreferQuality.fromString(json['quality']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'track': track.toJson(),
      'quality': quality.toString(),
    };
  }
}
