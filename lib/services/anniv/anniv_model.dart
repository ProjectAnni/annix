// ignore_for_file: constant_identifier_names

import 'dart:convert';

import 'package:annix/services/local/database.dart';
import 'package:annix/services/metadata/metadata_model.dart';
import 'package:drift/drift.dart' hide JsonKey;
import 'package:json_annotation/json_annotation.dart';

part 'anniv_model.g.dart';

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

  String? toIdentifier() => '$albumId/$discId';

  factory DiscIdentifier.fromIdentifier(String identifier) {
    final parts = identifier.split('/');
    return DiscIdentifier(
      albumId: parts[0],
      discId: parts.length == 2 ? int.parse(parts[1]) : 1,
    );
  }
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

  factory TrackIdentifier.fromSlashSplitString(String slashed) {
    final split = slashed.split('/');
    return TrackIdentifier(
      albumId: split[0],
      discId: int.parse(split[1]),
      trackId: int.parse(split[2]),
    );
  }

  Map<String, dynamic> toJson() => _$TrackIdentifierToJson(this);

  @override
  String toString() => '$albumId/$discId/$trackId';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TrackIdentifier) return false;
    return albumId == other.albumId &&
        discId == other.discId &&
        trackId == other.trackId;
  }

  @override
  int get hashCode => Object.hash(albumId, discId, trackId);
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
  TrackIdentifier id;

  String title;
  String artist;
  String albumTitle;
  TrackType type;

  TrackInfoWithAlbum({
    required this.id,
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
        'album_id': id.albumId,
        'disc_id': id.discId,
        'track_id': id.trackId,
        'title': title,
        'artist': artist,
        'album_title': albumTitle,
        'type': _$TrackTypeEnumMap[type],
      };

  factory TrackInfoWithAlbum.fromTrack(Track track) {
    return TrackInfoWithAlbum(
      id: track.id,
      title: track.title,
      artist: track.artist,
      type: track.type,
      albumTitle: track.disc.album.title,
    );
  }
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class PlaylistInfo {
  String id;
  String name;
  String? description;
  String owner;
  bool isPublic;
  DiscIdentifier? cover;
  int lastModified;

  PlaylistInfo({
    required this.id,
    required this.name,
    this.description,
    required this.owner,
    required this.isPublic,
    required this.cover,
    required this.lastModified,
  });

  factory PlaylistInfo.fromJson(Map<String, dynamic> json) =>
      _$PlaylistInfoFromJson(json);

  PlaylistCompanion toCompanion(
      {Value<int> id = const Value.absent(), bool hasItems = false}) {
    return PlaylistCompanion(
      id: id,
      name: Value(name),
      description: Value(description),
      cover: Value(cover?.toIdentifier()),
      remoteId: Value(this.id),
      owner: Value(owner),
      public: Value(isPublic),
      lastModified: Value(lastModified),
      hasItems: Value(hasItems),
    );
  }
}

@JsonSerializable(fieldRename: FieldRename.snake, createFactory: false)
class PatchedPlaylistInfo {
  String? name;
  String? description;
  bool? isPublic;
  DiscIdentifier? cover;
  int? lastModified;

  PatchedPlaylistInfo({
    this.name,
    this.description,
    this.isPublic,
    this.cover,
    this.lastModified,
  });

  Map<String, dynamic> toJson() => _$PatchedPlaylistInfoToJson(this);
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

enum PlaylistItemType {
  normal,
  dummy,
  album;

  @override
  String toString() {
    switch (this) {
      case PlaylistItemType.normal:
        return 'normal';
      case PlaylistItemType.dummy:
        return 'dummy';
      case PlaylistItemType.album:
        return 'album';
    }
  }

  factory PlaylistItemType.fromInstance(PlaylistItem item) {
    if (item is PlaylistItemTrack) {
      return PlaylistItemType.normal;
    } else if (item is PlaylistItemDummyTrack) {
      return PlaylistItemType.dummy;
    } else if (item is PlaylistItemAlbum) {
      return PlaylistItemType.album;
    } else {
      throw ArgumentError('Unknown item type');
    }
  }
}

abstract class PlaylistItem {
  String? description;

  PlaylistItem({this.description});

  factory PlaylistItem.fromDatabase(PlaylistItemData data) {
    return PlaylistItem.fromJson({
      'type': data.type,
      'description': data.description,
      'info': jsonDecode(data.info),
    });
  }

  factory PlaylistItem.fromJson(Map<String, dynamic> json) {
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

  Map<String, dynamic> toJson() {
    return {
      'type': PlaylistItemType.fromInstance(this).toString(),
      'description': description,
    };
  }

  PlaylistItemCompanion toCompanion(
      {required int playlistId, required int order}) {
    return PlaylistItemCompanion(
      playlistId: Value(playlistId),
      type: Value(PlaylistItemType.fromInstance(this).toString()),
      description: Value(description),
      info: Value(jsonEncode(toJson()['info'])),
      order: Value(order),
    );
  }
}

class PlaylistItemTrack extends PlaylistItem {
  final TrackInfoWithAlbum info;

  PlaylistItemTrack({super.description, required this.info});

  factory PlaylistItemTrack.fromJson(Map<String, dynamic> json) =>
      PlaylistItemTrack(
        info: TrackInfoWithAlbum.fromJson(json['info']),
        description: json['description'],
      );

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['info'] = info.toJson();
    return json;
  }
}

class PlaylistItemDummyTrack extends PlaylistItem {
  final RequiredTrackInfo info;

  PlaylistItemDummyTrack({super.description, required this.info});

  factory PlaylistItemDummyTrack.fromJson(Map<String, dynamic> json) =>
      PlaylistItemDummyTrack(
        info: RequiredTrackInfo.fromJson(json['info']),
        description: json['description'],
      );

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['info'] = info.toJson();
    return json;
  }
}

class PlaylistItemAlbum extends PlaylistItem {
  String albumId;

  PlaylistItemAlbum({super.description, required this.albumId});

  factory PlaylistItemAlbum.fromJson(Map<String, dynamic> json) =>
      PlaylistItemAlbum(
        albumId: json['info'],
        description: json['description'],
      );

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['info'] = albumId;
    return json;
  }
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
class RepoDatabaseDescription {
  final int lastModified;

  RepoDatabaseDescription({required this.lastModified});

  factory RepoDatabaseDescription.fromJson(Map<String, dynamic> json) =>
      _$RepoDatabaseDescriptionFromJson(json);
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
