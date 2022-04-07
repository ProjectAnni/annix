import 'package:annix/controllers/annil_controller.dart';
import 'package:annix/services/annil.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
            "Not logged in to Anniv",
            style: context.textTheme.titleLarge,
          ),
          Text(
            // TODO: some description about anniv's functions
            "TODO: some description about anniv’s functions",
            style: context.textTheme.bodyMedium,
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: TextButton(
              child: Text("Login"),
              onPressed: () {
                // TODO: show anniv login dialog
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget afterLogin(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.0, right: 12.0, top: 16, left: 16),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: CircleAvatar(),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      "Yesterday17",
                      style: context.textTheme.titleLarge,
                    ),
                    Text(
                      "Anniv Site Name Goes Here",
                      style: context.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              // TODO: Add more things in this card
              SizedBox(height: 80),
              IconButton(
                icon: Icon(Icons.more_vert_outlined),
                padding: EdgeInsets.zero,
                alignment: Alignment.topRight,
                splashRadius: 1.0,
                onPressed: () {},
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            children: [
              TextButton(
                child: Text("Logout"),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: context.theme.colorScheme.surfaceVariant,
      child: beforeLogin(context),
    );
  }
}

///////////////////////////////////////////////////////////////////////////////
/// Annil
class AnnilDialogController extends GetxController {
  var serverNameController = TextEditingController();
  var serverUrlController = TextEditingController();
  var serverTokenController = TextEditingController();
}

class AnnilDialog extends StatelessWidget {
  final AnnilDialogController _controller = AnnilDialogController();
  final void Function(AnnilClient annil) onSubmit;

  AnnilDialog({Key? key, required this.onSubmit}) : super(key: key);

  Widget buildTextField(BuildContext context, String labelText,
      TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: labelText,
          isDense: true,
          filled: true,
          fillColor: context.theme.colorScheme.surfaceVariant,
        ),
        controller: controller,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
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
            buildTextField(context, "Name", _controller.serverNameController),
            buildTextField(context, "Server", _controller.serverUrlController),
            buildTextField(context, "Token", _controller.serverTokenController),
          ],
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            textStyle: context.textTheme.labelLarge,
          ),
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(Get.overlayContext!).pop(),
        ),
        TextButton(
          style: TextButton.styleFrom(
            textStyle: context.textTheme.labelLarge,
          ),
          child: const Text('Add'),
          onPressed: () {
            // TODO: Add annil
            Navigator.of(Get.overlayContext!).pop();
          },
        ),
      ],
      titlePadding: EdgeInsets.only(top: 8),
      contentPadding: EdgeInsets.fromLTRB(16, 0, 16, 0),
      actionsPadding: EdgeInsets.zero,
      insetPadding: EdgeInsets.zero,
      buttonPadding: EdgeInsets.zero,
      elevation: 16,
    );
  }
}

class AnnilListTile extends StatelessWidget {
  final AnnilClient annil;

  const AnnilListTile({Key? key, required this.annil}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(annil.name),
      leading: Icon(Icons.drag_handle_outlined),
      trailing: IconButton(
        icon: Icon(Icons.edit_outlined),
        onPressed: () {
          Get.generalDialog(
            pageBuilder: (context, animation, secondaryAnimation) {
              return Container();
            },
          );
        },
      ),
      dense: true,
      selected: true,
    );
  }
}

class ServerView extends StatelessWidget {
  const ServerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AnnilController annil = Get.find();
    var clients = annil.clients.values.toList();
    clients.sort((a, b) => a.priority - b.priority);

    return Column(
      children: [
        AppBar(
          title: Text("Server"),
          centerTitle: true,
        ),
        AnnivCard(),
        ListTile(
          title: Text("Libraries"),
          trailing: IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Get.dialog(
                AnnilDialog(
                  onSubmit: (annil) {
                    // TODO: save annil
                  },
                ),
              );
            },
          ),
        ),
        Expanded(
          child: ReorderableListView(
            padding: EdgeInsets.zero,
            buildDefaultDragHandles: true,
            onReorder: (oldIndex, newIndex) {},
            children: clients
                .map((value) =>
                    AnnilListTile(annil: value, key: ValueKey(value.priority)))
                .toList(),
          ),
        ),
      ],
    );
  }
}
