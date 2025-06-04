import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:echogenai/services/web_scraping_service.dart';

class StorageService {
  static const String _scrapedUrlsKey = 'scraped_urls';
  static const String _generatedScriptsKey = 'generated_scripts';
  static const String _generatedPodcastsKey = 'generated_podcasts';

  // Save scraped URL content
  Future<void> saveScrapedUrl(ScrapedUrlData urlData) async {
    final prefs = await SharedPreferences.getInstance();
    final existingData = await getScrapedUrls();
    
    // Remove existing entry with same URL to avoid duplicates
    existingData.removeWhere((item) => item.url == urlData.url);
    
    // Add new entry at the beginning
    existingData.insert(0, urlData);
    
    // Keep only last 50 entries
    if (existingData.length > 50) {
      existingData.removeRange(50, existingData.length);
    }
    
    final jsonList = existingData.map((item) => item.toJson()).toList();
    await prefs.setString(_scrapedUrlsKey, jsonEncode(jsonList));
  }

  // Get all scraped URLs
  Future<List<ScrapedUrlData>> getScrapedUrls() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_scrapedUrlsKey);
    
    if (jsonString == null) return [];
    
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => ScrapedUrlData.fromJson(json)).toList();
  }

  // Save generated script
  Future<void> saveGeneratedScript(GeneratedScript script) async {
    final prefs = await SharedPreferences.getInstance();
    final existingScripts = await getGeneratedScripts();
    
    // Add new script at the beginning
    existingScripts.insert(0, script);
    
    // Keep only last 50 entries
    if (existingScripts.length > 50) {
      existingScripts.removeRange(50, existingScripts.length);
    }
    
    final jsonList = existingScripts.map((script) => script.toJson()).toList();
    await prefs.setString(_generatedScriptsKey, jsonEncode(jsonList));
  }

  // Get all generated scripts
  Future<List<GeneratedScript>> getGeneratedScripts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_generatedScriptsKey);
    
    if (jsonString == null) return [];
    
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => GeneratedScript.fromJson(json)).toList();
  }

  // Save generated podcast
  Future<void> saveGeneratedPodcast(GeneratedPodcast podcast) async {
    final prefs = await SharedPreferences.getInstance();
    final existingPodcasts = await getGeneratedPodcasts();
    
    // Add new podcast at the beginning
    existingPodcasts.insert(0, podcast);
    
    // Keep only last 30 entries
    if (existingPodcasts.length > 30) {
      existingPodcasts.removeRange(30, existingPodcasts.length);
    }
    
    final jsonList = existingPodcasts.map((podcast) => podcast.toJson()).toList();
    await prefs.setString(_generatedPodcastsKey, jsonEncode(jsonList));
  }

  // Get all generated podcasts
  Future<List<GeneratedPodcast>> getGeneratedPodcasts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_generatedPodcastsKey);

    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => GeneratedPodcast.fromJson(json)).toList();
  }

  // Delete a specific generated script
  Future<void> deleteGeneratedScript(String scriptId) async {
    final prefs = await SharedPreferences.getInstance();
    final existingScripts = await getGeneratedScripts();

    // Remove the script with the matching ID
    existingScripts.removeWhere((script) => script.id == scriptId);

    final jsonList = existingScripts.map((script) => script.toJson()).toList();
    await prefs.setString(_generatedScriptsKey, jsonEncode(jsonList));
  }

  // Delete a specific generated podcast
  Future<void> deleteGeneratedPodcast(String podcastId) async {
    final prefs = await SharedPreferences.getInstance();
    final existingPodcasts = await getGeneratedPodcasts();

    // Remove the podcast with the matching ID
    existingPodcasts.removeWhere((podcast) => podcast.id == podcastId);

    final jsonList = existingPodcasts.map((podcast) => podcast.toJson()).toList();
    await prefs.setString(_generatedPodcastsKey, jsonEncode(jsonList));
  }

  // Delete a specific scraped URL
  Future<void> deleteScrapedUrl(String urlId) async {
    final prefs = await SharedPreferences.getInstance();
    final existingUrls = await getScrapedUrls();

    // Remove the URL with the matching ID
    existingUrls.removeWhere((url) => url.id == urlId);

    final jsonList = existingUrls.map((url) => url.toJson()).toList();
    await prefs.setString(_scrapedUrlsKey, jsonEncode(jsonList));
  }

  // Clear all data (for debugging)
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_scrapedUrlsKey);
    await prefs.remove(_generatedScriptsKey);
    await prefs.remove(_generatedPodcastsKey);
  }
}

// Data models
class ScrapedUrlData {
  final String id;
  final String url;
  final String title;
  final String content;
  final String provider;
  final DateTime scrapedAt;
  final Map<String, dynamic> metadata;

  ScrapedUrlData({
    required this.id,
    required this.url,
    required this.title,
    required this.content,
    required this.provider,
    required this.scrapedAt,
    required this.metadata,
  });

  factory ScrapedUrlData.fromScrapeResult(ScrapeResult result, String provider) {
    return ScrapedUrlData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      url: result.url,
      title: result.title,
      content: result.markdown,
      provider: provider,
      scrapedAt: DateTime.now(),
      metadata: result.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'title': title,
      'content': content,
      'provider': provider,
      'scrapedAt': scrapedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory ScrapedUrlData.fromJson(Map<String, dynamic> json) {
    return ScrapedUrlData(
      id: json['id'],
      url: json['url'],
      title: json['title'],
      content: json['content'],
      provider: json['provider'],
      scrapedAt: DateTime.parse(json['scrapedAt']),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}

class GeneratedScript {
  final String id;
  final String script;
  final String sourceTitle;
  final String sourceUrl;
  final String category;
  final String speaker1;
  final String speaker2;
  final String provider;
  final String model;
  final DateTime generatedAt;

  GeneratedScript({
    required this.id,
    required this.script,
    required this.sourceTitle,
    required this.sourceUrl,
    required this.category,
    required this.speaker1,
    required this.speaker2,
    required this.provider,
    required this.model,
    required this.generatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'script': script,
      'sourceTitle': sourceTitle,
      'sourceUrl': sourceUrl,
      'category': category,
      'speaker1': speaker1,
      'speaker2': speaker2,
      'provider': provider,
      'model': model,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }

  factory GeneratedScript.fromJson(Map<String, dynamic> json) {
    return GeneratedScript(
      id: json['id'],
      script: json['script'],
      sourceTitle: json['sourceTitle'],
      sourceUrl: json['sourceUrl'],
      category: json['category'],
      speaker1: json['speaker1'],
      speaker2: json['speaker2'],
      provider: json['provider'],
      model: json['model'],
      generatedAt: DateTime.parse(json['generatedAt']),
    );
  }
}

class GeneratedPodcast {
  final String id;
  final String title;
  final String scriptId;
  final String audioPath;
  final String status; // 'generating', 'completed', 'failed'
  final DateTime generatedAt;
  final Map<String, dynamic> metadata;

  GeneratedPodcast({
    required this.id,
    required this.title,
    required this.scriptId,
    required this.audioPath,
    required this.status,
    required this.generatedAt,
    required this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'scriptId': scriptId,
      'audioPath': audioPath,
      'status': status,
      'generatedAt': generatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory GeneratedPodcast.fromJson(Map<String, dynamic> json) {
    return GeneratedPodcast(
      id: json['id'],
      title: json['title'],
      scriptId: json['scriptId'],
      audioPath: json['audioPath'],
      status: json['status'],
      generatedAt: DateTime.parse(json['generatedAt']),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}
