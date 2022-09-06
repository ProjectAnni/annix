import 'dart:async';
import 'dart:math';

import 'package:annix/global.dart';
import 'package:annix/services/annil/audio_source.dart';
import 'package:annix/services/annil/client.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/services/lyric/lyric_provider.dart';
import 'package:annix/services/lyric/lyric_provider_anniv.dart';
import 'package:annix/services/lyric/lyric_provider_petitlyrics.dart';
import 'package:annix/services/metadata/metadata.dart';
import 'package:annix/services/metadata/metadata_model.dart';
import 'package:audio_session/audio_session.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  factory PlayerStatus.fromPlayingStatus(PlayerState state) {
    switch (state) {
      case PlayerState.playing:
        return PlayerStatus.playing;
      case PlayerState.paused:
        return PlayerStatus.paused;
      case PlayerState.stopped:
      case PlayerState.completed:
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
    return TrackLyric(lyric: LyricResult.empty(), type: TrackType.Normal);
  }
}

class PlayerService extends ChangeNotifier {
  static final AudioPlayer player = AudioPlayer();

  // TODO: cache this map
  static final ValueNotifier<Map<String, Duration>> durationMap =
      ValueNotifier({});

  PlayerStatus playerStatus = PlayerStatus.stopped;
  LoopMode loopMode = LoopMode.off;
  double volume = 1.0;

  // Playing queue
  List<AnnilAudioSource> queue = [];
  int? playingIndex;

  AnnilAudioSource? get playing =>
      playingIndex != null ? queue[playingIndex!] : null;

  TrackLyric? playingLyric;

  // Progress
  Duration position = Duration.zero;
  Duration duration = Duration.zero;

  PlayerService() {
    PlayerService.player.onPlayerStateChanged.listen((s) {
      // stop event from player can not interrupt buffering state
      if (!(playerStatus == PlayerStatus.buffering &&
          s == PlayerState.stopped)) {
        playerStatus = PlayerStatus.fromPlayingStatus(s);
        notifyListeners();
      }
    });

    PlayerService.player.onPlayerComplete.listen((event) => next());

    // Position
    PlayerService.player.onPositionChanged.listen((updatedPosition) {
      position = updatedPosition;
      notifyListeners();
    });
    // Duration
    PlayerService.durationMap.addListener(() {
      final id = playing?.id;
      if (id != null) {
        final d = durationMap.value[id];
        if (d != null) {
          duration = d;
          notifyListeners();
        }
      }
    });
    PlayerService.player.onDurationChanged.listen((updatedDuration) {
      final id = playing?.id;
      if (id != null) {
        if (updatedDuration > Duration.zero) {
          duration = updatedDuration;
          notifyListeners();
        }
      }
    });
  }

  Future<void> play({bool reload = false}) async {
    if (queue.isEmpty) return;

    if (!reload) {
      FLog.trace(text: "Resume playing");
      await PlayerService.player.resume();
      return;
    }

    final currentIndex = playingIndex;
    if (currentIndex == null || currentIndex >= queue.length) {
      FLog.trace(text: "Stop playing");
      await stop();
      return;
    }

    // activate audio session
    if (!await AudioSession.instance.then((e) => e.setActive(true))) {
      // request denied
      return;
    }

    FLog.trace(text: "Start playing");

    // set lyric to null as loading
    playingLyric = null;
    await stop(false);
    notifyListeners();

    final source = queue[currentIndex];
    final toPlayId = source.id;
    if (!source.preloaded) {
      // current track is not preloaded, buffering
      playerStatus = PlayerStatus.buffering;
      notifyListeners();
    }

    // preload the next track
    if (queue.length > currentIndex + 1) {
      queue[playingIndex! + 1].preload();
    }

    getLyric(source).then((lyric) {
      if (playing?.id == toPlayId) {
        setLyric(lyric);
      }
    }, onError: (err) {
      if (playing?.id == toPlayId) {
        setLyric(null);
      }
    });

    try {
      // wait for audio file to download and play it
      await PlayerService.player.play(source, volume: volume);
    } catch (e) {
      if (e is AudioCancelledError) {
        return;
      }

      // TODO: tell user why skipped
      FLog.error(text: "Failed to play", exception: e);
      next();
    }

    // when playback start, set state to playing
    if (playing?.id == toPlayId && playerStatus == PlayerStatus.buffering) {
      playerStatus = PlayerStatus.playing;
      notifyListeners();
    }
  }

  Future<void> pause() async {
    FLog.trace(text: "Pause playing");
    await PlayerService.player.pause();
  }

