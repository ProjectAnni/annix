import 'package:annix/controllers/anniv_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavoriteButton extends StatelessWidget {
  final String id;
  FavoriteButton({Key? key, required this.id}) : super(key: key);

  final favorited = false.obs;

  @override
  Widget build(BuildContext context) {
    final AnnivController anniv = Get.find();

    if (anniv.favorites.containsKey(id)) {
      favorited.value = true;
    }

    return Obx(
      () => IconButton(
        icon: Icon(
          favorited.value
              ? Icons.favorite_outlined
              : Icons.favorite_border_outlined,
        ),
        onPressed: () async {
          try {
            if (!favorited.value) {
              favorited.value = true;
              await anniv.addFavorite(id);
            } else {
              favorited.value = false;
              await anniv.removeFavorite(id);
            }
          } catch (e) {
            favorited.value = !favorited.value;
          }
        },
      ),
    );
  }
}
