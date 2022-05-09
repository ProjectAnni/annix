import 'package:json_annotation/json_annotation.dart';

part 'anniv.g.dart';

Object? readValueFlatten(Map json, String key) {
  return json;
}

@JsonSerializable(fieldRename: FieldRename.snake)
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
  Map<String, dynamic> toJson() => _$SiteInfoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
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
  Map<String, dynamic> toJson() => _$UserInfoToJson(this);
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
  String type;
  List<DiscInfo> discs;

  AlbumInfo({
    required this.albumId,
    required this.title,
    this.edition,
    required this.catalog,
    required this.artist,
    required this.date,
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
  String type;
  List<TrackInfo> tracks;

  DiscInfo({
    required this.title,
    required this.artist,
    required this.catalog,
    required this.type,
    required this.tracks,
  });

  factory DiscInfo.fromJson(Map<String, dynamic> json) =>
      _$DiscInfoFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class TrackIdentifier {
  String albumId;
  int discId;
  int trackId;

  TrackIdentifier({
    required this.albumId,
    required this.discId,
    required this.trackId,
  });

  factory TrackIdentifier.fromJson(Map<String, dynamic> json) =>
      _$TrackIdentifierFromJson(json);

  factory TrackIdentifier.fromSlashSplitedString(String slashed) {
    final splited = slashed.split('/');
    return TrackIdentifier(
      albumId: splited[0],
      discId: int.parse(splited[1]),
      trackId: int.parse(splited[2]),
    );
  }

  Map<String, dynamic> toJson() => _$TrackIdentifierToJson(this);

  String toSlashedString() => '$albumId/$discId/$trackId';
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class TrackInfo {
  String title;
  String artist;
  String type;

  TrackInfo({
    required this.title,
    required this.artist,
    required this.type,
  });

  factory TrackInfo.fromJson(Map<String, dynamic> json) =>
      _$TrackInfoFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class TrackInfoWithAlbum {
  @JsonKey(fromJson: _trackFromJson, readValue: readValueFlatten)
  TrackIdentifier track;

  @JsonKey(fromJson: _infoFromJson, readValue: readValueFlatten)
  TrackInfo info;

  TrackInfoWithAlbum({
    required this.track,
    required this.info,
  });

  factory TrackInfoWithAlbum.fromJson(Map<String, dynamic> json) =>
      _$TrackInfoWithAlbumFromJson(json);

  static TrackIdentifier _trackFromJson(Map<String, dynamic> json) =>
      TrackIdentifier.fromJson(json);

  static TrackInfo _infoFromJson(Map<String, dynamic> json) =>
      TrackInfo.fromJson(json);
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
class Playlist {
  @JsonKey(fromJson: _introFromJson, readValue: readValueFlatten)
  PlaylistIntro intro;

  bool isPublic;
  List<PlaylistSongWithId> songs;

  Playlist({
    required this.intro,
    required this.isPublic,
    required this.songs,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) =>
      _$PlaylistFromJson(json);

  static PlaylistIntro _introFromJson(Map<String, dynamic> json) =>
      PlaylistIntro.fromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class PlaylistSong {
  @JsonKey(fromJson: _trackFromJson, readValue: readValueFlatten)
  TrackIdentifier track;

  String? description;

  PlaylistSong({
    required this.track,
    this.description,
  });

  factory PlaylistSong.fromJson(Map<String, dynamic> json) =>
      _$PlaylistSongFromJson(json);

  static TrackIdentifier _trackFromJson(Map<String, dynamic> json) =>
      TrackIdentifier.fromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class PlaylistSongWithId {
  String id;
  @JsonKey(fromJson: _songFromJson, readValue: readValueFlatten)
  PlaylistSong song;

  PlaylistSongWithId({
    required this.id,
    required this.song,
  });

  factory PlaylistSongWithId.fromJson(Map<String, dynamic> json) =>
      _$PlaylistSongWithIdFromJson(json);

  static PlaylistSong _songFromJson(Map<String, dynamic> json) =>
      PlaylistSong.fromJson(json);
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

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class LyricResponse {
  LyricLanguage source;
  List<LyricLanguage> translations;

  LyricResponse({required this.source, required this.translations});

  factory LyricResponse.fromJson(Map<String, dynamic> json) =>
      _$LyricResponseFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class LyricLanguage {
  String language;
  String type; // "text" | "lrc"
  String data;
  // UserIntro contributor;

  LyricLanguage({
    required this.language,
    required this.type,
    required this.data,
  });

  factory LyricLanguage.fromJson(Map<String, dynamic> json) =>
      _$LyricLanguageFromJson(json);
}
