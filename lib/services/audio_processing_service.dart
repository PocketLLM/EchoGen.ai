import 'dart:io';
import 'dart:typed_data';

import '../models/tts_models.dart';
import '../utils/logger.dart';
import 'audio_validation_service.dart';

/// Lightweight audio processing service for podcast generation
/// Focuses on essential functionality without external dependencies
class AudioProcessingService {
  static const String _tag = 'AudioProcessingService';

  /// Validate and get basic information about an audio file
  /// This replaces the FFmpeg-based conversion with validation-only approach
  Future<AudioConversionResult> validateAudio({
    required String inputPath,
    required AudioFormat expectedFormat,
    Function(double progress)? onProgress,
    Function(String log)? onLog,
  }) async {
    Logger.info('Validating audio file: ${File(inputPath).path}', tag: _tag);

    try {
      // Validate input file exists
      final inputFile = File(inputPath);
      if (!await inputFile.exists()) {
        throw AudioProcessingException(
          message: 'Input file does not exist: $inputPath',
          userMessage: 'The audio file was not found.',
        );
      }

      // Report progress
      onProgress?.call(0.3);
      onLog?.call('Validating audio file format...');

      // Use our audio validation service
      final validationResult = await AudioValidationService.validateAudioFile(inputPath);

      onProgress?.call(0.7);

      if (!validationResult.isValid) {
        throw AudioProcessingException(
          message: 'Invalid audio file: ${validationResult.error}',
          userMessage: 'The audio file format is not supported or corrupted.',
        );
      }

      onProgress?.call(1.0);
      onLog?.call('Audio validation completed successfully');

      final fileSize = await inputFile.length();

      return AudioConversionResult(
        success: true,
        outputPath: inputPath, // Same as input since we're not converting
        fileSize: fileSize,
        format: expectedFormat,
        audioInfo: validationResult.audioInfo,
      );
    } catch (e) {
      Logger.error('Audio validation error: $e', tag: _tag);
      if (e is AudioProcessingException) {
        rethrow;
      }
      throw AudioProcessingException(
        message: 'Unexpected error during validation: $e',
        userMessage: 'An unexpected error occurred during audio validation.',
      );
    }
  }

  /// Copy audio file to a new location (replaces format conversion)
  /// Since we generate proper WAV files, conversion is usually not needed
  Future<AudioConversionResult> copyAudio({
    required String inputPath,
    required String outputPath,
    Function(double progress)? onProgress,
    Function(String log)? onLog,
  }) async {
    Logger.info('Copying audio file: $inputPath → $outputPath', tag: _tag);

    try {
      final inputFile = File(inputPath);
      if (!await inputFile.exists()) {
        throw AudioProcessingException(
          message: 'Input file does not exist: $inputPath',
          userMessage: 'The audio file to copy was not found.',
        );
      }

      onProgress?.call(0.1);
      onLog?.call('Starting file copy...');

      // Read and write file in chunks for progress tracking
      final inputBytes = await inputFile.readAsBytes();
      final outputFile = File(outputPath);

      onProgress?.call(0.5);
      onLog?.call('Writing output file...');

      await outputFile.writeAsBytes(inputBytes);

      onProgress?.call(1.0);
      onLog?.call('File copy completed');

      final fileSize = await outputFile.length();

      return AudioConversionResult(
        success: true,
        outputPath: outputPath,
        fileSize: fileSize,
        format: AudioFormat.wav, // Assume WAV since that's what we generate
      );
    } catch (e) {
      Logger.error('Audio copy error: $e', tag: _tag);
      throw AudioProcessingException(
        message: 'Failed to copy audio file: $e',
        userMessage: 'Failed to copy the audio file.',
      );
    }
  }

  /// Get basic information about an audio file using our validation service
  Future<AudioFileInfo> getAudioInfo(String filePath) async {
    Logger.info('Getting audio info for: $filePath', tag: _tag);

    try {
      final validationResult = await AudioValidationService.validateAudioFile(filePath);

      if (!validationResult.isValid) {
        throw AudioProcessingException(
          message: 'Cannot get info for invalid audio file: ${validationResult.error}',
          userMessage: 'Unable to read audio file information.',
        );
      }

      final file = File(filePath);
      final fileSize = await file.length();

      return AudioFileInfo(
        filePath: filePath,
        fileSize: fileSize,
        format: validationResult.audioInfo?.format ?? 'Unknown',
        duration: validationResult.audioInfo?.duration ?? Duration.zero,
        sampleRate: validationResult.audioInfo?.sampleRate ?? 0,
        channels: validationResult.audioInfo?.channels ?? 0,
        bitrate: _estimateBitrate(
          fileSize,
          validationResult.audioInfo?.duration ?? Duration.zero
        ),
      );
    } catch (e) {
      Logger.error('Error getting audio info', error: e, tag: _tag);
      if (e is AudioProcessingException) rethrow;
      throw AudioProcessingException(
        message: 'Failed to get audio information: $e',
        userMessage: 'Unable to read audio file information.',
      );
    }
  }

  /// Estimate bitrate from file size and duration
  int _estimateBitrate(int fileSizeBytes, Duration duration) {
    if (duration.inSeconds == 0) return 0;

    // Convert to bits per second, then to kbps
    final bitsPerSecond = (fileSizeBytes * 8) / duration.inSeconds;
    return (bitsPerSecond / 1000).round();
  }

  /// Check if a file is a valid audio file
  Future<bool> isValidAudioFile(String filePath) async {
    try {
      final validationResult = await AudioValidationService.validateAudioFile(filePath);
      return validationResult.isValid;
    } catch (e) {
      Logger.warning('Error checking audio file validity: $e', tag: _tag);
      return false;
    }
  }

  /// Get supported audio formats (simplified list)
  List<AudioFormat> getSupportedFormats() {
    return [
      AudioFormat.wav,
      AudioFormat.mp3,
      // Note: Without FFmpeg, we primarily support WAV files
      // MP3 support is limited to playback only
    ];
  }

  /// Simple audio format detection based on file extension
  AudioFormat? detectAudioFormat(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    switch (extension) {
      case 'wav':
        return AudioFormat.wav;
      case 'mp3':
        return AudioFormat.mp3;
      case 'pcm':
        return AudioFormat.pcm;
      default:
        return null; // Unsupported format
    }
  }

  /// Cancel operations (placeholder for compatibility)
  Future<void> cancelAllSessions() async {
    Logger.info('Cancel requested - no active sessions to cancel', tag: _tag);
    // No-op since we don't have background sessions without FFmpeg
  }
}