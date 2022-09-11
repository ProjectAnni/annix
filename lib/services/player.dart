import 'dart:async';
import 'dart:convert';
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
import 'package:annix/ui/widgets/utils/property_value_notifier.dart';
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

class PlayingTrack extends ChangeNotifier {
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
    notifyListeners();
  }

  void updateDuration(Duration duration) {
    this.duration = duration;
    notifyListeners();
  }

  void updateLyric(TrackLyric? lyric) {
    this.lyric = lyric ?? TrackLyric.empty();
    notifyListeners();
  }

  @override
  void dispose() {
    source.cancel();
    super.dispose();
  }

  Future<TrackLyric?> getLyric() async {
    if (track.type != TrackType.Normal) {
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
        LyricProvider provider = LyricProviderPetitLyrics();
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
      FLog.error(text: "Failed to fetch lyric", exception: e);
      return null;
    }
  }
}

class PlayerService extends ChangeNotifier {
  static final AudioPlayer player = AudioPlayer();

  // TODO: cache this map
  static final PropertyValueNotifier<Map<String, Duration>> durationMap =
      PropertyValueNotifier({});

  PlayerStatus playerStatus = PlayerStatus.stopped;
  LoopMode loopMode = LoopMode.off;
  double volume = 1.0;

  // Playing queue
  List<AnnilAudioSource> queue = [];

  int? get playingIndex =>
      playing != null ? queue.indexOf(playing!.source) : null;
  PlayingTrack? playing;

  PlayerService() {
    _load();

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
      playing?.updatePosition(updatedPosition);
    });
    // Duration
    PlayerService.durationMap.addListener(() {
      final id = playing?.id;
      if (id != null) {
        final duration = durationMap.value[id];
        if (duration != null) {
          playing?.updateDuration(duration);
          notifyListeners();
        }
      }
    });
    PlayerService.player.onDurationChanged.listen((updatedDuration) {
      final id = playing?.id;
      if (id != null) {
        if (updatedDuration > Duration.zero) {
          playing?.updateDuration(updatedDuration);
          notifyListeners();
        }
      }
    });
  }

  _load() {
    final queue = Global.preferences.getStringList('player.queue') ?? [];
    this.queue =
        queue.map((e) => AnnilAudioSource.fromJson(jsonDecode(e))).toList();

    final playingIndex = Global.preferences.getInt('player.playingIndex');
    if (playingIndex != null) {
      setPlayingIndex(playingIndex);
    }

    final loopMode = Global.preferences.getInt('player.loopMode');
    this.loopMode = LoopMode.values[loopMode ?? 0];

    volume = Global.preferences.getDouble('player.volume') ?? 1.0;

    WidgetsBinding.instance
        .addPostFrameCallback((_) => play(reload: true, setSourceOnly: true));
  }

  Future<void> play({bool reload = false, setSourceOnly = false}) async {
    if (queue.isEmpty) return;

    // activate audio session
    if (!await AudioSession.instance.then((e) => e.setActive(true))) {
      // request denied
      return;
    }

    if (!reload && PlayerService.player.state == PlayerState.paused) {
      FLog.trace(text: "Resume playing");
      await PlayerService.player.resume();
      return;
    }

    final playing = this.playing;
    if (playing == null) {
      await stop();
      return;
    }
    final currentIndex = playingIndex!;

    // stop previous playback
    FLog.trace(text: "Start playing");
    await stop(false);

    final source = playing.source;
    final toPlayId = source.id;
    if (!source.preloaded) {
      // current track is not preloaded, buffering
      playerStatus = PlayerStatus.buffering;
      notifyListeners();
    }

    // preload the next track
    if (queue.length > currentIndex + 1) {
      queue[currentIndex + 1].preload();
    }

    try {
      // wait for audio file to download and play it
      if (setSourceOnly) {
        await PlayerService.player.setVolume(volume);
        await PlayerService.player.setSource(source);
      } else {
        await PlayerService.player.play(source, volume: volume);
      }
    } catch (e) {
      if (e is AudioCancelledError) {
        return;
      }

      // TODO: tell user why skipped
      FLog.error(text: "Failed to play", exception: e);
      next();
    }

    // when playback starts, set state to playing
    if (playing.id == toPlayId && playerStatus == PlayerStatus.buffering) {
      if (setSourceOnly) {
        playerStatus = PlayerStatus.paused;
      } else {
        playerStatus = PlayerStatus.playing;
      }
      notifyListeners();
    }
  }

  Future<void> pause() async {
    FLog.trace(text: "Pause playing");
    // deactivate audio session
    if (!await AudioSession.instance.then((e) => e.setActive(false))) {
      // request denied
      return;
    }
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
    playing?.updateDuration(Duration.zero);
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

    // seek first for ui update
    playing?.updatePosition(position);
    notifyListeners();

    // then notify player
    await PlayerService.player.seek(position);
  }

  Future<void> remove(int index) async {
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
    loopMode = mode;
    notifyListeners();
    Global.preferences.setInt("player.loopMode", loopMode.index);
  }

  Future<void> setPlayingIndex(int index,
      {bool reload = false, bool notify = true}) async {
    final playing = this.playing;
    final nowPlayingIndex = playingIndex;
    if (nowPlayingIndex != index || reload) {
      playing?.dispose();
      this.playing = PlayingTrack(queue[index]);
    }

    if (nowPlayingIndex != null) {
      Global.preferences.setInt("player.playingIndex", nowPlayingIndex);
    } else {
      Global.preferences.remove("player.playingIndex");
    }
    if (notify) notifyListeners();
  }

  Future<void> setPlayingQueue(List<AnnilAudioSource> songs,
      {int initialIndex = 0}) async {
    // 1. set playing queue
    queue = songs;
    // 2. set playing index
    if (songs.isNotEmpty) {
      setPlayingIndex(initialIndex % songs.length, reload: true, notify: false);
    } else {
      playing?.dispose();
      playing = null;
    }

    Global.preferences.setStringList(
        "player.queue", queue.map((e) => jsonEncode(e.toJson())).toList());

    await play(reload: true);
  }

  Future<void> setVolume(double volume) async {
    this.volume = volume;
    notifyListeners();

    await PlayerService.player.setVolume(volume);
    await Global.preferences.setDouble("player.volume", volume);
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
      final album = metadataMap[albumId];
      if (album != null) {
        // random disc in metadata
        final discIndex = rand.nextInt(album.discs.length);
        final disc = album.discs[discIndex];
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
            songs.add(AnnilAudioSource.from(id: id, metadata: metadata));
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
}
