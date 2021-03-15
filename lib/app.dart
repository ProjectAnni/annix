import 'package:annix/pages/home.dart';
import 'package:annix/pages/login.dart';
import 'package:flutter/material.dart';

class Annix extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Annix',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        // brightness: Brightness.dark,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/new_server': (context) => LoginPage(),
      },
    );
  }
}
