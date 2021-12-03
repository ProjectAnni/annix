import 'package:annix/pages/home.dart';
import 'package:annix/pages/setup.dart';
import 'package:annix/services/global.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

class Annix extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var initialRoute = '/home_desktop';
    if (Global.needSetup) {
      initialRoute = '/setup';
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Annix',
      theme: ThemeData(
        // primarySwatch: Colors.teal,
        brightness: Brightness.dark,
      ),
      initialRoute: initialRoute,
      routes: {
        '/home_desktop': (context) => WindowBorder(
              color: Color(0xFF805306),
              width: 4,
              child: HomePage(),
            ),
        '/setup': (context) => AnnixSetup(),
      },
    );
  }
}
