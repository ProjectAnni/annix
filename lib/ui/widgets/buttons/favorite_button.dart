import 'package:annix/providers.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class FavoriteButton extends ConsumerWidget {
  const FavoriteButton({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final favoriteTracks = ref.watch(favoriteTracksProvider);
    final playingTrack =
        ref.watch(playingProvider.select((final p) => p.source?.track));

    final favorites = favoriteTracks.value ?? [];
    return IconButton(
      isSelected: favorites.any(
        (final f) =>
            playingTrack?.id ==
            TrackIdentifier(
              albumId: f.albumId,
              discId: f.discId,
              trackId: f.trackId,
            ),
      ),
      icon: const Icon(Icons.favorite_border_outlined),
      selectedIcon: const Icon(Icons.favorite_outlined),
      onPressed: () async {
        if (playingTrack != null) {
          ref.read(annivProvider).toggleFavoriteTrack(playingTrack);
        }
      },
    );
  }
}

class FavoriteAlbumButton extends ConsumerWidget {
  final String albumId;

  const FavoriteAlbumButton({super.key, required this.albumId});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final favoriteAlbums = ref.watch(favoriteAlbumsProvider);
    final favorites = favoriteAlbums.value ?? [];

    return IconButton(
      isSelected: favorites.any((final album) => album.albumId == albumId),
      icon: const Icon(Icons.star_border_outlined),
      selectedIcon: const Icon(Icons.star_outlined),
      onPressed: () async {
        ref.read(annivProvider).toggleFavoriteAlbum(albumId);
      },
    );
  }
}
