import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/tts_models.dart';
import '../utils/error_handler.dart';
import '../utils/logger.dart';
import '../utils/retry_handler.dart';
import '../utils/progress_tracker.dart' as progress;

/// Enhanced TTS Service with proper Gemini integration and comprehensive error handling
class EnhancedTTSService {
  static const String _geminiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  static const Duration _defaultTimeout = Duration(minutes: 5);
  static const int _maxRetries = 3;
  
  final http.Client _httpClient;
  bool _isDisposed = false;

  EnhancedTTSService({http.Client? httpClient}) 
      : _httpClient = httpClient ?? http.Client();

  /// Initialize the service and validate configuration
  Future<void> initialize() async {
    if (_isDisposed) throw StateError('Service has been disposed');
    
    _log('🚀 Initializing Enhanced TTS Service');
    
    // Validate API key on initialization
    await validateApiKey();
    
    _log('✅ Enhanced TTS Service initialized successfully');
  }

  /// Validate the Gemini API key
  Future<bool> validateApiKey() async {
    if (_isDisposed) throw StateError('Service has been disposed');
    
    try {
      _log('🔍 Validating Gemini API key');
      
      final apiKey = await _getApiKey();
      if (apiKey.isEmpty) {
        throw TTSException(
          type: TTSErrorType.invalidApiKey,
          message: 'Gemini API key not found',
          userMessage: 'Please configure your Gemini API key in Settings',
          recoveryActions: [
            RecoveryAction.openSettings,
            RecoveryAction.viewApiKeyGuide,
          ],
        );
      }

      // Validate API key format
      if (!apiKey.startsWith('AIza') || apiKey.length < 20) {
        throw TTSException(
          type: TTSErrorType.invalidApiKey,
          message: 'Invalid API key format',
          userMessage: 'Your Gemini API key appears to be invalid. Keys should start with "AIza"',
          recoveryActions: [
            RecoveryAction.openSettings,
            RecoveryAction.viewApiKeyGuide,
          ],
        );
      }

      _log('✅ API key validation successful');
      return true;
    } catch (e) {
      _log('❌ API key validation failed: $e');
      if (e is TTSException) rethrow;
      throw TTSException(
        type: TTSErrorType.invalidApiKey,
        message: 'API key validation failed: $e',
        userMessage: 'Unable to validate your API key. Please check your configuration.',
        recoveryActions: [RecoveryAction.openSettings],
      );
    }
  }

  /// Get available TTS voices from Gemini
  Future<List<TTSVoice>> getAvailableVoices() async {
    if (_isDisposed) throw StateError('Service has been disposed');
    
    _log('🎭 Fetching available TTS voices');
    
    // Return the official Gemini TTS voices
    final voices = [
      // Primary voices with detailed characteristics
      TTSVoice(
        id: 'Zephyr',
        name: 'Zephyr',
        displayName: 'Zephyr (Bright)',
        gender: VoiceGender.neutral,
        language: 'en-US',
        characteristics: ['bright', 'clear', 'energetic'],
        description: 'A bright and energetic voice perfect for engaging content',
      ),
      TTSVoice(
        id: 'Puck',
        name: 'Puck',
        displayName: 'Puck (Upbeat)',
        gender: VoiceGender.neutral,
        language: 'en-US',
        characteristics: ['upbeat', 'playful', 'dynamic'],
        description: 'An upbeat and playful voice that brings energy to conversations',
      ),
      TTSVoice(
        id: 'Charon',
        name: 'Charon',
        displayName: 'Charon (Informative)',
        gender: VoiceGender.neutral,
        language: 'en-US',
        characteristics: ['informative', 'authoritative', 'clear'],
        description: 'An informative and authoritative voice ideal for educational content',
      ),
      TTSVoice(
        id: 'Kore',
        name: 'Kore',
        displayName: 'Kore (Firm)',
        gender: VoiceGender.female,
        language: 'en-US',
        characteristics: ['firm', 'confident', 'professional'],
        description: 'A firm and confident female voice with professional tone',
      ),
      TTSVoice(
        id: 'Fenrir',
        name: 'Fenrir',
        displayName: 'Fenrir (Excitable)',
        gender: VoiceGender.male,
        language: 'en-US',
        characteristics: ['excitable', 'enthusiastic', 'dynamic'],
        description: 'An excitable and enthusiastic male voice full of energy',
      ),
      TTSVoice(
        id: 'Leda',
        name: 'Leda',
        displayName: 'Leda (Youthful)',
        gender: VoiceGender.female,
        language: 'en-US',
        characteristics: ['youthful', 'fresh', 'vibrant'],
        description: 'A youthful and vibrant female voice with fresh appeal',
      ),
    ];

    _log('✅ Retrieved ${voices.length} available voices');
    return voices;
  }

