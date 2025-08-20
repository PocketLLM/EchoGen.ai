import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:echogenai/constants/app_theme.dart';
import 'package:echogenai/widgets/app_bar_widget.dart';
import 'package:echogenai/services/storage_service.dart';
import 'package:echogenai/services/global_audio_manager.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class PodcastPlayerScreen extends StatefulWidget {
  final GeneratedPodcast podcast;

  const PodcastPlayerScreen({
    super.key,
    required this.podcast,
  });

  @override
  State<PodcastPlayerScreen> createState() => _PodcastPlayerScreenState();
}

class _PodcastPlayerScreenState extends State<PodcastPlayerScreen>
    with TickerProviderStateMixin {

  late AnimationController _playButtonController;
  late AnimationController _logoSpinController;
  late Animation<double> _playButtonAnimation;
  late Animation<double> _logoSpinAnimation;

  final GlobalAudioManager _audioManager = GlobalAudioManager.instance;
  bool _isPlaying = false;
  bool _isLoading = true;
  bool _showScript = false;
  bool _hasError = false;
  String? _errorMessage;

  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  double _playbackSpeed = 1.0;
  final List<double> _speedOptions = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
  bool _isSpeedControlExpanded = false;

  PageController _pageController = PageController();
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializePlayer();

    // Listen to global audio manager streams
    _audioManager.isPlayingStream.listen((isPlaying) {
      if (mounted) {
        setState(() {
          _isPlaying = isPlaying;
          if (isPlaying) {
            _playButtonController.forward();
            _logoSpinController.repeat();
          } else {
            _playButtonController.reverse();
            _logoSpinController.stop();
          }
        });
      }
    });

    _audioManager.positionStream.listen((position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    });

    _audioManager.durationStream.listen((duration) {
      if (mounted) {
        setState(() {
          _totalDuration = duration ?? Duration.zero;
        });
      }
    });

    _audioManager.speedStream.listen((speed) {
      if (mounted) {
        setState(() {
          _playbackSpeed = speed;
        });
      }
    });
  }

  void _setupAnimations() {
    _playButtonController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _logoSpinController = AnimationController(
      duration: const Duration(seconds: 8), // Slow spin - 8 seconds per rotation
      vsync: this,
    );

    _playButtonAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _playButtonController,
      curve: Curves.easeInOut,
    ));

    _logoSpinAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoSpinController,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _playButtonController.dispose();
    _logoSpinController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _initializePlayer() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      // Load the podcast using the global audio manager
      await _audioManager.playPodcast(widget.podcast);

      // Get initial state
      setState(() {
        _isPlaying = _audioManager.isPlaying;
        _currentPosition = _audioManager.position;
        _totalDuration = _audioManager.duration ?? Duration.zero;
        _playbackSpeed = _audioManager.speed;
        _isLoading = false;
      });

      print('✅ Podcast loaded successfully via global audio manager');
    } catch (e) {
      print('❌ Error initializing player: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Failed to load audio: $e\n\nTry downloading the file and opening it with another media player.';
      });
    }
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _audioManager.pause();
    } else {
      _audioManager.playPodcast(widget.podcast);
    }
  }

  void _seekTo(Duration position) {
    _audioManager.seek(position);
  }

  void _rewind() {
    _audioManager.rewind();
  }

  void _fastForward() {
    _audioManager.fastForward();
  }

  Future<void> _changePlaybackSpeed([double? newSpeed]) async {
    try {
      double targetSpeed;
      if (newSpeed != null) {
        targetSpeed = newSpeed;
      } else {
        targetSpeed = _speedOptions[(_speedOptions.indexOf(_playbackSpeed) + 1) % _speedOptions.length];
      }
      await _audioManager.setSpeed(targetSpeed);
    } catch (e) {
      _showError('Speed change error: $e');
    }
  }

  void _toggleSpeedControl() {
    setState(() {
      _isSpeedControlExpanded = !_isSpeedControlExpanded;
    });
  }

  Future<void> _downloadPodcast() async {
    try {
      // Get the original file
      final sourceFile = File(widget.podcast.audioPath);
      if (!await sourceFile.exists()) {
        throw Exception('Audio file not found');
      }

      // Get user's preferred download directory
      final prefs = await SharedPreferences.getInstance();
      final folderType = prefs.getString('download_folder_type') ?? 'app_documents';

      Directory targetDirectory;
      String locationName;

      // Try to use the user's preferred directory
      try {
        switch (folderType) {
          case 'downloads':
            targetDirectory = Directory('/storage/emulated/0/Download/EchoGenAI');
            locationName = 'Downloads folder';
            break;
          case 'external':
            targetDirectory = Directory('/storage/emulated/0/EchoGenAI');
            locationName = 'External storage';
            break;
          case 'music':
            targetDirectory = Directory('/storage/emulated/0/Music/EchoGenAI');
            locationName = 'Music folder';
            break;
          default:
            targetDirectory = await getApplicationDocumentsDirectory();
            locationName = 'App documents';
        }

        // Create directory if it doesn't exist
        if (!await targetDirectory.exists()) {
          await targetDirectory.create(recursive: true);
        }
      } catch (e) {
        print('⚠️ Error accessing preferred directory: $e');
        // Fallback to Downloads directory
        targetDirectory = Directory('/storage/emulated/0/Download');
        locationName = 'Downloads folder';
        
        if (!await targetDirectory.exists()) {
          // Final fallback to app documents
          targetDirectory = await getApplicationDocumentsDirectory();
          locationName = 'App documents';
        }
      }

      // Generate a clean filename
      final cleanTitle = widget.podcast.title
          .replaceAll(RegExp(r'[^\w\s-]'), '')
          .replaceAll(RegExp(r'\s+'), '_');
      final fileExt = sourceFile.path.split('.').last.toLowerCase();
      final fileName = '${cleanTitle}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final targetFile = File('${targetDirectory.path}/$fileName');

      // Copy the file
      try {
        await sourceFile.copy(targetFile.path);
        print('📥 File copied to: ${targetFile.path}');
      } catch (e) {
        print('⚠️ Error copying file: $e');
        throw Exception('Could not copy file: $e');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.download_done, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Podcast saved to $locationName: ${targetFile.path}'),
                ),
              ],
            ),
            backgroundColor: AppTheme.secondaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    } catch (e) {
      _showError('Failed to download podcast: $e');
    }
  }

  Future<void> _sharePodcast() async {
    try {
      await Share.share(
        'Check out this amazing podcast: ${widget.podcast.title}',
        subject: 'EchoGen.ai Podcast',
      );
    } catch (e) {
      _showError('Failed to share podcast: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.secondaryRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: EchoGenAppBar(
        title: 'Podcast Player',
        showLogo: false,
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: _downloadPodcast,
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: _sharePodcast,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? _buildErrorState(isDarkMode)
              : PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPageIndex = index;
                    });
                  },
                  children: [
                    // Page 1: Player View
                    _buildPlayerPage(isDarkMode),
                    // Page 2: Transcript View
                    _buildTranscriptPage(isDarkMode),
                  ],
                ),
    );
  }

  Widget _buildPlayerPage(bool isDarkMode) {
    return Column(
      children: [
        // Podcast Info Card
        Expanded(
          flex: 4,
          child: Container(
            margin: const EdgeInsets.all(16),
            child: _buildPodcastInfoCard(isDarkMode),
          ),
        ),

        // Player Controls Container with gradient background
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                isDarkMode
                  ? AppTheme.surfaceDark.withOpacity(0.95)
                  : AppTheme.surface.withOpacity(0.95),
                isDarkMode
                  ? AppTheme.surfaceVariantDark.withOpacity(0.9)
                  : AppTheme.surfaceVariant.withOpacity(0.8),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Progress Bar
              _buildProgressBar(isDarkMode),
              const SizedBox(height: 12),

              // Player Controls
              _buildPlayerControls(isDarkMode),
              const SizedBox(height: 20),

              // Page indicator and swipe hint
              _buildPageIndicator(isDarkMode),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTranscriptPage(bool isDarkMode) {
    return Column(
      children: [
        // Header with back navigation
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  _pageController.animateToPage(
                    0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                ),
              ),
              Expanded(
                child: Text(
                  'Transcript',
                  style: AppTheme.headingMedium.copyWith(
                    color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48), // Balance the back button
            ],
          ),
        ),

        // Transcript content
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  isDarkMode
                    ? AppTheme.surfaceDark.withOpacity(0.95)
                    : AppTheme.surface.withOpacity(0.95),
                  isDarkMode
                    ? AppTheme.surfaceVariantDark.withOpacity(0.9)
                    : AppTheme.surfaceVariant.withOpacity(0.8),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDarkMode
                  ? AppTheme.primaryBlue.withOpacity(0.2)
                  : AppTheme.primaryBlue.withOpacity(0.1),
              ),
            ),
            child: SingleChildScrollView(
              child: Text(
                widget.podcast.metadata['script'] as String? ?? 'No script available for this podcast.',
                style: AppTheme.bodyLarge.copyWith(
                  color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                  height: 1.6,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),

        // Mini player controls at bottom
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                isDarkMode
                  ? AppTheme.surfaceDark.withOpacity(0.95)
                  : AppTheme.surface.withOpacity(0.95),
                isDarkMode
                  ? AppTheme.surfaceVariantDark.withOpacity(0.9)
                  : AppTheme.surfaceVariant.withOpacity(0.8),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Row(
            children: [
              // Play/Pause button
              GestureDetector(
                onTap: _togglePlayPause,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryBlue, AppTheme.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Progress info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.podcast.title,
                      style: AppTheme.bodyMedium.copyWith(
                        color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatDuration(_currentPosition)} / ${_formatDuration(_totalDuration)}',
                      style: AppTheme.bodySmall.copyWith(
                        color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPageIndicator(bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Page dots
        Row(
          children: [
            _buildPageDot(0, isDarkMode),
            const SizedBox(width: 8),
            _buildPageDot(1, isDarkMode),
          ],
        ),
        const SizedBox(width: 16),

        // Swipe hint
        Text(
          'Swipe for transcript →',
          style: AppTheme.bodySmall.copyWith(
            color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildPageDot(int index, bool isDarkMode) {
    final isActive = index == _currentPageIndex;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isActive ? 20 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
          ? AppTheme.primaryBlue
          : (isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary).withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildPodcastInfoCard(bool isDarkMode) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue.withOpacity(0.1),
            AppTheme.primaryLight.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.05),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableHeight = constraints.maxHeight;
          final iconSize = (availableHeight * 0.5).clamp(100.0, 160.0);

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Podcast Icon with animated gradient border
              Container(
                width: iconSize,
                height: iconSize,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryBlue.withOpacity(0.8),
                      AppTheme.primaryLight.withOpacity(0.6),
                      AppTheme.secondaryGreen.withOpacity(0.3),
                      AppTheme.primaryLight.withOpacity(0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDarkMode ? AppTheme.surfaceDark : AppTheme.surface,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(iconSize / 2),
                    child: AnimatedBuilder(
                      animation: _logoSpinAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _isPlaying ? _logoSpinAnimation.value * 2 * 3.14159 : 0,
                          child: child,
                        );
                      },
                      child: Image.asset(
                        'lib/assets/logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.podcasts,
                            size: iconSize * 0.4,
                            color: AppTheme.primaryBlue,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: availableHeight * 0.05),

              // Title with animation
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 500),
                style: AppTheme.headingLarge.copyWith(
                  color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: (availableHeight * 0.06).clamp(16.0, 22.0),
                ),
                child: Text(
                  widget.podcast.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              SizedBox(height: availableHeight * 0.03),

              // Metadata - Enhanced chips
              Flexible(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildMetadataChip(
                      icon: Icons.category,
                      label: widget.podcast.metadata['category'] ?? 'Unknown',
                      isDarkMode: isDarkMode,
                      color: AppTheme.primaryBlue,
                    ),
                    _buildMetadataChip(
                      icon: Icons.people,
                      label: '${widget.podcast.metadata['speaker1']} & ${widget.podcast.metadata['speaker2']}',
                      isDarkMode: isDarkMode,
                      color: AppTheme.secondaryGreen,
                    ),
                    _buildMetadataChip(
                      icon: Icons.access_time,
                      label: _totalDuration.inSeconds > 0
                          ? _formatDuration(_totalDuration)
                          : widget.podcast.metadata['duration'] ?? 'Unknown',
                      isDarkMode: isDarkMode,
                      color: AppTheme.secondaryOrange,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMetadataChip({
    required IconData icon,
    required String label,
    required bool isDarkMode,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: isDarkMode 
                ? color.withOpacity(0.9) 
                : color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(bool isDarkMode) {
    return Column(
      children: [
        // Time indicators
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_currentPosition),
                style: AppTheme.bodySmall.copyWith(
                  color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                _formatDuration(_totalDuration),
                style: AppTheme.bodySmall.copyWith(
                  color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Custom progress bar
        Container(
          height: 36,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double maxWidth = constraints.maxWidth;
              final double progress = _totalDuration.inSeconds > 0 
                ? (_currentPosition.inSeconds / _totalDuration.inSeconds).clamp(0.0, 1.0)
                : 0.0;
              
              return GestureDetector(
                onTapDown: (details) {
                  final double newPosition = details.localPosition.dx / maxWidth;
                  if (newPosition >= 0 && newPosition <= 1.0) {
                    final int seconds = (newPosition * _totalDuration.inSeconds).round();
                    _seekTo(Duration(seconds: seconds));
                  }
                },
                onHorizontalDragUpdate: (details) {
                  final double newPosition = (details.localPosition.dx / maxWidth).clamp(0.0, 1.0);
                  final int seconds = (newPosition * _totalDuration.inSeconds).round();
                  _seekTo(Duration(seconds: seconds));
                },
                child: Container(
                  width: double.infinity,
                  height: 12,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: isDarkMode
                      ? AppTheme.surfaceVariantDark.withOpacity(0.8)
                      : AppTheme.surfaceVariant.withOpacity(0.9),
                  ),
                  child: Stack(
                    children: [
                      // Progress bar fill
                      Container(
                        width: maxWidth * progress,
                        height: 12,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          gradient: LinearGradient(
                            colors: [AppTheme.primaryBlue, AppTheme.primaryLight],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryBlue.withOpacity(0.3),
                              blurRadius: 4,
                              spreadRadius: 0.5,
                            ),
                          ],
                        ),
                      ),
                      
                      // Thumb (handle)
                      Positioned(
                        left: (maxWidth * progress) - 6,
                        top: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 3,
                                spreadRadius: 0.3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerControls(bool isDarkMode) {
    return Column(
      children: [
        // Main Controls Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Skip backward button
            GestureDetector(
              onTap: () => _rewind(),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      isDarkMode
                        ? AppTheme.surfaceVariantDark.withOpacity(0.9)
                        : AppTheme.surfaceVariant.withOpacity(0.9),
                      isDarkMode
                        ? AppTheme.surfaceDark.withOpacity(0.8)
                        : AppTheme.surface.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: isDarkMode
                      ? AppTheme.primaryBlue.withOpacity(0.3)
                      : AppTheme.primaryBlue.withOpacity(0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.replay_10_rounded,
                      size: 28,
                      color: AppTheme.primaryBlue,
                    ),
                  ],
                ),
              ),
            ),

            // Play/Pause button
            GestureDetector(
              onTap: _togglePlayPause,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryBlue, AppTheme.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withOpacity(0.4),
                      blurRadius: 16,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    key: ValueKey<bool>(_isPlaying),
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Skip forward button
            GestureDetector(
              onTap: () => _fastForward(),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      isDarkMode
                        ? AppTheme.surfaceVariantDark.withOpacity(0.9)
                        : AppTheme.surfaceVariant.withOpacity(0.9),
                      isDarkMode
                        ? AppTheme.surfaceDark.withOpacity(0.8)
                        : AppTheme.surface.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: isDarkMode
                      ? AppTheme.primaryBlue.withOpacity(0.3)
                      : AppTheme.primaryBlue.withOpacity(0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.forward_10_rounded,
                      size: 28,
                      color: AppTheme.primaryBlue,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Enhanced Playback Speed Control
        _buildSpeedControl(isDarkMode),
      ],
    );
  }

  Widget _buildSpeedControl(bool isDarkMode) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: _isSpeedControlExpanded
        ? _buildExpandedSpeedControl(isDarkMode)
        : _buildCompactSpeedControl(isDarkMode),
    );
  }

  Widget _buildCompactSpeedControl(bool isDarkMode) {
    return GestureDetector(
      onTap: _toggleSpeedControl,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryBlue.withOpacity(0.1),
              AppTheme.primaryLight.withOpacity(0.15),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryBlue.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.speed,
              size: 18,
              color: AppTheme.primaryBlue,
            ),
            const SizedBox(width: 6),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Text(
                '${_playbackSpeed}x',
                key: ValueKey<double>(_playbackSpeed),
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedSpeedControl(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue.withOpacity(0.1),
            AppTheme.primaryLight.withOpacity(0.15),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Left speeds (0.25x, 0.5x)
          ..._speedOptions.where((speed) => speed < 1.0).map((speed) =>
            _buildSpeedOption(speed, isDarkMode)
          ).toList(),

          // Current speed (center)
          GestureDetector(
            onTap: _toggleSpeedControl,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.speed,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_playbackSpeed}x',
                    style: AppTheme.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right speeds (1.25x, 1.5x)
          ..._speedOptions.where((speed) => speed > 1.0).map((speed) =>
            _buildSpeedOption(speed, isDarkMode)
          ).toList(),
        ],
      ),
    );
  }

  Widget _buildSpeedOption(double speed, bool isDarkMode) {
    final isSelected = speed == _playbackSpeed;
    return GestureDetector(
      onTap: () {
        _changePlaybackSpeed(speed);
        _toggleSpeedControl();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
            ? AppTheme.primaryBlue.withOpacity(0.2)
            : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '${speed}x',
          style: AppTheme.bodySmall.copyWith(
            color: isSelected
              ? AppTheme.primaryBlue
              : (isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildScriptToggle(bool isDarkMode) {
    return GestureDetector(
      onTap: () => _showScriptBottomSheet(isDarkMode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.secondaryGreen.withOpacity(0.15),
              AppTheme.secondaryGreen.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppTheme.secondaryGreen.withOpacity(0.1),
              blurRadius: 4,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: AppTheme.secondaryGreen.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.article_outlined,
              color: AppTheme.secondaryGreen,
              size: 22,
            ),
            const SizedBox(width: 10),
            Text(
              'View Transcript',
              style: AppTheme.labelLarge.copyWith(
                color: AppTheme.secondaryGreen,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showScriptBottomSheet(bool isDarkMode) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: isDarkMode ? AppTheme.backgroundDark : AppTheme.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDarkMode ? AppTheme.surfaceVariantDark : AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.article,
                      color: AppTheme.primaryBlue,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Podcast Script',
                      style: AppTheme.headingMedium.copyWith(
                        color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Script content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: _buildScriptContent(isDarkMode),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScriptContent(bool isDarkMode) {
    // Get the actual script content from the podcast metadata
    final script = widget.podcast.metadata['script'] as String? ??
                   widget.podcast.metadata['content'] as String? ??
                   'No script available for this podcast.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Script title
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.primaryBlue.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.article,
                color: AppTheme.primaryBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Podcast Script',
                style: AppTheme.titleMedium.copyWith(
                  color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Script content
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode ? AppTheme.surfaceDark : AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode ? AppTheme.surfaceVariantDark : AppTheme.borderLight,
            ),
          ),
          child: SelectableText(
            script,
            style: AppTheme.bodyMedium.copyWith(
              color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
              height: 1.6,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.secondaryRed.withOpacity(0.1),
                border: Border.all(
                  color: AppTheme.secondaryRed.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.error_outline,
                size: 40,
                color: AppTheme.secondaryRed,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Audio Playback Error',
              style: AppTheme.headingMedium.copyWith(
                color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Unable to load the audio file. Please try again.',
              style: AppTheme.bodyMedium.copyWith(
                color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _initializePlayer(),
                  icon: Icon(Icons.refresh, color: Colors.white),
                  label: Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () => _downloadPodcast(),
                  icon: Icon(Icons.download),
                  label: Text('Download'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                    side: BorderSide(
                      color: isDarkMode ? AppTheme.surfaceVariantDark : AppTheme.borderLight,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(Icons.arrow_back),
              label: Text('Go Back'),
              style: OutlinedButton.styleFrom(
                foregroundColor: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                side: BorderSide(
                  color: isDarkMode ? AppTheme.surfaceVariantDark.withOpacity(0.5) : AppTheme.borderLight.withOpacity(0.5),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Validates that a WAV file has proper headers and format
  Future<bool> _validateWavFile(File file) async {
    try {
      final bytes = await file.readAsBytes();

      // Check minimum file size (WAV header is 44 bytes)
      if (bytes.length < 44) {
        print('❌ WAV file too small: ${bytes.length} bytes');
        return false;
      }

      // Check RIFF header
      final riffHeader = String.fromCharCodes(bytes.sublist(0, 4));
      if (riffHeader != 'RIFF') {
        print('❌ Invalid RIFF header: $riffHeader');
        return false;
      }

      // Check WAVE format
      final waveFormat = String.fromCharCodes(bytes.sublist(8, 12));
      if (waveFormat != 'WAVE') {
        print('❌ Invalid WAVE format: $waveFormat');
        return false;
      }

      // Check fmt chunk
      final fmtChunk = String.fromCharCodes(bytes.sublist(12, 16));
      if (fmtChunk != 'fmt ') {
        print('❌ Invalid fmt chunk: $fmtChunk');
        return false;
      }

      print('✅ WAV file validation passed');
      return true;
    } catch (e) {
      print('❌ WAV validation error: $e');
      return false;
    }
  }

  /// Gets the appropriate MIME type for an audio file based on its extension
  String _getMimeType(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    switch (extension) {
      case 'wav':
        return 'audio/wav';
      case 'mp3':
        return 'audio/mpeg';
      case 'aac':
        return 'audio/aac';
      case 'm4a':
        return 'audio/mp4';
      case 'ogg':
        return 'audio/ogg';
      case 'flac':
        return 'audio/flac';
      default:
        return 'audio/wav'; // Default to WAV
    }
  }
}
