import 'package:annix/native/api/logging.dart';
import 'package:annix/services/path.dart';
import 'package:flutter/foundation.dart';

class Logger {
  static bool initialized = false;

  static void init() {
    initLogger(path: logPath());
    initialized = true;
  }

  static void error(
    String message, {
    String? className,
    String? methodName,
    Object? exception,
    StackTrace? stacktrace,
  }) {
    _log(
      'ERROR',
      message,
      className: className,
      methodName: methodName,
      exception: exception,
      stacktrace: stacktrace,
    );
  }

  static void warn(
    String message, {
    String? className,
    String? methodName,
    Object? exception,
    StackTrace? stacktrace,
  }) {
    _log(
      'WARN',
      message,
      className: className,
      methodName: methodName,
      exception: exception,
      stacktrace: stacktrace,
    );
  }

  static void info(String message) {
    _log('INFO', message);
  }

  static void debug(String message) {
    _log('DEBUG', message);
  }

  static void trace(String message) {
    _log('TRACE', message);
  }

  static _log(
    String level,
    String message, {
    String? className,
    String? methodName,
    Object? exception,
    StackTrace? stacktrace,
  }) {
    if (exception is Error && stacktrace == null) {
      stacktrace = exception.stackTrace;
    }

    if (kDebugMode) {
      debugPrint('[$level]: $message');
      if (className != null) {
        debugPrint('Class: $className');
      }
      if (methodName != null) {
        debugPrint('Method: $methodName');
      }
      if (exception != null) {
        debugPrint('Exception: $exception');
      }
      if (stacktrace != null) {
        debugPrint('Stacktrace: $stacktrace');
      }
    }

    if (initialized) {
      logNative(
        level: level,
        message: message,
        file: className,
        module: methodName,
        exception: exception.toString(),
        stacktace: stacktrace.toString(),
      );
    }
  }
}
