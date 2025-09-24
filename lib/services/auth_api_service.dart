import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/app_config.dart';
import '../models/auth_models.dart';

class AuthApiService {
  AuthApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Uri _buildUri(String path) => Uri.parse('${AppConfig.apiBaseUrl}$path');

  Map<String, String> _jsonHeaders({String? token}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<AuthResponseModel> signIn({
    required String identifier,
    required String password,
  }) async {
    final response = await _client
        .post(
          _buildUri('/auth/signin'),
          headers: _jsonHeaders(),
          body: json.encode({
            'method': 'email',
            'email': identifier,
            'password': password,
          }),
        )
        .timeout(AppConfig.networkTimeout);

    final Map<String, dynamic> body = _decodeBody(response);
    _throwIfError(response, body);

    return AuthResponseModel.fromJson(body);
  }

  Future<AuthResponseModel> signUp({
    required String email,
    required String password,
    required String? fullName,
  }) async {
    final response = await _client
        .post(
          _buildUri('/auth/signup'),
          headers: _jsonHeaders(),
          body: json.encode({
            'method': 'email',
            'email': email,
            'password': password,
            if (fullName != null && fullName.isNotEmpty) 'fullName': fullName,
          }),
        )
        .timeout(AppConfig.networkTimeout);

    final Map<String, dynamic> body = _decodeBody(response);
    _throwIfError(response, body);

    return AuthResponseModel.fromJson(body);
  }

  Future<UserProfileModel> fetchCurrentUser(String token) async {
    final response = await _client
        .get(
          _buildUri('/auth/me'),
          headers: _jsonHeaders(token: token),
        )
        .timeout(AppConfig.networkTimeout);

    final Map<String, dynamic> body = _decodeBody(response);
    _throwIfError(response, body);

    return UserProfileModel.fromJson(body);
  }

  Future<UserProfileModel> refreshUser(String userId, String token) async {
    final response = await _client
        .get(
          _buildUri('/auth/users/$userId'),
          headers: _jsonHeaders(token: token),
        )
        .timeout(AppConfig.networkTimeout);

    final Map<String, dynamic> body = _decodeBody(response);
    _throwIfError(response, body);

    return UserProfileModel.fromJson(body);
  }

  Future<UserProfileModel> updateProfile({
    required String token,
    String? fullName,
    String? avatarUrl,
    String? bio,
    Map<String, dynamic>? preferences,
  }) async {
    final payload = <String, dynamic>{};
    if (fullName != null) payload['fullName'] = fullName;
    if (avatarUrl != null) payload['avatarUrl'] = avatarUrl;
    if (bio != null) payload['bio'] = bio;
    if (preferences != null) payload['preferences'] = preferences;

    final response = await _client
        .patch(
          _buildUri('/auth/profile'),
          headers: _jsonHeaders(token: token),
          body: json.encode(payload),
        )
        .timeout(AppConfig.networkTimeout);

    final Map<String, dynamic> body = _decodeBody(response);
    _throwIfError(response, body);

    return UserProfileModel.fromJson(body);
  }

  Future<UserProfileModel> submitOnboarding({
    required String token,
    required List<OnboardingAnswerModel> responses,
  }) async {
    final response = await _client
        .post(
          _buildUri('/auth/onboarding'),
          headers: _jsonHeaders(token: token),
          body: json.encode({
            'responses': responses.map((e) => e.toJson()).toList(),
          }),
        )
        .timeout(AppConfig.networkTimeout);

    final Map<String, dynamic> body = _decodeBody(response);
    _throwIfError(response, body);

    return UserProfileModel.fromJson(body);
  }

  Future<AccountDeletionStatusModel> scheduleAccountDeletion(String token) async {
    final response = await _client
        .delete(
          _buildUri('/auth/account'),
          headers: _jsonHeaders(token: token),
        )
        .timeout(AppConfig.networkTimeout);

    final Map<String, dynamic> body = _decodeBody(response);
    _throwIfError(response, body);

    return AccountDeletionStatusModel.fromJson(body);
  }

  Future<AccountDeletionStatusModel?> cancelAccountDeletion(String token) async {
    final response = await _client
        .post(
          _buildUri('/auth/account/cancel'),
          headers: _jsonHeaders(token: token),
        )
        .timeout(AppConfig.networkTimeout);

    if (response.statusCode == 204 || response.body.isEmpty) {
      return null;
    }

    final Map<String, dynamic> body = _decodeBody(response);
    _throwIfError(response, body);

    if (body.isEmpty) {
      return null;
    }

    return AccountDeletionStatusModel.fromJson(body);
  }

  Future<void> signOut(String token) async {
    final response = await _client
        .post(
          _buildUri('/auth/signout'),
          headers: _jsonHeaders(token: token),
        )
        .timeout(AppConfig.networkTimeout);

    if (response.statusCode >= 400) {
      final Map<String, dynamic> body = _decodeBody(response);
      _throwIfError(response, body);
    }
  }

  Map<String, dynamic> _decodeBody(http.Response response) {
    if (response.body.isEmpty) {
      return <String, dynamic>{};
    }
    try {
      final dynamic decoded = json.decode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return <String, dynamic>{'data': decoded};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  void _throwIfError(http.Response response, Map<String, dynamic> body) {
    if (response.statusCode >= 400) {
      final message = body['detail'] ?? body['message'] ?? 'Request failed';
      throw ApiException(message.toString(), statusCode: response.statusCode);
    }
  }
}
