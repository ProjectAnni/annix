import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/ui/page/album.dart';
import 'package:annix/ui/widgets/artist_text.dart';
import 'package:annix/ui/widgets/shimmer/shimmer_text.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AlbumTitleText extends StatelessWidget {
  final String title;
  const AlbumTitleText({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: context.textTheme.labelMedium?.copyWith(
        color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class TrackTitleText extends ConsumerWidget {
  final TrackIdentifier identifier;

  const TrackTitleText({super.key, required this.identifier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final track = ref.watch(trackFamily(identifier));

    return track.when(
      data: (track) => Text(
        track.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      error: (_, __) => const Text('Error'),
      loading: () => const ShimmerText(length: 8),
    );
  }
}

class TrackArtistText extends ConsumerWidget {
  final TrackIdentifier identifier;
  const TrackArtistText({super.key, required this.identifier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final track = ref.watch(trackFamily(identifier));

    return track.when(
      data: (track) => ArtistText(
        track.artist,
        overflow: TextOverflow.ellipsis,
      ),
      error: (_, __) => const Text('Error'),
      loading: () => const ShimmerText(length: 4),
    );
  }
}

class LazyAlbumTitleText extends ConsumerWidget {
  final String albumId;
  const LazyAlbumTitleText({super.key, required this.albumId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final album = ref.watch(albumFamily(albumId));

    return album.when(
      data: (album) => AlbumTitleText(title: album.title),
      error: (_, __) => const Text('Error'),
      loading: () => const ShimmerText(length: 6),
    );
  }
}
