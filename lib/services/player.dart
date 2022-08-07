import 'dart:async';
import 'dart:math';

import 'package:annix/controllers/annil_controller.dart';
import 'package:annix/controllers/anniv_controller.dart';
import 'package:annix/lyric/lyric_provider.dart';
import 'package:annix/lyric/lyric_provider_petitlyrics.dart';
import 'package:annix/models/anniv.dart';
import 'package:annix/models/metadata.dart';
import 'package:annix/services/annil.dart';
import 'package:annix/services/global.dart';
import 'package:audio_session/audio_session.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
      this.playingIndex != null ? this.queue[this.playingIndex!] : null;
  String? playingLyric;

  PlayerService() {
    PlayerService.player.onPlayerStateChanged.listen((s) {
      this.playerStatus = PlayerStatus.fromPlayingStatus(s);
      this.notifyListeners();
    });

    PlayerService.player.onPlayerComplete.listen((event) => this.next());
  }

  Future<void> play({bool reload = false}) async {
    if (this.queue.isEmpty) return;

    // activate audio session
    if (!await (await AudioSession.instance).setActive(true)) {
      // request denied
      return;
    }

    if (reload) {
      if (this.playingIndex != null && this.playingIndex! < this.queue.length) {
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
        this.playingLyric = null;
        notifyListeners();

        final source = this.queue[this.playingIndex!];
        if (!source.preloaded) {
          this.playerStatus = PlayerStatus.buffering;
          notifyListeners();
        }

        this.getLyric(source).then((lyric) {
          if (this.playing == source) {
            this.playingLyric = lyric?.data ?? "";
            notifyListeners();
          }
        });

        await PlayerService.player.play(source, volume: volume);
        if (this.queue.length > this.playingIndex! + 1) {
          this.queue[this.playingIndex! + 1].preload();
        }
      } else {
        FLog.trace(text: "Stop playing");
        await this.stop();
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
    if (this.playerStatus == PlayerStatus.playing) {
      await this.pause();
    } else {
      await this.play();
    }
  }

  Future<void> stop() async {
    if (this.playerStatus != PlayerStatus.stopped) {
      await PlayerService.player.stop();
      // this.progress.value = Duration.zero;
      await (await AudioSession.instance).setActive(false);
    }
  }

  Future<void> previous() async {
    FLog.trace(text: "Seek to previous");
    if (this.queue.isNotEmpty && this.playingIndex != null) {
      switch (this.loopMode) {
        case LoopMode.off:
          // to the next song / stop
          if (this.playingIndex! > 0) {
            this.playingIndex = this.playingIndex! - 1;
            this.notifyListeners();
            await this.play(reload: true);
          }
          break;
        case LoopMode.all:
          // to the previous song / last song
          this.playingIndex = (this.playingIndex! > 0
                  ? this.playingIndex!
                  : this.queue.length) -
              1;
          this.notifyListeners();
          await this.play(reload: true);
          break;
        case LoopMode.one:
          // replay this song
          await this.seek(Duration.zero);
          await this.play();
          break;
        case LoopMode.random:
          // to a random song
          final rng = Random();
          this.playingIndex = rng.nextInt(this.queue.length);
          this.notifyListeners();
          await this.play(reload: true);
          break;
      }
    }
  }

  Future<void> next() async {
    FLog.trace(text: "Seek to next");
    if (this.queue.isNotEmpty && this.playingIndex != null) {
      switch (this.loopMode) {
        case LoopMode.off:
          // to the next song / stop
          if (this.playingIndex! < this.queue.length - 1) {
            this.playingIndex = this.playingIndex! + 1;
            this.notifyListeners();
            await this.play(reload: true);
          } else {
            await this.stop();
          }
          break;
        case LoopMode.all:
          // to the next song / first song
          this.playingIndex = (this.playingIndex! + 1) % this.queue.length;
          this.notifyListeners();
          await this.play(reload: true);
          break;
        case LoopMode.one:
          // replay this song
          await this.seek(Duration.zero);
          await this.play();
          break;
        case LoopMode.random:
          // to a random song
          final rng = Random();
          this.playingIndex = rng.nextInt(this.queue.length);
          this.notifyListeners();
          await this.play(reload: true);
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
    if (this.queue.isNotEmpty) {
      final to = index % this.queue.length;
      if (to != this.playingIndex) {
        // index changed, set new audio source
        this.playingIndex = to;
        this.notifyListeners();
        await this.play(reload: true);
      } else {
        // index not changed, seek to start
        await this.seek(Duration.zero);
      }
    }
  }

  Future<void> setLoopMode(LoopMode mode) async {
    FLog.trace(text: "Set loop mode $mode");
    this.loopMode = mode;
    this.notifyListeners();
  }

  Future<void> setPlayingQueue(List<AnnilAudioSource> songs,
      {int initialIndex = 0}) async {
    this.queue = songs;
    this.playingIndex = songs.isNotEmpty ? initialIndex % songs.length : null;
    this.notifyListeners();

    await this.play(reload: true);
  }

  Future<void> setVolume(double volume) async {
    this.volume = volume;
    this.notifyListeners();

    await PlayerService.player.setVolume(volume);
  }

  Future<void> fullShuffleMode({int count = 30}) async {
    AnnilController annil = Get.find();
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

    final metadataMap =
        await (await Global.metadataSource.future).getAlbums(albumIds);
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

    await this.setLoopMode(LoopMode.off);
    await this.setPlayingQueue(await Future.wait(songs));
  }

  Future<LyricLanguage?> getLyric(AnnilAudioSource item) async {
    final AnnivController anniv = Get.find();
    final id = item.id;

    // 1. local cache
    var lyric = await LyricProvider.getLocal(id);

    // 2. anniv
    if (lyric == null) {
      final lyricResult = await anniv.client!.getLyric(id);
      lyric = lyricResult?.source;
    }

    // 3. lyric provider
    if (lyric == null) {
      LyricProvider provider = LyricProviderPetitLyrics();
      final songs = await provider.search(item.track);
      if (songs.isNotEmpty) {
        lyric = await songs.first.lyric;
      }
    }

    // 4. save to local cache
    if (lyric != null) {
      LyricProvider.saveLocal(item.id, lyric);
    }
    return lyric;
  }
}

class PlayingProgress extends ChangeNotifier {
  PlayingProgress() {
    PlayerService.player.onPositionChanged.listen((p) {
      this.position = p;
      notifyListeners();
    });
    PlayerService.player.onDurationChanged.listen((d) {
      if (d > Duration.zero) {
        if (d > Duration.zero) {
          this.duration = d;
        } else {
          this.duration = /* durationMap[player.playing!.id] ?? */ Duration
              .zero;
        }
        notifyListeners();
      }
    });
  }

  Duration position = Duration.zero;
  Duration duration = Duration.zero;

  // Map<String, Duration> durationMap = Map();
}
