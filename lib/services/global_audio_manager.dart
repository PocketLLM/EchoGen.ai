import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:echogenai/services/background_audio_service.dart';
import 'package:echogenai/services/storage_service.dart';

class GlobalAudioManager {
  static GlobalAudioManager? _instance;
  static GlobalAudioManager get instance => _instance ??= GlobalAudioManager._();
  
  GlobalAudioManager._();

  AudioHandler? _audioHandler;
  BackgroundAudioService? _backgroundService;
  
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
  bool get isPlaying => _backgroundService?.playing ?? false;
  GeneratedPodcast? get currentPodcast => _backgroundService?.currentPodcast;
  Duration get position => _backgroundService?.position ?? Duration.zero;
  Duration? get duration => _backgroundService?.duration;
  double get speed => _backgroundService?.speed ?? 1.0;

  Future<void> init() async {
    try {
      _audioHandler = await AudioService.init(
        builder: () {
          final service = BackgroundAudioService.instance;
          service.init();
          return service;
        },
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.echogenai.audio',
          androidNotificationChannelName: 'EchoGenAI Audio',
          androidNotificationChannelDescription: 'Audio playback for EchoGenAI podcasts',
          androidNotificationOngoing: false,
          androidStopForegroundOnPause: true,
        ),
      );

      _backgroundService = _audioHandler as BackgroundAudioService?;
      
      if (_backgroundService != null) {
        // Listen to state changes and broadcast them
        _backgroundService!.playerStateStream.listen((state) {
          _isPlayingController.add(state.playing);
        });
        
        _backgroundService!.positionStream.listen((position) {
          _positionController.add(position);
        });
        
        _backgroundService!.durationStream.listen((duration) {
          _durationController.add(duration);
        });
        
        // Listen to media item changes
        _audioHandler!.mediaItem.listen((mediaItem) {
          if (mediaItem != null && _backgroundService!.currentPodcast != null) {
            _currentPodcastController.add(_backgroundService!.currentPodcast);
          } else {
            _currentPodcastController.add(null);
          }
        });
      }
    } catch (e) {
      print('Error initializing global audio manager: $e');
    }
  }

  Future<void> playPodcast(GeneratedPodcast podcast) async {
    try {
      if (_backgroundService == null) {
        await init();
      }
      
      // If it's a different podcast, load it first
      if (_backgroundService!.currentPodcast?.id != podcast.id) {
        await _backgroundService!.loadPodcast(podcast);
        _currentPodcastController.add(podcast);
      }
      
      await _audioHandler!.play();
    } catch (e) {
      print('Error playing podcast: $e');
      throw e;
    }
  }

  Future<void> pause() async {
    try {
      await _audioHandler?.pause();
    } catch (e) {
      print('Error pausing audio: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _audioHandler?.stop();
      _currentPodcastController.add(null);
    } catch (e) {
      print('Error stopping audio: $e');
    }
  }

  Future<void> seek(Duration position) async {
    try {
      await _audioHandler?.seek(position);
    } catch (e) {
      print('Error seeking audio: $e');
    }
  }

  Future<void> rewind() async {
    try {
      await _audioHandler?.rewind();
    } catch (e) {
      print('Error rewinding audio: $e');
    }
  }

  Future<void> fastForward() async {
    try {
      await _audioHandler?.fastForward();
    } catch (e) {
      print('Error fast forwarding audio: $e');
    }
  }

  Future<void> setSpeed(double speed) async {
    try {
      await _audioHandler?.setSpeed(speed);
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
    _backgroundService?.dispose();
  }
}
