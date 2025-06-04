import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:echogenai/constants/app_theme.dart';
import 'package:echogenai/widgets/app_bar_widget.dart';
import 'package:echogenai/screens/podcast_generation_screen.dart';
import 'package:share_plus/share_plus.dart';

class ScriptPreviewScreen extends StatefulWidget {
  final String script;
  final String sourceTitle;
  final String sourceUrl;
  final String category;
  final String speaker1;
  final String speaker2;

  const ScriptPreviewScreen({
    super.key,
    required this.script,
    required this.sourceTitle,
    required this.sourceUrl,
    required this.category,
    required this.speaker1,
    required this.speaker2,
  });

  @override
  State<ScriptPreviewScreen> createState() => _ScriptPreviewScreenState();
}

class _ScriptPreviewScreenState extends State<ScriptPreviewScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _copyScript() async {
    await Clipboard.setData(ClipboardData(text: widget.script));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.copy, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text('Script copied to clipboard!'),
          ],
        ),
        backgroundColor: AppTheme.secondaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _shareScript() async {
    try {
      await Share.share(
        widget.script,
        subject: 'Podcast Script: ${widget.sourceTitle}',
      );
    } catch (e) {
      _showError('Failed to share script: $e');
    }
  }

  void _generatePodcast() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PodcastGenerationScreen(
          script: widget.script,
          sourceTitle: widget.sourceTitle,
          sourceUrl: widget.sourceUrl,
          category: widget.category,
          speaker1: widget.speaker1,
          speaker2: widget.speaker2,
        ),
      ),
    );
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

  int _getCharacterCount() {
    return widget.script.length;
  }

  int _getWordCount() {
    return widget.script.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
  }

  Duration _getEstimatedDuration() {
    final wordCount = _getWordCount();
    final wordsPerMinute = 150; // Average speaking rate
    final minutes = (wordCount / wordsPerMinute).ceil();
    return Duration(minutes: minutes);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: EchoGenAppBar(
        title: 'Script Preview',
        showLogo: false,
        actions: [
          IconButton(
            icon: Icon(Icons.copy),
            onPressed: _copyScript,
            tooltip: 'Copy Script',
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: _shareScript,
            tooltip: 'Share Script',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header Info
            Container(
              padding: const EdgeInsets.all(16),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.sourceTitle,
                    style: AppTheme.headingMedium.copyWith(
                      color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _buildInfoChip(
                        icon: Icons.category,
                        label: widget.category,
                        color: AppTheme.primaryBlue,
                        isDarkMode: isDarkMode,
                      ),
                      _buildInfoChip(
                        icon: Icons.people,
                        label: '${widget.speaker1} & ${widget.speaker2}',
                        color: AppTheme.secondaryGreen,
                        isDarkMode: isDarkMode,
                      ),
                      _buildInfoChip(
                        icon: Icons.text_fields,
                        label: '${_getCharacterCount()} chars',
                        color: AppTheme.primaryLight,
                        isDarkMode: isDarkMode,
                      ),
                      _buildInfoChip(
                        icon: Icons.access_time,
                        label: '~${_getEstimatedDuration().inMinutes} min',
                        color: AppTheme.secondaryOrange,
                        isDarkMode: isDarkMode,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Script Content
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? AppTheme.surfaceDark : AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDarkMode ? AppTheme.surfaceVariantDark : AppTheme.borderLight,
                    ),
                  ),
                  child: Scrollbar(
                    controller: _scrollController,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: SelectableText(
                        widget.script,
                        style: AppTheme.bodyMedium.copyWith(
                          color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Action Buttons
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? AppTheme.backgroundDark : AppTheme.background,
                border: Border(
                  top: BorderSide(
                    color: isDarkMode ? AppTheme.surfaceVariantDark : AppTheme.borderLight,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close, color: Colors.white, size: 18),
                      label: Text('Cancel'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondaryRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _generatePodcast,
                      icon: Icon(Icons.podcasts, color: Colors.white, size: 20),
                      label: Text('Generate Podcast'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDarkMode,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
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
