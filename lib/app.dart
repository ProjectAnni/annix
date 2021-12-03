import 'package:annix/pages/home.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

class Annix extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Annix',
      theme: ThemeData(
        // primarySwatch: Colors.teal,
        brightness: Brightness.dark,
      ),
      home: WindowBorder(
        color: Color(0xFF805306),
        width: 4,
        child: HomePage(),
      ),
    );
  }
}
