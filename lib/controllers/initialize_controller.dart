import 'package:get/get.dart';

class InitializeController extends GetxController {
  Rx<bool> done = false.obs;

  InitializeController(List<Future> futures) {
    Future.wait(futures).then((value) => done.value = true);
  }
}
