import 'dart:async';
import 'dart:io';

import 'package:annix/providers.dart';
import 'package:annix/services/anniv/anniv.dart';
import 'package:annix/services/logger.dart';
import 'package:annix/services/playback/playback.dart';
import 'package:annix/services/local/database.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_service_platform_interface/audio_service_platform_interface.dart';
import 'package:audio_session/audio_session.dart';
import 'package:anni_mpris_service/anni_mpris_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AnnixAudioHandler extends BaseAudioHandler {
  final Ref ref;

  final PlaybackService player;

  final AnnivService anniv;
  final LocalDatabase database;

  static Future<void> init(final Ref ref) async {
    if (Platform.isLinux) {
      AudioServicePlatform.instance = LinuxAudioService(ref);
    }

    final service = await AudioService.init(
      builder: () => AnnixAudioHandler._(ref),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'rs.anni.annix.audio',
        androidNotificationChannelName: 'Annix Audio playback',
        androidNotificationIcon: 'drawable/ic_notification',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
        artDownscaleHeight: 300,
        artDownscaleWidth: 300,
        preloadArtwork: true,
      ),
    );

    unawaited(AudioSession.instance.then((final session) async {
      await session.configure(const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionMode: AVAudioSessionMode.moviePlayback,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.music,
          usage: AndroidAudioUsage.media,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      ));

      // unplugged
      session.becomingNoisyEventStream.listen((final _) => service.pause());

      bool interrupted = false;
      // interruption
      session.interruptionEventStream.listen((final event) {
        if (event.begin) {
          Logger.info('handling interruption beginning ${event.type}');
          switch (event.type) {
            case AudioInterruptionType.duck:
              // TODO
              break;
            case AudioInterruptionType.pause:
            case AudioInterruptionType.unknown:
              if (service.player.playerStatus == PlayerStatus.playing) {
                interrupted = true;
                service.pause();
              }
              break;
          }
        } else {
          Logger.info('handling interruption end ${event.type}');
          switch (event.type) {
            case AudioInterruptionType.duck:
              // TODO
              break;
            case AudioInterruptionType.pause:
              if (interrupted) {
                interrupted = false;
                service.play();
              }
            // We should not resume unknown interruptions
            case AudioInterruptionType.unknown:
              break;
          }
        }
      });
    }));

    AudioService.notificationClicked.listen((final clicked) {
      if (clicked) {
        ref.read(routerProvider).openPanel();
      }
    });
  }

  AnnixAudioHandler._(this.ref)
      : player = ref.read(playbackProvider),
        anniv = ref.read(annivProvider),
        database = ref.read(localDatabaseProvider) {
    player.addListener(() => _updatePlaybackState());
    player.playing.addListener(() => _updatePlaybackState());
  }

  @override
  Future<void> play() async {
    return player.play();
  }

  @override
  Future<void> pause() {
    return player.pause();
  }

  @override
  Future<void> stop() {
    return player.stop();
  }

  @override
  Future<void> seek(final Duration position) {
    return player.seek(position);
  }

  @override
  Future<void> skipToNext() {
    return player.next();
  }

  @override
  Future<void> skipToPrevious() {
    return player.previous();
  }

  void _updatePlaybackState() {
    final isPlaying = player.playerStatus == PlayerStatus.playing;

    final controls = [
      MediaControl.skipToPrevious,
      if (isPlaying) MediaControl.pause else MediaControl.play,
      MediaControl.skipToNext,
      MediaControl.stop,
    ];

    final playState = PlaybackState(
      controls: controls,
      systemActions: {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices:
          List.generate(controls.length, (final i) => i)
              .where((final i) =>
                  controls[i].action == MediaAction.fastForward ||
                  controls[i].action == MediaAction.pause ||
                  controls[i].action == MediaAction.play ||
                  controls[i].action == MediaAction.skipToNext)
              .toList(),
      processingState: {
        PlayerStatus.playing: AudioProcessingState.ready,
        PlayerStatus.stopped: AudioProcessingState.ready,
        PlayerStatus.paused: AudioProcessingState.ready,
        PlayerStatus.buffering: AudioProcessingState.buffering,
      }[player.playerStatus]!,
      playing: isPlaying,
      updatePosition: player.playing.position,
    );
    if (playbackState.value != playState) {
      try {
        playbackState.add(playState);
      } catch (e) {
        Logger.error(
          'Failed to update playback state',
          className: 'AnnixAudioHandler',
          methodName: '_updatePlaybackState',
          exception: e,
        );
      }
    }

    final source = player.playing.source;
    if (source != null &&
        (mediaItem.value?.id != source.id ||
            mediaItem.value?.duration != player.playing.duration)) {
      final proxy = ref.read(proxyProvider);
      mediaItem.add(MediaItem(
        id: source.id,
        title: source.track.title,
        album: source.track.albumTitle,
        artist: source.track.artist,
        duration: player.playing.duration,
        artUri: proxy.coverUri(
          source.identifier.albumId,
          source.identifier.discId,
        ),
      ));
    }
  }
}

