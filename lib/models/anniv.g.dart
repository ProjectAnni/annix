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
