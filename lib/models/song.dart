class Song {
  final String catalog;
  final String? discCatalog;
  final int trackId;

  Song({required this.catalog, required this.trackId, this.discCatalog});

  Song.fromJson(List<dynamic> json)
      : catalog = json[0],
        discCatalog = json[1],
        trackId = json[2];

  List<dynamic> toJson() => [catalog, discCatalog, trackId];
}
