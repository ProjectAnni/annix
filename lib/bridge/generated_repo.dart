// AUTO GENERATED FILE, DO NOT EDIT.
// Generated by `flutter_rust_bridge`@ 1.72.0.
// ignore_for_file: non_constant_identifier_names, unused_element, duplicate_ignore, directives_ordering, curly_braces_in_flow_control_structures, unnecessary_lambdas, slash_for_doc_comments, prefer_const_literals_to_create_immutables, implicit_dynamic_list_literal, duplicate_import, unused_import, unnecessary_import, prefer_single_quotes, prefer_const_constructors, use_super_parameters, always_use_package_imports, annotate_overrides, invalid_use_of_protected_member, constant_identifier_names, invalid_use_of_internal_member, prefer_is_empty, unnecessary_const

import 'dart:convert';
import 'dart:async';
import 'package:meta/meta.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import 'package:uuid/uuid.dart';

import 'dart:ffi' as ffi;

abstract class ApiRepository {
  Future<LocalDb> newStaticMethodLocalDb({required String path, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kNewStaticMethodLocalDbConstMeta;

  Future<String?> getAlbumMethodLocalDb({required LocalDb that, required UuidValue albumId, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kGetAlbumMethodLocalDbConstMeta;

  Future<List<UuidValue>> getAlbumsByTagMethodLocalDb(
      {required LocalDb that, required String tag, required bool recursive, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kGetAlbumsByTagMethodLocalDbConstMeta;

  Future<List<TagItem>> getTagsMethodLocalDb({required LocalDb that, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kGetTagsMethodLocalDbConstMeta;

  DropFnType get dropOpaqueMutexRepoDatabaseRead;
  ShareFnType get shareOpaqueMutexRepoDatabaseRead;
  OpaqueTypeFinalizer get MutexRepoDatabaseReadFinalizer;
}

@sealed
class MutexRepoDatabaseRead extends FrbOpaque {
  final ApiRepository bridge;
  MutexRepoDatabaseRead.fromRaw(int ptr, int size, this.bridge) : super.unsafe(ptr, size);
  @override
  DropFnType get dropFn => bridge.dropOpaqueMutexRepoDatabaseRead;

  @override
  ShareFnType get shareFn => bridge.shareOpaqueMutexRepoDatabaseRead;

  @override
  OpaqueTypeFinalizer get staticFinalizer => bridge.MutexRepoDatabaseReadFinalizer;
}

class LocalDb {
  final ApiRepository bridge;
  final MutexRepoDatabaseRead repo;

  const LocalDb({
    required this.bridge,
    required this.repo,
  });

  static Future<LocalDb> newLocalDb({required ApiRepository bridge, required String path, dynamic hint}) =>
      bridge.newStaticMethodLocalDb(path: path, hint: hint);

  Future<String?> getAlbum({required UuidValue albumId, dynamic hint}) => bridge.getAlbumMethodLocalDb(
        that: this,
        albumId: albumId,
      );

  Future<List<UuidValue>> getAlbumsByTag({required String tag, required bool recursive, dynamic hint}) =>
      bridge.getAlbumsByTagMethodLocalDb(
        that: this,
        tag: tag,
        recursive: recursive,
      );

  Future<List<TagItem>> getTags({dynamic hint}) => bridge.getTagsMethodLocalDb(
        that: this,
      );
}

class TagItem {
  final String name;
  final List<String> children;

  const TagItem({
    required this.name,
    required this.children,
  });
}

class ApiRepositoryImpl implements ApiRepository {
  final ApiRepositoryPlatform _platform;
  factory ApiRepositoryImpl(ExternalLibrary dylib) => ApiRepositoryImpl.raw(ApiRepositoryPlatform(dylib));

  /// Only valid on web/WASM platforms.
  factory ApiRepositoryImpl.wasm(FutureOr<WasmModule> module) => ApiRepositoryImpl(module as ExternalLibrary);
  ApiRepositoryImpl.raw(this._platform);
  Future<LocalDb> newStaticMethodLocalDb({required String path, dynamic hint}) {
    var arg0 = _platform.api2wire_String(path);
    return _platform.executeNormal(FlutterRustBridgeTask(
      callFfi: (port_) => _platform.inner.wire_new__static_method__LocalDb(port_, arg0),
      parseSuccessData: (d) => _wire2api_local_db(d),
      constMeta: kNewStaticMethodLocalDbConstMeta,
      argValues: [path],
      hint: hint,
    ));
  }

  FlutterRustBridgeTaskConstMeta get kNewStaticMethodLocalDbConstMeta => const FlutterRustBridgeTaskConstMeta(
        debugName: "new__static_method__LocalDb",
        argNames: ["path"],
      );

  Future<String?> getAlbumMethodLocalDb({required LocalDb that, required UuidValue albumId, dynamic hint}) {
    var arg0 = _platform.api2wire_box_autoadd_local_db(that);
    var arg1 = _platform.api2wire_Uuid(albumId);
    return _platform.executeNormal(FlutterRustBridgeTask(
      callFfi: (port_) => _platform.inner.wire_get_album__method__LocalDb(port_, arg0, arg1),
      parseSuccessData: _wire2api_opt_String,
      constMeta: kGetAlbumMethodLocalDbConstMeta,
      argValues: [that, albumId],
      hint: hint,
    ));
  }

  FlutterRustBridgeTaskConstMeta get kGetAlbumMethodLocalDbConstMeta => const FlutterRustBridgeTaskConstMeta(
        debugName: "get_album__method__LocalDb",
        argNames: ["that", "albumId"],
      );

  Future<List<UuidValue>> getAlbumsByTagMethodLocalDb(
      {required LocalDb that, required String tag, required bool recursive, dynamic hint}) {
    var arg0 = _platform.api2wire_box_autoadd_local_db(that);
    var arg1 = _platform.api2wire_String(tag);
    var arg2 = recursive;
    return _platform.executeNormal(FlutterRustBridgeTask(
      callFfi: (port_) => _platform.inner.wire_get_albums_by_tag__method__LocalDb(port_, arg0, arg1, arg2),
      parseSuccessData: _wire2api_Uuids,
      constMeta: kGetAlbumsByTagMethodLocalDbConstMeta,
      argValues: [that, tag, recursive],
      hint: hint,
    ));
  }

  FlutterRustBridgeTaskConstMeta get kGetAlbumsByTagMethodLocalDbConstMeta => const FlutterRustBridgeTaskConstMeta(
        debugName: "get_albums_by_tag__method__LocalDb",
        argNames: ["that", "tag", "recursive"],
      );

  Future<List<TagItem>> getTagsMethodLocalDb({required LocalDb that, dynamic hint}) {
    var arg0 = _platform.api2wire_box_autoadd_local_db(that);
    return _platform.executeNormal(FlutterRustBridgeTask(
      callFfi: (port_) => _platform.inner.wire_get_tags__method__LocalDb(port_, arg0),
      parseSuccessData: _wire2api_list_tag_item,
      constMeta: kGetTagsMethodLocalDbConstMeta,
      argValues: [that],
      hint: hint,
    ));
  }

  FlutterRustBridgeTaskConstMeta get kGetTagsMethodLocalDbConstMeta => const FlutterRustBridgeTaskConstMeta(
        debugName: "get_tags__method__LocalDb",
        argNames: ["that"],
      );

  DropFnType get dropOpaqueMutexRepoDatabaseRead => _platform.inner.drop_opaque_MutexRepoDatabaseRead;
  ShareFnType get shareOpaqueMutexRepoDatabaseRead => _platform.inner.share_opaque_MutexRepoDatabaseRead;
  OpaqueTypeFinalizer get MutexRepoDatabaseReadFinalizer => _platform.MutexRepoDatabaseReadFinalizer;

  void dispose() {
    _platform.dispose();
  }
// Section: wire2api

  MutexRepoDatabaseRead _wire2api_MutexRepoDatabaseRead(dynamic raw) {
    return MutexRepoDatabaseRead.fromRaw(raw[0], raw[1], this);
  }

  String _wire2api_String(dynamic raw) {
    return raw as String;
  }

  List<String> _wire2api_StringList(dynamic raw) {
    return (raw as List<dynamic>).cast<String>();
  }

  List<UuidValue> _wire2api_Uuids(dynamic raw) {
    final bytes = _wire2api_uint_8_list(raw);
    return wire2apiUuids(bytes);
  }

  List<TagItem> _wire2api_list_tag_item(dynamic raw) {
    return (raw as List<dynamic>).map(_wire2api_tag_item).toList();
  }

  LocalDb _wire2api_local_db(dynamic raw) {
    final arr = raw as List<dynamic>;
    if (arr.length != 1) throw Exception('unexpected arr length: expect 1 but see ${arr.length}');
    return LocalDb(
      bridge: this,
      repo: _wire2api_MutexRepoDatabaseRead(arr[0]),
    );
  }

  String? _wire2api_opt_String(dynamic raw) {
    return raw == null ? null : _wire2api_String(raw);
  }

  TagItem _wire2api_tag_item(dynamic raw) {
    final arr = raw as List<dynamic>;
    if (arr.length != 2) throw Exception('unexpected arr length: expect 2 but see ${arr.length}');
    return TagItem(
      name: _wire2api_String(arr[0]),
      children: _wire2api_StringList(arr[1]),
    );
  }

  int _wire2api_u8(dynamic raw) {
    return raw as int;
  }

  Uint8List _wire2api_uint_8_list(dynamic raw) {
    return raw as Uint8List;
  }
}

// Section: api2wire

@protected
bool api2wire_bool(bool raw) {
  return raw;
}

@protected
int api2wire_u8(int raw) {
  return raw;
}

// Section: finalizer

class ApiRepositoryPlatform extends FlutterRustBridgeBase<ApiRepositoryWire> {
  ApiRepositoryPlatform(ffi.DynamicLibrary dylib) : super(ApiRepositoryWire(dylib));

// Section: api2wire

  @protected
  wire_MutexRepoDatabaseRead api2wire_MutexRepoDatabaseRead(MutexRepoDatabaseRead raw) {
    final ptr = inner.new_MutexRepoDatabaseRead();
    _api_fill_to_wire_MutexRepoDatabaseRead(raw, ptr);
    return ptr;
  }

  @protected
  ffi.Pointer<wire_uint_8_list> api2wire_String(String raw) {
    return api2wire_uint_8_list(utf8.encoder.convert(raw));
  }

  @protected
  ffi.Pointer<wire_uint_8_list> api2wire_Uuid(UuidValue raw) {
    return api2wire_uint_8_list(raw.toBytes());
  }

  @protected
  ffi.Pointer<wire_LocalDb> api2wire_box_autoadd_local_db(LocalDb raw) {
    final ptr = inner.new_box_autoadd_local_db_0();
    _api_fill_to_wire_local_db(raw, ptr.ref);
    return ptr;
  }

  @protected
  ffi.Pointer<wire_uint_8_list> api2wire_uint_8_list(Uint8List raw) {
    final ans = inner.new_uint_8_list_0(raw.length);
    ans.ref.ptr.asTypedList(raw.length).setAll(0, raw);
    return ans;
  }
// Section: finalizer

  late final OpaqueTypeFinalizer _MutexRepoDatabaseReadFinalizer =
      OpaqueTypeFinalizer(inner._drop_opaque_MutexRepoDatabaseReadPtr);
  OpaqueTypeFinalizer get MutexRepoDatabaseReadFinalizer => _MutexRepoDatabaseReadFinalizer;
// Section: api_fill_to_wire

  void _api_fill_to_wire_MutexRepoDatabaseRead(MutexRepoDatabaseRead apiObj, wire_MutexRepoDatabaseRead wireObj) {
    wireObj.ptr = apiObj.shareOrMove();
  }

  void _api_fill_to_wire_box_autoadd_local_db(LocalDb apiObj, ffi.Pointer<wire_LocalDb> wireObj) {
    _api_fill_to_wire_local_db(apiObj, wireObj.ref);
  }

  void _api_fill_to_wire_local_db(LocalDb apiObj, wire_LocalDb wireObj) {
    wireObj.repo = api2wire_MutexRepoDatabaseRead(apiObj.repo);
  }
}

// ignore_for_file: camel_case_types, non_constant_identifier_names, avoid_positional_boolean_parameters, annotate_overrides, constant_identifier_names

// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.
// ignore_for_file: type=lint

/// generated by flutter_rust_bridge
class ApiRepositoryWire implements FlutterRustBridgeWireBase {
  @internal
  late final dartApi = DartApiDl(init_frb_dart_api_dl);

  /// Holds the symbol lookup function.
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName) _lookup;

  /// The symbols are looked up in [dynamicLibrary].
  ApiRepositoryWire(ffi.DynamicLibrary dynamicLibrary) : _lookup = dynamicLibrary.lookup;

  /// The symbols are looked up with [lookup].
  ApiRepositoryWire.fromLookup(ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName) lookup)
      : _lookup = lookup;

  ffi.Pointer<wire_NativePreferenceStore> new_box_autoadd_native_preference_store_1() {
    return _new_box_autoadd_native_preference_store_1();
  }

  late final _new_box_autoadd_native_preference_store_1Ptr =
      _lookup<ffi.NativeFunction<ffi.Pointer<wire_NativePreferenceStore> Function()>>(
          'new_box_autoadd_native_preference_store_1');
  late final _new_box_autoadd_native_preference_store_1 =
      _new_box_autoadd_native_preference_store_1Ptr.asFunction<ffi.Pointer<wire_NativePreferenceStore> Function()>();

  void store_dart_post_cobject(
    DartPostCObjectFnType ptr,
  ) {
    return _store_dart_post_cobject(
      ptr,
    );
  }

  late final _store_dart_post_cobjectPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(DartPostCObjectFnType)>>('store_dart_post_cobject');
  late final _store_dart_post_cobject = _store_dart_post_cobjectPtr.asFunction<void Function(DartPostCObjectFnType)>();

  Object get_dart_object(
    int ptr,
  ) {
    return _get_dart_object(
      ptr,
    );
  }

  late final _get_dart_objectPtr = _lookup<ffi.NativeFunction<ffi.Handle Function(ffi.UintPtr)>>('get_dart_object');
  late final _get_dart_object = _get_dart_objectPtr.asFunction<Object Function(int)>();

  void drop_dart_object(
    int ptr,
  ) {
    return _drop_dart_object(
      ptr,
    );
  }

  late final _drop_dart_objectPtr = _lookup<ffi.NativeFunction<ffi.Void Function(ffi.UintPtr)>>('drop_dart_object');
  late final _drop_dart_object = _drop_dart_objectPtr.asFunction<void Function(int)>();

  int new_dart_opaque(
    Object handle,
  ) {
    return _new_dart_opaque(
      handle,
    );
  }

  late final _new_dart_opaquePtr = _lookup<ffi.NativeFunction<ffi.UintPtr Function(ffi.Handle)>>('new_dart_opaque');
  late final _new_dart_opaque = _new_dart_opaquePtr.asFunction<int Function(Object)>();

  int init_frb_dart_api_dl(
    ffi.Pointer<ffi.Void> obj,
  ) {
    return _init_frb_dart_api_dl(
      obj,
    );
  }

  late final _init_frb_dart_api_dlPtr =
      _lookup<ffi.NativeFunction<ffi.IntPtr Function(ffi.Pointer<ffi.Void>)>>('init_frb_dart_api_dl');
  late final _init_frb_dart_api_dl = _init_frb_dart_api_dlPtr.asFunction<int Function(ffi.Pointer<ffi.Void>)>();

  void wire_new__static_method__LocalDb(
    int port_,
    ffi.Pointer<wire_uint_8_list> path,
  ) {
    return _wire_new__static_method__LocalDb(
      port_,
      path,
    );
  }

  late final _wire_new__static_method__LocalDbPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Int64, ffi.Pointer<wire_uint_8_list>)>>(
          'wire_new__static_method__LocalDb');
  late final _wire_new__static_method__LocalDb =
      _wire_new__static_method__LocalDbPtr.asFunction<void Function(int, ffi.Pointer<wire_uint_8_list>)>();

  void wire_get_album__method__LocalDb(
    int port_,
    ffi.Pointer<wire_LocalDb> that,
    ffi.Pointer<wire_uint_8_list> album_id,
  ) {
    return _wire_get_album__method__LocalDb(
      port_,
      that,
      album_id,
    );
  }

  late final _wire_get_album__method__LocalDbPtr = _lookup<
          ffi.NativeFunction<ffi.Void Function(ffi.Int64, ffi.Pointer<wire_LocalDb>, ffi.Pointer<wire_uint_8_list>)>>(
      'wire_get_album__method__LocalDb');
  late final _wire_get_album__method__LocalDb = _wire_get_album__method__LocalDbPtr
      .asFunction<void Function(int, ffi.Pointer<wire_LocalDb>, ffi.Pointer<wire_uint_8_list>)>();

  void wire_get_albums_by_tag__method__LocalDb(
    int port_,
    ffi.Pointer<wire_LocalDb> that,
    ffi.Pointer<wire_uint_8_list> tag,
    bool recursive,
  ) {
    return _wire_get_albums_by_tag__method__LocalDb(
      port_,
      that,
      tag,
      recursive,
    );
  }

  late final _wire_get_albums_by_tag__method__LocalDbPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(ffi.Int64, ffi.Pointer<wire_LocalDb>, ffi.Pointer<wire_uint_8_list>,
              ffi.Bool)>>('wire_get_albums_by_tag__method__LocalDb');
  late final _wire_get_albums_by_tag__method__LocalDb = _wire_get_albums_by_tag__method__LocalDbPtr
      .asFunction<void Function(int, ffi.Pointer<wire_LocalDb>, ffi.Pointer<wire_uint_8_list>, bool)>();

  void wire_get_tags__method__LocalDb(
    int port_,
    ffi.Pointer<wire_LocalDb> that,
  ) {
    return _wire_get_tags__method__LocalDb(
      port_,
      that,
    );
  }

  late final _wire_get_tags__method__LocalDbPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Int64, ffi.Pointer<wire_LocalDb>)>>(
          'wire_get_tags__method__LocalDb');
  late final _wire_get_tags__method__LocalDb =
      _wire_get_tags__method__LocalDbPtr.asFunction<void Function(int, ffi.Pointer<wire_LocalDb>)>();

  wire_MutexRepoDatabaseRead new_MutexRepoDatabaseRead() {
    return _new_MutexRepoDatabaseRead();
  }

  late final _new_MutexRepoDatabaseReadPtr =
      _lookup<ffi.NativeFunction<wire_MutexRepoDatabaseRead Function()>>('new_MutexRepoDatabaseRead');
  late final _new_MutexRepoDatabaseRead =
      _new_MutexRepoDatabaseReadPtr.asFunction<wire_MutexRepoDatabaseRead Function()>();

  ffi.Pointer<wire_LocalDb> new_box_autoadd_local_db_0() {
    return _new_box_autoadd_local_db_0();
  }

  late final _new_box_autoadd_local_db_0Ptr =
      _lookup<ffi.NativeFunction<ffi.Pointer<wire_LocalDb> Function()>>('new_box_autoadd_local_db_0');
  late final _new_box_autoadd_local_db_0 =
      _new_box_autoadd_local_db_0Ptr.asFunction<ffi.Pointer<wire_LocalDb> Function()>();

  ffi.Pointer<wire_uint_8_list> new_uint_8_list_0(
    int len,
  ) {
    return _new_uint_8_list_0(
      len,
    );
  }

  late final _new_uint_8_list_0Ptr =
      _lookup<ffi.NativeFunction<ffi.Pointer<wire_uint_8_list> Function(ffi.Int32)>>('new_uint_8_list_0');
  late final _new_uint_8_list_0 = _new_uint_8_list_0Ptr.asFunction<ffi.Pointer<wire_uint_8_list> Function(int)>();

  void drop_opaque_MutexRepoDatabaseRead(
    ffi.Pointer<ffi.Void> ptr,
  ) {
    return _drop_opaque_MutexRepoDatabaseRead(
      ptr,
    );
  }

  late final _drop_opaque_MutexRepoDatabaseReadPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Void>)>>('drop_opaque_MutexRepoDatabaseRead');
  late final _drop_opaque_MutexRepoDatabaseRead =
      _drop_opaque_MutexRepoDatabaseReadPtr.asFunction<void Function(ffi.Pointer<ffi.Void>)>();

  ffi.Pointer<ffi.Void> share_opaque_MutexRepoDatabaseRead(
    ffi.Pointer<ffi.Void> ptr,
  ) {
    return _share_opaque_MutexRepoDatabaseRead(
      ptr,
    );
  }

  late final _share_opaque_MutexRepoDatabaseReadPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Void> Function(ffi.Pointer<ffi.Void>)>>(
          'share_opaque_MutexRepoDatabaseRead');
  late final _share_opaque_MutexRepoDatabaseRead =
      _share_opaque_MutexRepoDatabaseReadPtr.asFunction<ffi.Pointer<ffi.Void> Function(ffi.Pointer<ffi.Void>)>();

  void free_WireSyncReturn(
    WireSyncReturn ptr,
  ) {
    return _free_WireSyncReturn(
      ptr,
    );
  }

  late final _free_WireSyncReturnPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(WireSyncReturn)>>('free_WireSyncReturn');
  late final _free_WireSyncReturn = _free_WireSyncReturnPtr.asFunction<void Function(WireSyncReturn)>();

  ffi.Pointer<wire_LocalStore> new_box_autoadd_local_store_2() {
    return _new_box_autoadd_local_store_2();
  }

  late final _new_box_autoadd_local_store_2Ptr =
      _lookup<ffi.NativeFunction<ffi.Pointer<wire_LocalStore> Function()>>('new_box_autoadd_local_store_2');
  late final _new_box_autoadd_local_store_2 =
      _new_box_autoadd_local_store_2Ptr.asFunction<ffi.Pointer<wire_LocalStore> Function()>();
}

class _Dart_Handle extends ffi.Opaque {}

class wire_MutexDummy1Connection extends ffi.Struct {
  external ffi.Pointer<ffi.Void> ptr;
}

class wire_NativePreferenceStore extends ffi.Struct {
  external wire_MutexDummy1Connection conn;
}

class wire_uint_8_list extends ffi.Struct {
  external ffi.Pointer<ffi.Uint8> ptr;

  @ffi.Int32()
  external int len;
}

class wire_MutexRepoDatabaseRead extends ffi.Struct {
  external ffi.Pointer<ffi.Void> ptr;
}

class wire_LocalDb extends ffi.Struct {
  external wire_MutexRepoDatabaseRead repo;
}

class wire_MutexConnection extends ffi.Struct {
  external ffi.Pointer<ffi.Void> ptr;
}

class wire_LocalStore extends ffi.Struct {
  external wire_MutexConnection conn;
}

typedef DartPostCObjectFnType
    = ffi.Pointer<ffi.NativeFunction<ffi.Bool Function(DartPort port_id, ffi.Pointer<ffi.Void> message)>>;
typedef DartPort = ffi.Int64;
