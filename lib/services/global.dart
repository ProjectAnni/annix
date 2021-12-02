import 'package:annix/services/annil.dart';
import 'package:annix/services/audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Global {
  static late SharedPreferences _preferences;

  static late AnnilClient annil;
  static late AnniAudioService audioService;

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();

    annil = AnnilClient(
      // TODO: let user input annil config
      baseUrl: 'http://localhost:3614',
      authorization:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjAsInR5cGUiOiJ1c2VyIiwidXNlcm5hbWUiOiJ0ZXN0IiwiYWxsb3dTaGFyZSI6dHJ1ZX0.7CH27OBvUnJhKxBdtZbJSXA-JIwQ4MWqI5JsZ46NoKk',
    );

    audioService = AnniAudioService();
    await audioService.init();
  }
}
