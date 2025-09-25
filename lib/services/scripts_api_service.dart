import '../models/script_models.dart';
import 'backend_api_client.dart';

class ScriptsApiService {
  ScriptsApiService({BackendApiClient? apiClient})
      : _client = apiClient ?? BackendApiClient();

  final BackendApiClient _client;

  Future<ScriptModel> createScript({
    required String token,
    required CreateScriptRequest request,
  }) async {
    final response = await _client.post(
      '/scripts',
      token: token,
      body: request.toJson(),
    ) as Map<String, dynamic>;

    return ScriptModel.fromJson(response);
  }

  Future<List<ScriptModel>> listScripts({
    required String token,
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _client.get(
      '/scripts',
      token: token,
      queryParameters: {
        'limit': limit,
        'offset': offset,
      },
    ) as List<dynamic>;

    return response
        .map((dynamic item) => ScriptModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ScriptModel> getScript({
    required String token,
    required String scriptId,
  }) async {
    final response = await _client.get(
      '/scripts/$scriptId',
      token: token,
    ) as Map<String, dynamic>;

    return ScriptModel.fromJson(response);
  }

  Future<void> deleteScript({
    required String token,
    required String scriptId,
  }) async {
    await _client.delete(
      '/scripts/$scriptId',
      token: token,
    );
  }
}
