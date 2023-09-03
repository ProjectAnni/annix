import 'package:annix/bridge/native.dart';
import 'package:annix/services/lyric/lyric_source.dart';
import 'package:annix/services/metadata/metadata_model.dart';

enum LoopMode {
  off,
  all,
  one,
  random,
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
