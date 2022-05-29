import 'package:annix/i18n/i18n.dart';
import 'package:annix/pages/root/base.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlaylistsView extends StatelessWidget {
  const PlaylistsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return <Widget>[
          BaseSliverAppBar(title: Text(I18n.PLAYLISTS.tr)),
        ];
      },
      body: Container(),
    );
  }
}
