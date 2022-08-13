import 'package:annix/controllers/anniv_controller.dart';
import 'package:annix/ui/route/delegate.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AnnivLoginDialog extends StatelessWidget {
  final _serverUrlController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  AnnivLoginDialog({Key? key}) : super(key: key);

  void _showSnackBar(BuildContext context, String text) {
    final snackBar = SnackBar(content: Text(text));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    final anniv = Provider.of<AnnivController>(context, listen: false);

    return AlertDialog(
      title: Center(
        child: Column(
          children: const [
            Padding(
              padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
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
            TextFormField(
              decoration: const InputDecoration(
                labelText: "Server",
              ),
              controller: _serverUrlController,
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: "Email",
              ),
              controller: _emailController,
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: "Password",
              ),
              controller: _passwordController,
              obscureText: true,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text('Login'),
          onPressed: () async {
            var url = _serverUrlController.text;
            var email = _emailController.text;
            final password = _passwordController.text;
            final delegate = AnnixRouterDelegate.of(context);
            if (url.isEmpty) {
              _showSnackBar(context, "Please enter a valid URL");
            } else if (email.isEmpty || !email.contains('@')) {
              _showSnackBar(context, "Please enter a valid email");
            } else if (password.isEmpty) {
              _showSnackBar(context, "Please enter a password");
            } else {
              email = email.trim();
              if (!url.startsWith("http://") && !url.startsWith("https://")) {
                url = "https://$url";
              }
              try {
                // TODO: alert progress
                await anniv.login(url, email, password);
                delegate.popRoute();
              } catch (e) {
                _showSnackBar(context, e.toString());
              }
            }
          },
        ),
      ],
    );
  }
}
