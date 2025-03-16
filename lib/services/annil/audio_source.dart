import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/services/annil/annil.dart';

class AnnilAudioSource {
  final PreferQuality? quality;

  final TrackIdentifier identifier;

  AnnilAudioSource({
    required this.identifier,
    this.quality,
  });

  String get id => identifier.toString();

  bool preloaded = false;

  /////// Serialization ///////
  static AnnilAudioSource fromJson(final Map<String, dynamic> json) {
    return AnnilAudioSource(
      identifier: TrackIdentifier.fromJson(json['identifier']),
      quality: PreferQuality.fromString(json['quality']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'identifier': identifier.toJson(),
      'quality': quality.toString(),
    };
  }
}
