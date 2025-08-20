# Design Document

## Overview

This design addresses the critical podcast generation and playback issues in EchoGen.ai by implementing a robust, reliable system for AI-powered audio content creation. The solution focuses on proper Gemini TTS API integration, audio format standardization, and enhanced user experience through better error handling and feedback.

The design follows a modular architecture that separates concerns between TTS generation, audio processing, file management, and playback, enabling easier maintenance and future enhancements.

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    User Interface Layer                     │
├─────────────────────────────────────────────────────────────┤
│  PodcastGenerationScreen  │  PodcastPlayerScreen           │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                   Service Layer                            │
├─────────────────────────────────────────────────────────────┤
│  Enhanced TTS Service  │  Audio Processing  │  File Manager │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                 External APIs & Storage                     │
├─────────────────────────────────────────────────────────────┤
│    Gemini TTS API     │   Local Storage   │   Media Player  │
└─────────────────────────────────────────────────────────────┘
```

### Component Interaction Flow

1. **Generation Request**: User initiates podcast generation with script and voice selections
2. **API Integration**: Enhanced TTS Service formats and sends request to Gemini TTS API
3. **Audio Processing**: Raw PCM data is converted to standard WAV format with proper headers
4. **File Management**: Processed audio is saved with metadata and proper file structure
5. **Playback Integration**: Audio player loads the standardized file for immediate playback
6. **Error Handling**: Any failures are caught and presented with user-friendly messages

## Components and Interfaces

### 1. Enhanced TTS Service

**Purpose**: Manages all text-to-speech operations with proper API integration and error handling.

**Key Responsibilities**:
- Gemini TTS API communication with correct endpoints and formatting
- Audio format conversion from PCM to WAV
- Progress tracking and user feedback
- Comprehensive error handling and recovery

**Interface**:
```dart
class EnhancedTTSService {
  Future<PodcastGenerationResult> generatePodcast({
    required String script,
    required VoiceConfiguration voiceConfig,
    required GenerationOptions options,
    Function(double progress, String status)? onProgress,
  });
  
  Future<List<TTSVoice>> getAvailableVoices();
  Future<bool> validateApiKey();
  Future<AudioPreview> previewVoice(String voiceId, String sampleText);
}
```

**Implementation Details**:
- Uses correct Gemini TTS endpoint: `/v1beta/models/{model}:generateContent`
- Implements proper multi-speaker request formatting
- Handles streaming responses for large content
- Includes retry logic with exponential backoff
- Validates API responses before processing

### 2. Audio Processing Module

**Purpose**: Handles all audio format conversion, validation, and metadata management.

**Key Responsibilities**:
- PCM to WAV conversion with proper headers
- Audio file validation and integrity checking
- Metadata embedding (title, duration, speakers)
- Format compatibility verification

**Interface**:
```dart
class AudioProcessor {
  Future<ProcessedAudio> convertPCMToWAV(
    Uint8List pcmData, 
    AudioConfig config
  );
  
  Future<bool> validateAudioFile(String filePath);
  Future<AudioMetadata> extractMetadata(String filePath);
  Future<String> embedMetadata(String filePath, PodcastMetadata metadata);
}
```

**Technical Specifications**:
- WAV format: 16-bit PCM, 24kHz sample rate (matching Gemini TTS output)
- Proper RIFF header generation for maximum compatibility
- Metadata embedding using standard audio tags
- File integrity validation using checksum verification

### 3. File Management System

**Purpose**: Manages podcast file storage, organization, and access across different storage locations.

**Key Responsibilities**:
- Intelligent storage location selection based on permissions
- File naming and organization
- Cleanup of temporary files
- Cross-platform file access handling

**Interface**:
```dart
class PodcastFileManager {
  Future<String> saveGeneratedPodcast(
    ProcessedAudio audio, 
    PodcastMetadata metadata
  );
  
  Future<String> getOptimalStorageLocation();
  Future<bool> validateStoragePermissions();
  Future<void> cleanupTemporaryFiles();
  Future<String> exportToDownloads(String podcastPath);
}
```

**Storage Strategy**:
- Primary: App documents directory (always accessible)
- Secondary: Downloads folder (if permissions available)
- Tertiary: External storage (Android) or Music folder
- Fallback: Temporary directory with user notification

### 4. Enhanced Audio Player

**Purpose**: Provides reliable audio playback with comprehensive format support and user controls.

**Key Responsibilities**:
- Multi-format audio playback support
- Advanced playback controls (speed, seeking, etc.)
- Background audio session management
- Error recovery and alternative playback methods

**Interface**:
```dart
class EnhancedAudioPlayer {
  Future<void> loadAudio(String filePath);
  Future<void> play();
  Future<void> pause();
  Future<void> seekTo(Duration position);
  Future<void> setPlaybackSpeed(double speed);
  
  Stream<PlayerState> get playerStateStream;
  Stream<Duration> get positionStream;
  Stream<Duration> get durationStream;
}
```

**Implementation Details**:
- Uses `just_audio` package exclusively (removes `audioplayers` conflict)
- Implements format detection and validation before playback
- Includes fallback playback methods for compatibility issues
- Proper audio session configuration for background playback

### 5. Error Handling and User Feedback System

**Purpose**: Provides comprehensive error handling with user-friendly messages and recovery options.

**Key Responsibilities**:
- Error categorization and user-friendly message generation
- Recovery suggestion system
- Progress tracking and status updates
- Logging and debugging support

**Interface**:
```dart
class ErrorHandler {
  UserFriendlyError processError(Exception error, ErrorContext context);
  List<RecoveryAction> getRecoveryActions(ErrorType errorType);
  void logError(Exception error, StackTrace stackTrace, Map<String, dynamic> context);
}

