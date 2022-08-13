import 'package:annix/services/annil/audio_source.dart';
import 'package:annix/services/player.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/global.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

abstract class PlaylistScreen extends StatelessWidget {
  /// Page title
  abstract final Widget? pageTitle;

  /// Page actions
  abstract final List<Widget>? pageActions;

  /// Cover image of the playlist.
  abstract final Widget cover;

  /// Playlist name, will be displayed in intro part
  abstract final String title;

  /// Additional widgets after title of intro part
  abstract final List<Widget> intro;

  /// Widget to show track list
  abstract final Widget body;

  /// Tracks to play
  abstract final List<TrackIdentifier> tracks;

  /// Refresh callback
  abstract final RefreshCallback? refresh;

  const PlaylistScreen({super.key});

  Widget _albumIntro(BuildContext context) {
    return Container(
      height: 180,
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.titleMedium,
                    textScaleFactor: 1.2,
                  ),
                  ...intro,
                  ButtonBar(
                    alignment: MainAxisAlignment.start,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.play_arrow),
                        label: const Text("Play All"),
                        onPressed: () {
                          playFullList(context, shuffle: false);
                        },
                      ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.shuffle),
                        label: const Text("Shuffle"),
                        onPressed: () {
                          playFullList(context, shuffle: true);
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
    final actions = pageActions ?? [];
    var child = body;
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
        child = RefreshIndicator(
          onRefresh: refresh!,
          child: child,
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: pageTitle,
        scrolledUnderElevation: 0,
        actions: actions,
      ),
      body: Column(
        children: [
          _albumIntro(context),
          Expanded(child: child),
        ],
      ),
    );
  }

  void playFullList(BuildContext context,
      {bool shuffle = false, int initialIndex = 0}) async {
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

    await Provider.of<PlayerService>(context, listen: false).setPlayingQueue(
      await Future.wait<AnnilAudioSource>(trackList.map(
        (s) => AnnilAudioSource.from(
          albumId: s.albumId,
          discId: s.discId,
          trackId: s.trackId,
        ),
      )),
      initialIndex: initialIndex,
    );
  }
}
