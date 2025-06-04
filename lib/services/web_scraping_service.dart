import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WebScrapingService {
  static const String _firecrawlBaseUrl = 'https://api.firecrawl.dev/v1';
  static const String _hyperbrowserBaseUrl = 'https://api.hyperbrowser.ai/api';

  // Get API keys from storage
  Future<String?> _getApiKey(String service) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('api_key_$service');
  }

  // Scrape single URL using Firecrawl
  Future<ScrapeResult> scrapeWithFirecrawl(String url, {
    List<String> formats = const ['markdown'],
    bool onlyMainContent = true,
  }) async {
    final apiKey = await _getApiKey('firecrawl');
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Firecrawl API key not found. Please configure it in settings.');
    }

    // Check if the URL is a PDF, which might cause timeout issues
    if (url.toLowerCase().endsWith('.pdf')) {
      // Add a warning for PDF files
      print('Warning: Scraping PDF files may take longer or time out');
    }

    try {
      final response = await http.post(
        Uri.parse('$_firecrawlBaseUrl/scrape'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'url': url,
          'formats': formats,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return ScrapeResult.fromFirecrawlResponse(data['data'], url);
        } else {
          throw Exception('Firecrawl API error: ${data['error'] ?? 'Unknown error'}');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Invalid Firecrawl API key. Please check your configuration.');
      } else if (response.statusCode == 402) {
        throw Exception('Firecrawl API quota exceeded. Please upgrade your plan.');
      } else if (response.statusCode == 408) {
        throw Exception('The request timed out. This may happen with large PDF files or complex pages. Try again or use a different URL.');
      } else {
        throw Exception('Firecrawl API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('Firecrawl API')) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Batch scrape multiple URLs using Firecrawl
  Future<BatchScrapeJob> batchScrapeWithFirecrawl(List<String> urls, {
    List<String> formats = const ['markdown'],
    bool onlyMainContent = true,
  }) async {
    final apiKey = await _getApiKey('firecrawl');
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Firecrawl API key not found. Please configure it in settings.');
    }

    try {
      final response = await http.post(
        Uri.parse('$_firecrawlBaseUrl/batch/scrape'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'urls': urls,
          'formats': formats,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return BatchScrapeJob(
          id: data['id'],
          service: 'firecrawl',
          urls: urls,
          status: 'pending',
          checkUrl: data['url'],
        );
      } else if (response.statusCode == 401) {
        throw Exception('Invalid Firecrawl API key. Please check your configuration.');
      } else if (response.statusCode == 402) {
        throw Exception('Batch scraping requires a premium Firecrawl plan.');
      } else {
        throw Exception('Firecrawl API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('Firecrawl API') || e.toString().contains('Batch scraping requires')) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Scrape single URL using Hyperbrowser
  Future<ScrapeResult> scrapeWithHyperbrowser(String url, {
    List<String> formats = const ['markdown'],
    bool onlyMainContent = true,
  }) async {
    final apiKey = await _getApiKey('hyperbrowser');
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Hyperbrowser API key not found. Please configure it in settings.');
    }

    try {
      // Start scrape job with correct Hyperbrowser API format
      final startResponse = await http.post(
        Uri.parse('$_hyperbrowserBaseUrl/scrape'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': apiKey,
        },
        body: jsonEncode({
          'url': url,
          'scrapeOptions': {
            'formats': formats,
            'onlyMainContent': onlyMainContent,
          }
        }),
      );

      if (startResponse.statusCode != 200) {
        if (startResponse.statusCode == 401) {
          throw Exception('Invalid Hyperbrowser API key. Please check your configuration.');
        } else if (startResponse.statusCode == 402) {
          throw Exception('Hyperbrowser API quota exceeded. Please upgrade your plan.');
        } else {
          final errorBody = startResponse.body;
          throw Exception('Hyperbrowser API error: ${startResponse.statusCode} - $errorBody');
        }
      }

      final startData = jsonDecode(startResponse.body);
      final jobId = startData['jobId'];

      // Poll for completion
      return await _pollHyperbrowserJob(jobId, apiKey, url);
    } catch (e) {
      if (e.toString().contains('Hyperbrowser API')) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Batch scrape multiple URLs using Hyperbrowser
  Future<BatchScrapeJob> batchScrapeWithHyperbrowser(List<String> urls, {
    List<String> formats = const ['markdown'],
    bool onlyMainContent = true,
  }) async {
    final apiKey = await _getApiKey('hyperbrowser');
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Hyperbrowser API key not found. Please configure it in settings.');
    }

    try {
      final response = await http.post(
        Uri.parse('$_hyperbrowserBaseUrl/scrape/batch'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': apiKey,
        },
        body: jsonEncode({
          'urls': urls,
          'scrapeOptions': {
            'formats': formats,
            'onlyMainContent': onlyMainContent,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return BatchScrapeJob(
          id: data['jobId'],
          service: 'hyperbrowser',
          urls: urls,
          status: 'pending',
          checkUrl: '$_hyperbrowserBaseUrl/scrape/batch/${data['jobId']}',
        );
      } else if (response.statusCode == 401) {
        throw Exception('Invalid Hyperbrowser API key. Please check your configuration.');
      } else if (response.statusCode == 402) {
        throw Exception('Batch scraping requires a premium Hyperbrowser plan.');
      } else {
        final errorBody = response.body;
        throw Exception('Hyperbrowser API error: ${response.statusCode} - $errorBody');
      }
    } catch (e) {
      if (e.toString().contains('Hyperbrowser API') || e.toString().contains('Batch scraping requires')) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Poll Hyperbrowser job until completion
  Future<ScrapeResult> _pollHyperbrowserJob(String jobId, String apiKey, String url) async {
    const maxAttempts = 30; // 5 minutes with 10-second intervals
    int attempts = 0;

    while (attempts < maxAttempts) {
      await Future.delayed(const Duration(seconds: 10));
      attempts++;

      try {
        final response = await http.get(
          Uri.parse('$_hyperbrowserBaseUrl/scrape/$jobId'),
          headers: {
            'x-api-key': apiKey,
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final status = data['status'];

          if (status == 'completed') {
            return ScrapeResult.fromHyperbrowserResponse(data['data'], url);
          } else if (status == 'failed') {
            final errorMessage = data['error'] ?? 'Unknown error';
            if (errorMessage.toLowerCase().contains('timeout')) {
              throw Exception('The request timed out. This may happen with large pages or complex content. Try again or use a different URL.');
            } else {
              throw Exception('Hyperbrowser scraping failed: $errorMessage');
            }
          }
          // Continue polling if status is 'pending' or 'running'
        } else {
          throw Exception('Error checking job status: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        if (attempts >= maxAttempts) {
          throw Exception('Timeout waiting for scrape completion: ${e.toString()}');
        }
        // Continue polling on network errors
      }
    }

    throw Exception('Timeout: Scraping took longer than expected. Try again with a simpler page or URL.');
  }

  // Check batch scrape job status
  Future<BatchScrapeResult> checkBatchScrapeStatus(BatchScrapeJob job) async {
    final apiKey = await _getApiKey(job.service);
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('${job.service} API key not found. Please configure it in settings.');
    }

    try {
      final headers = job.service == 'firecrawl'
          ? {'Authorization': 'Bearer $apiKey'}
          : {'x-api-key': apiKey};

      final response = await http.get(
        Uri.parse(job.checkUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return BatchScrapeResult.fromResponse(data, job.service);
      } else {
        throw Exception('Error checking batch status: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Process multiple URLs one by one (alternative to batch)
  Future<List<ScrapeResult>> scrapeMultipleUrls(
    List<String> urls,
    String service, {
    List<String> formats = const ['markdown'],
    bool onlyMainContent = true,
    Function(int, int)? onProgress,
  }) async {
    final results = <ScrapeResult>[];
    
    for (int i = 0; i < urls.length; i++) {
      try {
        final result = service == 'firecrawl'
            ? await scrapeWithFirecrawl(urls[i], formats: formats, onlyMainContent: onlyMainContent)
            : await scrapeWithHyperbrowser(urls[i], formats: formats, onlyMainContent: onlyMainContent);
        
        results.add(result);
        onProgress?.call(i + 1, urls.length);
        
        // Add delay between requests to be respectful
        if (i < urls.length - 1) {
          await Future.delayed(const Duration(seconds: 2));
        }
      } catch (e) {
        // Add failed result
        results.add(ScrapeResult(
          url: urls[i],
          title: 'Error',
          markdown: '',
          metadata: {},
          error: e.toString(),
          success: false,
        ));
        onProgress?.call(i + 1, urls.length);
      }
    }
    
    return results;
  }
}

// Data models
class ScrapeResult {
  final String url;
  final String title;
  final String markdown;
  final String? html;
  final Map<String, dynamic> metadata;
  final String? error;
  final bool success;

  ScrapeResult({
    required this.url,
    required this.title,
    required this.markdown,
    this.html,
    required this.metadata,
    this.error,
    required this.success,
  });

  factory ScrapeResult.fromFirecrawlResponse(Map<String, dynamic> data, String url) {
    return ScrapeResult(
      url: url,
      title: data['metadata']?['title'] ?? 'Untitled',
      markdown: data['markdown'] ?? '',
      html: data['html'],
      metadata: data['metadata'] ?? {},
      success: true,
    );
  }

  factory ScrapeResult.fromHyperbrowserResponse(Map<String, dynamic> data, String url) {
    return ScrapeResult(
      url: url,
      title: data['metadata']?['title'] ?? 'Untitled',
      markdown: data['markdown'] ?? '',
      html: data['html'],
      metadata: data['metadata'] ?? {},
      success: true,
    );
  }
}

class BatchScrapeJob {
  final String id;
  final String service;
  final List<String> urls;
  final String status;
  final String checkUrl;

  BatchScrapeJob({
    required this.id,
    required this.service,
    required this.urls,
    required this.status,
    required this.checkUrl,
  });
}

class BatchScrapeResult {
  final String status;
  final List<ScrapeResult> results;
  final int? total;
  final int? completed;
  final String? error;

  BatchScrapeResult({
    required this.status,
    required this.results,
    this.total,
    this.completed,
    this.error,
  });

  factory BatchScrapeResult.fromResponse(Map<String, dynamic> data, String service) {
    final results = <ScrapeResult>[];
    
    if (service == 'firecrawl') {
      final dataList = data['data'] as List<dynamic>? ?? [];
      for (final item in dataList) {
        results.add(ScrapeResult.fromFirecrawlResponse(item, item['metadata']?['sourceURL'] ?? ''));
      }
      
      return BatchScrapeResult(
        status: data['status'] ?? 'unknown',
        results: results,
        total: data['total'],
        completed: data['completed'],
      );
    } else {
      // Hyperbrowser
      final dataList = data['data'] as List<dynamic>? ?? [];
      for (final item in dataList) {
        if (item['status'] == 'completed') {
          results.add(ScrapeResult.fromHyperbrowserResponse(item, item['url'] ?? ''));
        } else {
          results.add(ScrapeResult(
            url: item['url'] ?? '',
            title: 'Error',
            markdown: '',
            metadata: {},
            error: item['error'] ?? 'Scraping failed',
            success: false,
          ));
        }
      }
      
      return BatchScrapeResult(
        status: data['status'] ?? 'unknown',
        results: results,
      );
    }
  }
}
