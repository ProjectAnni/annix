// This file is automatically generated, so please do not edit it.
// Generated by `flutter_rust_bridge`@ 2.1.0.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:uuid/uuid.dart';

/// Color
Future<int> getThemeColor({required String path}) =>
    RustLib.instance.api.crateApiSimpleGetThemeColor(path: path);

// Rust type: RustOpaqueMoi<Mutex < Connection >>
abstract class MutexConnection implements RustOpaqueInterface {}

// Rust type: RustOpaqueMoi<Mutex < RepoDatabaseRead >>
abstract class MutexRepoDatabaseRead implements RustOpaqueInterface {}

/// Repo
class LocalDb {
  final MutexRepoDatabaseRead repo;

  const LocalDb({
    required this.repo,
  });

  Future<String?> getAlbum({required UuidValue albumId}) => RustLib.instance.api
      .crateApiSimpleLocalDbGetAlbum(that: this, albumId: albumId);

  Future<List<UuidValue>> getAlbumsByTag(
          {required String tag, required bool recursive}) =>
      RustLib.instance.api.crateApiSimpleLocalDbGetAlbumsByTag(
          that: this, tag: tag, recursive: recursive);

  Future<List<TagItem>> getTags() =>
      RustLib.instance.api.crateApiSimpleLocalDbGetTags(
        that: this,
      );

  // HINT: Make it `#[frb(sync)]` to let it become the default constructor of Dart class.
  static Future<LocalDb> newInstance({required String path}) =>
      RustLib.instance.api.crateApiSimpleLocalDbNew(path: path);

  @override
  int get hashCode => repo.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalDb &&
          runtimeType == other.runtimeType &&
          repo == other.repo;
}

/// API
class LocalStore {
  final MutexConnection conn;

  const LocalStore.raw({
    required this.conn,
  });

  Future<void> clear({String? category}) => RustLib.instance.api
      .crateApiSimpleLocalStoreClear(that: this, category: category);

  Future<String?> get_({required String category, required String key}) =>
      RustLib.instance.api.crateApiSimpleLocalStoreGet(
          that: this, category: category, key: key);

  Future<void> insert(
          {required String category,
          required String key,
          required String value}) =>
      RustLib.instance.api.crateApiSimpleLocalStoreInsert(
          that: this, category: category, key: key, value: value);

  factory LocalStore({required String root}) =>
      RustLib.instance.api.crateApiSimpleLocalStoreNew(root: root);

  @override
  int get hashCode => conn.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalStore &&
          runtimeType == other.runtimeType &&
          conn == other.conn;
}

/// Preferences
class NativePreferenceStore {
  final MutexConnection conn;

  const NativePreferenceStore.raw({
    required this.conn,
  });

  String? get_({required String key}) => RustLib.instance.api
      .crateApiSimpleNativePreferenceStoreGet(that: this, key: key);

  factory NativePreferenceStore({required String root}) =>
      RustLib.instance.api.crateApiSimpleNativePreferenceStoreNew(root: root);

  void remove({required String key}) => RustLib.instance.api
      .crateApiSimpleNativePreferenceStoreRemove(that: this, key: key);

  void removePrefix({required String prefix}) =>
      RustLib.instance.api.crateApiSimpleNativePreferenceStoreRemovePrefix(
          that: this, prefix: prefix);

  void set_({required String key, required String value}) =>
      RustLib.instance.api.crateApiSimpleNativePreferenceStoreSet(
          that: this, key: key, value: value);

  @override
  int get hashCode => conn.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NativePreferenceStore &&
          runtimeType == other.runtimeType &&
          conn == other.conn;
}

class TagItem {
  final String name;
  final List<String> children;

  const TagItem({
    required this.name,
    required this.children,
  });

  @override
  int get hashCode => name.hashCode ^ children.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TagItem &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          children == other.children;
}
