import 'package:annic/services/platform.dart';
import 'package:audio_service/audio_service.dart';

class AnniAudioPlayer {
  AnniAudioPlayer() {
    if (AnniPlatform.isDesktop) {
      //
    } else if (AnniPlatform.isMobile || AnniPlatform.isWeb) {
      //
    }
  }

  prepare() async {
    if (AnniPlatform.isDesktop) {
      //
    } else if (AnniPlatform.isMobile || AnniPlatform.isWeb) {
      //
    }
  }

  play() {
    if (AnniPlatform.isDesktop) {
      //
    } else if (AnniPlatform.isMobile || AnniPlatform.isWeb) {
      AudioService.play();
    }
  }
}
