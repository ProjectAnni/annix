import 'package:annix/services/anniv/anniv.dart';
import 'package:annix/ui/dialogs/loading.dart';
import 'package:annix/ui/route/delegate.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:annix/i18n/strings.g.dart';

class AnnivLoginPage extends StatefulWidget {
  const AnnivLoginPage({super.key});

  @override
  State<AnnivLoginPage> createState() => _AnnivLoginPageState();
}

class _AnnivLoginPageState extends State<AnnivLoginPage> {
  final _serverUrlController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _showSnackBar(BuildContext context, String text) {
    final snackBar = SnackBar(content: Text(text));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t.server.login_to_anniv),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.cloud_outlined),
                border: OutlineInputBorder(),
                labelText: 'Server',
              ),
              controller: _serverUrlController,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.email_outlined),
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              controller: _emailController,
              autofillHints: const [AutofillHints.email],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.password),
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              controller: _passwordController,
              obscureText: true,
              autofillHints: const [AutofillHints.email],
            ),
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton(
        isExtended: true,
        child: const Icon(Icons.check),
        onPressed: () async {
          final anniv = context.read<AnnivService>();

          var url = _serverUrlController.text;
          var email = _emailController.text;
          final password = _passwordController.text;
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
              delegate.popRoute();
            } catch (e) {
              _showSnackBar(context, e.toString());
            } finally {
              delegate.popRoute();
            }
          }
        },
      ),
    );
  }
}
