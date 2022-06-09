// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anniv.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SiteInfo _$SiteInfoFromJson(Map<String, dynamic> json) => SiteInfo(
      siteName: json['site_name'] as String,
      description: json['description'] as String,
      protocolVersion: json['protocol_version'] as String,
      features:
          (json['features'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$SiteInfoToJson(SiteInfo instance) => <String, dynamic>{
      'site_name': instance.siteName,
      'description': instance.description,
      'protocol_version': instance.protocolVersion,
      'features': instance.features,
    };

UserInfo _$UserInfoFromJson(Map<String, dynamic> json) => UserInfo(
      userId: json['user_id'] as String,
      email: json['email'] as String,
      nickname: json['nickname'] as String,
      avatar: json['avatar'] as String,
    );

Map<String, dynamic> _$UserInfoToJson(UserInfo instance) => <String, dynamic>{
      'user_id': instance.userId,
      'email': instance.email,
      'nickname': instance.nickname,
      'avatar': instance.avatar,
    };

AnnilToken _$AnnilTokenFromJson(Map<String, dynamic> json) => AnnilToken(
      id: json['id'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      token: json['token'] as String,
      priority: json['priority'] as int,
      controlled: json['controlled'] as bool,
    );

Map<String, dynamic> _$AnnilTokenToJson(AnnilToken instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'url': instance.url,
      'token': instance.token,
      'priority': instance.priority,
      'controlled': instance.controlled,
    };

AlbumInfo _$AlbumInfoFromJson(Map<String, dynamic> json) => AlbumInfo(
      albumId: json['album_id'] as String,
      title: json['title'] as String,
      edition: json['edition'] as String?,
      catalog: json['catalog'] as String,
      artist: json['artist'] as String,
      date: json['date'] as String,
      type: $enumDecode(_$TrackTypeEnumMap, json['type']),
      discs: (json['discs'] as List<dynamic>)
          .map((e) => DiscInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

const _$TrackTypeEnumMap = {
  TrackType.Normal: 'normal',
  TrackType.Instrumental: 'instrumental',
  TrackType.Absolute: 'absolute',
  TrackType.Drama: 'drama',
  TrackType.Radio: 'radio',
  TrackType.Vocal: 'vocal',
};

DiscInfo _$DiscInfoFromJson(Map<String, dynamic> json) => DiscInfo(
      title: json['title'] as String?,
      artist: json['artist'] as String?,
      catalog: json['catalog'] as String,
      type: $enumDecodeNullable(_$TrackTypeEnumMap, json['type']),
      tracks: (json['tracks'] as List<dynamic>)
          .map((e) => TrackInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

DiscIdentifier _$DiscIdentifierFromJson(Map<String, dynamic> json) =>
    DiscIdentifier(
      albumId: json['album_id'] as String,
      discId: json['disc_id'] as int,
    );

Map<String, dynamic> _$DiscIdentifierToJson(DiscIdentifier instance) =>
    <String, dynamic>{
      'album_id': instance.albumId,
      'disc_id': instance.discId,
    };

TrackIdentifier _$TrackIdentifierFromJson(Map<String, dynamic> json) =>
    TrackIdentifier(
      albumId: json['album_id'] as String,
      discId: json['disc_id'] as int,
      trackId: json['track_id'] as int,
    );

Map<String, dynamic> _$TrackIdentifierToJson(TrackIdentifier instance) =>
    <String, dynamic>{
      'album_id': instance.albumId,
      'disc_id': instance.discId,
      'track_id': instance.trackId,
    };

TrackInfo _$TrackInfoFromJson(Map<String, dynamic> json) => TrackInfo(
      title: json['title'] as String,
      artist: json['artist'] as String?,
      type: $enumDecodeNullable(_$TrackTypeEnumMap, json['type']),
    );

RequiredTrackInfo _$RequiredTrackInfoFromJson(Map<String, dynamic> json) =>
    RequiredTrackInfo(
      title: json['title'] as String,
      artist: json['artist'] as String,
      type: $enumDecode(_$TrackTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$RequiredTrackInfoToJson(RequiredTrackInfo instance) =>
    <String, dynamic>{
      'title': instance.title,
      'artist': instance.artist,
      'type': _$TrackTypeEnumMap[instance.type],
    };

TrackInfoWithAlbum _$TrackInfoWithAlbumFromJson(Map<String, dynamic> json) =>
    TrackInfoWithAlbum(
      track: TrackInfoWithAlbum._trackFromJson(
          readValueFlatten(json, 'track') as Map<String, dynamic>),
      title: json['title'] as String,
      artist: json['artist'] as String,
      albumTitle: json['album_title'] as String,
      type: $enumDecode(_$TrackTypeEnumMap, json['type']),
    );

PlaylistInfo _$PlaylistInfoFromJson(Map<String, dynamic> json) => PlaylistInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      owner: json['owner'] as String,
      isPublic: json['is_public'] as bool,
      cover: DiscIdentifier.fromJson(json['cover'] as Map<String, dynamic>),
    );

SearchResult _$SearchResultFromJson(Map<String, dynamic> json) => SearchResult(
      albums: (json['albums'] as List<dynamic>?)
          ?.map((e) => AlbumInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      tracks: (json['tracks'] as List<dynamic>?)
          ?.map((e) => TrackInfoWithAlbum.fromJson(e as Map<String, dynamic>))
          .toList(),
      playlists: (json['playlists'] as List<dynamic>?)
          ?.map((e) => PlaylistInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

LyricResponse _$LyricResponseFromJson(Map<String, dynamic> json) =>
    LyricResponse(
      source: LyricLanguage.fromJson(json['source'] as Map<String, dynamic>),
      translations: (json['translations'] as List<dynamic>)
          .map((e) => LyricLanguage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

LyricLanguage _$LyricLanguageFromJson(Map<String, dynamic> json) =>
    LyricLanguage(
      language: json['language'] as String,
      type: json['type'] as String,
      data: json['data'] as String,
    );

Map<String, dynamic> _$LyricLanguageToJson(LyricLanguage instance) =>
    <String, dynamic>{
      'language': instance.language,
      'type': instance.type,
      'data': instance.data,
    };

RepoDatabaseDecsription _$RepoDatabaseDecsriptionFromJson(
        Map<String, dynamic> json) =>
    RepoDatabaseDecsription(
      lastModified: json['last_modified'] as int,
    );
