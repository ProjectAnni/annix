import 'package:toml/toml.dart';

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
      result += "-" + (month! < 10 ? '0$month' : '$month');
      if (day != null) {
        result += "-" + (day! < 10 ? '0$day' : '$day');
      }
    }
    return result;
  }
}

class Tag {
  final String name;
  final String? edition;

  Tag({required this.name, this.edition});

  static Tag fromDynamic(dynamic value) {
    if (value is String) {
      // name:edition
      var parts = value.split(":");
      return Tag(
        // TODO: check whether the split is accurate
        name: parts[0],
        edition: parts.length == 1 ? null : parts[1],
      );
    } else {
      // { name = "My Category", edition = "e1" }
      return Tag(
        name: value['name'],
        edition: value['edition'],
      );
    }
  }

  @override
  String toString() {
    return name + (edition == null ? "" : ":$edition");
  }
}

enum TrackType { Normal, Instrumental, Absoltue, Drama, Radio, Vocal, Unknown }

TrackType? stringToTrackType(String? value) {
  switch (value) {
    case null:
      return null;
    case "normal":
      return TrackType.Normal;
    case "instrumental":
      return TrackType.Instrumental;
    case "absolute":
      return TrackType.Absoltue;
    case "drama":
      return TrackType.Drama;
    case "radio":
      return TrackType.Radio;
    case "vocal":
      return TrackType.Vocal;
    default:
      return TrackType.Unknown;
  }
}

class Album {
  final String title;
  final String? edition;
  final String catalog;
  final String artist;
  final TrackType type;
  final ReleaseDate date;
  final List<Tag>? tags;
  final List<Disc> discs;

  Album({
    required this.title,
    this.edition,
    required this.catalog,
    required this.artist,
    required this.type,
    required this.date,
    this.tags,
    required this.discs,
  }) {
    this.discs.forEach((element) => element.album = this);
  }

  static Album fromMap(Map<String, dynamic> map) {
    String title = map['album']['title'];
    String? edition = map['album']['edition'];
    String catalog = map['album']['catalog'];
    String artist = map['album']['artist'];
    TrackType type = stringToTrackType(map['album']['type']!)!;
    ReleaseDate date = ReleaseDate.fromDynamic(map['album']['date']);
    List<Tag>? tags = (map['album']['tags'] as List<dynamic>?)
        ?.map((e) => Tag.fromDynamic(e))
        .toList();
    List<Disc> discs = (map['discs'] as List<dynamic>)
        .map((e) => Disc.fromMap(e as Map<String, dynamic>))
        .toList();
    return Album(
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
}

class Disc {
  late final Album album;
  final String? _title;
  final String catalog;
  final String? _artist;
  final TrackType? _type;
  final List<Tag>? tags;
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
    this.tracks.forEach((element) => element.disc = this);
  }

  String get title => _title ?? album.title;
  String get artist => _artist ?? album.artist;
  TrackType get type => _type ?? album.type;

  static Disc fromMap(Map<String, dynamic> map) {
    String? title = map['title'];
    String catalog = map['catalog'];
    String? artist = map['artist'];
    TrackType? type = stringToTrackType(map['type']);
    List<Tag>? tags = (map['tags'] as List<dynamic>?)
        ?.map((e) => Tag.fromDynamic(e))
        .toList();

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
}

class Track {
  late final Disc disc;
  final String title;
  final String? _artist;
  final TrackType? _type;
  final List<Tag>? tags;

  Track({
    required this.title,
    String? artist,
    TrackType? type,
    this.tags = const [],
  })  : _artist = artist,
        _type = type;

  String get artist => _artist ?? disc.artist;
  TrackType get type => _type ?? disc.type;

  static Track fromMap(Map<String, dynamic> map) {
    String title = map['title'];
    String artist = map['artist'];

    TrackType? type = stringToTrackType(map['type']);
    List<Tag>? tags = (map['tags'] as List<dynamic>?)
        ?.map((e) => Tag.fromDynamic(e))
        .toList();
    return Track(title: title, artist: artist, type: type, tags: tags);
  }
}
