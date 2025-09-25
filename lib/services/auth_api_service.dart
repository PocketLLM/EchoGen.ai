import 'package:http/http.dart' as http;

import '../models/auth_models.dart';
import 'backend_api_client.dart';

class AuthApiService {
  AuthApiService({BackendApiClient? apiClient, http.Client? httpClient})
      : _client = apiClient ?? BackendApiClient(httpClient: httpClient);

  final BackendApiClient _client;

  Future<AuthResponseModel> signIn({
    required String identifier,
    required String password,
  }) async {
    final response = await _client.post(
      '/auth/signin',
      body: {
        'method': 'email',
        'email': identifier,
        'password': password,
      },
    ) as Map<String, dynamic>;

    return AuthResponseModel.fromJson(response);
  }

  Future<AuthResponseModel> signUp({
    required String email,
    required String password,
    required String? fullName,
  }) async {
    final response = await _client.post(
      '/auth/signup',
      body: {
        'method': 'email',
        'email': email,
        'password': password,
        if (fullName != null && fullName.isNotEmpty) 'fullName': fullName,
      },
    ) as Map<String, dynamic>;

    return AuthResponseModel.fromJson(response);
  }

  Future<UserProfileModel> fetchCurrentUser(String token) async {
    final response = await _client.get(
      '/auth/me',
      token: token,
    ) as Map<String, dynamic>;

    return UserProfileModel.fromJson(response);
  }

  Future<UserProfileModel> refreshUser(String userId, String token) async {
    final response = await _client.get(
      '/auth/users/$userId',
      token: token,
    ) as Map<String, dynamic>;

    return UserProfileModel.fromJson(response);
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

    final response = await _client.patch(
      '/auth/profile',
      token: token,
      body: payload,
    ) as Map<String, dynamic>;

    return UserProfileModel.fromJson(response);
  }

  Future<UserProfileModel> submitOnboarding({
    required String token,
    required List<OnboardingAnswerModel> responses,
  }) async {
    final response = await _client.post(
      '/auth/onboarding',
      token: token,
      body: {
        'responses': responses.map((e) => e.toJson()).toList(),
      },
    ) as Map<String, dynamic>;

    return UserProfileModel.fromJson(response);
  }

  Future<AccountDeletionStatusModel> scheduleAccountDeletion(String token) async {
    final response = await _client.delete(
      '/auth/account',
      token: token,
    ) as Map<String, dynamic>;

    return AccountDeletionStatusModel.fromJson(response);
  }

  Future<AccountDeletionStatusModel?> cancelAccountDeletion(String token) async {
    final response = await _client.post(
      '/auth/account/cancel',
      token: token,
    );

    if (response == null) {
      return null;
    }

    final data = response as Map<String, dynamic>;
    if (data.isEmpty) {
      return null;
    }

    return AccountDeletionStatusModel.fromJson(data);
  }

  Future<void> signOut(String token) async {
    await _client.post(
      '/auth/signout',
      token: token,
    );
  }
}
