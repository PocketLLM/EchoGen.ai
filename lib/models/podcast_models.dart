import 'script_models.dart';

class PodcastModel {
  const PodcastModel({
    required this.id,
    required this.userId,
    required this.scriptId,
    required this.audioUrl,
    this.coverArtUrl,
    this.durationSeconds,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String scriptId;
  final String audioUrl;
  final String? coverArtUrl;
  final int? durationSeconds;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory PodcastModel.fromJson(Map<String, dynamic> json) => PodcastModel(
        id: json['id'] as String,
        userId: json['user_id'] as String? ?? json['userId'] as String? ?? '',
        scriptId: json['script_id'] as String? ?? json['scriptId'] as String? ?? '',
        audioUrl: json['audio_url'] as String? ?? json['audioUrl'] as String? ?? '',
        coverArtUrl:
            json['cover_art_url'] as String? ?? json['coverArtUrl'] as String?,
        durationSeconds: (json['duration_seconds'] as num?)?.toInt() ??
            (json['durationSeconds'] as num?)?.toInt(),
        metadata: (json['metadata'] as Map<String, dynamic>?) ?? <String, dynamic>{},
        createdAt: _parseDateTime(json['created_at'])!,
        updatedAt: _parseDateTime(json['updated_at'])!,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'user_id': userId,
        'script_id': scriptId,
        'audio_url': audioUrl,
        'cover_art_url': coverArtUrl,
        'duration_seconds': durationSeconds,
        'metadata': metadata,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

class PodcastDetailModel extends PodcastModel {
  const PodcastDetailModel({
    required super.id,
    required super.userId,
    required super.scriptId,
    required super.audioUrl,
    super.coverArtUrl,
    super.durationSeconds,
    required super.metadata,
    required super.createdAt,
    required super.updatedAt,
    required this.script,
  });

  final ScriptModel script;

  factory PodcastDetailModel.fromJson(Map<String, dynamic> json) =>
      PodcastDetailModel(
        id: json['id'] as String,
        userId: json['user_id'] as String? ?? json['userId'] as String? ?? '',
        scriptId: json['script_id'] as String? ?? json['scriptId'] as String? ?? '',
        audioUrl: json['audio_url'] as String? ?? json['audioUrl'] as String? ?? '',
        coverArtUrl:
            json['cover_art_url'] as String? ?? json['coverArtUrl'] as String?,
        durationSeconds: (json['duration_seconds'] as num?)?.toInt() ??
            (json['durationSeconds'] as num?)?.toInt(),
        metadata: (json['metadata'] as Map<String, dynamic>?) ?? <String, dynamic>{},
        createdAt: _parseDateTime(json['created_at'])!,
        updatedAt: _parseDateTime(json['updated_at'])!,
        script: ScriptModel.fromJson(json['script'] as Map<String, dynamic>),
      );
}

class CreatePodcastRequest {
  const CreatePodcastRequest({
    required this.scriptId,
    required this.audioStoragePath,
    this.coverArtStoragePath,
    this.durationSeconds,
    this.metadata = const <String, dynamic>{},
  });

  final String scriptId;
  final String audioStoragePath;
  final String? coverArtStoragePath;
  final int? durationSeconds;
  final Map<String, dynamic> metadata;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'script_id': scriptId,
        'audio_storage_path': audioStoragePath,
        if (coverArtStoragePath != null)
          'cover_art_storage_path': coverArtStoragePath,
        if (durationSeconds != null) 'duration_seconds': durationSeconds,
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
