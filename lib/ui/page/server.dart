import 'package:annix/services/annil/annil.dart';
import 'package:annix/services/anniv/anniv.dart';
import 'package:annix/services/local/database.dart';
import 'package:annix/ui/dialogs/annil.dart';
import 'package:annix/ui/route/delegate.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:annix/i18n/strings.g.dart';

///////////////////////////////////////////////////////////////////////////////
/// Anniv
class AnnivCard extends StatelessWidget {
  const AnnivCard({super.key});

  // Card content before login
  Widget beforeLogin(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0).copyWith(bottom: 12, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            t.server.not_logged_in,
            style: context.textTheme.titleLarge,
          ),
          Text(
            t.server.anniv_features,
            style: context.textTheme.bodyMedium,
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: TextButton(
              child: Text(t.server.login),
              onPressed: () {
                AnnixRouterDelegate.of(context).to(name: '/login');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget afterLogin(BuildContext context, SiteUserInfo info) {
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
              PopupMenuButton<String>(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'Logout',
                    child: Text(t.server.logout),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'Logout') {
                    final anniv = context.read<AnnivService>();
                    anniv.logout();
                  }
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
                    final anniv = context.read<AnnivService>();
                    await anniv.updateDatabase();
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inner = Consumer<AnnivService>(
      builder: (context, AnnivService anniv, child) {
        if (anniv.info == null) {
          return beforeLogin(context);
        } else {
          return afterLogin(context, anniv.info!);
        }
      },
    );

    return Card(child: inner);
  }
}

///////////////////////////////////////////////////////////////////////////////
/// Annil
class AnnilListTile extends StatelessWidget {
  final LocalAnnilServer annil;
  final bool enabled;

  const AnnilListTile({super.key, required this.annil, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(annil.name),
      leading: const Icon(Icons.library_music_outlined),
      selected: true,
      enabled: enabled,
      onTap: () {
        // FIXME: edit annil
        // Get.generalDialog(
        //   pageBuilder: (context, animation, secondaryAnimation) {
        //     return Container();
        //   },
        // );
      },
    );
  }
}

///////////////////////////////////////////////////////////////////////////////
/// Page
class ServerView extends StatelessWidget {
  const ServerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t.server.server),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              AnnixRouterDelegate.of(context).to(name: '/settings');
            },
          ),
        ],
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
                  builder: (context) => AnnilAddDialog(
                    onSubmit: (name, url, token) {
                      // TODO: save annil
                    },
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: Consumer<AnnilService>(
              builder: (context, annil, child) {
                return ReorderableListView(
                  buildDefaultDragHandles: true,
                  onReorder: (oldIndex, newIndex) async {
                    var oldAnnil = annil.servers[oldIndex];
                    final newAnnil = annil.servers[newIndex];

                    final db = context.read<LocalDatabase>();
                    final anniv = context.read<AnnivService>();
                    if (oldIndex < newIndex) {
                      // - priority
                      oldAnnil =
                          oldAnnil.copyWith(priority: newAnnil.priority - 1);
                      await (db.localAnnilServers.update()
                            ..where((tbl) => tbl.id.equals(oldAnnil.id)))
                          .write(oldAnnil);
                    } else if (oldIndex > newIndex) {
                      // + priority
                      oldAnnil =
                          oldAnnil.copyWith(priority: newAnnil.priority + 1);
                      await (db.localAnnilServers.update()
                            ..where((tbl) => tbl.id.equals(oldAnnil.id)))
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
                        (server) => AnnilListTile(
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
