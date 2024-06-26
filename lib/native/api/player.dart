// This file is automatically generated, so please do not edit it.
// Generated by `flutter_rust_bridge`@ 2.0.0-dev.32.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

// Rust type: RustOpaqueMoi<flutter_rust_bridge::for_generated::rust_async::RwLock<AnnixPlayer>>
@sealed
class AnnixPlayer extends RustOpaque {
  AnnixPlayer.dcoDecode(List<dynamic> wire)
      : super.dcoDecode(wire, _kStaticData);

  AnnixPlayer.sseDecode(int ptr, int externalSizeOnNative)
      : super.sseDecode(ptr, externalSizeOnNative, _kStaticData);

  static final _kStaticData = RustArcStaticData(
    rustArcIncrementStrongCount:
        RustLib.instance.api.rust_arc_increment_strong_count_AnnixPlayer,
    rustArcDecrementStrongCount:
        RustLib.instance.api.rust_arc_decrement_strong_count_AnnixPlayer,
    rustArcDecrementStrongCountPtr:
        RustLib.instance.api.rust_arc_decrement_strong_count_AnnixPlayerPtr,
  );

  bool isPlaying({dynamic hint}) =>
      RustLib.instance.api.annixPlayerIsPlaying(that: this, hint: hint);

  factory AnnixPlayer({dynamic hint}) =>
      RustLib.instance.api.annixPlayerNew(hint: hint);

  Future<void> openFile({required String path, dynamic hint}) =>
      RustLib.instance.api
          .annixPlayerOpenFile(that: this, path: path, hint: hint);

  Future<void> pause({dynamic hint}) =>
      RustLib.instance.api.annixPlayerPause(that: this, hint: hint);

  Future<void> play({dynamic hint}) =>
      RustLib.instance.api.annixPlayerPlay(that: this, hint: hint);

  Stream<PlayerStateEvent> playerStateStream({dynamic hint}) =>
      RustLib.instance.api.annixPlayerPlayerStateStream(that: this, hint: hint);

  Stream<ProgressState> progressStream({dynamic hint}) =>
      RustLib.instance.api.annixPlayerProgressStream(that: this, hint: hint);

  Future<void> seek({required int position, dynamic hint}) =>
      RustLib.instance.api
          .annixPlayerSeek(that: this, position: position, hint: hint);

  Future<void> setVolume({required double volume, dynamic hint}) =>
      RustLib.instance.api
          .annixPlayerSetVolume(that: this, volume: volume, hint: hint);

  Future<void> stop({dynamic hint}) =>
      RustLib.instance.api.annixPlayerStop(that: this, hint: hint);
}

enum PlayerStateEvent {
  /// Started playing
  play,

  /// Paused
  pause,

  /// Stopped playing
  stop,
  ;
}

class ProgressState {
  final int position;
  final int duration;

  const ProgressState({
    required this.position,
    required this.duration,
  });

  @override
  int get hashCode => position.hashCode ^ duration.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgressState &&
          runtimeType == other.runtimeType &&
          position == other.position &&
          duration == other.duration;
}
