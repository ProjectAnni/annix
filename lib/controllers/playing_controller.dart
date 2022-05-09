import 'dart:math';

import 'package:annix/controllers/annil_controller.dart';
import 'package:annix/models/metadata.dart';
import 'package:annix/services/global.dart';
import 'package:annix/third_party/just_audio_background/just_audio_background.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class PlayingController extends GetxController {
  AudioPlayer player = AudioPlayer(
    audioLoadConfiguration: AudioLoadConfiguration(
      androidLoadControl: AndroidLoadControl(
        enableConstantBitrateSeeking: true,
      ),
    ),
  );

  @override
  onInit() {
    this.isPlaying.bindStream(player.playingStream);
    this.progress.bindStream(player.positionStream);
    this.buffered.bindStream(player.bufferedPositionStream);
    this.duration.bindStream(player.durationStream);

    this.loopMode.bindStream(player.loopModeStream);
    this.shuffleEnabled.bindStream(player.shuffleModeEnabledStream);
    this.playingIndex.bindStream(player.currentIndexStream);

    this.queue.listen((queue) {
      final index = this.playingIndex.value;
      if (index == null || index >= queue.length) {
        currentPlaying.value = null;
      } else {
        currentPlaying.value = queue[this.playingIndex.value!];
      }
    });
    this.playingIndex.listen((index) {
      if (index == null || index >= this.queue.length) {
        currentPlaying.value = null;
      } else {
        currentPlaying.value = this.queue[index];
      }
    });

    super.onInit();
  }

  Rx<bool> isPlaying = false.obs;
  Rx<LoopMode> loopMode = LoopMode.off.obs;
  Rx<bool> shuffleEnabled = false.obs;

  Rx<Duration> progress = Duration.zero.obs;
  Rx<Duration> buffered = Duration.zero.obs;
  Rxn<Duration> duration = Rxn();

  RxMap<String, Duration> durationMap = RxMap();

  Future<void> play() async {
    debugPrint("[PlayingController] play()");
    await player.play();
  }

  Future<void> pause() async {
    debugPrint("[PlayingController] pause()");
    await player.pause();
  }

  Future<void> playOrPause() async {
    if (this.isPlaying.value) {
      await this.pause();
    } else {
      await this.play();
    }
  }

  Future<void> previous() async {
    await player.seekToPrevious();
  }

  Future<void> next() async {
    await player.seekToNext();
  }

  Future<void> seek(Duration position) async {
    await player.seek(position);
  }

  Future<void> jump(int index) async {
    debugPrint("[PlayingController] jump($index)");
    await player.seek(Duration.zero, index: index);
  }

  Future<void> setLoopMode(LoopMode mode) async {
    await player.setLoopMode(mode);
  }

  Future<void> setShuffleModeEnabled(bool enable) async {
    await player.setShuffleModeEnabled(enable);
  }

  // Playing queue
  RxList<MediaItem> queue = RxList.empty(growable: true);
  Rxn<int> playingIndex = Rxn();
  Rxn<MediaItem> currentPlaying = Rxn();

  Future<void> setPlayingQueue(List<IndexedAudioSource> songs,
      {int? initialIndex}) async {
    await pause();

    playingIndex.value = initialIndex ?? 0;
    queue.replaceRange(0, queue.length, songs.map((e) => e.tag as MediaItem));
    queue.refresh();

    debugPrint("[PlayingController] setAudioSource");
    final playQueue = ConcatenatingAudioSource(children: songs);
    await player.setAudioSource(playQueue, initialIndex: initialIndex);
    await play();
  }

  Duration getDuration(String id) {
    return this.durationMap[id] ?? this.duration.value ?? Duration.zero;
  }

  Future<void> fullShuffleMode({int count = 30}) async {
    AnnilController annil = Get.find();
    final albums = annil.albums.toList();
    final rand = Random();

    final songs = <IndexedAudioSource>[];
    for (int i = 0; i < count; i++) {
      final albumId = albums[rand.nextInt(albums.length)];
      final metadata =
          (await Global.metadataSource!.getAlbum(albumId: albumId))!;
      // random disc in metadata
      final discIndex = rand.nextInt(metadata.discs.length);
      final disc = metadata.discs[discIndex];
      // random track
      final trackIndex = rand.nextInt(disc.tracks.length);
      final track = disc.tracks[trackIndex];

      if (track.type == TrackType.Normal) {
        songs.add(await annil.getAudio(
          albumId: albumId,
          discId: discIndex + 1,
          trackId: trackIndex + 1,
        ));
      }
    }

    await this.setLoopMode(LoopMode.off);
    await this.setShuffleModeEnabled(false);
    await this.setPlayingQueue(songs);
  }
}
