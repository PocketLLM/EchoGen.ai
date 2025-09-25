import '../models/content_models.dart';
import 'backend_api_client.dart';

class ContentApiService {
  ContentApiService({BackendApiClient? apiClient})
      : _client = apiClient ?? BackendApiClient();

  final BackendApiClient _client;

  Future<ContentItemModel> createContent({
    required String token,
    required CreateContentRequest request,
  }) async {
    final response = await _client.post(
      '/content',
      token: token,
      body: request.toJson(),
    ) as Map<String, dynamic>;

    return ContentItemModel.fromJson(response);
  }

  Future<ContentListModel> listContent({
    required String token,
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _client.get(
      '/content',
      token: token,
      queryParameters: {
        'limit': limit,
        'offset': offset,
      },
    ) as Map<String, dynamic>;

    return ContentListModel.fromJson(response);
  }

  Future<ContentItemModel> getContent({
    required String token,
    required String contentId,
  }) async {
    final response = await _client.get(
      '/content/$contentId',
      token: token,
    ) as Map<String, dynamic>;

    return ContentItemModel.fromJson(response);
  }

  Future<void> deleteContent({
    required String token,
    required String contentId,
  }) async {
    await _client.delete(
      '/content/$contentId',
      token: token,
    );
  }
}
