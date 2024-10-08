import 'package:annix/services/lyric/lyric_source.dart';
import 'package:annix/services/metadata/metadata_model.dart';
import 'package:annix/native/api/player.dart';
import 'package:flutter/material.dart';

enum ShuffleMode {
  off,
  on;

  Icon getIcon({final Color? activeColor}) {
    switch (this) {
      case ShuffleMode.off:
        return const Icon(Icons.shuffle);
      case ShuffleMode.on:
        return Icon(Icons.shuffle, color: activeColor);
    }
  }

  ShuffleMode next() {
    switch (this) {
      case ShuffleMode.off:
        return ShuffleMode.on;
      case ShuffleMode.on:
        return ShuffleMode.off;
    }
  }
}

enum LoopMode {
  off,
  all,
  one;

  Icon getIcon({final Color? activeColor}) {
    switch (this) {
      case LoopMode.off:
        return const Icon(Icons.repeat);
      case LoopMode.all:
        return Icon(Icons.repeat, color: activeColor);
      case LoopMode.one:
        return Icon(Icons.repeat_one, color: activeColor);
    }
  }

  LoopMode next() {
    switch (this) {
      case LoopMode.off:
        return LoopMode.all;
      case LoopMode.all:
        return LoopMode.one;
      case LoopMode.one:
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
