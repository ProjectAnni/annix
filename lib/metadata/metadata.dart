class ReleaseDate {
  // TODO: release date
}

enum TrackType { Normal, Instrumental, Absoltue, Drama, Radio, Vocal }

class Album {
  final String title;
  final String edition;
  final String catalog;
  final String artist;
  final TrackType type;
  final ReleaseDate date;
  final List<String> tags;

  Album({
    required this.title,
    required this.edition,
    required this.catalog,
    required this.artist,
    required this.type,
    required this.date,
    required this.tags,
  });
}

class Disc {
  final Album album;
  final String? title;
  final String catalog;
  final String? artist;
  final TrackType? type;
  final List<String> tags;

  Disc({
    required this.album,
    this.title,
    required this.catalog,
    this.artist,
    this.type,
    this.tags = const [],
  });
}

class Track {
  final Disc disc;
  final String title;
  final String? artist;
  final TrackType? type;
  final List<String> tags;

  Track({
    required this.disc,
    required this.title,
    this.artist,
    this.type,
    this.tags = const [],
  });
}
