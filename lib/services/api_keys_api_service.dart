import '../models/api_key_models.dart';
import 'backend_api_client.dart';

class ApiKeysApiService {
  ApiKeysApiService({BackendApiClient? apiClient})
      : _client = apiClient ?? BackendApiClient();

  final BackendApiClient _client;

  Future<ApiKeyModel> createKey({
    required String token,
    required CreateApiKeyRequest request,
  }) async {
    final response = await _client.post(
      '/api-keys',
      token: token,
      body: request.toJson(),
    ) as Map<String, dynamic>;

    return ApiKeyModel.fromJson(response);
  }

  Future<List<ApiKeyModel>> listKeys(String token) async {
    final response = await _client.get(
      '/api-keys',
      token: token,
    ) as List<dynamic>;

    return response
        .map((dynamic item) => ApiKeyModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ApiKeyModel> updateKey({
    required String token,
    required String keyId,
    required UpdateApiKeyRequest request,
  }) async {
    final response = await _client.patch(
      '/api-keys/$keyId',
      token: token,
      body: request.toJson(),
    ) as Map<String, dynamic>;

    return ApiKeyModel.fromJson(response);
  }

  Future<void> deleteKey({
    required String token,
    required String keyId,
  }) async {
    await _client.delete(
      '/api-keys/$keyId',
      token: token,
    );
  }
}
