/// Data models for the Enhanced TTS Service

/// Voice configuration for multi-speaker podcast generation
class VoiceConfiguration {
  final String speaker1Voice;
  final String speaker2Voice;
  final String speaker1Name;
  final String speaker2Name;
  final String languageCode;

  const VoiceConfiguration({
    required this.speaker1Voice,
    required this.speaker2Voice,
    this.speaker1Name = 'Speaker1',
    this.speaker2Name = 'Speaker2',
    this.languageCode = 'en-US',
  });

  Map<String, dynamic> toJson() => {
    'speaker1Voice': speaker1Voice,
    'speaker2Voice': speaker2Voice,
    'speaker1Name': speaker1Name,
    'speaker2Name': speaker2Name,
    'languageCode': languageCode,
  };

  factory VoiceConfiguration.fromJson(Map<String, dynamic> json) => VoiceConfiguration(
    speaker1Voice: json['speaker1Voice'] as String,
    speaker2Voice: json['speaker2Voice'] as String,
    speaker1Name: json['speaker1Name'] as String? ?? 'Speaker1',
    speaker2Name: json['speaker2Name'] as String? ?? 'Speaker2',
    languageCode: json['languageCode'] as String? ?? 'en-US',
  );

  @override
  String toString() => 'VoiceConfiguration(s1: $speaker1Voice, s2: $speaker2Voice)';
}

/// Options for podcast generation
class GenerationOptions {
  final String model;
  final double temperature;
  final int maxRetries;
  final Duration timeout;
  final bool enableBackgroundGeneration;

  const GenerationOptions({
    this.model = 'gemini-2.0-flash-exp',
    this.temperature = 0.7,
    this.maxRetries = 3,
    this.timeout = const Duration(minutes: 5),
    this.enableBackgroundGeneration = true,
  });

  Map<String, dynamic> toJson() => {
    'model': model,
    'temperature': temperature,
    'maxRetries': maxRetries,
    'timeoutMinutes': timeout.inMinutes,
    'enableBackgroundGeneration': enableBackgroundGeneration,
  };

  factory GenerationOptions.fromJson(Map<String, dynamic> json) => GenerationOptions(
    model: json['model'] as String? ?? 'gemini-2.0-flash-exp',
    temperature: (json['temperature'] as num?)?.toDouble() ?? 0.7,
    maxRetries: json['maxRetries'] as int? ?? 3,
    timeout: Duration(minutes: json['timeoutMinutes'] as int? ?? 5),
    enableBackgroundGeneration: json['enableBackgroundGeneration'] as bool? ?? true,
  );
}

/// Result of podcast generation
class PodcastGenerationResult {
  final bool success;
  final String? audioFilePath;
  final AudioMetadata? metadata;
  final GenerationStats stats;
  final TTSException? error;

  const PodcastGenerationResult({
    required this.success,
    this.audioFilePath,
    this.metadata,
    required this.stats,
    this.error,
  });

  @override
  String toString() => 'PodcastGenerationResult(success: $success, path: $audioFilePath)';
}

/// Audio configuration for processing
class AudioConfig {
  final int sampleRate;
  final int channels;
  final int bitsPerSample;
  final AudioFormat format;

  const AudioConfig({
    this.sampleRate = 24000,
    this.channels = 1,
    this.bitsPerSample = 16,
    this.format = AudioFormat.wav,
  });

  Map<String, dynamic> toJson() => {
    'sampleRate': sampleRate,
    'channels': channels,
    'bitsPerSample': bitsPerSample,
    'format': format.name,
  };

  factory AudioConfig.fromJson(Map<String, dynamic> json) => AudioConfig(
    sampleRate: json['sampleRate'] as int? ?? 24000,
    channels: json['channels'] as int? ?? 1,
    bitsPerSample: json['bitsPerSample'] as int? ?? 16,
    format: AudioFormat.values.firstWhere(
      (f) => f.name == json['format'],
      orElse: () => AudioFormat.wav,
    ),
  );
}

/// Audio metadata
class AudioMetadata {
  final String title;
  final Duration duration;
  final DateTime createdAt;
  final AudioConfig config;
  final int fileSize;
  final String checksum;
  final Map<String, String> customMetadata;

  const AudioMetadata({
    required this.title,
    required this.duration,
    required this.createdAt,
    required this.config,
    required this.fileSize,
    required this.checksum,
    this.customMetadata = const {},
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'durationMs': duration.inMilliseconds,
    'createdAt': createdAt.toIso8601String(),
    'config': config.toJson(),
    'fileSize': fileSize,
    'checksum': checksum,
    'customMetadata': customMetadata,
  };

  factory AudioMetadata.fromJson(Map<String, dynamic> json) => AudioMetadata(
    title: json['title'] as String,
    duration: Duration(milliseconds: json['durationMs'] as int),
    createdAt: DateTime.parse(json['createdAt'] as String),
    config: AudioConfig.fromJson(json['config'] as Map<String, dynamic>),
    fileSize: json['fileSize'] as int,
    checksum: json['checksum'] as String,
    customMetadata: Map<String, String>.from(json['customMetadata'] as Map? ?? {}),
  );
}

/// TTS Voice information
class TTSVoice {
  final String id;
  final String name;
  final String displayName;
  final VoiceGender gender;
  final String language;
  final List<String> characteristics;
  final String description;