  Future<void> playOrPause() async {
    if (playerStatus == PlayerStatus.playing) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> stop([bool setInactive = true]) async {
    position = Duration.zero;
    notifyListeners();
    await Future.wait([
      if (setInactive) AudioSession.instance.then((i) => i.setActive(false)),
      PlayerService.player.release(),
    ]);
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
          final rng = Random();
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
          final rng = Random();
          setPlayingIndex(rng.nextInt(queue.length));
          await play(reload: true);
          break;
      }
    }
  }

  Future<void> seek(Duration position) async {
    FLog.trace(text: "Seek to position $position");
    await PlayerService.player.seek(position);
  }

  Future<void> jump(int index) async {
    FLog.trace(text: "Jump to $index in playing queue");
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

  Future<void> setLoopMode(LoopMode mode) async {
    FLog.trace(text: "Set loop mode $mode");
    loopMode = mode;
    notifyListeners();
  }

  Future<void> setPlayingIndex(int index) async {
    if (playingIndex != index) {
      playing?.cancel();
      playingIndex = index;
      duration = Duration.zero;
    }
    notifyListeners();
  }

  Future<void> setPlayingQueue(List<AnnilAudioSource> songs,
      {int initialIndex = 0}) async {
    // 1. cancel current playing(loading) track
    playing?.cancel();
    // 2. set playing queue
    queue = songs;
    // 3. set playing index
    playingIndex = songs.isNotEmpty ? initialIndex % songs.length : null;
    // 4. set duration to zero
    duration = Duration.zero;

    notifyListeners();
    await play(reload: true);
  }

  Future<void> setVolume(double volume) async {
    this.volume = volume;
    notifyListeners();

    await PlayerService.player.setVolume(volume);
  }

  Future<void> fullShuffleMode(BuildContext context,
      {int count = 30, bool waitUntilPlayback = false}) async {
    final CombinedOnlineAnnilClient annil = context.read();
    final albums = annil.albums;
    if (albums.isEmpty) {
      return;
    }

    final rand = Random();

    final songs = <Future<AnnilAudioSource?>>[];
    final albumIds = <String>[];

    for (int i = 0; i < count; i++) {
      final albumId = albums[rand.nextInt(albums.length)];
      albumIds.add(albumId);
    }

    final MetadataService metadata = context.read();
    final metadataMap = await metadata.getAlbums(albumIds);
    for (final albumId in albumIds) {
      final metadata = metadataMap[albumId];
      if (metadata != null) {
        // random disc in metadata
        final discIndex = rand.nextInt(metadata.discs.length);
        final disc = metadata.discs[discIndex];
        // random track
        final trackIndex = rand.nextInt(disc.tracks.length);
        final track = disc.tracks[trackIndex];

        final id = TrackIdentifier(
          albumId: albumId,
          discId: discIndex + 1,
          trackId: trackIndex + 1,
        );

        if (annil.isAvailable(id)) {
          if (track.type == TrackType.Normal) {
            // ignore: use_build_context_synchronously
            songs.add(AnnilAudioSource.from(Global.context, id: id));
          }
        }
      }
    }

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

  void setLyric(TrackLyric? lyric) {
    playingLyric = lyric ?? TrackLyric.empty();
    notifyListeners();
  }

  Future<TrackLyric?> getLyric(AnnilAudioSource item) async {
    if (item.track.type != TrackType.Normal) {
      return TrackLyric(lyric: LyricResult.empty(), type: item.track.type);
    }

    try {
      final id = item.id;

      // 1. local cache
      var lyric = await LyricProvider.getLocal(id);

      // 2. anniv
      if (lyric == null) {
        final anniv = LyricProviderAnniv();
        final result =
            await anniv.search(track: item.identifier, title: item.track.title);
        if (result.isNotEmpty) {
          lyric = await result[0].lyric;
        }
      }

      // 3. lyric provider
      if (lyric == null) {
        LyricProvider provider = LyricProviderPetitLyrics();
        final songs = await provider.search(
          track: item.identifier,
          title: item.track.title,
          artist: item.track.artist,
          album: item.track.albumTitle,
        );
        if (songs.isNotEmpty) {
          lyric = await songs.first.lyric;
        }
      }

      // 4. save to local cache
      if (lyric != null) {
        LyricProvider.saveLocal(item.id, lyric);
        return TrackLyric(lyric: lyric, type: item.track.type);
      }

      return null;
    } catch (e) {
      FLog.error(text: "Failed to fetch lyric", exception: e);
      return null;
    }
  }
}
