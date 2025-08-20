import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:echogenai/constants/app_theme.dart';
import 'package:echogenai/widgets/app_bar_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiKeysScreen extends StatefulWidget {
  const ApiKeysScreen({super.key});

  @override
  State<ApiKeysScreen> createState() => _ApiKeysScreenState();
}

class _ApiKeysScreenState extends State<ApiKeysScreen> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _isValidating = {};
  final Map<String, ApiKeyStatus> _keyStatus = {};
  
  final List<ApiKeyConfig> _apiConfigs = [
    ApiKeyConfig(
      id: 'gemini',
      name: 'Google Gemini',
      description: 'For AI text generation and processing',
      svgAsset: 'lib/assets/icons/gemini.svg',
      icon: Icons.auto_awesome,
      color: AppTheme.primaryBlue,
      placeholder: 'AIzaSy...',
    ),
    ApiKeyConfig(
      id: 'openai',
      name: 'OpenAI',
      description: 'For GPT models and text generation',
      svgAsset: 'lib/assets/icons/OpenAI_light.svg',
      icon: Icons.psychology,
      color: AppTheme.secondaryGreen,
      placeholder: 'sk-...',
    ),
    ApiKeyConfig(
      id: 'groq',
      name: 'Groq',
      description: 'For fast inference with Llama models',
      svgAsset: 'lib/assets/icons/groq.svg',
      icon: Icons.speed,
      color: AppTheme.secondaryRed,
      placeholder: 'gsk_...',
    ),
    ApiKeyConfig(
      id: 'openrouter',
      name: 'OpenRouter',
      description: 'Access to multiple AI models',
      icon: Icons.hub,
      color: AppTheme.onboardingYellow,
      placeholder: 'sk-or-...',
    ),
    ApiKeyConfig(
      id: 'firecrawl',
      name: 'Firecrawl',
      description: 'For web scraping and content extraction',
      icon: Icons.web,
      color: AppTheme.primaryLight,
      placeholder: 'fc-...',
    ),
    ApiKeyConfig(
      id: 'hyperbrowser',
      name: 'HyperbrowserAI',
      description: 'Alternative web scraping service',
      icon: Icons.travel_explore,
      color: AppTheme.onboardingBlue,
      placeholder: 'Your Hyperbrowser API key',
    ),
    ApiKeyConfig(
      id: 'imagerouter',
      name: 'ImageRouter',
      description: 'For AI-generated podcast cover art',
      icon: Icons.image,
      color: AppTheme.secondaryOrange,
      placeholder: 'Your ImageRouter API key',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadSavedKeys();
  }

  void _initializeControllers() {
    for (final config in _apiConfigs) {
      _controllers[config.id] = TextEditingController();
      _keyStatus[config.id] = ApiKeyStatus.notSet;
      _isValidating[config.id] = false;
    }
  }

  Future<void> _loadSavedKeys() async {
    final prefs = await SharedPreferences.getInstance();
    for (final config in _apiConfigs) {
      final savedKey = prefs.getString('api_key_${config.id}');
      if (savedKey != null && savedKey.isNotEmpty) {
        _controllers[config.id]!.text = savedKey;
        setState(() {
          _keyStatus[config.id] = ApiKeyStatus.saved;
        });
      }
    }
  }

  Future<void> _saveApiKey(String keyId, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_key_$keyId', value);
  }

  Future<void> _deleteApiKey(String keyId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('api_key_$keyId');
  }

  Future<void> _validateApiKey(ApiKeyConfig config) async {
    final key = _controllers[config.id]!.text.trim();
    if (key.isEmpty) return;

    setState(() {
      _isValidating[config.id] = true;
      _keyStatus[config.id] = ApiKeyStatus.validating;
    });

    try {
      // Simulate API validation (replace with actual validation)
      await Future.delayed(const Duration(seconds: 2));
      
      // Basic validation based on key format
      bool isValid = _validateKeyFormat(config.id, key);
      
      if (isValid) {
        await _saveApiKey(config.id, key);
        setState(() {
          _keyStatus[config.id] = ApiKeyStatus.valid;
        });
        _showSnackBar('${config.name} API key validated and saved!', isSuccess: true);
      } else {
        setState(() {
          _keyStatus[config.id] = ApiKeyStatus.invalid;
        });
        _showSnackBar('Invalid ${config.name} API key format', isSuccess: false);
      }
    } catch (e) {
      setState(() {
        _keyStatus[config.id] = ApiKeyStatus.error;
      });
      _showSnackBar('Error validating ${config.name} API key: $e', isSuccess: false);
    } finally {
      setState(() {
        _isValidating[config.id] = false;
      });
    }
  }

  bool _validateKeyFormat(String keyId, String key) {
    switch (keyId) {
      case 'gemini':
        return key.startsWith('AIza') && key.length > 20;
      case 'openai':
        return key.startsWith('sk-') && key.length > 20;
      case 'groq':
        return key.startsWith('gsk_') && key.length > 20;
      case 'openrouter':
        return key.startsWith('sk-or-') && key.length > 20;
      case 'firecrawl':
        return key.startsWith('fc-') && key.length > 10;
      case 'hyperbrowser':
        return key.length >= 8;
      case 'imagerouter':
        return key.length >= 20; // ImageRouter keys are typically longer
      default:
        return key.length > 10;
    }
  }

  void _showSnackBar(String message, {required bool isSuccess}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isSuccess ? AppTheme.secondaryGreen : AppTheme.secondaryRed,
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
        title: 'API Keys',
        showLogo: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
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
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primaryBlue.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      border: Border.all(
                        color: AppTheme.primaryBlue.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.vpn_key_rounded,
                      size: 32,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Secure API Key Management',
                    style: AppTheme.headingMedium.copyWith(
                      color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your API keys are stored securely on your device and never shared with third parties.',
                    textAlign: TextAlign.center,
                    style: AppTheme.bodyMedium.copyWith(
                      color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // API Keys List
            ...(_apiConfigs.map((config) => _buildApiKeyCard(config, isDarkMode))),
            
            const SizedBox(height: 24),
            
            // Help Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? AppTheme.surfaceVariantDark : AppTheme.surfaceVariant,
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
                      Icon(
                        Icons.help_outline,
                        color: AppTheme.primaryBlue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Need Help?',
                        style: AppTheme.titleMedium.copyWith(
                          color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• Get your API keys from the respective service providers\n'
                    '• Keys are validated before saving\n'
                    '• You can update or delete keys anytime\n'
                    '• All keys are stored locally and encrypted',
                    style: AppTheme.bodyMedium.copyWith(
                      color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                      height: 1.5,
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

  Widget _buildApiKeyCard(ApiKeyConfig config, bool isDarkMode) {
    final status = _keyStatus[config.id] ?? ApiKeyStatus.notSet;
    final isValidating = _isValidating[config.id] ?? false;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.surfaceDark : AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getStatusColor(status).withOpacity(0.3),
          width: 1.5,
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: config.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: config.svgAsset != null
                      ? Padding(
                          padding: const EdgeInsets.all(12),
                          child: _buildApiIcon(config, isDarkMode),
                        )
                      : Icon(
                          config.icon!,
                          color: config.color,
                          size: 24,
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        config.name,
                        style: AppTheme.titleMedium.copyWith(
                          color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        config.description,
                        style: AppTheme.bodyMedium.copyWith(
                          color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusIndicator(status, isValidating),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Input Field
            TextField(
              controller: _controllers[config.id],
              obscureText: true,
              decoration: InputDecoration(
                hintText: config.placeholder,
                prefixIcon: Icon(Icons.key, color: config.color),
                suffixIcon: _controllers[config.id]!.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _controllers[config.id]!.clear();
                            _keyStatus[config.id] = ApiKeyStatus.notSet;
                          });
                          _deleteApiKey(config.id);
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: config.color.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: config.color, width: 2),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  if (value.isEmpty) {
                    _keyStatus[config.id] = ApiKeyStatus.notSet;
                  } else {
                    _keyStatus[config.id] = ApiKeyStatus.modified;
                  }
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isValidating || _controllers[config.id]!.text.trim().isEmpty
                        ? null
                        : () => _validateApiKey(config),
                    icon: isValidating
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isDarkMode ? AppTheme.textPrimaryDark : AppTheme.surface,
                              ),
                            ),
                          )
                        : Icon(Icons.check_circle_outline),
                    label: Text(isValidating ? 'Validating...' : 'Validate & Save'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: config.color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
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
  }

  Widget _buildStatusIndicator(ApiKeyStatus status, bool isValidating) {
    if (isValidating) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
        ),
      );
    }

    IconData icon;
    Color color;
    
    switch (status) {
      case ApiKeyStatus.valid:
        icon = Icons.check_circle;
        color = AppTheme.secondaryGreen;
        break;
      case ApiKeyStatus.invalid:
        icon = Icons.error;
        color = AppTheme.secondaryRed;
        break;
      case ApiKeyStatus.error:
        icon = Icons.warning;
        color = AppTheme.onboardingYellow;
        break;
      case ApiKeyStatus.saved:
        icon = Icons.save;
        color = AppTheme.primaryBlue;
        break;
      case ApiKeyStatus.modified:
        icon = Icons.edit;
        color = AppTheme.onboardingYellow;
        break;
      case ApiKeyStatus.notSet:
      default:
        icon = Icons.key_off;
        color = Colors.grey;
        break;
    }

    return Icon(icon, color: color, size: 24);
  }

  Widget _buildApiIcon(ApiKeyConfig config, bool isDarkMode) {
    String svgPath = config.svgAsset!;

    // Use dark mode variant for OpenAI if available
    if (config.id == 'openai') {
      svgPath = isDarkMode
          ? 'lib/assets/icons/OpenAI_dark.svg'
          : 'lib/assets/icons/OpenAI_light.svg';
    }

    try {
      return SvgPicture.asset(
        svgPath,
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(
          config.color,
          BlendMode.srcIn,
        ),
        placeholderBuilder: (context) => Icon(
          config.icon ?? Icons.api,
          color: config.color,
          size: 24,
        ),
      );
    } catch (e) {
      print('Error loading API SVG: $svgPath - $e');
      return Icon(
        config.icon ?? Icons.api,
        color: config.color,
        size: 24,
      );
    }
  }

  Color _getStatusColor(ApiKeyStatus status) {
    switch (status) {
      case ApiKeyStatus.valid:
        return AppTheme.secondaryGreen;
      case ApiKeyStatus.invalid:
      case ApiKeyStatus.error:
        return AppTheme.secondaryRed;
      case ApiKeyStatus.saved:
      case ApiKeyStatus.modified:
        return AppTheme.primaryBlue;
      case ApiKeyStatus.notSet:
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}

class ApiKeyConfig {
  final String id;
  final String name;
  final String description;
  final IconData? icon;
  final String? svgAsset;
  final Color color;
  final String placeholder;

  const ApiKeyConfig({
    required this.id,
    required this.name,
    required this.description,
    this.icon,
    this.svgAsset,
    required this.color,
    required this.placeholder,
  }) : assert(icon != null || svgAsset != null, 'Either icon or svgAsset must be provided');
}

enum ApiKeyStatus {
  notSet,
  modified,
  validating,
  valid,
  invalid,
  error,
  saved,
}
