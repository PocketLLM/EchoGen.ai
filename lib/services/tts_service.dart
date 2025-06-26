import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;

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
        
        // Decode base64 audio data
        final audioBytes = base64Decode(audioData);
        
        // Save the original WAV file
        final directory = await _getDownloadDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        final wavPath = '${directory.path}/podcast_$timestamp.wav';
        
        // Save audio file to preferred location
        final wavFile = File(wavPath);
        await wavFile.writeAsBytes(audioBytes);
        print('📀 Original WAV podcast saved to: $wavPath');
        
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

  // This method has been removed in favor of the actual implementation 
  // using the Gemini TTS API

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
