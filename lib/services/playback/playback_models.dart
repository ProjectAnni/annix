import 'package:annix/services/lyric/lyric_source.dart';
import 'package:annix/services/metadata/metadata_model.dart';
import 'package:annix/native/api/player.dart';
import 'package:flutter/material.dart';

enum LoopMode {
  off,
  all,
  one,
  random;

  Icon getIcon({final Color? inactiveColor}) {
    switch (this) {
      case LoopMode.off:
        return Icon(Icons.repeat, color: inactiveColor);
      case LoopMode.all:
        return const Icon(Icons.repeat);
      case LoopMode.one:
        return const Icon(Icons.repeat_one);
      case LoopMode.random:
        return const Icon(Icons.shuffle);
    }
  }

  LoopMode next() {
    switch (this) {
      case LoopMode.off:
        return LoopMode.all;
      case LoopMode.all:
        return LoopMode.one;
      case LoopMode.one:
        return LoopMode.random;
      case LoopMode.random:
        return LoopMode.off;
    }
  }
}

enum PlayerStatus {
  buffering,
  playing,
  paused,
  stopped;

  factory PlayerStatus.fromPlayingState(final PlayerStateEvent state) {
    switch (state) {
      case PlayerStateEvent.play:
        return PlayerStatus.playing;
      case PlayerStateEvent.pause:
        return PlayerStatus.paused;
      case PlayerStateEvent.stop:
        return PlayerStatus.stopped;
    }
  }
}

class TrackLyric {
  final LyricResult lyric;
  final TrackType type;

  TrackLyric({required this.lyric, required this.type});

  bool get isEmpty => lyric.isEmpty;

  factory TrackLyric.empty() {
    return TrackLyric(lyric: LyricResult.empty(), type: TrackType.normal);
  }
}
