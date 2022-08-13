import 'dart:async';
import 'dart:math';

import 'package:annix/services/annil/audio_source.dart';
import 'package:annix/services/annil/client.dart';
import 'package:annix/services/lyric/lyric_provider.dart';
import 'package:annix/services/lyric/lyric_provider_anniv.dart';
import 'package:annix/services/lyric/lyric_provider_petitlyrics.dart';
import 'package:annix/global.dart';
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

class PlayerService extends ChangeNotifier {
  static final AudioPlayer player = AudioPlayer();

  PlayerStatus playerStatus = PlayerStatus.stopped;
  LoopMode loopMode = LoopMode.off;
  double volume = 1.0;

  // Playing queue
  List<AnnilAudioSource> queue = [];
  int? playingIndex;
  AnnilAudioSource? get playing =>
      playingIndex != null ? queue[playingIndex!] : null;
  LyricResult? playingLyric;

  PlayerService() {
    PlayerService.player.onPlayerStateChanged.listen((s) {
      playerStatus = PlayerStatus.fromPlayingStatus(s);
      notifyListeners();
    });

    PlayerService.player.onPlayerComplete.listen((event) => next());
  }

  Future<void> play({bool reload = false}) async {
    if (queue.isEmpty) return;

    // activate audio session
    if (!await (await AudioSession.instance).setActive(true)) {
      // request denied
      return;
    }

    if (reload) {
      if (playingIndex != null && playingIndex! < queue.length) {
        FLog.trace(text: "Start playing");

        // FIXME: stop playing before reload
        // We did not stop here because the stop event would interrupt the `buffering` event.

        // await this.stop();
        // final stopStatus = Completer();
        // late StreamSubscription<PlayerStatus> listener;
        // listener = playerStatus.listen((status) {
        //   if (status == PlayerStatus.stopped && !stopStatus.isCompleted) {
        //     stopStatus.complete();
        //     listener.cancel();
        //   }
        // });
        // await stopStatus.future;

        // set lyric to null as loading
        playingLyric = null;
        notifyListeners();

        final source = queue[playingIndex!];
        if (!source.preloaded) {
          playerStatus = PlayerStatus.buffering;
          notifyListeners();
        }

        getLyric(source).then((lyric) {
          if (playing == source) {
            playingLyric = lyric ?? LyricResult.empty();
            notifyListeners();
          }
        });

        await PlayerService.player.play(source, volume: volume);
        if (queue.length > playingIndex! + 1) {
          queue[playingIndex! + 1].preload();
        }
      } else {
        FLog.trace(text: "Stop playing");
        await stop();
      }
    } else {
      FLog.trace(text: "Resume playing");
      await PlayerService.player.resume();
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

  Future<void> stop() async {
    if (playerStatus != PlayerStatus.stopped) {
      await PlayerService.player.stop();
      // this.progress.value = Duration.zero;
      await (await AudioSession.instance).setActive(false);
    }
  }

  Future<void> previous() async {
    FLog.trace(text: "Seek to previous");
    if (queue.isNotEmpty && playingIndex != null) {
      switch (loopMode) {
        case LoopMode.off:
          // to the next song / stop
          if (playingIndex! > 0) {
            playingIndex = playingIndex! - 1;
            notifyListeners();
            await play(reload: true);
          }
          break;
        case LoopMode.all:
          // to the previous song / last song
          playingIndex = (playingIndex! > 0 ? playingIndex! : queue.length) - 1;
          notifyListeners();
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
          playingIndex = rng.nextInt(queue.length);
          notifyListeners();
          await play(reload: true);
          break;
      }
    }
  }

  Future<void> next() async {
    FLog.trace(text: "Seek to next");
    if (queue.isNotEmpty && playingIndex != null) {
      switch (loopMode) {
        case LoopMode.off:
          // to the next song / stop
          if (playingIndex! < queue.length - 1) {
            playingIndex = playingIndex! + 1;
            notifyListeners();
            await play(reload: true);
          } else {
            await stop();
          }
          break;
        case LoopMode.all:
          // to the next song / first song
          playingIndex = (playingIndex! + 1) % queue.length;
          notifyListeners();
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
          playingIndex = rng.nextInt(queue.length);
          notifyListeners();
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
        playingIndex = to;
        notifyListeners();
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

  Future<void> setPlayingQueue(List<AnnilAudioSource> songs,
      {int initialIndex = 0}) async {
    queue = songs;
    playingIndex = songs.isNotEmpty ? initialIndex % songs.length : null;
    notifyListeners();

    await play(reload: true);
  }

  Future<void> setVolume(double volume) async {
    this.volume = volume;
    notifyListeners();

    await PlayerService.player.setVolume(volume);
  }

  Future<void> fullShuffleMode(
      {int count = 30, bool waitUntilPlayback = false}) async {
    final annil =
        Provider.of<CombinedOnlineAnnilClient>(Global.context, listen: false);
    final albums = annil.albums.toList();
    if (albums.isEmpty) {
      return;
    }

    final rand = Random();

    final songs = <Future<AnnilAudioSource>>[];
    final albumIds = <String>[];

    for (int i = 0; i < count; i++) {
      final albumId = albums[rand.nextInt(albums.length)];
      albumIds.add(albumId);
    }

    final metadataMap = await Global.metadataSource.getAlbums(albumIds);
    for (final albumId in albumIds) {
      final metadata = metadataMap[albumId];
      if (metadata != null) {
        // random disc in metadata
        final discIndex = rand.nextInt(metadata.discs.length);
        final disc = metadata.discs[discIndex];
        // random track
        final trackIndex = rand.nextInt(disc.tracks.length);
        final track = disc.tracks[trackIndex];

        if (track.type == TrackType.Normal) {
          songs.add(AnnilAudioSource.from(
            albumId: albumId,
            discId: discIndex + 1,
            trackId: trackIndex + 1,
          ));
        }
      }
    }

    await setLoopMode(LoopMode.off);

    final queue = await Future.wait(songs);
    if (waitUntilPlayback) {
      await setPlayingQueue(queue);
    } else {
      setPlayingQueue(queue);
    }
  }

  void setLyric(LyricResult? lyric) {
    playingLyric = lyric ?? LyricResult.empty();
    notifyListeners();
  }

  Future<LyricResult?> getLyric(AnnilAudioSource item) async {
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
          album: item.track.disc.album.title,
        );
        if (songs.isNotEmpty) {
          lyric = await songs.first.lyric;
        }
      }

      // 4. save to local cache
      if (lyric != null) {
        LyricProvider.saveLocal(item.id, lyric);
      }
      return lyric;
    } catch (e) {
      FLog.error(text: "Failed to fetch lyric", exception: e);
      return null;
    }
  }
}

class PlayingProgress extends ChangeNotifier {
  PlayingProgress() {
    PlayerService.player.onPositionChanged.listen((p) {
      position = p;
      notifyListeners();
    });
    PlayerService.player.onDurationChanged.listen((d) {
      if (d > Duration.zero) {
        if (d > Duration.zero) {
          duration = d;
        } else {
          duration = /* durationMap[player.playing!.id] ?? */ Duration.zero;
        }
        notifyListeners();
      }
    });
  }

  Duration position = Duration.zero;
  Duration duration = Duration.zero;

  // Map<String, Duration> durationMap = Map();
}
