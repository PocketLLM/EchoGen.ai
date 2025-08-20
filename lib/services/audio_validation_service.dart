import 'dart:io';
import 'dart:typed_data';

/// Service for validating audio files and ensuring they are properly formatted
class AudioValidationService {
  
  /// Validates an audio file to ensure it's properly formatted and playable
  static Future<AudioValidationResult> validateAudioFile(String filePath) async {
    try {
      final file = File(filePath);
      
      // Check if file exists
      if (!await file.exists()) {
        return AudioValidationResult(
          isValid: false,
          error: 'File does not exist',
          details: 'Audio file not found at: $filePath',
        );
      }
      
      // Check file size
      final fileSize = await file.length();
      if (fileSize == 0) {
        return AudioValidationResult(
          isValid: false,
          error: 'Empty file',
          details: 'Audio file is empty (0 bytes)',
        );
      }
      
      // Validate based on file extension
      final extension = filePath.toLowerCase().split('.').last;
      switch (extension) {
        case 'wav':
          return await _validateWavFile(file, fileSize);
        case 'mp3':
          return await _validateMp3File(file, fileSize);
        default:
          return AudioValidationResult(
            isValid: true,
            warning: 'Unknown audio format: $extension',
            details: 'File exists but format validation not implemented for .$extension',
            fileSize: fileSize,
          );
      }
    } catch (e) {
      return AudioValidationResult(
        isValid: false,
        error: 'Validation failed',
        details: 'Error during validation: $e',
      );
    }
  }
  
  /// Validates a WAV file format
  static Future<AudioValidationResult> _validateWavFile(File file, int fileSize) async {
    try {
      final bytes = await file.readAsBytes();
      
      // Check minimum file size (WAV header is 44 bytes)
      if (bytes.length < 44) {
        return AudioValidationResult(
          isValid: false,
          error: 'Invalid WAV file',
          details: 'WAV file too small: ${bytes.length} bytes (minimum 44 bytes required)',
          fileSize: fileSize,
        );
      }
      
      // Check RIFF header
      final riffHeader = String.fromCharCodes(bytes.sublist(0, 4));
      if (riffHeader != 'RIFF') {
        return AudioValidationResult(
          isValid: false,
          error: 'Invalid WAV file',
          details: 'Invalid RIFF header: $riffHeader (expected: RIFF)',
          fileSize: fileSize,
        );
      }
      
      // Check WAVE format
      final waveFormat = String.fromCharCodes(bytes.sublist(8, 12));
      if (waveFormat != 'WAVE') {
        return AudioValidationResult(
          isValid: false,
          error: 'Invalid WAV file',
          details: 'Invalid WAVE format: $waveFormat (expected: WAVE)',
          fileSize: fileSize,
        );
      }
      
      // Check fmt chunk
      final fmtChunk = String.fromCharCodes(bytes.sublist(12, 16));
      if (fmtChunk != 'fmt ') {
        return AudioValidationResult(
          isValid: false,
          error: 'Invalid WAV file',
          details: 'Invalid fmt chunk: $fmtChunk (expected: fmt )',
          fileSize: fileSize,
        );
      }
      
      // Extract audio format information
      final audioFormat = _readUint16(bytes, 20);
      final channels = _readUint16(bytes, 22);
      final sampleRate = _readUint32(bytes, 24);
      final bitsPerSample = _readUint16(bytes, 34);
      
      // Validate audio format (1 = PCM)
      if (audioFormat != 1) {
        return AudioValidationResult(
          isValid: false,
          error: 'Unsupported WAV format',
          details: 'Audio format $audioFormat not supported (only PCM format 1 is supported)',
          fileSize: fileSize,
        );
      }
      
      return AudioValidationResult(
        isValid: true,
        details: 'Valid WAV file: ${channels} channel(s), ${sampleRate}Hz, ${bitsPerSample}-bit PCM',
        fileSize: fileSize,
        audioInfo: AudioInfo(
          format: 'WAV',
          channels: channels,
          sampleRate: sampleRate,
          bitsPerSample: bitsPerSample,
          duration: _calculateWavDuration(bytes, sampleRate, channels, bitsPerSample),
        ),
      );
    } catch (e) {
      return AudioValidationResult(
        isValid: false,
        error: 'WAV validation failed',
        details: 'Error validating WAV file: $e',
        fileSize: fileSize,
      );
    }
  }
  
