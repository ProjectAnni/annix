class Song {
  final String catalog;
  final int trackId;

  Song({required this.catalog, required this.trackId});

  Song.fromJson(List<dynamic> json)
      : catalog = json[0],
        trackId = json[1];

  List<dynamic> toJson() => [catalog, trackId];
}
