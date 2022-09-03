import 'package:annix/services/anniv/anniv.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/services/local/database.dart';
import 'package:annix/services/player.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key});

  @override
  Widget build(BuildContext context) {
    final anniv = Provider.of<AnnivService>(context, listen: false);

    return Consumer2<PlayerService, List<Favorite>>(
      builder: (context, player, favorites, child) => IconButton(
        isSelected: favorites.firstWhereOrNull((f) =>
                player.playing?.identifier ==
                TrackIdentifier(
                  albumId: f.albumId,
                  discId: f.discId,
                  trackId: f.trackId,
                )) !=
            null,
        icon: const Icon(Icons.favorite_border_outlined),
        selectedIcon: const Icon(Icons.favorite_outlined),
        onPressed: () async {
          final track = player.playing?.track;
          if (track != null) {
            anniv.toggleFavorite(track);
          }
        },
      ),
    );
  }
}
