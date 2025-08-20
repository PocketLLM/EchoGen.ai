import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import 'audio_validation_service.dart';

class TTSService {
  static const String _geminiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  static const String _openaiBaseUrl = 'https://api.openai.com/v1';
  static const String _elevenlabsBaseUrl = 'https://api.elevenlabs.io/v1';

  Future<List<TTSVoice>> getAvailableVoices(String provider) async {
    switch (provider.toLowerCase()) {
      case 'gemini':
        return _getGeminiVoices();
      case 'openai':
        return _getOpenAIVoices();
      case 'elevenlabs':
        return _getElevenLabsVoices();
      default:
        throw Exception('Unsupported TTS provider: $provider');
    }
  }

  Future<List<TTSVoice>> _getGeminiVoices() async {
    // Official Gemini TTS voices with correct characteristics
    return [
      // Primary voices
      TTSVoice(id: 'Zephyr', name: 'Zephyr (Bright)', gender: 'Bright', language: 'en-US'),
      TTSVoice(id: 'Puck', name: 'Puck (Upbeat)', gender: 'Upbeat', language: 'en-US'),
      TTSVoice(id: 'Charon', name: 'Charon (Informative)', gender: 'Informative', language: 'en-US'),
      TTSVoice(id: 'Kore', name: 'Kore (Firm)', gender: 'Female', language: 'en-US'),
      TTSVoice(id: 'Fenrir', name: 'Fenrir (Excitable)', gender: 'Male', language: 'en-US'),
      TTSVoice(id: 'Leda', name: 'Leda (Youthful)', gender: 'Female', language: 'en-US'),

      // Additional voices
      TTSVoice(id: 'Orus', name: 'Orus (Firm)', gender: 'Male', language: 'en-US'),
      TTSVoice(id: 'Aoede', name: 'Aoede (Breezy)', gender: 'Female', language: 'en-US'),
      TTSVoice(id: 'Callirrhoe', name: 'Callirrhoe (Easy-going)', gender: 'Female', language: 'en-US'),
      TTSVoice(id: 'Autonoe', name: 'Autonoe (Bright)', gender: 'Female', language: 'en-US'),
      TTSVoice(id: 'Enceladus', name: 'Enceladus (Breathy)', gender: 'Male', language: 'en-US'),
      TTSVoice(id: 'Iapetus', name: 'Iapetus (Clear)', gender: 'Male', language: 'en-US'),
      TTSVoice(id: 'Umbriel', name: 'Umbriel (Easy-going)', gender: 'Male', language: 'en-US'),
      TTSVoice(id: 'Algieba', name: 'Algieba (Smooth)', gender: 'Female', language: 'en-US'),
      TTSVoice(id: 'Despina', name: 'Despina (Smooth)', gender: 'Female', language: 'en-US'),
      TTSVoice(id: 'Erinome', name: 'Erinome (Clear)', gender: 'Female', language: 'en-US'),
      TTSVoice(id: 'Algenib', name: 'Algenib (Gravelly)', gender: 'Male', language: 'en-US'),
      TTSVoice(id: 'Rasalgethi', name: 'Rasalgethi (Informative)', gender: 'Male', language: 'en-US'),
      TTSVoice(id: 'Laomedeia', name: 'Laomedeia (Upbeat)', gender: 'Female', language: 'en-US'),
      TTSVoice(id: 'Achernar', name: 'Achernar (Soft)', gender: 'Male', language: 'en-US'),
      TTSVoice(id: 'Alnilam', name: 'Alnilam (Firm)', gender: 'Male', language: 'en-US'),
      TTSVoice(id: 'Schedar', name: 'Schedar (Even)', gender: 'Male', language: 'en-US'),
      TTSVoice(id: 'Gacrux', name: 'Gacrux (Mature)', gender: 'Male', language: 'en-US'),
      TTSVoice(id: 'Pulcherrima', name: 'Pulcherrima (Forward)', gender: 'Female', language: 'en-US'),
      TTSVoice(id: 'Achird', name: 'Achird (Friendly)', gender: 'Male', language: 'en-US'),
      TTSVoice(id: 'Zubenelgenubi', name: 'Zubenelgenubi (Casual)', gender: 'Male', language: 'en-US'),
      TTSVoice(id: 'Vindemiatrix', name: 'Vindemiatrix (Gentle)', gender: 'Female', language: 'en-US'),
      TTSVoice(id: 'Sadachbia', name: 'Sadachbia (Lively)', gender: 'Male', language: 'en-US'),
      TTSVoice(id: 'Sadaltager', name: 'Sadaltager (Knowledgeable)', gender: 'Male', language: 'en-US'),
      TTSVoice(id: 'Sulafat', name: 'Sulafat (Warm)', gender: 'Male', language: 'en-US'),
    ];
  }

