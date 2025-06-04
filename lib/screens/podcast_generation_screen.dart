import 'package:flutter/material.dart';
import 'package:echogenai/constants/app_theme.dart';
import 'package:echogenai/widgets/app_bar_widget.dart';
import 'package:echogenai/services/storage_service.dart';
import 'package:echogenai/services/tts_service.dart';
import 'package:echogenai/services/ai_service.dart';
import 'package:echogenai/screens/podcast_player_screen.dart';

class PodcastGenerationScreen extends StatefulWidget {
  final String script;
  final String sourceTitle;
  final String sourceUrl;
  final String category;
  final String speaker1;
  final String speaker2;

  const PodcastGenerationScreen({
    super.key,
    required this.script,
    required this.sourceTitle,
    required this.sourceUrl,
    required this.category,
    required this.speaker1,
    required this.speaker2,
  });

  @override
  State<PodcastGenerationScreen> createState() => _PodcastGenerationScreenState();
}

class _PodcastGenerationScreenState extends State<PodcastGenerationScreen>
    with TickerProviderStateMixin {
  final TTSService _ttsService = TTSService();
  final StorageService _storageService = StorageService();
  final AIService _aiService = AIService();

  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  String _selectedTTSProvider = 'Gemini';
  String? _selectedSpeaker1Voice;
  String? _selectedSpeaker2Voice;
  
  List<TTSVoice> _availableVoices = [];
  bool _isLoadingVoices = false;
  bool _isGenerating = false;
  String? _error;
  
  double _generationProgress = 0.0;
  String _currentStep = '';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadVoices();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  Future<void> _loadVoices() async {
    setState(() {
      _isLoadingVoices = true;
      _error = null;
    });

    try {
      final voices = await _ttsService.getAvailableVoices(_selectedTTSProvider);
      setState(() {
        _availableVoices = voices;
        _selectedSpeaker1Voice = voices.isNotEmpty ? voices.first.id : null;
        _selectedSpeaker2Voice = voices.length > 1 ? voices[1].id : voices.first.id;
        _isLoadingVoices = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoadingVoices = false;
        _availableVoices = [];
      });
    }
  }

  Future<void> _generatePodcast() async {
    if (_selectedSpeaker1Voice == null || _selectedSpeaker2Voice == null) {
      _showError('Please select voices for both speakers');
      return;
    }

    setState(() {
      _isGenerating = true;
      _error = null;
      _generationProgress = 0.0;
      _currentStep = 'Initializing podcast generation...';
    });

    try {
      // Step 1: Parse script
      await Future.delayed(const Duration(milliseconds: 800));
      setState(() {
        _generationProgress = 0.15;
        _currentStep = 'Analyzing script structure...';
      });

      // Step 2: Prepare TTS request
      await Future.delayed(const Duration(milliseconds: 600));
      setState(() {
        _generationProgress = 0.25;
        _currentStep = 'Preparing voice synthesis...';
      });

      // Step 3: Generate audio (this is the main step)
      setState(() {
        _generationProgress = 0.35;
        _currentStep = 'Generating ${widget.speaker1} and ${widget.speaker2} voices...';
      });

      // Generate the actual podcast with speaker names
      final podcastPath = await _ttsService.generatePodcast(
        script: widget.script,
        speaker1Voice: _selectedSpeaker1Voice!,
        speaker2Voice: _selectedSpeaker2Voice!,
        provider: _selectedTTSProvider,
        speaker1Name: widget.speaker1,
        speaker2Name: widget.speaker2,
      );

      // Step 4: Processing audio
      await Future.delayed(const Duration(milliseconds: 400));
      setState(() {
        _generationProgress = 0.75;
        _currentStep = 'Processing audio quality...';
      });

      // Step 5: Finalizing
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() {
        _generationProgress = 0.90;
        _currentStep = 'Finalizing podcast...';
      });

      // Extract title from script using AI service
      final extractedTitle = _aiService.extractTitleFromScript(widget.script);
      final finalTitle = extractedTitle.isNotEmpty ? extractedTitle : widget.sourceTitle;

      // Calculate approximate duration (rough estimate based on text length)
      final wordCount = widget.script.split(' ').length;
      final estimatedMinutes = (wordCount / 150).ceil(); // ~150 words per minute
      final duration = '${estimatedMinutes}:00';

      // Save to library
      final podcast = GeneratedPodcast(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: finalTitle,
        scriptId: '', // We could link to script if needed
        audioPath: podcastPath,
        status: 'completed',
        generatedAt: DateTime.now(),
        metadata: {
          'category': widget.category,
          'speaker1': widget.speaker1,
          'speaker2': widget.speaker2,
          'speaker1Voice': _selectedSpeaker1Voice!,
          'speaker2Voice': _selectedSpeaker2Voice!,
          'provider': _selectedTTSProvider,
          'sourceUrl': widget.sourceUrl,
          'duration': duration,
          'wordCount': wordCount,
        },
      );

      await _storageService.saveGeneratedPodcast(podcast);

      // Final step
      setState(() {
        _generationProgress = 1.0;
        _currentStep = 'Podcast ready!';
      });

      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        setState(() {
          _isGenerating = false;
        });

        // Navigate to podcast player
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => PodcastPlayerScreen(podcast: podcast),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
        _showError(e.toString());
      }
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    if (_isGenerating) {
      return _buildGeneratingScreen(isDarkMode);
    }

    return Scaffold(
      appBar: const EchoGenAppBar(
        title: 'Generate Podcast',
        showLogo: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Script Info
            _buildScriptInfo(isDarkMode),
            const SizedBox(height: 24),
            
            // TTS Provider Selection
            _buildTTSProviderSelection(isDarkMode),
            const SizedBox(height: 16),
            
            // Voice Selection
            _buildVoiceSelection(isDarkMode),
            const SizedBox(height: 24),
            
            // Generate Button
            _buildGenerateButton(isDarkMode),
            
            // Error Display
            if (_error != null) ...[
              const SizedBox(height: 16),
              _buildErrorDisplay(isDarkMode),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGeneratingScreen(bool isDarkMode) {
    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.backgroundDark : AppTheme.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated AI Icon
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: AnimatedBuilder(
                      animation: _rotationAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotationAnimation.value * 2 * 3.14159,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primaryBlue,
                                  AppTheme.primaryLight,
                                  AppTheme.secondaryGreen,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryBlue.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.auto_awesome,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 40),
              
              // Progress Bar
              Container(
                width: double.infinity,
                height: 8,
                decoration: BoxDecoration(
                  color: isDarkMode ? AppTheme.surfaceVariantDark : AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _generationProgress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primaryBlue, AppTheme.primaryLight],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Progress Text
              Text(
                'Generating Your Podcast',
                style: AppTheme.headingLarge.copyWith(
                  color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 12),
              
              Text(
                _currentStep,
                style: AppTheme.bodyLarge.copyWith(
                  color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              Text(
                '${(_generationProgress * 100).toInt()}% Complete',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              // Fun message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3)),
                ),
                child: Text(
                  '🎙️ Creating magic with AI voices...\nYour podcast will be ready soon!',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScriptInfo(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.surfaceDark : AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? AppTheme.surfaceVariantDark : AppTheme.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Script Information',
            style: AppTheme.titleMedium.copyWith(
              color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Title', widget.sourceTitle, isDarkMode),
          const SizedBox(height: 8),
          _buildInfoRow('Category', widget.category, isDarkMode),
          const SizedBox(height: 8),
          _buildInfoRow('Speaker 1', widget.speaker1, isDarkMode),
          const SizedBox(height: 8),
          _buildInfoRow('Speaker 2', widget.speaker2, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDarkMode) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: AppTheme.bodyMedium.copyWith(
              color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTheme.bodyMedium.copyWith(
              color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTTSProviderSelection(bool isDarkMode) {
    final providers = ['Gemini', 'OpenAI', 'ElevenLabs'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.surfaceDark : AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? AppTheme.surfaceVariantDark : AppTheme.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TTS Provider',
            style: AppTheme.titleMedium.copyWith(
              color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedTTSProvider,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: providers.map((provider) {
              return DropdownMenuItem(
                value: provider,
                child: Text(provider),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedTTSProvider = value;
                  _selectedSpeaker1Voice = null;
                  _selectedSpeaker2Voice = null;
                });
                _loadVoices();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceSelection(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.surfaceDark : AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? AppTheme.surfaceVariantDark : AppTheme.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Voice Selection',
            style: AppTheme.titleMedium.copyWith(
              color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          if (_isLoadingVoices)
            const Center(child: CircularProgressIndicator())
          else if (_availableVoices.isEmpty)
            Text(
              'No voices available for this provider.',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.secondaryRed,
              ),
            )
          else ...[
            // Speaker 1 Voice
            Text(
              '${widget.speaker1} Voice',
              style: AppTheme.bodyMedium.copyWith(
                color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedSpeaker1Voice,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: _availableVoices.map((voice) {
                return DropdownMenuItem(
                  value: voice.id,
                  child: Text('${voice.name} (${voice.gender})'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSpeaker1Voice = value;
                });
              },
            ),
            const SizedBox(height: 16),
            // Speaker 2 Voice
            Text(
              '${widget.speaker2} Voice',
              style: AppTheme.bodyMedium.copyWith(
                color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedSpeaker2Voice,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: _availableVoices.map((voice) {
                return DropdownMenuItem(
                  value: voice.id,
                  child: Text('${voice.name} (${voice.gender})'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSpeaker2Voice = value;
                });
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGenerateButton(bool isDarkMode) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: _isGenerating || _selectedSpeaker1Voice == null || _selectedSpeaker2Voice == null
            ? null
            : _generatePodcast,
        icon: _isGenerating
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(Icons.play_arrow, color: Colors.white),
        label: Text(_isGenerating ? 'Generating...' : 'Generate Podcast'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorDisplay(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.secondaryRed.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: AppTheme.secondaryRed, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _error!,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.secondaryRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}