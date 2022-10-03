import 'package:annix/services/annil/audio_source.dart';

abstract class Playlist {
  List<AnnilAudioSource> getTracks();
}
