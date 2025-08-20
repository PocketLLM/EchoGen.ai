import 'package:flutter/material.dart';
import 'package:echogenai/constants/app_theme.dart';
import 'package:echogenai/widgets/app_bar_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: const EchoGenAppBar(
        title: 'About',
        showLogo: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Logo and Name
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.asset(
                        'lib/assets/logo.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback to icon if image fails to load
                          return Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.radio_rounded,
                              size: 50,
                              color: AppTheme.white,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'EchoGen.ai',
                    style: AppTheme.displayMedium.copyWith(
                      color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Craft your voice with AI',
                    style: AppTheme.titleMedium.copyWith(
                      color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // App Description
            _buildSection(
              context,
              '📱 About the App',
              'EchoGen.ai is a powerful AI-powered podcast generation tool that transforms your ideas, URLs, and documents into engaging podcast scripts. Whether you\'re a content creator, educator, or business professional, EchoGen.ai helps you create compelling audio content effortlessly.',
            ),
            
            const SizedBox(height: 24),
            
            // Features
            _buildSection(
              context,
              '✨ Features',
              '• Generate podcasts from URLs and documents\n• AI-powered script generation with multiple models\n• Background audio playback with notifications\n• Mini player across all screens\n• Custom cover art generation with ImageRouter\n• Centralized API key management\n• Multiple TTS providers (Gemini, OpenAI, ElevenLabs)\n• Dark/Light theme support\n• Modern and intuitive UI\n• Export and share functionality',
            ),
            
            const SizedBox(height: 24),
            
            // Version Info
            _buildInfoCard(
              context,
              [
                _buildInfoRow(context, 'Version', '0.2.0+BETA'),
                _buildInfoRow(context, 'Build', 'Flutter 3.24.0'),
                _buildInfoRow(context, 'Platform', 'Android • iOS'),
                _buildInfoRow(context, 'License', 'MIT License'),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Legal Links
            _buildSection(
              context,
              '📋 Legal',
              '',
            ),
            
            const SizedBox(height: 8),
            
            _buildLegalOption(
              context,
              Icons.description_outlined,
              'Terms and Conditions',
              'View our terms of service',
              () => _showLegalDialog(context, 'Terms and Conditions', _getTermsContent()),
            ),
            
            const SizedBox(height: 12),
            
            _buildLegalOption(
              context,
              Icons.privacy_tip_outlined,
              'Privacy Policy',
              'How we handle your data',
              () => _showLegalDialog(context, 'Privacy Policy', _getPrivacyContent()),
            ),
            
            const SizedBox(height: 12),
            
            _buildLegalOption(
              context,
              Icons.code_outlined,
              'Licenses',
              'Open source licenses',
              () => _showLegalDialog(context, 'Open Source Licenses', _getLicensesContent()),
            ),
            
            const SizedBox(height: 32),
            
            // Social Links
            Center(
              child: Column(
                children: [
                  Text(
                    'Connect with us',
                    style: AppTheme.titleMedium.copyWith(
                      color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildSocialButton(
                        context,
                        Icons.code,
                        'GitHub',
                        () => _launchUrl(context, 'https://github.com/echogenai/echogenai'),
                      ),
                      _buildSocialButton(
                        context,
                        Icons.favorite,
                        'Sponsor',
                        () => _launchUrl(context, 'https://github.com/sponsors/echogenai'),
                      ),
                      _buildSocialButton(
                        context,
                        Icons.alternate_email,
                        'Contact',
                        () => _launchUrl(context, 'mailto:contact@echogen.ai'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Footer
            Center(
              child: Text(
                'Made with ❤️ for the community\n© 2024 EchoGen.ai',
                textAlign: TextAlign.center,
                style: AppTheme.bodySmall.copyWith(
                  color: isDarkMode ? AppTheme.textTertiaryDark : AppTheme.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.titleLarge.copyWith(
            color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (content.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            content,
            style: AppTheme.bodyMedium.copyWith(
              color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, List<Widget> children) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.surfaceVariantDark : AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? AppTheme.surfaceVariantDark : AppTheme.border,
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.bodyMedium.copyWith(
              color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTheme.bodyMedium.copyWith(
              color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalOption(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDarkMode ? AppTheme.surfaceVariantDark : AppTheme.border,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppTheme.primaryBlue,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.titleMedium.copyWith(
                      color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
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
              Icons.chevron_right,
              color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.primaryBlue),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: AppTheme.primaryBlue,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLegalDialog(BuildContext context, String title, String content) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 600),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDarkMode ? AppTheme.surfaceDark : AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTheme.headingMedium.copyWith(
                    color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      content,
                      style: AppTheme.bodyMedium.copyWith(
                        color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // Opens in Chrome/default browser
        );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open: $url'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening link: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getTermsContent() {
    return '''
Terms and Conditions

Last updated: December 2024

1. Acceptance of Terms
By using EchoGen.ai, you agree to these terms and conditions.

2. Use License
Permission is granted to use this application for personal and commercial purposes.

3. Disclaimer
The service is provided "as is" without any warranties.

4. Limitations
In no event shall EchoGen.ai be liable for any damages arising from the use of this service.

5. Privacy
We respect your privacy. Please review our Privacy Policy for information on how we collect and use data.

6. Changes to Terms
We reserve the right to modify these terms at any time.

For questions about these Terms, please contact us at contact@echogen.ai.
''';
  }

  String _getPrivacyContent() {
    return '''
Privacy Policy

Last updated: December 2024

1. Information We Collect
We collect information you provide directly to us and information about your use of our services.

2. How We Use Information
We use the information to provide, maintain, and improve our services.

3. Information Sharing
We do not sell, trade, or otherwise transfer your personal information to third parties.

4. Data Security
We implement appropriate security measures to protect your personal information.

5. Your Rights
You have the right to access, update, or delete your personal information.

6. Changes to Privacy Policy
We may update this privacy policy from time to time.

For questions about this Privacy Policy, please contact us at privacy@echogen.ai.
''';
  }

  String _getLicensesContent() {
    return '''
Open Source Licenses

EchoGen.ai is built using the following open source libraries:

Flutter Framework
Copyright (c) 2017 The Flutter Authors
Licensed under the BSD 3-Clause License

Google Fonts
Copyright (c) 2019 Google Inc.
Licensed under the Apache License 2.0

Provider
Copyright (c) 2019 Remi Rousselet
Licensed under the MIT License

Shared Preferences
Copyright (c) 2017 The Flutter Authors
Licensed under the BSD 3-Clause License

Material Design Icons
Copyright (c) Google Inc.
Licensed under the Apache License 2.0

For complete license texts, please visit the respective project repositories.
''';
  }
}
