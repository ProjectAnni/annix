import 'package:f_logs/f_logs.dart';
import 'package:get/get.dart';

class InitializeController extends GetxController {
  Rx<bool> done = false.obs;

  InitializeController(List<Future> futures) {
    (() async {
      try {
        await Future.wait(futures);
      } catch (e) {
        FLog.error(
          className: "InitializeController",
          methodName: "constructor",
          text: "initialization error",
          exception: e,
          stacktrace: e is Error ? e.stackTrace : null,
        );
      } finally {
        done.value = true;
      }
    })();
  }
}