  /// Generate a podcast with multi-speaker configuration
  Future<PodcastGenerationResult> generatePodcast({
    required String script,
    required VoiceConfiguration voiceConfig,
    required GenerationOptions options,
    Function(double progress, String status)? onProgress,
    Function(Duration? estimatedTimeRemaining)? onTimeUpdate,
    Function(UserFriendlyError error)? onError,
  }) async {
    if (_isDisposed) throw StateError('Service has been disposed');
    
    final startTime = DateTime.now();
    _log('🎙️ Starting podcast generation');
    _log('📝 Script length: ${script.length} characters');
    _log('🗣️ Voice config: ${voiceConfig.speaker1Voice} & ${voiceConfig.speaker2Voice}');

    // Create comprehensive progress tracker
    final progressTracker = progress.ProgressTrackerFactory.createForPodcastGeneration(
      onProgress: onProgress ?? (_, __) {},
      onError: onError,
      onTimeUpdate: onTimeUpdate,
    );

    try {
      // Start progress tracking
      progressTracker.start();
      
      // Phase 1: Initialization
      progressTracker.updatePhaseProgress('Initialization', 0.0, status: 'Validating configuration...');
      await _validateGenerationInputs(script, voiceConfig, options);
      progressTracker.updatePhaseProgress('Initialization', 1.0, status: 'Configuration validated');
      
      // Generate the podcast with enhanced progress tracking
      final result = await _generateWithRetry(
        script: script,
        voiceConfig: voiceConfig,
        options: options,
        progressTracker: progressTracker,
      );

      // Complete progress tracking
      progressTracker.complete('Podcast generation completed!');

      final duration = DateTime.now().difference(startTime);
      _log('✅ Podcast generation completed in ${duration.inSeconds}s');

      return result;
    } catch (e) {
      final duration = DateTime.now().difference(startTime);
      _log('❌ Podcast generation failed after ${duration.inSeconds}s: $e');
      
      // Report error through progress tracker
      if (e is TTSException) {
        final userError = UserFriendlyError.fromTTSException(e);
        progressTracker.reportError(userError);
      }
      
      if (e is TTSException) {
        return PodcastGenerationResult(
          success: false,
          error: e,
          stats: GenerationStats(
            startTime: startTime,
            endTime: DateTime.now(),
            scriptLength: script.length,
            retryCount: 0,
          ),
        );
      }
      
      // Wrap unexpected errors
      final wrappedException = TTSException(
        type: TTSErrorType.unknown,
        message: 'Unexpected error during generation: $e',
        userMessage: 'An unexpected error occurred. Please try again.',
        recoveryActions: [RecoveryAction.retry],
      );
      
      return PodcastGenerationResult(
        success: false,
        error: wrappedException,
        stats: GenerationStats(
          startTime: startTime,
          endTime: DateTime.now(),
          scriptLength: script.length,
          retryCount: 0,
        ),
      );
    }
  }

