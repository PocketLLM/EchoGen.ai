import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

/// Service for generating podcast cover art using ImageRouter API
class ImageRouterService {
  static const String _baseUrl = 'https://api.imagerouter.io';
  static const String _apiKeyKey = 'image_router_api_key';
  
  /// Get available models from ImageRouter
  Future<List<ImageModel>> getAvailableModels() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/v1/models'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final models = <ImageModel>[];
        
        // Parse the models response
        if (data is Map && data['data'] is List) {
          for (final model in data['data']) {
            if (model['type'] == 'image' && model['id'] != null) {
              models.add(ImageModel.fromJson(model));
            }
          }
        }
        
        // Add some default models if none found
        if (models.isEmpty) {
          models.addAll([
            ImageModel(
              id: 'openai/dall-e-3',
              name: 'DALL-E 3',
              description: 'High-quality image generation',
              provider: 'OpenAI',
            ),
            ImageModel(
              id: 'stability-ai/stable-diffusion-xl',
              name: 'Stable Diffusion XL',
              description: 'Fast and creative image generation',
              provider: 'Stability AI',
            ),
            ImageModel(
              id: 'midjourney/midjourney',
              name: 'Midjourney',
              description: 'Artistic and creative image generation',
              provider: 'Midjourney',
            ),
          ]);
        }
        
        return models;
      } else {
        throw Exception('Failed to fetch models: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching ImageRouter models: $e');
      // Return default models on error
      return [
        ImageModel(
          id: 'openai/dall-e-3',
          name: 'DALL-E 3',
          description: 'High-quality image generation',
          provider: 'OpenAI',
        ),
        ImageModel(
          id: 'stability-ai/stable-diffusion-xl',
          name: 'Stable Diffusion XL',
          description: 'Fast and creative image generation',
          provider: 'Stability AI',
        ),
      ];
    }
  }

  /// Generate cover art for a podcast
  Future<String?> generateCoverArt({
    required String prompt,
    required String modelId,
    String quality = 'auto',
    String size = '1024x1024',
    String? podcastTitle,
  }) async {
    try {
      final apiKey = await getApiKey();
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('ImageRouter API key not configured');
      }

      // Enhanced prompt for podcast cover art
      final enhancedPrompt = _enhancePromptForPodcast(prompt, podcastTitle);
      
      final response = await http.post(
        Uri.parse('$_baseUrl/v1/openai/images/generations'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'prompt': enhancedPrompt,
          'model': modelId,
          'quality': quality,
          'size': size,
          'response_format': 'url',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['data'] != null && data['data'].isNotEmpty) {
          final imageUrl = data['data'][0]['url'];
          
          // Download and save the image locally
          final localPath = await _downloadAndSaveImage(imageUrl, podcastTitle);
          return localPath;
        } else {
          throw Exception('No image generated');
        }
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['error']?['message'] ?? 'Unknown error';
        throw Exception('ImageRouter API error: $errorMessage');
      }
    } catch (e) {
      print('Error generating cover art: $e');
      rethrow;
    }
  }

  /// Download image from URL and save locally
  Future<String> _downloadAndSaveImage(String imageUrl, String? podcastTitle) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final coverArtDir = Directory('${directory.path}/cover_art');
        
        if (!await coverArtDir.exists()) {
          await coverArtDir.create(recursive: true);
        }
        
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final sanitizedTitle = podcastTitle?.replaceAll(RegExp(r'[^\w\s-]'), '') ?? 'podcast';
        final filename = '${sanitizedTitle}_$timestamp.png';
        final file = File('${coverArtDir.path}/$filename');
        
        await file.writeAsBytes(response.bodyBytes);
        return file.path;
      } else {
        throw Exception('Failed to download image: ${response.statusCode}');
      }
    } catch (e) {
      print('Error downloading image: $e');
      rethrow;
    }
  }

  /// Enhance prompt specifically for podcast cover art
  String _enhancePromptForPodcast(String basePrompt, String? podcastTitle) {
    final titlePart = podcastTitle != null ? ' for "$podcastTitle"' : '';
    
    return '''Create a professional podcast cover art$titlePart. $basePrompt. 
    Style: Modern, clean, professional podcast cover design with good typography space. 
    Format: Square aspect ratio, high contrast, readable from small sizes. 
    Quality: High resolution, vibrant colors, podcast-appropriate aesthetic.''';
  }

  /// Save API key
  Future<void> saveApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyKey, apiKey);
  }

  /// Get saved API key
  Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyKey);
  }

  /// Check if API key is configured
  Future<bool> hasApiKey() async {
    final apiKey = await getApiKey();
    return apiKey != null && apiKey.isNotEmpty;
  }

  /// Validate API key by making a test request
  Future<bool> validateApiKey(String apiKey) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/v1/models'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error validating API key: $e');
      return false;
    }
  }

  /// Get user's rate limits and balance info
  Future<Map<String, dynamic>?> getRateLimits() async {
    try {
      final apiKey = await getApiKey();
      if (apiKey == null) return null;

      // This would typically be available in the API response headers
      // For now, return default info
      return {
        'imageGeneration': '6 req/s',
        'videoGeneration': '1 req/s',
        'balance': 'Check dashboard',
      };
    } catch (e) {
      print('Error getting rate limits: $e');
      return null;
    }
  }
}

/// Model representing an available image generation model
class ImageModel {
  final String id;
  final String name;
  final String description;
  final String provider;
  final List<String>? supportedSizes;
  final List<String>? supportedQualities;

  ImageModel({
    required this.id,
    required this.name,
    required this.description,
    required this.provider,
    this.supportedSizes,
    this.supportedQualities,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      id: json['id'] ?? '',
      name: json['name'] ?? json['id'] ?? '',
      description: json['description'] ?? '',
      provider: json['owned_by'] ?? 'Unknown',
      supportedSizes: json['supported_sizes']?.cast<String>(),
      supportedQualities: json['supported_qualities']?.cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'provider': provider,
      'supportedSizes': supportedSizes,
      'supportedQualities': supportedQualities,
    };
  }

  @override
  String toString() => '$name ($provider)';
}

/// Exception for ImageRouter-related errors
class ImageRouterException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;

  ImageRouterException(this.message, {this.statusCode, this.errorCode});

  @override
  String toString() => 'ImageRouterException: $message';
}
