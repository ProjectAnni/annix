import 'package:annix/providers.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

enum AnnilDialogMode {
  add,
  edit,
}

typedef AnnilDialogOnSubmitCallback = void Function(
    String name, String url, String token);

class AnnilDialog extends HookConsumerWidget {
  final AnnilDialogOnSubmitCallback onSubmit;
  final String? name;
  final String? url;
  final String? token;
  final AnnilDialogMode mode;

  const AnnilDialog({
    super.key,
    required this.onSubmit,
    this.name,
    this.url,
    this.token,
    required this.mode,
  });

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final serverNameController = useTextEditingController(text: name);
    final serverUrlController = useTextEditingController(text: url);
    final serverTokenController = useTextEditingController(text: token);

    return AlertDialog(
      titlePadding: const EdgeInsets.only(top: 8),
      contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      elevation: 16,
      title: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: mode == AnnilDialogMode.add
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
              decoration: const InputDecoration(labelText: 'Name'),
              controller: serverNameController,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Server'),
              controller: serverUrlController,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Token'),
              controller: serverTokenController,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(textStyle: context.textTheme.labelLarge),
          child: const Text('Cancel'),
          onPressed: () => ref.read(routerProvider).popRoute(),
        ),
        TextButton(
          style: TextButton.styleFrom(textStyle: context.textTheme.labelLarge),
          child: mode == AnnilDialogMode.add
              ? const Text('Add')
              : const Text('Update'),
          onPressed: () {
            ref.read(routerProvider).popRoute();
            onSubmit(
              serverNameController.text,
              serverUrlController.text,
              serverTokenController.text,
            );
          },
        ),
      ],
    );
  }
}

class AnnilAddDialog extends StatelessWidget {
  final AnnilDialogOnSubmitCallback onSubmit;

  const AnnilAddDialog({super.key, required this.onSubmit});

  @override
  Widget build(final BuildContext context) {
    return AnnilDialog(
      mode: AnnilDialogMode.add,
      onSubmit: onSubmit,
    );
  }
}
