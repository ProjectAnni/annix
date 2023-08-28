// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metadata_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Album _$AlbumFromJson(Map<String, dynamic> json) => Album(
      albumId: json['album_id'] as String,
      title: json['title'] as String,
      edition: json['edition'] as String?,
      catalog: json['catalog'] as String,
      artist: json['artist'] as String,
      type: $enumDecode(_$TrackTypeEnumMap, json['type']),
      date: ReleaseDate.fromJson(ReleaseDate.readValue(json, 'date') as String),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      discs: (json['discs'] as List<dynamic>)
          .map((e) => Disc.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AlbumToJson(Album instance) => <String, dynamic>{
      'album_id': instance.albumId,
      'title': instance.title,
      'edition': instance.edition,
      'catalog': instance.catalog,
      'artist': instance.artist,
      'type': _$TrackTypeEnumMap[instance.type]!,
      'date': instance.date.toJson(),
      'tags': instance.tags,
      'discs': instance.discs.map((e) => e.toJson()).toList(),
    };

const _$TrackTypeEnumMap = {
  TrackType.normal: 'normal',
  TrackType.instrumental: 'instrumental',
  TrackType.absolute: 'absolute',
  TrackType.drama: 'drama',
  TrackType.radio: 'radio',
  TrackType.vocal: 'vocal',
};

Disc _$DiscFromJson(Map<String, dynamic> json) => Disc(
      title: json['title'] as String?,
      catalog: json['catalog'] as String,
      artist: json['artist'] as String?,
      type: $enumDecodeNullable(_$TrackTypeEnumMap, json['type']),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      tracks: (json['tracks'] as List<dynamic>)
          .map((e) => Track.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DiscToJson(Disc instance) => <String, dynamic>{
      'catalog': instance.catalog,
      'tags': instance.tags,
      'tracks': instance.tracks.map((e) => e.toJson()).toList(),
      'title': instance.title,
      'artist': instance.artist,
      'type': _$TrackTypeEnumMap[instance.type]!,
    };

Track _$TrackFromJson(Map<String, dynamic> json) => Track(
      title: json['title'] as String,
      artist: json['artist'] as String?,
      type: $enumDecodeNullable(_$TrackTypeEnumMap, json['type']),
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
    );

Map<String, dynamic> _$TrackToJson(Track instance) => <String, dynamic>{
      'title': instance.title,
      'tags': instance.tags,
      'artist': instance.artist,
      'type': _$TrackTypeEnumMap[instance.type]!,
    };