  Future<List<TTSVoice>> _getOpenAIVoices() async {
    // OpenAI TTS voices
    return [
      TTSVoice(id: 'alloy', name: 'Alloy', gender: 'Neutral', language: 'en-US'),
      TTSVoice(id: 'echo', name: 'Echo', gender: 'Male', language: 'en-US'),
      TTSVoice(id: 'fable', name: 'Fable', gender: 'Male', language: 'en-US'),
      TTSVoice(id: 'onyx', name: 'Onyx', gender: 'Male', language: 'en-US'),
      TTSVoice(id: 'nova', name: 'Nova', gender: 'Female', language: 'en-US'),
      TTSVoice(id: 'shimmer', name: 'Shimmer', gender: 'Female', language: 'en-US'),
    ];
  }

  Future<List<TTSVoice>> _getElevenLabsVoices() async {
    // Mock ElevenLabs voices (would need API call in real implementation)
    return [
      TTSVoice(id: 'rachel', name: 'Rachel', gender: 'Female', language: 'en-US'),
      TTSVoice(id: 'drew', name: 'Drew', gender: 'Male', language: 'en-US'),
      TTSVoice(id: 'clyde', name: 'Clyde', gender: 'Male', language: 'en-US'),
      TTSVoice(id: 'paul', name: 'Paul', gender: 'Male', language: 'en-US'),
      TTSVoice(id: 'domi', name: 'Domi', gender: 'Female', language: 'en-US'),
      TTSVoice(id: 'dave', name: 'Dave', gender: 'Male', language: 'en-US'),
    ];
  }

  Future<String> generatePodcast({
    required String script,
    required String speaker1Voice,
    required String speaker2Voice,
    required String provider,
    String speaker1Name = 'Speaker1',
    String speaker2Name = 'Speaker2',
    String model = 'gemini-2.5-flash-preview-tts',
    String languageCode = 'en-US',
  }) async {
    try {
      print('🎙️ Starting podcast generation with provider: $provider');
      print('🤖 Using model: $model');
      print('📝 Script length: ${script.length} characters');
      print('🗣️ Speaker 1: $speaker1Name ($speaker1Voice)');
      print('🗣️ Speaker 2: $speaker2Name ($speaker2Voice)');
      print('🌐 Language: $languageCode');

      // For now, we only support Gemini multi-speaker TTS
      if (provider.toLowerCase() != 'gemini') {
        print('⚠️ Non-Gemini provider selected: $provider. Only Gemini is currently supported.');
        throw Exception('Only Gemini TTS is available at this time. Other providers coming soon!');
      }
      
      // Use Gemini's multi-speaker TTS
      return await _generateGeminiMultiSpeakerPodcast(
        script: script,
        speaker1Voice: speaker1Voice,
        speaker2Voice: speaker2Voice,
        speaker1Name: speaker1Name,
        speaker2Name: speaker2Name,
        model: model,
        languageCode: languageCode,
      );
    } catch (e) {
      print('❌ Error generating podcast: $e');
      rethrow;
    }
  }

  // Helper method to verify API key
  Future<String> verifyGeminiApiKey() async {
    print('🔍 Verifying Gemini API key access...');
    
    final prefs = await SharedPreferences.getInstance();
    
    // Get API key from settings
    final apiKey = prefs.getString('api_key_gemini');
    
    if (apiKey != null && apiKey.isNotEmpty) {
      print('✅ Found API key: ${apiKey.substring(0, 4)}...${apiKey.substring(apiKey.length - 4)}');
    } else {
      print('❌ No Gemini API key found');
      throw Exception('Gemini API key not found. Please configure it in Settings > API Keys.');
    }
    
    // Format check
    if (!apiKey.startsWith('AIza') || apiKey.length < 20) {
      print('❌ Gemini API key has incorrect format');
      throw Exception('Invalid Gemini API key format. Keys should start with "AIza".');
    }
    
    print('✅ API key verification complete');
    return apiKey;
  }

