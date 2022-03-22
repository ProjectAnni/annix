import 'package:annix/controllers/playing_controller.dart';
import 'package:annix/services/audio.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class PlaylistController extends GetxController {
  var playingController = Get.find<PlayingController>();

  final AnniAudioService _service;

  List<AudioSource> get playlist => _service.playlist;

  PlaylistController({required AnniAudioService service}) : _service = service {
    _service.playlistChangeNotifier.addListener(() {
      playingController.updateTrack(_service.activeAudioSource?.toTrack());
    });
  }

  Future<void> goto(AudioSource audio) async {
    var index = playlist.indexOf(audio);
    if (index != -1) {
      await _service.goto(index);
    }
  }
}
