import 'package:annix/controllers/player_controller.dart';
import 'package:annix/controllers/settings_controller.dart';
import 'package:annix/models/anniv.dart';
import 'package:annix/services/annil.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class PlaylistScreen extends StatelessWidget {
  /// Page title
  final Widget? pageTitle;

  /// Page actions
  final List<Widget>? pageActions;

  /// Cover image of the playlist.
  Widget get cover;

  /// Playlist name, will be displayed in intro part
  String get title;

  /// Additional widgets after title of intro part
  List<Widget> get intro => [];

  /// Widget to show track list
  Widget get body;

  /// Tracks to play
  List<TrackIdentifier> get tracks;

  const PlaylistScreen({
    Key? key,
    this.pageTitle,
    this.pageActions,
  }) : super(key: key);

  Widget _albumIntro(BuildContext context) {
    return Container(
      height: 150,
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // cover
          Container(
            height: 150,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              elevation: 8,
              child: AspectRatio(
                aspectRatio: 1,
                child: cover,
              ),
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
                  AutoSizeText(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.titleMedium,
                    textScaleFactor: 1.2,
                    minFontSize: context.textTheme.titleSmall!.fontSize!,
                  ),
                  ...intro,
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
    final SettingsController settings = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: pageTitle,
        actions: pageActions,
      ),
      body: Column(
        children: [
          _albumIntro(context),
          Expanded(child: body),
        ],
      ),
      floatingActionButton: GestureDetector(
        onLongPress: () {
          settings.shufflePlayButton.value = !settings.shufflePlayButton.value;
        },
        child: Obx(() {
          return FloatingActionButton(
            child: Icon(
              settings.shufflePlayButton.value
                  ? Icons.shuffle
                  : Icons.play_arrow,
            ),
            onPressed: () => _playFullList(settings.shufflePlayButton.value),
          );
        }),
      ),
    );
  }

  void _playFullList(bool shuffle) async {
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
    );
  }
}
