import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Lightweight logging utility that surfaces structured debugging output
/// without polluting release builds.
class DebugLogger {
  const DebugLogger._();

  /// Emit a debug level log with an optional [category] label.
  static void log(
    String message, {
    String category = 'EchoGen',
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kDebugMode) {
      developer.log(
        message,
        name: category,
        error: error,
        stackTrace: stackTrace,
      );
    } else if (error != null) {
      debugPrint('[$category] $message: $error');
    }
  }
}
