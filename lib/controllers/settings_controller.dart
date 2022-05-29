import 'package:annix/services/global.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
  /// Download audio files using mobile network
  ///
  /// Default: true
  late RxBool useMobileNetwork;

  /// Show shuffle button as FAB instead of play button
  ///
  /// Default value: false
  late RxBool shufflePlayButton;

  @override
  void onInit() {
    super.onInit();
    // TODO: persist settings
    useMobileNetwork =
        (Global.preferences.getBool("annix_use_mobile_network") ?? true).obs;
    shufflePlayButton =
        (Global.preferences.getBool("annix_shuffle_play_button") ?? false).obs;
  }
}
