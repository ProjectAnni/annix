import 'package:annix/controllers/anniv_controller.dart';
import 'package:annix/services/annil.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavoriteButton extends StatelessWidget {
  final AnnivController anniv = Get.find();
  final AnnilAudioSource audio;
  final RxBool favorited = false.obs;

  FavoriteButton(this.audio, {Key? key}) : super(key: key) {
    // listen further updates
    favorited.bindStream(anniv.favorites.stream
        .map((favorites) => favorites.containsKey(audio.id)));
    // initialize current status
    favorited.value = anniv.favorites.containsKey(audio.id);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => IconButton(
        isSelected: favorited.value,
        icon: Icon(Icons.favorite_border_outlined),
        selectedIcon: Icon(Icons.favorite_outlined),
        onPressed: () async {
          this.anniv.toggleFavorite(audio.id);
        },
      ),
    );
  }
}
