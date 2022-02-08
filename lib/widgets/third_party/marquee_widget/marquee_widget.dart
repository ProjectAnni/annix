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
  final Duration animationDuration, backDuration, pauseDuration;
  final DirectionMarguee directionMarguee;
  final Cubic forwardAnimation;
  final Cubic backwardAnimation;
  final bool autoRepeat;
  Marquee(
      {required this.child,
      this.direction = Axis.horizontal,
      this.animationDuration = const Duration(milliseconds: 5000),
      this.backDuration = const Duration(milliseconds: 5000),
      this.pauseDuration = const Duration(milliseconds: 2000),
      this.directionMarguee = DirectionMarguee.TwoDirection,
      this.forwardAnimation = Curves.easeIn,
      this.backwardAnimation = Curves.easeOut,
      this.autoRepeat = true});

  final ScrollController _scrollController = ScrollController();

  scroll(bool repeated) async {
    do {
      if (_scrollController.hasClients) {
        await Future.delayed(pauseDuration);
        if (_scrollController.hasClients)
          await _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: animationDuration,
            curve: forwardAnimation,
          );
        await Future.delayed(pauseDuration);
        if (_scrollController.hasClients)
          switch (directionMarguee) {
            case DirectionMarguee.oneDirection:
              _scrollController.jumpTo(0.0);
              break;
            case DirectionMarguee.TwoDirection:
              await _scrollController.animateTo(
                0.0,
                duration: backDuration,
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
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SingleChildScrollView(
        child: child,
        scrollDirection: direction,
        controller: _scrollController,
      ),
    );
  }
}