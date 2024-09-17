import 'package:annix/providers.dart';
import 'package:annix/services/anniv/anniv.dart';
import 'package:annix/services/local/database.dart';
import 'package:annix/ui/dialogs/annil.dart';
import 'package:annix/ui/widgets/anniv/anniv_not_login_card.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:annix/i18n/strings.g.dart';
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

    return annivInfo == null
        ? const AnnivNotLoginCard()
        : Card(
            child: afterLogin(context, ref, annivInfo),
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

///////////////////////////////////////////////////////////////////////////////
/// Page
class ServerView extends StatelessWidget {
  const ServerView({super.key});

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t.server.server),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const AnnivCard(),
          ListTile(
            title: Text(t.server.libraries),
            trailing: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (final context) => AnnilAddDialog(
                    onSubmit: (final name, final url, final token) {
                      // TODO: save annil
                    },
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: Consumer(
              builder: (final context, final ref, final child) {
                final annil = ref.watch(annilProvider);
                return ReorderableListView(
                  buildDefaultDragHandles: true,
                  onReorder: (final oldIndex, final newIndex) async {
                    var oldAnnil = annil.servers[oldIndex];
                    final newAnnil = annil.servers[newIndex];

                    final db = ref.read(localDatabaseProvider);
                    final anniv = ref.read(annivProvider);
                    if (oldIndex < newIndex) {
                      // - priority
                      oldAnnil =
                          oldAnnil.copyWith(priority: newAnnil.priority - 1);
                      await (db.localAnnilServers.update()
                            ..where((final tbl) => tbl.id.equals(oldAnnil.id)))
                          .write(oldAnnil);
                    } else if (oldIndex > newIndex) {
                      // + priority
                      oldAnnil =
                          oldAnnil.copyWith(priority: newAnnil.priority + 1);
                      await (db.localAnnilServers.update()
                            ..where((final tbl) => tbl.id.equals(oldAnnil.id)))
                          .write(oldAnnil);
                    }

                    if (oldAnnil.remoteId != null) {
                      // update to anniv
                      // TODO: write to local after request
                      await anniv.client?.updateCredential(
                        oldAnnil.remoteId!,
                        priority: oldAnnil.priority,
                      );
                    }
                  },
                  children: annil.servers
                      .map(
                        (final server) => AnnilListTile(
                          annil: server,
                          key: ValueKey(server.priority),
                          enabled: annil.etags[server.id] != null,
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
