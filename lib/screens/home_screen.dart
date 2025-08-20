import 'package:flutter/material.dart';
import 'package:echogenai/constants/app_theme.dart';
import 'package:echogenai/widgets/app_bar_widget.dart';
import 'package:echogenai/widgets/bottom_nav_bar_widget.dart';
import 'package:echogenai/widgets/mini_player_widget.dart';
import 'package:echogenai/screens/about_screen.dart';
import 'package:echogenai/screens/api_keys_screen.dart';
import 'package:echogenai/screens/url_scraping_screen.dart';
import 'package:echogenai/screens/content_preview_screen.dart';
import 'package:echogenai/screens/script_generation_screen.dart';
import 'package:echogenai/screens/script_preview_screen.dart';
import 'package:echogenai/screens/podcast_generation_screen.dart';
import 'package:echogenai/screens/podcast_player_screen.dart';
import 'package:echogenai/services/web_scraping_service.dart';
import 'package:echogenai/services/storage_service.dart';
import 'package:echogenai/services/ai_service.dart';
import 'package:echogenai/services/global_audio_manager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:echogenai/providers/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _hasNewContent = false; // For library badge
  late TabController _tabController;
  
  final List<Widget> _screens = [
    const _CreateTab(),
    const _LibraryTab(),
    const _SettingsTab(),
  ];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Simulate new content in library
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _hasNewContent = true;
        });
      }
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _screens[_selectedIndex],
          // Mini player positioned at the bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 80, // Above the bottom navigation bar
            child: const MiniPlayerWidget(),
          ),
        ],
      ),
      bottomNavigationBar: EchoGenBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            if (index == 1) {
              // Clear badge when library is selected
              _hasNewContent = false;
            }
          });
        },
        showBadge: _hasNewContent && _selectedIndex != 1,
      ),
    );
  }
}

class _CreateTab extends StatefulWidget {
  const _CreateTab();

  @override
  State<_CreateTab> createState() => _CreateTabState();
}

