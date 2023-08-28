import 'package:annix/services/annil/audio_source.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'metadata_model.g.dart';

@JsonSerializable(createFactory: false, createToJson: false)
class ReleaseDate {
  final int year;
  final int? month;
  final int? day;

  ReleaseDate({required this.year, this.month, this.day});

  @override
  String toString() {
    String result = year.toString();
    if (month != null) {
      result += "-${month! < 10 ? '0$month' : '$month'}";
      if (day != null) {
        result += "-${day! < 10 ? '0$day' : '$day'}";
      }
    }
    return result;
  }

  static readValue(final Map map, final String key) => map[key] as dynamic;

  factory ReleaseDate.fromJson(final String value) {
    // "yyyy-mm-dd"
    // "yyyy-mm"
    // "yyyy"
    final parts = value.split('-');
    return ReleaseDate(
      year: int.parse(parts[0]),
      month: parts.length > 1 ? int.parse(parts[1]) : null,
      day: parts.length > 2 ? int.parse(parts[2]) : null,
    );
  }

  String toJson() => toString();
}

@JsonEnum(fieldRename: FieldRename.snake)
enum TrackType {
  normal,
  instrumental,
  absolute,
  drama,
  radio,
  vocal;

  factory TrackType.fromString(final String value) {
    return $enumDecode(
      _$TrackTypeEnumMap,
      value,
      unknownValue: TrackType.normal,
    );
  }

  @override
  String toString() {
    return _$TrackTypeEnumMap[this]!;
  }
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Album {
  final String albumId;
  final String title;
  final String? edition;
  final String catalog;
  final String artist;
  final TrackType type;
  @JsonKey(readValue: ReleaseDate.readValue)
  final ReleaseDate date;
  final List<String>? tags;
  final List<Disc> discs;

  String get fullTitle => title + (edition != null ? '【$edition】' : '');

  Album({
    required this.albumId,
    required this.title,
    this.edition,
    required this.catalog,
    required this.artist,
    required this.type,
    required this.date,
    this.tags,
    required this.discs,
  }) {
    for (final disc in discs) {
      disc.album = this;
    }
  }

  factory Album.fromJson(final Map<String, dynamic> json) =>
      _$AlbumFromJson(json);

  Map<String, dynamic> toJson() => _$AlbumToJson(this);

  List<AnnilAudioSource> getTracks() {
    final List<AnnilAudioSource> sources = [];
    for (final disc in discs) {
      for (final track in disc.tracks) {
        sources
            .add(AnnilAudioSource(track: TrackInfoWithAlbum.fromTrack(track)));
      }
    }
    return sources;
  }
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Disc {
  @JsonKey(includeFromJson: false, includeToJson: false)
  late final Album album;

  final String? _title;
  final String catalog;
  final String? _artist;
  final TrackType? _type;
  final List<String>? tags;
  final List<Track> tracks;

  Disc({
    final String? title,
    required this.catalog,
    final String? artist,
    final TrackType? type,
    this.tags,
    required this.tracks,
  })  : _title = title,
        _artist = artist,
        _type = type {
    for (final track in tracks) {
      track.disc = this;
    }
  }

  String get title => _title ?? album.title;

  String get artist => _artist ?? album.artist;

  TrackType get type => _type ?? album.type;

  factory Disc.fromJson(final Map<String, dynamic> json) =>
      _$DiscFromJson(json);

  Map<String, dynamic> toJson() => _$DiscToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Track {
  @JsonKey(includeFromJson: false, includeToJson: false)
  late final Disc disc;

  final String title;
  final String? _artist;
  final TrackType? _type;
  final List<String>? tags;

  Track({
    required this.title,
    final String? artist,
    final TrackType? type,
    this.tags = const [],
  })  : _artist = artist,
        _type = type;

  String get artist => _artist ?? disc.artist;

  TrackType get type => _type ?? disc.type;

  TrackIdentifier get id => TrackIdentifier(
        albumId: disc.album.albumId,
        discId: disc.album.discs.indexOf(disc) + 1,
        trackId: disc.tracks.indexOf(this) + 1,
      );

  factory Track.fromJson(final Map<String, dynamic> json) =>
      _$TrackFromJson(json);

  Map<String, dynamic> toJson() => _$TrackToJson(this);
}

class TagEntry extends TagInfo {
  final List<String> children;

  TagEntry({required this.children, required super.name, required super.type});
}
