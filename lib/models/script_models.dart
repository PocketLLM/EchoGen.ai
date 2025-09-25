class ScriptSegmentModel {
  const ScriptSegmentModel({
    required this.speaker,
    required this.content,
    this.startTime,
    this.endTime,
  });

  final String speaker;
  final String content;
  final double? startTime;
  final double? endTime;

  factory ScriptSegmentModel.fromJson(Map<String, dynamic> json) =>
      ScriptSegmentModel(
        speaker: json['speaker'] as String,
        content: json['content'] as String,
        startTime: (json['start_time'] as num?)?.toDouble() ??
            (json['startTime'] as num?)?.toDouble(),
        endTime: (json['end_time'] as num?)?.toDouble() ??
            (json['endTime'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'speaker': speaker,
        'content': content,
        if (startTime != null) 'start_time': startTime,
        if (endTime != null) 'end_time': endTime,
      };
}

class ScriptModel {
  const ScriptModel({
    required this.id,
    required this.userId,
    this.sourceContentId,
    required this.prompt,
    required this.model,
    required this.language,
    required this.segments,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String? sourceContentId;
  final String prompt;
  final String model;
  final String language;
  final List<ScriptSegmentModel> segments;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory ScriptModel.fromJson(Map<String, dynamic> json) => ScriptModel(
        id: json['id'] as String,
        userId: json['user_id'] as String? ?? json['userId'] as String? ?? '',
        sourceContentId:
            json['source_content_id'] as String? ?? json['sourceContentId'] as String?,
        prompt: json['prompt'] as String,
        model: json['model'] as String,
        language: json['language'] as String,
        segments: (json['segments'] as List<dynamic>)
            .map((dynamic segment) =>
                ScriptSegmentModel.fromJson(segment as Map<String, dynamic>))
            .toList(),
        metadata: (json['metadata'] as Map<String, dynamic>?) ?? <String, dynamic>{},
        createdAt: _parseDateTime(json['created_at'])!,
        updatedAt: _parseDateTime(json['updated_at'])!,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'user_id': userId,
        'source_content_id': sourceContentId,
        'prompt': prompt,
        'model': model,
        'language': language,
        'segments': segments.map((segment) => segment.toJson()).toList(),
        'metadata': metadata,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

class CreateScriptRequest {
  const CreateScriptRequest({
    this.sourceContentId,
    required this.prompt,
    required this.model,
    this.language = 'en',
    required this.segments,
    this.metadata = const <String, dynamic>{},
  });

  final String? sourceContentId;
  final String prompt;
  final String model;
  final String language;
  final List<ScriptSegmentModel> segments;
  final Map<String, dynamic> metadata;

  Map<String, dynamic> toJson() => <String, dynamic>{
        if (sourceContentId != null) 'source_content_id': sourceContentId,
        'prompt': prompt,
        'model': model,
        'language': language,
        'segments': segments.map((segment) => segment.toJson()).toList(),
        if (metadata.isNotEmpty) 'metadata': metadata,
      };
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is DateTime) {
    return value;
  }
  return DateTime.parse(value.toString()).toLocal();
}
