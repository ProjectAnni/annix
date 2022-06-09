import 'package:annix/pages/playing/playing_desktop.dart';
import 'package:annix/pages/playing/playing_mobile.dart';
import 'package:annix/services/global.dart';
import 'package:flutter/cupertino.dart';

class PlayingScreen extends StatelessWidget {
  const PlayingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Global.isDesktop) {
      return PlayingDesktopScreen();
    } else {
      return PlayingMobileScreen();
    }
  }
}
