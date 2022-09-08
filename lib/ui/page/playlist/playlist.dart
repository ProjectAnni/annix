import 'package:annix/services/annil/audio_source.dart';
import 'package:annix/services/player.dart';
import 'package:annix/global.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

typedef TrackListCallback = Future<List<AnnilAudioSource>> Function();

class PlaylistScreen extends StatelessWidget {
  /// Page title
  final Widget? pageTitle;

  /// Page actions
  final List<Widget>? pageActions;

  /// Cover image of the playlist.
  final Widget cover;

  /// Playlist name, will be displayed in intro part
  final String title;

  /// Additional widgets after title of intro part
  final List<Widget> intro;

  /// Widget to show track list
  final Widget child;

  /// Tracks to play
  final TrackListCallback onTracks;

  /// Refresh callback
  final RefreshCallback? refresh;

  const PlaylistScreen({
    super.key,
    this.pageTitle,
    this.pageActions,
    required this.cover,
    required this.title,
    required this.intro,
    required this.child,
    required this.onTracks,
    this.refresh,
  });

  Widget _albumIntro(BuildContext context) {
    return Container(
      height: 144,
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // cover
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FractionallySizedBox(
              heightFactor: 1,
              child: cover,
            ),
          ),
          // intro text
          Flexible(
            child: Container(
              padding: const EdgeInsets.only(right: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.titleMedium,
                  ),
                  ...intro,
                  ButtonBar(
                    alignment: MainAxisAlignment.start,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.play_arrow),
                        label: const Text("Play"),
                        onPressed: () async {
                          final player = context.read<PlayerService>();
                          final tracks = await onTracks();
                          playFullList(
                            player: player,
                            tracks: tracks,
                            shuffle: false,
                          );
                        },
                      ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.shuffle),
                        label: const Text("Shuffle"),
                        onPressed: () async {
                          final player = context.read<PlayerService>();
                          final tracks = await onTracks();
                          playFullList(
                            player: player,
                            tracks: tracks,
                            shuffle: true,
                          );
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget result = Column(
      children: [
        _albumIntro(context),
        Expanded(child: child),
      ],
    );

    final actions = pageActions ?? [];
    if (refresh != null) {
      if (Global.isDesktop) {
        // sync button on desktop
        actions.add(
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: refresh,
          ),
        );
      } else {
        // refresh indicator on mobile
        result = RefreshIndicator(
          onRefresh: refresh!,
          child: result,
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: pageTitle,
        scrolledUnderElevation: 0,
        actions: actions,
      ),
      body: result,
    );
  }
}

void playFullList({
  required PlayerService player,
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
