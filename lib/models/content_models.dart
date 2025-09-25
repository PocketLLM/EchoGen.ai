class ContentItemModel {
  const ContentItemModel({
    required this.id,
    required this.userId,
    required this.url,
    required this.title,
    required this.markdown,
    required this.provider,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String url;
  final String title;
  final String markdown;
  final String provider;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory ContentItemModel.fromJson(Map<String, dynamic> json) => ContentItemModel(
        id: json['id'] as String,
        userId: json['user_id'] as String? ?? json['userId'] as String? ?? '',
        url: json['url'] as String,
        title: json['title'] as String,
        markdown: json['markdown'] as String,
        provider: json['provider'] as String,
        metadata: (json['metadata'] as Map<String, dynamic>?) ?? <String, dynamic>{},
        createdAt: _parseDateTime(json['created_at'])!,
        updatedAt: _parseDateTime(json['updated_at'])!,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'user_id': userId,
        'url': url,
        'title': title,
        'markdown': markdown,
        'provider': provider,
        'metadata': metadata,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

class ContentListModel {
  const ContentListModel({
    required this.items,
    required this.total,
  });

  final List<ContentItemModel> items;
  final int total;

  factory ContentListModel.fromJson(Map<String, dynamic> json) => ContentListModel(
        items: (json['items'] as List<dynamic>)
            .map((dynamic item) =>
                ContentItemModel.fromJson(item as Map<String, dynamic>))
            .toList(),
        total: json['total'] as int,
      );
}

class CreateContentRequest {
  const CreateContentRequest({
    required this.url,
    required this.title,
    required this.markdown,
    required this.provider,
    this.metadata = const <String, dynamic>{},
  });

  final String url;
  final String title;
  final String markdown;
  final String provider;
  final Map<String, dynamic> metadata;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'url': url,
        'title': title,
        'markdown': markdown,
        'provider': provider,
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
