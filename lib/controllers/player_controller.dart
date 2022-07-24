import 'dart:async';
import 'dart:math';

import 'package:annix/controllers/annil_controller.dart';
import 'package:annix/models/anniv.dart';
import 'package:annix/models/metadata.dart';
import 'package:annix/services/annil.dart';
import 'package:annix/services/global.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:f_logs/f_logs.dart';
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

class PlayerController extends GetxController {
  final AudioPlayer player = AudioPlayer();

  Rx<PlayerStatus> playerStatus = PlayerStatus.stopped.obs;
  Rx<LoopMode> loopMode = LoopMode.off.obs;

  Rx<Duration> progress = Duration.zero.obs;
  Rx<Duration> buffered = Duration.zero.obs;
  Rx<Duration> duration = Duration.zero.obs;

  Map<String, Duration> durationMap = Map();

  // Playing queue
  List<AnnilAudioSource> queue = [];
  int? playingIndex;
  AnnilAudioSource? get playing =>
      this.playingIndex != null ? this.queue[this.playingIndex!] : null;

  @override
  onInit() {
    super.onInit();

    this.playerStatus.bindStream(player.onPlayerStateChanged
        .map((s) => PlayerStatus.fromPlayingStatus(s)));
    this.progress.bindStream(player.onPositionChanged);
    this.duration.bindStream(player.onDurationChanged.map((duration) {
      if (duration > Duration.zero) {
        return duration;
      } else {
        return durationMap[this.playing!.id] ?? Duration.zero;
      }
    }));

    this.player.onPlayerComplete.listen((event) => this.next());
  }

  Future<void> play({bool reload = false}) async {
    if (this.queue.isEmpty) return;

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

        final source = this.queue[this.playingIndex!];
        if (!source.preloaded) {
          this.playerStatus.value = PlayerStatus.buffering;
        }
        await this.player.play(source);
        if (this.queue.length > this.playingIndex! + 1) {
          this.queue[this.playingIndex! + 1].preload();
        }
      } else {
        FLog.trace(text: "Stop playing");
        await this.stop();
      }
    } else {
      FLog.trace(text: "Resume playing");
      await player.resume();
    }
  }

  Future<void> pause() async {
    FLog.trace(text: "Pause playing");
    await player.pause();
  }

  Future<void> playOrPause() async {
    if (this.playerStatus.value == PlayerStatus.playing) {
      await this.pause();
    } else {
      await this.play();
    }
  }

  Future<void> stop() async {
    if (this.playerStatus.value != PlayerStatus.stopped) {
      await this.player.stop();
      this.progress.value = Duration.zero;
    }
  }

  Future<void> previous() async {
    FLog.trace(text: "Seek to previous");
    if (this.queue.isNotEmpty && this.playingIndex != null) {
      switch (this.loopMode.value) {
        case LoopMode.off:
          // to the next song / stop
          if (this.playingIndex! > 0) {
            this.playingIndex = this.playingIndex! - 1;
            this.refresh();
            await this.play(reload: true);
          }
          break;
        case LoopMode.all:
          // to the previous song / last song
          this.playingIndex = (this.playingIndex! > 0
                  ? this.playingIndex!
                  : this.queue.length) -
              1;
          this.refresh();
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
          this.refresh();
          await this.play(reload: true);
          break;
      }
    }
  }

  Future<void> next() async {
    FLog.trace(text: "Seek to next");
    if (this.queue.isNotEmpty && this.playingIndex != null) {
      switch (this.loopMode.value) {
        case LoopMode.off:
          // to the next song / stop
          if (this.playingIndex! < this.queue.length - 1) {
            this.playingIndex = this.playingIndex! + 1;
            this.refresh();
            await this.play(reload: true);
          } else {
            await this.stop();
          }
          break;
        case LoopMode.all:
          // to the next song / first song
          this.playingIndex = (this.playingIndex! + 1) % this.queue.length;
          this.refresh();
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
          this.refresh();
          await this.play(reload: true);
          break;
      }
    }
  }

  Future<void> seek(Duration position) async {
    FLog.trace(text: "Seek to position $position");
    await player.seek(position);
  }

  Future<void> jump(int index) async {
    FLog.trace(text: "Jump to $index in playing queue");
    if (this.queue.isNotEmpty) {
      final to = index % this.queue.length;
      if (to != this.playingIndex) {
        // index changed, set new audio source
        this.playingIndex = to;
        this.refresh();
        await this.play(reload: true);
      } else {
        // index not changed, seek to start
        await this.seek(Duration.zero);
      }
    }
  }

  Future<void> setLoopMode(LoopMode mode) async {
    FLog.trace(text: "Set loop mode $mode");
    this.loopMode.value = mode;
  }

  Future<void> setPlayingQueue(List<AnnilAudioSource> songs,
      {int initialIndex = 0}) async {
    this.queue = songs;
    this.playingIndex = songs.isNotEmpty ? initialIndex % songs.length : null;
    this.refresh();
    await this.play(reload: true);
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
}
