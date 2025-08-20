import 'package:flutter/material.dart';
import 'package:echogenai/constants/app_theme.dart';
import 'package:echogenai/widgets/app_bar_widget.dart';
import 'package:echogenai/services/image_router_service.dart';
import 'dart:io';

class CoverArtGenerationScreen extends StatefulWidget {
  final String podcastTitle;
  final String? existingCoverPath;
  final Function(String?)? onCoverArtGenerated;

  const CoverArtGenerationScreen({
    super.key,
    required this.podcastTitle,
    this.existingCoverPath,
    this.onCoverArtGenerated,
  });

  @override
  State<CoverArtGenerationScreen> createState() => _CoverArtGenerationScreenState();
}

class _CoverArtGenerationScreenState extends State<CoverArtGenerationScreen> {
  final ImageRouterService _imageService = ImageRouterService();
  final TextEditingController _promptController = TextEditingController();
  
  List<ImageModel> _availableModels = [];
  ImageModel? _selectedModel;
  String _selectedQuality = 'auto';
  String _selectedSize = '1024x1024';
  
  bool _isLoading = false;
  bool _isGenerating = false;
  bool _hasApiKey = false;
  String? _generatedImagePath;
  String? _error;

  final List<String> _qualityOptions = ['auto', 'low', 'medium', 'high'];
  final List<String> _sizeOptions = ['512x512', '1024x1024', '1024x1792', '1792x1024'];

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    setState(() => _isLoading = true);
    
    try {
      // Check if API key exists
      _hasApiKey = await _imageService.hasApiKey();
      
      if (_hasApiKey) {
        // Load available models
        _availableModels = await _imageService.getAvailableModels();
        if (_availableModels.isNotEmpty) {
          _selectedModel = _availableModels.first;
        }
      }
      
      // Set default prompt based on podcast title
      _promptController.text = _generateDefaultPrompt();
      
    } catch (e) {
      _setError('Failed to initialize: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _generateDefaultPrompt() {
    return 'Professional podcast cover art with modern design, vibrant colors, and clean typography. '
           'Theme related to "${widget.podcastTitle}". Minimalist style with good contrast.';
  }



  Future<void> _generateCoverArt() async {
    if (_promptController.text.trim().isEmpty) {
      _setError('Please enter a prompt for the cover art');
      return;
    }

    if (_selectedModel == null) {
      _setError('Please select a model');
      return;
    }

    setState(() {
      _isGenerating = true;
      _error = null;
    });

    try {
      final imagePath = await _imageService.generateCoverArt(
        prompt: _promptController.text.trim(),
        modelId: _selectedModel!.id,
        quality: _selectedQuality,
        size: _selectedSize,
        podcastTitle: widget.podcastTitle,
      );

      if (imagePath != null) {
        setState(() {
          _generatedImagePath = imagePath;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cover art generated successfully!')),
        );
      } else {
        _setError('Failed to generate cover art');
      }
    } catch (e) {
      _setError('Error generating cover art: $e');
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  void _useCoverArt() {
    if (_generatedImagePath != null) {
      widget.onCoverArtGenerated?.call(_generatedImagePath);
      Navigator.of(context).pop(_generatedImagePath);
    }
  }

  void _setError(String? error) {
    setState(() => _error = error);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: EchoGenAppBar(
        title: 'Generate Cover Art',
        showLogo: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    'Create Custom Cover Art',
                    style: AppTheme.headingLarge.copyWith(
                      color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'For: ${widget.podcastTitle}',
                    style: AppTheme.bodyMedium.copyWith(
                      color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // API Key Section
                  if (!_hasApiKey) ...[
                    _buildApiKeySection(isDarkMode),
                    const SizedBox(height: 24),
                  ],

                  // Generation Section
                  if (_hasApiKey) ...[
                    _buildGenerationSection(isDarkMode),
                    const SizedBox(height: 24),
                  ],

                  // Generated Image Preview
                  if (_generatedImagePath != null) ...[
                    _buildImagePreview(isDarkMode),
                    const SizedBox(height: 24),
                  ],

                  // Error Display
                  if (_error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _error!,
                              style: AppTheme.bodyMedium.copyWith(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildApiKeySection(bool isDarkMode) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.key,
                color: AppTheme.primaryBlue,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'ImageRouter API Key Required',
                style: AppTheme.titleMedium.copyWith(
                  color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'To generate custom cover art, you need an ImageRouter API key. Configure it in the API Keys settings.',
            style: AppTheme.bodyMedium.copyWith(
              color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed('/api_keys');
              },
              icon: Icon(Icons.settings, color: Colors.white),
              label: Text('Go to API Keys Settings'),
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
        ],
      ),
    );
  }

  Widget _buildGenerationSection(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Generation Settings',
          style: AppTheme.titleLarge.copyWith(
            color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),

        // Prompt Input
        TextField(
          controller: _promptController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Describe your cover art',
            hintText: 'Enter a detailed description of the cover art you want...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: Icon(Icons.description),
          ),
        ),
        const SizedBox(height: 16),

        // Model Selection
        if (_availableModels.isNotEmpty) ...[
          DropdownButtonFormField<ImageModel>(
            value: _selectedModel,
            decoration: InputDecoration(
              labelText: 'AI Model',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: Icon(Icons.psychology),
            ),
            items: _availableModels.map((model) {
              return DropdownMenuItem(
                value: model,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(model.name),
                    Text(
                      model.description,
                      style: AppTheme.bodySmall.copyWith(
                        color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (model) {
              setState(() => _selectedModel = model);
            },
          ),
          const SizedBox(height: 16),
        ],

        // Quality and Size Row
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedQuality,
                decoration: InputDecoration(
                  labelText: 'Quality',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _qualityOptions.map((quality) {
                  return DropdownMenuItem(
                    value: quality,
                    child: Text(quality.toUpperCase()),
                  );
                }).toList(),
                onChanged: (quality) {
                  setState(() => _selectedQuality = quality!);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedSize,
                decoration: InputDecoration(
                  labelText: 'Size',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _sizeOptions.map((size) {
                  return DropdownMenuItem(
                    value: size,
                    child: Text(size),
                  );
                }).toList(),
                onChanged: (size) {
                  setState(() => _selectedSize = size!);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Generate Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isGenerating ? null : _generateCoverArt,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isGenerating
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text('Generating...'),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome),
                      const SizedBox(width: 8),
                      const Text('Generate Cover Art'),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview(bool isDarkMode) {
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
          Text(
            'Generated Cover Art',
            style: AppTheme.titleLarge.copyWith(
              color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Image Preview
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(_generatedImagePath!),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.error,
                        size: 50,
                        color: Colors.grey[600],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _generateCoverArt,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Generate New'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _useCoverArt,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Use This Cover'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}