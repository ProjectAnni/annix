import 'package:annix/services/annil/audio_source.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/services/lyric/lyric_provider.dart';
import 'package:annix/services/lyric/lyric_provider_anniv.dart';
import 'package:annix/services/lyric/lyric_provider_petitlyrics.dart';
import 'package:annix/services/metadata/metadata_model.dart';
import 'package:annix/services/playback/playback.dart';
import 'package:f_logs/f_logs.dart';
import 'package:flutter/foundation.dart';

class PlayingTrack extends ChangeNotifier {
  bool _disposed = false;

  final AnnilAudioSource source;

  PlayingTrack(this.source) {
    getLyric().then(updateLyric, onError: (_) => updateLyric(null));
  }

  TrackLyric? lyric;
  Duration position = Duration.zero;
  Duration duration = Duration.zero;

  TrackInfoWithAlbum get track => source.track;

  TrackIdentifier get identifier => source.identifier;

  String get id => source.id;

  void updatePosition(Duration position) {
    this.position = position;
    if (!_disposed) notifyListeners();
  }

  void updateDuration(Duration duration) {
    this.duration = duration;
    if (!_disposed) notifyListeners();
  }

  void updateLyric(TrackLyric? lyric) {
    this.lyric = lyric ?? TrackLyric.empty();
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    source.cancel();
    super.dispose();
  }

  Future<TrackLyric?> getLyric() async {
    if (track.type != TrackType.normal) {
      return TrackLyric(lyric: LyricResult.empty(), type: track.type);
    }

    try {
      final id = this.id;

      // 1. local cache
      var lyric = await LyricProvider.getLocal(id);

      // 2. anniv
      if (lyric == null) {
        final anniv = LyricProviderAnniv();
        final result =
        await anniv.search(track: identifier, title: track.title);
        if (result.isNotEmpty) {
          lyric = await result[0].lyric;
        }
      }

      // 3. lyric provider
      if (lyric == null) {
        final LyricProvider provider = LyricProviderPetitLyrics();
        final songs = await provider.search(
          track: identifier,
          title: track.title,
          artist: track.artist,
          album: track.albumTitle,
        );
        if (songs.isNotEmpty) {
          lyric = await songs.first.lyric;
        }
      }

      // 4. save to local cache
      if (lyric != null) {
        LyricProvider.saveLocal(id, lyric);
        return TrackLyric(lyric: lyric, type: track.type);
      }

      return null;
    } catch (e) {
      FLog.error(text: 'Failed to fetch lyric', exception: e);
      return null;
    }
  }
}
