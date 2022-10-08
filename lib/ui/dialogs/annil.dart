import 'package:annix/ui/route/delegate.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';

enum AnnilDialogMode {
  add,
  edit,
}

typedef AnnilDialogOnSubmitCallback = void Function(
    String name, String url, String token);

class BaseAnnilDialog extends StatefulWidget {
  final AnnilDialogOnSubmitCallback onSubmit;
  final String? name;
  final String? url;
  final String? token;
  final AnnilDialogMode mode;

  const BaseAnnilDialog({
    super.key,
    required this.onSubmit,
    this.name,
    this.url,
    this.token,
    required this.mode,
  });

  @override
  State<BaseAnnilDialog> createState() => _BaseAnnilDialogState();
}

class _BaseAnnilDialogState extends State<BaseAnnilDialog> {
  late final TextEditingController _serverNameController;
  late final TextEditingController _serverUrlController;
  late final TextEditingController _serverTokenController;

  @override
  void initState() {
    super.initState();

    _serverNameController = TextEditingController(text: widget.name);
    _serverUrlController = TextEditingController(text: widget.url);
    _serverTokenController = TextEditingController(text: widget.token);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: widget.mode == AnnilDialogMode.add
                  ? const Icon(Icons.add_box_outlined, size: 32)
                  : const Icon(Icons.edit_outlined, size: 32),
            ),
            const Text('Annil Library'),
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
          child: widget.mode == AnnilDialogMode.add
              ? const Text('Add')
              : const Text('Update'),
          onPressed: () {
            AnnixRouterDelegate.of(context).popRoute();
            widget.onSubmit(
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
  final AnnilDialogOnSubmitCallback onSubmit;

  const AnnilAddDialog({super.key, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return BaseAnnilDialog(
      mode: AnnilDialogMode.add,
      onSubmit: onSubmit,
    );
  }
}
