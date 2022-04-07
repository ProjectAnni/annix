import 'package:annix/controllers/anniv_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavoriteButton extends StatefulWidget {
  final String id;

  const FavoriteButton({Key? key, required this.id}) : super(key: key);

  @override
  FavoriteButtonState createState() => FavoriteButtonState();
}

class FavoriteButtonState extends State<FavoriteButton> {
  bool favorited = false;

  @override
  Widget build(BuildContext context) {
    final AnnivController anniv = Get.find();

    if (anniv.client!.favorites.containsKey(widget.id)) {
      favorited = true;
    }

    return IconButton(
      icon: Icon(
        favorited ? Icons.favorite_outlined : Icons.favorite_border_outlined,
      ),
      onPressed: () async {
        try {
          if (!favorited) {
            setState(() {
              favorited = true;
            });
            await anniv.client!.addFavorite(widget.id);
          } else {
            setState(() {
              favorited = false;
            });
            await anniv.client!.removeFavorite(widget.id);
          }
        } catch (e) {
          setState(() {
            favorited = !favorited;
            // TODO: Toast error
          });
        }
      },
    );
  }
}
