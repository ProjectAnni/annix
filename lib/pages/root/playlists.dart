import 'package:annix/pages/root/base.dart';
import 'package:flutter/material.dart';

class PlaylistsView extends StatelessWidget {
  const PlaylistsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return <Widget>[
          BaseSliverAppBar(title: Text("Playlists")),
        ];
      },
      body: Container(),
    );
  }
}