  /// Validates an MP3 file format (basic validation)
  static Future<AudioValidationResult> _validateMp3File(File file, int fileSize) async {
    try {
      final bytes = await file.readAsBytes();
      
      // Check for MP3 header (ID3 tag or MP3 frame sync)
      if (bytes.length < 3) {
        return AudioValidationResult(
          isValid: false,
          error: 'Invalid MP3 file',
          details: 'MP3 file too small: ${bytes.length} bytes',
          fileSize: fileSize,
        );
      }
      
      // Check for ID3 tag
      final id3Header = String.fromCharCodes(bytes.sublist(0, 3));
      if (id3Header == 'ID3') {
        return AudioValidationResult(
          isValid: true,
          details: 'Valid MP3 file with ID3 tag',
          fileSize: fileSize,
          audioInfo: AudioInfo(format: 'MP3'),
        );
      }
      
      // Check for MP3 frame sync (0xFF 0xFB or similar)
      if (bytes[0] == 0xFF && (bytes[1] & 0xE0) == 0xE0) {
        return AudioValidationResult(
          isValid: true,
          details: 'Valid MP3 file with frame sync',
          fileSize: fileSize,
          audioInfo: AudioInfo(format: 'MP3'),
        );
      }
      
      return AudioValidationResult(
        isValid: false,
        error: 'Invalid MP3 file',
        details: 'No valid MP3 header found',
        fileSize: fileSize,
      );
    } catch (e) {
      return AudioValidationResult(
        isValid: false,
        error: 'MP3 validation failed',
        details: 'Error validating MP3 file: $e',
        fileSize: fileSize,
      );
    }
  }
  
  // Helper methods for reading binary data
  static int _readUint16(Uint8List bytes, int offset) {
    return bytes[offset] | (bytes[offset + 1] << 8);
  }
  
  static int _readUint32(Uint8List bytes, int offset) {
    return bytes[offset] | 
           (bytes[offset + 1] << 8) | 
           (bytes[offset + 2] << 16) | 
           (bytes[offset + 3] << 24);
  }
  
  static Duration? _calculateWavDuration(Uint8List bytes, int sampleRate, int channels, int bitsPerSample) {
    try {
      // Find data chunk
      int dataOffset = 36;
      while (dataOffset < bytes.length - 8) {
        final chunkId = String.fromCharCodes(bytes.sublist(dataOffset, dataOffset + 4));
        if (chunkId == 'data') {
          final dataSize = _readUint32(bytes, dataOffset + 4);
          final bytesPerSample = (bitsPerSample ~/ 8) * channels;
          final totalSamples = dataSize ~/ bytesPerSample;
          final durationSeconds = totalSamples / sampleRate;
          return Duration(milliseconds: (durationSeconds * 1000).round());
        }
        final chunkSize = _readUint32(bytes, dataOffset + 4);
        dataOffset += 8 + chunkSize;
      }
    } catch (e) {
      // If duration calculation fails, return null
    }
    return null;
  }
}

/// Result of audio file validation
class AudioValidationResult {
  final bool isValid;
  final String? error;
  final String? warning;
  final String? details;
  final int? fileSize;
  final AudioInfo? audioInfo;
  
  AudioValidationResult({
    required this.isValid,
    this.error,
    this.warning,
    this.details,
    this.fileSize,
    this.audioInfo,
  });
  
  @override
  String toString() {
    if (isValid) {
      return 'Valid audio file${details != null ? ': $details' : ''}';
    } else {
      return 'Invalid audio file${error != null ? ' - $error' : ''}${details != null ? ': $details' : ''}';
    }
  }
}

/// Audio file information
class AudioInfo {
  final String format;
  final int? channels;
  final int? sampleRate;
  final int? bitsPerSample;
  final Duration? duration;
  
  AudioInfo({
    required this.format,
    this.channels,
    this.sampleRate,
    this.bitsPerSample,
    this.duration,
  });
  
  @override
  String toString() {
    final parts = <String>[format];
    if (channels != null) parts.add('${channels}ch');
    if (sampleRate != null) parts.add('${sampleRate}Hz');
    if (bitsPerSample != null) parts.add('${bitsPerSample}bit');
    if (duration != null) {
      final seconds = duration!.inMilliseconds / 1000;
      parts.add('${seconds.toStringAsFixed(1)}s');
    }
    return parts.join(' ');
  }
}
