import 'package:flutter/foundation.dart';

/// Simple logger utility for debugging
class AppLogger {
  static const String _tag = 'Miilto';

  /// Log debug message
  static void debug(String message, {String? tag}) {
    if (kDebugMode) {
      print('[$_tag${tag != null ? ':$tag' : ''}] DEBUG: $message');
    }
  }

  /// Log info message
  static void info(String message, {String? tag}) {
    if (kDebugMode) {
      print('[$_tag${tag != null ? ':$tag' : ''}] INFO: $message');
    }
  }

  /// Log warning message
  static void warning(String message, {String? tag}) {
    if (kDebugMode) {
      print('[$_tag${tag != null ? ':$tag' : ''}] WARNING: $message');
    }
  }

  /// Log error message with optional exception and stack trace
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      print('[$_tag${tag != null ? ':$tag' : ''}] ERROR: $message');
      if (error != null) {
        print('[$_tag${tag != null ? ':$tag' : ''}] Exception: $error');
      }
      if (stackTrace != null) {
        print('[$_tag${tag != null ? ':$tag' : ''}] StackTrace: $stackTrace');
      }
    }
  }
}
