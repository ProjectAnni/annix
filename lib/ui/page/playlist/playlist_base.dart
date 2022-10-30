import 'package:annix/global.dart';
import 'package:annix/services/annil/audio_source.dart';
import 'package:annix/services/playback/playback.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';

typedef PlaybackCallback = void Function(bool shuffle);

class BasePlaylistScreen extends StatelessWidget {
  /// Page title
  final Widget? pageTitle;

  /// Page actions
  final List<Widget> actions;

  /// Cover image of the playlist.
  final Widget cover;

  /// Playlist name, will be displayed in intro part
  final String title;

  /// Additional widgets after title of intro part
  final List<Widget> intro;

  /// Widget to show track list
  final Widget child;

  /// Playback callback
  final PlaybackCallback? onPlay;

  /// Refresh callback
  final RefreshCallback? onRefresh;

  /// Download callback
  final VoidCallback? onDownload;

  const BasePlaylistScreen({
    super.key,
    this.pageTitle,
    this.actions = const [],
    required this.cover,
    required this.title,
    required this.intro,
    required this.child,
    this.onPlay,
    this.onRefresh,
    this.onDownload,
  });

  Widget _albumIntro(BuildContext context) {
    return Container(
      height: Global.isDesktop ? 240 : 160, // 240, 200, 160
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // cover
          Container(
            padding: const EdgeInsets.only(left: 16, right: 32),
            child: FractionallySizedBox(
              heightFactor: 1,
              child: cover,
            ),
          ),
          // intro text
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.titleMedium
                        ?.apply(fontSizeDelta: 2.0),
                  ),
                ),
                ...intro,
                if (context.isDesktopOrLandscape) _playButtons(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _playButtons(BuildContext context) {
    return ButtonBar(
      alignment: MainAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          icon: const Icon(Icons.play_arrow),
          label: const Text('Play'),
          onPressed: onPlay == null ? null : () => onPlay!(false),
        ),
        TextButton.icon(
          icon: const Icon(Icons.shuffle),
          label: const Text('Shuffle'),
          onPressed: onPlay == null ? null : () => onPlay!(true),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget result = Column(
      children: [
        _albumIntro(context),
        if (!context.isDesktopOrLandscape) _playButtons(context),
        Expanded(child: child),
      ],
    );

    final pageActions = actions +
        [
          if (onDownload != null)
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: onDownload,
            ),
        ];
    if (onRefresh != null) {
      if (context.isDesktopOrLandscape) {
        // sync button on desktop
        pageActions.add(
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: onRefresh,
          ),
        );
      } else {
        // refresh indicator on mobile
        result = RefreshIndicator(
          onRefresh: onRefresh!,
          child: result,
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: pageTitle,
        scrolledUnderElevation: 0,
        actions: pageActions,
      ),
      body: result,
    );
  }
}

void playFullList({
  required PlaybackService player,
  required List<AnnilAudioSource> tracks,
  bool shuffle = false,
  int initialIndex = 0,
}) async {
  assert(
  // when shuffle is on, initialIndex can only be zero
  (shuffle && initialIndex == 0) ||
      // or disable shuffle
      !shuffle,
  );

  final trackList = tracks;
  if (shuffle) {
    trackList.shuffle();
  }

  await player.setPlayingQueue(
    trackList,
    initialIndex: initialIndex,
  );
}
