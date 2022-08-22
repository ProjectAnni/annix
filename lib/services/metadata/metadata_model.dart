// ignore_for_file: constant_identifier_names

import 'package:annix/services/anniv/anniv_model.dart';
import 'package:toml/toml.dart';
import 'package:json_annotation/json_annotation.dart';

part 'metadata_model.g.dart';

@JsonSerializable(createFactory: false)
class ReleaseDate {
  final int year;
  final int? month;
  final int? day;

  ReleaseDate({required this.year, this.month, this.day});

  static ReleaseDate fromDynamic(dynamic value) {
    if (value is String) {
      // "yyyy-mm-dd"
      // "yyyy-mm"
      // "yyyy"
      var parts = value.split('-');
      return ReleaseDate(
        year: int.parse(parts[0]),
        month: parts.length > 1 ? int.parse(parts[1]) : null,
        day: parts.length > 2 ? int.parse(parts[2]) : null,
      );
    } else if (value is Map<String, dynamic>) {
      // { year = 2021, month = 6, day = 22 }
      return ReleaseDate(
        year: value['year'],
        month: value['month'],
        day: value['day'],
      );
    } else if (value is TomlLocalDate) {
      // yyyy-mm-dd
      return ReleaseDate(
        year: value.date.year,
        month: value.date.month,
        day: value.date.day,
      );
    } else {
      throw UnsupportedError("Unsupported release date format");
    }
  }

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

  static readValue(Map map, String key) => map[key] as dynamic;

  factory ReleaseDate.fromJson(dynamic json) => fromDynamic(json);

  Map<String, dynamic> toJson() => _$ReleaseDateToJson(this);
}

@JsonEnum(fieldRename: FieldRename.snake)
enum TrackType {
  Normal,
  Instrumental,
  Absolute,
  Drama,
  Radio,
  Vocal;

  factory TrackType.fromString(String value) {
    switch (value) {
      case "normal":
        return TrackType.Normal;
      case "instrumental":
        return TrackType.Instrumental;
      case "absolute":
        return TrackType.Absolute;
      case "drama":
        return TrackType.Drama;
      case "radio":
        return TrackType.Radio;
      case "vocal":
        return TrackType.Vocal;
      default:
        return TrackType.Normal;
    }
  }

  @override
  String toString() {
    switch (this) {
      case TrackType.Normal:
        return "normal";
      case TrackType.Instrumental:
        return "instrumental";
      case TrackType.Absolute:
        return "absolute";
      case TrackType.Drama:
        return "drama";
      case TrackType.Radio:
        return "radio";
      case TrackType.Vocal:
        return "vocal";
      default:
        return "unknown";
    }
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

  String get fullTitle => title + (edition != null ? "【$edition】" : "");

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

  static Album fromMap(Map<String, dynamic> map) {
    String albumId = map['album']['album_id'];
    String title = map['album']['title'];
    String? edition = map['album']['edition'];
    String catalog = map['album']['catalog'];
    String artist = map['album']['artist'];
    TrackType type = TrackType.fromString(map['album']['type']!);
    ReleaseDate date = ReleaseDate.fromDynamic(map['album']['date']);
    List<String>? tags = (map['album']['tags'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList();
    List<Disc> discs = (map['discs'] as List<dynamic>)
        .map((e) => Disc.fromMap(e as Map<String, dynamic>))
        .toList();
    return Album(
      albumId: albumId,
      title: title,
      edition: edition,
      catalog: catalog,
      artist: artist,
      type: type,
      date: date,
      tags: tags,
      discs: discs,
    );
  }

  factory Album.fromJson(Map<String, dynamic> json) => _$AlbumFromJson(json);

  Map<String, dynamic> toJson() => _$AlbumToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Disc {
  @JsonKey(ignore: true)
  late final Album album;

  final String? _title;
  final String catalog;
  final String? _artist;
  final TrackType? _type;
  final List<String>? tags;
  final List<Track> tracks;

  Disc({
    String? title,
    required this.catalog,
    String? artist,
    TrackType? type,
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

  static Disc fromMap(Map<String, dynamic> map) {
    String? title = map['title'];
    String catalog = map['catalog'];
    String? artist = map['artist'];
    TrackType? type = TrackType.fromString(map['type']);
    List<String>? tags =
        (map['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList();

    List<Track> tracks = (map['tracks'] as List<Map<String, dynamic>>)
        .map((e) => Track.fromMap(e))
        .toList();
    return Disc(
      title: title,
      catalog: catalog,
      artist: artist,
      type: type,
      tags: tags,
      tracks: tracks,
    );
  }

  factory Disc.fromJson(Map<String, dynamic> json) => _$DiscFromJson(json);

  Map<String, dynamic> toJson() => _$DiscToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Track {
  @JsonKey(ignore: true)
  late final Disc disc;

  final String title;
  final String? _artist;
  final TrackType? _type;
  final List<String>? tags;

  Track({
    required this.title,
    String? artist,
    TrackType? type,
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

  static Track fromMap(Map<String, dynamic> map) {
    String title = map['title'];
    String? artist = map['artist'];

    TrackType? type = TrackType.fromString(map['type']);
    List<String>? tags =
        (map['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList();
    return Track(title: title, artist: artist, type: type, tags: tags);
  }

  factory Track.fromJson(Map<String, dynamic> json) => _$TrackFromJson(json);

  Map<String, dynamic> toJson() => _$TrackToJson(this);
}

class TagEntry extends TagInfo {
  final List<String> children;

  TagEntry({required this.children, required super.name, required super.type});
}
