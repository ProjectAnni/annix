import 'package:annix/services/lyric/lyric_provider.dart';
import 'package:annix/services/metadata/metadata_model.dart';
import 'package:simple_audio/simple_audio.dart';

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

  factory PlayerStatus.fromPlaybackState(PlaybackState state) {
    switch (state) {
      case PlaybackState.play:
        return PlayerStatus.playing;
      case PlaybackState.pause:
        return PlayerStatus.paused;
      case PlaybackState.done:
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