  /// Preview a voice with sample text
  Future<AudioPreview> previewVoice(
    String voiceId, 
    String sampleText, {
    Function(double progress, String status)? onProgress,
  }) async {
    if (_isDisposed) throw StateError('Service has been disposed');
    
    _log('🎵 Generating voice preview for: $voiceId');
    
    // Create progress tracker for voice preview
    final progressTracker = progress.ProgressTrackerFactory.createForVoicePreview(
      onProgress: onProgress ?? (_, __) {},
    );
    
    try {
      progressTracker.start();
      
      // Create a simple voice configuration for preview
      final previewConfig = VoiceConfiguration(
        speaker1Voice: voiceId,
        speaker2Voice: voiceId, // Same voice for preview
        speaker1Name: 'Speaker',
        speaker2Name: 'Speaker',
        languageCode: 'en-US',
      );

      final options = GenerationOptions(
        model: 'gemini-2.0-flash-exp',
        timeout: Duration(minutes: 1),
        maxRetries: 1,
      );

      progressTracker.updatePhaseProgress('Preparation', 1.0);

      final result = await generatePodcast(
        script: 'Speaker: $sampleText',
        voiceConfig: previewConfig,
        options: options,
        onProgress: (progress, status) {
          // Map full generation progress to preview generation phase
          progressTracker.updatePhaseProgress('Generation', progress, status: status);
        },
      );

      if (result.success && result.audioFilePath != null) {
        progressTracker.complete('Voice preview ready!');
        
        return AudioPreview(
          voiceId: voiceId,
          audioFilePath: result.audioFilePath!,
          duration: result.metadata?.duration ?? Duration.zero,
          sampleText: sampleText,
        );
      } else {
        throw result.error ?? TTSException(
          type: TTSErrorType.audioProcessing,
          message: 'Failed to generate voice preview',
          userMessage: 'Unable to generate voice preview. Please try again.',
          recoveryActions: [RecoveryAction.retry],
        );
      }
    } catch (e) {
      _log('❌ Voice preview failed: $e');
      if (e is TTSException) rethrow;
      throw TTSException(
        type: TTSErrorType.audioProcessing,
        message: 'Voice preview failed: $e',
        userMessage: 'Unable to generate voice preview. Please try again.',
        recoveryActions: [RecoveryAction.retry],
      );
    }
  }

  /// Dispose of the service and clean up resources
  void dispose() {
    if (_isDisposed) return;
    
    _log('🧹 Disposing Enhanced TTS Service');
    _httpClient.close();
    _isDisposed = true;
  }

  // Private helper methods