class ProgressTracker {
  void updateProgress(double progress, String status);
  void setEstimatedTimeRemaining(Duration timeRemaining);
  void reportError(UserFriendlyError error);
}
```

**Error Categories**:
- API Authentication errors (invalid/missing API key)
- Network connectivity issues
- Rate limiting and quota exceeded
- Audio processing failures
- File system and permissions errors
- Playback compatibility issues

## Data Models

### Core Data Structures

```dart
class VoiceConfiguration {
  final String speaker1Voice;
  final String speaker2Voice;
  final String speaker1Name;
  final String speaker2Name;
  final String languageCode;
}

class GenerationOptions {
  final String model;
  final double temperature;
  final int maxRetries;
  final Duration timeout;
  final bool enableBackgroundGeneration;
}

class PodcastGenerationResult {
  final String audioFilePath;
  final AudioMetadata metadata;
  final GenerationStats stats;
  final bool success;
  final UserFriendlyError? error;
}

class AudioConfig {
  final int sampleRate;
  final int channels;
  final int bitsPerSample;
  final AudioFormat format;
}

class ProcessedAudio {
  final String filePath;
  final AudioConfig config;
  final Duration duration;
  final int fileSize;
  final String checksum;
}

class UserFriendlyError {
  final String title;
  final String message;
  final List<RecoveryAction> recoveryActions;
  final ErrorSeverity severity;
  final String technicalDetails;
}
```

## Error Handling

### Error Classification System

**Level 1: User Errors**
- Missing or invalid API key
- Insufficient storage space
- Network connectivity issues
- *Recovery*: Clear instructions and retry options

**Level 2: System Errors**
- API rate limiting
- Audio processing failures
- File permission issues
- *Recovery*: Automatic retry with backoff, alternative methods

**Level 3: Critical Errors**
- API service unavailable
- Corrupted audio data
- System resource exhaustion
- *Recovery*: Graceful degradation, error reporting, manual intervention

### Error Message Framework

```dart
class ErrorMessages {
  static const Map<ErrorType, ErrorTemplate> templates = {
    ErrorType.invalidApiKey: ErrorTemplate(
      title: "API Key Required",
      message: "Your Gemini API key is missing or invalid.",
      actions: [
        RecoveryAction.openSettings,
        RecoveryAction.viewApiKeyGuide,
      ],
    ),
    ErrorType.networkError: ErrorTemplate(
      title: "Connection Problem",
      message: "Unable to connect to the TTS service. Please check your internet connection.",
      actions: [
        RecoveryAction.retry,
        RecoveryAction.checkConnection,
      ],
    ),
    // ... additional error templates
  };
}
```

### Progress Feedback System

**Generation Phases**:
1. **Initialization** (0-10%): API key validation, request preparation
2. **API Request** (10-30%): Sending request to Gemini TTS
3. **Audio Processing** (30-80%): Receiving and processing audio data
4. **File Creation** (80-95%): Converting to WAV and saving file
5. **Finalization** (95-100%): Metadata embedding and cleanup

**Status Messages**:
- "Preparing your podcast..."
- "Generating AI voices..."
- "Processing audio quality..."
- "Finalizing your podcast..."
- "Ready to play!"

## Testing Strategy

### Unit Testing

**TTS Service Tests**:
- API request formatting validation
- Response parsing and error handling
- Audio format conversion accuracy
- Progress tracking functionality

**Audio Processing Tests**:
- PCM to WAV conversion correctness
- Metadata embedding verification
- File integrity validation
- Format compatibility testing

**File Management Tests**:
- Storage location selection logic
- Permission handling scenarios
- File naming and organization
- Cleanup operation verification

### Integration Testing

**End-to-End Generation Flow**:
- Complete podcast generation with various script lengths
- Multi-speaker voice configuration testing
- Error scenario handling (network failures, invalid API keys)
- Background generation reliability

**Playback Integration**:
- Audio player compatibility with generated files
- Playback control functionality
- Background audio session management
- Error recovery during playback

### Performance Testing

**Generation Performance**:
- Script length vs. generation time analysis
- Memory usage during processing
- Concurrent generation handling
- Background processing reliability

**Audio Quality Validation**:
- Generated audio clarity and consistency
- Multi-speaker voice distinction
- Format compatibility across devices
- Metadata preservation accuracy

### User Acceptance Testing

**Usability Scenarios**:
- First-time user setup and API key configuration
- Typical podcast generation workflow
- Error recovery and user guidance
- File management and sharing operations

**Device Compatibility**:
- Testing across different Android versions
- Various device storage configurations
- Network condition variations
- Background app behavior

## Implementation Phases

### Phase 1: Core Fixes (Week 1-2)
- Fix Gemini TTS API integration
- Implement PCM to WAV conversion
- Remove audio player package conflicts
- Add basic error handling

### Phase 2: Enhanced Features (Week 3-4)
- Implement comprehensive error handling
- Add progress tracking and user feedback
- Enhance file management system
- Improve audio player reliability

### Phase 3: Polish and Optimization (Week 5-6)
- Performance optimization
- Advanced error recovery
- User experience enhancements
- Comprehensive testing and bug fixes

This design provides a solid foundation for reliable podcast generation and playback while maintaining extensibility for future enhancements.