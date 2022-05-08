import 'package:annix/pages/playing/control.dart';
import 'package:annix/pages/playing/queue.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class PlayingScreen extends StatelessWidget {
  PlayingScreen({Key? key}) : super(key: key);

  final PageController controller = PageController(initialPage: 1);

  @override
  Widget build(BuildContext context) {
    final inner = DefaultTabController(
      length: 3,
      initialIndex: 1,
      child: Scaffold(
        appBar: AppBar(
          leadingWidth: 0,
          leading: Container(),
          centerTitle: true,
          title: SmoothPageIndicator(
            controller: controller,
            count: 3,
            effect: WormEffect(
              dotWidth: 12,
              dotHeight: 12,
              activeDotColor: context.theme.colorScheme.primary,
            ),
          ),
        ),
        body: PageView.builder(
          controller: controller,
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return Text("Lyric");
              case 1:
                return PlayingControl();
              case 2:
                return PlayingQueue();
              default:
                return Container();
            }
          },
        ),
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
