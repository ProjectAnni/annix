import 'package:annix/controllers/player_controller.dart';
import 'package:annix/models/anniv.dart';
import 'package:annix/services/annil.dart';
import 'package:annix/services/global.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

  Widget _albumIntro(BuildContext context) {
    return Container(
      height: 180,
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // cover
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: FractionallySizedBox(
              heightFactor: 1,
              child: cover,
            ),
          ),
          // intro text
          Flexible(
            child: Container(
              padding: EdgeInsets.only(right: 16),
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
                        icon: Icon(Icons.play_arrow),
                        label: Text("Play All"),
                        onPressed: () {
                          playFullList(shuffle: false);
                        },
                      ),
                      OutlinedButton.icon(
                        icon: Icon(Icons.shuffle),
                        label: Text("Shuffle"),
                        onPressed: () {
                          playFullList(shuffle: true);
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
    if (this.refresh != null) {
      if (Global.isDesktop) {
        // sync button on desktop
        actions.add(
          IconButton(
            icon: Icon(Icons.sync),
            onPressed: this.refresh,
          ),
        );
      } else {
        // refresh indicator on mobile
        child = RefreshIndicator(
          onRefresh: this.refresh!,
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

  void playFullList({bool shuffle = false, int initialIndex = 0}) async {
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

    final PlayerController playing = Get.find();
    await playing.setPlayingQueue(
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
