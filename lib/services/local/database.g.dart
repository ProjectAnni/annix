// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class AnnivUser extends Table with TableInfo<AnnivUser, AnnivUserData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  AnnivUser(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT');
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _nicknameMeta =
      const VerificationMeta('nickname');
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
      'nickname', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _avatarMeta = const VerificationMeta('avatar');
  late final GeneratedColumn<String> avatar = GeneratedColumn<String>(
      'avatar', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  @override
  List<GeneratedColumn> get $columns => [id, userId, nickname, avatar];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'anniv_user';
  @override
  VerificationContext validateIntegrity(Insertable<AnnivUserData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('nickname')) {
      context.handle(_nicknameMeta,
          nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta));
    } else if (isInserting) {
      context.missing(_nicknameMeta);
    }
    if (data.containsKey('avatar')) {
      context.handle(_avatarMeta,
          avatar.isAcceptableOrUnknown(data['avatar']!, _avatarMeta));
    } else if (isInserting) {
      context.missing(_avatarMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AnnivUserData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnnivUserData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      nickname: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nickname'])!,
      avatar: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avatar'])!,
    );
  }

  @override
  AnnivUser createAlias(String alias) {
    return AnnivUser(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class AnnivUserData extends DataClass implements Insertable<AnnivUserData> {
  final int id;
  final String userId;
  final String nickname;
  final String avatar;
  const AnnivUserData(
      {required this.id,
      required this.userId,
      required this.nickname,
      required this.avatar});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['nickname'] = Variable<String>(nickname);
    map['avatar'] = Variable<String>(avatar);
    return map;
  }

  AnnivUserCompanion toCompanion(bool nullToAbsent) {
    return AnnivUserCompanion(
      id: Value(id),
      userId: Value(userId),
      nickname: Value(nickname),
      avatar: Value(avatar),
    );
  }

  factory AnnivUserData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnnivUserData(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['user_id']),
      nickname: serializer.fromJson<String>(json['nickname']),
      avatar: serializer.fromJson<String>(json['avatar']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'user_id': serializer.toJson<String>(userId),
      'nickname': serializer.toJson<String>(nickname),
      'avatar': serializer.toJson<String>(avatar),
    };
  }

  AnnivUserData copyWith(
          {int? id, String? userId, String? nickname, String? avatar}) =>
      AnnivUserData(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        nickname: nickname ?? this.nickname,
        avatar: avatar ?? this.avatar,
      );
  AnnivUserData copyWithCompanion(AnnivUserCompanion data) {
    return AnnivUserData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      nickname: data.nickname.present ? data.nickname.value : this.nickname,
      avatar: data.avatar.present ? data.avatar.value : this.avatar,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AnnivUserData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('nickname: $nickname, ')
          ..write('avatar: $avatar')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, nickname, avatar);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnnivUserData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.nickname == this.nickname &&
          other.avatar == this.avatar);
}

class AnnivUserCompanion extends UpdateCompanion<AnnivUserData> {
  final Value<int> id;
  final Value<String> userId;
  final Value<String> nickname;
  final Value<String> avatar;
  const AnnivUserCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.nickname = const Value.absent(),
    this.avatar = const Value.absent(),
  });
  AnnivUserCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    required String nickname,
    required String avatar,
  })  : userId = Value(userId),
        nickname = Value(nickname),
        avatar = Value(avatar);
  static Insertable<AnnivUserData> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? nickname,
    Expression<String>? avatar,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (nickname != null) 'nickname': nickname,
      if (avatar != null) 'avatar': avatar,
    });
  }

  AnnivUserCompanion copyWith(
      {Value<int>? id,
      Value<String>? userId,
      Value<String>? nickname,
      Value<String>? avatar}) {
    return AnnivUserCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (avatar.present) {
      map['avatar'] = Variable<String>(avatar.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnnivUserCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('nickname: $nickname, ')
          ..write('avatar: $avatar')
          ..write(')'))
        .toString();
  }
}

