import 'dart:math';

import 'package:annix/controllers/annil_controller.dart';
import 'package:annix/controllers/anniv_controller.dart';
import 'package:annix/models/metadata.dart';
import 'package:annix/services/global.dart';
import 'package:audio_service/audio_service.dart';
import 'package:f_logs/f_logs.dart';
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

  final AnnivController anniv = Get.find();

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
        final now = this.queue[this.playingIndex.value!];
        currentPlaying.value = now;
        favorited.value = this.anniv.favorites.containsKey(now.id);
      }
    });
    this.playingIndex.listen((index) {
      if (index == null || index >= this.queue.length) {
        currentPlaying.value = null;
      } else {
        final now = this.queue[index];
        currentPlaying.value = now;
        favorited.value = this.anniv.favorites.containsKey(now.id);
      }
    });
    this.anniv.favorites.listen((favoriteMap) {
      final currentId = queue[this.playingIndex.value!].id;
      favorited.value = favoriteMap.containsKey(currentId);
    });

    super.onInit();
  }

  Rx<bool> isPlaying = false.obs;
  Rx<LoopMode> loopMode = LoopMode.off.obs;
  Rx<bool> shuffleEnabled = false.obs;

  Rx<Duration> progress = Duration.zero.obs;
  Rx<Duration> buffered = Duration.zero.obs;
  Rxn<Duration> duration = Rxn();
  RxBool favorited = false.obs;

  RxMap<String, Duration> durationMap = RxMap();

  Future<void> play() async {
    FLog.debug(
      className: "PlayingController",
      methodName: "play",
      text: "start playing",
    );
    await player.play();
  }

  Future<void> pause() async {
    FLog.debug(
      className: "PlayingController",
      methodName: "pause",
      text: "pause playing",
    );
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
    FLog.debug(
      className: "PlayingController",
      methodName: "jump",
      text: "jump to $index in playing queue",
    );
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

  Future<void> toggleFavorite() async {
    if (this.favorited.value) {
      await this.anniv.removeFavorite(this.currentPlaying.value!.id);
    } else {
      await this.anniv.addFavorite(this.currentPlaying.value!.id);
    }
    this.favorited.value = !this.favorited.value;
  }
}
