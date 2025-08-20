import 'dart:async';
import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:echogenai/services/storage_service.dart';

class BackgroundAudioService extends BaseAudioHandler with QueueHandler, SeekHandler {
  static BackgroundAudioService? _instance;
  static BackgroundAudioService get instance => _instance ??= BackgroundAudioService._();
  
  BackgroundAudioService._();

  final AudioPlayer _audioPlayer = AudioPlayer();
  final Completer<void> _readyCompleter = Completer<void>();
  
  GeneratedPodcast? _currentPodcast;
  
  Future<void> get ready => _readyCompleter.future;

  Future<void> init() async {
    try {
      // Configure audio session
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.speech());
      
      // Listen to audio player events
      _audioPlayer.playerStateStream.listen(_broadcastState);
      _audioPlayer.positionStream.listen((position) {
        playbackState.add(playbackState.value.copyWith(
          updatePosition: position,
        ));
      });
      
      // Set initial state
      playbackState.add(PlaybackState(
        controls: [
          MediaControl.rewind,
          MediaControl.play,
          MediaControl.fastForward,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: AudioProcessingState.idle,
        playing: false,
      ));
      
      _readyCompleter.complete();
    } catch (e) {
      print('Error initializing background audio service: $e');
      _readyCompleter.complete();
    }
  }

  Future<void> loadPodcast(GeneratedPodcast podcast) async {
    try {
      _currentPodcast = podcast;
      
      // Set media item
      final mediaItem = MediaItem(
        id: podcast.id,
        album: 'EchoGenAI',
        title: podcast.title,
        artist: '${podcast.metadata['speaker1']} & ${podcast.metadata['speaker2']}',
        duration: null, // Will be set when audio loads
        artUri: null, // Could add cover art URI here
        extras: {
          'audioPath': podcast.audioPath,
          'category': podcast.metadata['category'],
        },
      );
      
      this.mediaItem.add(mediaItem);
      
      // Load audio file
      final file = File(podcast.audioPath);
      if (await file.exists()) {
        await _audioPlayer.setFilePath(podcast.audioPath);
        
        // Update duration when available
        _audioPlayer.durationStream.listen((duration) {
          if (duration != null) {
            final updatedMediaItem = mediaItem.copyWith(duration: duration);
            this.mediaItem.add(updatedMediaItem);
          }
        });
      } else {
        throw Exception('Audio file not found: ${podcast.audioPath}');
      }
    } catch (e) {
      print('Error loading podcast: $e');
      throw e;
    }
  }

  @override
  Future<void> play() async {
    try {
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  @override
  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
    } catch (e) {
      print('Error pausing audio: $e');
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      playbackState.add(PlaybackState(
        controls: [
          MediaControl.play,
        ],
        processingState: AudioProcessingState.idle,
        playing: false,
      ));
    } catch (e) {
      print('Error stopping audio: $e');
    }
  }

  @override
  Future<void> seek(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      print('Error seeking audio: $e');
    }
  }

  @override
  Future<void> skipToNext() async {
    // Could implement playlist functionality here
  }

  @override
  Future<void> skipToPrevious() async {
    // Could implement playlist functionality here
  }

  @override
  Future<void> rewind() async {
    final currentPosition = _audioPlayer.position;
    final newPosition = currentPosition - const Duration(seconds: 10);
    await seek(newPosition > Duration.zero ? newPosition : Duration.zero);
  }

  @override
  Future<void> fastForward() async {
    final currentPosition = _audioPlayer.position;
    final duration = _audioPlayer.duration;
    if (duration != null) {
      final newPosition = currentPosition + const Duration(seconds: 10);
      await seek(newPosition < duration ? newPosition : duration);
    }
  }

  @override
  Future<void> setSpeed(double speed) async {
    try {
      await _audioPlayer.setSpeed(speed);
    } catch (e) {
      print('Error setting speed: $e');
    }
  }

  void _broadcastState(PlayerState playerState) {
    final isPlaying = playerState.playing;
    final processingState = switch (playerState.processingState) {
      ProcessingState.idle => AudioProcessingState.idle,
      ProcessingState.loading => AudioProcessingState.loading,
      ProcessingState.buffering => AudioProcessingState.buffering,
      ProcessingState.ready => AudioProcessingState.ready,
      ProcessingState.completed => AudioProcessingState.completed,
    };

    playbackState.add(PlaybackState(
      controls: [
        MediaControl.rewind,
        if (isPlaying) MediaControl.pause else MediaControl.play,
        MediaControl.fastForward,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: processingState,
      playing: isPlaying,
      updatePosition: _audioPlayer.position,
      bufferedPosition: _audioPlayer.bufferedPosition,
      speed: _audioPlayer.speed,
      queueIndex: 0,
    ));
  }

  // Getters for UI to access player state
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Duration get position => _audioPlayer.position;
  Duration? get duration => _audioPlayer.duration;
  bool get playing => _audioPlayer.playing;
  double get speed => _audioPlayer.speed;
  
  GeneratedPodcast? get currentPodcast => _currentPodcast;

  @override
  Future<void> onTaskRemoved() async {
    // Handle when app is removed from recent apps
    await stop();
  }

  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}

// Audio handler factory for audio_service
Future<AudioHandler> createAudioHandler() async {
  final service = BackgroundAudioService.instance;
  await service.init();
  return service;
}
