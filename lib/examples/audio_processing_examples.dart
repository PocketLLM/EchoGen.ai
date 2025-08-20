import '../services/audio_processing_service.dart';
import '../models/tts_models.dart';

/// Examples of using the lightweight audio processing service
/// Focused on validation and basic operations without FFmpeg dependency
class AudioProcessingExamples {
  final AudioProcessingService _audioProcessor = AudioProcessingService();

  /// Example 1: Validate and copy podcast file (replaces conversion)
  Future<void> validateAndCopyPodcast(String wavPath) async {
    try {
      print('🎵 Validating and copying podcast...');
      
      // First validate the audio file
      final validationResult = await _audioProcessor.validateAudio(
        inputPath: wavPath,
        expectedFormat: AudioFormat.wav,
        onProgress: (progress) {
          print('Validation progress: ${(progress * 100).toInt()}%');
        },
        onLog: (log) {
          print('Audio processing: $log');
        },
      );

      if (validationResult.success) {
        print('✅ Validation successful!');
        print('📁 File: ${validationResult.outputPath}');
        print('📊 Size: ${validationResult.fileSize} bytes');
        if (validationResult.audioInfo != null) {
          print('🎵 Audio info: ${validationResult.audioInfo}');
        }
      }
    } catch (e) {
      print('❌ Validation failed: $e');
    }
  }

  /// Example 2: Get detailed audio information
  Future<void> analyzePodcastAudio(String audioPath) async {
    try {
      print('🔍 Analyzing podcast audio...');
      
      final audioInfo = await _audioProcessor.getAudioInfo(audioPath);
      
      print('📊 Audio Analysis Results:');
      print('   Format: ${audioInfo.format}');
      print('   Duration: ${audioInfo.duration}');
      print('   Sample Rate: ${audioInfo.sampleRate} Hz');
      print('   Channels: ${audioInfo.channels}');
      print('   Bitrate: ${audioInfo.bitrate} kbps');
      print('   File Size: ${audioInfo.fileSize} bytes');
      
    } catch (e) {
      print('❌ Analysis failed: $e');
    }
  }

  /// Example 3: Copy podcast to different location
  Future<void> copyPodcastFile(String inputPath, String outputPath) async {
    try {
      print('📁 Copying podcast file...');
      
      final result = await _audioProcessor.copyAudio(
        inputPath: inputPath,
        outputPath: outputPath,
        onProgress: (progress) {
          print('Copy progress: ${(progress * 100).toInt()}%');
        },
        onLog: (log) {
          print('Copy: $log');
        },
      );

      if (result.success) {
        print('✅ Copy complete!');
        print('📁 Copied to: ${result.outputPath}');
        print('📊 Size: ${result.fileSize} bytes');
      }
    } catch (e) {
      print('❌ Copy failed: $e');
    }
  }

  /// Example 4: Validate multiple audio files
  Future<void> validateMultiplePodcasts(List<String> audioPaths) async {
    print('🔍 Validating multiple podcast files...');
    
    for (int i = 0; i < audioPaths.length; i++) {
      final audioPath = audioPaths[i];
      print('\n📁 Validating file ${i + 1}/${audioPaths.length}: $audioPath');
      
      try {
        final isValid = await _audioProcessor.isValidAudioFile(audioPath);
        if (isValid) {
          print('✅ Valid audio file');
          
          // Get detailed info for valid files
          final audioInfo = await _audioProcessor.getAudioInfo(audioPath);
          print('   📊 ${audioInfo.format} | ${audioInfo.duration} | ${audioInfo.fileSize} bytes');
        } else {
          print('❌ Invalid audio file');
        }
      } catch (e) {
        print('❌ Validation error: $e');
      }
    }
    
    print('\n🎉 Batch validation complete!');
  }

