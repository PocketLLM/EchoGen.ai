import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

import '../models/tts_models.dart';
import 'logger.dart';

/// Comprehensive progress tracking system with time estimation and cancellation
class ProgressTracker {
  final Function(double progress, String status) _onProgress;
  final Function(UserFriendlyError error)? _onError;
  final Function(Duration? estimatedTimeRemaining)? _onTimeUpdate;
  
  double _currentProgress = 0.0;
  String _currentStatus = '';
  DateTime? _startTime;
  Duration? _estimatedTimeRemaining;
  final List<ProgressPhase> _phases = [];
  int _currentPhaseIndex = 0;
  bool _isCompleted = false;
  bool _isCancelled = false;

  ProgressTracker({
    required Function(double progress, String status) onProgress,
    Function(UserFriendlyError error)? onError,
    Function(Duration? estimatedTimeRemaining)? onTimeUpdate,
  }) : _onProgress = onProgress, 
       _onError = onError,
       _onTimeUpdate = onTimeUpdate {
    _initializePhases();
  }

  /// Initialize the standard phases for podcast generation
  void _initializePhases() {
    _phases.addAll([
      ProgressPhase(
        name: 'Initialization',
        startProgress: 0.0,
        endProgress: 0.1,
        estimatedDuration: Duration(seconds: 2),
        statusMessages: [
          'Initializing podcast generation...',
          'Validating configuration...',
          'Preparing request...',
        ],
      ),
      ProgressPhase(
        name: 'API Request',
        startProgress: 0.1,
        endProgress: 0.4,
        estimatedDuration: Duration(seconds: 5),
        statusMessages: [
          'Sending request to Gemini TTS...',
          'Waiting for AI voice generation...',
          'Processing multi-speaker configuration...',
        ],
      ),
      ProgressPhase(
        name: 'Audio Generation',
        startProgress: 0.4,
        endProgress: 0.8,
        estimatedDuration: Duration(seconds: 30),
        statusMessages: [
          'Generating AI voices...',
          'Processing speech synthesis...',
          'Applying voice characteristics...',
          'Finalizing audio quality...',
        ],
      ),
      ProgressPhase(
        name: 'Audio Processing',
        startProgress: 0.8,
        endProgress: 0.95,
        estimatedDuration: Duration(seconds: 8),
        statusMessages: [
          'Processing audio data...',
          'Converting to WAV format...',
          'Embedding metadata...',
          'Validating audio quality...',
        ],
      ),
      ProgressPhase(
        name: 'Finalization',
        startProgress: 0.95,
        endProgress: 1.0,
        estimatedDuration: Duration(seconds: 3),
        statusMessages: [
          'Saving podcast file...',
          'Finalizing generation...',
          'Ready to play!',
        ],
      ),
    ]);
  }

  /// Start tracking progress
  void start() {
    _startTime = DateTime.now();
    _isCompleted = false;
    _isCancelled = false;
    _currentPhaseIndex = 0;
    
    Logger.info('Progress tracking started', tag: 'ProgressTracker');
    updateProgress(0.0, 'Starting podcast generation...');
  }

  /// Update progress with automatic phase management
  void updateProgress(double progress, String? customStatus) {
    if (_isCancelled || _isCompleted) return;
    
    _currentProgress = progress.clamp(0.0, 1.0);
    
    // Update current phase based on progress
    _updateCurrentPhase();
    
    // Use custom status or generate from current phase
    _currentStatus = customStatus ?? _getCurrentPhaseStatus();
    
    // Update time estimation
    _updateEstimatedTime();
    
    // Notify listeners
    _onProgress(_currentProgress, _currentStatus);
    _onTimeUpdate?.call(_estimatedTimeRemaining);
    
    Logger.progress(_currentProgress, _currentStatus);
  }

  /// Update progress for a specific phase
  void updatePhaseProgress(String phaseName, double phaseProgress, {String? status}) {
    final phase = _phases.firstWhere(
      (p) => p.name == phaseName,
      orElse: () => _phases[_currentPhaseIndex],
    );
    
    final overallProgress = phase.startProgress + 
        (phase.endProgress - phase.startProgress) * phaseProgress.clamp(0.0, 1.0);
    
    updateProgress(overallProgress, status);
  }

  /// Set estimated time remaining manually
  void setEstimatedTimeRemaining(Duration timeRemaining) {
    _estimatedTimeRemaining = timeRemaining;
    _onTimeUpdate?.call(_estimatedTimeRemaining);
  }

