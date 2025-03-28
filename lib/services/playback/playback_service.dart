import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:annix/providers.dart';
import 'package:annix/services/annil/audio_source.dart';
import 'package:annix/services/annil/annil.dart';
import 'package:annix/services/anniv/anniv.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/services/logger.dart';
import 'package:annix/services/metadata/metadata_model.dart';
import 'package:annix/services/path.dart';
import 'package:annix/services/playback/playback.dart';
import 'package:annix/native/api/player.dart';
import 'package:audio_session/audio_session.dart' hide AVAudioSessionCategory;
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void playFullList({
  required final PlaybackService player,
  required final List<AnnilAudioSource> tracks,
  final bool shuffle = false,
  final int initialIndex = 0,
}) async {
  assert(
    // when shuffle is on, initialIndex can only be zero
    (shuffle && initialIndex == 0) ||
        // or disable shuffle
        !shuffle,
  );

  final trackList = tracks;
  if (shuffle) {
    trackList.shuffle();
  }

  await player.setPlayingQueue(
    trackList,
    initialIndex: initialIndex,
  );
}

AudioQuality fromQuality(PreferQuality q) {
  switch (q) {
    case PreferQuality.low:
      return AudioQuality.low;
    case PreferQuality.medium:
      return AudioQuality.medium;
    case PreferQuality.high:
      return AudioQuality.high;
    case PreferQuality.lossless:
      return AudioQuality.lossless;
  }
}

class PlaybackService extends ChangeNotifier {
  final AnnixPlayer player = AnnixPlayer(cachePath: audioCachePath());

  final Ref ref;

  PlayerStatus playerStatus = PlayerStatus.stopped;
  LoopMode loopMode = LoopMode.off;
  ShuffleMode shuffleMode = ShuffleMode.off;
  double volume = 1.0;

  // Playing queue
  List<AnnilAudioSource> queue = [];

  int? get playingIndex {
    final source = playing.source;
    if (source != null) {
      return queue.indexOf(source);
    }
    return null;
  }

  final PlayingTrack playing;

  final rng = Random();

  final AnnivService anniv;

  void reorderQueue(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= queue.length) return;
    // using > instead of >= here because if we drag to the end of the list,
    // then newIndex will be queue.length
    if (newIndex < 0 || newIndex > queue.length) return;

    if (oldIndex > newIndex) {
      // moving up
      final song = queue.removeAt(oldIndex);
      queue.insert(newIndex, song);
    } else {
      // moving down
      final song = queue.removeAt(oldIndex);
      queue.insert(newIndex - 1, song);
    }

