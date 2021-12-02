import 'package:annix/app.dart';
import 'package:annix/services/global.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Global.init();
  runApp(Annix());
}
