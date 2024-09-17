import 'package:annix/providers.dart';
import 'package:annix/services/local/database.dart';
import 'package:annix/ui/dialogs/loading.dart';
import 'package:annix/ui/page/annil/annil.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AnnilCard extends ConsumerWidget {
  const AnnilCard({
    super.key,
    required this.annil,
    required this.cache,
  });

  final LocalAnnilServer annil;
  final LocalAnnilInfo cache;

  void onEdit(WidgetRef ref) {
    // TODO: edit annil info
  }

  void onSync(BuildContext context, WidgetRef ref) async {
    final delegate = ref.read(goRouterProvider);
    final provider = ref.read(annilProvider);

    showLoadingDialog(context);
    await provider.updateAlbums(annil);
    delegate.pop();
    ref.invalidate(annilCacheFamily);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // const Icon(Icons.storage, size: 32),
                    // const SizedBox(width: 8),
                    Text(
                      annil.name,
                      style: context.textTheme.headlineLarge,
                    ),
                  ],
                ),
                Card.outlined(
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Row(
                      children: [
                        const Icon(Icons.album, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          cache.albums.length.toString(),
                          style: context.textTheme.titleSmall,
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Row(
                children: [
                  const Icon(Icons.tag, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    annil.priority.toString(),
                    style: context.textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Row(
                children: [
                  const Icon(Icons.link, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    annil.url,
                    style: context.textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            if (cache.cache.etag != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  children: [
                    const Icon(Icons.sell, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      cache.cache.etag!,
                      style: context.textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            if (cache.cache.lastUpdate != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  children: [
                    const Icon(Icons.update, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      DateTime.fromMillisecondsSinceEpoch(
                              cache.cache.lastUpdate!)
                          .toString(),
                      style: context.textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: null, // () => onEdit(ref),
                ),
                IconButton(
                  icon: const Icon(Icons.sync),
                  onPressed: () => onSync(context, ref),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
