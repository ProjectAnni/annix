import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class PlaylistScreen extends StatelessWidget {
  /// Additional widgets after title of intro part
  final List<Widget>? intro;

  /// Page title
  final Widget? pageTitle;

  /// Page actions
  final List<Widget>? pageActions;

  /// Page FAB
  final Widget? pageFloatingActionButton;

  /// Cover image of the playlist.
  Widget get cover;

  /// Playlist name, will be displayed in intro part
  String get title;

  /// Widget to show track list
  Widget get body;

  const PlaylistScreen({
    Key? key,
    this.intro,
    this.pageTitle,
    this.pageActions,
    this.pageFloatingActionButton,
  }) : super(key: key);

  Widget _albumIntro(BuildContext context) {
    return Container(
      height: 150,
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                  ...(intro ?? []),
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
      floatingActionButton: pageFloatingActionButton,
    );
  }
}
