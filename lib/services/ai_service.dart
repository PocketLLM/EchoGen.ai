import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AIService {
  static const String _geminiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  static const String _groqBaseUrl = 'https://api.groq.com/openai/v1';
  static const String _openaiBaseUrl = 'https://api.openai.com/v1';
  static const String _openrouterBaseUrl = 'https://openrouter.ai/api/v1';

  // Get API key from storage
  Future<String?> _getApiKey(String provider) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('api_key_${provider.toLowerCase()}');
  }

  // Get available models for a provider
  Future<List<AIModel>> getModels(String provider) async {
    final apiKey = await _getApiKey(provider);
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('$provider API key not found. Please configure it in settings.');
    }

    try {
      switch (provider.toLowerCase()) {
        case 'gemini':
          return await _getGeminiModels(apiKey);
        case 'groq':
          return await _getGroqModels(apiKey);
        case 'openai':
          return await _getOpenAIModels(apiKey);
        case 'openrouter':
          return await _getOpenRouterModels(apiKey);
        default:
          throw Exception('Unsupported provider: $provider');
      }
    } catch (e) {
      throw Exception('Failed to fetch models for $provider: ${e.toString()}');
    }
  }

  Future<List<AIModel>> _getGeminiModels(String apiKey) async {
    final response = await http.get(
      Uri.parse('$_geminiBaseUrl/models?key=$apiKey'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final models = <AIModel>[];
      
      for (final model in data['models'] ?? []) {
        final name = model['name'] as String;
        if (name.contains('gemini') && !name.contains('vision') && !name.contains('embedding')) {
          models.add(AIModel(
            id: name.split('/').last,
            name: name.split('/').last,
            contextLength: _getGeminiContextLength(name),
            provider: 'Gemini',
          ));
        }
      }
      
      return models;
    } else {
      throw Exception('Failed to fetch Gemini models: ${response.statusCode}');
    }
  }

  Future<List<AIModel>> _getGroqModels(String apiKey) async {
    final response = await http.get(
      Uri.parse('$_groqBaseUrl/models'),
      headers: {
        'Authorization': 'Bearer $apiKey',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final models = <AIModel>[];
      
      for (final model in data['data'] ?? []) {
        final id = model['id'] as String;
        if (!id.contains('whisper') && !id.contains('tts')) {
          models.add(AIModel(
            id: id,
            name: id,
            contextLength: _getGroqContextLength(id),
            provider: 'Groq',
          ));
        }
      }
      
      return models;
    } else {
      throw Exception('Failed to fetch Groq models: ${response.statusCode}');
    }
  }

  Future<List<AIModel>> _getOpenAIModels(String apiKey) async {
    final response = await http.get(
      Uri.parse('$_openaiBaseUrl/models'),
      headers: {
        'Authorization': 'Bearer $apiKey',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final models = <AIModel>[];
      
      for (final model in data['data'] ?? []) {
        final id = model['id'] as String;
        if (id.contains('gpt') && !id.contains('instruct')) {
          models.add(AIModel(
            id: id,
            name: id,
            contextLength: _getOpenAIContextLength(id),
            provider: 'OpenAI',
          ));
        }
      }
      
      return models;
    } else {
      throw Exception('Failed to fetch OpenAI models: ${response.statusCode}');
    }
  }

  Future<List<AIModel>> _getOpenRouterModels(String apiKey) async {
    final response = await http.get(
      Uri.parse('$_openrouterBaseUrl/models'),
      headers: {
        'Authorization': 'Bearer $apiKey',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final models = <AIModel>[];
      
      for (final model in data['data'] ?? []) {
        final id = model['id'] as String;
        final contextLength = model['context_length'] as int? ?? 4096;
        
        models.add(AIModel(
          id: id,
          name: model['name'] ?? id,
          contextLength: contextLength,
          provider: 'OpenRouter',
        ));
      }
      
      return models;
    } else {
      throw Exception('Failed to fetch OpenRouter models: ${response.statusCode}');
    }
  }

  // Generate script using the selected provider and model
  Future<String> generateScript({
    required String provider,
    required String model,
    required String systemPrompt,
    required String userPrompt,
    required String content,
  }) async {
    final apiKey = await _getApiKey(provider);
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('$provider API key not found. Please configure it in settings.');
    }

    try {
      switch (provider.toLowerCase()) {
        case 'gemini':
          return await _generateWithGemini(apiKey, model, systemPrompt, userPrompt, content);
        case 'groq':
          return await _generateWithGroq(apiKey, model, systemPrompt, userPrompt, content);
        case 'openai':
          return await _generateWithOpenAI(apiKey, model, systemPrompt, userPrompt, content);
        case 'openrouter':
          return await _generateWithOpenRouter(apiKey, model, systemPrompt, userPrompt, content);
        default:
          throw Exception('Unsupported provider: $provider');
      }
    } catch (e) {
      throw Exception('Failed to generate script: ${e.toString()}');
    }
  }

  Future<String> _generateWithGemini(String apiKey, String model, String systemPrompt, String userPrompt, String content) async {
    print('🤖 [AI Service] Generating with Gemini model: $model');

    final response = await http.post(
      Uri.parse('$_geminiBaseUrl/models/$model:generateContent?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'system_instruction': {
          'parts': [{'text': systemPrompt}]
        },
        'contents': [
          {
            'parts': [
              {'text': '$userPrompt\n\nContent to convert:\n$content'}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.7,
          'maxOutputTokens': 8192,
        }
      }),
    );

    print('🌐 [AI Service] Gemini API response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['candidates'] != null && data['candidates'].isNotEmpty) {
        final rawResponse = data['candidates'][0]['content']['parts'][0]['text'];
        print('📝 [AI Service] Raw response length: ${rawResponse.length} characters');
        print('📝 [AI Service] Raw response preview: ${rawResponse.substring(0, rawResponse.length > 200 ? 200 : rawResponse.length)}...');

        final processedResponse = _processThinkingModel(rawResponse);
        print('✅ [AI Service] Processed response length: ${processedResponse.length} characters');

        if (processedResponse.trim().isEmpty) {
          print('⚠️ [AI Service] Warning: Processed response is empty, returning raw response');
          return rawResponse;
        }

        return processedResponse;
      } else {
        throw Exception('No response generated from Gemini');
      }
    } else {
      print('❌ [AI Service] Gemini API error: ${response.statusCode} - ${response.body}');
      throw Exception('Gemini API error: ${response.statusCode} - ${response.body}');
    }
  }

  Future<String> _generateWithGroq(String apiKey, String model, String systemPrompt, String userPrompt, String content) async {
    print('🤖 [AI Service] Generating with Groq model: $model');

    final response = await http.post(
      Uri.parse('$_groqBaseUrl/chat/completions'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': model,
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': '$userPrompt\n\nContent to convert:\n$content'},
        ],
        'temperature': 0.7,
        'max_tokens': 8192,
      }),
    );

    print('🌐 [AI Service] Groq API response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final rawResponse = data['choices'][0]['message']['content'];
      print('📝 [AI Service] Raw response length: ${rawResponse.length} characters');
      print('📝 [AI Service] Raw response preview: ${rawResponse.substring(0, rawResponse.length > 200 ? 200 : rawResponse.length)}...');

      final processedResponse = _processThinkingModel(rawResponse);
      print('✅ [AI Service] Processed response length: ${processedResponse.length} characters');

      if (processedResponse.trim().isEmpty) {
        print('⚠️ [AI Service] Warning: Processed response is empty, returning raw response');
        return rawResponse;
      }

      return processedResponse;
    } else {
      print('❌ [AI Service] Groq API error: ${response.statusCode} - ${response.body}');
      throw Exception('Groq API error: ${response.statusCode} - ${response.body}');
    }
  }

  Future<String> _generateWithOpenAI(String apiKey, String model, String systemPrompt, String userPrompt, String content) async {
    print('🤖 [AI Service] Generating with OpenAI model: $model');

    final response = await http.post(
      Uri.parse('$_openaiBaseUrl/chat/completions'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': model,
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': '$userPrompt\n\nContent to convert:\n$content'},
        ],
        'temperature': 0.7,
        'max_tokens': 8192,
      }),
    );

    print('🌐 [AI Service] OpenAI API response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final rawResponse = data['choices'][0]['message']['content'];
      print('📝 [AI Service] Raw response length: ${rawResponse.length} characters');
      print('📝 [AI Service] Raw response preview: ${rawResponse.substring(0, rawResponse.length > 200 ? 200 : rawResponse.length)}...');

      final processedResponse = _processThinkingModel(rawResponse);
      print('✅ [AI Service] Processed response length: ${processedResponse.length} characters');

      if (processedResponse.trim().isEmpty) {
        print('⚠️ [AI Service] Warning: Processed response is empty, returning raw response');
        return rawResponse;
      }

      return processedResponse;
    } else {
      print('❌ [AI Service] OpenAI API error: ${response.statusCode} - ${response.body}');
      throw Exception('OpenAI API error: ${response.statusCode} - ${response.body}');
    }
  }

  Future<String> _generateWithOpenRouter(String apiKey, String model, String systemPrompt, String userPrompt, String content) async {
    print('🤖 [AI Service] Generating with OpenRouter model: $model');

    final response = await http.post(
      Uri.parse('$_openrouterBaseUrl/chat/completions'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
        'HTTP-Referer': 'https://echogen.ai',
        'X-Title': 'EchoGen.ai',
      },
      body: jsonEncode({
        'model': model,
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': '$userPrompt\n\nContent to convert:\n$content'},
        ],
        'temperature': 0.7,
        'max_tokens': 8192,
      }),
    );

    print('🌐 [AI Service] OpenRouter API response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final rawResponse = data['choices'][0]['message']['content'];
      print('📝 [AI Service] Raw response length: ${rawResponse.length} characters');
      print('📝 [AI Service] Raw response preview: ${rawResponse.substring(0, rawResponse.length > 200 ? 200 : rawResponse.length)}...');

      final processedResponse = _processThinkingModel(rawResponse);
      print('✅ [AI Service] Processed response length: ${processedResponse.length} characters');

      if (processedResponse.trim().isEmpty) {
        print('⚠️ [AI Service] Warning: Processed response is empty, returning raw response');
        return rawResponse;
      }

      return processedResponse;
    } else {
      print('❌ [AI Service] OpenRouter API error: ${response.statusCode} - ${response.body}');
      throw Exception('OpenRouter API error: ${response.statusCode} - ${response.body}');
    }
  }

  // Helper methods to get context lengths
  int _getGeminiContextLength(String model) {
    if (model.contains('2.0')) return 2000000;
    if (model.contains('1.5')) return 1000000;
    return 32768;
  }

  int _getGroqContextLength(String id) {
    if (id.contains('llama-3.3-70b')) return 128000;
    if (id.contains('llama-3.1')) return 128000;
    if (id.contains('8192')) return 8192;
    return 4096;
  }

  int _getOpenAIContextLength(String id) {
    if (id.contains('gpt-4')) return 128000;
    if (id.contains('gpt-3.5')) return 16385;
    return 4096;
  }

  // Check if content fits in model's context window
  bool canHandleContent(String content, int contextLength) {
    // Rough estimation: 1 token ≈ 4 characters
    final estimatedTokens = content.length ~/ 4;
    // Reserve 2000 tokens for system prompt and response
    return estimatedTokens < (contextLength - 2000);
  }

  // Process thinking models to extract only the actual script content
  String _processThinkingModel(String rawResponse) {
    print('🧠 [AI Service] Processing thinking model response...');
    print('🧠 [AI Service] Original length: ${rawResponse.length} characters');

    // Store original for fallback
    final originalResponse = rawResponse;
    String processed = rawResponse;

    // Remove thinking tags and content for models like QwQ, DeepSeek, etc.
    final thinkingTagsRemoved = processed.replaceAll(RegExp(r'<thinking>.*?</thinking>', dotAll: true), '');
    if (thinkingTagsRemoved.length != processed.length) {
      print('🧠 [AI Service] Removed <thinking> tags, new length: ${thinkingTagsRemoved.length}');
      processed = thinkingTagsRemoved;
    }

    // Remove <think>...</think> blocks
    final thinkTagsRemoved = processed.replaceAll(RegExp(r'<think>.*?</think>', dotAll: true), '');
    if (thinkTagsRemoved.length != processed.length) {
      print('🧠 [AI Service] Removed <think> tags, new length: ${thinkTagsRemoved.length}');
      processed = thinkTagsRemoved;
    }

    // More conservative removal of reasoning blocks - only if they're clearly at the start
    final reasoningPatterns = [
      RegExp(r'^Let me think.*?(?=\n\n)', dotAll: true, multiLine: true),
      RegExp(r'^I need to.*?(?=\n\n)', dotAll: true, multiLine: true),
      RegExp(r'^First, I.*?(?=\n\n)', dotAll: true, multiLine: true),
    ];

    for (final pattern in reasoningPatterns) {
      final beforeRemoval = processed.length;
      processed = processed.replaceAll(pattern, '');
      if (processed.length != beforeRemoval) {
        print('🧠 [AI Service] Removed reasoning pattern, new length: ${processed.length}');
      }
    }

    // More conservative line-by-line filtering
    final lines = processed.split('\n');
    final filteredLines = <String>[];
    bool inThinkingBlock = false;
    int removedLines = 0;

    for (String line in lines) {
      final trimmedLine = line.trim();

      // Skip empty lines at the beginning only
      if (filteredLines.isEmpty && trimmedLine.isEmpty) continue;

      // Detect thinking patterns - be more specific
      if (trimmedLine.startsWith('*thinking*') ||
          trimmedLine.startsWith('*reasoning*') ||
          trimmedLine.startsWith('*analysis*') ||
          trimmedLine.startsWith('Let me think') ||
          trimmedLine.startsWith('I need to think')) {
        inThinkingBlock = true;
        removedLines++;
        continue;
      }

      // End of thinking block - look for clear script indicators
      if (inThinkingBlock && (
          trimmedLine.startsWith('**') ||  // Bold text (likely title)
          trimmedLine.startsWith('#') ||   // Markdown header
          trimmedLine.contains('Speaker') ||  // Speaker indicators
          trimmedLine.contains(':') && trimmedLine.length > 10)) {  // Dialogue
        inThinkingBlock = false;
      }

      // Skip lines that are clearly thinking
      if (inThinkingBlock) {
        removedLines++;
        continue;
      }

      filteredLines.add(line);
    }

    if (removedLines > 0) {
      print('🧠 [AI Service] Removed $removedLines lines of thinking content');
    }

    processed = filteredLines.join('\n').trim();

    // Clean up extra whitespace
    processed = processed.replaceAll(RegExp(r'\n\s*\n\s*\n'), '\n\n');

    print('🧠 [AI Service] Final processed length: ${processed.length} characters');

    // Safety check - if we removed too much content, return original
    if (processed.length < originalResponse.length * 0.3) {
      print('⚠️ [AI Service] Warning: Processed response is too short (${processed.length} vs ${originalResponse.length}), returning original');
      return originalResponse;
    }

    // Additional safety check - ensure we have some meaningful content
    if (processed.trim().length < 50) {
      print('⚠️ [AI Service] Warning: Processed response is too short, returning original');
      return originalResponse;
    }

    return processed;
  }

  // Extract title from generated script
  String extractTitleFromScript(String script) {
    print('🏷️ [AI Service] Extracting title from script...');

    // Look for title patterns in the script
    final titlePatterns = [
      RegExp(r'^Title:\s*(.+)$', caseSensitive: false, multiLine: true), // Most specific first
      RegExp(r'(?:Title|TITLE):\s*(.+)', caseSensitive: false),
      RegExp(r'(?:Episode|EPISODE):\s*(.+)', caseSensitive: false),
      RegExp(r'(?:Podcast|PODCAST):\s*(.+)', caseSensitive: false),
      RegExp(r'^#\s*(.+)$', multiLine: true), // Markdown header at start of line
      RegExp(r'^\*\*(.+?)\*\*$', multiLine: true), // Bold text on its own line
    ];

    for (int i = 0; i < titlePatterns.length; i++) {
      final pattern = titlePatterns[i];
      final match = pattern.firstMatch(script);
      if (match != null && match.group(1) != null) {
        String title = match.group(1)!.trim();
        // Clean up the title
        title = title.replaceAll('*', '').replaceAll('#', '').replaceAll('"', '').replaceAll("'", '').trim();
        title = title.replaceAll(RegExp(r'\s+'), ' '); // Normalize whitespace

        if (title.isNotEmpty && title.length >= 5 && title.length <= 150) {
          print('🏷️ [AI Service] Found title with pattern ${i + 1}: "$title"');
          return title;
        }
      }
    }

    // If no explicit title found, try to extract from first meaningful line
    final lines = script.split('\n');
    for (int i = 0; i < lines.length && i < 10; i++) { // Check first 10 lines only
      final trimmedLine = lines[i].trim();
      if (trimmedLine.isNotEmpty &&
          !trimmedLine.toLowerCase().contains('speaker') &&
          !trimmedLine.toLowerCase().contains(':') &&
          !trimmedLine.startsWith('[') &&
          !trimmedLine.startsWith('(') &&
          !trimmedLine.startsWith('*') &&
          !trimmedLine.startsWith('#') &&
          trimmedLine.length >= 10 &&
          trimmedLine.length <= 150) {
        final cleanTitle = trimmedLine
            .replaceAll('*', '')
            .replaceAll('#', '')
            .replaceAll(':', '')
            .replaceAll('"', '')
            .replaceAll("'", '')
            .trim();
        if (cleanTitle.isNotEmpty) {
          print('🏷️ [AI Service] Found title from line ${i + 1}: "$cleanTitle"');
          return cleanTitle;
        }
      }
    }

    print('🏷️ [AI Service] No title found in script');
    return '';
  }
}

class AIModel {
  final String id;
  final String name;
  final int contextLength;
  final String provider;

  AIModel({
    required this.id,
    required this.name,
    required this.contextLength,
    required this.provider,
  });
}
