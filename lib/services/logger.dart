import 'package:annix/native/api/logging.dart';

class Logger {
  static void error(String message) {
    logNative(level: 'ERROR', message: message);
  }

  static void info(String message) {
    logNative(level: 'INFO', message: message);
  }

  static void debug(String message) {
    logNative(level: 'DEBUG', message: message);
  }

  static void trace(String message) {
    logNative(level: 'TRACE', message: message);
  }
}
