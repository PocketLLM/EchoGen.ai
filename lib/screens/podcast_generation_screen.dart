import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:echogenai/constants/app_theme.dart';
import 'package:echogenai/widgets/app_bar_widget.dart';
import 'package:echogenai/services/storage_service.dart';
import 'package:echogenai/services/tts_service.dart';
import 'package:echogenai/services/ai_service.dart';
import 'package:echogenai/screens/cover_art_generation_screen.dart';
import 'dart:io';
import 'package:echogenai/screens/podcast_player_screen.dart';
import 'dart:io';

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
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final TTSService _ttsService = TTSService();
  final StorageService _storageService = StorageService();
  final AIService _aiService = AIService();

  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _waveAnimation;

  String _selectedTTSProvider = 'Gemini';
  String? _selectedSpeaker1Voice;
  String? _selectedSpeaker2Voice;
  String _selectedModel = 'gemini-2.5-flash-preview-tts'; // Default model
  String _selectedLanguageCode = 'en-US'; // Default language
  String? _customCoverArtPath; // Path to custom generated cover art
  
  // Available models
  final List<Map<String, dynamic>> _availableModels = [
    {
      'id': 'gemini-2.5-flash-preview-tts', 
      'name': 'Gemini 2.5 Flash TTS', 
      'description': 'Fast voice generation with good quality'
    },
    {
      'id': 'gemini-2.5-pro-preview-tts', 
      'name': 'Gemini 2.5 Pro TTS', 
      'description': 'Higher quality voice with more natural intonation'
    },
  ];
  
  // Available languages
  final List<Map<String, dynamic>> _availableLanguages = [
    {'code': 'en-US', 'name': 'English (US)'},
    {'code': 'ko-KR', 'name': 'Korean'},
    {'code': 'ja-JP', 'name': 'Japanese'},
    {'code': 'zh-CN', 'name': 'Chinese (Simplified)'},
    {'code': 'fr-FR', 'name': 'French'},
    {'code': 'de-DE', 'name': 'German'},
    {'code': 'es-US', 'name': 'Spanish (US)'},
    {'code': 'it-IT', 'name': 'Italian'},
    {'code': 'pt-BR', 'name': 'Portuguese (Brazil)'},
    {'code': 'hi-IN', 'name': 'Hindi'},
  ];
  
  List<TTSVoice> _availableVoices = [];
  bool _isLoadingVoices = false;
  bool _isGenerating = false;
  String? _error;
  
  double _generationProgress = 0.0;
  String _currentStep = '';
  bool _keepConnectionAlive = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadVoices();
    _verifyApiKeyConfig();
    
    // Register for app lifecycle changes
    WidgetsBinding.instance.addObserver(this as WidgetsBindingObserver);
  }
  
  // Check API key configuration on startup
  Future<void> _verifyApiKeyConfig() async {
    try {
      await _ttsService.verifyGeminiApiKey();
    } catch (e) {
      // We'll show this error when the user tries to generate
      print('⚠️ API key verification warning: $e');
    }
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
    
    _waveController = AnimationController(
      duration: const Duration(seconds: 1),
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
    
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
    _waveController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _waveController.dispose();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Keep connection alive when app goes to background
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (_isGenerating) {
        setState(() {
          _keepConnectionAlive = true;
        });
        print("🔄 App went to background, keeping connection alive");
      }
    } else if (state == AppLifecycleState.resumed) {
      print("✅ App resumed from background");
    }
    super.didChangeAppLifecycleState(state);
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
      _currentStep = 'Firing up the podcast kitchen 🔥';
      _keepConnectionAlive = true;  // Flag to maintain connection in background
    });

    try {
      // Step 1: Parse script
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _generationProgress = 0.15;
        _currentStep = 'Reading your script like a bedtime story 📖';
      });

      // Step 2: Prepare TTS request
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() {
        _generationProgress = 0.25;
        _currentStep = 'Warming up the vocal cords 🎤';
      });

      // Step 3: Generate audio (this is the main step)
      setState(() {
        _generationProgress = 0.35;
        _currentStep = 'Bringing ${widget.speaker1} and ${widget.speaker2} to life 🎭';
      });

      // Generate the actual podcast with speaker names
      final podcastPath = await _ttsService.generatePodcast(
        script: widget.script,
        speaker1Voice: _selectedSpeaker1Voice!,
        speaker2Voice: _selectedSpeaker2Voice!,
        provider: _selectedTTSProvider,
        speaker1Name: widget.speaker1,
        speaker2Name: widget.speaker2,
        model: _selectedModel,
        languageCode: _selectedLanguageCode,
      );

      // Step 4: Processing audio
      setState(() {
        _generationProgress = 0.85;
        _currentStep = 'Polishing the audio to perfection ✨';
      });

      // Extract title from script using AI service
      final extractedTitle = _aiService.extractTitleFromScript(widget.script);
      final finalTitle = extractedTitle.isNotEmpty ? extractedTitle : widget.sourceTitle;

      // Calculate approximate duration (based on script length)
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
          'script': widget.script, // Store the script in metadata for reference
          'audioFormat': 'wav', // Store the correct format for better compatibility
          'language': _selectedLanguageCode, // Store selected language
          'customCoverArt': _customCoverArtPath, // Store custom cover art path if generated
        },
      );

      await _storageService.saveGeneratedPodcast(podcast);
      
      // No need to save a duplicate MP3 version - save storage space
      // Final step
      setState(() {
        _generationProgress = 1.0;
        _currentStep = 'Your podcast is ready to serve! 🎧🍽️';
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
      print('Error during podcast generation: $e');
      if (mounted) {
        setState(() {
          _isGenerating = false;
          _error = e.toString();
        });
        
        // Extract more user-friendly error message
        String errorMessage = e.toString();
        if (errorMessage.contains('API key not found')) {
          errorMessage = 'Gemini API key not found. Please add your API key in Settings > API Keys.';
        } else if (errorMessage.contains('Invalid Gemini API key format')) {
          errorMessage = 'Your API key appears to be invalid. Gemini API keys start with "AIza" and are at least 20 characters long.';
        } else if (errorMessage.contains('429')) {
          errorMessage = 'API rate limit exceeded. Please try again later.';
        } else if (errorMessage.contains('403') || errorMessage.toLowerCase().contains('permission')) {
          errorMessage = 'API access denied. Make sure your API key is correct and has access to Gemini TTS.';
        } else if (errorMessage.toLowerCase().contains('network')) {
          errorMessage = 'Network error. Please check your internet connection and try again.';
        } else if (errorMessage.contains('500')) {
          errorMessage = 'Server error from Google Gemini. Please try again later.';
        }
        
        _showError(errorMessage);
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
            const SizedBox(height: 16),
            
            // TTS Provider Selection
            _buildTTSProviderSelection(isDarkMode),
            const SizedBox(height: 16),
            
            // Model Selection
            _buildModelSelection(isDarkMode),
            const SizedBox(height: 16),
            
            // Language Selection (NEW)
            _buildLanguageSelection(isDarkMode),
            const SizedBox(height: 16),
            
            // Voice Selection
            _buildVoiceSelection(isDarkMode),
            const SizedBox(height: 24),

            // Cover Art Section
            _buildCoverArtSection(isDarkMode),
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
      body: WillPopScope(
        // Prevent accidental back navigation during generation
        onWillPop: () async {
          if (_generationProgress > 0.1 && _generationProgress < 0.9) {
            final confirmExit = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Cancel Generation?'),
                content: Text('Podcast generation is in progress. Are you sure you want to cancel?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('Continue'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text('Cancel'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondaryRed),
                  ),
                ],
              ),
            );
            return confirmExit ?? false;
          }
          return true;
        },
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated AI Icon with sound wave effect
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Sound waves animation
                    ...List.generate(3, (index) {
                      return AnimatedBuilder(
                        animation: _waveAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1.0 + (index * 0.3) + (_waveAnimation.value * 0.3),
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.transparent,
                                border: Border.all(
                                  color: AppTheme.primaryBlue.withOpacity(0.3 - (index * 0.1)), 
                                  width: 3,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }),
                    
                    // Main icon
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
                                    Icons.podcasts,
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
                  ],
                ),
                
                const SizedBox(height: 40),
                
                // Progress Indicator - Enhanced with pulsing and more visual effects
                Container(
                  width: double.infinity,
                  height: 16,
                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDarkMode ? AppTheme.surfaceVariantDark : AppTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        spreadRadius: 0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Main progress bar
                      FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _generationProgress,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppTheme.primaryBlue, AppTheme.primaryLight],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryBlue.withOpacity(0.3),
                                blurRadius: 4,
                                spreadRadius: 0,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Animated glow at progress edge
                      if (_generationProgress > 0.05 && _generationProgress < 0.98)
                        Positioned(
                          left: MediaQuery.of(context).size.width * 0.8 * _generationProgress - 35,
                          top: -4,
                          child: AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.1 + (0.1 * _pulseAnimation.value)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryBlue.withOpacity(0.3 + (0.1 * _pulseAnimation.value)),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                    ],
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
                
                // Current step with helpful messages
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _currentStep,
                        style: AppTheme.bodyLarge.copyWith(
                          color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getHelpfulMessage(),
                        style: AppTheme.bodyMedium.copyWith(
                          color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  '${(_generationProgress * 100).toInt()}% Complete',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 40),
                
                // Time estimation
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.2)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '🎙️ Creating AI-powered podcast',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 18,
                            color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              _getEstimatedTimeLeft(),
                              style: AppTheme.bodySmall.copyWith(
                                color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  String _getEstimatedTimeLeft() {
    if (_generationProgress < 0.05) return "Preparing...";
    if (_generationProgress > 0.95) return "Almost done!";

    // Calculate based on script length
    final scriptLength = widget.script.length;
    final baseTime = 5 + (scriptLength / 1000); // 5 seconds base + 1 second per 1000 chars
    final remainingPercentage = 1.0 - _generationProgress;
    final secondsLeft = (baseTime * remainingPercentage).round();

    if (secondsLeft < 60) {
      return "$secondsLeft sec remaining";
    } else {
      final minutes = secondsLeft ~/ 60;
      final seconds = secondsLeft % 60;
      return "$minutes:${seconds.toString().padLeft(2, '0')} min remaining";
    }
  }

  String _getHelpfulMessage() {
    if (_generationProgress < 0.2) {
      return "Keep the app open, cooking spices for you 🌶️";
    } else if (_generationProgress < 0.4) {
      return "Generating content, audio is just on the door 🎵";
    } else if (_generationProgress < 0.6) {
      return "Mixing voices like a master chef 👨‍🍳";
    } else if (_generationProgress < 0.8) {
      return "Adding the final touches ✨";
    } else if (_generationProgress < 0.95) {
      return "Almost ready to serve your podcast 🎧";
    } else {
      return "Bon appétit! Your podcast is ready 🍽️";
    }
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
          
          // Gemini option (active)
          _buildProviderOption(
            'Gemini', 
            'Google\'s advanced text-to-speech technology', 
            true, 
            isDarkMode,
            svgAsset: 'lib/assets/icons/gemini.svg',
          ),
          
          // OpenAI option (coming soon)
          _buildProviderOption(
            'OpenAI', 
            'Coming Soon', 
            false, 
            isDarkMode,
            svgAsset: isDarkMode ? 'lib/assets/icons/OpenAI_dark.svg' : 'lib/assets/icons/OpenAI_light.svg',
          ),
          
          // ElevenLabs option (coming soon)  
          _buildProviderOption(
            'ElevenLabs', 
            'Coming Soon', 
            false, 
            isDarkMode,
            icon: Icons.spatial_audio,
          ),
        ],
      ),
    );
  }

  Widget _buildProviderOption(String name, String description, bool isAvailable, bool isDarkMode, {IconData? icon, String? svgAsset}) {
    return GestureDetector(
      onTap: isAvailable ? () {
        setState(() {
          _selectedTTSProvider = name;
          _selectedSpeaker1Voice = null;
          _selectedSpeaker2Voice = null;
        });
        _loadVoices();
      } : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _selectedTTSProvider == name 
              ? AppTheme.primaryBlue.withOpacity(0.1) 
              : (isAvailable ? Colors.transparent : AppTheme.surfaceVariant.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _selectedTTSProvider == name 
                ? AppTheme.primaryBlue 
                : (isAvailable ? Colors.grey.withOpacity(0.3) : Colors.grey.withOpacity(0.2)),
            width: _selectedTTSProvider == name ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            if (svgAsset != null)
              Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(right: 2),
                child: SvgPicture.asset(
                  svgAsset,
                  colorFilter: ColorFilter.mode(
                    isAvailable 
                      ? (_selectedTTSProvider == name ? AppTheme.primaryBlue : Colors.grey)
                      : Colors.grey.withOpacity(0.6),
                    BlendMode.srcIn,
                  ),
                ),
              )
            else
              Icon(
                icon ?? (isAvailable ? Icons.record_voice_over : Icons.timelapse),
                size: 20,
                color: isAvailable 
                    ? (_selectedTTSProvider == name ? AppTheme.primaryBlue : Colors.grey)
                    : Colors.grey.withOpacity(0.6),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: isAvailable 
                          ? (_selectedTTSProvider == name 
                              ? AppTheme.primaryBlue 
                              : (isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary))
                          : Colors.grey,
                      fontWeight: _selectedTTSProvider == name ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: isAvailable 
                          ? (isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary)
                          : Colors.grey.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (_selectedTTSProvider == name)
              Icon(Icons.check_circle, color: AppTheme.primaryBlue, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildModelSelection(bool isDarkMode) {
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
            'TTS Model',
            style: AppTheme.titleMedium.copyWith(
              color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ..._availableModels.map((model) => _buildModelOption(
            model['id'],
            model['name'],
            model['description'],
            isDarkMode,
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildModelOption(String id, String name, String description, bool isDarkMode) {
    final bool isSelected = _selectedModel == id;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedModel = id;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.model_training,
              size: 20,
              color: isSelected ? AppTheme.primaryBlue : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: isSelected
                          ? AppTheme.primaryBlue
                          : (isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppTheme.primaryBlue, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelection(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.surfaceDark : AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.language,
                color: AppTheme.primaryBlue,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'Language',
                style: AppTheme.titleMedium.copyWith(
                  color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedLanguageCode,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isDarkMode ? AppTheme.textTertiaryDark : AppTheme.border,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isDarkMode ? AppTheme.textTertiaryDark : AppTheme.border,
                ),
              ),
              filled: true,
              fillColor: isDarkMode ? Colors.black26 : Colors.white,
            ),
            items: _availableLanguages.map((language) {
              return DropdownMenuItem<String>(
                value: language['code'],
                child: Text(language['name']),
              );
            }).toList(),
            onChanged: (String? value) {
              if (value != null) {
                setState(() {
                  _selectedLanguageCode = value;
                });
              }
            },
          ),
          const SizedBox(height: 8),
          Text(
            'Select the language for your podcast. This helps the TTS engine generate more natural pronunciation.',
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
            ),
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
              isExpanded: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: _availableVoices.map((voice) {
                return DropdownMenuItem(
                  value: voice.id,
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      '${voice.name} (${voice.gender})',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
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
              isExpanded: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: _availableVoices.map((voice) {
                return DropdownMenuItem(
                  value: voice.id,
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      '${voice.name} (${voice.gender})',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
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

  Widget _buildCoverArtSection(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.secondaryGreen.withOpacity(0.1),
            AppTheme.secondaryGreen.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.secondaryGreen.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.image,
                color: AppTheme.secondaryGreen,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Custom Cover Art',
                style: AppTheme.titleMedium.copyWith(
                  color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                'Optional',
                style: AppTheme.bodySmall.copyWith(
                  color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Generate AI-powered cover art for your podcast using ImageRouter',
            style: AppTheme.bodyMedium.copyWith(
              color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 16),

          if (_customCoverArtPath != null) ...[
            // Show preview of generated cover art
            Container(
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.secondaryGreen.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    child: Image.file(
                      File(_customCoverArtPath!),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey[300],
                          child: Icon(Icons.error, color: Colors.grey[600]),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Custom Cover Art',
                            style: AppTheme.bodyMedium.copyWith(
                              color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'AI-generated cover art ready to use',
                            style: AppTheme.bodySmall.copyWith(
                              color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _customCoverArtPath = null;
                      });
                    },
                    icon: Icon(
                      Icons.close,
                      color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          OutlinedButton.icon(
            onPressed: () => _openCoverArtGeneration(),
            icon: Icon(
              _customCoverArtPath != null ? Icons.edit : Icons.auto_awesome,
              size: 20,
            ),
            label: Text(_customCoverArtPath != null ? 'Edit Cover Art' : 'Generate Cover Art'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.secondaryGreen,
              side: BorderSide(color: AppTheme.secondaryGreen),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openCoverArtGeneration() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => CoverArtGenerationScreen(
          podcastTitle: widget.sourceTitle,
          existingCoverPath: _customCoverArtPath,
          onCoverArtGenerated: (path) {
            setState(() {
              _customCoverArtPath = path;
            });
          },
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _customCoverArtPath = result;
      });
    }
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
    final bool isApiKeyError = _error != null && 
        (_error!.toLowerCase().contains('api key') || 
        _error!.toLowerCase().contains('settings'));
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.secondaryRed.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
          
          if (isApiKeyError) ...[
            const SizedBox(height: 12),
            Center(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed('/api_keys');
                },
                icon: Icon(
                  Icons.vpn_key_rounded,
                  size: 18,
                ),
                label: Text('Go to API Keys Settings'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.secondaryRed,
                  side: BorderSide(color: AppTheme.secondaryRed),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}