import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

import '../models/tts_models.dart';
import 'logger.dart';

/// Advanced retry handler with exponential backoff and cancellation support
class RetryHandler {
  static const Duration _baseDelay = Duration(seconds: 1);
  static const Duration _maxDelay = Duration(minutes: 2);
  static const double _backoffMultiplier = 2.0;
  static const double _jitterFactor = 0.1;

  /// Execute a function with retry logic and exponential backoff
  static Future<T> executeWithRetry<T>({
    required Future<T> Function() operation,
    required int maxRetries,
    required bool Function(Exception) shouldRetry,
    Function(int attempt, Duration delay)? onRetry,
    Function(double progress, String status)? onProgress,
    Completer<void>? cancellationToken,
  }) async {
    Exception? lastException;
    
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        // Check for cancellation
        if (cancellationToken?.isCompleted == true) {
          throw TTSException(
            type: TTSErrorType.unknown,
            message: 'Operation was cancelled',
            userMessage: 'The operation was cancelled by the user.',
            recoveryActions: [],
          );
        }

        Logger.debug('Executing attempt $attempt/$maxRetries');
        
        final result = await operation();
        
        if (attempt > 1) {
          Logger.success('Operation succeeded on attempt $attempt');
        }
        
        return result;
      } catch (e) {
        Logger.warning('Attempt $attempt failed: $e');
        
        Exception exception;
        if (e is Exception) {
          exception = e;
        } else {
          exception = Exception('Unexpected error: $e');
        }
        
        lastException = exception;
        
        // Don't retry if we shouldn't or if this is the last attempt
        if (!shouldRetry(exception) || attempt == maxRetries) {
          break;
        }
        
        // Calculate delay with exponential backoff and jitter
        final delay = _calculateDelay(attempt);
        
        Logger.info('Retrying in ${delay.inSeconds}s (attempt ${attempt + 1}/$maxRetries)');
        
        // Notify about retry
        onRetry?.call(attempt, delay);
        onProgress?.call(
          0.2 + (attempt / maxRetries) * 0.1, 
          'Retrying in ${delay.inSeconds}s (attempt ${attempt + 1}/$maxRetries)...'
        );
        
        // Wait with cancellation support
        await _delayWithCancellation(delay, cancellationToken);
      }
    }
    
    // All retries failed
    Logger.error('All $maxRetries attempts failed');
    throw lastException ?? Exception('All retry attempts failed');
  }

  /// Calculate delay with exponential backoff and jitter
  static Duration _calculateDelay(int attemptNumber) {
    // Exponential backoff: baseDelay * (multiplier ^ (attempt - 1))
    final exponentialDelay = _baseDelay.inMilliseconds * 
        pow(_backoffMultiplier, attemptNumber - 1);
    
    // Add jitter to prevent thundering herd
    final jitter = exponentialDelay * _jitterFactor * (Random().nextDouble() - 0.5);
    final totalDelay = exponentialDelay + jitter;
    
    // Cap at maximum delay
    final cappedDelay = Duration(
      milliseconds: min(totalDelay.round(), _maxDelay.inMilliseconds)
    );
    
    return cappedDelay;
  }

  /// Delay with cancellation support
  static Future<void> _delayWithCancellation(
    Duration delay, 
    Completer<void>? cancellationToken,
  ) async {
    if (cancellationToken == null) {
      await Future.delayed(delay);
      return;
    }

    final delayCompleter = Completer<void>();
    final timer = Timer(delay, () {
      if (!delayCompleter.isCompleted) {
        delayCompleter.complete();
      }
    });

    try {
      await Future.any([
        delayCompleter.future,
        cancellationToken.future,
      ]);
    } finally {
      timer.cancel();
    }

    if (cancellationToken.isCompleted) {
      throw TTSException(
        type: TTSErrorType.unknown,
        message: 'Operation was cancelled during retry delay',
        userMessage: 'The operation was cancelled.',
        recoveryActions: [],
      );
    }
  }

  /// Determine if an error should trigger a retry
  static bool shouldRetryError(Exception error) {
    if (error is TTSException) {
      switch (error.type) {
        case TTSErrorType.networkError:
        case TTSErrorType.timeout:
        case TTSErrorType.serverError:
          return true;
        case TTSErrorType.rateLimited:
          return true; // With longer delay
        case TTSErrorType.invalidApiKey:
        case TTSErrorType.invalidInput:
        case TTSErrorType.invalidVoice:
        case TTSErrorType.audioProcessing:
        case TTSErrorType.unknown:
          return false;
      }
    }

    // Check for common network errors
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('socket') ||
        errorString.contains('network') ||
        errorString.contains('timeout') ||
        errorString.contains('connection')) {
      return true;
    }

    return false;
  }

  /// Get appropriate delay for specific error types
  static Duration getDelayForError(Exception error, int attemptNumber) {
    if (error is TTSException && error.type == TTSErrorType.rateLimited) {
      // Longer delay for rate limiting
      return Duration(seconds: 30 + (attemptNumber * 15));
    }
    
    return _calculateDelay(attemptNumber);
  }
}

/// Cancellation token for operations
class CancellationToken {
  final Completer<void> _completer = Completer<void>();
  bool _isCancelled = false;

  /// Cancel the operation
  void cancel() {
    if (!_isCancelled) {
      _isCancelled = true;
      _completer.complete();
      Logger.info('Operation cancelled by user');
    }
  }

  /// Check if cancelled
  bool get isCancelled => _isCancelled;

  /// Get the future that completes when cancelled
  Future<void> get future => _completer.future;

  /// Throw if cancelled
  void throwIfCancelled() {
    if (_isCancelled) {
      throw TTSException(
        type: TTSErrorType.unknown,
        message: 'Operation was cancelled',
        userMessage: 'The operation was cancelled.',
        recoveryActions: [],
      );
    }
  }
}

/// Timeout handler with cancellation support
class TimeoutHandler {
  /// Execute operation with timeout and cancellation
  static Future<T> executeWithTimeout<T>({
    required Future<T> Function() operation,
    required Duration timeout,
    CancellationToken? cancellationToken,
    String? operationName,
  }) async {
    final timeoutCompleter = Completer<T>();
    final operationCompleter = Completer<T>();
    
    // Start the operation
    operation().then((result) {
      if (!operationCompleter.isCompleted) {
        operationCompleter.complete(result);
      }
    }).catchError((error) {
      if (!operationCompleter.isCompleted) {
        operationCompleter.completeError(error);
      }
    });

    // Set up timeout
    final timer = Timer(timeout, () {
      if (!timeoutCompleter.isCompleted) {
        final name = operationName ?? 'Operation';
        timeoutCompleter.completeError(
          TTSException(
            type: TTSErrorType.timeout,
            message: '$name timed out after ${timeout.inMinutes} minutes',
            userMessage: 'The operation took too long to complete. Please try again.',
            recoveryActions: [RecoveryAction.retry, RecoveryAction.editScript],
          ),
        );
      }
    });

    try {
      final futures = <Future<T>>[
        operationCompleter.future,
        timeoutCompleter.future,
      ];

      // Add cancellation if provided
      if (cancellationToken != null) {
        futures.add(cancellationToken.future.then<T>((_) {
          throw TTSException(
            type: TTSErrorType.unknown,
            message: 'Operation was cancelled',
            userMessage: 'The operation was cancelled.',
            recoveryActions: [],
          );
        }));
      }

      return await Future.any(futures);
    } finally {
      timer.cancel();
    }
  }
}