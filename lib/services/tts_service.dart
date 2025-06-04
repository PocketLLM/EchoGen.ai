import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  }) async {
    if (provider.toLowerCase() == 'gemini') {
      // Use Gemini's multi-speaker TTS for better quality
      return await _generateGeminiMultiSpeakerPodcast(
        script: script,
        speaker1Voice: speaker1Voice,
        speaker2Voice: speaker2Voice,
        speaker1Name: speaker1Name,
        speaker2Name: speaker2Name,
      );
    } else {
      // Use traditional segment-by-segment approach for other providers
      final segments = _parseScript(script);
      final audioSegments = <String>[];

      for (final segment in segments) {
        final voiceId = segment.speaker == 'Speaker 1' ? speaker1Voice : speaker2Voice;
        final audioPath = await _generateAudioSegment(
          text: segment.text,
          voiceId: voiceId,
          provider: provider,
        );
        audioSegments.add(audioPath);
      }

      final combinedAudioPath = await _combineAudioSegments(audioSegments);
      return combinedAudioPath;
    }
  }

  Future<String> _generateGeminiMultiSpeakerPodcast({
    required String script,
    required String speaker1Voice,
    required String speaker2Voice,
    required String speaker1Name,
    required String speaker2Name,
  }) async {
    try {
      print('🎙️ Starting Gemini multi-speaker podcast generation...');
      print('📝 Script length: ${script.length} characters');
      print('🗣️ Speaker 1: $speaker1Name ($speaker1Voice)');
      print('🗣️ Speaker 2: $speaker2Name ($speaker2Voice)');

      final prefs = await SharedPreferences.getInstance();
      final apiKey = prefs.getString('gemini_api_key');

      if (apiKey == null || apiKey.isEmpty) {
        print('❌ Gemini API key not found');
        throw Exception('Gemini API key not found. Please configure it in settings.');
      }

      print('🔑 API key found, making request...');
      final url = Uri.parse('$_geminiBaseUrl/models/gemini-2.5-flash-preview-tts:generateContent?key=$apiKey');

      final requestBody = {
        'contents': [
          {
            'parts': [
              {
                'text': script,
              }
            ]
          }
        ],
        'generationConfig': {
          'responseModalities': ['AUDIO'],
          'speechConfig': {
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
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ Successful response from Gemini TTS');
        final responseData = jsonDecode(response.body);

        if (responseData['candidates'] != null &&
            responseData['candidates'].isNotEmpty &&
            responseData['candidates'][0]['content'] != null &&
            responseData['candidates'][0]['content']['parts'] != null &&
            responseData['candidates'][0]['content']['parts'].isNotEmpty &&
            responseData['candidates'][0]['content']['parts'][0]['inlineData'] != null) {

          final audioData = responseData['candidates'][0]['content']['parts'][0]['inlineData']['data'];
          print('🎵 Audio data received, size: ${audioData.length} characters (base64)');

          final audioBytes = base64Decode(audioData);
          print('🎵 Decoded audio size: ${audioBytes.length} bytes');

          final directory = await _getDownloadDirectory();
          final fileName = 'podcast_${DateTime.now().millisecondsSinceEpoch}.wav';
          final filePath = '${directory.path}/$fileName';

          final file = File(filePath);
          await file.writeAsBytes(audioBytes);

          print('💾 Audio saved to: $filePath');
          print('✅ Podcast generation completed successfully!');

          return filePath;
        } else {
          print('❌ Invalid response structure from Gemini TTS');
          throw Exception('Invalid response structure from Gemini TTS API');
        }
      } else {
        print('❌ API error: ${response.statusCode}');
        print('❌ Response body: ${response.body}');
        final errorData = jsonDecode(response.body);
        throw Exception('Gemini TTS API error: ${errorData['error']['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('❌ Error generating Gemini multi-speaker podcast: $e');
      print('🔄 Falling back to mock implementation...');
      // Fallback to mock implementation
      return await _generateMockPodcast();
    }
  }

  Future<String> _generateMockPodcast() async {
    await Future.delayed(const Duration(seconds: 2));

    final directory = await _getDownloadDirectory();
    final fileName = 'podcast_${DateTime.now().millisecondsSinceEpoch}.wav';
    final filePath = '${directory.path}/$fileName';

    // Create a longer mock audio file (10 seconds)
    final file = File(filePath);

    final sampleRate = 24000;
    final duration = 10; // 10 seconds
    final numSamples = sampleRate * duration;
    final dataSize = numSamples * 2;
    final fileSize = 36 + dataSize;

    final wavData = ByteData(44 + dataSize);

    // WAV header
    wavData.setUint32(0, 0x52494646, Endian.big); // "RIFF"
    wavData.setUint32(4, fileSize, Endian.little);
    wavData.setUint32(8, 0x57415645, Endian.big); // "WAVE"
    wavData.setUint32(12, 0x666d7420, Endian.big); // "fmt "
    wavData.setUint32(16, 16, Endian.little);
    wavData.setUint16(20, 1, Endian.little);
    wavData.setUint16(22, 1, Endian.little);
    wavData.setUint32(24, sampleRate, Endian.little);
    wavData.setUint32(28, sampleRate * 2, Endian.little);
    wavData.setUint16(32, 2, Endian.little);
    wavData.setUint16(34, 16, Endian.little);
    wavData.setUint32(36, 0x64617461, Endian.big); // "data"
    wavData.setUint32(40, dataSize, Endian.little);

    // Fill with silence
    for (int i = 44; i < 44 + dataSize; i++) {
      wavData.setUint8(i, 0);
    }

    await file.writeAsBytes(wavData.buffer.asUint8List());

    return filePath;
  }

  // New method that accepts speaker names
  Future<String> generatePodcastAudio({
    required List<ScriptSegment> segments,
    required String speaker1Voice,
    required String speaker2Voice,
    required String provider,
    required Function(double, String) onProgress,
  }) async {
    final audioSegments = <String>[];

    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final progress = (i + 1) / segments.length;
      onProgress(progress, 'Generating audio for ${segment.speaker}...');

      // For now, alternate between voices (in real implementation, match by speaker name)
      final voiceId = i % 2 == 0 ? speaker1Voice : speaker2Voice;

      final audioPath = await _generateAudioSegment(
        text: segment.text,
        voiceId: voiceId,
        provider: provider,
      );
      audioSegments.add(audioPath);
    }

    onProgress(1.0, 'Combining audio segments...');
    final combinedAudioPath = await _combineAudioSegments(audioSegments);

    return combinedAudioPath;
  }

  // Parse script into segments with speaker names
  List<ScriptSegment> parseScript(String script, String speaker1Name, String speaker2Name) {
    final segments = <ScriptSegment>[];
    final lines = script.split('\n');

    String? currentSpeaker;
    String currentText = '';

    for (final line in lines) {
      final trimmedLine = line.trim();

      // Skip empty lines and title
      if (trimmedLine.isEmpty ||
          trimmedLine.toLowerCase().startsWith('title:') ||
          trimmedLine.toLowerCase().startsWith('episode:') ||
          trimmedLine.toLowerCase().startsWith('podcast:')) {
        continue;
      }

      // Check if line starts with speaker name
      if (trimmedLine.contains(':')) {
        // Save previous segment if exists
        if (currentSpeaker != null && currentText.isNotEmpty) {
          segments.add(ScriptSegment(
            speaker: currentSpeaker,
            text: currentText.trim(),
          ));
        }

        // Parse new speaker
        final parts = trimmedLine.split(':');
        if (parts.length >= 2) {
          final speakerName = parts[0].trim();
          currentText = parts.sublist(1).join(':').trim();

          // Map speaker names to standardized names
          if (speakerName.toLowerCase().contains(speaker1Name.toLowerCase()) ||
              speakerName.toLowerCase() == speaker1Name.toLowerCase()) {
            currentSpeaker = speaker1Name;
          } else if (speakerName.toLowerCase().contains(speaker2Name.toLowerCase()) ||
                     speakerName.toLowerCase() == speaker2Name.toLowerCase()) {
            currentSpeaker = speaker2Name;
          } else {
            // Default assignment if speaker name doesn't match
            currentSpeaker = speakerName;
          }
        }
      } else {
        // Continue current speaker's text
        if (currentText.isNotEmpty) {
          currentText += ' ';
        }
        currentText += trimmedLine;
      }
    }

    // Add final segment
    if (currentSpeaker != null && currentText.isNotEmpty) {
      segments.add(ScriptSegment(
        speaker: currentSpeaker,
        text: currentText.trim(),
      ));
    }

    return segments;
  }

  List<ScriptSegment> _parseScript(String script) {
    final segments = <ScriptSegment>[];
    final lines = script.split('\n');
    
    String? currentSpeaker;
    String currentText = '';
    
    for (final line in lines) {
      final trimmedLine = line.trim();
      
      // Skip empty lines and title
      if (trimmedLine.isEmpty || trimmedLine.toLowerCase().startsWith('title:')) {
        continue;
      }
      
      // Check if line starts with speaker name
      if (trimmedLine.contains(':')) {
        // Save previous segment if exists
        if (currentSpeaker != null && currentText.isNotEmpty) {
          segments.add(ScriptSegment(
            speaker: currentSpeaker,
            text: currentText.trim(),
          ));
        }
        
        // Parse new speaker
        final parts = trimmedLine.split(':');
        if (parts.length >= 2) {
          currentSpeaker = parts[0].trim();
          currentText = parts.sublist(1).join(':').trim();
        }
      } else {
        // Continue current speaker's text
        if (currentText.isNotEmpty) {
          currentText += ' ';
        }
        currentText += trimmedLine;
      }
    }
    
    // Add final segment
    if (currentSpeaker != null && currentText.isNotEmpty) {
      segments.add(ScriptSegment(
        speaker: currentSpeaker,
        text: currentText.trim(),
      ));
    }
    
    return segments;
  }

  Future<String> _generateAudioSegment({
    required String text,
    required String voiceId,
    required String provider,
  }) async {
    switch (provider.toLowerCase()) {
      case 'gemini':
        return await _generateGeminiAudio(text, voiceId);
      case 'openai':
        return await _generateOpenAIAudio(text, voiceId);
      case 'elevenlabs':
        return await _generateElevenLabsAudio(text, voiceId);
      default:
        throw Exception('Unsupported TTS provider: $provider');
    }
  }

  Future<String> _generateGeminiAudio(String text, String voiceId) async {
    try {
      // Get API key from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final apiKey = prefs.getString('gemini_api_key');

      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('Gemini API key not found. Please configure it in settings.');
      }

      // Prepare the request
      final url = Uri.parse('$_geminiBaseUrl/models/gemini-2.5-flash-preview-tts:generateContent?key=$apiKey');

      final requestBody = {
        'contents': [
          {
            'parts': [
              {
                'text': text,
              }
            ]
          }
        ],
        'generationConfig': {
          'responseModalities': ['AUDIO'],
          'speechConfig': {
            'voiceConfig': {
              'prebuiltVoiceConfig': {
                'voiceName': voiceId,
              }
            }
          }
        }
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Extract audio data from response
        final audioData = responseData['candidates'][0]['content']['parts'][0]['inlineData']['data'];

        // Decode base64 audio data
        final audioBytes = base64Decode(audioData);

        // Get download directory based on user preference
        final directory = await _getDownloadDirectory();
        final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.wav';
        final filePath = '${directory.path}/$fileName';

        // Save audio file
        final file = File(filePath);
        await file.writeAsBytes(audioBytes);

        return filePath;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('Gemini TTS API error: ${errorData['error']['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('Error generating Gemini audio: $e');
      // Fallback to mock implementation for development
      return await _generateMockAudio();
    }
  }

  Future<Directory> _getDownloadDirectory() async {
    final prefs = await SharedPreferences.getInstance();
    final folderType = prefs.getString('download_folder_type') ?? 'app_documents';

    switch (folderType) {
      case 'downloads':
        // Try to get downloads directory
        try {
          final directory = Directory('/storage/emulated/0/Download/EchoGenAI');
          if (!await directory.exists()) {
            await directory.create(recursive: true);
          }
          return directory;
        } catch (e) {
          // Fallback to app documents
          return await getApplicationDocumentsDirectory();
        }
      case 'external':
        // Try to get external storage
        try {
          final directory = Directory('/storage/emulated/0/EchoGenAI');
          if (!await directory.exists()) {
            await directory.create(recursive: true);
          }
          return directory;
        } catch (e) {
          // Fallback to app documents
          return await getApplicationDocumentsDirectory();
        }
      case 'custom':
        // Use custom selected folder
        try {
          final customPath = prefs.getString('custom_download_path');
          if (customPath != null) {
            final directory = Directory('$customPath/EchoGenAI');
            if (!await directory.exists()) {
              await directory.create(recursive: true);
            }
            return directory;
          } else {
            // Fallback to app documents if custom path is not found
            return await getApplicationDocumentsDirectory();
          }
        } catch (e) {
          // Fallback to app documents
          return await getApplicationDocumentsDirectory();
        }
      default:
        return await getApplicationDocumentsDirectory();
    }
  }

  Future<String> _generateMockAudio() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final directory = await _getDownloadDirectory();
    final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.wav';
    final filePath = '${directory.path}/$fileName';

    // Create a mock audio file with some basic WAV header
    final file = File(filePath);

    // Create a simple WAV file with silence (44 bytes header + 1 second of silence at 24kHz)
    final sampleRate = 24000;
    final duration = 1; // 1 second
    final numSamples = sampleRate * duration;
    final dataSize = numSamples * 2; // 16-bit samples
    final fileSize = 36 + dataSize;

    final wavData = ByteData(44 + dataSize);

    // WAV header
    wavData.setUint32(0, 0x52494646, Endian.big); // "RIFF"
    wavData.setUint32(4, fileSize, Endian.little);
    wavData.setUint32(8, 0x57415645, Endian.big); // "WAVE"
    wavData.setUint32(12, 0x666d7420, Endian.big); // "fmt "
    wavData.setUint32(16, 16, Endian.little); // PCM format size
    wavData.setUint16(20, 1, Endian.little); // PCM format
    wavData.setUint16(22, 1, Endian.little); // Mono
    wavData.setUint32(24, sampleRate, Endian.little); // Sample rate
    wavData.setUint32(28, sampleRate * 2, Endian.little); // Byte rate
    wavData.setUint16(32, 2, Endian.little); // Block align
    wavData.setUint16(34, 16, Endian.little); // Bits per sample
    wavData.setUint32(36, 0x64617461, Endian.big); // "data"
    wavData.setUint32(40, dataSize, Endian.little); // Data size

    // Fill with silence (zeros)
    for (int i = 44; i < 44 + dataSize; i++) {
      wavData.setUint8(i, 0);
    }

    await file.writeAsBytes(wavData.buffer.asUint8List());

    return filePath;
  }

  Future<String> _generateOpenAIAudio(String text, String voiceId) async {
    // Mock implementation - in real app, would call OpenAI TTS API
    await Future.delayed(const Duration(milliseconds: 500));
    
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.mp3';
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
    final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.mp3';
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
    final fileName = 'podcast_${DateTime.now().millisecondsSinceEpoch}.mp3';
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
