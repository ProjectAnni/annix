import 'package:annix/services/global.dart';
import 'package:flutter/material.dart';

class FavoriteButton extends StatefulWidget {
  final String id;

  const FavoriteButton({Key? key, required this.id}) : super(key: key);

  @override
  FavoriteButtonState createState() => FavoriteButtonState();
}

class FavoriteButtonState extends State<FavoriteButton> {
  bool favorited = false;

  @override
  void initState() {
    super.initState();

    if (Global.anniv!.favorites.containsKey(widget.id)) {
      favorited = true;
    }
  }

  @override
  Widget build(BuildContext context) {
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
            await Global.anniv!.addFavorite(widget.id);
          } else {
            setState(() {
              favorited = false;
            });
            await Global.anniv!.removeFavorite(widget.id);
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
