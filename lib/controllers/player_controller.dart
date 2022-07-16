import 'dart:math';

import 'package:annix/controllers/annil_controller.dart';
import 'package:annix/controllers/anniv_controller.dart';
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

class PlayerController extends GetxController {
  final AudioPlayer player = AudioPlayer();
  final AnnivController anniv = Get.find();

  Rx<PlayerState> playerState = PlayerState.stopped.obs;
  Rx<LoopMode> loopMode = LoopMode.off.obs;

  Rx<Duration> progress = Duration.zero.obs;
  Rx<Duration> buffered = Duration.zero.obs;
  Rx<Duration> duration = Duration.zero.obs;

  RxMap<String, Duration> durationMap = RxMap();

  // Playing queue
  List<AnnilAudioSource> queue = [];
  int? playingIndex;
  AnnilAudioSource? get playing =>
      this.playingIndex != null ? this.queue[this.playingIndex!] : null;

  @override
  onInit() {
    super.onInit();

    this.playerState.bindStream(player.onPlayerStateChanged);
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

  Future<void> play([bool reload = false]) async {
    if (reload) {
      if (this.playingIndex != null && this.playingIndex! < this.queue.length) {
        FLog.trace(text: "Start playing");
        await this.player.play(this.queue[this.playingIndex!]);
        if (this.queue.length > this.playingIndex! + 1) {
          this.queue[this.playingIndex! + 1].preload();
        }
      } else {
        FLog.trace(text: "Stop playing");
        await this.player.stop();
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
    if (this.playerState.value == PlayerState.playing) {
      await this.pause();
    } else {
      await this.play();
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
            await this.play(true);
          }
          break;
        case LoopMode.all:
          // to the previous song / last song
          this.playingIndex = (this.playingIndex! > 0
                  ? this.playingIndex!
                  : this.queue.length) -
              1;
          this.refresh();
          await this.play(true);
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
          await this.play(true);
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
            await this.play(true);
          }
          break;
        case LoopMode.all:
          // to the next song / first song
          this.playingIndex = (this.playingIndex! + 1) % this.queue.length;
          this.refresh();
          await this.play(true);
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
          await this.play(true);
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
        await this.play(true);
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
    await this.play(true);
  }

  Future<void> fullShuffleMode({int count = 30}) async {
    AnnilController annil = Get.find();
    final albums = annil.albums.toList();
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
