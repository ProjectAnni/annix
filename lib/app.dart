import 'package:annix/models/playlist.dart';
import 'package:annix/pages/home.dart';
import 'package:annix/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Annix extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ActivePlaylist()),
      ],
      child: MaterialApp(
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
      ),
    );
  }
}