class Playlist extends Table with TableInfo<Playlist, PlaylistData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Playlist(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT');
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _coverMeta = const VerificationMeta('cover');
  late final GeneratedColumn<String> cover = GeneratedColumn<String>(
      'cover', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _remoteIdMeta =
      const VerificationMeta('remoteId');
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
      'remote_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _ownerMeta = const VerificationMeta('owner');
  late final GeneratedColumn<String> owner = GeneratedColumn<String>(
      'owner', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _publicMeta = const VerificationMeta('public');
  late final GeneratedColumn<bool> public = GeneratedColumn<bool>(
      'public', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _lastModifiedMeta =
      const VerificationMeta('lastModified');
  late final GeneratedColumn<int> lastModified = GeneratedColumn<int>(
      'last_modified', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _hasItemsMeta =
      const VerificationMeta('hasItems');
  late final GeneratedColumn<bool> hasItems = GeneratedColumn<bool>(
      'has_items', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        cover,
        description,
        remoteId,
        owner,
        public,
        lastModified,
        hasItems
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlist';
  @override
  VerificationContext validateIntegrity(Insertable<PlaylistData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('cover')) {
      context.handle(
          _coverMeta, cover.isAcceptableOrUnknown(data['cover']!, _coverMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('remote_id')) {
      context.handle(_remoteIdMeta,
          remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta));
    }
    if (data.containsKey('owner')) {
      context.handle(
          _ownerMeta, owner.isAcceptableOrUnknown(data['owner']!, _ownerMeta));
    }
    if (data.containsKey('public')) {
      context.handle(_publicMeta,
          public.isAcceptableOrUnknown(data['public']!, _publicMeta));
    }
    if (data.containsKey('last_modified')) {
      context.handle(
          _lastModifiedMeta,
          lastModified.isAcceptableOrUnknown(
              data['last_modified']!, _lastModifiedMeta));
    }
    if (data.containsKey('has_items')) {
      context.handle(_hasItemsMeta,
          hasItems.isAcceptableOrUnknown(data['has_items']!, _hasItemsMeta));
    } else if (isInserting) {
      context.missing(_hasItemsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaylistData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      cover: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cover']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      remoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remote_id']),
      owner: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner']),
      public: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}public']),
      lastModified: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_modified']),
      hasItems: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}has_items'])!,
    );
  }

  @override
  Playlist createAlias(String alias) {
    return Playlist(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class PlaylistData extends DataClass implements Insertable<PlaylistData> {
  /// local properties
  final int id;
  final String name;
  final String? cover;
  final String? description;

  /// remote properties
  final String? remoteId;

  /// remote id (string), should be unique
  final String? owner;

  /// owner id of the playlist
  final bool? public;

  /// whether the playlist is public
  final int? lastModified;

  /// last modified timestamp of remote playlist
  final bool hasItems;
  const PlaylistData(
      {required this.id,
      required this.name,
      this.cover,
      this.description,
      this.remoteId,
      this.owner,
      this.public,
      this.lastModified,
      required this.hasItems});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || cover != null) {
      map['cover'] = Variable<String>(cover);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    if (!nullToAbsent || owner != null) {
      map['owner'] = Variable<String>(owner);
    }
    if (!nullToAbsent || public != null) {
      map['public'] = Variable<bool>(public);
    }
    if (!nullToAbsent || lastModified != null) {
      map['last_modified'] = Variable<int>(lastModified);
    }
    map['has_items'] = Variable<bool>(hasItems);
    return map;
  }

  PlaylistCompanion toCompanion(bool nullToAbsent) {
    return PlaylistCompanion(
      id: Value(id),
      name: Value(name),
      cover:
          cover == null && nullToAbsent ? const Value.absent() : Value(cover),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      owner:
          owner == null && nullToAbsent ? const Value.absent() : Value(owner),
      public:
          public == null && nullToAbsent ? const Value.absent() : Value(public),
      lastModified: lastModified == null && nullToAbsent
          ? const Value.absent()
          : Value(lastModified),
      hasItems: Value(hasItems),
    );
  }

  factory PlaylistData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      cover: serializer.fromJson<String?>(json['cover']),
      description: serializer.fromJson<String?>(json['description']),
      remoteId: serializer.fromJson<String?>(json['remote_id']),
      owner: serializer.fromJson<String?>(json['owner']),
      public: serializer.fromJson<bool?>(json['public']),
      lastModified: serializer.fromJson<int?>(json['last_modified']),
      hasItems: serializer.fromJson<bool>(json['has_items']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'cover': serializer.toJson<String?>(cover),
      'description': serializer.toJson<String?>(description),
      'remote_id': serializer.toJson<String?>(remoteId),
      'owner': serializer.toJson<String?>(owner),
      'public': serializer.toJson<bool?>(public),
      'last_modified': serializer.toJson<int?>(lastModified),
      'has_items': serializer.toJson<bool>(hasItems),
    };
  }

  PlaylistData copyWith(
          {int? id,
          String? name,
          Value<String?> cover = const Value.absent(),
          Value<String?> description = const Value.absent(),
          Value<String?> remoteId = const Value.absent(),
          Value<String?> owner = const Value.absent(),
          Value<bool?> public = const Value.absent(),
          Value<int?> lastModified = const Value.absent(),
          bool? hasItems}) =>
      PlaylistData(
        id: id ?? this.id,
        name: name ?? this.name,
        cover: cover.present ? cover.value : this.cover,
        description: description.present ? description.value : this.description,
        remoteId: remoteId.present ? remoteId.value : this.remoteId,
        owner: owner.present ? owner.value : this.owner,
        public: public.present ? public.value : this.public,
        lastModified:
            lastModified.present ? lastModified.value : this.lastModified,
        hasItems: hasItems ?? this.hasItems,
      );
  PlaylistData copyWithCompanion(PlaylistCompanion data) {
    return PlaylistData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      cover: data.cover.present ? data.cover.value : this.cover,
      description:
          data.description.present ? data.description.value : this.description,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      owner: data.owner.present ? data.owner.value : this.owner,
      public: data.public.present ? data.public.value : this.public,
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
      hasItems: data.hasItems.present ? data.hasItems.value : this.hasItems,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('cover: $cover, ')
          ..write('description: $description, ')
          ..write('remoteId: $remoteId, ')
          ..write('owner: $owner, ')
          ..write('public: $public, ')
          ..write('lastModified: $lastModified, ')
          ..write('hasItems: $hasItems')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, cover, description, remoteId, owner,
      public, lastModified, hasItems);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistData &&
          other.id == this.id &&
          other.name == this.name &&
          other.cover == this.cover &&
          other.description == this.description &&
          other.remoteId == this.remoteId &&
          other.owner == this.owner &&
          other.public == this.public &&
          other.lastModified == this.lastModified &&
          other.hasItems == this.hasItems);
}

class PlaylistCompanion extends UpdateCompanion<PlaylistData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> cover;
  final Value<String?> description;
  final Value<String?> remoteId;
  final Value<String?> owner;
  final Value<bool?> public;
  final Value<int?> lastModified;
  final Value<bool> hasItems;
  const PlaylistCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.cover = const Value.absent(),
    this.description = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.owner = const Value.absent(),
    this.public = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.hasItems = const Value.absent(),
  });
  PlaylistCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.cover = const Value.absent(),
    this.description = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.owner = const Value.absent(),
    this.public = const Value.absent(),
    this.lastModified = const Value.absent(),
    required bool hasItems,
  })  : name = Value(name),
        hasItems = Value(hasItems);
  static Insertable<PlaylistData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? cover,
    Expression<String>? description,
    Expression<String>? remoteId,
    Expression<String>? owner,
    Expression<bool>? public,
    Expression<int>? lastModified,
    Expression<bool>? hasItems,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (cover != null) 'cover': cover,
      if (description != null) 'description': description,
      if (remoteId != null) 'remote_id': remoteId,
      if (owner != null) 'owner': owner,
      if (public != null) 'public': public,
      if (lastModified != null) 'last_modified': lastModified,
      if (hasItems != null) 'has_items': hasItems,
    });
  }

  PlaylistCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String?>? cover,
      Value<String?>? description,
      Value<String?>? remoteId,
      Value<String?>? owner,
      Value<bool?>? public,
      Value<int?>? lastModified,
      Value<bool>? hasItems}) {
    return PlaylistCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      cover: cover ?? this.cover,
      description: description ?? this.description,
      remoteId: remoteId ?? this.remoteId,
      owner: owner ?? this.owner,
      public: public ?? this.public,
      lastModified: lastModified ?? this.lastModified,
      hasItems: hasItems ?? this.hasItems,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (cover.present) {
      map['cover'] = Variable<String>(cover.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (owner.present) {
      map['owner'] = Variable<String>(owner.value);
    }
    if (public.present) {
      map['public'] = Variable<bool>(public.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<int>(lastModified.value);
    }
    if (hasItems.present) {
      map['has_items'] = Variable<bool>(hasItems.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('cover: $cover, ')
          ..write('description: $description, ')
          ..write('remoteId: $remoteId, ')
          ..write('owner: $owner, ')
          ..write('public: $public, ')
          ..write('lastModified: $lastModified, ')
          ..write('hasItems: $hasItems')
          ..write(')'))
        .toString();
  }
}

class PlaylistItem extends Table
    with TableInfo<PlaylistItem, PlaylistItemData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  PlaylistItem(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT');
  static const VerificationMeta _playlistIdMeta =
      const VerificationMeta('playlistId');
  late final GeneratedColumn<int> playlistId = GeneratedColumn<int>(
      'playlist_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints:
          'NOT NULL DEFAULT \'normal\' CHECK (type IN (\'normal\', \'dummy\', \'album\'))',
      defaultValue: const CustomExpression('\'normal\''));
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _infoMeta = const VerificationMeta('info');
  late final GeneratedColumn<String> info = GeneratedColumn<String>(
      'info', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _remoteIdMeta =
      const VerificationMeta('remoteId');
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
      'remote_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
      'order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  @override
  List<GeneratedColumn> get $columns =>
      [id, playlistId, type, description, info, remoteId, order];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlist_item';
  @override
  VerificationContext validateIntegrity(Insertable<PlaylistItemData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('playlist_id')) {
      context.handle(
          _playlistIdMeta,
          playlistId.isAcceptableOrUnknown(
              data['playlist_id']!, _playlistIdMeta));
    } else if (isInserting) {
      context.missing(_playlistIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('info')) {
      context.handle(
          _infoMeta, info.isAcceptableOrUnknown(data['info']!, _infoMeta));
    } else if (isInserting) {
      context.missing(_infoMeta);
    }
    if (data.containsKey('remote_id')) {
      context.handle(_remoteIdMeta,
          remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta));
    }
    if (data.containsKey('order')) {
      context.handle(
          _orderMeta, order.isAcceptableOrUnknown(data['order']!, _orderMeta));
    } else if (isInserting) {
      context.missing(_orderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaylistItemData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistItemData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      playlistId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}playlist_id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      info: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}info'])!,
      remoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remote_id']),
      order: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order'])!,
    );
  }

  @override
  PlaylistItem createAlias(String alias) {
    return PlaylistItem(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints =>
      const ['FOREIGN KEY(playlist_id)REFERENCES playlist(id)'];
  @override
  bool get dontWriteConstraints => true;
}

class PlaylistItemData extends DataClass
    implements Insertable<PlaylistItemData> {
  final int id;
  final int playlistId;
  final String type;
  final String? description;
  final String info;
  final String? remoteId;
  final int order;
  const PlaylistItemData(
      {required this.id,
      required this.playlistId,
      required this.type,
      this.description,
      required this.info,
      this.remoteId,
      required this.order});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['playlist_id'] = Variable<int>(playlistId);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['info'] = Variable<String>(info);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    map['order'] = Variable<int>(order);
    return map;
  }

  PlaylistItemCompanion toCompanion(bool nullToAbsent) {
    return PlaylistItemCompanion(
      id: Value(id),
      playlistId: Value(playlistId),
      type: Value(type),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      info: Value(info),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      order: Value(order),
    );
  }

  factory PlaylistItemData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistItemData(
      id: serializer.fromJson<int>(json['id']),
      playlistId: serializer.fromJson<int>(json['playlist_id']),
      type: serializer.fromJson<String>(json['type']),
      description: serializer.fromJson<String?>(json['description']),
      info: serializer.fromJson<String>(json['info']),
      remoteId: serializer.fromJson<String?>(json['remote_id']),
      order: serializer.fromJson<int>(json['order']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'playlist_id': serializer.toJson<int>(playlistId),
      'type': serializer.toJson<String>(type),
      'description': serializer.toJson<String?>(description),
      'info': serializer.toJson<String>(info),
      'remote_id': serializer.toJson<String?>(remoteId),
      'order': serializer.toJson<int>(order),
    };
  }

  PlaylistItemData copyWith(
          {int? id,
          int? playlistId,
          String? type,
          Value<String?> description = const Value.absent(),
          String? info,
          Value<String?> remoteId = const Value.absent(),
          int? order}) =>
      PlaylistItemData(
        id: id ?? this.id,
        playlistId: playlistId ?? this.playlistId,
        type: type ?? this.type,
        description: description.present ? description.value : this.description,
        info: info ?? this.info,
        remoteId: remoteId.present ? remoteId.value : this.remoteId,
        order: order ?? this.order,
      );
  PlaylistItemData copyWithCompanion(PlaylistItemCompanion data) {
    return PlaylistItemData(
      id: data.id.present ? data.id.value : this.id,
      playlistId:
          data.playlistId.present ? data.playlistId.value : this.playlistId,
      type: data.type.present ? data.type.value : this.type,
      description:
          data.description.present ? data.description.value : this.description,
      info: data.info.present ? data.info.value : this.info,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      order: data.order.present ? data.order.value : this.order,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistItemData(')
          ..write('id: $id, ')
          ..write('playlistId: $playlistId, ')
          ..write('type: $type, ')
          ..write('description: $description, ')
          ..write('info: $info, ')
          ..write('remoteId: $remoteId, ')
          ..write('order: $order')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, playlistId, type, description, info, remoteId, order);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistItemData &&
          other.id == this.id &&
          other.playlistId == this.playlistId &&
          other.type == this.type &&
          other.description == this.description &&
          other.info == this.info &&
          other.remoteId == this.remoteId &&
          other.order == this.order);
}

class PlaylistItemCompanion extends UpdateCompanion<PlaylistItemData> {
  final Value<int> id;
  final Value<int> playlistId;
  final Value<String> type;
  final Value<String?> description;
  final Value<String> info;
  final Value<String?> remoteId;
  final Value<int> order;
  const PlaylistItemCompanion({
    this.id = const Value.absent(),
    this.playlistId = const Value.absent(),
    this.type = const Value.absent(),
    this.description = const Value.absent(),
    this.info = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.order = const Value.absent(),
  });
  PlaylistItemCompanion.insert({
    this.id = const Value.absent(),
    required int playlistId,
    this.type = const Value.absent(),
    this.description = const Value.absent(),
    required String info,
    this.remoteId = const Value.absent(),
    required int order,
  })  : playlistId = Value(playlistId),
        info = Value(info),
        order = Value(order);
  static Insertable<PlaylistItemData> custom({
    Expression<int>? id,
    Expression<int>? playlistId,
    Expression<String>? type,
    Expression<String>? description,
    Expression<String>? info,
    Expression<String>? remoteId,
    Expression<int>? order,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (playlistId != null) 'playlist_id': playlistId,
      if (type != null) 'type': type,
      if (description != null) 'description': description,
      if (info != null) 'info': info,
      if (remoteId != null) 'remote_id': remoteId,
      if (order != null) 'order': order,
    });
  }

  PlaylistItemCompanion copyWith(
      {Value<int>? id,
      Value<int>? playlistId,
      Value<String>? type,
      Value<String?>? description,
      Value<String>? info,
      Value<String?>? remoteId,
      Value<int>? order}) {
    return PlaylistItemCompanion(
      id: id ?? this.id,
      playlistId: playlistId ?? this.playlistId,
      type: type ?? this.type,
      description: description ?? this.description,
      info: info ?? this.info,
      remoteId: remoteId ?? this.remoteId,
      order: order ?? this.order,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (playlistId.present) {
      map['playlist_id'] = Variable<int>(playlistId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (info.present) {
      map['info'] = Variable<String>(info.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistItemCompanion(')
          ..write('id: $id, ')
          ..write('playlistId: $playlistId, ')
          ..write('type: $type, ')
          ..write('description: $description, ')
          ..write('info: $info, ')
          ..write('remoteId: $remoteId, ')
          ..write('order: $order')
          ..write(')'))
        .toString();
  }
}

class LocalFavoriteTracks extends Table
    with TableInfo<LocalFavoriteTracks, LocalFavoriteTrack> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  LocalFavoriteTracks(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT');
  static const VerificationMeta _albumIdMeta =
      const VerificationMeta('albumId');
  late final GeneratedColumn<String> albumId = GeneratedColumn<String>(
      'album_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _discIdMeta = const VerificationMeta('discId');
  late final GeneratedColumn<int> discId = GeneratedColumn<int>(
      'disc_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _trackIdMeta =
      const VerificationMeta('trackId');
  late final GeneratedColumn<int> trackId = GeneratedColumn<int>(
      'track_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
      'artist', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _albumTitleMeta =
      const VerificationMeta('albumTitle');
  late final GeneratedColumn<String> albumTitle = GeneratedColumn<String>(
      'album_title', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints:
          'NOT NULL DEFAULT \'normal\' CHECK (type IN (\'normal\', \'instrumental\', \'absolute\', \'drama\', \'radio\', \'vocal\'))',
      defaultValue: const CustomExpression('\'normal\''));
  @override
  List<GeneratedColumn> get $columns =>
      [id, albumId, discId, trackId, title, artist, albumTitle, type];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_favorite_tracks';
  @override
  VerificationContext validateIntegrity(Insertable<LocalFavoriteTrack> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('album_id')) {
      context.handle(_albumIdMeta,
          albumId.isAcceptableOrUnknown(data['album_id']!, _albumIdMeta));
    } else if (isInserting) {
      context.missing(_albumIdMeta);
    }
    if (data.containsKey('disc_id')) {
      context.handle(_discIdMeta,
          discId.isAcceptableOrUnknown(data['disc_id']!, _discIdMeta));
    } else if (isInserting) {
      context.missing(_discIdMeta);
    }
    if (data.containsKey('track_id')) {
      context.handle(_trackIdMeta,
          trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta));
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('artist')) {
      context.handle(_artistMeta,
          artist.isAcceptableOrUnknown(data['artist']!, _artistMeta));
    }
    if (data.containsKey('album_title')) {
      context.handle(
          _albumTitleMeta,
          albumTitle.isAcceptableOrUnknown(
              data['album_title']!, _albumTitleMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalFavoriteTrack map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalFavoriteTrack(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      albumId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}album_id'])!,
      discId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}disc_id'])!,
      trackId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}track_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title']),
      artist: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}artist']),
      albumTitle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}album_title']),
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
    );
  }

  @override
  LocalFavoriteTracks createAlias(String alias) {
    return LocalFavoriteTracks(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class LocalFavoriteTrack extends DataClass
    implements Insertable<LocalFavoriteTrack> {
  final int id;
  final String albumId;
  final int discId;
  final int trackId;

  /// some metadata
  final String? title;
  final String? artist;
  final String? albumTitle;
  final String type;
  const LocalFavoriteTrack(
      {required this.id,
      required this.albumId,
      required this.discId,
      required this.trackId,
      this.title,
      this.artist,
      this.albumTitle,
      required this.type});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['album_id'] = Variable<String>(albumId);
    map['disc_id'] = Variable<int>(discId);
    map['track_id'] = Variable<int>(trackId);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || artist != null) {
      map['artist'] = Variable<String>(artist);
    }
    if (!nullToAbsent || albumTitle != null) {
      map['album_title'] = Variable<String>(albumTitle);
    }
    map['type'] = Variable<String>(type);
    return map;
  }

  LocalFavoriteTracksCompanion toCompanion(bool nullToAbsent) {
    return LocalFavoriteTracksCompanion(
      id: Value(id),
      albumId: Value(albumId),
      discId: Value(discId),
      trackId: Value(trackId),
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
      artist:
          artist == null && nullToAbsent ? const Value.absent() : Value(artist),
      albumTitle: albumTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(albumTitle),
      type: Value(type),
    );
  }

  factory LocalFavoriteTrack.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalFavoriteTrack(
      id: serializer.fromJson<int>(json['id']),
      albumId: serializer.fromJson<String>(json['album_id']),
      discId: serializer.fromJson<int>(json['disc_id']),
      trackId: serializer.fromJson<int>(json['track_id']),
      title: serializer.fromJson<String?>(json['title']),
      artist: serializer.fromJson<String?>(json['artist']),
      albumTitle: serializer.fromJson<String?>(json['album_title']),
      type: serializer.fromJson<String>(json['type']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'album_id': serializer.toJson<String>(albumId),
      'disc_id': serializer.toJson<int>(discId),
      'track_id': serializer.toJson<int>(trackId),
      'title': serializer.toJson<String?>(title),
      'artist': serializer.toJson<String?>(artist),
      'album_title': serializer.toJson<String?>(albumTitle),
      'type': serializer.toJson<String>(type),
    };
  }

  LocalFavoriteTrack copyWith(
          {int? id,
          String? albumId,
          int? discId,
          int? trackId,
          Value<String?> title = const Value.absent(),
          Value<String?> artist = const Value.absent(),
          Value<String?> albumTitle = const Value.absent(),
          String? type}) =>
      LocalFavoriteTrack(
        id: id ?? this.id,
        albumId: albumId ?? this.albumId,
        discId: discId ?? this.discId,
        trackId: trackId ?? this.trackId,
        title: title.present ? title.value : this.title,
        artist: artist.present ? artist.value : this.artist,
        albumTitle: albumTitle.present ? albumTitle.value : this.albumTitle,
        type: type ?? this.type,
      );
  LocalFavoriteTrack copyWithCompanion(LocalFavoriteTracksCompanion data) {
    return LocalFavoriteTrack(
      id: data.id.present ? data.id.value : this.id,
      albumId: data.albumId.present ? data.albumId.value : this.albumId,
      discId: data.discId.present ? data.discId.value : this.discId,
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      title: data.title.present ? data.title.value : this.title,
      artist: data.artist.present ? data.artist.value : this.artist,
      albumTitle:
          data.albumTitle.present ? data.albumTitle.value : this.albumTitle,
      type: data.type.present ? data.type.value : this.type,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalFavoriteTrack(')
          ..write('id: $id, ')
          ..write('albumId: $albumId, ')
          ..write('discId: $discId, ')
          ..write('trackId: $trackId, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('albumTitle: $albumTitle, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, albumId, discId, trackId, title, artist, albumTitle, type);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalFavoriteTrack &&
          other.id == this.id &&
          other.albumId == this.albumId &&
          other.discId == this.discId &&
          other.trackId == this.trackId &&
          other.title == this.title &&
          other.artist == this.artist &&
          other.albumTitle == this.albumTitle &&
          other.type == this.type);
}

class LocalFavoriteTracksCompanion extends UpdateCompanion<LocalFavoriteTrack> {
  final Value<int> id;
  final Value<String> albumId;
  final Value<int> discId;
  final Value<int> trackId;
  final Value<String?> title;
  final Value<String?> artist;
  final Value<String?> albumTitle;
  final Value<String> type;
  const LocalFavoriteTracksCompanion({
    this.id = const Value.absent(),
    this.albumId = const Value.absent(),
    this.discId = const Value.absent(),
    this.trackId = const Value.absent(),
    this.title = const Value.absent(),
    this.artist = const Value.absent(),
    this.albumTitle = const Value.absent(),
    this.type = const Value.absent(),
  });
  LocalFavoriteTracksCompanion.insert({
    this.id = const Value.absent(),
    required String albumId,
    required int discId,
    required int trackId,
    this.title = const Value.absent(),
    this.artist = const Value.absent(),
    this.albumTitle = const Value.absent(),
    this.type = const Value.absent(),
  })  : albumId = Value(albumId),
        discId = Value(discId),
        trackId = Value(trackId);
  static Insertable<LocalFavoriteTrack> custom({
    Expression<int>? id,
    Expression<String>? albumId,
    Expression<int>? discId,
    Expression<int>? trackId,
    Expression<String>? title,
    Expression<String>? artist,
    Expression<String>? albumTitle,
    Expression<String>? type,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (albumId != null) 'album_id': albumId,
      if (discId != null) 'disc_id': discId,
      if (trackId != null) 'track_id': trackId,
      if (title != null) 'title': title,
      if (artist != null) 'artist': artist,
      if (albumTitle != null) 'album_title': albumTitle,
      if (type != null) 'type': type,
    });
  }

  LocalFavoriteTracksCompanion copyWith(
      {Value<int>? id,
      Value<String>? albumId,
      Value<int>? discId,
      Value<int>? trackId,
      Value<String?>? title,
      Value<String?>? artist,
      Value<String?>? albumTitle,
      Value<String>? type}) {
    return LocalFavoriteTracksCompanion(
      id: id ?? this.id,
      albumId: albumId ?? this.albumId,
      discId: discId ?? this.discId,
      trackId: trackId ?? this.trackId,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      albumTitle: albumTitle ?? this.albumTitle,
      type: type ?? this.type,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (albumId.present) {
      map['album_id'] = Variable<String>(albumId.value);
    }
    if (discId.present) {
      map['disc_id'] = Variable<int>(discId.value);
    }
    if (trackId.present) {
      map['track_id'] = Variable<int>(trackId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (albumTitle.present) {
      map['album_title'] = Variable<String>(albumTitle.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalFavoriteTracksCompanion(')
          ..write('id: $id, ')
          ..write('albumId: $albumId, ')
          ..write('discId: $discId, ')
          ..write('trackId: $trackId, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('albumTitle: $albumTitle, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }
}

class LocalFavoriteAlbums extends Table
    with TableInfo<LocalFavoriteAlbums, LocalFavoriteAlbum> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  LocalFavoriteAlbums(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT');
  static const VerificationMeta _albumIdMeta =
      const VerificationMeta('albumId');
  late final GeneratedColumn<String> albumId = GeneratedColumn<String>(
      'album_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  @override
  List<GeneratedColumn> get $columns => [id, albumId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_favorite_albums';
  @override
  VerificationContext validateIntegrity(Insertable<LocalFavoriteAlbum> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('album_id')) {
      context.handle(_albumIdMeta,
          albumId.isAcceptableOrUnknown(data['album_id']!, _albumIdMeta));
    } else if (isInserting) {
      context.missing(_albumIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalFavoriteAlbum map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalFavoriteAlbum(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      albumId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}album_id'])!,
    );
  }

  @override
  LocalFavoriteAlbums createAlias(String alias) {
    return LocalFavoriteAlbums(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class LocalFavoriteAlbum extends DataClass
    implements Insertable<LocalFavoriteAlbum> {
  final int id;
  final String albumId;
  const LocalFavoriteAlbum({required this.id, required this.albumId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['album_id'] = Variable<String>(albumId);
    return map;
  }

  LocalFavoriteAlbumsCompanion toCompanion(bool nullToAbsent) {
    return LocalFavoriteAlbumsCompanion(
      id: Value(id),
      albumId: Value(albumId),
    );
  }

  factory LocalFavoriteAlbum.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalFavoriteAlbum(
      id: serializer.fromJson<int>(json['id']),
      albumId: serializer.fromJson<String>(json['album_id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'album_id': serializer.toJson<String>(albumId),
    };
  }

  LocalFavoriteAlbum copyWith({int? id, String? albumId}) => LocalFavoriteAlbum(
        id: id ?? this.id,
        albumId: albumId ?? this.albumId,
      );
  LocalFavoriteAlbum copyWithCompanion(LocalFavoriteAlbumsCompanion data) {
    return LocalFavoriteAlbum(
      id: data.id.present ? data.id.value : this.id,
      albumId: data.albumId.present ? data.albumId.value : this.albumId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalFavoriteAlbum(')
          ..write('id: $id, ')
          ..write('albumId: $albumId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, albumId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalFavoriteAlbum &&
          other.id == this.id &&
          other.albumId == this.albumId);
}

class LocalFavoriteAlbumsCompanion extends UpdateCompanion<LocalFavoriteAlbum> {
  final Value<int> id;
  final Value<String> albumId;
  const LocalFavoriteAlbumsCompanion({
    this.id = const Value.absent(),
    this.albumId = const Value.absent(),
  });
  LocalFavoriteAlbumsCompanion.insert({
    this.id = const Value.absent(),
    required String albumId,
  }) : albumId = Value(albumId);
  static Insertable<LocalFavoriteAlbum> custom({
    Expression<int>? id,
    Expression<String>? albumId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (albumId != null) 'album_id': albumId,
    });
  }

  LocalFavoriteAlbumsCompanion copyWith(
      {Value<int>? id, Value<String>? albumId}) {
    return LocalFavoriteAlbumsCompanion(
      id: id ?? this.id,
      albumId: albumId ?? this.albumId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (albumId.present) {
      map['album_id'] = Variable<String>(albumId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalFavoriteAlbumsCompanion(')
          ..write('id: $id, ')
          ..write('albumId: $albumId')
          ..write(')'))
        .toString();
  }
}

class LocalAnnilServers extends Table
    with TableInfo<LocalAnnilServers, LocalAnnilServer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  LocalAnnilServers(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT');
  static const VerificationMeta _remoteIdMeta =
      const VerificationMeta('remoteId');
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
      'remote_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _tokenMeta = const VerificationMeta('token');
  late final GeneratedColumn<String> token = GeneratedColumn<String>(
      'token', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
      'priority', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  @override
  List<GeneratedColumn> get $columns =>
      [id, remoteId, name, url, token, priority];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_annil_servers';
  @override
  VerificationContext validateIntegrity(Insertable<LocalAnnilServer> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('remote_id')) {
      context.handle(_remoteIdMeta,
          remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('token')) {
      context.handle(
          _tokenMeta, token.isAcceptableOrUnknown(data['token']!, _tokenMeta));
    } else if (isInserting) {
      context.missing(_tokenMeta);
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    } else if (isInserting) {
      context.missing(_priorityMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalAnnilServer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAnnilServer(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      remoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remote_id']),
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url'])!,
      token: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}token'])!,
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}priority'])!,
    );
  }

  @override
  LocalAnnilServers createAlias(String alias) {
    return LocalAnnilServers(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class LocalAnnilServer extends DataClass
    implements Insertable<LocalAnnilServer> {
  final int id;
  final String? remoteId;
  final String name;
  final String url;
  final String token;
  final int priority;
  const LocalAnnilServer(
      {required this.id,
      this.remoteId,
      required this.name,
      required this.url,
      required this.token,
      required this.priority});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    map['name'] = Variable<String>(name);
    map['url'] = Variable<String>(url);
    map['token'] = Variable<String>(token);
    map['priority'] = Variable<int>(priority);
    return map;
  }

  LocalAnnilServersCompanion toCompanion(bool nullToAbsent) {
    return LocalAnnilServersCompanion(
      id: Value(id),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      name: Value(name),
      url: Value(url),
      token: Value(token),
      priority: Value(priority),
    );
  }

  factory LocalAnnilServer.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAnnilServer(
      id: serializer.fromJson<int>(json['id']),
      remoteId: serializer.fromJson<String?>(json['remote_id']),
      name: serializer.fromJson<String>(json['name']),
      url: serializer.fromJson<String>(json['url']),
      token: serializer.fromJson<String>(json['token']),
      priority: serializer.fromJson<int>(json['priority']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'remote_id': serializer.toJson<String?>(remoteId),
      'name': serializer.toJson<String>(name),
      'url': serializer.toJson<String>(url),
      'token': serializer.toJson<String>(token),
      'priority': serializer.toJson<int>(priority),
    };
  }

  LocalAnnilServer copyWith(
          {int? id,
          Value<String?> remoteId = const Value.absent(),
          String? name,
          String? url,
          String? token,
          int? priority}) =>
      LocalAnnilServer(
        id: id ?? this.id,
        remoteId: remoteId.present ? remoteId.value : this.remoteId,
        name: name ?? this.name,
        url: url ?? this.url,
        token: token ?? this.token,
        priority: priority ?? this.priority,
      );
  LocalAnnilServer copyWithCompanion(LocalAnnilServersCompanion data) {
    return LocalAnnilServer(
      id: data.id.present ? data.id.value : this.id,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      name: data.name.present ? data.name.value : this.name,
      url: data.url.present ? data.url.value : this.url,
      token: data.token.present ? data.token.value : this.token,
      priority: data.priority.present ? data.priority.value : this.priority,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAnnilServer(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('name: $name, ')
          ..write('url: $url, ')
          ..write('token: $token, ')
          ..write('priority: $priority')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, remoteId, name, url, token, priority);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAnnilServer &&
          other.id == this.id &&
          other.remoteId == this.remoteId &&
          other.name == this.name &&
          other.url == this.url &&
          other.token == this.token &&
          other.priority == this.priority);
}

class LocalAnnilServersCompanion extends UpdateCompanion<LocalAnnilServer> {
  final Value<int> id;
  final Value<String?> remoteId;
  final Value<String> name;
  final Value<String> url;
  final Value<String> token;
  final Value<int> priority;
  const LocalAnnilServersCompanion({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.name = const Value.absent(),
    this.url = const Value.absent(),
    this.token = const Value.absent(),
    this.priority = const Value.absent(),
  });
  LocalAnnilServersCompanion.insert({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    required String name,
    required String url,
    required String token,
    required int priority,
  })  : name = Value(name),
        url = Value(url),
        token = Value(token),
        priority = Value(priority);
  static Insertable<LocalAnnilServer> custom({
    Expression<int>? id,
    Expression<String>? remoteId,
    Expression<String>? name,
    Expression<String>? url,
    Expression<String>? token,
    Expression<int>? priority,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteId != null) 'remote_id': remoteId,
      if (name != null) 'name': name,
      if (url != null) 'url': url,
      if (token != null) 'token': token,
      if (priority != null) 'priority': priority,
    });
  }

  LocalAnnilServersCompanion copyWith(
      {Value<int>? id,
      Value<String?>? remoteId,
      Value<String>? name,
      Value<String>? url,
      Value<String>? token,
      Value<int>? priority}) {
    return LocalAnnilServersCompanion(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      name: name ?? this.name,
      url: url ?? this.url,
      token: token ?? this.token,
      priority: priority ?? this.priority,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (token.present) {
      map['token'] = Variable<String>(token.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAnnilServersCompanion(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('name: $name, ')
          ..write('url: $url, ')
          ..write('token: $token, ')
          ..write('priority: $priority')
          ..write(')'))
        .toString();
  }
}

class LocalAnnilCaches extends Table
    with TableInfo<LocalAnnilCaches, LocalAnnilCache> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  LocalAnnilCaches(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _annilIdMeta =
      const VerificationMeta('annilId');
  late final GeneratedColumn<int> annilId = GeneratedColumn<int>(
      'annil_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL PRIMARY KEY');
  static const VerificationMeta _etagMeta = const VerificationMeta('etag');
  late final GeneratedColumn<String> etag = GeneratedColumn<String>(
      'etag', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _lastUpdateMeta =
      const VerificationMeta('lastUpdate');
  late final GeneratedColumn<int> lastUpdate = GeneratedColumn<int>(
      'last_update', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  @override
  List<GeneratedColumn> get $columns => [annilId, etag, lastUpdate];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_annil_caches';
  @override
  VerificationContext validateIntegrity(Insertable<LocalAnnilCache> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('annil_id')) {
      context.handle(_annilIdMeta,
          annilId.isAcceptableOrUnknown(data['annil_id']!, _annilIdMeta));
    }
    if (data.containsKey('etag')) {
      context.handle(
          _etagMeta, etag.isAcceptableOrUnknown(data['etag']!, _etagMeta));
    }
    if (data.containsKey('last_update')) {
      context.handle(
          _lastUpdateMeta,
          lastUpdate.isAcceptableOrUnknown(
              data['last_update']!, _lastUpdateMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {annilId};
  @override
  LocalAnnilCache map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAnnilCache(
      annilId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}annil_id'])!,
      etag: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}etag']),
      lastUpdate: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_update']),
    );
  }

  @override
  LocalAnnilCaches createAlias(String alias) {
    return LocalAnnilCaches(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints =>
      const ['FOREIGN KEY(annil_id)REFERENCES local_annil_servers(id)'];
  @override
  bool get dontWriteConstraints => true;
}

class LocalAnnilCache extends DataClass implements Insertable<LocalAnnilCache> {
  final int annilId;
  final String? etag;
  final int? lastUpdate;
  const LocalAnnilCache({required this.annilId, this.etag, this.lastUpdate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['annil_id'] = Variable<int>(annilId);
    if (!nullToAbsent || etag != null) {
      map['etag'] = Variable<String>(etag);
    }
    if (!nullToAbsent || lastUpdate != null) {
      map['last_update'] = Variable<int>(lastUpdate);
    }
    return map;
  }

  LocalAnnilCachesCompanion toCompanion(bool nullToAbsent) {
    return LocalAnnilCachesCompanion(
      annilId: Value(annilId),
      etag: etag == null && nullToAbsent ? const Value.absent() : Value(etag),
      lastUpdate: lastUpdate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUpdate),
    );
  }

  factory LocalAnnilCache.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAnnilCache(
      annilId: serializer.fromJson<int>(json['annil_id']),
      etag: serializer.fromJson<String?>(json['etag']),
      lastUpdate: serializer.fromJson<int?>(json['last_update']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'annil_id': serializer.toJson<int>(annilId),
      'etag': serializer.toJson<String?>(etag),
      'last_update': serializer.toJson<int?>(lastUpdate),
    };
  }

  LocalAnnilCache copyWith(
          {int? annilId,
          Value<String?> etag = const Value.absent(),
          Value<int?> lastUpdate = const Value.absent()}) =>
      LocalAnnilCache(
        annilId: annilId ?? this.annilId,
        etag: etag.present ? etag.value : this.etag,
        lastUpdate: lastUpdate.present ? lastUpdate.value : this.lastUpdate,
      );
  LocalAnnilCache copyWithCompanion(LocalAnnilCachesCompanion data) {
    return LocalAnnilCache(
      annilId: data.annilId.present ? data.annilId.value : this.annilId,
      etag: data.etag.present ? data.etag.value : this.etag,
      lastUpdate:
          data.lastUpdate.present ? data.lastUpdate.value : this.lastUpdate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAnnilCache(')
          ..write('annilId: $annilId, ')
          ..write('etag: $etag, ')
          ..write('lastUpdate: $lastUpdate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(annilId, etag, lastUpdate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAnnilCache &&
          other.annilId == this.annilId &&
          other.etag == this.etag &&
          other.lastUpdate == this.lastUpdate);
}

class LocalAnnilCachesCompanion extends UpdateCompanion<LocalAnnilCache> {
  final Value<int> annilId;
  final Value<String?> etag;
  final Value<int?> lastUpdate;
  const LocalAnnilCachesCompanion({
    this.annilId = const Value.absent(),
    this.etag = const Value.absent(),
    this.lastUpdate = const Value.absent(),
  });
  LocalAnnilCachesCompanion.insert({
    this.annilId = const Value.absent(),
    this.etag = const Value.absent(),
    this.lastUpdate = const Value.absent(),
  });
  static Insertable<LocalAnnilCache> custom({
    Expression<int>? annilId,
    Expression<String>? etag,
    Expression<int>? lastUpdate,
  }) {
    return RawValuesInsertable({
      if (annilId != null) 'annil_id': annilId,
      if (etag != null) 'etag': etag,
      if (lastUpdate != null) 'last_update': lastUpdate,
    });
  }

  LocalAnnilCachesCompanion copyWith(
      {Value<int>? annilId, Value<String?>? etag, Value<int?>? lastUpdate}) {
    return LocalAnnilCachesCompanion(
      annilId: annilId ?? this.annilId,
      etag: etag ?? this.etag,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (annilId.present) {
      map['annil_id'] = Variable<int>(annilId.value);
    }
    if (etag.present) {
      map['etag'] = Variable<String>(etag.value);
    }
    if (lastUpdate.present) {
      map['last_update'] = Variable<int>(lastUpdate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAnnilCachesCompanion(')
          ..write('annilId: $annilId, ')
          ..write('etag: $etag, ')
          ..write('lastUpdate: $lastUpdate')
          ..write(')'))
        .toString();
  }
}

class LocalAnnilAlbums extends Table
    with TableInfo<LocalAnnilAlbums, LocalAnnilAlbum> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  LocalAnnilAlbums(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT');
  static const VerificationMeta _annilIdMeta =
      const VerificationMeta('annilId');
  late final GeneratedColumn<int> annilId = GeneratedColumn<int>(
      'annil_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _albumIdMeta =
      const VerificationMeta('albumId');
  late final GeneratedColumn<String> albumId = GeneratedColumn<String>(
      'album_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  @override
  List<GeneratedColumn> get $columns => [id, annilId, albumId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_annil_albums';
  @override
  VerificationContext validateIntegrity(Insertable<LocalAnnilAlbum> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('annil_id')) {
      context.handle(_annilIdMeta,
          annilId.isAcceptableOrUnknown(data['annil_id']!, _annilIdMeta));
    } else if (isInserting) {
      context.missing(_annilIdMeta);
    }
    if (data.containsKey('album_id')) {
      context.handle(_albumIdMeta,
          albumId.isAcceptableOrUnknown(data['album_id']!, _albumIdMeta));
    } else if (isInserting) {
      context.missing(_albumIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalAnnilAlbum map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAnnilAlbum(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      annilId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}annil_id'])!,
      albumId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}album_id'])!,
    );
  }

  @override
  LocalAnnilAlbums createAlias(String alias) {
    return LocalAnnilAlbums(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints =>
      const ['FOREIGN KEY(annil_id)REFERENCES local_annil_servers(id)'];
  @override
  bool get dontWriteConstraints => true;
}

class LocalAnnilAlbum extends DataClass implements Insertable<LocalAnnilAlbum> {
  final int id;
  final int annilId;
  final String albumId;
  const LocalAnnilAlbum(
      {required this.id, required this.annilId, required this.albumId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['annil_id'] = Variable<int>(annilId);
    map['album_id'] = Variable<String>(albumId);
    return map;
  }

  LocalAnnilAlbumsCompanion toCompanion(bool nullToAbsent) {
    return LocalAnnilAlbumsCompanion(
      id: Value(id),
      annilId: Value(annilId),
      albumId: Value(albumId),
    );
  }

  factory LocalAnnilAlbum.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAnnilAlbum(
      id: serializer.fromJson<int>(json['id']),
      annilId: serializer.fromJson<int>(json['annil_id']),
      albumId: serializer.fromJson<String>(json['album_id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'annil_id': serializer.toJson<int>(annilId),
      'album_id': serializer.toJson<String>(albumId),
    };
  }

  LocalAnnilAlbum copyWith({int? id, int? annilId, String? albumId}) =>
      LocalAnnilAlbum(
        id: id ?? this.id,
        annilId: annilId ?? this.annilId,
        albumId: albumId ?? this.albumId,
      );
  LocalAnnilAlbum copyWithCompanion(LocalAnnilAlbumsCompanion data) {
    return LocalAnnilAlbum(
      id: data.id.present ? data.id.value : this.id,
      annilId: data.annilId.present ? data.annilId.value : this.annilId,
      albumId: data.albumId.present ? data.albumId.value : this.albumId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAnnilAlbum(')
          ..write('id: $id, ')
          ..write('annilId: $annilId, ')
          ..write('albumId: $albumId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, annilId, albumId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAnnilAlbum &&
          other.id == this.id &&
          other.annilId == this.annilId &&
          other.albumId == this.albumId);
}

class LocalAnnilAlbumsCompanion extends UpdateCompanion<LocalAnnilAlbum> {
  final Value<int> id;
  final Value<int> annilId;
  final Value<String> albumId;
  const LocalAnnilAlbumsCompanion({
    this.id = const Value.absent(),
    this.annilId = const Value.absent(),
    this.albumId = const Value.absent(),
  });
  LocalAnnilAlbumsCompanion.insert({
    this.id = const Value.absent(),
    required int annilId,
    required String albumId,
  })  : annilId = Value(annilId),
        albumId = Value(albumId);
  static Insertable<LocalAnnilAlbum> custom({
    Expression<int>? id,
    Expression<int>? annilId,
    Expression<String>? albumId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (annilId != null) 'annil_id': annilId,
      if (albumId != null) 'album_id': albumId,
    });
  }

  LocalAnnilAlbumsCompanion copyWith(
      {Value<int>? id, Value<int>? annilId, Value<String>? albumId}) {
    return LocalAnnilAlbumsCompanion(
      id: id ?? this.id,
      annilId: annilId ?? this.annilId,
      albumId: albumId ?? this.albumId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (annilId.present) {
      map['annil_id'] = Variable<int>(annilId.value);
    }
    if (albumId.present) {
      map['album_id'] = Variable<String>(albumId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAnnilAlbumsCompanion(')
          ..write('id: $id, ')
          ..write('annilId: $annilId, ')
          ..write('albumId: $albumId')
          ..write(')'))
        .toString();
  }
}

class PlaybackRecords extends Table
    with TableInfo<PlaybackRecords, PlaybackRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  PlaybackRecords(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT');
  static const VerificationMeta _albumIdMeta =
      const VerificationMeta('albumId');
  late final GeneratedColumn<String> albumId = GeneratedColumn<String>(
      'album_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _discIdMeta = const VerificationMeta('discId');
  late final GeneratedColumn<int> discId = GeneratedColumn<int>(
      'disc_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _trackIdMeta =
      const VerificationMeta('trackId');
  late final GeneratedColumn<int> trackId = GeneratedColumn<int>(
      'track_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  late final GeneratedColumn<int> at = GeneratedColumn<int>(
      'at', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _lockedMeta = const VerificationMeta('locked');
  late final GeneratedColumn<bool> locked = GeneratedColumn<bool>(
      'locked', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  @override
  List<GeneratedColumn> get $columns =>
      [id, albumId, discId, trackId, at, locked];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playback_records';
  @override
  VerificationContext validateIntegrity(Insertable<PlaybackRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('album_id')) {
      context.handle(_albumIdMeta,
          albumId.isAcceptableOrUnknown(data['album_id']!, _albumIdMeta));
    } else if (isInserting) {
      context.missing(_albumIdMeta);
    }
    if (data.containsKey('disc_id')) {
      context.handle(_discIdMeta,
          discId.isAcceptableOrUnknown(data['disc_id']!, _discIdMeta));
    } else if (isInserting) {
      context.missing(_discIdMeta);
    }
    if (data.containsKey('track_id')) {
      context.handle(_trackIdMeta,
          trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta));
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('locked')) {
      context.handle(_lockedMeta,
          locked.isAcceptableOrUnknown(data['locked']!, _lockedMeta));
    } else if (isInserting) {
      context.missing(_lockedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaybackRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaybackRecord(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      albumId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}album_id'])!,
      discId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}disc_id'])!,
      trackId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}track_id'])!,
      at: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}at'])!,
      locked: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}locked'])!,
    );
  }

  @override
  PlaybackRecords createAlias(String alias) {
    return PlaybackRecords(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class PlaybackRecord extends DataClass implements Insertable<PlaybackRecord> {
  final int id;

  /// Played track
  final String albumId;
  final int discId;
  final int trackId;

  /// Playback time
  final int at;

  /// Whether this record is uploading to anniv server
  final bool locked;
  const PlaybackRecord(
      {required this.id,
      required this.albumId,
      required this.discId,
      required this.trackId,
      required this.at,
      required this.locked});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['album_id'] = Variable<String>(albumId);
    map['disc_id'] = Variable<int>(discId);
    map['track_id'] = Variable<int>(trackId);
    map['at'] = Variable<int>(at);
    map['locked'] = Variable<bool>(locked);
    return map;
  }

  PlaybackRecordsCompanion toCompanion(bool nullToAbsent) {
    return PlaybackRecordsCompanion(
      id: Value(id),
      albumId: Value(albumId),
      discId: Value(discId),
      trackId: Value(trackId),
      at: Value(at),
      locked: Value(locked),
    );
  }

  factory PlaybackRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaybackRecord(
      id: serializer.fromJson<int>(json['id']),
      albumId: serializer.fromJson<String>(json['album_id']),
      discId: serializer.fromJson<int>(json['disc_id']),
      trackId: serializer.fromJson<int>(json['track_id']),
      at: serializer.fromJson<int>(json['at']),
      locked: serializer.fromJson<bool>(json['locked']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'album_id': serializer.toJson<String>(albumId),
      'disc_id': serializer.toJson<int>(discId),
      'track_id': serializer.toJson<int>(trackId),
      'at': serializer.toJson<int>(at),
      'locked': serializer.toJson<bool>(locked),
    };
  }

  PlaybackRecord copyWith(
          {int? id,
          String? albumId,
          int? discId,
          int? trackId,
          int? at,
          bool? locked}) =>
      PlaybackRecord(
        id: id ?? this.id,
        albumId: albumId ?? this.albumId,
        discId: discId ?? this.discId,
        trackId: trackId ?? this.trackId,
        at: at ?? this.at,
        locked: locked ?? this.locked,
      );
  PlaybackRecord copyWithCompanion(PlaybackRecordsCompanion data) {
    return PlaybackRecord(
      id: data.id.present ? data.id.value : this.id,
      albumId: data.albumId.present ? data.albumId.value : this.albumId,
      discId: data.discId.present ? data.discId.value : this.discId,
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      at: data.at.present ? data.at.value : this.at,
      locked: data.locked.present ? data.locked.value : this.locked,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaybackRecord(')
          ..write('id: $id, ')
          ..write('albumId: $albumId, ')
          ..write('discId: $discId, ')
          ..write('trackId: $trackId, ')
          ..write('at: $at, ')
          ..write('locked: $locked')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, albumId, discId, trackId, at, locked);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaybackRecord &&
          other.id == this.id &&
          other.albumId == this.albumId &&
          other.discId == this.discId &&
          other.trackId == this.trackId &&
          other.at == this.at &&
          other.locked == this.locked);
}

class PlaybackRecordsCompanion extends UpdateCompanion<PlaybackRecord> {
  final Value<int> id;
  final Value<String> albumId;
  final Value<int> discId;
  final Value<int> trackId;
  final Value<int> at;
  final Value<bool> locked;
  const PlaybackRecordsCompanion({
    this.id = const Value.absent(),
    this.albumId = const Value.absent(),
    this.discId = const Value.absent(),
    this.trackId = const Value.absent(),
    this.at = const Value.absent(),
    this.locked = const Value.absent(),
  });
  PlaybackRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String albumId,
    required int discId,
    required int trackId,
    required int at,
    required bool locked,
  })  : albumId = Value(albumId),
        discId = Value(discId),
        trackId = Value(trackId),
        at = Value(at),
        locked = Value(locked);
  static Insertable<PlaybackRecord> custom({
    Expression<int>? id,
    Expression<String>? albumId,
    Expression<int>? discId,
    Expression<int>? trackId,
    Expression<int>? at,
    Expression<bool>? locked,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (albumId != null) 'album_id': albumId,
      if (discId != null) 'disc_id': discId,
      if (trackId != null) 'track_id': trackId,
      if (at != null) 'at': at,
      if (locked != null) 'locked': locked,
    });
  }

  PlaybackRecordsCompanion copyWith(
      {Value<int>? id,
      Value<String>? albumId,
      Value<int>? discId,
      Value<int>? trackId,
      Value<int>? at,
      Value<bool>? locked}) {
    return PlaybackRecordsCompanion(
      id: id ?? this.id,
      albumId: albumId ?? this.albumId,
      discId: discId ?? this.discId,
      trackId: trackId ?? this.trackId,
      at: at ?? this.at,
      locked: locked ?? this.locked,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (albumId.present) {
      map['album_id'] = Variable<String>(albumId.value);
    }
    if (discId.present) {
      map['disc_id'] = Variable<int>(discId.value);
    }
    if (trackId.present) {
      map['track_id'] = Variable<int>(trackId.value);
    }
    if (at.present) {
      map['at'] = Variable<int>(at.value);
    }
    if (locked.present) {
      map['locked'] = Variable<bool>(locked.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaybackRecordsCompanion(')
          ..write('id: $id, ')
          ..write('albumId: $albumId, ')
          ..write('discId: $discId, ')
          ..write('trackId: $trackId, ')
          ..write('at: $at, ')
          ..write('locked: $locked')
          ..write(')'))
        .toString();
  }
}

abstract class _$LocalDatabase extends GeneratedDatabase {
  _$LocalDatabase(QueryExecutor e) : super(e);
  $LocalDatabaseManager get managers => $LocalDatabaseManager(this);
  late final AnnivUser annivUser = AnnivUser(this);
  late final Playlist playlist = Playlist(this);
  late final PlaylistItem playlistItem = PlaylistItem(this);
  late final LocalFavoriteTracks localFavoriteTracks =
      LocalFavoriteTracks(this);
  late final Index localFavoriteTracksIndex = Index(
      'local_favorite_tracks_index',
      'CREATE UNIQUE INDEX IF NOT EXISTS local_favorite_tracks_index ON local_favorite_tracks (album_id, disc_id, track_id)');
  late final LocalFavoriteAlbums localFavoriteAlbums =
      LocalFavoriteAlbums(this);
  late final LocalAnnilServers localAnnilServers = LocalAnnilServers(this);
  late final LocalAnnilCaches localAnnilCaches = LocalAnnilCaches(this);
  late final LocalAnnilAlbums localAnnilAlbums = LocalAnnilAlbums(this);
  late final PlaybackRecords playbackRecords = PlaybackRecords(this);
  Selectable<PlaylistItemData> playlistItems(int var1) {
    return customSelect(
        'SELECT * FROM playlist_item WHERE playlist_id = ?1 ORDER BY "order"',
        variables: [
          Variable<int>(var1)
        ],
        readsFrom: {
          playlistItem,
        }).asyncMap(playlistItem.mapFromRow);
  }

  Selectable<PlaylistData> playlistByOwner(String? var1) {
    return customSelect('SELECT * FROM playlist WHERE owner = ?1', variables: [
      Variable<String>(var1)
    ], readsFrom: {
      playlist,
    }).asyncMap(playlist.mapFromRow);
  }

  Selectable<bool> isTrackFavorite(String var1, int var2, int var3) {
    return customSelect(
        'SELECT EXISTS (SELECT 1 AS _c1 FROM local_favorite_tracks WHERE album_id = ?1 AND disc_id = ?2 AND track_id = ?3) AS _c0',
        variables: [
          Variable<String>(var1),
          Variable<int>(var2),
          Variable<int>(var3)
        ],
        readsFrom: {
          localFavoriteTracks,
        }).map((QueryRow row) => row.read<bool>('_c0'));
  }

  Selectable<bool> isAlbumFavorite(String var1) {
    return customSelect(
        'SELECT EXISTS (SELECT 1 AS _c1 FROM local_favorite_albums WHERE album_id = ?1) AS _c0',
        variables: [
          Variable<String>(var1)
        ],
        readsFrom: {
          localFavoriteAlbums,
        }).map((QueryRow row) => row.read<bool>('_c0'));
  }

  Selectable<LocalAnnilServer> sortedAnnilServers() {
    return customSelect(
        'SELECT * FROM local_annil_servers ORDER BY priority DESC',
        variables: [],
        readsFrom: {
          localAnnilServers,
        }).asyncMap(localAnnilServers.mapFromRow);
  }

  Selectable<LocalAnnilServer> annilToUse(String var1) {
    return customSelect(
        'SELECT * FROM local_annil_servers WHERE id IN (SELECT annil_id FROM local_annil_albums WHERE album_id = ?1) ORDER BY priority DESC',
        variables: [
          Variable<String>(var1)
        ],
        readsFrom: {
          localAnnilServers,
          localAnnilAlbums,
        }).asyncMap(localAnnilServers.mapFromRow);
  }

  Future<int> updateAnnilETag(int var1, String? var2, int? var3) {
    return customInsert(
      'INSERT OR REPLACE INTO local_annil_caches (annil_id, etag, last_update) VALUES (?1, ?2, ?3)',
      variables: [
        Variable<int>(var1),
        Variable<String>(var2),
        Variable<int>(var3)
      ],
      updates: {localAnnilCaches},
    );
  }

  Selectable<String> availableAlbums() {
    return customSelect('SELECT DISTINCT album_id FROM local_annil_albums',
        variables: [],
        readsFrom: {
          localAnnilAlbums,
        }).map((QueryRow row) => row.read<String>('album_id'));
  }

  Selectable<PlaybackRecordsToSubmitResult> playbackRecordsToSubmit() {
    return customSelect(
        'SELECT id, album_id, disc_id, track_id, at FROM playback_records WHERE locked = FALSE',
        variables: [],
        readsFrom: {
          playbackRecords,
        }).map((QueryRow row) => PlaybackRecordsToSubmitResult(
          id: row.read<int>('id'),
          albumId: row.read<String>('album_id'),
          discId: row.read<int>('disc_id'),
          trackId: row.read<int>('track_id'),
          at: row.read<int>('at'),
        ));
  }

  Future<int> lockPlaybackRecords(List<int> var1) {
    var $arrayStartIndex = 1;
    final expandedvar1 = $expandVar($arrayStartIndex, var1.length);
    $arrayStartIndex += var1.length;
    return customUpdate(
      'UPDATE playback_records SET locked = TRUE WHERE id IN ($expandedvar1)',
      variables: [for (var $ in var1) Variable<int>($)],
      updates: {playbackRecords},
      updateKind: UpdateKind.update,
    );
  }

  Future<int> unlockPlaybackRecords(List<int> var1) {
    var $arrayStartIndex = 1;
    final expandedvar1 = $expandVar($arrayStartIndex, var1.length);
    $arrayStartIndex += var1.length;
    return customUpdate(
      'UPDATE playback_records SET locked = FALSE WHERE id IN ($expandedvar1)',
      variables: [for (var $ in var1) Variable<int>($)],
      updates: {playbackRecords},
      updateKind: UpdateKind.update,
    );
  }

  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        annivUser,
        playlist,
        playlistItem,
        localFavoriteTracks,
        localFavoriteTracksIndex,
        localFavoriteAlbums,
        localAnnilServers,
        localAnnilCaches,
        localAnnilAlbums,
        playbackRecords
      ];
}

typedef $AnnivUserCreateCompanionBuilder = AnnivUserCompanion Function({
  Value<int> id,
  required String userId,
  required String nickname,
  required String avatar,
});
typedef $AnnivUserUpdateCompanionBuilder = AnnivUserCompanion Function({
  Value<int> id,
  Value<String> userId,
  Value<String> nickname,
  Value<String> avatar,
});

class $AnnivUserFilterComposer extends Composer<_$LocalDatabase, AnnivUser> {
  $AnnivUserFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nickname => $composableBuilder(
      column: $table.nickname, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get avatar => $composableBuilder(
      column: $table.avatar, builder: (column) => ColumnFilters(column));
}

class $AnnivUserOrderingComposer extends Composer<_$LocalDatabase, AnnivUser> {
  $AnnivUserOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nickname => $composableBuilder(
      column: $table.nickname, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get avatar => $composableBuilder(
      column: $table.avatar, builder: (column) => ColumnOrderings(column));
}

class $AnnivUserAnnotationComposer
    extends Composer<_$LocalDatabase, AnnivUser> {
  $AnnivUserAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => column);

  GeneratedColumn<String> get avatar =>
      $composableBuilder(column: $table.avatar, builder: (column) => column);
}

class $AnnivUserTableManager extends RootTableManager<
    _$LocalDatabase,
    AnnivUser,
    AnnivUserData,
    $AnnivUserFilterComposer,
    $AnnivUserOrderingComposer,
    $AnnivUserAnnotationComposer,
    $AnnivUserCreateCompanionBuilder,
    $AnnivUserUpdateCompanionBuilder,
    (AnnivUserData, BaseReferences<_$LocalDatabase, AnnivUser, AnnivUserData>),
    AnnivUserData,
    PrefetchHooks Function()> {
  $AnnivUserTableManager(_$LocalDatabase db, AnnivUser table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $AnnivUserFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $AnnivUserOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $AnnivUserAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> nickname = const Value.absent(),
            Value<String> avatar = const Value.absent(),
          }) =>
              AnnivUserCompanion(
            id: id,
            userId: userId,
            nickname: nickname,
            avatar: avatar,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String userId,
            required String nickname,
            required String avatar,
          }) =>
              AnnivUserCompanion.insert(
            id: id,
            userId: userId,
            nickname: nickname,
            avatar: avatar,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $AnnivUserProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    AnnivUser,
    AnnivUserData,
    $AnnivUserFilterComposer,
    $AnnivUserOrderingComposer,
    $AnnivUserAnnotationComposer,
    $AnnivUserCreateCompanionBuilder,
    $AnnivUserUpdateCompanionBuilder,
    (AnnivUserData, BaseReferences<_$LocalDatabase, AnnivUser, AnnivUserData>),
    AnnivUserData,
    PrefetchHooks Function()>;
typedef $PlaylistCreateCompanionBuilder = PlaylistCompanion Function({
  Value<int> id,
  required String name,
  Value<String?> cover,
  Value<String?> description,
  Value<String?> remoteId,
  Value<String?> owner,
  Value<bool?> public,
  Value<int?> lastModified,
  required bool hasItems,
});
typedef $PlaylistUpdateCompanionBuilder = PlaylistCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String?> cover,
  Value<String?> description,
  Value<String?> remoteId,
  Value<String?> owner,
  Value<bool?> public,
  Value<int?> lastModified,
  Value<bool> hasItems,
});

class $PlaylistFilterComposer extends Composer<_$LocalDatabase, Playlist> {
  $PlaylistFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cover => $composableBuilder(
      column: $table.cover, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get owner => $composableBuilder(
      column: $table.owner, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get public => $composableBuilder(
      column: $table.public, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastModified => $composableBuilder(
      column: $table.lastModified, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hasItems => $composableBuilder(
      column: $table.hasItems, builder: (column) => ColumnFilters(column));
}

class $PlaylistOrderingComposer extends Composer<_$LocalDatabase, Playlist> {
  $PlaylistOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cover => $composableBuilder(
      column: $table.cover, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get owner => $composableBuilder(
      column: $table.owner, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get public => $composableBuilder(
      column: $table.public, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastModified => $composableBuilder(
      column: $table.lastModified,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hasItems => $composableBuilder(
      column: $table.hasItems, builder: (column) => ColumnOrderings(column));
}

class $PlaylistAnnotationComposer extends Composer<_$LocalDatabase, Playlist> {
  $PlaylistAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get cover =>
      $composableBuilder(column: $table.cover, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get owner =>
      $composableBuilder(column: $table.owner, builder: (column) => column);

  GeneratedColumn<bool> get public =>
      $composableBuilder(column: $table.public, builder: (column) => column);

  GeneratedColumn<int> get lastModified => $composableBuilder(
      column: $table.lastModified, builder: (column) => column);

  GeneratedColumn<bool> get hasItems =>
      $composableBuilder(column: $table.hasItems, builder: (column) => column);
}

class $PlaylistTableManager extends RootTableManager<
    _$LocalDatabase,
    Playlist,
    PlaylistData,
    $PlaylistFilterComposer,
    $PlaylistOrderingComposer,
    $PlaylistAnnotationComposer,
    $PlaylistCreateCompanionBuilder,
    $PlaylistUpdateCompanionBuilder,
    (PlaylistData, BaseReferences<_$LocalDatabase, Playlist, PlaylistData>),
    PlaylistData,
    PrefetchHooks Function()> {
  $PlaylistTableManager(_$LocalDatabase db, Playlist table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $PlaylistFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $PlaylistOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $PlaylistAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> cover = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> remoteId = const Value.absent(),
            Value<String?> owner = const Value.absent(),
            Value<bool?> public = const Value.absent(),
            Value<int?> lastModified = const Value.absent(),
            Value<bool> hasItems = const Value.absent(),
          }) =>
              PlaylistCompanion(
            id: id,
            name: name,
            cover: cover,
            description: description,
            remoteId: remoteId,
            owner: owner,
            public: public,
            lastModified: lastModified,
            hasItems: hasItems,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String?> cover = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> remoteId = const Value.absent(),
            Value<String?> owner = const Value.absent(),
            Value<bool?> public = const Value.absent(),
            Value<int?> lastModified = const Value.absent(),
            required bool hasItems,
          }) =>
              PlaylistCompanion.insert(
            id: id,
            name: name,
            cover: cover,
            description: description,
            remoteId: remoteId,
            owner: owner,
            public: public,
            lastModified: lastModified,
            hasItems: hasItems,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $PlaylistProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    Playlist,
    PlaylistData,
    $PlaylistFilterComposer,
    $PlaylistOrderingComposer,
    $PlaylistAnnotationComposer,
    $PlaylistCreateCompanionBuilder,
    $PlaylistUpdateCompanionBuilder,
    (PlaylistData, BaseReferences<_$LocalDatabase, Playlist, PlaylistData>),
    PlaylistData,
    PrefetchHooks Function()>;
typedef $PlaylistItemCreateCompanionBuilder = PlaylistItemCompanion Function({
  Value<int> id,
  required int playlistId,
  Value<String> type,
  Value<String?> description,
  required String info,
  Value<String?> remoteId,
  required int order,
});
typedef $PlaylistItemUpdateCompanionBuilder = PlaylistItemCompanion Function({
  Value<int> id,
  Value<int> playlistId,
  Value<String> type,
  Value<String?> description,
  Value<String> info,
  Value<String?> remoteId,
  Value<int> order,
});

class $PlaylistItemFilterComposer
    extends Composer<_$LocalDatabase, PlaylistItem> {
  $PlaylistItemFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get playlistId => $composableBuilder(
      column: $table.playlistId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get info => $composableBuilder(
      column: $table.info, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get order => $composableBuilder(
      column: $table.order, builder: (column) => ColumnFilters(column));
}

class $PlaylistItemOrderingComposer
    extends Composer<_$LocalDatabase, PlaylistItem> {
  $PlaylistItemOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get playlistId => $composableBuilder(
      column: $table.playlistId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get info => $composableBuilder(
      column: $table.info, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get order => $composableBuilder(
      column: $table.order, builder: (column) => ColumnOrderings(column));
}

class $PlaylistItemAnnotationComposer
    extends Composer<_$LocalDatabase, PlaylistItem> {
  $PlaylistItemAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get playlistId => $composableBuilder(
      column: $table.playlistId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get info =>
      $composableBuilder(column: $table.info, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<int> get order =>
      $composableBuilder(column: $table.order, builder: (column) => column);
}

class $PlaylistItemTableManager extends RootTableManager<
    _$LocalDatabase,
    PlaylistItem,
    PlaylistItemData,
    $PlaylistItemFilterComposer,
    $PlaylistItemOrderingComposer,
    $PlaylistItemAnnotationComposer,
    $PlaylistItemCreateCompanionBuilder,
    $PlaylistItemUpdateCompanionBuilder,
    (
      PlaylistItemData,
      BaseReferences<_$LocalDatabase, PlaylistItem, PlaylistItemData>
    ),
    PlaylistItemData,
    PrefetchHooks Function()> {
  $PlaylistItemTableManager(_$LocalDatabase db, PlaylistItem table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $PlaylistItemFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $PlaylistItemOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $PlaylistItemAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> playlistId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> info = const Value.absent(),
            Value<String?> remoteId = const Value.absent(),
            Value<int> order = const Value.absent(),
          }) =>
              PlaylistItemCompanion(
            id: id,
            playlistId: playlistId,
            type: type,
            description: description,
            info: info,
            remoteId: remoteId,
            order: order,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int playlistId,
            Value<String> type = const Value.absent(),
            Value<String?> description = const Value.absent(),
            required String info,
            Value<String?> remoteId = const Value.absent(),
            required int order,
          }) =>
              PlaylistItemCompanion.insert(
            id: id,
            playlistId: playlistId,
            type: type,
            description: description,
            info: info,
            remoteId: remoteId,
            order: order,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $PlaylistItemProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    PlaylistItem,
    PlaylistItemData,
    $PlaylistItemFilterComposer,
    $PlaylistItemOrderingComposer,
    $PlaylistItemAnnotationComposer,
    $PlaylistItemCreateCompanionBuilder,
    $PlaylistItemUpdateCompanionBuilder,
    (
      PlaylistItemData,
      BaseReferences<_$LocalDatabase, PlaylistItem, PlaylistItemData>
    ),
    PlaylistItemData,
    PrefetchHooks Function()>;
typedef $LocalFavoriteTracksCreateCompanionBuilder
    = LocalFavoriteTracksCompanion Function({
  Value<int> id,
  required String albumId,
  required int discId,
  required int trackId,
  Value<String?> title,
  Value<String?> artist,
  Value<String?> albumTitle,
  Value<String> type,
});
typedef $LocalFavoriteTracksUpdateCompanionBuilder
    = LocalFavoriteTracksCompanion Function({
  Value<int> id,
  Value<String> albumId,
  Value<int> discId,
  Value<int> trackId,
  Value<String?> title,
  Value<String?> artist,
  Value<String?> albumTitle,
  Value<String> type,
});

class $LocalFavoriteTracksFilterComposer
    extends Composer<_$LocalDatabase, LocalFavoriteTracks> {
  $LocalFavoriteTracksFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get albumId => $composableBuilder(
      column: $table.albumId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get discId => $composableBuilder(
      column: $table.discId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get trackId => $composableBuilder(
      column: $table.trackId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get artist => $composableBuilder(
      column: $table.artist, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get albumTitle => $composableBuilder(
      column: $table.albumTitle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));
}

class $LocalFavoriteTracksOrderingComposer
    extends Composer<_$LocalDatabase, LocalFavoriteTracks> {
  $LocalFavoriteTracksOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get albumId => $composableBuilder(
      column: $table.albumId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get discId => $composableBuilder(
      column: $table.discId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get trackId => $composableBuilder(
      column: $table.trackId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get artist => $composableBuilder(
      column: $table.artist, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get albumTitle => $composableBuilder(
      column: $table.albumTitle, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));
}

class $LocalFavoriteTracksAnnotationComposer
    extends Composer<_$LocalDatabase, LocalFavoriteTracks> {
  $LocalFavoriteTracksAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get albumId =>
      $composableBuilder(column: $table.albumId, builder: (column) => column);

  GeneratedColumn<int> get discId =>
      $composableBuilder(column: $table.discId, builder: (column) => column);

  GeneratedColumn<int> get trackId =>
      $composableBuilder(column: $table.trackId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<String> get albumTitle => $composableBuilder(
      column: $table.albumTitle, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);
}

class $LocalFavoriteTracksTableManager extends RootTableManager<
    _$LocalDatabase,
    LocalFavoriteTracks,
    LocalFavoriteTrack,
    $LocalFavoriteTracksFilterComposer,
    $LocalFavoriteTracksOrderingComposer,
    $LocalFavoriteTracksAnnotationComposer,
    $LocalFavoriteTracksCreateCompanionBuilder,
    $LocalFavoriteTracksUpdateCompanionBuilder,
    (
      LocalFavoriteTrack,
      BaseReferences<_$LocalDatabase, LocalFavoriteTracks, LocalFavoriteTrack>
    ),
    LocalFavoriteTrack,
    PrefetchHooks Function()> {
  $LocalFavoriteTracksTableManager(
      _$LocalDatabase db, LocalFavoriteTracks table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $LocalFavoriteTracksFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $LocalFavoriteTracksOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $LocalFavoriteTracksAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> albumId = const Value.absent(),
            Value<int> discId = const Value.absent(),
            Value<int> trackId = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<String?> artist = const Value.absent(),
            Value<String?> albumTitle = const Value.absent(),
            Value<String> type = const Value.absent(),
          }) =>
              LocalFavoriteTracksCompanion(
            id: id,
            albumId: albumId,
            discId: discId,
            trackId: trackId,
            title: title,
            artist: artist,
            albumTitle: albumTitle,
            type: type,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String albumId,
            required int discId,
            required int trackId,
            Value<String?> title = const Value.absent(),
            Value<String?> artist = const Value.absent(),
            Value<String?> albumTitle = const Value.absent(),
            Value<String> type = const Value.absent(),
          }) =>
              LocalFavoriteTracksCompanion.insert(
            id: id,
            albumId: albumId,
            discId: discId,
            trackId: trackId,
            title: title,
            artist: artist,
            albumTitle: albumTitle,
            type: type,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $LocalFavoriteTracksProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    LocalFavoriteTracks,
    LocalFavoriteTrack,
    $LocalFavoriteTracksFilterComposer,
    $LocalFavoriteTracksOrderingComposer,
    $LocalFavoriteTracksAnnotationComposer,
    $LocalFavoriteTracksCreateCompanionBuilder,
    $LocalFavoriteTracksUpdateCompanionBuilder,
    (
      LocalFavoriteTrack,
      BaseReferences<_$LocalDatabase, LocalFavoriteTracks, LocalFavoriteTrack>
    ),
    LocalFavoriteTrack,
    PrefetchHooks Function()>;
typedef $LocalFavoriteAlbumsCreateCompanionBuilder
    = LocalFavoriteAlbumsCompanion Function({
  Value<int> id,
  required String albumId,
});
typedef $LocalFavoriteAlbumsUpdateCompanionBuilder
    = LocalFavoriteAlbumsCompanion Function({
  Value<int> id,
  Value<String> albumId,
});

class $LocalFavoriteAlbumsFilterComposer
    extends Composer<_$LocalDatabase, LocalFavoriteAlbums> {
  $LocalFavoriteAlbumsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get albumId => $composableBuilder(
      column: $table.albumId, builder: (column) => ColumnFilters(column));
}

class $LocalFavoriteAlbumsOrderingComposer
    extends Composer<_$LocalDatabase, LocalFavoriteAlbums> {
  $LocalFavoriteAlbumsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get albumId => $composableBuilder(
      column: $table.albumId, builder: (column) => ColumnOrderings(column));
}

class $LocalFavoriteAlbumsAnnotationComposer
    extends Composer<_$LocalDatabase, LocalFavoriteAlbums> {
  $LocalFavoriteAlbumsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get albumId =>
      $composableBuilder(column: $table.albumId, builder: (column) => column);
}

class $LocalFavoriteAlbumsTableManager extends RootTableManager<
    _$LocalDatabase,
    LocalFavoriteAlbums,
    LocalFavoriteAlbum,
    $LocalFavoriteAlbumsFilterComposer,
    $LocalFavoriteAlbumsOrderingComposer,
    $LocalFavoriteAlbumsAnnotationComposer,
    $LocalFavoriteAlbumsCreateCompanionBuilder,
    $LocalFavoriteAlbumsUpdateCompanionBuilder,
    (
      LocalFavoriteAlbum,
      BaseReferences<_$LocalDatabase, LocalFavoriteAlbums, LocalFavoriteAlbum>
    ),
    LocalFavoriteAlbum,
    PrefetchHooks Function()> {
  $LocalFavoriteAlbumsTableManager(
      _$LocalDatabase db, LocalFavoriteAlbums table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $LocalFavoriteAlbumsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $LocalFavoriteAlbumsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $LocalFavoriteAlbumsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> albumId = const Value.absent(),
          }) =>
              LocalFavoriteAlbumsCompanion(
            id: id,
            albumId: albumId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String albumId,
          }) =>
              LocalFavoriteAlbumsCompanion.insert(
            id: id,
            albumId: albumId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $LocalFavoriteAlbumsProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    LocalFavoriteAlbums,
    LocalFavoriteAlbum,
    $LocalFavoriteAlbumsFilterComposer,
    $LocalFavoriteAlbumsOrderingComposer,
    $LocalFavoriteAlbumsAnnotationComposer,
    $LocalFavoriteAlbumsCreateCompanionBuilder,
    $LocalFavoriteAlbumsUpdateCompanionBuilder,
    (
      LocalFavoriteAlbum,
      BaseReferences<_$LocalDatabase, LocalFavoriteAlbums, LocalFavoriteAlbum>
    ),
    LocalFavoriteAlbum,
    PrefetchHooks Function()>;
typedef $LocalAnnilServersCreateCompanionBuilder = LocalAnnilServersCompanion
    Function({
  Value<int> id,
  Value<String?> remoteId,
  required String name,
  required String url,
  required String token,
  required int priority,
});
typedef $LocalAnnilServersUpdateCompanionBuilder = LocalAnnilServersCompanion
    Function({
  Value<int> id,
  Value<String?> remoteId,
  Value<String> name,
  Value<String> url,
  Value<String> token,
  Value<int> priority,
});

class $LocalAnnilServersFilterComposer
    extends Composer<_$LocalDatabase, LocalAnnilServers> {
  $LocalAnnilServersFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get token => $composableBuilder(
      column: $table.token, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnFilters(column));
}

class $LocalAnnilServersOrderingComposer
    extends Composer<_$LocalDatabase, LocalAnnilServers> {
  $LocalAnnilServersOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get token => $composableBuilder(
      column: $table.token, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));
}

class $LocalAnnilServersAnnotationComposer
    extends Composer<_$LocalDatabase, LocalAnnilServers> {
  $LocalAnnilServersAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get token =>
      $composableBuilder(column: $table.token, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);
}

class $LocalAnnilServersTableManager extends RootTableManager<
    _$LocalDatabase,
    LocalAnnilServers,
    LocalAnnilServer,
    $LocalAnnilServersFilterComposer,
    $LocalAnnilServersOrderingComposer,
    $LocalAnnilServersAnnotationComposer,
    $LocalAnnilServersCreateCompanionBuilder,
    $LocalAnnilServersUpdateCompanionBuilder,
    (
      LocalAnnilServer,
      BaseReferences<_$LocalDatabase, LocalAnnilServers, LocalAnnilServer>
    ),
    LocalAnnilServer,
    PrefetchHooks Function()> {
  $LocalAnnilServersTableManager(_$LocalDatabase db, LocalAnnilServers table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $LocalAnnilServersFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $LocalAnnilServersOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $LocalAnnilServersAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> remoteId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> url = const Value.absent(),
            Value<String> token = const Value.absent(),
            Value<int> priority = const Value.absent(),
          }) =>
              LocalAnnilServersCompanion(
            id: id,
            remoteId: remoteId,
            name: name,
            url: url,
            token: token,
            priority: priority,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> remoteId = const Value.absent(),
            required String name,
            required String url,
            required String token,
            required int priority,
          }) =>
              LocalAnnilServersCompanion.insert(
            id: id,
            remoteId: remoteId,
            name: name,
            url: url,
            token: token,
            priority: priority,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $LocalAnnilServersProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    LocalAnnilServers,
    LocalAnnilServer,
    $LocalAnnilServersFilterComposer,
    $LocalAnnilServersOrderingComposer,
    $LocalAnnilServersAnnotationComposer,
    $LocalAnnilServersCreateCompanionBuilder,
    $LocalAnnilServersUpdateCompanionBuilder,
    (
      LocalAnnilServer,
      BaseReferences<_$LocalDatabase, LocalAnnilServers, LocalAnnilServer>
    ),
    LocalAnnilServer,
    PrefetchHooks Function()>;
typedef $LocalAnnilCachesCreateCompanionBuilder = LocalAnnilCachesCompanion
    Function({
  Value<int> annilId,
  Value<String?> etag,
  Value<int?> lastUpdate,
});
typedef $LocalAnnilCachesUpdateCompanionBuilder = LocalAnnilCachesCompanion
    Function({
  Value<int> annilId,
  Value<String?> etag,
  Value<int?> lastUpdate,
});

class $LocalAnnilCachesFilterComposer
    extends Composer<_$LocalDatabase, LocalAnnilCaches> {
  $LocalAnnilCachesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get annilId => $composableBuilder(
      column: $table.annilId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get etag => $composableBuilder(
      column: $table.etag, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastUpdate => $composableBuilder(
      column: $table.lastUpdate, builder: (column) => ColumnFilters(column));
}

class $LocalAnnilCachesOrderingComposer
    extends Composer<_$LocalDatabase, LocalAnnilCaches> {
  $LocalAnnilCachesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get annilId => $composableBuilder(
      column: $table.annilId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get etag => $composableBuilder(
      column: $table.etag, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastUpdate => $composableBuilder(
      column: $table.lastUpdate, builder: (column) => ColumnOrderings(column));
}

class $LocalAnnilCachesAnnotationComposer
    extends Composer<_$LocalDatabase, LocalAnnilCaches> {
  $LocalAnnilCachesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get annilId =>
      $composableBuilder(column: $table.annilId, builder: (column) => column);

  GeneratedColumn<String> get etag =>
      $composableBuilder(column: $table.etag, builder: (column) => column);

  GeneratedColumn<int> get lastUpdate => $composableBuilder(
      column: $table.lastUpdate, builder: (column) => column);
}

class $LocalAnnilCachesTableManager extends RootTableManager<
    _$LocalDatabase,
    LocalAnnilCaches,
    LocalAnnilCache,
    $LocalAnnilCachesFilterComposer,
    $LocalAnnilCachesOrderingComposer,
    $LocalAnnilCachesAnnotationComposer,
    $LocalAnnilCachesCreateCompanionBuilder,
    $LocalAnnilCachesUpdateCompanionBuilder,
    (
      LocalAnnilCache,
      BaseReferences<_$LocalDatabase, LocalAnnilCaches, LocalAnnilCache>
    ),
    LocalAnnilCache,
    PrefetchHooks Function()> {
  $LocalAnnilCachesTableManager(_$LocalDatabase db, LocalAnnilCaches table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $LocalAnnilCachesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $LocalAnnilCachesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $LocalAnnilCachesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> annilId = const Value.absent(),
            Value<String?> etag = const Value.absent(),
            Value<int?> lastUpdate = const Value.absent(),
          }) =>
              LocalAnnilCachesCompanion(
            annilId: annilId,
            etag: etag,
            lastUpdate: lastUpdate,
          ),
          createCompanionCallback: ({
            Value<int> annilId = const Value.absent(),
            Value<String?> etag = const Value.absent(),
            Value<int?> lastUpdate = const Value.absent(),
          }) =>
              LocalAnnilCachesCompanion.insert(
            annilId: annilId,
            etag: etag,
            lastUpdate: lastUpdate,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $LocalAnnilCachesProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    LocalAnnilCaches,
    LocalAnnilCache,
    $LocalAnnilCachesFilterComposer,
    $LocalAnnilCachesOrderingComposer,
    $LocalAnnilCachesAnnotationComposer,
    $LocalAnnilCachesCreateCompanionBuilder,
    $LocalAnnilCachesUpdateCompanionBuilder,
    (
      LocalAnnilCache,
      BaseReferences<_$LocalDatabase, LocalAnnilCaches, LocalAnnilCache>
    ),
    LocalAnnilCache,
    PrefetchHooks Function()>;
typedef $LocalAnnilAlbumsCreateCompanionBuilder = LocalAnnilAlbumsCompanion
    Function({
  Value<int> id,
  required int annilId,
  required String albumId,
});
typedef $LocalAnnilAlbumsUpdateCompanionBuilder = LocalAnnilAlbumsCompanion
    Function({
  Value<int> id,
  Value<int> annilId,
  Value<String> albumId,
});

class $LocalAnnilAlbumsFilterComposer
    extends Composer<_$LocalDatabase, LocalAnnilAlbums> {
  $LocalAnnilAlbumsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get annilId => $composableBuilder(
      column: $table.annilId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get albumId => $composableBuilder(
      column: $table.albumId, builder: (column) => ColumnFilters(column));
}

class $LocalAnnilAlbumsOrderingComposer
    extends Composer<_$LocalDatabase, LocalAnnilAlbums> {
  $LocalAnnilAlbumsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get annilId => $composableBuilder(
      column: $table.annilId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get albumId => $composableBuilder(
      column: $table.albumId, builder: (column) => ColumnOrderings(column));
}

class $LocalAnnilAlbumsAnnotationComposer
    extends Composer<_$LocalDatabase, LocalAnnilAlbums> {
  $LocalAnnilAlbumsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get annilId =>
      $composableBuilder(column: $table.annilId, builder: (column) => column);

  GeneratedColumn<String> get albumId =>
      $composableBuilder(column: $table.albumId, builder: (column) => column);
}

class $LocalAnnilAlbumsTableManager extends RootTableManager<
    _$LocalDatabase,
    LocalAnnilAlbums,
    LocalAnnilAlbum,
    $LocalAnnilAlbumsFilterComposer,
    $LocalAnnilAlbumsOrderingComposer,
    $LocalAnnilAlbumsAnnotationComposer,
    $LocalAnnilAlbumsCreateCompanionBuilder,
    $LocalAnnilAlbumsUpdateCompanionBuilder,
    (
      LocalAnnilAlbum,
      BaseReferences<_$LocalDatabase, LocalAnnilAlbums, LocalAnnilAlbum>
    ),
    LocalAnnilAlbum,
    PrefetchHooks Function()> {
  $LocalAnnilAlbumsTableManager(_$LocalDatabase db, LocalAnnilAlbums table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $LocalAnnilAlbumsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $LocalAnnilAlbumsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $LocalAnnilAlbumsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> annilId = const Value.absent(),
            Value<String> albumId = const Value.absent(),
          }) =>
              LocalAnnilAlbumsCompanion(
            id: id,
            annilId: annilId,
            albumId: albumId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int annilId,
            required String albumId,
          }) =>
              LocalAnnilAlbumsCompanion.insert(
            id: id,
            annilId: annilId,
            albumId: albumId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $LocalAnnilAlbumsProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    LocalAnnilAlbums,
    LocalAnnilAlbum,
    $LocalAnnilAlbumsFilterComposer,
    $LocalAnnilAlbumsOrderingComposer,
    $LocalAnnilAlbumsAnnotationComposer,
    $LocalAnnilAlbumsCreateCompanionBuilder,
    $LocalAnnilAlbumsUpdateCompanionBuilder,
    (
      LocalAnnilAlbum,
      BaseReferences<_$LocalDatabase, LocalAnnilAlbums, LocalAnnilAlbum>
    ),
    LocalAnnilAlbum,
    PrefetchHooks Function()>;
typedef $PlaybackRecordsCreateCompanionBuilder = PlaybackRecordsCompanion
    Function({
  Value<int> id,
  required String albumId,
  required int discId,
  required int trackId,
  required int at,
  required bool locked,
});
typedef $PlaybackRecordsUpdateCompanionBuilder = PlaybackRecordsCompanion
    Function({
  Value<int> id,
  Value<String> albumId,
  Value<int> discId,
  Value<int> trackId,
  Value<int> at,
  Value<bool> locked,
});

class $PlaybackRecordsFilterComposer
    extends Composer<_$LocalDatabase, PlaybackRecords> {
  $PlaybackRecordsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get albumId => $composableBuilder(
      column: $table.albumId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get discId => $composableBuilder(
      column: $table.discId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get trackId => $composableBuilder(
      column: $table.trackId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get at => $composableBuilder(
      column: $table.at, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get locked => $composableBuilder(
      column: $table.locked, builder: (column) => ColumnFilters(column));
}

class $PlaybackRecordsOrderingComposer
    extends Composer<_$LocalDatabase, PlaybackRecords> {
  $PlaybackRecordsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get albumId => $composableBuilder(
      column: $table.albumId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get discId => $composableBuilder(
      column: $table.discId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get trackId => $composableBuilder(
      column: $table.trackId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get at => $composableBuilder(
      column: $table.at, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get locked => $composableBuilder(
      column: $table.locked, builder: (column) => ColumnOrderings(column));
}

class $PlaybackRecordsAnnotationComposer
    extends Composer<_$LocalDatabase, PlaybackRecords> {
  $PlaybackRecordsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get albumId =>
      $composableBuilder(column: $table.albumId, builder: (column) => column);

  GeneratedColumn<int> get discId =>
      $composableBuilder(column: $table.discId, builder: (column) => column);

  GeneratedColumn<int> get trackId =>
      $composableBuilder(column: $table.trackId, builder: (column) => column);

  GeneratedColumn<int> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<bool> get locked =>
      $composableBuilder(column: $table.locked, builder: (column) => column);
}

class $PlaybackRecordsTableManager extends RootTableManager<
    _$LocalDatabase,
    PlaybackRecords,
    PlaybackRecord,
    $PlaybackRecordsFilterComposer,
    $PlaybackRecordsOrderingComposer,
    $PlaybackRecordsAnnotationComposer,
    $PlaybackRecordsCreateCompanionBuilder,
    $PlaybackRecordsUpdateCompanionBuilder,
    (
      PlaybackRecord,
      BaseReferences<_$LocalDatabase, PlaybackRecords, PlaybackRecord>
    ),
    PlaybackRecord,
    PrefetchHooks Function()> {
  $PlaybackRecordsTableManager(_$LocalDatabase db, PlaybackRecords table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $PlaybackRecordsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $PlaybackRecordsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $PlaybackRecordsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> albumId = const Value.absent(),
            Value<int> discId = const Value.absent(),
            Value<int> trackId = const Value.absent(),
            Value<int> at = const Value.absent(),
            Value<bool> locked = const Value.absent(),
          }) =>
              PlaybackRecordsCompanion(
            id: id,
            albumId: albumId,
            discId: discId,
            trackId: trackId,
            at: at,
            locked: locked,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String albumId,
            required int discId,
            required int trackId,
            required int at,
            required bool locked,
          }) =>
              PlaybackRecordsCompanion.insert(
            id: id,
            albumId: albumId,
            discId: discId,
            trackId: trackId,
            at: at,
            locked: locked,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $PlaybackRecordsProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    PlaybackRecords,
    PlaybackRecord,
    $PlaybackRecordsFilterComposer,
    $PlaybackRecordsOrderingComposer,
    $PlaybackRecordsAnnotationComposer,
    $PlaybackRecordsCreateCompanionBuilder,
    $PlaybackRecordsUpdateCompanionBuilder,
    (
      PlaybackRecord,
      BaseReferences<_$LocalDatabase, PlaybackRecords, PlaybackRecord>
    ),
    PlaybackRecord,
    PrefetchHooks Function()>;

class $LocalDatabaseManager {
  final _$LocalDatabase _db;
  $LocalDatabaseManager(this._db);
  $AnnivUserTableManager get annivUser =>
      $AnnivUserTableManager(_db, _db.annivUser);
  $PlaylistTableManager get playlist =>
      $PlaylistTableManager(_db, _db.playlist);
  $PlaylistItemTableManager get playlistItem =>
      $PlaylistItemTableManager(_db, _db.playlistItem);
  $LocalFavoriteTracksTableManager get localFavoriteTracks =>
      $LocalFavoriteTracksTableManager(_db, _db.localFavoriteTracks);
  $LocalFavoriteAlbumsTableManager get localFavoriteAlbums =>
      $LocalFavoriteAlbumsTableManager(_db, _db.localFavoriteAlbums);
  $LocalAnnilServersTableManager get localAnnilServers =>
      $LocalAnnilServersTableManager(_db, _db.localAnnilServers);
  $LocalAnnilCachesTableManager get localAnnilCaches =>
      $LocalAnnilCachesTableManager(_db, _db.localAnnilCaches);
  $LocalAnnilAlbumsTableManager get localAnnilAlbums =>
      $LocalAnnilAlbumsTableManager(_db, _db.localAnnilAlbums);
  $PlaybackRecordsTableManager get playbackRecords =>
      $PlaybackRecordsTableManager(_db, _db.playbackRecords);
}

class PlaybackRecordsToSubmitResult {
  final int id;
  final String albumId;
  final int discId;
  final int trackId;
  final int at;
  PlaybackRecordsToSubmitResult({
    required this.id,
    required this.albumId,
    required this.discId,
    required this.trackId,
    required this.at,
  });
}
