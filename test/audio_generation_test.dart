import 'package:flutter_test/flutter_test.dart';
import 'package:echogenai/services/audio_validation_service.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math';

void main() {
  group('Audio Generation Tests', () {
    test('PCM to WAV conversion creates valid WAV file', () async {
      // Create mock PCM data (16-bit signed, 24kHz, mono)
      const int sampleRate = 24000;
      const int duration = 1; // 1 second
      const int samples = sampleRate * duration;
      
      // Generate a simple sine wave as test PCM data
      final pcmData = Uint8List(samples * 2); // 16-bit = 2 bytes per sample
      for (int i = 0; i < samples; i++) {
        // Generate a 440Hz sine wave
        final double sample = 0.5 * 32767 * sin(2.0 * pi * 440 * i / sampleRate);
        final int intSample = sample.round();
        
        // Write as little-endian 16-bit signed integer
        pcmData[i * 2] = intSample & 0xFF;
        pcmData[i * 2 + 1] = (intSample >> 8) & 0xFF;
      }
      
      // Convert PCM to WAV using the same method as TTS service
      final wavData = _convertPcmToWav(pcmData);
      
      // Create a temporary file
      final tempDir = Directory.systemTemp;
      final testFile = File('${tempDir.path}/test_audio.wav');
      await testFile.writeAsBytes(wavData);
      
      try {
        // Validate the generated WAV file
        final validationResult = await AudioValidationService.validateAudioFile(testFile.path);
        
        expect(validationResult.isValid, true, reason: validationResult.error ?? 'Unknown error');
        expect(validationResult.audioInfo?.format, 'WAV');
        expect(validationResult.audioInfo?.channels, 1);
        expect(validationResult.audioInfo?.sampleRate, 24000);
        expect(validationResult.audioInfo?.bitsPerSample, 16);
        
        print('✅ Test passed: ${validationResult.details}');
        if (validationResult.audioInfo != null) {
          print('🎵 Audio info: ${validationResult.audioInfo}');
        }
      } finally {
        // Clean up
        if (await testFile.exists()) {
          await testFile.delete();
        }
      }
    });
    
    test('Audio validation detects invalid WAV files', () async {
      // Create an invalid WAV file (just random bytes)
      final invalidData = Uint8List.fromList([1, 2, 3, 4, 5]);
      
      final tempDir = Directory.systemTemp;
      final testFile = File('${tempDir.path}/invalid_audio.wav');
      await testFile.writeAsBytes(invalidData);
      
      try {
        final validationResult = await AudioValidationService.validateAudioFile(testFile.path);
        
        expect(validationResult.isValid, false);
        expect(validationResult.error, isNotNull);
        
        print('✅ Test passed: Invalid file correctly detected - ${validationResult.error}');
      } finally {
        // Clean up
        if (await testFile.exists()) {
          await testFile.delete();
        }
      }
    });
    
    test('Audio validation handles non-existent files', () async {
      final validationResult = await AudioValidationService.validateAudioFile('/non/existent/file.wav');
      
      expect(validationResult.isValid, false);
      expect(validationResult.error, 'File does not exist');
      
      print('✅ Test passed: Non-existent file correctly handled');
    });
  });
}

/// Converts raw PCM audio data to WAV format with proper headers
/// This is the same method used in the TTS service
Uint8List _convertPcmToWav(Uint8List pcmData) {
  const int sampleRate = 24000; // Gemini TTS uses 24kHz
  const int bitsPerSample = 16; // 16-bit audio
  const int channels = 1; // Mono audio
  
  final int byteRate = sampleRate * channels * (bitsPerSample ~/ 8);
  final int blockAlign = channels * (bitsPerSample ~/ 8);
  final int dataSize = pcmData.length;
  final int fileSize = 36 + dataSize; // WAV header is 44 bytes, minus 8 for RIFF header
  
  // Create WAV header
  final ByteData header = ByteData(44);
  
  // RIFF header
  header.setUint8(0, 0x52); // 'R'
  header.setUint8(1, 0x49); // 'I'
  header.setUint8(2, 0x46); // 'F'
  header.setUint8(3, 0x46); // 'F'
  header.setUint32(4, fileSize, Endian.little); // File size
  header.setUint8(8, 0x57);  // 'W'
  header.setUint8(9, 0x41);  // 'A'
  header.setUint8(10, 0x56); // 'V'
  header.setUint8(11, 0x45); // 'E'
  
  // Format chunk
  header.setUint8(12, 0x66); // 'f'
  header.setUint8(13, 0x6D); // 'm'
  header.setUint8(14, 0x74); // 't'
  header.setUint8(15, 0x20); // ' '
  header.setUint32(16, 16, Endian.little); // Format chunk size
  header.setUint16(20, 1, Endian.little);  // Audio format (PCM)
  header.setUint16(22, channels, Endian.little); // Number of channels
  header.setUint32(24, sampleRate, Endian.little); // Sample rate
  header.setUint32(28, byteRate, Endian.little); // Byte rate
  header.setUint16(32, blockAlign, Endian.little); // Block align
  header.setUint16(34, bitsPerSample, Endian.little); // Bits per sample
  
  // Data chunk
  header.setUint8(36, 0x64); // 'd'
  header.setUint8(37, 0x61); // 'a'
  header.setUint8(38, 0x74); // 't'
  header.setUint8(39, 0x61); // 'a'
  header.setUint32(40, dataSize, Endian.little); // Data size
  
  // Combine header and PCM data
  final Uint8List wavData = Uint8List(44 + dataSize);
  wavData.setRange(0, 44, header.buffer.asUint8List());
  wavData.setRange(44, 44 + dataSize, pcmData);
  
  return wavData;
}
