import 'package:flutter/foundation.dart';

class AppLogger {
  static const String _tag = "FOOD_RECOGNIZER";
  static bool _enableLogging = true;

  static set enableLogging(bool value) {
    _enableLogging = value;
  }

  static void d(String message) {
    if (_enableLogging && kDebugMode) {
      debugPrint('[$_tag][DEBUG] $message');
    }
  }

  static void i(String message) {
    if (_enableLogging && kDebugMode) {
      debugPrint('[$_tag][INFO] $message');
    }
  }

  static void e(String message, [Object? error, StackTrace? stackTrace]) {
    if (_enableLogging && kDebugMode) {
      debugPrint('[$_tag][ERROR] $message');
      if (error != null) debugPrint('Error: $error');
      if (stackTrace != null) debugPrint('StackTrace: $stackTrace');
    }
  }

  static void w(String message) {
    if (_enableLogging && kDebugMode) {
      debugPrint('[$_tag][WARN] $message');
    }
  }
}
