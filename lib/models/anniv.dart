import 'package:json_annotation/json_annotation.dart';

part 'anniv.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class SiteInfo {
  final String siteName;
  final String description;
  final String protocolVersion;
  final List<String> features;

  SiteInfo({
    required this.siteName,
    required this.description,
    required this.protocolVersion,
    required this.features,
  });

  factory SiteInfo.fromJson(Map<String, dynamic> json) =>
      _$SiteInfoFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class UserInfo {
  final String userId;
  final String email;
  final String nickname;
  final String avatar;

  UserInfo({
    required this.userId,
    required this.email,
    required this.nickname,
    required this.avatar,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) =>
      _$UserInfoFromJson(json);
}

@JsonSerializable()
class AnnilToken {
  final String id;
  final String name;
  final String url;
  final String token;
  final int priority;

  AnnilToken({
    required this.id,
    required this.name,
    required this.url,
    required this.token,
    required this.priority,
  });

  factory AnnilToken.fromJson(Map<String, dynamic> json) =>
      _$AnnilTokenFromJson(json);

  Map<String, dynamic> toJson() => _$AnnilTokenToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class AlbumInfo {
  String albumId;
  String title;
  String? edition;
  String catalog;
  String artist;
  String date;
  List<String> tags;
  String type;
  List<DiscInfo> discs;

  AlbumInfo({
    required this.albumId,
    required this.title,
    this.edition,
    required this.catalog,
    required this.artist,
    required this.date,
    required this.tags,
    required this.type,
    required this.discs,
  });

  factory AlbumInfo.fromJson(Map<String, dynamic> json) =>
      _$AlbumInfoFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class DiscInfo {
  String title;
  String artist;
  String catalog;
  List<String> tags;
  String type;
  List<TrackInfo> tracks;

  DiscInfo({
    required this.title,
    required this.artist,
    required this.catalog,
    required this.tags,
    required this.type,
    required this.tracks,
  });

  factory DiscInfo.fromJson(Map<String, dynamic> json) =>
      _$DiscInfoFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class TrackInfo {
  String title;
  String artist;
  String type;
  List<String> tags;

  TrackInfo({
    required this.title,
    required this.artist,
    required this.tags,
    required this.type,
  });

  factory TrackInfo.fromJson(Map<String, dynamic> json) =>
      _$TrackInfoFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class TrackInfoWithAlbum extends TrackInfo {
  String albumId;
  int discId;
  int trackId;

  TrackInfoWithAlbum({
    required String title,
    required String artist,
    required String type,
    required List<String> tags,
    required this.albumId,
    required this.discId,
    required this.trackId,
  }) : super(title: title, artist: artist, type: type, tags: tags);

  factory TrackInfoWithAlbum.fromJson(Map<String, dynamic> json) =>
      _$TrackInfoWithAlbumFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class PlaylistIntro {
  String id;
  String name;
  String? description;
  String owner;
  Cover cover;

  PlaylistIntro({
    required this.id,
    required this.name,
    this.description,
    required this.owner,
    required this.cover,
  });

  factory PlaylistIntro.fromJson(Map<String, dynamic> json) =>
      _$PlaylistIntroFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class Playlist extends PlaylistIntro {
  bool isPublic;
  List<PlaylistSongWithId> songs;

  Playlist({
    required String id,
    required String name,
    String? description,
    required String owner,
    required Cover cover,
    required this.isPublic,
    required this.songs,
  }) : super(
            id: id,
            name: name,
            description: description,
            owner: owner,
            cover: cover);

  factory Playlist.fromJson(Map<String, dynamic> json) =>
      _$PlaylistFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class PlaylistSong {
  String albumId;
  int discId;
  int trackId;
  String? description;

  PlaylistSong({
    required this.albumId,
    required this.discId,
    required this.trackId,
    this.description,
  });

  factory PlaylistSong.fromJson(Map<String, dynamic> json) =>
      _$PlaylistSongFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class PlaylistSongWithId extends PlaylistSong {
  String id;

  PlaylistSongWithId({
    required this.id,
    required String albumId,
    required int discId,
    required int trackId,
    String? description,
  }) : super(
          albumId: albumId,
          discId: discId,
          trackId: trackId,
          description: description,
        );

  factory PlaylistSongWithId.fromJson(Map<String, dynamic> json) =>
      _$PlaylistSongWithIdFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class Cover {
  String albumId;
  int? discId;

  Cover({required this.albumId, this.discId});

  factory Cover.fromJson(Map<String, dynamic> json) => _$CoverFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class SearchResult {
  List<AlbumInfo>? albums;
  List<TrackInfoWithAlbum>? tracks;
  List<PlaylistIntro>? playlists;

  SearchResult({this.albums, this.tracks, this.playlists});

  factory SearchResult.fromJson(Map<String, dynamic> json) =>
      _$SearchResultFromJson(json);
}
