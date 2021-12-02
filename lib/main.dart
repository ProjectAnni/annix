import 'package:annix/app.dart';
import 'package:annix/services/global.dart';
import 'package:annix/services/window.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AnnilWindow.init();

  await Global.init();
  runApp(Annix());
}
