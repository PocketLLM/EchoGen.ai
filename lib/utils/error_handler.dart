import 'package:flutter/foundation.dart';
import '../models/tts_models.dart';

/// Comprehensive error handling system for TTS operations
class ErrorHandler {
  static const Map<TTSErrorType, ErrorTemplate> _errorTemplates = {
    TTSErrorType.invalidApiKey: ErrorTemplate(
      title: "API Key Required",
      message: "Your Gemini API key is missing or invalid. Please configure it in Settings to generate podcasts.",
      actions: [
        RecoveryAction.openSettings,
        RecoveryAction.viewApiKeyGuide,
      ],
      severity: ErrorSeverity.warning,
    ),
    TTSErrorType.networkError: ErrorTemplate(
      title: "Connection Problem",
      message: "Unable to connect to the TTS service. Please check your internet connection and try again.",
      actions: [
        RecoveryAction.retry,
        RecoveryAction.checkConnection,
      ],
      severity: ErrorSeverity.error,
    ),
    TTSErrorType.timeout: ErrorTemplate(
      title: "Request Timeout",
      message: "The generation request took too long to complete. This might be due to a long script or network issues.",
      actions: [
        RecoveryAction.retry,
        RecoveryAction.editScript,
        RecoveryAction.checkConnection,
      ],
      severity: ErrorSeverity.error,
    ),
    TTSErrorType.rateLimited: ErrorTemplate(
      title: "Rate Limited",
      message: "You've made too many requests recently. Please wait a moment before trying again.",
      actions: [
        RecoveryAction.retry,
      ],
      severity: ErrorSeverity.warning,
    ),
    TTSErrorType.serverError: ErrorTemplate(
      title: "Server Error",
      message: "The TTS service is experiencing issues. Please try again in a few minutes.",
      actions: [
        RecoveryAction.retry,
        RecoveryAction.contactSupport,
      ],
      severity: ErrorSeverity.error,
    ),
    TTSErrorType.invalidInput: ErrorTemplate(
      title: "Invalid Script",
      message: "There's an issue with your script. Please check that it's not empty and within the character limit.",
      actions: [
        RecoveryAction.editScript,
      ],
      severity: ErrorSeverity.warning,
    ),
    TTSErrorType.invalidVoice: ErrorTemplate(
      title: "Voice Not Available",
      message: "The selected voice is not available. Please choose a different voice and try again.",
      actions: [
        RecoveryAction.selectVoice,
        RecoveryAction.retry,
      ],
      severity: ErrorSeverity.warning,
    ),
    TTSErrorType.audioProcessing: ErrorTemplate(
      title: "Audio Processing Error",
      message: "There was an error processing the generated audio. Please try generating again.",
      actions: [
        RecoveryAction.retry,
        RecoveryAction.contactSupport,
      ],
      severity: ErrorSeverity.error,
    ),
    TTSErrorType.unknown: ErrorTemplate(
      title: "Unexpected Error",
      message: "An unexpected error occurred. Please try again or contact support if the problem persists.",
      actions: [
        RecoveryAction.retry,
        RecoveryAction.contactSupport,
      ],
      severity: ErrorSeverity.critical,
    ),
  };

  /// Process any exception and convert it to a user-friendly error
  static UserFriendlyError processError(Exception error, ErrorContext context) {
    _logError(error, context);

    if (error is TTSException) {
      return _processTTSException(error, context);
    }

    // Handle common Flutter/Dart exceptions
    if (error.toString().contains('SocketException') || 
        error.toString().contains('NetworkException')) {
      return _createUserFriendlyError(
        TTSErrorType.networkError,
        technicalDetails: error.toString(),
      );
    }

    if (error.toString().contains('TimeoutException')) {
      return _createUserFriendlyError(
        TTSErrorType.timeout,
        technicalDetails: error.toString(),
      );
    }

    if (error.toString().contains('FormatException') ||
        error.toString().contains('ArgumentError')) {
      return _createUserFriendlyError(
        TTSErrorType.invalidInput,
        technicalDetails: error.toString(),
      );
    }

    // Default to unknown error
    return _createUserFriendlyError(
      TTSErrorType.unknown,
      technicalDetails: error.toString(),
    );
  }

  /// Get recovery actions for a specific error type
  static List<RecoveryAction> getRecoveryActions(TTSErrorType errorType) {
    return _errorTemplates[errorType]?.actions ?? [RecoveryAction.retry];
  }

  /// Log error with context for debugging
  static void logError(
    Exception error, 
    StackTrace? stackTrace, 
    Map<String, dynamic> context,
  ) {
    if (kDebugMode) {
      print('🚨 [ErrorHandler] Error logged:');
      print('   Error: $error');
      print('   Context: $context');
      if (stackTrace != null) {
        print('   Stack trace: $stackTrace');
      }
    }
  }

  /// Check if an error type should trigger automatic retry
  static bool shouldAutoRetry(TTSErrorType errorType) {
    switch (errorType) {
      case TTSErrorType.networkError:
      case TTSErrorType.timeout:
      case TTSErrorType.serverError:
        return true;
      case TTSErrorType.rateLimited:
        return true; // With delay
      case TTSErrorType.invalidApiKey:
      case TTSErrorType.invalidInput:
      case TTSErrorType.invalidVoice:
      case TTSErrorType.audioProcessing:
      case TTSErrorType.unknown:
        return false;
    }
  }

