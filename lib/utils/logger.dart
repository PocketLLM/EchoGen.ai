import 'package:flutter/foundation.dart';

/// Centralized logging utility for the Enhanced TTS Service
class Logger {
  static const String _prefix = '[EnhancedTTS]';
  static bool _isEnabled = kDebugMode;

  /// Enable or disable logging
  static void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Log info message
  static void info(String message, {String? tag}) {
    if (_isEnabled) {
      final tagStr = tag != null ? '[$tag]' : '';
      print('ℹ️ $_prefix$tagStr $message');
    }
  }

  /// Log debug message
  static void debug(String message, {String? tag}) {
    if (_isEnabled && kDebugMode) {
      final tagStr = tag != null ? '[$tag]' : '';
      print('🐛 $_prefix$tagStr $message');
    }
  }

  /// Log warning message
  static void warning(String message, {String? tag}) {
    if (_isEnabled) {
      final tagStr = tag != null ? '[$tag]' : '';
      print('⚠️ $_prefix$tagStr $message');
    }
  }

  /// Log error message
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (_isEnabled) {
      final tagStr = tag != null ? '[$tag]' : '';
      print('❌ $_prefix$tagStr $message');
      if (error != null) {
        print('   Error: $error');
      }
      if (stackTrace != null && kDebugMode) {
        print('   Stack trace: $stackTrace');
      }
    }
  }

  /// Log success message
  static void success(String message, {String? tag}) {
    if (_isEnabled) {
      final tagStr = tag != null ? '[$tag]' : '';
      print('✅ $_prefix$tagStr $message');
    }
  }

  /// Log API request
  static void apiRequest(String method, String url, {Map<String, dynamic>? body}) {
    if (_isEnabled) {
      print('📤 $_prefix[API] $method $url');
      if (body != null && kDebugMode) {
        print('   Body: ${body.toString().substring(0, body.toString().length > 200 ? 200 : body.toString().length)}...');
      }
    }
  }

  /// Log API response
  static void apiResponse(int statusCode, String url, {String? body}) {
    if (_isEnabled) {
      final statusEmoji = statusCode >= 200 && statusCode < 300 ? '✅' : '❌';
      print('📥 $_prefix[API] $statusEmoji $statusCode $url');
      if (body != null && kDebugMode) {
        final preview = body.length > 200 ? '${body.substring(0, 200)}...' : body;
        print('   Response: $preview');
      }
    }
  }

  /// Log progress update
  static void progress(double progress, String status) {
    if (_isEnabled) {
      final percentage = (progress * 100).toInt();
      print('📊 $_prefix[Progress] $percentage% - $status');
    }
  }

  /// Log performance metrics
  static void performance(String operation, Duration duration, {Map<String, dynamic>? metrics}) {
    if (_isEnabled) {
      print('⏱️ $_prefix[Performance] $operation completed in ${duration.inMilliseconds}ms');
      if (metrics != null) {
        metrics.forEach((key, value) {
          print('   $key: $value');
        });
      }
    }
  }

  /// Log file operation
  static void fileOperation(String operation, String path, {int? size}) {
    if (_isEnabled) {
      final sizeStr = size != null ? ' (${_formatFileSize(size)})' : '';
      print('📁 $_prefix[File] $operation: $path$sizeStr');
    }
  }

  /// Log voice information
  static void voice(String message, {String? voiceId}) {
    if (_isEnabled) {
      final voiceStr = voiceId != null ? '[$voiceId]' : '';
      print('🎭 $_prefix[Voice]$voiceStr $message');
    }
  }

  /// Log audio processing
  static void audio(String message, {Duration? duration, int? sampleRate}) {
    if (_isEnabled) {
      final details = <String>[];
      if (duration != null) details.add('${duration.inSeconds}s');
      if (sampleRate != null) details.add('${sampleRate}Hz');
      final detailStr = details.isNotEmpty ? ' (${details.join(', ')})' : '';
      print('🎵 $_prefix[Audio] $message$detailStr');
    }
  }

  /// Format file size for display
  static String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }
}

/// Mixin for classes that need logging capabilities
mixin LoggerMixin {
  void logInfo(String message, {String? tag}) => Logger.info(message, tag: tag ?? runtimeType.toString());
  void logDebug(String message, {String? tag}) => Logger.debug(message, tag: tag ?? runtimeType.toString());
  void logWarning(String message, {String? tag}) => Logger.warning(message, tag: tag ?? runtimeType.toString());
  void logError(String message, {String? tag, Object? error, StackTrace? stackTrace}) => 
      Logger.error(message, tag: tag ?? runtimeType.toString(), error: error, stackTrace: stackTrace);
  void logSuccess(String message, {String? tag}) => Logger.success(message, tag: tag ?? runtimeType.toString());
}