  Future<String> _generateGeminiMultiSpeakerPodcast({
    required String script,
    required String speaker1Voice,
    required String speaker2Voice,
    required String speaker1Name,
    required String speaker2Name,
    String model = 'gemini-2.5-flash-preview-tts',
    String languageCode = 'en-US',
  }) async {
    // Use persistent HTTP client that can handle background state
    final client = http.Client();
    
    try {
      print('🎙️ Starting Gemini multi-speaker podcast generation...');
      print('🤖 Using model: $model');
      print('📝 Script length: ${script.length} characters');
      print('🗣️ Speaker 1: $speaker1Name ($speaker1Voice)');
      print('🗣️ Speaker 2: $speaker2Name ($speaker2Voice)');
      print('🌐 Language: $languageCode');

      // Use our verification helper to get a valid API key
      final apiKey = await verifyGeminiApiKey();

      print('🔑 API key found, making request...');
      // Ensure API key is properly URL-encoded
      final encodedApiKey = Uri.encodeQueryComponent(apiKey);
      final url = Uri.parse('$_geminiBaseUrl/models/$model:generateContent?key=$encodedApiKey');

      // Format the script to include a clear instruction for the TTS model
      final formattedScript = '''
TTS the following conversation between $speaker1Name and $speaker2Name:

$script
''';

      // Prepare the request according to Gemini TTS documentation
      final requestBody = {
        'contents': [
          {
            'parts': [
              {
                'text': formattedScript,
              }
            ]
          }
        ],
        'generationConfig': {
          'responseModalities': ['AUDIO'],
          'speechConfig': {
            'languageCode': languageCode,
            'multiSpeakerVoiceConfig': {
              'speakerVoiceConfigs': [
                {
                  'speaker': speaker1Name,
                  'voiceConfig': {
                    'prebuiltVoiceConfig': {
                      'voiceName': speaker1Voice,
                    }
                  }
                },
                {
                  'speaker': speaker2Name,
                  'voiceConfig': {
                    'prebuiltVoiceConfig': {
                      'voiceName': speaker2Voice,
                    }
                  }
                }
              ]
            }
          }
        }
      };

      print('📤 Sending request to Gemini TTS API...');
      // Use HTTP client that won't be interrupted by app going to background
      final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Keep-Alive': 'timeout=120, max=1000',
          'Connection': 'keep-alive',
        },
        body: jsonEncode(requestBody),
      ).timeout(
        const Duration(minutes: 3),
        onTimeout: () {
          client.close();
          throw Exception('Request timed out after 3 minutes. Please try with a shorter script or check your connection.');
        },
      );

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ Successful response from Gemini TTS');
        final responseData = jsonDecode(response.body);
        print('💾 Response structure: ${responseData.keys}');
        
        // Extract audio data from response
        final audioData = responseData['candidates'][0]['content']['parts'][0]['inlineData']['data'];

        // Decode base64 audio data (this is raw PCM data)
        final pcmBytes = base64Decode(audioData);
        print('📊 Raw PCM data size: ${pcmBytes.length} bytes');

        // Convert PCM to proper WAV format with headers
        final wavBytes = _convertPcmToWav(pcmBytes);
        print('📊 WAV data size: ${wavBytes.length} bytes');

        // Save the properly formatted WAV file
        final directory = await _getDownloadDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        final wavPath = '${directory.path}/podcast_$timestamp.wav';

        // Save audio file to preferred location
        final wavFile = File(wavPath);
        await wavFile.writeAsBytes(wavBytes);
        print('📀 Properly formatted WAV podcast saved to: $wavPath');

        // Validate the generated audio file
        final validationResult = await AudioValidationService.validateAudioFile(wavPath);
        if (!validationResult.isValid) {
          print('❌ Generated audio file validation failed: ${validationResult.error}');
          print('❌ Details: ${validationResult.details}');
          throw Exception('Generated audio file is invalid: ${validationResult.error}');
        }

        print('✅ Audio file validation passed: ${validationResult.details}');
        if (validationResult.audioInfo != null) {
          print('🎵 Audio info: ${validationResult.audioInfo}');
        }

        // Close HTTP client properly
        client.close();

