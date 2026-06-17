import 'package:flutter/foundation.dart';

/// Lightweight logging utility for tracking and error diagnostics.
class AppLogger {
  AppLogger._();

  static void info(String message) {
    if (kDebugMode) debugPrint('[TRACKING] $message');
  }

  static void warn(String message) {
    if (kDebugMode) debugPrint('[TRACKING WARNING] $message');
  }

  static void error(String message, [Object? error]) {
    if (kDebugMode) {
      debugPrint('[TRACKING ERROR] $message');
      if (error != null) debugPrint(error.toString());
    }
  }
}
