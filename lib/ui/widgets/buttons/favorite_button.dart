import 'package:annix/controllers/anniv_controller.dart';
import 'package:annix/services/annil/audio_source.dart';
import 'package:annix/services/global.dart';
import 'package:annix/services/player.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class FavoriteButton extends StatelessWidget {
  final _anniv = Provider.of<AnnivController>(Global.context, listen: false);

  final Rxn<AnnilAudioSource> audio = Rxn();
  final RxBool favorited = false.obs;

  FavoriteButton({super.key, AnnilAudioSource? audio}) {
    final player = Provider.of<PlayerService>(Global.context, listen: false);
    if (audio == null) {
      this.audio.value = player.playing;
    }
    player.addListener(() {
      this.audio.value = player.playing;
    });

    // listen favorite map updates
    favorited.bindStream(_anniv.favorites.stream
        .map((favorites) => favorites.containsKey(this.audio.value?.id)));
    this.audio.listen((audio) {
      favorited.value = _anniv.favorites.containsKey(audio?.id);
    });
    // initialize current status
    favorited.value = _anniv.favorites.containsKey(this.audio.value?.id);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => IconButton(
        isSelected: favorited.value,
        icon: const Icon(Icons.favorite_border_outlined),
        selectedIcon: const Icon(Icons.favorite_outlined),
        onPressed: () async {
          final id = audio.value?.identifier;
          if (id != null) {
            _anniv.toggleFavorite(id);
          }
        },
      ),
    );
  }
}