    ref.read(preferencesProvider).set('player.queue_v2',
        queue.map((final e) => jsonEncode(e.toJson())).toList());
    notifyListeners();
  }

  // We've loaded the latest playlist from database, and the player is in paused state,
  // then user may 'resume' playback. Here we should track the 'resume' action as playing once.
  //
  // This boolean is used to track this situation. After setting source in `play`,
  // this field would be set to `true`. It would be set back to false once current playing index
  // is switched, or at the time when the first 'resume' action was produced.
  bool loadedAndPaused = false;

  PlaybackService(this.ref)
      : anniv = ref.read(annivProvider),
        playing = PlayingTrack(ref) {
    _load();

    player.playerStateStream().listen((state) {
      if (state == PlayerStateEvent.stop) {
        next();
      } else {
        final newPlayerStatus = PlayerStatus.fromPlayingState(state);
        if (playerStatus != newPlayerStatus) {
          playerStatus = newPlayerStatus;
          notifyListeners();
        }
      }
    });

    player.progressStream().listen((progress) {
      final position = Duration(milliseconds: progress.position);
      final duration = Duration(milliseconds: progress.duration);

      playing.updatePosition(
          position, duration != Duration.zero ? duration : null);
    });
  }

  _load() {
    final preferences = ref.read(preferencesProvider);
    final queue = preferences.getStringList('player.queue_v2') ?? [];
    final playingIndex = preferences.getInt('player.playingIndex');

    if (playingIndex != null &&
        playingIndex >= 0 &&
        playingIndex < queue.length) {
      this.queue = queue
          .map((final e) => AnnilAudioSource.fromJson(jsonDecode(e)))
          .toList();
      _setPlayingIndex(playingIndex);
    }

    final loopMode = preferences.getInt('player.loopMode');
    this.loopMode = LoopMode.values[loopMode ?? 0];

    final shuffleMode = preferences.getInt('player.shuffleMode');
    this.shuffleMode = ShuffleMode.values[shuffleMode ?? 0];

    volume = preferences.getDouble('player.volume') ?? 1.0;
    player.setVolume(volume: volume);

    WidgetsBinding.instance
        .addPostFrameCallback((_) => play(reload: true, setSourceOnly: true));
  }

  Future<void> play({
    final bool reload = false,
    final bool setSourceOnly = false,
  }) async {
    if (queue.isEmpty) return;

    // activate audio session
    if (!await AudioSession.instance.then((final e) => e.setActive(true))) {
      // request denied
      return;
    }

    if (!reload && !player.isPlaying()) {
      Logger.trace('Resume playing');
      await player.play();

      if (loadedAndPaused) {
        loadedAndPaused = false;
      }
      return;
    }

    final playing = this.playing;
    final source = playing.source;
    if (source == null) {
      await stop();
      return;
    }

    // stop previous playback
    Logger.trace('Start playing');
    await stop(false);

    // TODO: move annil logic to rust and remove the workaround
    final annil = ref.read(annilProvider);
    await annil.syncedToRust.future;

    final settings = ref.read(settingsProvider);
    await player.setTrack(
      identifier: source.identifier.toString(),
      quality: fromQuality(settings.defaultAudioQuality.value),
      opus: settings.experimentalOpus.value,
    );

    if (setSourceOnly) {
      loadedAndPaused = true;
      playerStatus = PlayerStatus.paused;
    } else {
      await player.play();
      playerStatus = PlayerStatus.playing;
    }

    notifyListeners();
  }

  Future<void> pause() async {
    Logger.trace('Pause playing');

    await player.pause();
  }

  Future<void> playOrPause() async {
    if (playerStatus == PlayerStatus.playing) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> stop([final bool setInactive = true]) async {
    if (setInactive) {
      await Future.wait([
        AudioSession.instance.then((final i) => i.setActive(false)),
        player.stop(),
      ]);
    }
  }

  Future<void> previous() async {
    final currentIndex = playingIndex;
    if (queue.isNotEmpty && currentIndex != null) {
      if (shuffleMode == ShuffleMode.on) {
        await _setPlayingIndex(rng.nextInt(queue.length));
        await play(reload: true);
        return;
      }

      switch (loopMode) {
        case LoopMode.off:
          // to the next song / stop
          if (currentIndex > 0) {
            await _setPlayingIndex(currentIndex - 1);
            await play(reload: true);
          }
          break;
        case LoopMode.all:
          // to the previous song / last song
          await _setPlayingIndex(
              (currentIndex > 0 ? currentIndex : queue.length) - 1);
          await play(reload: true);
          break;
        case LoopMode.one:
          // replay this song
          playing.resetReport();
          await seek(Duration.zero);
          await play();
          break;
      }
    }
  }

  Future<void> next() async {
    final currentIndex = playingIndex;
    if (queue.isNotEmpty && currentIndex != null) {
      if (shuffleMode == ShuffleMode.on) {
        await _setPlayingIndex(rng.nextInt(queue.length));
        await play(reload: true);
        return;
      }

      switch (loopMode) {
        case LoopMode.off:
          // to the next song / stop
          if (currentIndex < queue.length - 1) {
            await _setPlayingIndex(currentIndex + 1);
            await play(reload: true);
          } else {
            await stop();
          }
          break;
        case LoopMode.all:
          // to the next song / first song
          await _setPlayingIndex((currentIndex + 1) % queue.length);
          await play(reload: true);
          break;
        case LoopMode.one:
          // replay this song
          await seek(Duration.zero);
          await play();
          break;
      }
    }
  }

  Future<void> seek(final Duration position) async {
    Logger.trace('Seek to position $position');

    // seek first for ui update
    playing.updatePosition(position, null);

    // then notify player
    await player.seek(position: position.inMilliseconds);
  }

  Future<void> remove(final int index) async {
    if (index < 0 || index >= queue.length) return;
    final removeCurrentPlayingTrack = index == playingIndex;

    if (removeCurrentPlayingTrack) {
      await stop();
    }

    queue.removeAt(index);
    if (removeCurrentPlayingTrack) {
      await _setPlayingIndex(index, notify: false);
      await play(reload: true);
    }
    notifyListeners();
  }

  Future<void> jump(final int index) async {
    Logger.trace('Jump to $index in playing queue');
    if (queue.isNotEmpty) {
      final to = index % queue.length;
      if (to != playingIndex) {
        // index changed, set new audio source
        await _setPlayingIndex(to);
        await play(reload: true);
      } else {
        // index not changed, seek to start
        await seek(Duration.zero);
      }
    }
  }

  Future<void> setLoopMode(final LoopMode mode) async {
    loopMode = mode;
    notifyListeners();
    ref.read(preferencesProvider).set('player.loopMode', loopMode.index);
  }

  Future<void> setShuffleMode(final ShuffleMode mode) async {
    shuffleMode = mode;
    notifyListeners();
    ref.read(preferencesProvider).set('player.shuffleMode', shuffleMode.index);
  }

  Future<void> _setPlayingIndex(final int index,
      {final bool reload = false, final bool notify = true}) async {
    loadedAndPaused = false;

    final playing = this.playing;
    final nowPlayingIndex = playingIndex;
    if (nowPlayingIndex != index || reload) {
      await player.pause();
      playing.setSource(queue[index]);
    }

    ref.read(preferencesProvider).set('player.playingIndex', index);
    if (notify) notifyListeners();
  }

  Future<void> setPlayingQueue(final List<AnnilAudioSource> songs,
      {final int initialIndex = 0}) async {
    // 1. set playing queue
    queue = songs;
    // 2. set playing index
    if (songs.isNotEmpty) {
      await _setPlayingIndex(initialIndex % songs.length,
          reload: true, notify: false);
    } else {
      playing.setSource(null);
    }

    ref.read(preferencesProvider).set('player.queue_v2',
        queue.map((final e) => jsonEncode(e.toJson())).toList());

    await play(reload: true);
  }

  Future<void> setVolume(final double volume) async {
    this.volume = min(1.0, volume);
    notifyListeners();

    await player.setVolume(volume: this.volume);
    ref.read(preferencesProvider).set('player.volume', this.volume);
  }

  Future<void> fullShuffleMode(
      {final int count = 10, bool append = true}) async {
    final annil = ref.read(annilProvider);
    final albums = annil.albums;
    if (albums.isEmpty) {
      return;
    }

    final albumIds = <String>[];

    for (int i = 0; i < count; i++) {
      final albumId = albums[rng.nextInt(albums.length)];
      albumIds.add(albumId);
    }

    final metadata = ref.read(metadataProvider);
    final metadataMap = await metadata.getAlbums(albumIds);
    final Set<TrackIdentifier> tracks = {};
    for (final albumId in albumIds) {
      final album = metadataMap[albumId];
      if (album != null) {
        // random disc in metadata
        final discIndex = rng.nextInt(album.discs.length);
        final disc = album.discs[discIndex];
        // random track
        final trackIndex = rng.nextInt(disc.tracks.length);
        final track = disc.tracks[trackIndex];

        final id = TrackIdentifier(
          albumId: albumId,
          discId: discIndex + 1,
          trackId: trackIndex + 1,
        );

        if (annil.isTrackAvailable(id)) {
          if (track.type == TrackType.normal) {
            tracks.add(id);
          }
        }
      }
    }

    await setLoopMode(LoopMode.off);

    final List<AnnilAudioSource> resultQueue =
        tracks.map((final id) => AnnilAudioSource(identifier: id)).toList();

    if (append && queue.isNotEmpty) {
      queue.addAll(resultQueue);
      ref.read(preferencesProvider).set('player.queue_v2',
          queue.map((final e) => jsonEncode(e.toJson())).toList());
      notifyListeners();
    } else {
      unawaited(setPlayingQueue(resultQueue));
    }
  }
}
