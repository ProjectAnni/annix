import 'package:annix/services/global.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
  late RxBool useMobileNetwork;

  @override
  void onInit() {
    super.onInit();
    useMobileNetwork =
        (Global.preferences.getBool("annix_use_mobile_network") ?? true).obs;
  }
}
