import 'package:flutter/material.dart';
import 'package:echogenai/constants/app_theme.dart';
import 'package:echogenai/services/global_audio_manager.dart';
import 'package:echogenai/services/storage_service.dart';
import 'package:echogenai/screens/podcast_player_screen.dart';

class MiniPlayerWidget extends StatefulWidget {
  const MiniPlayerWidget({super.key});

  @override
  State<MiniPlayerWidget> createState() => _MiniPlayerWidgetState();
}

class _MiniPlayerWidgetState extends State<MiniPlayerWidget> with TickerProviderStateMixin {
  final GlobalAudioManager _audioManager = GlobalAudioManager.instance;
  late AnimationController _slideController;
  late AnimationController _logoSpinController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _logoSpinAnimation;
  
  GeneratedPodcast? _currentPodcast;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration? _duration;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _logoSpinController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
    
    _logoSpinAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_logoSpinController);
    
    _setupListeners();
  }

  void _setupListeners() {
    _audioManager.currentPodcastStream.listen((podcast) {
      setState(() {
        _currentPodcast = podcast;
      });
      
      if (podcast != null) {
        _slideController.forward();
      } else {
        _slideController.reverse();
      }
    });
    
    _audioManager.isPlayingStream.listen((isPlaying) {
      setState(() {
        _isPlaying = isPlaying;
      });
      
      if (isPlaying) {
        _logoSpinController.repeat();
      } else {
        _logoSpinController.stop();
      }
    });
    
    _audioManager.positionStream.listen((position) {
      setState(() {
        _position = position;
      });
    });
    
    _audioManager.durationStream.listen((duration) {
      setState(() {
        _duration = duration;
      });
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _logoSpinController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    if (_currentPodcast == null) {
      return const SizedBox.shrink();
    }
    
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        height: 80,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? AppTheme.surfaceDark : AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDarkMode ? AppTheme.surfaceVariantDark : AppTheme.borderLight,
          ),
          boxShadow: [
            BoxShadow(
              color: (isDarkMode ? Colors.black : Colors.grey).withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PodcastPlayerScreen(podcast: _currentPodcast!),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Cover Art with spinning animation
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryBlue,
                          AppTheme.primaryLight,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: RotationTransition(
                        turns: _logoSpinAnimation,
                        child: Image.asset(
                          'lib/assets/logo.png',
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.podcasts,
                              color: Colors.white,
                              size: 28,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentPodcast!.title,
                          style: AppTheme.titleSmall.copyWith(
                            color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_currentPodcast!.metadata['speaker1']} & ${_currentPodcast!.metadata['speaker2']}',
                          style: AppTheme.bodySmall.copyWith(
                            color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Progress bar
                        if (_duration != null)
                          LinearProgressIndicator(
                            value: _duration!.inMilliseconds > 0 
                                ? _position.inMilliseconds / _duration!.inMilliseconds 
                                : 0.0,
                            backgroundColor: (isDarkMode ? Colors.white : Colors.black).withOpacity(0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                            minHeight: 2,
                          ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Controls
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Rewind button
                      IconButton(
                        onPressed: () => _audioManager.rewind(),
                        icon: Icon(
                          Icons.replay_10_rounded,
                          color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                        ),
                        iconSize: 24,
                      ),
                      
                      // Play/Pause button
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          onPressed: () {
                            if (_isPlaying) {
                              _audioManager.pause();
                            } else {
                              _audioManager.playPodcast(_currentPodcast!);
                            }
                          },
                          icon: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      
                      // Fast forward button
                      IconButton(
                        onPressed: () => _audioManager.fastForward(),
                        icon: Icon(
                          Icons.forward_10_rounded,
                          color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                        ),
                        iconSize: 24,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
