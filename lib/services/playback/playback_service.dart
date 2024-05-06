import 'dart:convert';
import 'dart:math';

import 'package:annix/providers.dart';
import 'package:annix/services/annil/audio_source.dart';
import 'package:annix/services/annil/annil.dart';
import 'package:annix/services/anniv/anniv.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/services/metadata/metadata_model.dart';
import 'package:annix/services/path.dart';
import 'package:annix/services/playback/playback.dart';
import 'package:annix/native/api/player.dart';
import 'package:annix/services/settings.dart';
import 'package:annix/ui/widgets/utils/property_value_notifier.dart';
import 'package:audio_session/audio_session.dart' hide AVAudioSessionCategory;
import 'package:f_logs/f_logs.dart';
import 'package:flutter/foundation.dart';
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
  static final AnnixPlayer player = AnnixPlayer(cachePath: playerCachePath());

  // TODO: cache this map
  static final PropertyValueNotifier<Map<String, Duration>> durationMap =
      PropertyValueNotifier({});

  final Ref ref;

  PlayerStatus playerStatus = PlayerStatus.stopped;
  LoopMode loopMode = LoopMode.off;
  double volume = 1.0;

  // Playing queue
  List<AnnilAudioSource> queue = [];

  int? get playingIndex =>
      playing != null ? queue.indexOf(playing!.source) : null;
  PlayingTrack? playing;

  final rng = Random();

  final AnnivService anniv;

  // We've loaded the latest playlist from database, and the player is in paused state,
  // then user may 'resume' playback. Here we should track the 'resume' action as playing once.
  //
  // This boolean is used to track this situation. After setting source in `play`,
  // this field would be set to `true`. It would be set back to false once current playing index
  // is switched, or at the time when the first 'resume' action was produced.
  bool loadedAndPaused = false;

  PlaybackService(this.ref) : anniv = ref.read(annivProvider) {
    _load();

    PlaybackService.player.playerStateStream().listen((state) {
      if (state == PlayerStateEvent.stop) {
        next();
      } else {
        playerStatus = PlayerStatus.fromPlayingState(state);
        notifyListeners();
      }
    });

    PlaybackService.player.progressStream().listen((progress) {
      // Position
      playing?.updatePosition(Duration(milliseconds: progress.position));

      // Duration
      if (progress.duration > 0) {
        playing?.updateDuration(Duration(milliseconds: progress.duration));
      }
    });

    // Duration
    PlaybackService.durationMap.addListener(() {
      final id = playing?.id;
      if (id != null) {
        final duration = durationMap.value[id];
        if (duration != null) {
          playing?.updateDuration(duration);
        }
      }
    });
  }

  _load() {
    final preferences = ref.read(preferencesProvider);
    final queue = preferences.getStringList('player.queue') ?? [];
    final playingIndex = preferences.getInt('player.playingIndex');

    if (playingIndex != null &&
        playingIndex >= 0 &&
        playingIndex < queue.length) {
      this.queue = queue
          .map((final e) => AnnilAudioSource.fromJson(jsonDecode(e)))
          .toList();
      setPlayingIndex(playingIndex);
    }

    final loopMode = preferences.getInt('player.loopMode');
    this.loopMode = LoopMode.values[loopMode ?? 0];

    volume = preferences.getDouble('player.volume') ?? 1.0;
    PlaybackService.player.setVolume(volume: volume);

    WidgetsBinding.instance.addPostFrameCallback((final _) =>
        play(reload: true, setSourceOnly: true, trackPlayback: false));

    final db = ref.read(localDatabaseProvider);
    final annilServersStream = db.sortedAnnilServers().watch();
    annilServersStream.listen((servers) {
      PlaybackService.player.clearProvider();
      for (final server in servers) {
        PlaybackService.player.addProvider(
            url: server.url, auth: server.token, priority: server.priority);
      }
    });
  }

  Future<void> play({
    final bool reload = false,
    final bool setSourceOnly = false,
    final bool trackPlayback = true,
  }) async {
    if (queue.isEmpty) return;

    // activate audio session
    if (!await AudioSession.instance.then((final e) => e.setActive(true))) {
      // request denied
      return;
    }

    if (!reload && !PlaybackService.player.isPlaying()) {
      FLog.trace(text: 'Resume playing');
      await PlaybackService.player.play();

      if (loadedAndPaused) {
        loadedAndPaused = false;

        final source = this.playing?.source;
        if (source != null) {
          anniv.trackPlayback(
            source.identifier,
            DateTime.now().millisecondsSinceEpoch ~/ 1000,
          );
        }
      }
      return;
    }

    final playing = this.playing;
    if (playing == null) {
      await stop();
      return;
    }

    // stop previous playback
    FLog.trace(text: 'Start playing');
    await stop(false);

    final source = playing.source;
    if (trackPlayback) {
      // FIXME: track playback after 1/3 of the song is played
      // Notice: we should not await statistics
      if (!kDebugMode) {
        anniv.trackPlayback(
          source.identifier,
          DateTime.now().millisecondsSinceEpoch ~/ 1000,
        );
      }
    }

    final settings = ref.read(settingsProvider);
    await PlaybackService.player.setTrack(
        identifier: source.identifier.toString(),
        quality: fromQuality(settings.defaultAudioQuality.value));

    if (setSourceOnly) {
      loadedAndPaused = true;
      playerStatus = PlayerStatus.paused;
    } else {
      await PlaybackService.player.play();
      playerStatus = PlayerStatus.playing;
    }

    notifyListeners();
  }

  Future<void> pause() async {
    FLog.trace(text: 'Pause playing');

    await PlaybackService.player.pause();
    // deactivate audio session
    await AudioSession.instance.then((final e) => e.setActive(false));
  }

  Future<void> playOrPause() async {
    if (playerStatus == PlayerStatus.playing) {
      await pause();
    } else {
      await play(trackPlayback: false);
    }
  }

  Future<void> stop([final bool setInactive = true]) async {
    playing?.updateDuration(Duration.zero);
    if (setInactive) {
      await Future.wait([
        AudioSession.instance.then((final i) => i.setActive(false)),
        PlaybackService.player.stop(),
      ]);
    }
  }

  Future<void> previous() async {
    final currentIndex = playingIndex;
    if (queue.isNotEmpty && currentIndex != null) {
      switch (loopMode) {
        case LoopMode.off:
          // to the next song / stop
          if (currentIndex > 0) {
            setPlayingIndex(currentIndex - 1);
            await play(reload: true);
          }
          break;
        case LoopMode.all:
          // to the previous song / last song
          setPlayingIndex((currentIndex > 0 ? currentIndex : queue.length) - 1);
          await play(reload: true);
          break;
        case LoopMode.one:
          // replay this song
          await seek(Duration.zero);
          await play();
          break;
        case LoopMode.random:
          // to a random song
          setPlayingIndex(rng.nextInt(queue.length));
          await play(reload: true);
          break;
      }
    }
  }

  Future<void> next() async {
    final currentIndex = playingIndex;
    if (queue.isNotEmpty && currentIndex != null) {
      switch (loopMode) {
        case LoopMode.off:
          // to the next song / stop
          if (currentIndex < queue.length - 1) {
            setPlayingIndex(currentIndex + 1);
            await play(reload: true);
          } else {
            await stop();
          }
          break;
        case LoopMode.all:
          // to the next song / first song
          setPlayingIndex((currentIndex + 1) % queue.length);
          await play(reload: true);
          break;
        case LoopMode.one:
          // replay this song
          await seek(Duration.zero);
          await play();
          break;
        case LoopMode.random:
          // to a random song
          setPlayingIndex(rng.nextInt(queue.length));
          await play(reload: true);
          break;
      }
    }
  }

  Future<void> seek(final Duration position) async {
    FLog.trace(text: 'Seek to position $position');

    // seek first for ui update
    playing?.updatePosition(position);

    // then notify player
    await PlaybackService.player.seek(position: position.inMilliseconds);
  }

  Future<void> remove(final int index) async {
    if (index < 0 || index >= queue.length) return;
    final removeCurrentPlayingTrack = index == playingIndex;

    if (removeCurrentPlayingTrack) {
      await stop();
    }

    queue.removeAt(index);
    if (removeCurrentPlayingTrack) {
      setPlayingIndex(index, notify: false);
      await play(reload: true);
    }
    notifyListeners();
  }

  Future<void> jump(final int index) async {
    FLog.trace(text: 'Jump to $index in playing queue');
    if (queue.isNotEmpty) {
      final to = index % queue.length;
      if (to != playingIndex) {
        // index changed, set new audio source
        setPlayingIndex(to);
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

  Future<void> setPlayingIndex(final int index,
      {final bool reload = false, final bool notify = true}) async {
    loadedAndPaused = false;

    final playing = this.playing;
    final nowPlayingIndex = playingIndex;
    if (nowPlayingIndex != index || reload) {
      playing?.dispose();
      this.playing = PlayingTrack(queue[index], ref);
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
      setPlayingIndex(initialIndex % songs.length, reload: true, notify: false);
    } else {
      playing?.dispose();
      playing = null;
    }

    ref.read(preferencesProvider).set('player.queue',
        queue.map((final e) => jsonEncode(e.toJson())).toList());

    await play(reload: true);
  }

  Future<void> setVolume(final double volume) async {
    this.volume = volume;
    notifyListeners();

    await PlaybackService.player.setVolume(volume: volume);
    ref.read(preferencesProvider).set('player.volume', volume);
  }

  Future<void> fullShuffleMode(
      {final int count = 30, final bool waitUntilPlayback = false}) async {
    final AnnilService annil = ref.read(annilProvider);
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

    final songs = tracks
        .map((final id) => AnnilAudioSource.from(id: id, metadata: metadata));
    await setLoopMode(LoopMode.off);

    final queue = await Future.wait(songs);
    final List<AnnilAudioSource> resultQueue = [];
    for (final song in queue) {
      if (song != null) {
        resultQueue.add(song);
      }
    }
    if (waitUntilPlayback) {
      await setPlayingQueue(resultQueue);
    } else {
      setPlayingQueue(resultQueue);
    }
  }
}
