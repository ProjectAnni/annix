// ignore_for_file: constant_identifier_names

import 'package:annix/models/metadata.dart';
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
  final bool controlled;

  AnnilToken({
    required this.id,
    required this.name,
    required this.url,
    required this.token,
    required this.priority,
    required this.controlled,
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
  TrackType type;
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
  String? title;
  String? artist;
  String catalog;
  TrackType? type;
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

  Disc toDisc() {
    return Disc(
      title: title,
      artist: artist,
      catalog: catalog,
      type: type,
      tracks: tracks.map((e) => e.toTrack()).toList(),
    );
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class DiscIdentifier {
  final String albumId;
  final int discId;

  DiscIdentifier({
    required this.albumId,
    required this.discId,
  });

  factory DiscIdentifier.fromJson(Map<String, dynamic> json) =>
      _$DiscIdentifierFromJson(json);

  Map<String, dynamic> toJson() => _$DiscIdentifierToJson(this);
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
  String? artist;
  TrackType? type;

  TrackInfo({
    required this.title,
    this.artist,
    this.type,
  });

  factory TrackInfo.fromJson(Map<String, dynamic> json) =>
      _$TrackInfoFromJson(json);

  Track toTrack() {
    return Track(
      title: title,
      artist: artist,
      type: type,
    );
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class RequiredTrackInfo {
  String title;
  String artist;
  TrackType type;

  RequiredTrackInfo({
    required this.title,
    required this.artist,
    required this.type,
  });

  factory RequiredTrackInfo.fromJson(Map<String, dynamic> json) =>
      _$RequiredTrackInfoFromJson(json);

  Map<String, dynamic> toJson() => _$RequiredTrackInfoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class TrackInfoWithAlbum {
  @JsonKey(fromJson: _trackFromJson, readValue: readValueFlatten)
  TrackIdentifier track;

  String title;
  String artist;
  String albumTitle;
  TrackType type;

  TrackInfoWithAlbum({
    required this.track,
    required this.title,
    required this.artist,
    required this.albumTitle,
    required this.type,
  });

  factory TrackInfoWithAlbum.fromJson(Map<String, dynamic> json) =>
      _$TrackInfoWithAlbumFromJson(json);

  static TrackIdentifier _trackFromJson(Map<String, dynamic> json) =>
      TrackIdentifier.fromJson(json);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'album_id': track.albumId,
        'disc_id': track.discId,
        'track_id': track.trackId,
        'title': title,
        'artist': artist,
        'album_title': albumTitle,
        'type': _$TrackTypeEnumMap[type],
      };
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class PlaylistInfo {
  String id;
  String name;
  String? description;
  String owner;
  bool isPublic;
  DiscIdentifier cover;

  PlaylistInfo({
    required this.id,
    required this.name,
    this.description,
    required this.owner,
    required this.isPublic,
    required this.cover,
  });

  factory PlaylistInfo.fromJson(Map<String, dynamic> json) =>
      _$PlaylistInfoFromJson(json);
}

class Playlist {
  PlaylistInfo intro;

  List<PlaylistItem> items;

  Playlist({required this.intro, required this.items});

  factory Playlist.fromJson(Map<String, dynamic> json) {
    final intro = PlaylistInfo.fromJson(json);
    final items =
        (json['items'] as List).map((e) => PlaylistItem.fromJson(e)).toList();
    return Playlist(intro: intro, items: items);
  }
}

enum PlaylistItemType { normal, dummy, album }

abstract class PlaylistItem<T> {
  PlaylistItemType type;
  String? description;
  T info;

  PlaylistItem({
    required this.type,
    this.description,
    required this.info,
  });

  static PlaylistItem<dynamic> fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    switch (type) {
      case 'normal':
        return PlaylistItemTrack.fromJson(json);
      case 'dummy':
        return PlaylistItemDummyTrack.fromJson(json);
      case 'album':
        return PlaylistItemAlbum.fromJson(json);
      default:
        throw Exception('Unknown playlist item type: $type');
    }
  }
}

class PlaylistItemTrack extends PlaylistItem<TrackInfoWithAlbum> {
  PlaylistItemTrack({
    String? description,
    required TrackInfoWithAlbum info,
  }) : super(
          type: PlaylistItemType.normal,
          description: description,
          info: info,
        );

  factory PlaylistItemTrack.fromJson(Map<String, dynamic> json) =>
      PlaylistItemTrack(
        info: TrackInfoWithAlbum.fromJson(json["info"]),
        description: json['description'],
      );
}

class PlaylistItemDummyTrack extends PlaylistItem<RequiredTrackInfo> {
  PlaylistItemDummyTrack({
    String? description,
    required RequiredTrackInfo info,
  }) : super(
          type: PlaylistItemType.dummy,
          description: description,
          info: info,
        );

  factory PlaylistItemDummyTrack.fromJson(Map<String, dynamic> json) =>
      PlaylistItemDummyTrack(
        info: RequiredTrackInfo.fromJson(json["info"]),
        description: json['description'],
      );
}

class PlaylistItemAlbum extends PlaylistItem<String /* AlbumIdentifier */ > {
  PlaylistItemAlbum({
    String? description,
    required String albumId,
  }) : super(
          type: PlaylistItemType.album,
          description: description,
          info: albumId,
        );

  factory PlaylistItemAlbum.fromJson(Map<String, dynamic> json) =>
      PlaylistItemAlbum(
        albumId: json['info'],
        description: json['description'],
      );
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class SearchResult {
  List<Album>? albums;
  List<TrackInfoWithAlbum>? tracks;
  List<PlaylistInfo>? playlists;

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

@JsonSerializable(fieldRename: FieldRename.snake)
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

  Map<String, dynamic> toJson() => _$LyricLanguageToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class RepoDatabaseDecsription {
  final int lastModified;

  RepoDatabaseDecsription({required this.lastModified});

  factory RepoDatabaseDecsription.fromJson(Map<String, dynamic> json) =>
      _$RepoDatabaseDecsriptionFromJson(json);
}

@JsonEnum(fieldRename: FieldRename.snake)
enum TagType {
  Artist,
  Group,
  Animation,
  Series,
  Project,
  Game,
  Organization,
  Default,
  Category;

  factory TagType.fromString(String type) {
    switch (type) {
      case 'artist':
        return TagType.Artist;
      case 'group':
        return TagType.Group;
      case 'animation':
        return TagType.Animation;
      case 'series':
        return TagType.Series;
      case 'project':
        return TagType.Project;
      case 'game':
        return TagType.Game;
      case 'organization':
        return TagType.Organization;
      case 'category':
        return TagType.Category;
      case 'default':
      default:
        return TagType.Default;
    }
  }
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class TagInfo {
  final String name;
  final TagType type;

  TagInfo({required this.name, required this.type});

  factory TagInfo.fromJson(Map<String, dynamic> json) =>
      _$TagInfoFromJson(json);
}