  const TTSVoice({
    required this.id,
    required this.name,
    required this.displayName,
    required this.gender,
    required this.language,
    this.characteristics = const [],
    this.description = '',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'displayName': displayName,
    'gender': gender.name,
    'language': language,
    'characteristics': characteristics,
    'description': description,
  };

  factory TTSVoice.fromJson(Map<String, dynamic> json) => TTSVoice(
    id: json['id'] as String,
    name: json['name'] as String,
    displayName: json['displayName'] as String,
    gender: VoiceGender.values.firstWhere(
      (g) => g.name == json['gender'],
      orElse: () => VoiceGender.neutral,
    ),
    language: json['language'] as String,
    characteristics: List<String>.from(json['characteristics'] as List? ?? []),
    description: json['description'] as String? ?? '',
  );

  @override
  String toString() => 'TTSVoice($id: $displayName)';
}

/// Audio preview result
class AudioPreview {
  final String voiceId;
  final String audioFilePath;
  final Duration duration;
  final String sampleText;

  const AudioPreview({
    required this.voiceId,
    required this.audioFilePath,
    required this.duration,
    required this.sampleText,
  });

  @override
  String toString() => 'AudioPreview($voiceId: ${duration.inSeconds}s)';
}

/// Generation statistics
class GenerationStats {
  final DateTime startTime;
  final DateTime endTime;
  final int scriptLength;
  final int retryCount;

  const GenerationStats({
    required this.startTime,
    required this.endTime,
    required this.scriptLength,
    required this.retryCount,
  });

  Duration get totalDuration => endTime.difference(startTime);

  Map<String, dynamic> toJson() => {
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'scriptLength': scriptLength,
    'retryCount': retryCount,
    'totalDurationMs': totalDuration.inMilliseconds,
  };

  factory GenerationStats.fromJson(Map<String, dynamic> json) => GenerationStats(
    startTime: DateTime.parse(json['startTime'] as String),
    endTime: DateTime.parse(json['endTime'] as String),
    scriptLength: json['scriptLength'] as int,
    retryCount: json['retryCount'] as int,
  );

  @override
  String toString() => 'GenerationStats(${totalDuration.inSeconds}s, $retryCount retries)';
}

/// TTS Exception with user-friendly error handling
class TTSException implements Exception {
  final TTSErrorType type;
  final String message;
  final String userMessage;
  final List<RecoveryAction> recoveryActions;
  final String? technicalDetails;

  const TTSException({
    required this.type,
    required this.message,
    required this.userMessage,
    this.recoveryActions = const [],
    this.technicalDetails,
  });

  @override
  String toString() => 'TTSException(${type.name}): $message';
}

/// User-friendly error with recovery actions
class UserFriendlyError {
  final String title;
  final String message;
  final List<RecoveryAction> recoveryActions;
  final ErrorSeverity severity;
  final String? technicalDetails;

  const UserFriendlyError({
    required this.title,
    required this.message,
    this.recoveryActions = const [],
    this.severity = ErrorSeverity.error,
    this.technicalDetails,
  });

  factory UserFriendlyError.fromTTSException(TTSException exception) {
    return UserFriendlyError(
      title: _getErrorTitle(exception.type),
      message: exception.userMessage,
      recoveryActions: exception.recoveryActions,
      severity: _getErrorSeverity(exception.type),
      technicalDetails: exception.technicalDetails ?? exception.message,
    );
  }

  static String _getErrorTitle(TTSErrorType type) {
    switch (type) {
      case TTSErrorType.invalidApiKey:
        return 'API Key Required';
      case TTSErrorType.networkError:
        return 'Connection Problem';
      case TTSErrorType.timeout:
        return 'Request Timeout';
      case TTSErrorType.rateLimited:
        return 'Rate Limited';
      case TTSErrorType.serverError:
        return 'Server Error';
      case TTSErrorType.invalidInput:
        return 'Invalid Input';
      case TTSErrorType.invalidVoice:
        return 'Voice Not Available';
      case TTSErrorType.audioProcessing:
        return 'Audio Processing Error';
      case TTSErrorType.unknown:
        return 'Unexpected Error';
    }
  }

  static ErrorSeverity _getErrorSeverity(TTSErrorType type) {
    switch (type) {
      case TTSErrorType.invalidApiKey:
      case TTSErrorType.invalidInput:
      case TTSErrorType.invalidVoice:
        return ErrorSeverity.warning;
      case TTSErrorType.networkError:
      case TTSErrorType.timeout:
      case TTSErrorType.rateLimited:
        return ErrorSeverity.error;
      case TTSErrorType.serverError:
      case TTSErrorType.audioProcessing:
      case TTSErrorType.unknown:
        return ErrorSeverity.critical;
    }
  }
}

/// Enums

enum VoiceGender {
  male,
  female,
  neutral,
}

enum AudioFormat {
  wav,
  mp3,
  pcm,
}

enum TTSErrorType {
  invalidApiKey,
  networkError,
  timeout,
  rateLimited,
  serverError,
  invalidInput,
  invalidVoice,
  audioProcessing,
  unknown,
}

enum RecoveryAction {
  retry,
  openSettings,
  viewApiKeyGuide,
  checkConnection,
  editScript,
  selectVoice,
  contactSupport,
}

enum ErrorSeverity {
  info,
  warning,
  error,
  critical,
}