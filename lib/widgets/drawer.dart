import 'package:flutter/material.dart';

class AnniDrawer extends StatelessWidget {
  static String _currentRoute = '/';

  static void _route(BuildContext context, String route) {
    if (_currentRoute != route) {
      Navigator.of(context).pushReplacementNamed(route);
      _currentRoute = route;
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            DrawerHeader(
              child: Text('Annic'),
            ),
            ListTile(
              title: Text('Home'),
              onTap: () => _route(context, '/'),
            )
          ],
        ),
      ),
    );
  }
}
