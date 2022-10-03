import 'dart:convert';
import 'dart:math';

import 'package:annix/global.dart';
import 'package:annix/services/annil/audio_source.dart';
import 'package:annix/services/annil/client.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/services/metadata/metadata.dart';
import 'package:annix/services/metadata/metadata_model.dart';
import 'package:annix/services/playback/playback.dart';
import 'package:annix/ui/widgets/utils/property_value_notifier.dart';
import 'package:audio_session/audio_session.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlaybackService extends ChangeNotifier {
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

  final rng = Random();

  PlaybackService() {
    _load();

    PlaybackService.player.onPlayerStateChanged.listen((s) {
      // stop event from player can not interrupt buffering state
      if (!(playerStatus == PlayerStatus.buffering &&
          s == PlayerState.stopped)) {
        playerStatus = PlayerStatus.fromPlayingStatus(s);
        notifyListeners();
      }
    });

    PlaybackService.player.onPlayerComplete.listen((event) => next());

    // Position
    PlaybackService.player.onPositionChanged.listen((updatedPosition) {
      playing?.updatePosition(updatedPosition);
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
    PlaybackService.player.onDurationChanged.listen((updatedDuration) {
      final id = playing?.id;
      if (id != null) {
        if (updatedDuration > Duration.zero) {
          playing?.updateDuration(updatedDuration);
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

    if (!reload && PlaybackService.player.state == PlayerState.paused) {
      FLog.trace(text: "Resume playing");
      await PlaybackService.player.resume();
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
        await PlaybackService.player.setVolume(volume);
        await PlaybackService.player.setSource(source);
      } else {
        await PlaybackService.player.play(source, volume: volume);
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
    await PlaybackService.player.pause();
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
    await Future.wait([
      if (setInactive) AudioSession.instance.then((i) => i.setActive(false)),
      PlaybackService.player.release(),
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

  Future<void> seek(Duration position) async {
    FLog.trace(text: "Seek to position $position");

    // seek first for ui update
    playing?.updatePosition(position);

    // then notify player
    await PlaybackService.player.seek(position);
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
    await Global.preferences.setInt("player.loopMode", loopMode.index);
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
      await Global.preferences.setInt("player.playingIndex", nowPlayingIndex);
    } else {
      await Global.preferences.remove("player.playingIndex");
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

    await Global.preferences.setStringList(
        "player.queue", queue.map((e) => jsonEncode(e.toJson())).toList());

    await play(reload: true);
  }

  Future<void> setVolume(double volume) async {
    this.volume = volume;
    notifyListeners();

    await PlaybackService.player.setVolume(volume);
    await Global.preferences.setDouble("player.volume", volume);
  }

  Future<void> fullShuffleMode(BuildContext context,
      {int count = 30, bool waitUntilPlayback = false}) async {
    final AnnilService annil = context.read();
    final albums = annil.albums;
    if (albums.isEmpty) {
      return;
    }

    final songs = <Future<AnnilAudioSource?>>[];
    final albumIds = <String>[];

    for (int i = 0; i < count; i++) {
      final albumId = albums[rng.nextInt(albums.length)];
      albumIds.add(albumId);
    }

    final MetadataService metadata = context.read();
    final metadataMap = await metadata.getAlbums(albumIds);
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

        if (annil.isAvailable(id)) {
          if (track.type == TrackType.Normal) {
            songs.add(
              AnnilAudioSource.from(id: id, metadata: metadata),
            );
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
