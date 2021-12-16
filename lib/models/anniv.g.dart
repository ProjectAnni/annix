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

UserInfo _$UserInfoFromJson(Map<String, dynamic> json) => UserInfo(
      userId: json['user_id'] as String,
      email: json['email'] as String,
      nickname: json['nickname'] as String,
      avatar: json['avatar'] as String,
    );

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