class _CreateTabState extends State<_CreateTab> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _promptSpeaker1Controller = TextEditingController(text: 'Alex');
  final TextEditingController _promptSpeaker2Controller = TextEditingController(text: 'Sam');
  final WebScrapingService _scrapingService = WebScrapingService();
  final StorageService _storageService = StorageService();
  final AIService _aiService = AIService();

  // Provider and model selections
  String _selectedUrlProvider = 'Firecrawl';
  String _selectedAiProvider = 'Gemini';
  String _selectedAiModel = 'gemini-1.5-flash';

  // Prompt tab selections
  String _selectedPromptProvider = 'Gemini';
  String? _selectedPromptModel;
  String _selectedPromptCategory = 'playful';
  List<AIModel> _promptAvailableModels = [];
  bool _isLoadingPromptModels = false;
  String? _promptError;

  // Loading states for buttons
  bool _isQuickFetchLoading = false;
  bool _isAdvancedScrapingLoading = false;
  bool _isGenerateScriptLoading = false;

  // Provider options
  final List<String> _urlProviders = ['Firecrawl', 'HyperbrowserAI'];
  final List<String> _aiProviders = ['Gemini', 'OpenAI', 'Groq', 'OpenRouter'];

  // Model options for each provider
  final Map<String, List<String>> _providerModels = {
    'Gemini': ['gemini-1.5-flash', 'gemini-1.5-pro', 'gemini-1.0-pro'],
    'OpenAI': ['gpt-4o', 'gpt-4o-mini', 'gpt-4-turbo', 'gpt-3.5-turbo'],
    'Groq': ['llama-3.1-70b-versatile', 'llama-3.1-8b-instant', 'mixtral-8x7b-32768'],
    'OpenRouter': ['meta-llama/llama-3.1-405b-instruct', 'anthropic/claude-3.5-sonnet', 'google/gemini-pro-1.5'],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        // Rebuild when tab changes to update colors
      });
    });
    _loadPromptModels();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _urlController.dispose();
    _promptController.dispose();
    _promptSpeaker1Controller.dispose();
    _promptSpeaker2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: const EchoGenAppBar(),
      body: Column(
        children: [
          // Tab Bar
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryBlue.withOpacity(0.1),
                  AppTheme.primaryLight.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.primaryBlue.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: _tabController.index == 0
                          ? LinearGradient(
                              colors: [AppTheme.primaryBlue, AppTheme.primaryLight],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      boxShadow: _tabController.index == 0
                          ? [
                              BoxShadow(
                                color: AppTheme.primaryBlue.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      'From URL',
                      style: TextStyle(
                        color: _tabController.index == 0
                            ? Colors.white
                            : (isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary),
                        fontWeight: _tabController.index == 0 ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                Tab(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: _tabController.index == 1
                          ? LinearGradient(
                              colors: [AppTheme.primaryBlue, AppTheme.primaryLight],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      boxShadow: _tabController.index == 1
                          ? [
                              BoxShadow(
                                color: AppTheme.primaryBlue.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      'From Files',
                      style: TextStyle(
                        color: _tabController.index == 1
                            ? Colors.white
                            : (isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary),
                        fontWeight: _tabController.index == 1 ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                Tab(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: _tabController.index == 2
                          ? LinearGradient(
                              colors: [AppTheme.primaryBlue, AppTheme.primaryLight],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      boxShadow: _tabController.index == 2
                          ? [
                              BoxShadow(
                                color: AppTheme.primaryBlue.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      'From Prompt',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _tabController.index == 2
                            ? Colors.white
                            : (isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary),
                        fontWeight: _tabController.index == 2 ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ],
              labelColor: Colors.transparent,
              unselectedLabelColor: Colors.transparent,
              indicatorColor: Colors.transparent,
              dividerColor: Colors.transparent,
            ),
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUrlTab(),
                _buildFilesTab(),
                _buildPromptTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildUrlTab() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            '🌐 Turn any article into a podcast',
            style: AppTheme.titleLarge.copyWith(
              color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _urlController,
            decoration: InputDecoration(
              labelText: 'Enter URL (article, blog...)',
              hintText: 'https://example.com/article',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '🔧 Content Extraction Provider',
            style: AppTheme.titleMedium.copyWith(
              color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildProviderDropdown(
            value: _selectedUrlProvider,
            items: _urlProviders,
            isUrlProvider: true,
            onChanged: (value) {
              setState(() {
                _selectedUrlProvider = value!;
              });
            },
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isAdvancedScrapingLoading ? null : () async {
                setState(() {
                  _isAdvancedScrapingLoading = true;
                });

                // Simulate loading
                await Future.delayed(const Duration(milliseconds: 500));

                if (mounted) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const UrlScrapingScreen(),
                    ),
                  );

                  setState(() {
                    _isAdvancedScrapingLoading = false;
                  });
                }
              },
              icon: _isAdvancedScrapingLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.web),
              label: Text(_isAdvancedScrapingLoading ? 'Loading...' : 'Advanced Web Scraping'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isQuickFetchLoading ? null : () async {
                await _performQuickFetch();
              },
              icon: _isQuickFetchLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.rocket_launch, color: Colors.white),
              label: Text(_isQuickFetchLoading ? 'Processing...' : 'Quick Fetch Content'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
  
  Widget _buildFilesTab() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            '📄 Transform documents into podcast',
            style: AppTheme.titleLarge.copyWith(
              color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 24),

          // Upload Area
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(
                color: isDarkMode ? AppTheme.surfaceVariantDark : AppTheme.border,
                style: BorderStyle.solid,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
              color: isDarkMode ? AppTheme.surfaceVariantDark.withOpacity(0.3) : AppTheme.surfaceVariant,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.upload_file_outlined,
                  size: 48,
                  color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                ),
                const SizedBox(height: 8),
                Text(
                  'Drop your document here or click to browse',
                  style: AppTheme.bodyMedium.copyWith(
                    color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Supports PDF, DOC, DOCX, TXT (Max 50MB)',
                  style: AppTheme.bodySmall.copyWith(
                    color: isDarkMode ? AppTheme.textTertiaryDark : AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Coming Soon Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryBlue.withOpacity(0.1),
                  AppTheme.primaryLight.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.primaryBlue.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.rocket_launch,
                  size: 48,
                  color: AppTheme.primaryBlue,
                ),
                const SizedBox(height: 16),
                Text(
                  '🚀 Coming Soon!',
                  style: AppTheme.headingMedium.copyWith(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Document upload and processing feature is under development. Stay tuned for updates!',
                  textAlign: TextAlign.center,
                  style: AppTheme.bodyMedium.copyWith(
                    color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.primaryBlue.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    '💡 Use "From URL" or "From Prompt" for now',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPromptTab() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            '💭 Create podcast from your ideas',
            style: AppTheme.titleLarge.copyWith(
              color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 24),

          // Prompt Input - MOVED TO TOP
          Container(
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
                  'Podcast Topic',
                  style: AppTheme.titleMedium.copyWith(
                    color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _promptController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'e.g., "A 10-minute discussion about AI impact on education"',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // AI Provider Selection
          _buildPromptProviderSelection(isDarkMode),
          const SizedBox(height: 16),

          // Model Selection
          _buildPromptModelSelection(isDarkMode),
          const SizedBox(height: 16),

          // Podcast Category
          _buildPromptCategorySelection(isDarkMode),
          const SizedBox(height: 16),

          // Speaker Names
          _buildPromptSpeakerNames(isDarkMode),
          const SizedBox(height: 24),

          // Generate Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _isGenerateScriptLoading ? null : () async {
                await _generateScriptFromPrompt();
              },
              icon: _isGenerateScriptLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(Icons.auto_awesome, color: Colors.white),
              label: Text(_isGenerateScriptLoading ? 'Generating...' : 'Generate Script'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Error Display
          if (_promptError != null) ...[
            const SizedBox(height: 16),
            _buildPromptErrorDisplay(isDarkMode),
          ],

          const SizedBox(height: 24),
          Text(
            '💡 Describe your idea and AI will create the complete script with title',
            style: AppTheme.bodyMedium.copyWith(
              color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProviderDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool isUrlProvider = false,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Determine background color for URL providers
    Color? backgroundColor;
    if (isUrlProvider) {
      if (value == 'Firecrawl') {
        backgroundColor = Colors.orange.withOpacity(0.1);
      } else if (value == 'HyperbrowserAI') {
        backgroundColor = Colors.yellow.withOpacity(0.1);
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(
          color: isDarkMode ? AppTheme.surfaceVariantDark : AppTheme.border,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(12),
        color: backgroundColor ?? (isDarkMode ? AppTheme.surfaceDark : AppTheme.surface),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
          ),
          style: AppTheme.bodyMedium.copyWith(
            color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
          ),
          dropdownColor: isDarkMode ? AppTheme.surfaceDark : AppTheme.surface,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  item,
                  style: AppTheme.bodyMedium.copyWith(
                    color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Future<void> _performQuickFetch() async {
    final url = _urlController.text.trim();

    if (url.isEmpty) {
      _showError('Please enter a URL');
      return;
    }

    if (Uri.tryParse(url) == null) {
      _showError('Please enter a valid URL');
      return;
    }

    // Check if it's a PDF file
    if (url.toLowerCase().endsWith('.pdf')) {
      final shouldProceed = await _showPdfWarningDialog();
      if (!shouldProceed) return;
    }

    setState(() {
      _isQuickFetchLoading = true;
    });

    try {
      ScrapeResult result;

      if (_selectedUrlProvider == 'Firecrawl') {
        result = await _scrapingService.scrapeWithFirecrawl(url, onlyMainContent: true);
      } else {
        result = await _scrapingService.scrapeWithHyperbrowser(url, onlyMainContent: true);
      }

      if (mounted) {
        setState(() {
          _isQuickFetchLoading = false;
        });

        if (result.success) {
          // Save scraped content to storage
          final scrapedData = ScrapedUrlData.fromScrapeResult(result, _selectedUrlProvider);
          await _storageService.saveScrapedUrl(scrapedData);

          // Show preview screen
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ContentPreviewScreen(
                result: result,
                provider: _selectedUrlProvider,
              ),
            ),
          );
        } else {
          _showError(result.error ?? 'Failed to scrape content');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isQuickFetchLoading = false;
        });
        _showError(e.toString());
      }
    }
  }

  Future<bool> _showPdfWarningDialog() async {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              const SizedBox(width: 8),
              Text('PDF Scraping Warning'),
            ],
          ),
          content: Text(
            'Scraping PDF files may take longer or time out. The content may also be less structured compared to regular web pages.\n\nDo you want to continue?',
            style: AppTheme.bodyMedium.copyWith(
              color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
              ),
              child: Text('Continue Anyway'),
            ),
          ],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: isDarkMode ? AppTheme.surfaceDark : AppTheme.surface,
        );
      },
    ) ?? false;
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

  // Prompt tab helper methods
  Future<void> _loadPromptModels() async {
    if (!mounted) return;

    setState(() {
      _isLoadingPromptModels = true;
      _promptError = null;
    });

    try {
      final models = await _aiService.getModels(_selectedPromptProvider);
      if (!mounted) return;

      setState(() {
        _promptAvailableModels = models;
        _selectedPromptModel = models.isNotEmpty ? models.first.id : null;
        _isLoadingPromptModels = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _promptError = e.toString();
        _isLoadingPromptModels = false;
        _promptAvailableModels = [];
        _selectedPromptModel = null;
      });
    }
  }

  Widget _buildPromptProviderSelection(bool isDarkMode) {
    final providers = ['Gemini', 'Groq', 'OpenAI', 'OpenRouter'];

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
            'AI Provider',
            style: AppTheme.titleMedium.copyWith(
              color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedPromptProvider,
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
                  _selectedPromptProvider = value;
                  _selectedPromptModel = null;
                  _promptAvailableModels = [];
                });
                _loadPromptModels();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPromptModelSelection(bool isDarkMode) {
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
            'Model',
            style: AppTheme.titleMedium.copyWith(
              color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          if (_isLoadingPromptModels)
            const Center(child: CircularProgressIndicator())
          else if (_promptAvailableModels.isEmpty)
            Text(
              'No models available. Please check your API key.',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.secondaryRed,
              ),
            )
          else
            Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedPromptModel,
                  isExpanded: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: _promptAvailableModels.map((model) {
                    return DropdownMenuItem(
                      value: model.id,
                      child: SizedBox(
                        width: double.infinity,
                        child: Text(
                          model.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPromptModel = value;
                    });
                  },
                ),
                if (_selectedPromptModel != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Context Length:',
                        style: AppTheme.bodySmall.copyWith(
                          color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3)),
                        ),
                        child: Text(
                          '${_promptAvailableModels.firstWhere((m) => m.id == _selectedPromptModel).contextLength} tokens',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPromptCategorySelection(bool isDarkMode) {
    final categories = {
      'playful': 'Playful & Fun',
      'serious': 'Serious & Professional',
      'investigative': 'Investigative Mystery',
      'coffee_chat': 'Coffee Chat',
      'tech_talk': 'Tech Talk',
      'storytelling': 'Storytelling',
    };

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
            'Podcast Style',
            style: AppTheme.titleMedium.copyWith(
              color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedPromptCategory,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: categories.entries.map((entry) {
              return DropdownMenuItem(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedPromptCategory = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPromptSpeakerNames(bool isDarkMode) {
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
            'Speaker Names',
            style: AppTheme.titleMedium.copyWith(
              color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _promptSpeaker1Controller,
                  decoration: InputDecoration(
                    labelText: 'Speaker 1',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _promptSpeaker2Controller,
                  decoration: InputDecoration(
                    labelText: 'Speaker 2',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPromptErrorDisplay(bool isDarkMode) {
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
              _promptError!,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.secondaryRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generateScriptFromPrompt() async {
    print('🎬 [Prompt Script] Starting prompt-based script generation...');

    final prompt = _promptController.text.trim();

    if (prompt.isEmpty) {
      print('❌ [Prompt Script] No prompt entered');
      _showError('Please enter a podcast topic');
      return;
    }

    if (_selectedPromptModel == null) {
      print('❌ [Prompt Script] No model selected');
      _showError('Please select a model');
      return;
    }

    print('🎬 [Prompt Script] Prompt: "$prompt"');
    print('🎬 [Prompt Script] Provider: $_selectedPromptProvider');
    print('🎬 [Prompt Script] Model: $_selectedPromptModel');
    print('🎬 [Prompt Script] Category: $_selectedPromptCategory');

    setState(() {
      _isGenerateScriptLoading = true;
      _promptError = null;
    });

    try {
      final systemPrompt = _getUpdatedSystemPrompt(_selectedPromptCategory);
      final userPrompt = '''Create a podcast script about: $prompt

Speaker Names:
- Speaker 1: ${_promptSpeaker1Controller.text}
- Speaker 2: ${_promptSpeaker2Controller.text}

Please use these exact speaker names in the script.''';

      print('🎬 [Prompt Script] System prompt length: ${systemPrompt.length} characters');
      print('🎬 [Prompt Script] User prompt length: ${userPrompt.length} characters');

      final script = await _aiService.generateScript(
        provider: _selectedPromptProvider,
        model: _selectedPromptModel!,
        systemPrompt: systemPrompt,
        userPrompt: userPrompt,
        content: '', // No source content for prompt-based generation
      );

      print('🎬 [Prompt Script] Generated script length: ${script.length} characters');

      if (script.trim().isEmpty) {
        print('❌ [Prompt Script] Generated script is empty!');
        _showError('Generated script is empty. Please try again with a different model or check your API keys.');
        setState(() {
          _isGenerateScriptLoading = false;
        });
        return;
      }

      if (mounted) {
        setState(() {
          _isGenerateScriptLoading = false;
        });

        // Extract title from the generated script using AI service
        final extractedTitle = _aiService.extractTitleFromScript(script);
        final finalTitle = extractedTitle.isNotEmpty
            ? extractedTitle
            : 'From Prompt: ${prompt.length > 50 ? '${prompt.substring(0, 50)}...' : prompt}';

        print('🎬 [Prompt Script] Extracted title: "$extractedTitle"');
        print('🎬 [Prompt Script] Final title: "$finalTitle"');

        // Save the generated script
        final generatedScript = GeneratedScript(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          script: script,
          sourceTitle: finalTitle,
          sourceUrl: 'prompt://generated',
          category: _getCategoryName(_selectedPromptCategory),
          speaker1: _promptSpeaker1Controller.text,
          speaker2: _promptSpeaker2Controller.text,
          provider: _selectedPromptProvider,
          model: _selectedPromptModel!,
          generatedAt: DateTime.now(),
        );

        await _storageService.saveGeneratedScript(generatedScript);
        print('🎬 [Prompt Script] Script saved successfully');

        // Navigate to script preview screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ScriptPreviewScreen(
              script: script,
              sourceTitle: generatedScript.sourceTitle,
              sourceUrl: generatedScript.sourceUrl,
              category: generatedScript.category,
              speaker1: _promptSpeaker1Controller.text,
              speaker2: _promptSpeaker2Controller.text,
            ),
          ),
        );
        print('🎬 [Prompt Script] Navigated to script preview');
      }
    } catch (e) {
      print('❌ [Prompt Script] Error: $e');
      if (mounted) {
        setState(() {
          _isGenerateScriptLoading = false;
        });
        _showError(e.toString());
      }
    }
  }

  String _getCategoryName(String key) {
    final categories = {
      'playful': 'Playful & Fun',
      'serious': 'Serious & Professional',
      'investigative': 'Investigative Mystery',
      'coffee_chat': 'Coffee Chat',
      'tech_talk': 'Tech Talk',
      'storytelling': 'Storytelling',
    };
    return categories[key] ?? 'Playful & Fun';
  }



  String _getUpdatedSystemPrompt(String category) {
    final prompts = {
      'playful': '''You are creating a playful and entertaining podcast script. Your task is to create ONLY a podcast conversation script.

CRITICAL REQUIREMENTS:
1. Start with "Title: [Your catchy title here]" on the first line
2. Create ONLY dialogue between the two speakers - no explanations, descriptions, or meta-commentary
3. Use the exact speaker names provided in the user prompt
4. Generate 8-12 minutes of conversation content (approximately 1200-1800 words)

CONVERSATION STYLE:
- Light-hearted and fun with occasional humor and jokes
- Engaging and energetic with natural banter between speakers
- Educational but not overly serious
- Include relevant examples and analogies when appropriate
- Use casual, conversational language
- Add moments of surprise and delight
- Keep the audience entertained while informing them
- Natural flow with smooth transitions between topics

EMOTIONAL EXPRESSIONS (use sparingly and naturally):
- [laughs] - for genuine laughter
- [chuckles] - for light amusement
- [sighs] - for emphasis or transition
- [pauses] - for dramatic effect
- [excited] - for enthusiasm
- [thoughtful] - for reflection

STRICT FORMAT:
Title: [Your catchy title here]

Speaker 1: [dialogue content only]
Speaker 2: [dialogue content only]
Speaker 1: [dialogue content only]
Speaker 2: [dialogue content only]
...

WHAT TO INCLUDE:
- Natural conversation flow
- Relevant information and insights
- Personal anecdotes and examples
- Questions and responses between speakers
- Smooth topic transitions
- Engaging opening and satisfying conclusion

WHAT TO AVOID:
- No background music references
- No sound effect descriptions
- No production notes or instructions
- No narrator voice or third-person descriptions
- No explanatory text outside the dialogue
- No meta-commentary about the podcast itself

IMPORTANT: Return ONLY the title and dialogue script. Nothing else.''',

      'serious': '''You are creating a serious and professional podcast script. Your task is to create ONLY a podcast conversation script.

CRITICAL REQUIREMENTS:
1. Start with "Title: [Your professional title here]" on the first line
2. Create ONLY dialogue between the two speakers - no explanations, descriptions, or meta-commentary
3. Use the exact speaker names provided in the user prompt
4. Generate 8-12 minutes of conversation content (approximately 1200-1800 words)

CONVERSATION STYLE:
- Thoughtful and analytical with deep insights
- Well-researched and factual approach
- Professional tone while remaining accessible
- Include expert-level analysis and commentary
- Use precise, articulate language
- Focus on implications and broader context
- Maintain credibility and authority
- Provide actionable insights
- Structured discussion with logical flow

EMOTIONAL EXPRESSIONS (use sparingly and naturally):
- [pauses thoughtfully] - for reflection
- [sighs] - for emphasis
- [considers] - for deliberation
- [nods] - for agreement
- [serious tone] - for gravity

STRICT FORMAT:
Title: [Your professional title here]

Speaker 1: [dialogue content only]
Speaker 2: [dialogue content only]
Speaker 1: [dialogue content only]
Speaker 2: [dialogue content only]
...

WHAT TO INCLUDE:
- In-depth analysis and expert insights
- Factual information and data
- Professional perspectives and opinions
- Thoughtful questions and responses
- Implications and consequences
- Actionable recommendations
- Structured argument development

WHAT TO AVOID:
- No background music references
- No sound effect descriptions
- No production notes or instructions
- No narrator voice or third-person descriptions
- No explanatory text outside the dialogue
- No meta-commentary about the podcast itself

IMPORTANT: Return ONLY the title and dialogue script. Nothing else.''',

      'investigative': '''You are creating an investigative podcast script. Your task is to create ONLY a podcast conversation script.

CRITICAL REQUIREMENTS:
1. Start with "Title: [Your investigative title here]" on the first line
2. Create ONLY dialogue between the two speakers - no explanations, descriptions, or meta-commentary
3. Use the exact speaker names provided in the user prompt
4. Generate 8-12 minutes of conversation content (approximately 1200-1800 words)

CONVERSATION STYLE:
- Mysterious and intriguing with a sense of discovery
- Methodical investigation of facts and evidence
- Building suspense and curiosity
- Questioning assumptions and digging deeper
- Revealing information progressively
- Include "what if" scenarios and theories
- Maintain journalistic integrity
- Create compelling narrative tension
- Structured investigation with logical progression

EMOTIONAL EXPRESSIONS (use sparingly and naturally):
- [intrigued] - for curiosity
- [pauses] - for suspense
- [whispers] - for confidential information
- [surprised] - for revelations
- [concerned] - for serious implications

STRICT FORMAT:
Title: [Your investigative title here]

Speaker 1: [dialogue content only]
Speaker 2: [dialogue content only]
Speaker 1: [dialogue content only]
Speaker 2: [dialogue content only]
...

WHAT TO INCLUDE:
- Step-by-step investigation process
- Evidence presentation and analysis
- Multiple perspectives and theories
- Fact-checking and verification
- Timeline reconstruction
- Key questions and revelations
- Logical conclusions and implications

WHAT TO AVOID:
- No background music references
- No sound effect descriptions
- No production notes or instructions
- No narrator voice or third-person descriptions
- No explanatory text outside the dialogue
- No meta-commentary about the podcast itself

IMPORTANT: Return ONLY the title and dialogue script. Nothing else.''',

      'coffee_chat': '''You are creating a casual coffee chat podcast script. Your task is to create ONLY a podcast conversation script.

CRITICAL REQUIREMENTS:
1. Start with "Title: [Your warm, friendly title here]" on the first line
2. Create ONLY dialogue between the two speakers - no explanations, descriptions, or meta-commentary
3. Use the exact speaker names provided in the user prompt
4. Generate 8-12 minutes of conversation content (approximately 1200-1800 words)

CONVERSATION STYLE:
- Warm, intimate, and conversational
- Like two friends catching up over coffee
- Personal anecdotes and relatable experiences
- Comfortable pauses and natural flow
- Genuine reactions and emotions
- Supportive and encouraging tone
- Include personal insights and reflections
- Feel authentic and unscripted
- Relaxed and comfortable atmosphere

EMOTIONAL EXPRESSIONS (use sparingly and naturally):
- [smiles] - for warmth
- [laughs softly] - for gentle humor
- [sighs contentedly] - for satisfaction
- [pauses] - for natural flow
- [warmly] - for affection

STRICT FORMAT:
Title: [Your warm, friendly title here]

Speaker 1: [dialogue content only]
Speaker 2: [dialogue content only]
Speaker 1: [dialogue content only]
Speaker 2: [dialogue content only]
...

WHAT TO INCLUDE:
- Personal stories and experiences
- Relatable situations and emotions
- Supportive and encouraging exchanges
- Natural conversation flow
- Genuine reactions and responses
- Comfortable silences and pauses
- Friendly advice and insights

WHAT TO AVOID:
- No background music references
- No sound effect descriptions
- No production notes or instructions
- No narrator voice or third-person descriptions
- No explanatory text outside the dialogue
- No meta-commentary about the podcast itself

IMPORTANT: Return ONLY the title and dialogue script. Nothing else.''',

      'tech_talk': '''You are creating a technology-focused podcast script. Your task is to create ONLY a podcast conversation script.

CRITICAL REQUIREMENTS:
1. Start with "Title: [Your tech-focused title here]" on the first line
2. Create ONLY dialogue between the two speakers - no explanations, descriptions, or meta-commentary
3. Use the exact speaker names provided in the user prompt
4. Generate 8-12 minutes of conversation content (approximately 1200-1800 words)

CONVERSATION STYLE:
- Technical but accessible to general audience
- Excited about innovation and possibilities
- Include practical applications and implications
- Discuss both benefits and potential concerns
- Use analogies to explain complex concepts
- Forward-thinking and visionary
- Include real-world examples and use cases
- Balance technical depth with clarity
- Educational and informative

EMOTIONAL EXPRESSIONS (use sparingly and naturally):
- [excited] - for innovation
- [amazed] - for breakthroughs
- [thoughtful] - for implications
- [pauses] - for emphasis
- [enthusiastic] - for possibilities

STRICT FORMAT:
Title: [Your tech-focused title here]

Speaker 1: [dialogue content only]
Speaker 2: [dialogue content only]
Speaker 1: [dialogue content only]
Speaker 2: [dialogue content only]
...

WHAT TO INCLUDE:
- Technical concepts explained simply
- Real-world applications and examples
- Future implications and possibilities
- Benefits and potential risks
- Industry trends and developments
- Practical advice and insights
- Innovation and breakthrough discussions

WHAT TO AVOID:
- No background music references
- No sound effect descriptions
- No production notes or instructions
- No narrator voice or third-person descriptions
- No explanatory text outside the dialogue
- No meta-commentary about the podcast itself

IMPORTANT: Return ONLY the title and dialogue script. Nothing else.''',

      'storytelling': '''You are creating a storytelling podcast script. Your task is to create ONLY a podcast conversation script.

CRITICAL REQUIREMENTS:
1. Start with "Title: [Your storytelling title here]" on the first line
2. Create ONLY dialogue between the two speakers - no explanations, descriptions, or meta-commentary
3. Use the exact speaker names provided in the user prompt
4. Generate 8-12 minutes of conversation content (approximately 1200-1800 words)

CONVERSATION STYLE:
- Narrative-driven with compelling story arcs
- Rich descriptions and vivid imagery through dialogue
- Emotional engagement and character development
- Building tension and resolution
- Include dramatic pauses and pacing
- Paint pictures with words through conversation
- Create immersive experiences
- Use storytelling techniques like foreshadowing
- Engaging narrative structure

EMOTIONAL EXPRESSIONS (use sparingly and naturally):
- [dramatic pause] - for tension
- [whispers] - for intimacy
- [excited] - for climax
- [softly] - for emotion
- [builds tension] - for suspense

STRICT FORMAT:
Title: [Your storytelling title here]

Speaker 1: [dialogue content only]
Speaker 2: [dialogue content only]
Speaker 1: [dialogue content only]
Speaker 2: [dialogue content only]
...

WHAT TO INCLUDE:
- Compelling narrative structure
- Character development through dialogue
- Vivid descriptions within conversation
- Emotional moments and connections
- Plot development and story arcs
- Tension building and resolution
- Immersive storytelling elements

WHAT TO AVOID:
- No background music references
- No sound effect descriptions
- No production notes or instructions
- No narrator voice or third-person descriptions
- No explanatory text outside the dialogue
- No meta-commentary about the podcast itself

IMPORTANT: Return ONLY the title and dialogue script. Nothing else.''',
    };

    return prompts[category] ?? prompts['playful']!;
  }
}

class _LibraryTab extends StatefulWidget {
  const _LibraryTab();

  @override
  State<_LibraryTab> createState() => _LibraryTabState();
}

class _LibraryTabState extends State<_LibraryTab> with TickerProviderStateMixin {
  late TabController _tabController;
  final StorageService _storageService = StorageService();

  List<ScrapedUrlData> _scrapedUrls = [];
  List<GeneratedScript> _generatedScripts = [];
  List<GeneratedPodcast> _generatedPodcasts = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        // Rebuild when tab changes to update colors
      });
    });
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final urls = await _storageService.getScrapedUrls();
      final scripts = await _storageService.getGeneratedScripts();
      final podcasts = await _storageService.getGeneratedPodcasts();

      setState(() {
        _scrapedUrls = urls;
        _generatedScripts = scripts;
        _generatedPodcasts = podcasts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: const EchoGenAppBar(
        title: 'My Library',
        showLogo: false,
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryBlue.withOpacity(0.1),
                  AppTheme.primaryLight.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.primaryBlue.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: _tabController.index == 0
                          ? LinearGradient(
                              colors: [AppTheme.primaryBlue, AppTheme.primaryLight],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      boxShadow: _tabController.index == 0
                          ? [
                              BoxShadow(
                                color: AppTheme.primaryBlue.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      'URLs',
                      style: TextStyle(
                        color: _tabController.index == 0
                            ? Colors.white
                            : (isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary),
                        fontWeight: _tabController.index == 0 ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                Tab(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: _tabController.index == 1
                          ? LinearGradient(
                              colors: [AppTheme.primaryBlue, AppTheme.primaryLight],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      boxShadow: _tabController.index == 1
                          ? [
                              BoxShadow(
                                color: AppTheme.primaryBlue.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      'Audios',
                      style: TextStyle(
                        color: _tabController.index == 1
                            ? Colors.white
                            : (isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary),
                        fontWeight: _tabController.index == 1 ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                Tab(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: _tabController.index == 2
                          ? LinearGradient(
                              colors: [AppTheme.primaryBlue, AppTheme.primaryLight],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      boxShadow: _tabController.index == 2
                          ? [
                              BoxShadow(
                                color: AppTheme.primaryBlue.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      'Scripts',
                      style: TextStyle(
                        color: _tabController.index == 2
                            ? Colors.white
                            : (isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary),
                        fontWeight: _tabController.index == 2 ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ],
              labelColor: Colors.transparent,
              unselectedLabelColor: Colors.transparent,
              indicatorColor: Colors.transparent,
              dividerColor: Colors.transparent,
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUrlsTab(isDarkMode),
                _buildAudiosTab(isDarkMode),
                _buildScriptsTab(isDarkMode),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrlsTab(bool isDarkMode) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_scrapedUrls.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.link,
              size: 80,
              color: AppTheme.primaryBlue,
            ),
            const SizedBox(height: 24),
            Text(
              'No URLs Scraped Yet',
              style: AppTheme.headingLarge.copyWith(
                color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Scraped URLs will appear here',
              style: AppTheme.bodyLarge.copyWith(
                color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _scrapedUrls.length,
        itemBuilder: (context, index) {
          final urlData = _scrapedUrls[index];
          return _buildUrlCard(urlData, isDarkMode);
        },
      ),
    );
  }

  Widget _buildUrlCard(ScrapedUrlData urlData, bool isDarkMode) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _openUrlPreview(urlData),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: urlData.provider == 'Firecrawl'
                          ? Colors.orange.withOpacity(0.1)
                          : Colors.yellow.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: urlData.provider == 'Firecrawl'
                            ? Colors.orange.withOpacity(0.3)
                            : Colors.yellow.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      urlData.provider,
                      style: AppTheme.bodySmall.copyWith(
                        color: urlData.provider == 'Firecrawl'
                            ? Colors.orange.shade700
                            : Colors.yellow.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(urlData.scrapedAt),
                    style: AppTheme.bodySmall.copyWith(
                      color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        _deleteScrapedUrl(urlData);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                    child: Icon(
                      Icons.more_vert,
                      color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                urlData.title,
                style: AppTheme.titleMedium.copyWith(
                  color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                urlData.url,
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.primaryBlue,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                '${urlData.content.length} characters extracted',
                style: AppTheme.bodySmall.copyWith(
                  color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openUrlPreview(ScrapedUrlData urlData) {
    // Convert ScrapedUrlData back to ScrapeResult for preview
    final result = ScrapeResult(
      success: true,
      url: urlData.url,
      title: urlData.title,
      markdown: urlData.content,
      metadata: urlData.metadata,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ContentPreviewScreen(
          result: result,
          provider: urlData.provider,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildAudiosTab(bool isDarkMode) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_generatedPodcasts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryBlue.withOpacity(0.1),
                border: Border.all(
                  color: AppTheme.primaryBlue.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.podcasts,
                size: 60,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Podcasts Generated Yet',
              style: AppTheme.headingLarge.copyWith(
                color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Generated podcasts will appear here',
              style: AppTheme.bodyLarge.copyWith(
                color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed('/create');
              },
              icon: Icon(Icons.add, color: Colors.white),
              label: Text('Create Your First Podcast'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _generatedPodcasts.length,
        itemBuilder: (context, index) {
          final podcast = _generatedPodcasts[index];
          return _buildPodcastCard(podcast, isDarkMode);
        },
      ),
    );
  }

  Widget _buildPodcastCard(GeneratedPodcast podcast, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.surfaceDark : AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? AppTheme.surfaceVariantDark : AppTheme.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDarkMode ? Colors.black : Colors.grey).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Cover Art
            Container(
              width: 60,
              height: 60,
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
                child: Image.asset(
                  'lib/assets/logo.png',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.podcasts,
                      color: Colors.white,
                      size: 30,
                    );
                  },
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    podcast.title,
                    style: AppTheme.titleMedium.copyWith(
                      color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Subtitle with speakers
                  Text(
                    '${podcast.metadata['speaker1']} & ${podcast.metadata['speaker2']}',
                    style: AppTheme.bodyMedium.copyWith(
                      color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryBlue.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      podcast.metadata['category']?.toString().toUpperCase() ?? 'ACAPELLA',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Actions
            Column(
              children: [
                // Play button
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () async {
                      try {
                        await GlobalAudioManager.instance.playPodcast(podcast);
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to play podcast: $e'),
                              backgroundColor: AppTheme.secondaryRed,
                            ),
                          );
                        }
                      }
                    },
                    icon: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Download button
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryGreen,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.secondaryGreen.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () {
                      // Download podcast
                      Share.shareXFiles([XFile(podcast.audioPath)], text: 'Check out this podcast: ${podcast.title}');
                    },
                    icon: Icon(
                      Icons.download,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 8),

            // 3-dot menu
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  _deletePodcast(podcast);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
              child: Icon(
                Icons.more_vert,
                color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScriptsTab(bool isDarkMode) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_generatedScripts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description,
              size: 80,
              color: AppTheme.primaryBlue,
            ),
            const SizedBox(height: 24),
            Text(
              'No Scripts Generated Yet',
              style: AppTheme.headingLarge.copyWith(
                color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Generated scripts will appear here',
              style: AppTheme.bodyLarge.copyWith(
                color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _generatedScripts.length,
        itemBuilder: (context, index) {
          final script = _generatedScripts[index];
          return _buildScriptCard(script, isDarkMode);
        },
      ),
    );
  }

  Widget _buildScriptCard(GeneratedScript script, bool isDarkMode) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _openScriptPreview(script),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3)),
                    ),
                    child: Text(
                      script.category,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(script.generatedAt),
                    style: AppTheme.bodySmall.copyWith(
                      color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        _deleteGeneratedScript(script);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                    child: Icon(
                      Icons.more_vert,
                      color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                script.sourceTitle,
                style: AppTheme.titleMedium.copyWith(
                  color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people, size: 16, color: AppTheme.primaryBlue),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '${script.speaker1} & ${script.speaker2}',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.smart_toy, size: 16, color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '${script.provider} ${script.model.length > 20 ? '${script.model.substring(0, 20)}...' : script.model}',
                          style: AppTheme.bodySmall.copyWith(
                            color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${script.script.length} characters',
                style: AppTheme.bodySmall.copyWith(
                  color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openScriptPreview(GeneratedScript script) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ScriptPreviewScreen(
          script: script.script,
          sourceTitle: script.sourceTitle,
          sourceUrl: script.sourceUrl,
          category: script.category,
          speaker1: script.speaker1,
          speaker2: script.speaker2,
        ),
      ),
    );
  }

  Future<void> _deletePodcast(GeneratedPodcast podcast) async {
    try {
      await _storageService.deleteGeneratedPodcast(podcast.id);
      await _loadData(); // Refresh the data

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text('Podcast deleted successfully'),
              ],
            ),
            backgroundColor: AppTheme.secondaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text('Failed to delete podcast'),
              ],
            ),
            backgroundColor: AppTheme.secondaryRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  Future<void> _deleteScrapedUrl(ScrapedUrlData urlData) async {
    try {
      await _storageService.deleteScrapedUrl(urlData.id);
      await _loadData(); // Refresh the data

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text('URL deleted successfully'),
              ],
            ),
            backgroundColor: AppTheme.secondaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text('Failed to delete URL'),
              ],
            ),
            backgroundColor: AppTheme.secondaryRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  Future<void> _deleteGeneratedScript(GeneratedScript script) async {
    try {
      await _storageService.deleteGeneratedScript(script.id);
      await _loadData(); // Refresh the data

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text('Script deleted successfully'),
              ],
            ),
            backgroundColor: AppTheme.secondaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text('Failed to delete script'),
              ],
            ),
            backgroundColor: AppTheme.secondaryRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  Widget _buildMetadataChip({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDarkMode,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

}

class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: const EchoGenAppBar(
        title: 'Settings',
        showLogo: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Preferences Section
            _buildSectionHeader(context, 'App Preferences'),
            const SizedBox(height: 12),
            _buildSettingsCard(
              context,
              [
                _buildSettingsTile(
                  context,
                  icon: Icons.key_outlined,
                  title: 'API Keys',
                  subtitle: 'Configure your AI service API keys',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ApiKeysScreen(),
                      ),
                    );
                  },
                ),
                _buildDivider(context),
                _buildSettingsTile(
                  context,
                  icon: Icons.folder_outlined,
                  title: 'Download Folder',
                  subtitle: 'Configure where podcasts are saved',
                  onTap: () {
                    _showDownloadFolderDialog(context);
                  },
                ),
                _buildDivider(context),
                _buildSettingsTile(
                  context,
                  icon: Icons.notifications_outlined,
                  title: 'Push Notifications',
                  subtitle: 'Manage notification preferences',
                  onTap: () {
                    // TODO: Navigate to notifications settings
                  },
                ),
                _buildDivider(context),
                _buildThemeTile(context, themeProvider, isDarkMode),
              ],
            ),

            const SizedBox(height: 24),

            // Support Section
            _buildSectionHeader(context, 'Support & Community'),
            const SizedBox(height: 12),
            _buildSettingsCard(
              context,
              [
                _buildSettingsTile(
                  context,
                  icon: Icons.group_outlined,
                  title: 'Join the Beta Group',
                  subtitle: 'Get early access to new features',
                  onTap: () {
                    // TODO: Navigate to beta group
                  },
                  showExternalIcon: true,
                ),
                _buildDivider(context),
                _buildSettingsTile(
                  context,
                  icon: Icons.help_outline,
                  title: 'Get Help',
                  subtitle: 'FAQ, tutorials, and support',
                  onTap: () {
                    // TODO: Navigate to help
                  },
                ),
                _buildDivider(context),
                _buildSettingsTile(
                  context,
                  icon: Icons.info_outline,
                  title: 'About',
                  subtitle: 'App version and information',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AboutScreen(),
                      ),
                    );
                  },
                ),
                _buildDivider(context),
                _buildSettingsTile(
                  context,
                  icon: Icons.download_outlined,
                  title: 'Download More Apps',
                  subtitle: 'Discover our other applications',
                  onTap: () {
                    // TODO: Navigate to more apps
                  },
                  showExternalIcon: true,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Account Section
            _buildSectionHeader(context, 'Account'),
            const SizedBox(height: 12),
            _buildSettingsCard(
              context,
              [
                _buildSettingsTile(
                  context,
                  icon: Icons.logout_outlined,
                  title: 'Log Out',
                  subtitle: 'Sign out of your account',
                  onTap: () {
                    _showLogoutDialog(context);
                  },
                  isDestructive: true,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Version Info
            Center(
              child: Column(
                children: [
                  Text(
                    'Version 2.1.0+RELEASE.1151',
                    style: AppTheme.bodySmall.copyWith(
                      color: isDarkMode ? AppTheme.textTertiaryDark : AppTheme.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '© 2024 EchoGen.ai. All rights reserved.',
                    style: AppTheme.bodySmall.copyWith(
                      color: isDarkMode ? AppTheme.textTertiaryDark : AppTheme.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Made with ❤️ for the community',
                    style: AppTheme.bodySmall.copyWith(
                      color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: AppTheme.titleMedium.copyWith(
          color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, List<Widget> children) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.surfaceDark : AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? AppTheme.surfaceVariantDark : AppTheme.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDarkMode ? Colors.black : Colors.grey).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showExternalIcon = false,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDestructive
                      ? AppTheme.secondaryRed.withOpacity(0.1)
                      : AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isDestructive ? AppTheme.secondaryRed : AppTheme.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.titleMedium.copyWith(
                        color: isDestructive
                            ? AppTheme.secondaryRed
                            : (isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTheme.bodySmall.copyWith(
                        color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                showExternalIcon ? Icons.open_in_new : Icons.chevron_right,
                color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                size: showExternalIcon ? 18 : 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeTile(BuildContext context, ThemeProvider themeProvider, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: AppTheme.primaryBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Theme',
                  style: AppTheme.titleMedium.copyWith(
                    color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isDarkMode ? 'Dark Mode' : 'Light Mode',
                  style: AppTheme.bodySmall.copyWith(
                    color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isDarkMode,
            onChanged: (_) {
              themeProvider.toggleTheme();
            },
            activeColor: AppTheme.primaryBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Divider(
      height: 1,
      thickness: 1,
      color: isDarkMode ? AppTheme.surfaceVariantDark : AppTheme.borderLight,
      indent: 56,
    );
  }

  void _showDownloadFolderDialog(BuildContext context) async {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Get current download folder from preferences
    final prefs = await SharedPreferences.getInstance();
    final currentFolder = prefs.getString('download_folder') ?? 'Default (App Documents)';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: isDarkMode ? AppTheme.surfaceDark : AppTheme.surface,
        title: Text(
          'Download Folder',
          style: AppTheme.headingMedium.copyWith(
            color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose where your generated podcasts will be saved:',
              style: AppTheme.bodyMedium.copyWith(
                color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDarkMode ? AppTheme.backgroundDark : AppTheme.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDarkMode ? AppTheme.surfaceVariantDark : AppTheme.borderLight,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.folder,
                    color: AppTheme.primaryBlue,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      currentFolder,
                      style: AppTheme.bodyMedium.copyWith(
                        color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: AppTheme.bodyMedium.copyWith(
                color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _selectDownloadFolder(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
            ),
            child: const Text(
              'Change Folder',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDownloadFolder(BuildContext context) async {
    try {
      final theme = Theme.of(context);
      final isDarkMode = theme.brightness == Brightness.dark;

      final result = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: isDarkMode ? AppTheme.surfaceDark : AppTheme.surface,
          title: Text(
            'Select Download Location',
            style: AppTheme.headingMedium.copyWith(
              color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.phone_android, color: AppTheme.primaryBlue),
                title: Text(
                  'App Documents',
                  style: AppTheme.bodyMedium.copyWith(
                    color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                  ),
                ),
                subtitle: Text(
                  'Default app storage',
                  style: AppTheme.bodySmall.copyWith(
                    color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                  ),
                ),
                onTap: () => Navigator.of(context).pop('app_documents'),
              ),
              ListTile(
                leading: Icon(Icons.download, color: AppTheme.secondaryGreen),
                title: Text(
                  'Downloads Folder',
                  style: AppTheme.bodyMedium.copyWith(
                    color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                  ),
                ),
                subtitle: Text(
                  'Device downloads folder',
                  style: AppTheme.bodySmall.copyWith(
                    color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                  ),
                ),
                onTap: () => Navigator.of(context).pop('downloads'),
              ),
              ListTile(
                leading: Icon(Icons.folder_special, color: AppTheme.secondaryOrange),
                title: Text(
                  'Music Folder',
                  style: AppTheme.bodyMedium.copyWith(
                    color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                  ),
                ),
                subtitle: Text(
                  'Device music/audio folder',
                  style: AppTheme.bodySmall.copyWith(
                    color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                  ),
                ),
                onTap: () => Navigator.of(context).pop('music'),
              ),
              ListTile(
                leading: Icon(Icons.sd_card, color: AppTheme.onboardingYellow),
                title: Text(
                  'External Storage',
                  style: AppTheme.bodyMedium.copyWith(
                    color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                  ),
                ),
                subtitle: Text(
                  'SD card or external storage',
                  style: AppTheme.bodySmall.copyWith(
                    color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                  ),
                ),
                onTap: () => Navigator.of(context).pop('external'),
              ),
            ],
          ),
        ),
      );

      if (result != null) {
        final prefs = await SharedPreferences.getInstance();
        String folderName;
        switch (result) {
          case 'downloads':
            folderName = 'Downloads Folder';
            break;
          case 'external':
            folderName = 'External Storage';
            break;
          case 'music':
            folderName = 'Music Folder';
            break;
          default:
            folderName = 'Default (App Documents)';
        }

        await prefs.setString('download_folder', folderName);
        await prefs.setString('download_folder_type', result);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Download folder set to: $folderName'),
              backgroundColor: AppTheme.secondaryGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting folder: $e'),
            backgroundColor: AppTheme.secondaryRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }



  void _showLogoutDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: isDarkMode ? AppTheme.surfaceDark : AppTheme.surface,
          title: Text(
            'Log Out',
            style: AppTheme.headingMedium.copyWith(
              color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
            ),
          ),
          content: Text(
            'Are you sure you want to log out of your account?',
            style: AppTheme.bodyMedium.copyWith(
              color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: AppTheme.bodyMedium.copyWith(
                  color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Implement logout functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logout functionality not implemented yet'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryRed,
              ),
              child: const Text(
                'Log Out',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}