import 'package:annix/providers.dart';
import 'package:annix/ui/dialogs/loading.dart';
import 'package:annix/ui/route/delegate.dart';
import 'package:flutter/material.dart';
import 'package:annix/i18n/strings.g.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AnnivLoginPage extends HookConsumerWidget {
  const AnnivLoginPage({super.key});

  void _showSnackBar(final BuildContext context, final String text) {
    final snackBar = SnackBar(content: Text(text));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final serverUrlController = useTextEditingController();
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text(t.server.login_to_anniv),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () async {
              final anniv = ref.read(annivProvider);

              var url = serverUrlController.text;
              var email = emailController.text;
              final password = passwordController.text;
              final delegate = AnnixRouterDelegate.of(context);
              if (url.isEmpty) {
                _showSnackBar(context, 'Please enter a valid URL');
              } else if (email.isEmpty || !email.contains('@')) {
                _showSnackBar(context, 'Please enter a valid email');
              } else if (password.isEmpty) {
                _showSnackBar(context, 'Please enter a password');
              } else {
                email = email.trim();
                if (!url.startsWith('http://') && !url.startsWith('https://')) {
                  url = 'https://$url';
                }
                try {
                  showLoadingDialog(context);
                  await anniv.login(url, email, password);
                  // pop login page
                  await delegate.popRoute();
                } catch (e) {
                  _showSnackBar(context, e.toString());
                } finally {
                  // hide loading dialog
                  await delegate.popRoute();
                }
              }
            },
          )
        ],
      ),
      body: AutofillGroup(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.cloud_outlined),
                  border: OutlineInputBorder(),
                  labelText: 'Server',
                ),
                controller: serverUrlController,
                autofillHints: const [AutofillHints.url],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.email_outlined),
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                controller: emailController,
                autofillHints: const [AutofillHints.email],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.password),
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                controller: passwordController,
                obscureText: true,
                autofillHints: const [AutofillHints.password],
              ),
            ),
          ],
        ),
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}
