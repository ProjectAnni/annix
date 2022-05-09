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
    );

Map<String, dynamic> _$AnnilTokenToJson(AnnilToken instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'url': instance.url,
      'token': instance.token,
      'priority': instance.priority,
    };

AlbumInfo _$AlbumInfoFromJson(Map<String, dynamic> json) => AlbumInfo(
      albumId: json['album_id'] as String,
      title: json['title'] as String,
      edition: json['edition'] as String?,
      catalog: json['catalog'] as String,
      artist: json['artist'] as String,
      date: json['date'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      type: json['type'] as String,
      discs: (json['discs'] as List<dynamic>)
          .map((e) => DiscInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

DiscInfo _$DiscInfoFromJson(Map<String, dynamic> json) => DiscInfo(
      title: json['title'] as String,
      artist: json['artist'] as String,
      catalog: json['catalog'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      type: json['type'] as String,
      tracks: (json['tracks'] as List<dynamic>)
          .map((e) => TrackInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

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
      artist: json['artist'] as String,
      type: json['type'] as String,
    );

TrackInfoWithAlbum _$TrackInfoWithAlbumFromJson(Map<String, dynamic> json) =>
    TrackInfoWithAlbum(
      track: TrackInfoWithAlbum._trackFromJson(
          readValueFlatten(json, 'track') as Map<String, dynamic>),
      info: TrackInfoWithAlbum._infoFromJson(
          readValueFlatten(json, 'info') as Map<String, dynamic>),
    );

PlaylistIntro _$PlaylistIntroFromJson(Map<String, dynamic> json) =>
    PlaylistIntro(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      owner: json['owner'] as String,
      cover: Cover.fromJson(json['cover'] as Map<String, dynamic>),
    );

Playlist _$PlaylistFromJson(Map<String, dynamic> json) => Playlist(
      intro: Playlist._introFromJson(
          readValueFlatten(json, 'intro') as Map<String, dynamic>),
      isPublic: json['is_public'] as bool,
      songs: (json['songs'] as List<dynamic>)
          .map((e) => PlaylistSongWithId.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

PlaylistSong _$PlaylistSongFromJson(Map<String, dynamic> json) => PlaylistSong(
      track: PlaylistSong._trackFromJson(
          readValueFlatten(json, 'track') as Map<String, dynamic>),
      description: json['description'] as String?,
    );

PlaylistSongWithId _$PlaylistSongWithIdFromJson(Map<String, dynamic> json) =>
    PlaylistSongWithId(
      id: json['id'] as String,
      song: PlaylistSongWithId._songFromJson(
          readValueFlatten(json, 'song') as Map<String, dynamic>),
    );

Cover _$CoverFromJson(Map<String, dynamic> json) => Cover(
      albumId: json['album_id'] as String,
      discId: json['disc_id'] as int?,
    );

SearchResult _$SearchResultFromJson(Map<String, dynamic> json) => SearchResult(
      albums: (json['albums'] as List<dynamic>?)
          ?.map((e) => AlbumInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      tracks: (json['tracks'] as List<dynamic>?)
          ?.map((e) => TrackInfoWithAlbum.fromJson(e as Map<String, dynamic>))
          .toList(),
      playlists: (json['playlists'] as List<dynamic>?)
          ?.map((e) => PlaylistIntro.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
