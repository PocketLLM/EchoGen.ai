import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/app_config.dart';
import '../models/api_exception.dart';

class BackendApiClient {
  BackendApiClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  Uri _buildUri(String path, [Map<String, dynamic>? queryParameters]) {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$path');
    if (queryParameters == null || queryParameters.isEmpty) {
      return uri;
    }
    final filtered = <String, String>{};
    queryParameters.forEach((key, value) {
      if (value == null) return;
      filtered[key] = value.toString();
    });
    return uri.replace(queryParameters: filtered);
  }

  Map<String, String> _jsonHeaders({String? token}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<dynamic> get(
    String path, {
    String? token,
    Map<String, dynamic>? queryParameters,
  }) {
    return _send(() {
      final uri = _buildUri(path, queryParameters);
      return _httpClient.get(uri, headers: _jsonHeaders(token: token));
    });
  }

  Future<dynamic> post(
    String path, {
    String? token,
    Object? body,
    Map<String, dynamic>? queryParameters,
  }) {
    return _send(() {
      final uri = _buildUri(path, queryParameters);
      return _httpClient.post(
        uri,
        headers: _jsonHeaders(token: token),
        body: body == null ? null : json.encode(body),
      );
    });
  }

  Future<dynamic> patch(
    String path, {
    String? token,
    Object? body,
    Map<String, dynamic>? queryParameters,
  }) {
    return _send(() {
      final uri = _buildUri(path, queryParameters);
      return _httpClient.patch(
        uri,
        headers: _jsonHeaders(token: token),
        body: body == null ? null : json.encode(body),
      );
    });
  }

  Future<dynamic> delete(
    String path, {
    String? token,
    Object? body,
    Map<String, dynamic>? queryParameters,
  }) {
    return _send(() {
      final uri = _buildUri(path, queryParameters);
      return _httpClient.delete(
        uri,
        headers: _jsonHeaders(token: token),
        body: body == null ? null : json.encode(body),
      );
    });
  }

  Future<dynamic> _send(Future<http.Response> Function() request) async {
    final response = await request().timeout(AppConfig.networkTimeout);
    final dynamic data = _decodeBody(response);
    _throwIfError(response, data);
    return data;
  }

  dynamic _decodeBody(http.Response response) {
    if (response.body.isEmpty) {
      return null;
    }
    try {
      return json.decode(response.body);
    } catch (_) {
      return response.body;
    }
  }

  void _throwIfError(http.Response response, dynamic body) {
    if (response.statusCode < 400) {
      return;
    }
    if (body is Map<String, dynamic>) {
      final message = body['detail'] ?? body['message'] ?? 'Request failed';
      throw ApiException(message.toString(), statusCode: response.statusCode);
    }
    if (body is String && body.isNotEmpty) {
      throw ApiException(body, statusCode: response.statusCode);
    }
    throw ApiException('Request failed', statusCode: response.statusCode);
  }
}
