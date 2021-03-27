import 'package:annix/app.dart';
import 'package:annix/services/global.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Global.init().then((_) => runApp(Annix()));
}
