import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:echogenai/constants/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class EchoGenAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final bool showLogo;
  final VoidCallback? onLogoTap;

  const EchoGenAppBar({
    super.key,
    this.title,
    this.actions,
    this.showLogo = true,
    this.onLogoTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return AppBar(
      elevation: 2,
      centerTitle: false,
      backgroundColor: theme.colorScheme.surface,
      scrolledUnderElevation: 4,
      title: showLogo
          ? GestureDetector(
              onTap: onLogoTap,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'lib/assets/logo.png',
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback to icon if image fails to load
                          return Icon(
                            Icons.radio_rounded,
                            color: theme.colorScheme.primary,
                            size: 28,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'EchoGen.ai',
                    style: GoogleFonts.comfortaa(
                      textStyle: AppTheme.headingMedium.copyWith(
                        color: isDarkMode
                            ? AppTheme.textPrimaryDark
                            : AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : title != null
              ? Text(
                  title!,
                  style: AppTheme.headingMedium.copyWith(
                    color: isDarkMode
                        ? AppTheme.textPrimaryDark
                        : AppTheme.textPrimary,
                  ),
                )
              : null,
      actions: actions ??
          [
            IconButton(
              icon: _buildSvgIcon(
                isDarkMode
                    ? 'lib/assets/icons/GitHub_dark.svg'
                    : 'lib/assets/icons/GitHub_light.svg',
                Icons.code,
                isDarkMode
                    ? AppTheme.textPrimaryDark
                    : AppTheme.textPrimary,
              ),
              onPressed: () async {
                await _launchGitHub(context);
              },
              tooltip: 'View on GitHub',
            ),
            IconButton(
              icon: _buildSvgIcon(
                'lib/assets/icons/bmc.svg',
                Icons.favorite,
                AppTheme.secondaryRed,
              ),
              onPressed: () {
                _showSponsorDialog(context);
              },
              tooltip: 'Sponsor',
            ),
            const SizedBox(width: 8),
          ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);

  Widget _buildSvgIcon(String svgPath, IconData fallbackIcon, Color color) {
    try {
      return SvgPicture.asset(
        svgPath,
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        placeholderBuilder: (context) => Icon(
          fallbackIcon,
          color: color,
          size: 24,
        ),
      );
    } catch (e) {
      print('Error loading SVG: $svgPath - $e');
      return Icon(
        fallbackIcon,
        color: color,
        size: 24,
      );
    }
  }

  Future<void> _launchGitHub(BuildContext context) async {
    const githubUrl = 'https://github.com/Mr-Dark-debug/EchoGen.ai';
    await _launchExternalUrl(
      context,
      githubUrl,
      linkLabel: 'GitHub repository',
    );
  }

  void _showSponsorDialog(BuildContext parentContext) {
    final theme = Theme.of(parentContext);
    final isDarkMode = theme.brightness == Brightness.dark;

    showDialog(
      context: parentContext,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDarkMode ? AppTheme.surfaceDark : AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: _buildSvgIcon(
                      'lib/assets/icons/bmc.svg',
                      Icons.favorite,
                      AppTheme.secondaryRed,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Support EchoGen.ai',
                  style: AppTheme.headingMedium.copyWith(
                    color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Help us keep this project alive and growing!',
                  textAlign: TextAlign.center,
                  style: AppTheme.bodyMedium.copyWith(
                    color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                _buildSponsorOption(
                  dialogContext,
                  '☕ Buy me a coffee',
                  'Support with a small donation',
                  () async => _launchSponsorUrl(parentContext, 'buymeacoffee'),
                  svgIcon: 'lib/assets/icons/bmc.svg',
                ),
                const SizedBox(height: 12),
                _buildSponsorOption(
                  dialogContext,
                  '💖 GitHub Sponsors',
                  'Become a monthly sponsor',
                  () async => _launchSponsorUrl(parentContext, 'github'),
                ),
                const SizedBox(height: 12),
                _buildSponsorOption(
                  dialogContext,
                  '🎯 Patreon',
                  'Join our community',
                  () async => _launchSponsorUrl(parentContext, 'patreon'),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isDarkMode ? AppTheme.surfaceVariantDark : AppTheme.border,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Maybe Later',
                            style: AppTheme.bodyMedium.copyWith(
                              color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppTheme.secondaryRed, AppTheme.secondaryRed.withOpacity(0.8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.secondaryRed.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.of(dialogContext).pop();
                            await _launchSponsorUrl(parentContext, 'buymeacoffee');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.favorite, color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Support',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSponsorOption(
    BuildContext context,
    String title,
    String subtitle,
    VoidCallback onTap, {
    String? svgIcon,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue.withOpacity(0.05),
            AppTheme.primaryLight.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
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
                  child: svgIcon != null
                      ? _buildSvgIcon(svgIcon, Icons.coffee, AppTheme.primaryBlue)
                      : Icon(
                          title.contains('coffee') ? Icons.coffee :
                          title.contains('GitHub') ? Icons.code :
                          Icons.favorite,
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
                        title,
                        style: AppTheme.titleMedium.copyWith(
                          color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
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
                  Icons.arrow_forward_ios,
                  color: AppTheme.primaryBlue.withOpacity(0.6),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchSponsorUrl(BuildContext context, String platform) async {
    String url;
    switch (platform) {
      case 'buymeacoffee':
        url = 'https://buymeacoffee.com/mrdarkdebug';
        break;
      case 'github':
        url = 'https://github.com/Mr-Dark-debug/EchoGen.ai';
        break;
      case 'patreon':
        url = 'https://github.com/Mr-Dark-debug/EchoGen.ai';
        break;
      default:
        url = 'https://github.com/Mr-Dark-debug/EchoGen.ai';
    }

    await _launchExternalUrl(
      context,
      url,
      linkLabel: platform,
    );
  }

  Future<void> _launchExternalUrl(
    BuildContext context,
    String url, {
    String? linkLabel,
  }) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        final didLaunch = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );

        if (!didLaunch && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open ${linkLabel ?? 'link'}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch ${linkLabel ?? url}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening ${linkLabel ?? 'link'}: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
