import 'package:annix/providers.dart';
import 'package:annix/services/anniv/anniv.dart';
import 'package:annix/services/local/database.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

///////////////////////////////////////////////////////////////////////////////
/// Anniv
class AnnivCard extends ConsumerWidget {
  const AnnivCard({super.key});

  Widget afterLogin(
    final BuildContext context,
    final WidgetRef ref,
    final SiteUserInfo info,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 4.0, right: 12.0, top: 16, left: 16),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: CircleAvatar(
                  child: Text(info.user.nickname.substring(0, 1)),
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      info.user.nickname,
                      style: context.textTheme.titleLarge,
                    ),
                    Text(
                      info.site.siteName,
                      style: context.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              // TODO: Add more things in this card
              const SizedBox(height: 80),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  ref.read(annivProvider).logout();
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            children: [
              if (info.site.features.contains('metadata-db'))
                // TODO: move this button to somewhere else
                TextButton(
                  child: const Text('Update Database'),
                  onPressed: () async {
                    await ref.read(annivProvider).updateDatabase();
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final annivInfo = ref.watch(annivProvider.select((final v) => v.info));

    return Card.outlined(
      child: afterLogin(context, ref, annivInfo!),
    );
  }
}

///////////////////////////////////////////////////////////////////////////////
/// Annil
class AnnilListTile extends ConsumerWidget {
  final LocalAnnilServer annil;
  final bool enabled;

  const AnnilListTile({super.key, required this.annil, required this.enabled});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    return ListTile(
      title: Text(annil.name),
      leading: const Icon(Icons.library_music_outlined),
      selected: true,
      enabled: enabled,
      onTap: () {
        context.push('/annil', extra: annil);
      },
    );
  }
}
