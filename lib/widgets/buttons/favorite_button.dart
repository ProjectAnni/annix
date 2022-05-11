import 'package:annix/controllers/anniv_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavoriteButton extends StatelessWidget {
  final AnnivController anniv = Get.find();
  final String id;
  final RxBool favorited = false.obs;

  FavoriteButton({Key? key, required this.id}) : super(key: key) {
    // listen further updates
    favorited.bindStream(
        anniv.favorites.stream.map((favorites) => favorites.containsKey(id)));
    // initialize current status
    favorited.value = anniv.favorites.containsKey(id);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => IconButton(
        icon: Icon(
          favorited.value
              ? Icons.favorite_outlined
              : Icons.favorite_border_outlined,
        ),
        onPressed: () async {
          this.anniv.toggleFavorite(id);
        },
      ),
    );
  }
}
