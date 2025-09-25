class ApiKeyModel {
  const ApiKeyModel({
    required this.id,
    required this.provider,
    this.keyAlias,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String provider;
  final String? keyAlias;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory ApiKeyModel.fromJson(Map<String, dynamic> json) => ApiKeyModel(
        id: json['id'] as String,
        provider: json['provider'] as String,
        keyAlias: json['key_alias'] as String? ?? json['keyAlias'] as String?,
        metadata: (json['metadata'] as Map<String, dynamic>?) ?? <String, dynamic>{},
        createdAt: _parseDateTime(json['created_at'])!,
        updatedAt: _parseDateTime(json['updated_at'])!,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'provider': provider,
        'key_alias': keyAlias,
        'metadata': metadata,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

class CreateApiKeyRequest {
  const CreateApiKeyRequest({
    required this.provider,
    this.keyAlias,
    required this.encryptedKey,
    this.metadata = const <String, dynamic>{},
  });

  final String provider;
  final String? keyAlias;
  final String encryptedKey;
  final Map<String, dynamic> metadata;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'provider': provider,
        if (keyAlias != null) 'key_alias': keyAlias,
        'encrypted_key': encryptedKey,
        if (metadata.isNotEmpty) 'metadata': metadata,
      };
}

class UpdateApiKeyRequest {
  const UpdateApiKeyRequest({
    this.keyAlias,
    this.encryptedKey,
    this.metadata,
  });

  final String? keyAlias;
  final String? encryptedKey;
  final Map<String, dynamic>? metadata;

  Map<String, dynamic> toJson() {
    final payload = <String, dynamic>{};
    if (keyAlias != null) payload['key_alias'] = keyAlias;
    if (encryptedKey != null) payload['encrypted_key'] = encryptedKey;
    if (metadata != null) payload['metadata'] = metadata;
    return payload;
  }
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
