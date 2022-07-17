import 'package:annix/controllers/anniv_controller.dart';
import 'package:annix/controllers/player_controller.dart';
import 'package:annix/services/annil.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavoriteButton extends StatelessWidget {
  final AnnivController anniv = Get.find();
  final PlayerController player = Get.find();

  final Rxn<AnnilAudioSource> audio;
  final RxBool favorited = false.obs;

  FavoriteButton([AnnilAudioSource? audio]) : audio = Rxn(audio) {
    player.addListener(() {
      this.audio.value = player.playing;
    });

    // listen favorite map updates
    favorited.bindStream(anniv.favorites.stream
        .map((favorites) => favorites.containsKey(this.audio.value?.id)));
    this.audio.listen((audio) {
      favorited.value = anniv.favorites.containsKey(audio?.id);
    });
    // initialize current status
    favorited.value = anniv.favorites.containsKey(this.audio.value?.id);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => IconButton(
        isSelected: favorited.value,
        icon: Icon(Icons.favorite_border_outlined),
        selectedIcon: Icon(Icons.favorite_outlined),
        onPressed: () async {
          final id = this.audio.value?.identifier;
          if (id != null) {
            this.anniv.toggleFavorite(id);
          }
        },
      ),
    );
  }
}
