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

  /// Whether to skip certification check
  ///
  /// Default value: false
  late RxBool skipCertificateVerification;

  @override
  void onInit() {
    super.onInit();

    useMobileNetwork =
        (Global.preferences.getBool("annix_use_mobile_network") ?? true).obs;
    useMobileNetwork.listen(saveChangedVariable("annix_use_mobile_network"));

    shufflePlayButton =
        (Global.preferences.getBool("annix_shuffle_play_button") ?? false).obs;
    shufflePlayButton.listen(saveChangedVariable("annix_shuffle_play_button"));

    skipCertificateVerification =
        (Global.preferences.getBool("annix_skip_certificate_verification") ??
                false)
            .obs;
    skipCertificateVerification
        .listen(saveChangedVariable("annix_skip_certificate_verification"));
  }

  void Function(T) saveChangedVariable<T>(String key) {
    return (value) {
      if (value is String) {
        Global.preferences.setString(key, value);
      } else if (value is bool) {
        Global.preferences.setBool(key, value);
      } else if (value is int) {
        Global.preferences.setInt(key, value);
      } else if (value is double) {
        Global.preferences.setDouble(key, value);
      } else {
        throw Exception("Unsupported type");
      }
    };
  }
}
