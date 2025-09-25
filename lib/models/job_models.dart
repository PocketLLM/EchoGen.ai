class JobModel {
  const JobModel({
    required this.id,
    required this.jobType,
    required this.status,
    required this.payload,
    this.result,
    this.error,
    required this.createdAt,
    required this.updatedAt,
    this.startedAt,
    this.finishedAt,
  });

  final String id;
  final String jobType;
  final String status;
  final Map<String, dynamic> payload;
  final Map<String, dynamic>? result;
  final String? error;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? startedAt;
  final DateTime? finishedAt;

  bool get isTerminal => status == 'succeeded' || status == 'failed';

  factory JobModel.fromJson(Map<String, dynamic> json) {
    final payload = json['payload'];
    final result = json['result'];
    return JobModel(
      id: json['id'] as String,
      jobType: json['job_type'] as String? ?? json['jobType'] as String? ?? '',
      status: json['status'] as String,
      payload: payload is Map<String, dynamic>
          ? Map<String, dynamic>.from(payload)
          : <String, dynamic>{},
      result: result is Map<String, dynamic>
          ? Map<String, dynamic>.from(result)
          : null,
      error: json['error'] as String?,
      createdAt: _parseDateTime(json['created_at'])!,
      updatedAt: _parseDateTime(json['updated_at'])!,
      startedAt: _parseDateTime(json['started_at'] ?? json['startedAt']),
      finishedAt: _parseDateTime(json['finished_at'] ?? json['finishedAt']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'job_type': jobType,
        'status': status,
        'payload': payload,
        if (result != null) 'result': result,
        if (error != null) 'error': error,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'started_at': startedAt?.toIso8601String(),
        'finished_at': finishedAt?.toIso8601String(),
      };
}

class CreateJobRequest {
  const CreateJobRequest({
    required this.jobType,
    this.payload = const <String, dynamic>{},
  });

  final String jobType;
  final Map<String, dynamic> payload;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'job_type': jobType,
        if (payload.isNotEmpty) 'payload': payload,
      };
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null || value == '') {
    return null;
  }
  if (value is DateTime) {
    return value;
  }
  return DateTime.parse(value.toString()).toLocal();
}
