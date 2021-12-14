import 'package:json_annotation/json_annotation.dart';

part 'anniv.g.dart';

@JsonSerializable(
  fieldRename: FieldRename.snake,
  createFactory: true,
  createToJson: false,
)
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
}

@JsonSerializable(
  fieldRename: FieldRename.snake,
  createFactory: true,
  createToJson: false,
)
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
}
