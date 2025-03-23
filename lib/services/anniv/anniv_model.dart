// ignore_for_file: constant_identifier_names

import 'dart:convert';

import 'package:annix/services/local/database.dart';
import 'package:annix/services/metadata/metadata_model.dart';
import 'package:drift/drift.dart' hide JsonKey;
import 'package:json_annotation/json_annotation.dart';

part 'anniv_model.g.dart';

Object? readValueFlatten(final Map json, final String key) {
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

  factory SiteInfo.fromJson(final Map<String, dynamic> json) =>
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

  factory UserInfo.fromJson(final Map<String, dynamic> json) =>
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

  factory AnnilToken.fromJson(final Map<String, dynamic> json) =>
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

  factory AlbumInfo.fromJson(final Map<String, dynamic> json) =>
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

  factory DiscInfo.fromJson(final Map<String, dynamic> json) =>
      _$DiscInfoFromJson(json);

  Disc toDisc() {
    return Disc(
      title: title,
      artist: artist,
      catalog: catalog,
      type: type,
      tracks: tracks.map((final e) => e.toTrack()).toList(),
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

  factory DiscIdentifier.fromJson(final Map<String, dynamic> json) =>
      _$DiscIdentifierFromJson(json);

  Map<String, dynamic> toJson() => _$DiscIdentifierToJson(this);

  String? toIdentifier() => '$albumId/$discId';

  factory DiscIdentifier.fromIdentifier(final String identifier) {
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

  factory TrackIdentifier.fromJson(final Map<String, dynamic> json) =>
      _$TrackIdentifierFromJson(json);

  factory TrackIdentifier.fromSlashSplitString(final String slashed) {
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
  bool operator ==(final Object other) {
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

  factory TrackInfo.fromJson(final Map<String, dynamic> json) =>
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

  factory RequiredTrackInfo.fromJson(final Map<String, dynamic> json) =>
      _$RequiredTrackInfoFromJson(json);

  Map<String, dynamic> toJson() => _$RequiredTrackInfoToJson(this);
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

  factory PlaylistInfo.fromJson(final Map<String, dynamic> json) =>
      _$PlaylistInfoFromJson(json);

  factory PlaylistInfo.fromData(PlaylistData data) {
    // TODO: throw if it is a local playlist
    return PlaylistInfo(
      id: data.remoteId!,
      name: data.name,
      description: data.description,
      owner: data.owner!,
      isPublic: data.public!,
      cover: data.cover != null
          ? DiscIdentifier.fromIdentifier(data.cover!)
          : null,
      lastModified: data.lastModified!,
    );
  }

  PlaylistCompanion toCompanion({
    final Value<int> id = const Value.absent(),
    final bool hasItems = false,
  }) {
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

  List<AnnivPlaylistItem> items;

  Playlist({required this.intro, required this.items});

  factory Playlist.fromJson(final Map<String, dynamic> json) {
    final intro = PlaylistInfo.fromJson(json);
    final items = (json['items'] as List)
        .map((final e) => AnnivPlaylistItem.fromJson(e))
        .toList();
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

  factory PlaylistItemType.fromInstance(final AnnivPlaylistItem item) {
    if (item is AnnivPlaylistItemTrack || item is AnnivPlaylistItemPlainTrack) {
      return PlaylistItemType.normal;
    } else if (item is AnnivPlaylistItemDummyTrack) {
      return PlaylistItemType.dummy;
    } else if (item is AnnivPlaylistItemAlbum) {
      return PlaylistItemType.album;
    } else {
      throw ArgumentError('Unknown item type');
    }
  }
}

// TODO: remove `Anniv` prefix
abstract class AnnivPlaylistItem {
  String? id;
  String? description;

  AnnivPlaylistItem({this.id, this.description});

  factory AnnivPlaylistItem.fromDatabase(final PlaylistItemData data) {
    return AnnivPlaylistItem.fromJson({
      'type': data.type,
      'id': data.remoteId,
      'description': data.description,
      'info': jsonDecode(data.info),
    });
  }

  factory AnnivPlaylistItem.fromJson(final Map<String, dynamic> json) {
    final type = json['type'] as String;
    switch (type) {
      case 'normal':
        return AnnivPlaylistItemTrack.fromJson(json);
      case 'dummy':
        return AnnivPlaylistItemDummyTrack.fromJson(json);
      case 'album':
        return AnnivPlaylistItemAlbum.fromJson(json);
      default:
        throw Exception('Unknown playlist item type: $type');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': PlaylistItemType.fromInstance(this).toString(),
      'description': description,
    };
  }

  PlaylistItemCompanion toCompanion({
    required final int playlistId,
    required final int order,
  }) {
    return PlaylistItemCompanion(
      playlistId: Value(playlistId),
      type: Value(PlaylistItemType.fromInstance(this).toString()),
      remoteId: Value(id),
      description: Value(description),
      info: Value(jsonEncode(toJson()['info'])),
      order: Value(order),
    );
  }
}

class AnnivPlaylistItemTrack extends AnnivPlaylistItem {
  final TrackIdentifier info;

  AnnivPlaylistItemTrack({super.id, super.description, required this.info});

  factory AnnivPlaylistItemTrack.fromJson(final Map<String, dynamic> json) =>
      AnnivPlaylistItemTrack(
        info: TrackIdentifier.fromJson(json['info']),
        id: json['id'],
        description: json['description'],
      );

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['info'] = info.toJson();
    return json;
  }
}

class AnnivPlaylistPlainItem extends AnnivPlaylistItem {
  AnnivPlaylistPlainItem({super.description});
}

class AnnivPlaylistItemPlainTrack extends AnnivPlaylistPlainItem {
  final TrackIdentifier track;

  AnnivPlaylistItemPlainTrack({super.description, required this.track});

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['info'] = track.toJson();
    return json;
  }
}

class AnnivPlaylistItemDummyTrack extends AnnivPlaylistItem {
  final RequiredTrackInfo info;

  AnnivPlaylistItemDummyTrack(
      {super.id, super.description, required this.info});

  factory AnnivPlaylistItemDummyTrack.fromJson(
          final Map<String, dynamic> json) =>
      AnnivPlaylistItemDummyTrack(
        info: RequiredTrackInfo.fromJson(json['info']),
        id: json['id'],
        description: json['description'],
      );

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['info'] = info.toJson();
    return json;
  }
}

class AnnivPlaylistItemAlbum extends AnnivPlaylistItem {
  String albumId;

  AnnivPlaylistItemAlbum({super.id, super.description, required this.albumId});

  factory AnnivPlaylistItemAlbum.fromJson(final Map<String, dynamic> json) =>
      AnnivPlaylistItemAlbum(
        albumId: json['info'],
        id: json['id'],
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
  List<TrackIdentifier>? tracks;
  List<PlaylistInfo>? playlists;

  SearchResult({this.albums, this.tracks, this.playlists});

  factory SearchResult.fromJson(final Map<String, dynamic> json) =>
      _$SearchResultFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class LyricResponse {
  LyricLanguage source;
  List<LyricLanguage> translations;

  LyricResponse({required this.source, required this.translations});

  factory LyricResponse.fromJson(final Map<String, dynamic> json) =>
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

  factory LyricLanguage.fromJson(final Map<String, dynamic> json) =>
      _$LyricLanguageFromJson(json);

  Map<String, dynamic> toJson() => _$LyricLanguageToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class RepoDatabaseDescription {
  final int lastModified;

  RepoDatabaseDescription({required this.lastModified});

  factory RepoDatabaseDescription.fromJson(final Map<String, dynamic> json) =>
      _$RepoDatabaseDescriptionFromJson(json);
}

@JsonEnum(fieldRename: FieldRename.snake)
enum TagType {
  Artist,
  Group,
  Animation,
  Series,
  Radio,
  Project,
  Game,
  Organization,
  Unknown,
  Category;

  factory TagType.fromString(final String type) {
    switch (type) {
      case 'artist':
        return TagType.Artist;
      case 'group':
        return TagType.Group;
      case 'animation':
        return TagType.Animation;
      case 'series':
        return TagType.Series;
      case 'radio':
        return TagType.Radio;
      case 'project':
        return TagType.Project;
      case 'game':
        return TagType.Game;
      case 'organization':
        return TagType.Organization;
      case 'category':
        return TagType.Category;
      case 'unknown':
      default:
        return TagType.Unknown;
    }
  }
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class TagInfo {
  final String name;
  final TagType type;

  TagInfo({required this.name, required this.type});

  factory TagInfo.fromJson(final Map<String, dynamic> json) =>
      _$TagInfoFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake, createFactory: false)
class SongPlayRecord {
  final TrackIdentifier track;
  final List<int> at;

  SongPlayRecord({required this.track, required this.at});

  Map<String, dynamic> toJson() => _$SongPlayRecordToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class SongPlayRecordResult {
  final TrackIdentifier track;
  final int count;

  SongPlayRecordResult({required this.track, required this.count});

  factory SongPlayRecordResult.fromJson(final Map<String, dynamic> json) =>
      _$SongPlayRecordResultFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class HistoryRecord {
  final TrackIdentifier track;
  final int at;

  HistoryRecord({required this.track, required this.at});

  factory HistoryRecord.fromJson(final Map<String, dynamic> json) =>
      _$HistoryRecordFromJson(json);
}
