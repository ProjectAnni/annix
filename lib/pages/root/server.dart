import 'package:annix/services/anniv/anniv.dart';
import 'package:annix/pages/root/base.dart';
import 'package:annix/services/annil/client.dart';
import 'package:annix/ui/dialogs/anniv_login.dart';
import 'package:annix/ui/route/delegate.dart';
import 'package:annix/ui/widgets/simple_text_field.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:annix/i18n/strings.g.dart';

///////////////////////////////////////////////////////////////////////////////
/// Anniv
class AnnivCard extends StatelessWidget {
  const AnnivCard({Key? key}) : super(key: key);

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
                showDialog(
                  context: context,
                  useRootNavigator: true,
                  builder: (context) => AnnivLoginDialog(),
                );
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
              PopupMenuButton(
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      child: Text(t.server.logout),
                      onTap: () {
                        final anniv =
                            Provider.of<AnnivService>(context, listen: false);
                        anniv.logout();
                      },
                    ),
                  ];
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.more_vert_outlined),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            children: [
              if (info.site.features.contains("metadata-db"))
                // TODO: move this button to somewhere else
                TextButton(
                  child: const Text("Update Database"),
                  onPressed: () async {
                    final anniv =
                        Provider.of<AnnivService>(context, listen: false);
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
  final OnlineAnnilClient annil;

  const AnnilListTile({Key? key, required this.annil}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(annil.name),
      leading: const Icon(Icons.drag_handle_outlined),
      trailing: IconButton(
        icon: const Icon(Icons.edit_outlined),
        onPressed: () {
          // FIXME: edit annil
          // Get.generalDialog(
          //   pageBuilder: (context, animation, secondaryAnimation) {
          //     return Container();
          //   },
          // );
        },
      ),
      dense: true,
      selected: true,
    );
  }
}

class AnnilDialog extends StatelessWidget {
  final serverNameController = TextEditingController();
  final serverUrlController = TextEditingController();
  final serverTokenController = TextEditingController();
  final void Function(OnlineAnnilClient annil) onSubmit;

  AnnilDialog({Key? key, required this.onSubmit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
        child: Column(
          children: const [
            Padding(
              padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Icon(
                Icons.add_box_outlined,
                size: 32,
              ),
            ),
            Text("Annil Library"),
          ],
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SimpleTextField(label: "Name", controller: serverNameController),
            SimpleTextField(label: "Server", controller: serverUrlController),
            SimpleTextField(label: "Token", controller: serverTokenController),
          ],
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            textStyle: context.textTheme.labelLarge,
          ),
          child: const Text('Cancel'),
          onPressed: () => AnnixRouterDelegate.of(context).popRoute(),
        ),
        TextButton(
          style: TextButton.styleFrom(
            textStyle: context.textTheme.labelLarge,
          ),
          child: const Text('Add'),
          onPressed: () {
            // TODO: Add annil
            AnnixRouterDelegate.of(context).popRoute();
          },
        ),
      ],
      titlePadding: const EdgeInsets.only(top: 8),
      contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      actionsPadding: EdgeInsets.zero,
      insetPadding: EdgeInsets.zero,
      buttonPadding: EdgeInsets.zero,
      elevation: 16,
    );
  }
}

///////////////////////////////////////////////////////////////////////////////
/// Page
class ServerView extends StatelessWidget {
  const ServerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BaseAppBar(
          title: Text(t.server.server),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                AnnixRouterDelegate.of(context).to(name: '/settings');
              },
            ),
          ],
        ),
        const AnnivCard(),
        ListTile(
          title: Text(t.server.libraries),
          trailing: IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AnnilDialog(
                  onSubmit: (annil) {
                    // TODO: save annil
                  },
                ),
              );
            },
          ),
        ),
        Expanded(
          child: Consumer<CombinedOnlineAnnilClient>(
            builder: (context, annil, child) {
              final sortedClients = annil.sortedClients;

              return ReorderableListView(
                padding: EdgeInsets.zero,
                buildDefaultDragHandles: true,
                onReorder: (oldIndex, newIndex) {},
                children: sortedClients
                    .map(
                      (value) => AnnilListTile(
                        annil: value,
                        key: ValueKey(value.priority),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}
