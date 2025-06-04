import 'package:flutter/material.dart';
import 'package:echogenai/constants/app_theme.dart';
import 'package:echogenai/widgets/app_bar_widget.dart';
import 'package:echogenai/services/web_scraping_service.dart';

class UrlScrapingScreen extends StatefulWidget {
  const UrlScrapingScreen({super.key});

  @override
  State<UrlScrapingScreen> createState() => _UrlScrapingScreenState();
}

class _UrlScrapingScreenState extends State<UrlScrapingScreen> {
  final WebScrapingService _scrapingService = WebScrapingService();
  final List<TextEditingController> _urlControllers = [TextEditingController()];
  final List<FocusNode> _urlFocusNodes = [FocusNode()];
  
  String _selectedService = 'firecrawl';
  String _scrapingMode = 'single'; // 'single', 'multiple', 'batch'
  bool _onlyMainContent = true;
  bool _isLoading = false;
  
  List<ScrapeResult> _results = [];
  BatchScrapeJob? _currentBatchJob;
  String? _error;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    for (final controller in _urlControllers) {
      controller.dispose();
    }
    for (final focusNode in _urlFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _addUrlField() {
    setState(() {
      _urlControllers.add(TextEditingController());
      _urlFocusNodes.add(FocusNode());
    });
  }

  void _removeUrlField(int index) {
    if (_urlControllers.length > 1) {
      setState(() {
        _urlControllers[index].dispose();
        _urlFocusNodes[index].dispose();
        _urlControllers.removeAt(index);
        _urlFocusNodes.removeAt(index);
      });
    }
  }

  List<String> _getValidUrls() {
    return _urlControllers
        .map((controller) => controller.text.trim())
        .where((url) => url.isNotEmpty && Uri.tryParse(url) != null)
        .toList();
  }

  Future<void> _startScraping() async {
    final urls = _getValidUrls();
    if (urls.isEmpty) {
      _showError('Please enter at least one valid URL');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _results.clear();
      _progress = 0.0;
    });

    try {
      if (_scrapingMode == 'single' || (_scrapingMode == 'multiple' && urls.length == 1)) {
        // Single URL scraping
        final result = _selectedService == 'firecrawl'
            ? await _scrapingService.scrapeWithFirecrawl(urls.first, onlyMainContent: _onlyMainContent)
            : await _scrapingService.scrapeWithHyperbrowser(urls.first, onlyMainContent: _onlyMainContent);
        
        setState(() {
          _results = [result];
          _progress = 1.0;
        });
      } else if (_scrapingMode == 'multiple') {
        // Multiple URLs one by one
        final results = await _scrapingService.scrapeMultipleUrls(
          urls,
          _selectedService,
          onlyMainContent: _onlyMainContent,
          onProgress: (current, total) {
            setState(() {
              _progress = current / total;
            });
          },
        );
        
        setState(() {
          _results = results;
        });
      } else if (_scrapingMode == 'batch') {
        // Batch scraping
        final job = _selectedService == 'firecrawl'
            ? await _scrapingService.batchScrapeWithFirecrawl(urls, onlyMainContent: _onlyMainContent)
            : await _scrapingService.batchScrapeWithHyperbrowser(urls, onlyMainContent: _onlyMainContent);
        
        setState(() {
          _currentBatchJob = job;
        });
        
        // Poll for batch completion
        await _pollBatchJob(job);
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pollBatchJob(BatchScrapeJob job) async {
    const maxAttempts = 60; // 10 minutes with 10-second intervals
    int attempts = 0;

    while (attempts < maxAttempts && _isLoading) {
      await Future.delayed(const Duration(seconds: 10));
      attempts++;

      try {
        final result = await _scrapingService.checkBatchScrapeStatus(job);
        
        setState(() {
          if (result.total != null && result.completed != null) {
            _progress = result.completed! / result.total!;
          }
        });

        if (result.status == 'completed') {
          setState(() {
            _results = result.results;
            _progress = 1.0;
          });
          break;
        } else if (result.status == 'failed') {
          _showError('Batch scraping failed: ${result.error ?? 'Unknown error'}');
          break;
        }
      } catch (e) {
        if (attempts >= maxAttempts) {
          _showError('Timeout: Batch scraping took longer than expected');
          break;
        }
      }
    }
  }

  void _showError(String message) {
    setState(() {
      _error = message;
    });
    
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

    return Scaffold(
      appBar: const EchoGenAppBar(
        title: 'URL Scraping',
        showLogo: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Selection
            _buildServiceSelector(isDarkMode),
            const SizedBox(height: 24),
            
            // Scraping Mode Selection
            _buildScrapingModeSelector(isDarkMode),
            const SizedBox(height: 24),
            
            // URL Input Section
            _buildUrlInputSection(isDarkMode),
            const SizedBox(height: 24),
            
            // Options
            _buildOptionsSection(isDarkMode),
            const SizedBox(height: 24),
            
            // Action Button
            _buildActionButton(isDarkMode),
            const SizedBox(height: 24),
            
            // Progress Indicator
            if (_isLoading) _buildProgressSection(isDarkMode),
            
            // Error Display
            if (_error != null) _buildErrorSection(isDarkMode),
            
            // Results Section
            if (_results.isNotEmpty) _buildResultsSection(isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceSelector(bool isDarkMode) {
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
            'Scraping Service',
            style: AppTheme.titleMedium.copyWith(
              color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildServiceOption('firecrawl', 'Firecrawl', Icons.local_fire_department, Colors.orange),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildServiceOption('hyperbrowser', 'Hyperbrowser', Icons.travel_explore, Colors.yellow.shade700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceOption(String value, String label, IconData icon, Color color) {
    final isSelected = _selectedService == value;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedService = value),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrapingModeSelector(bool isDarkMode) {
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
            'Scraping Mode',
            style: AppTheme.titleMedium.copyWith(
              color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              _buildModeOption('single', 'Single URL', 'Scrape one URL at a time', Icons.link),
              _buildModeOption('multiple', 'Multiple URLs', 'Process URLs one by one (free)', Icons.list),
              _buildModeOption('batch', 'Batch Scrape', 'Process all URLs simultaneously (premium)', Icons.batch_prediction),
            ],
          ),
          if (_scrapingMode == 'batch')
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppTheme.onboardingYellow.withOpacity(0.2)
                    : AppTheme.onboardingYellow.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDarkMode
                      ? AppTheme.onboardingYellow.withOpacity(0.5)
                      : AppTheme.onboardingYellow.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: AppTheme.onboardingYellow, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Batch scraping requires a premium API plan',
                      style: AppTheme.bodyMedium.copyWith(
                        color: isDarkMode
                            ? AppTheme.onboardingYellow
                            : const Color(0xFF8B6914), // Darker yellow for light mode
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

  Widget _buildModeOption(String value, String title, String description, IconData icon) {
    final isSelected = _scrapingMode == value;
    
    return GestureDetector(
      onTap: () => setState(() => _scrapingMode = value),
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
              icon,
              color: isSelected ? AppTheme.primaryBlue : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? AppTheme.primaryBlue : Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey,
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

  Widget _buildUrlInputSection(bool isDarkMode) {
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
          Row(
            children: [
              Expanded(
                child: Text(
                  'URLs to Scrape',
                  style: AppTheme.titleMedium.copyWith(
                    color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (_scrapingMode != 'single')
                IconButton(
                  onPressed: _addUrlField,
                  icon: Icon(Icons.add_circle, color: AppTheme.primaryBlue),
                  tooltip: 'Add URL',
                ),
            ],
          ),
          const SizedBox(height: 12),
          ..._buildUrlFields(isDarkMode),
        ],
      ),
    );
  }

  List<Widget> _buildUrlFields(bool isDarkMode) {
    final maxFields = _scrapingMode == 'single' ? 1 : _urlControllers.length;
    
    return List.generate(maxFields, (index) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _urlControllers[index],
                focusNode: _urlFocusNodes[index],
                decoration: InputDecoration(
                  hintText: 'https://example.com',
                  prefixIcon: Icon(Icons.link, color: AppTheme.primaryBlue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.url,
              ),
            ),
            if (_scrapingMode != 'single' && _urlControllers.length > 1)
              IconButton(
                onPressed: () => _removeUrlField(index),
                icon: Icon(Icons.remove_circle, color: AppTheme.secondaryRed),
                tooltip: 'Remove URL',
              ),
          ],
        ),
      );
    });
  }

  Widget _buildOptionsSection(bool isDarkMode) {
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
            'Scraping Options',
            style: AppTheme.titleMedium.copyWith(
              color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SwitchListTile(
                  title: Text(
                    'Extract Main Content Only',
                    style: AppTheme.bodyMedium.copyWith(
                      color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                    ),
                  ),
                  // subtitle: Text(
                  //   'Focus on the main article content, excluding navigation and ads',
                  //   style: AppTheme.bodyMedium.copyWith(
                  //     color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                  //   ),
                  // ),
                  value: _onlyMainContent,
                  onChanged: (value) => setState(() => _onlyMainContent = value),
                  activeColor: AppTheme.primaryBlue,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              IconButton(
                onPressed: () => _showMainContentInfo(context, isDarkMode),
                icon: Icon(
                  Icons.info_outline,
                  color: AppTheme.primaryBlue,
                  size: 20,
                ),
                tooltip: 'More information',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(bool isDarkMode) {
    final urls = _getValidUrls();
    final isDisabled = urls.isEmpty || _isLoading;
    
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: isDisabled ? null : _startScraping,
        icon: _isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(Icons.play_arrow, color: Colors.white),
        label: Text(_isLoading ? 'Scraping...' : 'Start Scraping'),
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

  Widget _buildProgressSection(bool isDarkMode) {
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
        children: [
          Row(
            children: [
              Icon(Icons.hourglass_empty, color: AppTheme.primaryBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                'Scraping in progress...',
                style: AppTheme.titleMedium.copyWith(
                  color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: _progress,
            backgroundColor: Colors.grey.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
          ),
          const SizedBox(height: 8),
          Text(
            '${(_progress * 100).toInt()}% complete',
            style: AppTheme.bodyMedium.copyWith(
              color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorSection(bool isDarkMode) {
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

  Widget _buildResultsSection(bool isDarkMode) {
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
          Row(
            children: [
              Icon(Icons.check_circle, color: AppTheme.secondaryGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                'Scraping Results (${_results.length})',
                style: AppTheme.titleMedium.copyWith(
                  color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...(_results.map((result) => _buildResultCard(result, isDarkMode))),
        ],
      ),
    );
  }

  Widget _buildResultCard(ScrapeResult result, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: result.success 
            ? AppTheme.secondaryGreen.withOpacity(0.1)
            : AppTheme.secondaryRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: result.success 
              ? AppTheme.secondaryGreen.withOpacity(0.3)
              : AppTheme.secondaryRed.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                result.success ? Icons.check_circle : Icons.error,
                color: result.success ? AppTheme.secondaryGreen : AppTheme.secondaryRed,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  result.title,
                  style: AppTheme.titleSmall.copyWith(
                    color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            result.url,
            style: AppTheme.bodySmall.copyWith(
              color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (!result.success && result.error != null) ...[
            const SizedBox(height: 8),
            Text(
              'Error: ${result.error}',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.secondaryRed,
              ),
            ),
          ],
          if (result.success && result.markdown.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '${result.markdown.length} characters extracted',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.secondaryGreen,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showMainContentInfo(BuildContext context, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: isDarkMode ? AppTheme.surfaceDark : AppTheme.surface,
          title: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppTheme.primaryBlue,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Main Content Extraction',
                style: AppTheme.headingMedium.copyWith(
                  color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'When enabled, this feature:',
                style: AppTheme.bodyMedium.copyWith(
                  color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _buildInfoPoint('✓ Extracts only the main article content', isDarkMode),
              _buildInfoPoint('✓ Removes navigation menus and sidebars', isDarkMode),
              _buildInfoPoint('✓ Filters out advertisements', isDarkMode),
              _buildInfoPoint('✓ Excludes comments and social media widgets', isDarkMode),
              _buildInfoPoint('✓ Provides cleaner, more focused content', isDarkMode),
              const SizedBox(height: 12),
              Text(
                'When disabled:',
                style: AppTheme.bodyMedium.copyWith(
                  color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _buildInfoPoint('• Extracts the entire page content', isDarkMode),
              _buildInfoPoint('• Includes all page elements', isDarkMode),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Got it',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoPoint(String text, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: AppTheme.bodyMedium.copyWith(
          color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
          height: 1.4,
        ),
      ),
    );
  }
}
