import 'package:annix/widgets/keepalive.dart';
import 'package:annix/pages/playing/playing_control.dart';
import 'package:annix/pages/playing/playing_lyric.dart';
import 'package:annix/pages/playing/playing_queue.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class PlayingMobileScreen extends StatelessWidget {
  PlayingMobileScreen({Key? key}) : super(key: key);

  final PageController controller = PageController(initialPage: 1);
  final pages = [
    KeepAlivePage(child: PlayingLyric()),
    PlayingControl(),
    PlayingQueue()
  ];

  @override
  Widget build(BuildContext context) {
    final inner = Scaffold(
      appBar: AppBar(
        leadingWidth: 0,
        leading: Container(),
        toolbarHeight: 28.0,
        centerTitle: true,
        title: SmoothPageIndicator(
          controller: controller,
          count: 3,
          effect: WormEffect(
            dotWidth: 12,
            dotHeight: 12,
            activeDotColor: context.colorScheme.primary,
          ),
        ),
      ),
      body: PageView.builder(
        controller: controller,
        itemCount: 3,
        itemBuilder: (context, index) {
          return pages[index];
        },
      ),
    );

    return GestureDetector(
      onVerticalDragEnd: (details) {
        if ((details.primaryVelocity ?? 0) > 300) {
          Get.back();
        }
      },
      child: inner,
    );
  }
}
