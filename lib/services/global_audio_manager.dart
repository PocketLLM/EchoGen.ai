import 'dart:async';
import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:echogenai/services/storage_service.dart';

class GlobalAudioManager {
  static GlobalAudioManager? _instance;
  static GlobalAudioManager get instance => _instance ??= GlobalAudioManager._();

  GlobalAudioManager._();

  AudioPlayer? _audioPlayer;
  GeneratedPodcast? _currentPodcast;

  final StreamController<bool> _isPlayingController = StreamController<bool>.broadcast();
  final StreamController<GeneratedPodcast?> _currentPodcastController = StreamController<GeneratedPodcast?>.broadcast();
  final StreamController<Duration> _positionController = StreamController<Duration>.broadcast();
  final StreamController<Duration?> _durationController = StreamController<Duration?>.broadcast();
  final StreamController<double> _speedController = StreamController<double>.broadcast();

  // Streams for UI to listen to
  Stream<bool> get isPlayingStream => _isPlayingController.stream;
  Stream<GeneratedPodcast?> get currentPodcastStream => _currentPodcastController.stream;
  Stream<Duration> get positionStream => _positionController.stream;
  Stream<Duration?> get durationStream => _durationController.stream;
  Stream<double> get speedStream => _speedController.stream;

  // Current state getters
  bool get isPlaying => _audioPlayer?.playing ?? false;
  GeneratedPodcast? get currentPodcast => _currentPodcast;
  Duration get position => _audioPlayer?.position ?? Duration.zero;
  Duration? get duration => _audioPlayer?.duration;
  double get speed => _audioPlayer?.speed ?? 1.0;

  Future<void> init() async {
    try {
      if (_audioPlayer != null) return; // Already initialized

      _audioPlayer = AudioPlayer();

      // Listen to state changes and broadcast them
      _audioPlayer!.playerStateStream.listen((state) {
        _isPlayingController.add(state.playing);
      });

      _audioPlayer!.positionStream.listen((position) {
        _positionController.add(position);
      });

      _audioPlayer!.durationStream.listen((duration) {
        _durationController.add(duration);
      });

      print('✅ Global audio manager initialized successfully');
    } catch (e) {
      print('Error initializing global audio manager: $e');
    }
  }

  Future<void> playPodcast(GeneratedPodcast podcast) async {
    try {
      if (_audioPlayer == null) {
        await init();
      }

      // Ensure we have a valid player
      if (_audioPlayer == null) {
        throw Exception('Audio player not initialized');
      }

      // If it's a different podcast, load it first
      if (_currentPodcast?.id != podcast.id) {
        await _loadPodcast(podcast);
      }

      await _audioPlayer!.play();
    } catch (e) {
      print('Error playing podcast: $e');
      throw e;
    }
  }

  Future<void> _loadPodcast(GeneratedPodcast podcast) async {
    try {
      _currentPodcast = podcast;
      _currentPodcastController.add(podcast);

      // Load audio file
      final file = File(podcast.audioPath);
      if (await file.exists()) {
        await _audioPlayer!.setFilePath(podcast.audioPath);
        print('✅ Podcast loaded successfully: ${podcast.title}');
      } else {
        throw Exception('Audio file not found: ${podcast.audioPath}');
      }
    } catch (e) {
      print('Error loading podcast: $e');
      throw e;
    }
  }

  Future<void> pause() async {
    try {
      await _audioPlayer?.pause();
    } catch (e) {
      print('Error pausing audio: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _audioPlayer?.stop();
      _currentPodcast = null;
      _currentPodcastController.add(null);
    } catch (e) {
      print('Error stopping audio: $e');
    }
  }

  Future<void> seek(Duration position) async {
    try {
      await _audioPlayer?.seek(position);
    } catch (e) {
      print('Error seeking audio: $e');
    }
  }

  Future<void> rewind() async {
    try {
      final currentPosition = _audioPlayer?.position ?? Duration.zero;
      final newPosition = currentPosition - const Duration(seconds: 10);
      await seek(newPosition > Duration.zero ? newPosition : Duration.zero);
    } catch (e) {
      print('Error rewinding audio: $e');
    }
  }

  Future<void> fastForward() async {
    try {
      final currentPosition = _audioPlayer?.position ?? Duration.zero;
      final duration = _audioPlayer?.duration;
      if (duration != null) {
        final newPosition = currentPosition + const Duration(seconds: 10);
        await seek(newPosition < duration ? newPosition : duration);
      }
    } catch (e) {
      print('Error fast forwarding audio: $e');
    }
  }

  Future<void> setSpeed(double speed) async {
    try {
      await _audioPlayer?.setSpeed(speed);
      _speedController.add(speed);
    } catch (e) {
      print('Error setting speed: $e');
    }
  }

  void dispose() {
    _isPlayingController.close();
    _currentPodcastController.close();
    _positionController.close();
    _durationController.close();
    _speedController.close();
    _audioPlayer?.dispose();
  }
}
