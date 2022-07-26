// Edited from marquee_widget

/*
Copyright (c) 2018 Marcel Garus

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import 'package:flutter/widgets.dart';

enum DirectionMarguee { oneDirection, TwoDirection }

class Marquee extends StatelessWidget {
  final Widget child;
  final Axis direction;
  final Duration pauseDuration;
  final DirectionMarguee directionMarguee;
  final Curve forwardAnimation;
  final Curve backwardAnimation;
  final bool autoRepeat;
  final bool autoSize;
  final double? width;
  Marquee(
      {required this.child,
      this.direction = Axis.horizontal,
      this.pauseDuration = const Duration(milliseconds: 2000),
      this.directionMarguee = DirectionMarguee.oneDirection,
      this.forwardAnimation = Curves.linear,
      this.backwardAnimation = Curves.linear,
      this.autoRepeat = true,
      this.autoSize = false,
      this.width});

  final ScrollController _scrollController = ScrollController();

  scroll(bool repeated) async {
    do {
      if (_scrollController.hasClients) {
        await Future.delayed(pauseDuration);
        if (_scrollController.hasClients &&
            _scrollController.position.maxScrollExtent > 0) {
          await _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(
              milliseconds:
                  (_scrollController.position.maxScrollExtent * 20).toInt(),
            ),
            curve: forwardAnimation,
          );
        }
        await Future.delayed(pauseDuration);
        if (_scrollController.hasClients)
          switch (directionMarguee) {
            case DirectionMarguee.oneDirection:
              _scrollController.jumpTo(0.0);
              break;
            case DirectionMarguee.TwoDirection:
              await _scrollController.animateTo(
                0.0,
                duration: Duration(
                  milliseconds:
                      _scrollController.position.maxScrollExtent.toInt() * 20,
                ),
                curve: backwardAnimation,
              );
              break;
          }
        repeated = autoRepeat;
      } else {
        await Future.delayed(pauseDuration);
      }
    } while (repeated);
  }

  @override
  Widget build(BuildContext context) {
    bool _repeated = true;
    scroll(_repeated);
    var inner = ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SingleChildScrollView(
        child: child,
        scrollDirection: direction,
        controller: _scrollController,
      ),
    );
    if (!autoSize) {
      return Container(
        width: width,
        child: inner,
      );
    } else {
      return LayoutBuilder(
        builder: (context, constraints) => Container(
          width: constraints.maxWidth,
          child: inner,
        ),
      );
    }
  }
}