class LinuxAudioService extends AudioServicePlatform {
  final AnnixMPRISService mpris;
  bool seekOnNextUpdate = false;

  LinuxAudioService(final Ref ref) : mpris = AnnixMPRISService(ref);

  @override
  Future<void> configure(final ConfigureRequest request) async {}

  @override
  Future<void> setState(final SetStateRequest request) async {
    mpris.playbackStatus =
        request.state.playing ? PlaybackStatus.playing : PlaybackStatus.stopped;
    mpris.updatePosition(request.state.updatePosition,
        forceEmitSeeked: seekOnNextUpdate);
    seekOnNextUpdate = false;
  }

  @override
  Future<void> setMediaItem(final SetMediaItemRequest request) async {
    final duration = request.mediaItem.duration;
    if (duration != null && duration > Duration.zero) {
      final trackId = "/${request.mediaItem.id.replaceAll('-', '')}";
      // if duration has changed on one track, clients may set current position to zero
      // so we need to `seek` to the correct position at next update
      seekOnNextUpdate = mpris.metadata.trackId == trackId &&
          mpris.metadata.trackLength != duration;

      mpris.metadata = Metadata(
        trackId: trackId,
        trackTitle: request.mediaItem.title,
        trackArtist: [request.mediaItem.artist!],
        artUrl: request.mediaItem.artUri.toString(),
        trackLength: duration,
        albumName: request.mediaItem.album!,
      );
    }
  }

  @override
  Future<void> stopService(final StopServiceRequest request) async {}

  @override
  void setHandlerCallbacks(final AudioHandlerCallbacks callbacks) {}

  @override
  Future<void> setQueue(final SetQueueRequest request) async {}
}

class AnnixMPRISService extends MPRISService {
  final PlaybackService player;

  AnnixMPRISService(final Ref ref)
      : player = ref.read(playbackProvider),
        super(
          'annix',
          identity: 'Annix',
          emitSeekedSignal: false,
          canPlay: true,
          canPause: true,
          canGoPrevious: true,
          canGoNext: true,
          canSeek: true,
          supportLoopStatus: true,
          supportShuffle: true,
        ) {
    player.addListener(() {
      switch (player.loopMode) {
        case LoopMode.off:
          loopStatus = LoopStatus.none;
          break;
        case LoopMode.all:
          loopStatus = LoopStatus.playlist;
          break;
        case LoopMode.one:
          loopStatus = LoopStatus.track;
          break;
      }
      switch (player.shuffleMode) {
        case ShuffleMode.off:
          shuffle = false;
          break;
        case ShuffleMode.on:
          shuffle = true;
          break;
      }
    });
  }

  @override
  Future<void> onPlayPause() async {
    await player.playOrPause();
  }

  @override
  Future<void> onPlay() async {
    await player.play();
  }

  @override
  Future<void> onPause() async {
    await player.pause();
  }

  @override
  Future<void> onPrevious() async {
    await player.previous();
  }

  @override
  Future<void> onNext() async {
    await player.next();
  }

  @override
  Future<void> onSeek(final int offset) async {
    if (player.playing.source != null) {
      await player
          .seek(player.playing.position + Duration(milliseconds: offset));
    }
  }

  @override
  Future<void> onSetPosition(final String trackId, final int position) async {
    await player.seek(Duration(microseconds: position));
  }

  @override
  Future<void> onLoopStatus(final LoopStatus loopStatus) async {
    switch (loopStatus) {
      case LoopStatus.none:
        await player.setLoopMode(LoopMode.off);
        break;
      case LoopStatus.track:
        await player.setLoopMode(LoopMode.one);
        break;
      case LoopStatus.playlist:
        await player.setLoopMode(LoopMode.all);
        break;
    }
    this.loopStatus = loopStatus;
  }

  @override
  Future<void> onShuffle(final bool shuffle) async {
    if (shuffle) {
      await player.setShuffleMode(ShuffleMode.on);
    } else {
      await player.setShuffleMode(ShuffleMode.off);
    }
    this.shuffle = shuffle;
  }
}
