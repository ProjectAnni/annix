import 'package:we_slide/we_slide.dart';

class AnniWeSlideController extends WeSlideController {
  final bool initial;

  AnniWeSlideController({required this.initial}) : super(initial: initial);

  @override
  // ignore: must_call_super
  void dispose() {
    if (value != initial) {
      value = initial;
    }
  }
}