  /// Get suggested retry delay for error type
  static Duration getRetryDelay(TTSErrorType errorType, int attemptNumber) {
    switch (errorType) {
      case TTSErrorType.rateLimited:
        return Duration(seconds: 30 + (attemptNumber * 15)); // Longer delay for rate limits
      case TTSErrorType.networkError:
      case TTSErrorType.timeout:
      case TTSErrorType.serverError:
        return Duration(seconds: 2 * attemptNumber); // Exponential backoff
      default:
        return Duration(seconds: attemptNumber);
    }
  }

  // Private helper methods

  static UserFriendlyError _processTTSException(TTSException exception, ErrorContext context) {
    final template = _errorTemplates[exception.type];
    
    return UserFriendlyError(
      title: template?.title ?? 'Error',
      message: exception.userMessage.isNotEmpty 
          ? exception.userMessage 
          : template?.message ?? 'An error occurred',
      recoveryActions: exception.recoveryActions.isNotEmpty 
          ? exception.recoveryActions 
          : template?.actions ?? [RecoveryAction.retry],
      severity: template?.severity ?? ErrorSeverity.error,
      technicalDetails: exception.technicalDetails ?? exception.message,
    );
  }

  static UserFriendlyError _createUserFriendlyError(
    TTSErrorType errorType, {
    String? technicalDetails,
  }) {
    final template = _errorTemplates[errorType]!;
    
    return UserFriendlyError(
      title: template.title,
      message: template.message,
      recoveryActions: template.actions,
      severity: template.severity,
      technicalDetails: technicalDetails,
    );
  }

  static void _logError(Exception error, ErrorContext context) {
    if (kDebugMode) {
      print('🚨 [ErrorHandler] Processing error:');
      print('   Type: ${error.runtimeType}');
      print('   Message: $error');
      print('   Context: ${context.operation} (${context.additionalInfo})');
    }
  }
}

/// Template for error messages and recovery actions
class ErrorTemplate {
  final String title;
  final String message;
  final List<RecoveryAction> actions;
  final ErrorSeverity severity;

  const ErrorTemplate({
    required this.title,
    required this.message,
    required this.actions,
    required this.severity,
  });
}

/// Context information for error processing
class ErrorContext {
  final String operation;
  final Map<String, dynamic> additionalInfo;

  const ErrorContext({
    required this.operation,
    this.additionalInfo = const {},
  });

  @override
  String toString() => 'ErrorContext($operation: $additionalInfo)';
}

/// Progress tracking system for user feedback
class ProgressTracker {
  final Function(double progress, String status) _onProgress;
  final Function(UserFriendlyError error)? _onError;
  
  double _currentProgress = 0.0;
  String _currentStatus = '';
  DateTime? _startTime;
  Duration? _estimatedTimeRemaining;

  ProgressTracker({
    required Function(double progress, String status) onProgress,
    Function(UserFriendlyError error)? onError,
  }) : _onProgress = onProgress, _onError = onError;

  /// Update progress with status message
  void updateProgress(double progress, String status) {
    _currentProgress = progress.clamp(0.0, 1.0);
    _currentStatus = status;
    
    _startTime ??= DateTime.now();
    _updateEstimatedTime();
    
    _onProgress(_currentProgress, _currentStatus);
    
    if (kDebugMode) {
      print('📊 [ProgressTracker] ${(_currentProgress * 100).toInt()}% - $status');
    }
  }

  /// Set estimated time remaining
  void setEstimatedTimeRemaining(Duration timeRemaining) {
    _estimatedTimeRemaining = timeRemaining;
  }

  /// Report an error through the progress system
  void reportError(UserFriendlyError error) {
    _onError?.call(error);
    
    if (kDebugMode) {
      print('🚨 [ProgressTracker] Error reported: ${error.title}');
    }
  }

  /// Mark operation as completed
  void complete(String finalStatus) {
    updateProgress(1.0, finalStatus);
  }

  /// Get current progress information
  ProgressInfo get currentInfo => ProgressInfo(
    progress: _currentProgress,
    status: _currentStatus,
    estimatedTimeRemaining: _estimatedTimeRemaining,
    elapsedTime: _startTime != null ? DateTime.now().difference(_startTime!) : null,
  );

  void _updateEstimatedTime() {
    if (_startTime != null && _currentProgress > 0.1) {
      final elapsed = DateTime.now().difference(_startTime!);
      final totalEstimated = elapsed.inMilliseconds / _currentProgress;
      final remaining = totalEstimated - elapsed.inMilliseconds;
      
      if (remaining > 0) {
        _estimatedTimeRemaining = Duration(milliseconds: remaining.round());
      }
    }
  }
}

/// Current progress information
class ProgressInfo {
  final double progress;
  final String status;
  final Duration? estimatedTimeRemaining;
  final Duration? elapsedTime;

  const ProgressInfo({
    required this.progress,
    required this.status,
    this.estimatedTimeRemaining,
    this.elapsedTime,
  });

  @override
  String toString() => 'ProgressInfo(${(progress * 100).toInt()}%: $status)';
}