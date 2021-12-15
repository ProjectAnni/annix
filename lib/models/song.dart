class Song {
  final String albumId;
  final int discId;
  final int trackId;

  Song({required this.albumId, required this.discId, required this.trackId});

  Song.fromJson(List<dynamic> json)
      : albumId = json[0],
        discId = json[1],
        trackId = json[2];

  List<dynamic> toJson() => [albumId, discId, trackId];
}
