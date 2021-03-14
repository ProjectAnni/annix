import 'package:annic/pages/home.dart';
import 'package:annic/pages/login.dart';
import 'package:flutter/material.dart';

class Annic extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Annic',
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