  /// Report an error
  void reportError(UserFriendlyError error) {
    Logger.error('Progress tracker reporting error: ${error.title}', tag: 'ProgressTracker');
    _onError?.call(error);
  }

  /// Mark as completed
  void complete([String? finalStatus]) {
    if (_isCancelled) return;
    
    _isCompleted = true;
    _currentProgress = 1.0;
    _currentStatus = finalStatus ?? 'Podcast generation completed!';
    _estimatedTimeRemaining = Duration.zero;
    
    _onProgress(_currentProgress, _currentStatus);
    _onTimeUpdate?.call(_estimatedTimeRemaining);
    
    final totalTime = _startTime != null ? DateTime.now().difference(_startTime!) : Duration.zero;
    Logger.success('Progress tracking completed in ${totalTime.inSeconds}s', tag: 'ProgressTracker');
  }

  /// Cancel the operation
  void cancel() {
    if (_isCompleted) return;
    
    _isCancelled = true;
    _currentStatus = 'Generation cancelled';
    
    Logger.info('Progress tracking cancelled', tag: 'ProgressTracker');
    _onProgress(_currentProgress, _currentStatus);
  }

  /// Get current progress information
  ProgressInfo get currentInfo => ProgressInfo(
    progress: _currentProgress,
    status: _currentStatus,
    estimatedTimeRemaining: _estimatedTimeRemaining,
    elapsedTime: _startTime != null ? DateTime.now().difference(_startTime!) : null,
    currentPhase: _currentPhaseIndex < _phases.length ? _phases[_currentPhaseIndex].name : 'Unknown',
    isCompleted: _isCompleted,
    isCancelled: _isCancelled,
  );

  /// Check if operation can be cancelled
  bool get canCancel => !_isCompleted && !_isCancelled;

  // Private helper methods

  void _updateCurrentPhase() {
    for (int i = 0; i < _phases.length; i++) {
      final phase = _phases[i];
      if (_currentProgress >= phase.startProgress && _currentProgress <= phase.endProgress) {
        if (i != _currentPhaseIndex) {
          _currentPhaseIndex = i;
          Logger.debug('Entered phase: ${phase.name}', tag: 'ProgressTracker');
        }
        break;
      }
    }
  }

  String _getCurrentPhaseStatus() {
    if (_currentPhaseIndex >= _phases.length) {
      return 'Completing...';
    }
    
    final phase = _phases[_currentPhaseIndex];
    final phaseProgress = (_currentProgress - phase.startProgress) / 
        (phase.endProgress - phase.startProgress);
    
    // Select status message based on phase progress
    final messageIndex = (phaseProgress * phase.statusMessages.length).floor()
        .clamp(0, phase.statusMessages.length - 1);
    
    return phase.statusMessages[messageIndex];
  }

  void _updateEstimatedTime() {
    if (_startTime == null || _currentProgress <= 0.05) return;
    
    final elapsed = DateTime.now().difference(_startTime!);
    
    // Method 1: Linear extrapolation
    final linearEstimate = _calculateLinearEstimate(elapsed);
    
    // Method 2: Phase-based estimate
    final phaseEstimate = _calculatePhaseBasedEstimate(elapsed);
    
    // Use the more conservative estimate
    final estimates = [linearEstimate, phaseEstimate].where((e) => e != null);
    if (estimates.isNotEmpty) {
      _estimatedTimeRemaining = estimates.reduce((a, b) => 
          a!.inMilliseconds > b!.inMilliseconds ? a : b);
      
      // Cap the estimate at a reasonable maximum
      if (_estimatedTimeRemaining!.inMinutes > 10) {
        _estimatedTimeRemaining = Duration(minutes: 10);
      }
    }
  }

  Duration? _calculateLinearEstimate(Duration elapsed) {
    if (_currentProgress <= 0.1) return null;
    
    final totalEstimated = elapsed.inMilliseconds / _currentProgress;
    final remaining = totalEstimated - elapsed.inMilliseconds;
    
    return remaining > 0 ? Duration(milliseconds: remaining.round()) : Duration.zero;
  }

