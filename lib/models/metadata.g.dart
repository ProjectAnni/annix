// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metadata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReleaseDate _$ReleaseDateFromJson(Map<String, dynamic> json) => ReleaseDate(
      year: json['year'] as int,
      month: json['month'] as int?,
      day: json['day'] as int?,
    );

Map<String, dynamic> _$ReleaseDateToJson(ReleaseDate instance) =>
    <String, dynamic>{
      'year': instance.year,
      'month': instance.month,
      'day': instance.day,
    };

Album _$AlbumFromJson(Map<String, dynamic> json) => Album(
      albumId: json['albumId'] as String,
      title: json['title'] as String,
      edition: json['edition'] as String?,
      catalog: json['catalog'] as String,
      artist: json['artist'] as String,
      type: $enumDecode(_$TrackTypeEnumMap, json['type']),
      date: ReleaseDate.fromJson(json['date'] as Map<String, dynamic>),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      discs: (json['discs'] as List<dynamic>)
          .map((e) => Disc.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AlbumToJson(Album instance) => <String, dynamic>{
      'albumId': instance.albumId,
      'title': instance.title,
      'edition': instance.edition,
      'catalog': instance.catalog,
      'artist': instance.artist,
      'type': _$TrackTypeEnumMap[instance.type],
      'date': instance.date,
      'tags': instance.tags,
      'discs': instance.discs,
    };

const _$TrackTypeEnumMap = {
  TrackType.Normal: 'Normal',
  TrackType.Instrumental: 'Instrumental',
  TrackType.Absolute: 'Absolute',
  TrackType.Drama: 'Drama',
  TrackType.Radio: 'Radio',
  TrackType.Vocal: 'Vocal',
  TrackType.Unknown: 'Unknown',
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
    )..album = Album.fromJson(json['album'] as Map<String, dynamic>);

Map<String, dynamic> _$DiscToJson(Disc instance) => <String, dynamic>{
      'album': instance.album,
      'catalog': instance.catalog,
      'tags': instance.tags,
      'tracks': instance.tracks,
      'title': instance.title,
      'artist': instance.artist,
      'type': _$TrackTypeEnumMap[instance.type],
    };

Track _$TrackFromJson(Map<String, dynamic> json) => Track(
      title: json['title'] as String,
      artist: json['artist'] as String?,
      type: $enumDecodeNullable(_$TrackTypeEnumMap, json['type']),
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
    )..disc = Disc.fromJson(json['disc'] as Map<String, dynamic>);

Map<String, dynamic> _$TrackToJson(Track instance) => <String, dynamic>{
      'disc': instance.disc,
      'title': instance.title,
      'tags': instance.tags,
      'artist': instance.artist,
      'type': _$TrackTypeEnumMap[instance.type],
    };
