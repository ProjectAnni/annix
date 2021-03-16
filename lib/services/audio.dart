import 'package:annix/services/platform.dart';
import 'package:audio_service/audio_service.dart';

class AnniAudioPlayer {
  AnniAudioPlayer() {
    if (AnniPlatform.isSupportedDesktop) {
      //
    } else if (AnniPlatform.isSupportedMobile || AnniPlatform.isWeb) {
      //
    }
  }

  prepare() async {
    if (AnniPlatform.isSupportedDesktop) {
      //
    } else if (AnniPlatform.isSupportedMobile || AnniPlatform.isWeb) {
      //
    }
  }

  play() {
    if (AnniPlatform.isSupportedDesktop) {
      //
    } else if (AnniPlatform.isSupportedMobile || AnniPlatform.isWeb) {
      AudioService.play();
    }
  }
}