  Future<String> _getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('api_key_gemini') ?? '';
  }

  Future<void> _validateGenerationInputs(
    String script,
    VoiceConfiguration voiceConfig,
    GenerationOptions options,
  ) async {
    if (script.trim().isEmpty) {
      throw TTSException(
        type: TTSErrorType.invalidInput,
        message: 'Script is empty',
        userMessage: 'Please provide a script to generate the podcast.',
        recoveryActions: [RecoveryAction.editScript],
      );
    }

    if (script.length > 50000) {
      throw TTSException(
        type: TTSErrorType.invalidInput,
        message: 'Script too long: ${script.length} characters',
        userMessage: 'Your script is too long. Please keep it under 50,000 characters.',
        recoveryActions: [RecoveryAction.editScript],
      );
    }

    // Validate voice configuration
    final availableVoices = await getAvailableVoices();
    final voiceIds = availableVoices.map((v) => v.id).toSet();
    
    if (!voiceIds.contains(voiceConfig.speaker1Voice)) {
      throw TTSException(
        type: TTSErrorType.invalidVoice,
        message: 'Invalid speaker 1 voice: ${voiceConfig.speaker1Voice}',
        userMessage: 'The selected voice for Speaker 1 is not available.',
        recoveryActions: [RecoveryAction.selectVoice],
      );
    }

    if (!voiceIds.contains(voiceConfig.speaker2Voice)) {
      throw TTSException(
        type: TTSErrorType.invalidVoice,
        message: 'Invalid speaker 2 voice: ${voiceConfig.speaker2Voice}',
        userMessage: 'The selected voice for Speaker 2 is not available.',
        recoveryActions: [RecoveryAction.selectVoice],
      );
    }
  }

  Future<PodcastGenerationResult> _generateWithRetry({
    required String script,
    required VoiceConfiguration voiceConfig,
    required GenerationOptions options,
    required progress.ProgressTracker progressTracker,
  }) async {
    final startTime = DateTime.now();
    final cancellationToken = CancellationToken();
    
    try {
      final result = await RetryHandler.executeWithRetry<_GenerationResult>(
        operation: () => TimeoutHandler.executeWithTimeout(
          operation: () => _performGeneration(
            script: script,
            voiceConfig: voiceConfig,
            options: options,
            progressTracker: progressTracker,
            attempt: 1, // Will be managed by RetryHandler
          ),
          timeout: options.timeout,
          cancellationToken: cancellationToken,
          operationName: 'Podcast Generation',
        ),
        maxRetries: options.maxRetries,
        shouldRetry: RetryHandler.shouldRetryError,
        onRetry: (attempt, delay) {
          Logger.info('Retrying generation: attempt $attempt, delay: ${delay.inSeconds}s');
          progressTracker.updateProgress(0.2, 'Retrying generation (attempt $attempt)...');
          progressTracker.setEstimatedTimeRemaining(delay);
        },
        onProgress: (progress, status) => progressTracker.updateProgress(progress, status),
        cancellationToken: null, // Simplified for now
      );

      return PodcastGenerationResult(
        success: true,
        audioFilePath: result.audioFilePath,
        metadata: result.metadata,
        stats: GenerationStats(
          startTime: startTime,
          endTime: DateTime.now(),
          scriptLength: script.length,
          retryCount: 0, // RetryHandler manages this internally
        ),
      );
    } catch (e) {
      Logger.error('Generation failed after all retries: $e');
      
      TTSException exception;
      if (e is TTSException) {
        exception = e;
      } else {
        exception = TTSException(
          type: TTSErrorType.unknown,
          message: 'Generation failed: $e',
          userMessage: 'An unexpected error occurred during generation.',
          recoveryActions: [RecoveryAction.retry],
        );
      }

      return PodcastGenerationResult(
        success: false,
        error: exception,
        stats: GenerationStats(
          startTime: startTime,
          endTime: DateTime.now(),
          scriptLength: script.length,
          retryCount: options.maxRetries,
        ),
      );
    }
  }



  Future<_GenerationResult> _performGeneration({
    required String script,
    required VoiceConfiguration voiceConfig,
    required GenerationOptions options,
    required progress.ProgressTracker progressTracker,
    required int attempt,
  }) async {
    final apiKey = await _getApiKey();
    
    // Phase 2: API Request preparation
    progressTracker.updatePhaseProgress('API Request', 0.0, status: 'Preparing TTS request...');
    
    // Construct the correct Gemini TTS API endpoint
    final encodedApiKey = Uri.encodeQueryComponent(apiKey);
    final url = Uri.parse('$_geminiBaseUrl/models/${options.model}:generateContent?key=$encodedApiKey');
    
    Logger.apiRequest('POST', url.toString());
    
    // Format the script with clear speaker instructions
    final formattedScript = _formatScriptForTTS(script, voiceConfig);
    
    // Prepare the request body according to Gemini TTS specification
    final requestBody = _buildRequestBody(formattedScript, voiceConfig, options);
    
    progressTracker.updatePhaseProgress('API Request', 0.5, status: 'Sending request to Gemini TTS...');
    
    try {
      final response = await _httpClient.post(
        url,
        headers: _buildRequestHeaders(),
        body: jsonEncode(requestBody),
      ).timeout(
        options.timeout,
        onTimeout: () {
          throw TTSException(
            type: TTSErrorType.timeout,
            message: 'Request timed out after ${options.timeout.inMinutes} minutes',
            userMessage: 'The generation request took too long. Please try with a shorter script.',
            recoveryActions: [RecoveryAction.retry, RecoveryAction.editScript],
          );
        },
      );

      Logger.apiResponse(response.statusCode, url.toString());
      
      if (response.statusCode == 200) {
        // Phase 3: Audio Generation (API completed successfully)
        progressTracker.updatePhaseProgress('Audio Generation', 1.0, status: 'Audio generation completed');
        
        return await _processSuccessfulResponse(response, voiceConfig, progressTracker);
      } else {
        throw _handleErrorResponse(response);
      }
    } on TTSException {
      rethrow;
    } catch (e) {
      Logger.error('API request failed: $e');
      throw _wrapNetworkError(e);
    }
  }

  /// Format script for TTS with proper speaker instructions
  String _formatScriptForTTS(String script, VoiceConfiguration voiceConfig) {
    return '''
Generate a multi-speaker podcast conversation with the following speakers:
- ${voiceConfig.speaker1Name}: Use voice "${voiceConfig.speaker1Voice}"
- ${voiceConfig.speaker2Name}: Use voice "${voiceConfig.speaker2Voice}"

Script:
$script
''';
  }

  /// Build the request body for Gemini TTS API
  Map<String, dynamic> _buildRequestBody(
    String formattedScript,
    VoiceConfiguration voiceConfig,
    GenerationOptions options,
  ) {
    return {
      'contents': [
        {
          'parts': [
            {
              'text': formattedScript,
            }
          ]
        }
      ],
      'generationConfig': {
        'responseModalities': ['AUDIO'],
        'speechConfig': {
          'languageCode': voiceConfig.languageCode,
          'multiSpeakerVoiceConfig': {
            'speakerVoiceConfigs': [
              {
                'speaker': voiceConfig.speaker1Name,
                'voiceConfig': {
                  'prebuiltVoiceConfig': {
                    'voiceName': voiceConfig.speaker1Voice,
                  }
                }
              },
              {
                'speaker': voiceConfig.speaker2Name,
                'voiceConfig': {
                  'prebuiltVoiceConfig': {
                    'voiceName': voiceConfig.speaker2Voice,
                  }
                }
              }
            ]
          }
        }
      }
    };
  }

  /// Build HTTP headers for the request
  Map<String, String> _buildRequestHeaders() {
    return {
      'Content-Type': 'application/json',
      'Keep-Alive': 'timeout=120, max=1000',
      'Connection': 'keep-alive',
    };
  }

  /// Process successful API response
  Future<_GenerationResult> _processSuccessfulResponse(
    http.Response response,
    VoiceConfiguration voiceConfig,
    progress.ProgressTracker progressTracker,
  ) async {
    try {
      Logger.success('Received successful response from Gemini TTS');
      
      final responseData = jsonDecode(response.body);
      Logger.debug('Response structure: ${responseData.keys}');
      
      // Phase 4: Audio Processing - Extracting audio
      progressTracker.updatePhaseProgress('Audio Processing', 0.0, status: 'Extracting audio data...');
      
      // Extract audio data from response
      final candidates = responseData['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        throw TTSException(
          type: TTSErrorType.audioProcessing,
          message: 'No audio candidates in response',
          userMessage: 'The TTS service did not generate any audio. Please try again.',
          recoveryActions: [RecoveryAction.retry],
        );
      }

      final content = candidates[0]['content'];
      final parts = content['parts'] as List?;
      if (parts == null || parts.isEmpty) {
        throw TTSException(
          type: TTSErrorType.audioProcessing,
          message: 'No audio parts in response',
          userMessage: 'The TTS service response was incomplete. Please try again.',
          recoveryActions: [RecoveryAction.retry],
        );
      }

      final inlineData = parts[0]['inlineData'];
      final audioDataBase64 = inlineData['data'] as String?;
      if (audioDataBase64 == null || audioDataBase64.isEmpty) {
        throw TTSException(
          type: TTSErrorType.audioProcessing,
          message: 'No audio data in response',
          userMessage: 'The TTS service did not provide audio data. Please try again.',
          recoveryActions: [RecoveryAction.retry],
        );
      }

      progressTracker.updatePhaseProgress('Audio Processing', 0.3, status: 'Decoding audio data...');
      
      // Decode base64 audio data
      final audioBytes = base64Decode(audioDataBase64);
      Logger.audio('Decoded audio data', duration: null, sampleRate: 24000);
      
      progressTracker.updatePhaseProgress('Audio Processing', 0.7, status: 'Saving audio file...');
      
      // Save the audio file
      final audioFilePath = await _saveAudioFile(audioBytes, voiceConfig);
      
      progressTracker.updatePhaseProgress('Audio Processing', 0.9, status: 'Creating metadata...');
      
      // Create metadata
      final metadata = await _createAudioMetadata(audioFilePath, voiceConfig);
      
      Logger.success('Audio file saved successfully: $audioFilePath');
      
      return _GenerationResult(
        audioFilePath: audioFilePath,
        metadata: metadata,
      );
    } catch (e) {
      Logger.error('Failed to process successful response: $e');
      if (e is TTSException) rethrow;
      throw TTSException(
        type: TTSErrorType.audioProcessing,
        message: 'Failed to process audio response: $e',
        userMessage: 'There was an error processing the generated audio. Please try again.',
        recoveryActions: [RecoveryAction.retry],
      );
    }
  }

  /// Handle error response from API
  TTSException _handleErrorResponse(http.Response response) {
    Logger.error('API error response: ${response.statusCode}');
    
    String errorMessage = 'Unknown error';
    TTSErrorType errorType = TTSErrorType.serverError;
    List<RecoveryAction> recoveryActions = [RecoveryAction.retry];
    
    try {
      final errorData = jsonDecode(response.body);
      errorMessage = errorData['error']['message'] ?? 'Unknown error';
      
      // Categorize error based on status code and message
      switch (response.statusCode) {
        case 400:
          errorType = TTSErrorType.invalidInput;
          recoveryActions = [RecoveryAction.editScript, RecoveryAction.selectVoice];
          break;
        case 401:
        case 403:
          errorType = TTSErrorType.invalidApiKey;
          recoveryActions = [RecoveryAction.openSettings, RecoveryAction.viewApiKeyGuide];
          break;
        case 429:
          errorType = TTSErrorType.rateLimited;
          recoveryActions = [RecoveryAction.retry];
          break;
        case 500:
        case 502:
        case 503:
        case 504:
          errorType = TTSErrorType.serverError;
          recoveryActions = [RecoveryAction.retry, RecoveryAction.contactSupport];
          break;
        default:
          errorType = TTSErrorType.unknown;
      }
    } catch (e) {
      Logger.warning('Failed to parse error response', error: e);
      errorMessage = 'HTTP ${response.statusCode}: ${response.body}';
    }

    return TTSException(
      type: errorType,
      message: 'API error: $errorMessage',
      userMessage: _getUserMessageForError(errorType, errorMessage),
      recoveryActions: recoveryActions,
      technicalDetails: 'HTTP ${response.statusCode}: ${response.body}',
    );
  }

  /// Wrap network errors in TTSException
  TTSException _wrapNetworkError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('socket') || errorString.contains('network')) {
      return TTSException(
        type: TTSErrorType.networkError,
        message: 'Network error: $error',
        userMessage: 'Unable to connect to the TTS service. Please check your internet connection.',
        recoveryActions: [RecoveryAction.retry, RecoveryAction.checkConnection],
      );
    }
    
    if (errorString.contains('timeout')) {
      return TTSException(
        type: TTSErrorType.timeout,
        message: 'Timeout error: $error',
        userMessage: 'The request took too long to complete. Please try again.',
        recoveryActions: [RecoveryAction.retry, RecoveryAction.editScript],
      );
    }
    
    return TTSException(
      type: TTSErrorType.unknown,
      message: 'Unexpected error: $error',
      userMessage: 'An unexpected error occurred. Please try again.',
      recoveryActions: [RecoveryAction.retry],
    );
  }

  /// Get user-friendly message for error type
  String _getUserMessageForError(TTSErrorType errorType, String apiMessage) {
    switch (errorType) {
      case TTSErrorType.invalidApiKey:
        return 'Your API key is invalid or missing. Please check your settings.';
      case TTSErrorType.invalidInput:
        if (apiMessage.toLowerCase().contains('voice')) {
          return 'The selected voice is not available. Please choose a different voice.';
        }
        return 'There\'s an issue with your script. Please check it and try again.';
      case TTSErrorType.rateLimited:
        return 'You\'ve made too many requests. Please wait a moment before trying again.';
      case TTSErrorType.serverError:
        return 'The TTS service is experiencing issues. Please try again in a few minutes.';
      default:
        return 'An error occurred during generation. Please try again.';
    }
  }

  /// Save audio bytes to file with optional format conversion
  Future<String> _saveAudioFile(Uint8List audioBytes, VoiceConfiguration voiceConfig) async {
    try {
      // Get a suitable directory for saving
      final directory = await _getAudioDirectory();
      
      // Generate filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final wavFilename = 'podcast_${timestamp}.wav';
      final wavFilePath = '${directory.path}/$wavFilename';
      
      // Write audio data to WAV file first
      final file = File(wavFilePath);
      await file.writeAsBytes(audioBytes);
      
      Logger.fileOperation('Saved audio file', wavFilePath, size: audioBytes.length);
      
      // TODO: Add optional MP3 conversion here using AudioProcessingService
      // Example:
      // final audioProcessor = AudioProcessingService();
      // final mp3Path = '${directory.path}/podcast_${timestamp}.mp3';
      // await audioProcessor.convertAudio(
      //   inputPath: wavFilePath,
      //   outputPath: mp3Path,
      //   targetFormat: AudioFormat.mp3,
      //   bitrate: 128,
      // );
      
      return wavFilePath;
    } catch (e) {
      Logger.error('Failed to save audio file: $e');
      throw TTSException(
        type: TTSErrorType.audioProcessing,
        message: 'Failed to save audio file: $e',
        userMessage: 'Unable to save the generated audio. Please check storage permissions.',
        recoveryActions: [RecoveryAction.retry],
      );
    }
  }

  /// Get directory for saving audio files
  Future<Directory> _getAudioDirectory() async {
    // This will be enhanced in the file management task
    // For now, use a simple approach
    try {
      final directory = Directory('/storage/emulated/0/Download/EchoGenAI');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      return directory;
    } catch (e) {
      // Fallback to app documents directory
      final appDir = await _getApplicationDocumentsDirectory();
      return appDir;
    }
  }

  /// Get application documents directory (fallback)
  Future<Directory> _getApplicationDocumentsDirectory() async {
    try {
      return await getApplicationDocumentsDirectory();
    } catch (e) {
      Logger.warning('Failed to get app documents directory, using temp: $e');
      return await getTemporaryDirectory();
    }
  }

  /// Create audio metadata
  Future<AudioMetadata> _createAudioMetadata(String filePath, VoiceConfiguration voiceConfig) async {
    final file = File(filePath);
    final fileSize = await file.length();
    
    // Calculate checksum (simple approach)
    final bytes = await file.readAsBytes();
    final checksum = bytes.fold<int>(0, (sum, byte) => sum + byte).toString();
    
    // Estimate duration (rough calculation for WAV files)
    // This will be improved in the audio processing task
    final estimatedDuration = Duration(seconds: (fileSize / 48000).round());
    
    return AudioMetadata(
      title: 'Generated Podcast ${DateTime.now().toIso8601String()}',
      duration: estimatedDuration,
      createdAt: DateTime.now(),
      config: const AudioConfig(
        sampleRate: 24000,
        channels: 1,
        bitsPerSample: 16,
        format: AudioFormat.wav,
      ),
      fileSize: fileSize,
      checksum: checksum,
      customMetadata: {
        'speaker1Voice': voiceConfig.speaker1Voice,
        'speaker2Voice': voiceConfig.speaker2Voice,
        'speaker1Name': voiceConfig.speaker1Name,
        'speaker2Name': voiceConfig.speaker2Name,
        'languageCode': voiceConfig.languageCode,
      },
    );
  }

  void _log(String message) {
    Logger.info(message, tag: 'EnhancedTTSService');
  }
}

// Internal result class for generation
class _GenerationResult {
  final String audioFilePath;
  final AudioMetadata metadata;

  _GenerationResult({
    required this.audioFilePath,
    required this.metadata,
  });
}