  /// Example 5: Simple podcast processing workflow
  Future<void> processSimplePodcast(String rawWavPath) async {
    try {
      print('🎬 Starting simple podcast processing...');
      
      // Step 1: Validate the input file
      print('📋 Step 1: Validating input file...');
      final validationResult = await _audioProcessor.validateAudio(
        inputPath: rawWavPath,
        expectedFormat: AudioFormat.wav,
      );
      
      if (!validationResult.success) {
        throw Exception('Input file validation failed');
      }
      print('✅ Step 1: Validation complete');

      // Step 2: Get audio information
      print('📋 Step 2: Analyzing audio...');
      final audioInfo = await _audioProcessor.getAudioInfo(rawWavPath);
      print('✅ Step 2: Analysis complete - ${audioInfo.format} | ${audioInfo.duration}');

      // Step 3: Copy to final location (simulates processing)
      final finalPath = rawWavPath.replaceAll('.wav', '_processed.wav');
      final copyResult = await _audioProcessor.copyAudio(
        inputPath: rawWavPath,
        outputPath: finalPath,
      );
      
      if (copyResult.success) {
        print('🎉 Simple processing complete!');
        print('📁 Final podcast: ${copyResult.outputPath}');
      }
      
    } catch (e) {
      print('❌ Processing failed: $e');
    }
  }

  /// Example 6: Check supported formats
  Future<void> demonstrateSupportedFormats() async {
    print('🎵 Supported Audio Formats:');
    
    final supportedFormats = _audioProcessor.getSupportedFormats();
    for (final format in supportedFormats) {
      print('   ✅ ${format.name.toUpperCase()}');
    }
    
    print('\n🔍 Format Detection Examples:');
    final testFiles = [
      'podcast.wav',
      'music.mp3',
      'audio.pcm',
      'unknown.xyz',
    ];
    
    for (final file in testFiles) {
      final detectedFormat = _audioProcessor.detectAudioFormat(file);
      if (detectedFormat != null) {
        print('   📁 $file → ${detectedFormat.name.toUpperCase()}');
      } else {
        print('   ❓ $file → Unknown format');
      }
    }
  }

  /// Example 7: Error handling demonstration
  Future<void> demonstrateErrorHandling() async {
    print('⚠️ Demonstrating error handling...');
    
    // Test with non-existent file
    try {
      await _audioProcessor.getAudioInfo('/non/existent/file.wav');
    } catch (e) {
      print('✅ Caught expected error for non-existent file: $e');
    }
    
    // Test with invalid format
    try {
      await _audioProcessor.validateAudio(
        inputPath: 'invalid.txt',
        expectedFormat: AudioFormat.wav,
      );
    } catch (e) {
      print('✅ Caught expected error for invalid format: $e');
    }
    
    print('🎉 Error handling demonstration complete!');
  }

  /// Example 8: Performance monitoring
  Future<void> monitorProcessingPerformance(String audioPath) async {
    print('⏱️ Monitoring processing performance...');
    
    final stopwatch = Stopwatch()..start();
    
    try {
      // Validation timing
      final validationStart = stopwatch.elapsedMilliseconds;
      final isValid = await _audioProcessor.isValidAudioFile(audioPath);
      final validationTime = stopwatch.elapsedMilliseconds - validationStart;
      
      print('📊 Validation: ${validationTime}ms (Valid: $isValid)');
      
      if (isValid) {
        // Analysis timing
        final analysisStart = stopwatch.elapsedMilliseconds;
        final audioInfo = await _audioProcessor.getAudioInfo(audioPath);
        final analysisTime = stopwatch.elapsedMilliseconds - analysisStart;
        
        print('📊 Analysis: ${analysisTime}ms');
        print('📊 File size: ${audioInfo.fileSize} bytes');
        print('📊 Duration: ${audioInfo.duration}');
      }
      
    } catch (e) {
      print('❌ Performance monitoring failed: $e');
    } finally {
      stopwatch.stop();
      print('⏱️ Total time: ${stopwatch.elapsedMilliseconds}ms');
    }
  }

  /// Example 9: Cleanup operations
  Future<void> demonstrateCleanup() async {
    print('🧹 Demonstrating cleanup operations...');
    
    // Cancel any ongoing operations (no-op in our lightweight service)
    await _audioProcessor.cancelAllSessions();
    print('✅ All sessions cancelled');
    
    print('🎉 Cleanup demonstration complete!');
  }
}
