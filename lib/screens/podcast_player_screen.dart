import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:echogenai/constants/app_theme.dart';
import 'package:echogenai/widgets/app_bar_widget.dart';
import 'package:echogenai/services/storage_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
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
  late AnimationController _waveController;
  late Animation<double> _playButtonAnimation;
  late Animation<double> _waveAnimation;

  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _showScript = false;
  bool _hasError = false;
  String? _errorMessage;

  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  double _playbackSpeed = 1.0;
  final List<double> _speedOptions = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _setupAnimations();
    _initializePlayer();
    _setupAudioListeners();
  }

  void _setupAnimations() {
    _playButtonController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _waveController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _playButtonAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _playButtonController,
      curve: Curves.easeInOut,
    ));

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _playButtonController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _setupAudioListeners() {
    // Listen to position changes
    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    });

    // Listen to duration changes
    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _totalDuration = duration;
        });
      }
    });

    // Listen to player state changes
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });

        if (state == PlayerState.playing) {
          _playButtonController.forward();
          _waveController.repeat();
        } else {
          _playButtonController.reverse();
          _waveController.stop();
        }
      }
    });

    // Listen to completion
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _currentPosition = Duration.zero;
        });
        _playButtonController.reverse();
        _waveController.stop();
      }
    });
  }

  Future<void> _initializePlayer() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      // Check if audio file exists
      final audioFile = File(widget.podcast.audioPath);
      if (!await audioFile.exists()) {
        throw Exception('Audio file not found at: ${widget.podcast.audioPath}');
      }

      // Set the audio source
      await _audioPlayer.setSourceDeviceFile(widget.podcast.audioPath);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
      _showError('Failed to load audio: $e');
    }
  }

  Future<void> _togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.resume();
      }
    } catch (e) {
      _showError('Playback error: $e');
    }
  }

  Future<void> _seekTo(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      _showError('Seek error: $e');
    }
  }

  void _skipForward() {
    final newPosition = _currentPosition + const Duration(seconds: 15);
    if (newPosition <= _totalDuration) {
      _seekTo(newPosition);
    }
  }

  void _skipBackward() {
    final newPosition = _currentPosition - const Duration(seconds: 15);
    if (newPosition >= Duration.zero) {
      _seekTo(newPosition);
    } else {
      _seekTo(Duration.zero);
    }
  }

  Future<void> _changePlaybackSpeed() async {
    final currentIndex = _speedOptions.indexOf(_playbackSpeed);
    final nextIndex = (currentIndex + 1) % _speedOptions.length;
    final newSpeed = _speedOptions[nextIndex];

    try {
      await _audioPlayer.setPlaybackRate(newSpeed);
      setState(() {
        _playbackSpeed = newSpeed;
      });
    } catch (e) {
      _showError('Failed to change playback speed: $e');
    }
  }

  Future<void> _downloadPodcast() async {
    try {
      final sourceFile = File(widget.podcast.audioPath);
      if (!await sourceFile.exists()) {
        throw Exception('Audio file not found');
      }

      // Get user's preferred download directory
      final prefs = await SharedPreferences.getInstance();
      final folderType = prefs.getString('download_folder_type') ?? 'app_documents';

      Directory targetDirectory;
      String locationName;

      switch (folderType) {
        case 'downloads':
          targetDirectory = Directory('/storage/emulated/0/Download/EchoGenAI');
          locationName = 'Downloads folder';
          break;
        case 'external':
          targetDirectory = Directory('/storage/emulated/0/EchoGenAI');
          locationName = 'External storage';
          break;
        case 'custom':
          final customPath = prefs.getString('custom_download_path');
          if (customPath != null) {
            targetDirectory = Directory('$customPath/EchoGenAI');
            locationName = 'Custom folder (${customPath.split('/').last})';
          } else {
            targetDirectory = await getApplicationDocumentsDirectory();
            locationName = 'App documents';
          }
          break;
        default:
          targetDirectory = await getApplicationDocumentsDirectory();
          locationName = 'App documents';
      }

      // Create directory if it doesn't exist
      if (!await targetDirectory.exists()) {
        await targetDirectory.create(recursive: true);
      }

      // Generate a clean filename
      final cleanTitle = widget.podcast.title
          .replaceAll(RegExp(r'[^\w\s-]'), '')
          .replaceAll(RegExp(r'\s+'), '_');
      final fileName = '${cleanTitle}_${DateTime.now().millisecondsSinceEpoch}.wav';
      final targetFile = File('${targetDirectory.path}/$fileName');

      // Copy the file
      await sourceFile.copy(targetFile.path);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.download_done, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Podcast saved to $locationName'),
                ),
              ],
            ),
            backgroundColor: AppTheme.secondaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            action: SnackBarAction(
              label: 'View',
              textColor: Colors.white,
              onPressed: () {
                // Could open file manager here
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
    final minutes = twoDigits(duration.inMinutes.remainder(60));
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
              : Column(
              children: [
                // Podcast Info Card - Expanded to take more space
                Expanded(
                  flex: 3,
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    child: _buildPodcastInfoCard(isDarkMode),
                  ),
                ),

                // Player Controls Section
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Progress Bar
                      _buildProgressBar(isDarkMode),
                      const SizedBox(height: 24),

                      // Player Controls
                      _buildPlayerControls(isDarkMode),
                      const SizedBox(height: 24),

                      // Script Toggle
                      _buildScriptToggle(isDarkMode),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPodcastInfoCard(bool isDarkMode) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue.withOpacity(0.1),
            AppTheme.primaryLight.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.2),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableHeight = constraints.maxHeight;
          final iconSize = (availableHeight * 0.5).clamp(100.0, 160.0);

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Podcast Icon - Responsive size based on available space
              Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryBlue, AppTheme.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(iconSize / 2),
                  child: Image.asset(
                    'lib/assets/logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.podcasts,
                        size: iconSize * 0.4,
                        color: Colors.white,
                      );
                    },
                  ),
                ),
              ),

              SizedBox(height: availableHeight * 0.05),

              // Title - Responsive text
              Flexible(
                child: Text(
                  widget.podcast.title,
                  style: AppTheme.headingLarge.copyWith(
                    color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: (availableHeight * 0.06).clamp(16.0, 22.0),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              SizedBox(height: availableHeight * 0.03),

              // Metadata - Compact chips
              Flexible(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildMetadataChip(
                      icon: Icons.category,
                      label: widget.podcast.metadata['category'] ?? 'Unknown',
                      isDarkMode: isDarkMode,
                    ),
                    _buildMetadataChip(
                      icon: Icons.people,
                      label: '${widget.podcast.metadata['speaker1']} & ${widget.podcast.metadata['speaker2']}',
                      isDarkMode: isDarkMode,
                    ),
                    _buildMetadataChip(
                      icon: Icons.access_time,
                      label: _totalDuration.inSeconds > 0
                          ? _formatDuration(_totalDuration)
                          : widget.podcast.metadata['duration'] ?? 'Unknown',
                      isDarkMode: isDarkMode,
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
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.surfaceDark : AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode ? AppTheme.surfaceVariantDark : AppTheme.borderLight,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primaryBlue),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDuration(_currentPosition),
              style: AppTheme.bodySmall.copyWith(
                color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
              ),
            ),
            Text(
              _formatDuration(_totalDuration),
              style: AppTheme.bodySmall.copyWith(
                color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppTheme.primaryBlue,
            inactiveTrackColor: isDarkMode ? AppTheme.surfaceVariantDark : AppTheme.surfaceVariant,
            thumbColor: AppTheme.primaryBlue,
            overlayColor: AppTheme.primaryBlue.withOpacity(0.2),
            trackHeight: 4,
          ),
          child: Slider(
            value: _totalDuration.inSeconds > 0
                ? _currentPosition.inSeconds.toDouble().clamp(0.0, _totalDuration.inSeconds.toDouble())
                : 0.0,
            max: _totalDuration.inSeconds > 0 ? _totalDuration.inSeconds.toDouble() : 1.0,
            onChanged: (value) {
              _seekTo(Duration(seconds: value.toInt()));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerControls(bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () => _skipBackward(),
          icon: Icon(Icons.replay_10, size: 32),
          color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
        ),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primaryBlue,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withOpacity(0.3),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: IconButton(
            onPressed: _togglePlayPause,
            icon: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              size: 32,
              color: Colors.white,
            ),
          ),
        ),
        IconButton(
          onPressed: () => _skipForward(),
          icon: Icon(Icons.forward_10, size: 32),
          color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
        ),
        // Speed control
        GestureDetector(
          onTap: () => _changePlaybackSpeed(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3)),
            ),
            child: Text(
              '${_playbackSpeed}x',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }



  Widget _buildScriptToggle(bool isDarkMode) {
    return GestureDetector(
      onTap: () => _showScriptBottomSheet(isDarkMode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDarkMode ? AppTheme.surfaceDark : AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDarkMode ? AppTheme.surfaceVariantDark : AppTheme.borderLight,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.visibility,
              color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              'Show Script',
              style: AppTheme.bodyMedium.copyWith(
                color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
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
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.arrow_back),
                  label: Text('Go Back'),
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
          ],
        ),
      ),
    );
  }
}
