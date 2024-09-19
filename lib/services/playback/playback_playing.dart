import 'package:annix/providers.dart';
import 'package:annix/services/annil/audio_source.dart';
import 'package:annix/services/logger.dart';
import 'package:annix/services/lyric/lyric_source.dart';
import 'package:annix/services/lyric/lyric_source_anniv.dart';
import 'package:annix/services/lyric/lyric_source_petitlyrics.dart';
import 'package:annix/services/metadata/metadata_model.dart';
import 'package:annix/services/playback/playback.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PlayingTrack extends ChangeNotifier {
  final Ref ref;

  AnnilAudioSource? source;
  bool reported = false;

  PlayingTrack(this.ref);

  void setSource(AnnilAudioSource? source) {
    this.source = source;
    position = Duration.zero;
    duration = Duration.zero;
    reported = false;

    if (source != null) {
      getLyric().then(updateLyric, onError: (final _) => updateLyric(null));
    }
    notifyListeners();
  }

  void resetReport() {
    reported = false;
  }

  TrackLyric? lyric;
  Duration position = Duration.zero;
  Duration duration = Duration.zero;

  double get progress => duration.inMilliseconds == 0
      ? 0
      : position.inMilliseconds / duration.inMilliseconds;

  void updatePosition(final Duration position) {
    this.position = position;
    notifyListeners();

    if (!reported &&
        duration != Duration.zero &&
        position.inSeconds >= (duration.inSeconds / 3)) {
      reported = true;
      ref.read(annivProvider).trackPlayback(
          source!.identifier, DateTime.now().millisecondsSinceEpoch ~/ 1000);
    }
  }

  void updateDuration(final Duration duration) {
    this.duration = duration;
    notifyListeners();
  }

  void updateLyric(final TrackLyric? lyric) {
    this.lyric = lyric ?? TrackLyric.empty();
    notifyListeners();
  }

  @Deprecated('Do not call PlayingTrack.dispose() as it is singleton now.')
  @override
  void dispose() {
    super.dispose();
  }

  Future<TrackLyric?> getLyric() async {
    final source = this.source;
    if (source == null) {
      return null;
    }

    if (source.track.type != TrackType.normal) {
      return TrackLyric(lyric: LyricResult.empty(), type: source.track.type);
    }

    try {
      final id = source.id;

      // 1. local cache
      var lyric = await LyricSource.getLocal(id);

      // 2. anniv
      if (lyric == null) {
        final anniv = LyricSourceAnniv(ref);
        final result = await anniv.search(
            track: source.identifier, title: source.track.title);
        if (result.isNotEmpty) {
          lyric = await result[0].lyric;
        }
      }

      // 3. lyric provider
      if (lyric == null) {
        final LyricSource provider = LyricSourcePetitLyrics();
        final songs = await provider.search(
          track: source.identifier,
          title: source.track.title,
          artist: source.track.artist,
          album: source.track.albumTitle,
        );
        if (songs.isNotEmpty) {
          lyric = await songs.first.lyric;
        }
      }

      // 4. save to local cache
      if (lyric != null) {
        await LyricSource.saveLocal(id, lyric);
        return TrackLyric(lyric: lyric, type: source.track.type);
      }

      return null;
    } catch (e) {
      Logger.error('Failed to fetch lyric', exception: e);
      return null;
    }
  }
}
