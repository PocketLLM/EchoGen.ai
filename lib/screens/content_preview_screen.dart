import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:echogenai/constants/app_theme.dart';
import 'package:echogenai/widgets/app_bar_widget.dart';
import 'package:echogenai/services/web_scraping_service.dart';
import 'package:echogenai/screens/script_generation_screen.dart';

class ContentPreviewScreen extends StatefulWidget {
  final ScrapeResult result;
  final String provider;

  const ContentPreviewScreen({
    super.key,
    required this.result,
    required this.provider,
  });

  @override
  State<ContentPreviewScreen> createState() => _ContentPreviewScreenState();
}

class _ContentPreviewScreenState extends State<ContentPreviewScreen> {
  bool _showMarkdown = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: EchoGenAppBar(
        title: 'Content Preview',
        showLogo: false,
        actions: [
          IconButton(
            onPressed: () => _copyToClipboard(),
            icon: Icon(
              Icons.copy,
              color: isDarkMode ? Colors.white : AppTheme.textPrimary,
            ),
            tooltip: 'Copy content',
          ),
          IconButton(
            onPressed: () => _shareContent(),
            icon: Icon(
              Icons.share,
              color: isDarkMode ? Colors.white : AppTheme.textPrimary,
            ),
            tooltip: 'Share content',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with URL and metadata
          _buildHeader(isDarkMode),
          
          // Toggle between markdown and metadata
          _buildToggleBar(isDarkMode),
          
          // Content area
          Expanded(
            child: _showMarkdown ? _buildMarkdownView(isDarkMode) : _buildMetadataView(isDarkMode),
          ),
          
          // Action buttons
          _buildActionButtons(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.surfaceDark : AppTheme.surface,
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? AppTheme.surfaceVariantDark : AppTheme.borderLight,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.provider == 'Firecrawl' 
                      ? Colors.orange.withOpacity(0.1)
                      : Colors.yellow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.provider == 'Firecrawl' 
                        ? Colors.orange.withOpacity(0.3)
                        : Colors.yellow.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  widget.provider,
                  style: AppTheme.bodySmall.copyWith(
                    color: widget.provider == 'Firecrawl' 
                        ? Colors.orange.shade700
                        : Colors.yellow.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.check_circle,
                color: AppTheme.secondaryGreen,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                'Success',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.secondaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.result.title,
            style: AppTheme.titleLarge.copyWith(
              color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            widget.result.url,
            style: AppTheme.bodyMedium.copyWith(
              color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.result.markdown.length} characters extracted',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.primaryBlue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleBar(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.surfaceVariantDark : AppTheme.surfaceVariant,
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _showMarkdown = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _showMarkdown 
                      ? AppTheme.primaryBlue 
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Content',
                  textAlign: TextAlign.center,
                  style: AppTheme.bodyMedium.copyWith(
                    color: _showMarkdown 
                        ? Colors.white 
                        : (isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary),
                    fontWeight: _showMarkdown ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _showMarkdown = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_showMarkdown 
                      ? AppTheme.primaryBlue 
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Metadata',
                  textAlign: TextAlign.center,
                  style: AppTheme.bodyMedium.copyWith(
                    color: !_showMarkdown 
                        ? Colors.white 
                        : (isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary),
                    fontWeight: !_showMarkdown ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarkdownView(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Container(
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
            widget.result.markdown.isNotEmpty 
                ? widget.result.markdown 
                : 'No content extracted',
            style: AppTheme.bodyMedium.copyWith(
              color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
              fontFamily: 'monospace',
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetadataView(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Container(
          width: double.infinity,
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
                'Metadata',
                style: AppTheme.titleMedium.copyWith(
                  color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              ...widget.result.metadata.entries.map((entry) => 
                _buildMetadataItem(entry.key, entry.value.toString(), isDarkMode)
              ),
              if (widget.result.metadata.isEmpty)
                Text(
                  'No metadata available',
                  style: AppTheme.bodyMedium.copyWith(
                    color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetadataItem(String key, String value, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            key,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.primaryBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(
            value,
            style: AppTheme.bodyMedium.copyWith(
              color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.surfaceDark : AppTheme.surface,
        border: Border(
          top: BorderSide(
            color: isDarkMode ? AppTheme.surfaceVariantDark : AppTheme.borderLight,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(Icons.arrow_back, color: AppTheme.primaryBlue),
              label: Text(
                'Back',
                style: TextStyle(color: AppTheme.primaryBlue),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppTheme.primaryBlue),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _generateScript(),
              icon: Icon(Icons.description, color: Colors.white),
              label: Text(
                'Generate Script',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard() {
    final content = _showMarkdown ? widget.result.markdown : widget.result.metadata.toString();
    Clipboard.setData(ClipboardData(text: content));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text('Content copied to clipboard'),
          ],
        ),
        backgroundColor: AppTheme.secondaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _shareContent() {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share functionality coming soon!'),
        backgroundColor: AppTheme.primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _generateScript() {
    // Navigate to script generation screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ScriptGenerationScreen(
          content: widget.result.markdown,
          sourceUrl: widget.result.url,
          sourceTitle: widget.result.title,
        ),
      ),
    );
  }
}
