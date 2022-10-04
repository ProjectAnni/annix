import 'package:annix/ui/route/delegate.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';

class _AnnilDialogBase extends StatelessWidget {
  final TextEditingController _serverNameController;
  final TextEditingController _serverUrlController;
  final TextEditingController _serverTokenController;

  final void Function(String name, String url, String token) onSubmit;

  _AnnilDialogBase({
    required this.onSubmit,
    String? name,
    String? url,
    String? token,
  })  : _serverNameController = TextEditingController(text: name),
        _serverUrlController = TextEditingController(text: url),
        _serverTokenController = TextEditingController(text: token);

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
            Text('Annil Library'),
          ],
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Name',
              ),
              controller: _serverNameController,
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Server',
              ),
              controller: _serverUrlController,
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Token',
              ),
              controller: _serverTokenController,
            ),
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
            AnnixRouterDelegate.of(context).popRoute();
            onSubmit(
              _serverNameController.text,
              _serverUrlController.text,
              _serverTokenController.text,
            );
          },
        ),
      ],
      titlePadding: const EdgeInsets.only(top: 8),
      contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      elevation: 16,
    );
  }
}

class AnnilAddDialog extends StatelessWidget {
  final _serverNameController = TextEditingController();
  final _serverUrlController = TextEditingController();
  final _serverTokenController = TextEditingController();

  final void Function(String name, String url, String token) onSubmit;

  AnnilAddDialog({
    Key? key,
    required this.onSubmit,
  }) : super(key: key);

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
            Text('Annil Library'),
          ],
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Name',
              ),
              controller: _serverNameController,
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Server',
              ),
              controller: _serverUrlController,
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Token',
              ),
              controller: _serverTokenController,
            ),
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
            AnnixRouterDelegate.of(context).popRoute();
            onSubmit(
              _serverNameController.text,
              _serverUrlController.text,
              _serverTokenController.text,
            );
          },
        ),
      ],
      // titlePadding: const EdgeInsets.only(top: 8),
      // contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      // actionsPadding: EdgeInsets.zero,
      // insetPadding: EdgeInsets.zero,
      // buttonPadding: EdgeInsets.zero,
      elevation: 16,
    );
  }
}
