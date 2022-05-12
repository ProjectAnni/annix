import 'package:annix/models/metadata.dart';
import 'package:annix/metadata/metadata_source.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class SqliteMetadataSource extends BaseMetadataSource {
  String dbPath;
  late Database database;

  SqliteMetadataSource({required this.dbPath});

  @override
  Future<void> prepare() async {
    database = await openDatabase(dbPath, readOnly: true);
  }

  @override
  Future<bool> canUpdate() async {
    return false;
  }

  @override
  Future<Album?> getAlbumDetail({required String albumId}) async {
    var albumUuid = Uuid.parse(albumId);
    List<Map<String, Object?>> discs = await database.rawQuery(
        "SELECT * FROM repo_disc WHERE album_id = ? ORDER BY disc_id",
        [albumUuid]);

    List<Disc> albumDiscs = await Future.wait(discs.map((disc) async {
      int discId = disc['disc_id'] as int;
      String discTitle = disc['title'] as String;
      String discArtist = disc['artist'] as String;
      String discCatalog = disc['catalog'] as String;
      TrackType discType =
          TrackTypeExtension.fromString(disc['disc_type'] as String);

      List<Map<String, Object?>> tracks = await database.rawQuery(
          "SELECT title, artist, track_type FROM repo_track WHERE album_id = ? AND disc_id = ? ORDER BY disc_id",
          [albumUuid, discId]);
      List<Track> discTracks = tracks.map((track) {
        String trackTitle = track['title'] as String;
        String trackArtist = track['artist'] as String;
        TrackType trackType =
            TrackTypeExtension.fromString(track['track_type'] as String);
        return Track(title: trackTitle, artist: trackArtist, type: trackType);
      }).toList();

      return Disc(
        title: discTitle,
        catalog: discCatalog,
        artist: discArtist,
        type: discType,
        tracks: discTracks,
      );
    }));
    List<Map<String, Object?>> album = await database.rawQuery(
        "SELECT * FROM repo_album WHERE album_id = ?", [Uuid.parse(albumId)]);
    if (album.isNotEmpty) {
      String title = album[0]['title'] as String;
      String? edition = album[0]['edition'] as String?;
      String catalog = album[0]['catalog'] as String;
      String artist = album[0]['artist'] as String;
      String releaseDate = album[0]['release_date'] as String;
      TrackType albumType =
          TrackTypeExtension.fromString(album[0]['album_type'] as String);

      return Album(
        albumId: albumId,
        title: title,
        edition: edition,
        artist: artist,
        catalog: catalog,
        date: ReleaseDate.fromDynamic(releaseDate),
        type: albumType,
        discs: albumDiscs,
      );
    } else {
      return null;
    }
  }

  @override
  bool get needPersist => false;
}
