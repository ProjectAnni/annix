import 'package:annix/controllers/annil_controller.dart';
import 'package:annix/controllers/anniv_controller.dart';
import 'package:annix/services/annil.dart';
import 'package:annix/widgets/simple_text_field.dart';
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
              onPressed: () => Get.dialog(AnnivDialog()),
            ),
          ),
        ],
      ),
    );
  }

  Widget afterLogin(BuildContext context, AnnivController anniv) {
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
                child: CircleAvatar(
                  child: Obx(() {
                    return Text(anniv.userInfo.value.nickname.substring(0, 1));
                  }),
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Obx(() {
                      return Text(
                        anniv.userInfo.value.nickname,
                        style: context.textTheme.titleLarge,
                      );
                    }),
                    Obx(() {
                      return Text(
                        anniv.siteInfo.value.siteName,
                        style: context.textTheme.bodyMedium,
                      );
                    }),
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
    final AnnivController anniv = Get.find();

    return Card(
      elevation: 0,
      color: context.theme.colorScheme.surfaceVariant,
      child: Obx(
        () => anniv.loggedIn.value
            ? afterLogin(context, anniv)
            : beforeLogin(context),
      ),
    );
  }
}

class AnnivDialogController extends GetxController {
  var serverUrlController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
}

class AnnivDialog extends StatelessWidget {
  final AnnivDialogController _controller = AnnivDialogController();

  AnnivDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AnnivController anniv = Get.find();

    return AlertDialog(
      title: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Icon(
                Icons.login_outlined,
                size: 32,
              ),
            ),
            Text("Login to Anniv"),
          ],
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SimpleTextField(
                label: "Server", controller: _controller.serverUrlController),
            SimpleTextField(
                label: "Email", controller: _controller.emailController),
            SimpleTextField(
                label: "Password",
                controller: _controller.passwordController,
                password: true),
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
          onPressed: () async {
            var url = this._controller.serverUrlController.text;
            var email = this._controller.emailController.text;
            final password = this._controller.passwordController.text;
            if (url.isEmpty) {
              Get.snackbar("Error", "Please enter a valid URL");
            } else if (email.isEmpty || !email.contains('@')) {
              Get.snackbar("Error", "Please enter a valid email");
            } else if (password.isEmpty) {
              Get.snackbar("Error", "Please enter a password");
            } else {
              email = email.trim();
              if (!url.startsWith("http://") && !url.startsWith("https://")) {
                url = "https://$url";
              }
              // login
              Get.snackbar("Logging in", "Please wait...");
              try {
                await anniv.login(url, email, password);
                Navigator.of(Get.overlayContext!).pop();
              } catch (e) {
                Get.snackbar("Failed to login", e.toString());
              }
            }
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

///////////////////////////////////////////////////////////////////////////////
/// Annil
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

class AnnilDialogController extends GetxController {
  var serverNameController = TextEditingController();
  var serverUrlController = TextEditingController();
  var serverTokenController = TextEditingController();
}

class AnnilDialog extends StatelessWidget {
  final AnnilDialogController _controller = AnnilDialogController();
  final void Function(AnnilClient annil) onSubmit;

  AnnilDialog({Key? key, required this.onSubmit}) : super(key: key);

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
            SimpleTextField(
                label: "Name", controller: _controller.serverNameController),
            SimpleTextField(
                label: "Server", controller: _controller.serverUrlController),
            SimpleTextField(
                label: "Token", controller: _controller.serverTokenController),
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

///////////////////////////////////////////////////////////////////////////////
/// Page
class ServerView extends StatelessWidget {
  const ServerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          child: Obx(() {
            AnnilController annil = Get.find();
            var clients = annil.clients.values.toList();
            clients.sort((a, b) => a.priority - b.priority);

            return ReorderableListView(
              padding: EdgeInsets.zero,
              buildDefaultDragHandles: true,
              onReorder: (oldIndex, newIndex) {},
              children: clients
                  .map((value) => AnnilListTile(
                      annil: value, key: ValueKey(value.priority)))
                  .toList(),
            );
          }),
        ),
      ],
    );
  }
}