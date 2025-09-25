import '../models/job_models.dart';
import 'backend_api_client.dart';

class JobsApiService {
  JobsApiService({BackendApiClient? apiClient})
      : _client = apiClient ?? BackendApiClient();

  final BackendApiClient _client;

  Future<JobModel> enqueueJob({
    required String token,
    required CreateJobRequest request,
  }) async {
    final response = await _client.post(
      '/jobs',
      token: token,
      body: request.toJson(),
    ) as Map<String, dynamic>;

    return JobModel.fromJson(response);
  }

  Future<List<JobModel>> listJobs({
    required String token,
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _client.get(
      '/jobs',
      token: token,
      queryParameters: {
        'limit': limit,
        'offset': offset,
      },
    ) as List<dynamic>;

    return response
        .map((dynamic item) => JobModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<JobModel> getJob({
    required String token,
    required String jobId,
  }) async {
    final response = await _client.get(
      '/jobs/$jobId',
      token: token,
    ) as Map<String, dynamic>;

    return JobModel.fromJson(response);
  }
}
