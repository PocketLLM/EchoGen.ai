import 'dart:convert';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ApiException(statusCode: $statusCode, message: $message)';
}

class AuthSessionTokens {
  const AuthSessionTokens({
    required this.accessToken,
    this.refreshToken,
    this.expiresIn,
  });

  final String accessToken;
  final String? refreshToken;
  final int? expiresIn;

  factory AuthSessionTokens.fromJson(Map<String, dynamic> json) => AuthSessionTokens(
        accessToken: json['access_token'] as String,
        refreshToken: json['refresh_token'] as String?,
        expiresIn: json['expires_in'] as int?,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'access_token': accessToken,
        if (refreshToken != null) 'refresh_token': refreshToken,
        if (expiresIn != null) 'expires_in': expiresIn,
      };
}

class AccountDeletionStatusModel {
  const AccountDeletionStatusModel({
    this.scheduledFor,
    this.requestedAt,
    this.cancelledAt,
    this.completedAt,
  });

  final DateTime? scheduledFor;
  final DateTime? requestedAt;
  final DateTime? cancelledAt;
  final DateTime? completedAt;

  bool get isActive =>
      scheduledFor != null && cancelledAt == null && completedAt == null;

  factory AccountDeletionStatusModel.fromJson(Map<String, dynamic> json) =>
      AccountDeletionStatusModel(
        scheduledFor: _parseDateTime(json['scheduled_for'] as String?),
        requestedAt: _parseDateTime(json['requested_at'] as String?),
        cancelledAt: _parseDateTime(json['cancelled_at'] as String?),
        completedAt: _parseDateTime(json['completed_at'] as String?),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'scheduled_for': scheduledFor?.toIso8601String(),
        'requested_at': requestedAt?.toIso8601String(),
        'cancelled_at': cancelledAt?.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
      };
}

class UserProfileModel {
  const UserProfileModel({
    required this.id,
    required this.email,
    required this.createdAt,
    required this.onboardingCompleted,
    this.fullName,
    this.lastSignInAt,
    this.avatarUrl,
    this.bio,
    this.preferences,
    this.pendingAccountDeletion,
  });

  final String id;
  final String email;
  final String? fullName;
  final DateTime createdAt;
  final DateTime? lastSignInAt;
  final String? avatarUrl;
  final String? bio;
  final Map<String, dynamic>? preferences;
  final bool onboardingCompleted;
  final AccountDeletionStatusModel? pendingAccountDeletion;

  UserProfileModel copyWith({
    String? fullName,
    String? avatarUrl,
    String? bio,
    Map<String, dynamic>? preferences,
    bool? onboardingCompleted,
    AccountDeletionStatusModel? pendingAccountDeletion,
  }) {
    return UserProfileModel(
      id: id,
      email: email,
      createdAt: createdAt,
      fullName: fullName ?? this.fullName,
      lastSignInAt: lastSignInAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      preferences: preferences ?? this.preferences,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      pendingAccountDeletion: pendingAccountDeletion ?? this.pendingAccountDeletion,
    );
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      UserProfileModel(
        id: json['id'] as String,
        email: json['email'] as String,
        fullName: json['fullName'] as String?,
        createdAt: _parseDateTime(json['created_at'] as String)!,
        lastSignInAt: _parseDateTime(json['last_sign_in_at'] as String?),
        avatarUrl: json['avatarUrl'] as String?,
        bio: json['bio'] as String?,
        preferences: _decodePreferences(json['preferences']),
        onboardingCompleted: (json['onboardingCompleted'] as bool?) ?? false,
        pendingAccountDeletion: json['pendingAccountDeletion'] == null
            ? null
            : AccountDeletionStatusModel.fromJson(
                json['pendingAccountDeletion'] as Map<String, dynamic>,
              ),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'email': email,
        'fullName': fullName,
        'created_at': createdAt.toIso8601String(),
        'last_sign_in_at': lastSignInAt?.toIso8601String(),
        'avatarUrl': avatarUrl,
        'bio': bio,
        'preferences': preferences,
        'onboardingCompleted': onboardingCompleted,
        'pendingAccountDeletion': pendingAccountDeletion?.toJson(),
      };
}

class AuthResponseModel {
  const AuthResponseModel({
    required this.user,
    required this.session,
  });

  final UserProfileModel user;
  final AuthSessionTokens session;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      AuthResponseModel(
        user: UserProfileModel.fromJson(json['user'] as Map<String, dynamic>),
        session: AuthSessionTokens.fromJson(
          json['session'] as Map<String, dynamic>,
        ),
      );
}

class OnboardingAnswerModel {
  const OnboardingAnswerModel({
    required this.questionId,
    required this.question,
    required this.answer,
  });

  final String questionId;
  final String question;
  final dynamic answer;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'questionId': questionId,
        'question': question,
        'answer': answer,
      };
}

AuthSessionTokens? decodeTokens(String? jsonStr) {
  if (jsonStr == null || jsonStr.isEmpty) {
    return null;
  }

  final Map<String, dynamic> data = json.decode(jsonStr) as Map<String, dynamic>;
  return AuthSessionTokens.fromJson(data);
}

String encodeTokens(AuthSessionTokens tokens) => json.encode(tokens.toJson());

DateTime? _parseDateTime(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  return DateTime.parse(value).toLocal();
}

Map<String, dynamic>? _decodePreferences(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is String && value.isNotEmpty) {
    try {
      return json.decode(value) as Map<String, dynamic>;
    } catch (_) {
      return <String, dynamic>{'raw': value};
    }
  }
  return null;
}