  Duration? _calculatePhaseBasedEstimate(Duration elapsed) {
    if (_currentPhaseIndex >= _phases.length) return Duration.zero;
    
    Duration totalRemaining = Duration.zero;
    
    // Add remaining time for current phase
    final currentPhase = _phases[_currentPhaseIndex];
    final phaseProgress = (_currentProgress - currentPhase.startProgress) / 
        (currentPhase.endProgress - currentPhase.startProgress);
    final phaseRemaining = currentPhase.estimatedDuration * (1 - phaseProgress);
    totalRemaining += phaseRemaining;
    
    // Add time for remaining phases
    for (int i = _currentPhaseIndex + 1; i < _phases.length; i++) {
      totalRemaining += _phases[i].estimatedDuration;
    }
    
    return totalRemaining;
  }
}

/// Represents a phase in the progress tracking
class ProgressPhase {
  final String name;
  final double startProgress;
  final double endProgress;
  final Duration estimatedDuration;
  final List<String> statusMessages;

  const ProgressPhase({
    required this.name,
    required this.startProgress,
    required this.endProgress,
    required this.estimatedDuration,
    required this.statusMessages,
  });

  @override
  String toString() => 'ProgressPhase($name: ${(startProgress * 100).toInt()}%-${(endProgress * 100).toInt()}%)';
}

/// Current progress information
class ProgressInfo {
  final double progress;
  final String status;
  final Duration? estimatedTimeRemaining;
  final Duration? elapsedTime;
  final String currentPhase;
  final bool isCompleted;
  final bool isCancelled;

  const ProgressInfo({
    required this.progress,
    required this.status,
    this.estimatedTimeRemaining,
    this.elapsedTime,
    required this.currentPhase,
    required this.isCompleted,
    required this.isCancelled,
  });

  /// Get progress as percentage
  int get progressPercentage => (progress * 100).round();

  /// Get formatted time remaining
  String get formattedTimeRemaining {
    if (estimatedTimeRemaining == null) return 'Calculating...';
    if (estimatedTimeRemaining!.inSeconds < 1) return 'Almost done';
    
    final minutes = estimatedTimeRemaining!.inMinutes;
    final seconds = estimatedTimeRemaining!.inSeconds % 60;
    
    if (minutes > 0) {
      return '${minutes}m ${seconds}s remaining';
    } else {
      return '${seconds}s remaining';
    }
  }

  /// Get formatted elapsed time
  String get formattedElapsedTime {
    if (elapsedTime == null) return '';
    
    final minutes = elapsedTime!.inMinutes;
    final seconds = elapsedTime!.inSeconds % 60;
    
    if (minutes > 0) {
      return '${minutes}m ${seconds}s elapsed';
    } else {
      return '${seconds}s elapsed';
    }
  }

  @override
  String toString() => 'ProgressInfo($progressPercentage%: $status, $currentPhase)';
}

/// Factory for creating progress trackers with common configurations
class ProgressTrackerFactory {
  /// Create a progress tracker for podcast generation
  static ProgressTracker createForPodcastGeneration({
    required Function(double progress, String status) onProgress,
    Function(UserFriendlyError error)? onError,
    Function(Duration? estimatedTimeRemaining)? onTimeUpdate,
  }) {
    return ProgressTracker(
      onProgress: onProgress,
      onError: onError,
      onTimeUpdate: onTimeUpdate,
    );
  }

  /// Create a progress tracker for voice preview
  static ProgressTracker createForVoicePreview({
    required Function(double progress, String status) onProgress,
    Function(UserFriendlyError error)? onError,
  }) {
    final tracker = ProgressTracker(
      onProgress: onProgress,
      onError: onError,
    );
    
    // Override phases for voice preview (simpler and faster)
    tracker._phases.clear();
    tracker._phases.addAll([
      ProgressPhase(
        name: 'Preparation',
        startProgress: 0.0,
        endProgress: 0.2,
        estimatedDuration: Duration(seconds: 1),
        statusMessages: ['Preparing voice preview...'],
      ),
      ProgressPhase(
        name: 'Generation',
        startProgress: 0.2,
        endProgress: 0.8,
        estimatedDuration: Duration(seconds: 5),
        statusMessages: [
          'Generating voice sample...',
          'Processing audio...',
        ],
      ),
      ProgressPhase(
        name: 'Completion',
        startProgress: 0.8,
        endProgress: 1.0,
        estimatedDuration: Duration(seconds: 1),
        statusMessages: ['Voice preview ready!'],
      ),
    ]);
    
    return tracker;
  }
}