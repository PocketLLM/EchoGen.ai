import '../models/podcast_models.dart';
import 'backend_api_client.dart';

class PodcastApiService {
  PodcastApiService({BackendApiClient? apiClient})
      : _client = apiClient ?? BackendApiClient();

  final BackendApiClient _client;

  Future<PodcastModel> createPodcast({
    required String token,
    required CreatePodcastRequest request,
  }) async {
    final response = await _client.post(
      '/podcasts',
      token: token,
      body: request.toJson(),
    ) as Map<String, dynamic>;

    return PodcastModel.fromJson(response);
  }

  Future<List<PodcastModel>> listPodcasts({
    required String token,
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _client.get(
      '/podcasts',
      token: token,
      queryParameters: {
        'limit': limit,
        'offset': offset,
      },
    ) as List<dynamic>;

    return response
        .map((dynamic item) => PodcastModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<PodcastModel> getPodcast({
    required String token,
    required String podcastId,
  }) async {
    final response = await _client.get(
      '/podcasts/$podcastId',
      token: token,
    ) as Map<String, dynamic>;

    return PodcastModel.fromJson(response);
  }

  Future<PodcastDetailModel> getPodcastWithScript({
    required String token,
    required String podcastId,
  }) async {
    final response = await _client.get(
      '/podcasts/$podcastId/with-script',
      token: token,
    ) as Map<String, dynamic>;

    return PodcastDetailModel.fromJson(response);
  }

  Future<void> deletePodcast({
    required String token,
    required String podcastId,
  }) async {
    await _client.delete(
      '/podcasts/$podcastId',
      token: token,
    );
  }
}