        // Return the WAV path (the primary format)
        return wavPath;
      } else {
        // Handle error response
        print('❌ Error response: ${response.statusCode}');
        print('❌ Error body: ${response.body}');
        
        // Extract error message from response if possible
        String errorMessage = 'Unknown error';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['error']['message'] ?? 'Unknown error';
        } catch (e) {
          errorMessage = 'Failed to parse error: ${response.body}';
        }
        
        // Close HTTP client before throwing
        client.close();
        
        throw Exception('Gemini TTS API error: $errorMessage');
      }
    } catch (e) {
      // Ensure client is closed even on errors
      client.close();
      
      print('❌ Error generating Gemini multi-speaker podcast: $e');
      throw Exception('Failed to generate podcast: $e');
    }
  }

  Future<Directory> _getDownloadDirectory() async {
    final prefs = await SharedPreferences.getInstance();
    final folderType = prefs.getString('download_folder_type') ?? 'app_documents';
    Directory directory;

    try {
      switch (folderType) {
        case 'downloads':
          // Try to get downloads directory
          directory = Directory('/storage/emulated/0/Download/EchoGenAI');
          break;
        case 'external':
          // Try to get external storage
          directory = Directory('/storage/emulated/0/EchoGenAI');
          break;
        case 'music':
          // Try to get music directory
          directory = Directory('/storage/emulated/0/Music/EchoGenAI');
          break;
        default:
          // Use app documents directory as a reliable fallback
          directory = await getApplicationDocumentsDirectory();
      }
      
      // Ensure directory exists
      if (!await directory.exists()) {
        try {
          await directory.create(recursive: true);
          print('📁 Created directory: ${directory.path}');
        } catch (e) {
          print('⚠️ Failed to create directory: $e');
          // Fallback to app documents
          directory = await getApplicationDocumentsDirectory();
        }
      }
      
      // Test write permissions by creating a test file
      try {
        final testFile = File('${directory.path}/test_permissions.txt');
        await testFile.writeAsString('test');
        await testFile.delete();
        print('✅ Directory has write permissions: ${directory.path}');
      } catch (e) {
        print('⚠️ Directory lacks write permissions: $e');
        // Fallback to app documents
        directory = await getApplicationDocumentsDirectory();
      }
      
      return directory;
    } catch (e) {
      print('⚠️ Error accessing storage: $e');
      // Fallback to app documents
      return await getApplicationDocumentsDirectory();
    }
  }

  /// Converts raw PCM audio data to WAV format with proper headers
  /// Gemini TTS returns 16-bit signed linear PCM at 24kHz sample rate
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

    print('✅ Successfully converted ${pcmData.length} bytes of PCM to ${wavData.length} bytes of WAV');
    return wavData;
  }

  // Legacy methods - kept for compatibility but not used
  Future<String> _generateOpenAIAudio(String text, String voiceId) async {
    // Mock implementation - in real app, would call OpenAI TTS API
    await Future.delayed(const Duration(milliseconds: 500));
    
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.wav';
    final filePath = '${directory.path}/$fileName';
    
    // Create a mock audio file
    final file = File(filePath);
    await file.writeAsBytes([]);
    
    return filePath;
  }

  Future<String> _generateElevenLabsAudio(String text, String voiceId) async {
    // Mock implementation - in real app, would call ElevenLabs API
    await Future.delayed(const Duration(milliseconds: 500));
    
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.wav';
    final filePath = '${directory.path}/$fileName';
    
    // Create a mock audio file
    final file = File(filePath);
    await file.writeAsBytes([]);
    
    return filePath;
  }

  Future<String> _combineAudioSegments(List<String> audioSegments) async {
    // Mock implementation - in real app, would combine audio files
    await Future.delayed(const Duration(milliseconds: 300));
    
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'podcast_${DateTime.now().millisecondsSinceEpoch}.wav';
    final filePath = '${directory.path}/$fileName';
    
    // Create a mock combined audio file
    final file = File(filePath);
    await file.writeAsBytes([]);
    
    return filePath;
  }
}

class TTSVoice {
  final String id;
  final String name;
  final String gender;
  final String language;

  TTSVoice({
    required this.id,
    required this.name,
    required this.gender,
    required this.language,
  });
}

class ScriptSegment {
  final String speaker;
  final String text;

  ScriptSegment({
    required this.speaker,
    required this.text,
  });
}
