import 'package:flutter/material.dart';
import 'package:echogenai/constants/app_theme.dart';
import 'package:echogenai/widgets/app_bar_widget.dart';
import 'package:echogenai/services/ai_service.dart';
import 'package:echogenai/services/storage_service.dart';
import 'package:echogenai/screens/script_preview_screen.dart';
import 'package:echogenai/screens/podcast_generation_screen.dart';

class ScriptGenerationScreen extends StatefulWidget {
  final String content;
  final String sourceUrl;
  final String sourceTitle;

  const ScriptGenerationScreen({
    super.key,
    required this.content,
    required this.sourceUrl,
    required this.sourceTitle,
  });

  @override
  State<ScriptGenerationScreen> createState() => _ScriptGenerationScreenState();
}

class _ScriptGenerationScreenState extends State<ScriptGenerationScreen> {
  final AIService _aiService = AIService();
  final StorageService _storageService = StorageService();
  final TextEditingController _userPromptController = TextEditingController();
  final TextEditingController _speaker1Controller = TextEditingController(text: 'Alex');
  final TextEditingController _speaker2Controller = TextEditingController(text: 'Sam');

  String _selectedProvider = 'Gemini';
  String? _selectedModel;
  String _selectedCategory = 'playful';
  
  List<AIModel> _availableModels = [];
  bool _isLoadingModels = false;
  bool _isGeneratingScript = false;
  String? _error;

  final List<String> _providers = ['Gemini', 'Groq', 'OpenAI', 'OpenRouter'];
  
  final Map<String, PodcastCategory> _categories = {
    'playful': PodcastCategory(
      name: 'Playful & Fun',
      description: 'Light-hearted, entertaining conversation',
      systemPrompt: '''You are creating a playful and entertaining podcast script. Your task is to create ONLY a podcast conversation script.

CRITICAL REQUIREMENTS:
1. Start with "Title: [Your catchy title here]" on the first line
2. Create ONLY dialogue between the two speakers - no explanations, descriptions, or meta-commentary
3. Use the exact speaker names provided in the user prompt
4. Generate 8-12 minutes of conversation content (approximately 1200-1800 words)
5. Use voice styling instructions in parentheses before speaker lines to control tone, emotion and delivery

VOICE STYLING (CRITICAL - READ CAREFULLY):
- Add voice style instructions in parentheses ONLY for TTS tone guidance
- Example: "Speaker 1: (excitedly) This is amazing news!"
- These emotions in parentheses are NEVER spoken aloud - they guide voice tone only
- The TTS system reads ONLY the dialogue after the parentheses
- Use emotions like: cheerfully, excitedly, laughing, whispering, thoughtfully, sadly, dramatically
- Don't overuse - add to 30-40% of lines at most for variety and emphasis
- REMEMBER: (emotion) = tone guidance, dialogue = what's actually spoken

CONVERSATION STYLE:
- Light-hearted and fun with occasional humor and jokes
- Engaging and energetic with natural banter between speakers
- Educational but not overly serious
- Include relevant examples and analogies when appropriate
- Use casual, conversational language
- Add moments of surprise and delight
- Keep the audience entertained while informing them

STRICT FORMAT:
Title: [Your catchy title here]

Speaker 1: (emotion/tone) [dialogue content only]
Speaker 2: [dialogue content only]
Speaker 1: [dialogue content only]
Speaker 2: (emotion/tone) [dialogue content only]
...

IMPORTANT: Return ONLY the title and dialogue script. No background music, sound effects, production notes, or explanatory text.''',
    ),
    'serious': PodcastCategory(
      name: 'Serious & Professional',
      description: 'In-depth, analytical discussion',
      systemPrompt: '''You are creating a serious and professional podcast script. Your task is to create ONLY a podcast conversation script.

CRITICAL REQUIREMENTS:
1. Start with "Title: [Your professional title here]" on the first line
2. Create ONLY dialogue between the two speakers - no explanations, descriptions, or meta-commentary
3. Use the exact speaker names provided in the user prompt
4. Generate 8-12 minutes of conversation content (approximately 1200-1800 words)
5. Use voice styling instructions in parentheses before speaker lines to control tone and delivery

VOICE STYLING (CRITICAL - READ CAREFULLY):
- Add voice style instructions in parentheses ONLY for TTS tone guidance
- Example: "Speaker 1: (authoritatively) The evidence suggests three key findings."
- These emotions in parentheses are NEVER spoken aloud - they guide voice tone only
- The TTS system reads ONLY the dialogue after the parentheses
- Use professional tones like: authoritatively, informatively, analytically, thoughtfully, considerately
- Don't overuse - add to 20-30% of lines where emphasis is needed
- REMEMBER: (emotion) = tone guidance, dialogue = what's actually spoken

CONVERSATION STYLE:
- Thoughtful and analytical with deep insights
- Well-researched and factual approach
- Professional tone while remaining accessible
- Include expert-level analysis and commentary
- Use precise, articulate language
- Focus on implications and broader context
- Maintain credibility and authority
- Provide actionable insights

STRICT FORMAT:
Title: [Your professional title here]

Speaker 1: (emotion/tone) [dialogue content only]
Speaker 2: [dialogue content only]
Speaker 1: [dialogue content only]
Speaker 2: (emotion/tone) [dialogue content only]
...

IMPORTANT: Return ONLY the title and dialogue script. No background music, sound effects, production notes, or explanatory text.''',
    ),
    'investigative': PodcastCategory(
      name: 'Investigative Mystery',
      description: 'Deep-dive investigative style',
      systemPrompt: '''You are creating an investigative podcast script. Your task is to create ONLY a podcast conversation script.

CRITICAL REQUIREMENTS:
1. Start with "Title: [Your investigative title here]" on the first line
2. Create ONLY dialogue between the two speakers - no explanations, descriptions, or meta-commentary
3. Use the exact speaker names provided in the user prompt
4. Generate 8-12 minutes of conversation content (approximately 1200-1800 words)
5. Use voice styling instructions in parentheses to control tone and create suspense

VOICE STYLING (CRITICAL - READ CAREFULLY):
- Add voice style instructions in parentheses ONLY for TTS tone guidance
- Example: "Speaker 1: (in a hushed voice) The evidence disappeared overnight."
- These emotions in parentheses are NEVER spoken aloud - they guide voice tone only
- The TTS system reads ONLY the dialogue after the parentheses
- Use tones like: mysteriously, urgently, suspiciously, cautiously, contemplatively, pensively
- Use voice styling to build tension and create atmosphere
- Don't overuse - add to 30-40% of lines for dramatic effect
- REMEMBER: (emotion) = tone guidance, dialogue = what's actually spoken

CONVERSATION STYLE:
- Mysterious and intriguing with a sense of discovery
- Methodical investigation of facts and evidence
- Building suspense and curiosity
- Questioning assumptions and digging deeper
- Revealing information progressively
- Include "what if" scenarios and theories
- Maintain journalistic integrity
- Create compelling narrative tension

STRICT FORMAT:
Title: [Your investigative title here]

Speaker 1: (emotion/tone) [dialogue content only]
Speaker 2: [dialogue content only]
Speaker 1: [dialogue content only]
Speaker 2: (emotion/tone) [dialogue content only]
...

IMPORTANT: Return ONLY the title and dialogue script. No background music, sound effects, production notes, or explanatory text.''',
    ),
    'coffee_chat': PodcastCategory(
      name: 'Coffee Chat',
      description: 'Casual, intimate conversation',
      systemPrompt: '''You are creating a casual coffee chat podcast script. Your task is to create ONLY a podcast conversation script.

CRITICAL REQUIREMENTS:
1. Start with "Title: [Your warm, friendly title here]" on the first line
2. Create ONLY dialogue between the two speakers - no explanations, descriptions, or meta-commentary
3. Use the exact speaker names provided in the user prompt
4. Generate 8-12 minutes of conversation content (approximately 1200-1800 words)
5. Use voice styling instructions in parentheses to create a warm, relaxed atmosphere

VOICE STYLING (CRITICAL - READ CAREFULLY):
- Add voice style instructions in parentheses ONLY for TTS tone guidance
- Example: "Speaker 1: (warmly) I've been thinking about what you said last week."
- These emotions in parentheses are NEVER spoken aloud - they guide voice tone only
- The TTS system reads ONLY the dialogue after the parentheses
- Use tones like: warmly, softly, casually, reflecting, chuckling, smiling, nostalgically
- Create a relaxed, authentic conversational feel
- Don't overuse - add to 30-40% of lines for natural flow
- REMEMBER: (emotion) = tone guidance, dialogue = what's actually spoken

CONVERSATION STYLE:
- Warm, intimate, and conversational
- Like two friends catching up over coffee
- Personal anecdotes and relatable experiences
- Comfortable pauses and natural flow
- Genuine reactions and emotions
- Supportive and encouraging tone
- Include personal insights and reflections
- Feel authentic and unscripted

STRICT FORMAT:
Title: [Your warm, friendly title here]

Speaker 1: (emotion/tone) [dialogue content only]
Speaker 2: [dialogue content only]
Speaker 1: [dialogue content only]
Speaker 2: (emotion/tone) [dialogue content only]
...

IMPORTANT: Return ONLY the title and dialogue script. No background music, sound effects, production notes, or explanatory text.''',
    ),
    'tech_talk': PodcastCategory(
      name: 'Tech Talk',
      description: 'Technology-focused discussion',
      systemPrompt: '''You are creating a technology-focused podcast script. Your task is to create ONLY a podcast conversation script.

CRITICAL REQUIREMENTS:
1. Start with "Title: [Your tech-focused title here]" on the first line
2. Create ONLY dialogue between the two speakers - no explanations, descriptions, or meta-commentary
3. Use the exact speaker names provided in the user prompt
4. Generate 8-12 minutes of conversation content (approximately 1200-1800 words)
5. Use voice styling instructions in parentheses for tech enthusiasm and clarity

VOICE STYLING:
- Add voice style instructions in parentheses before important lines 
- Example: "Speaker 1: (enthusiastically) This new technology changes everything!"
- Use tones like: enthusiastically, clearly, thoughtfully, technically, excitedly, knowledgeably
- Use voice styling to emphasize key technical points and innovations
- Don't overuse - add to 25-35% of lines for emphasis on key points

CONVERSATION STYLE:
- Technical but accessible to general audience
- Excited about innovation and possibilities
- Include practical applications and implications
- Discuss both benefits and potential concerns
- Use analogies to explain complex concepts
- Forward-thinking and visionary
- Include real-world examples and use cases
- Balance technical depth with clarity

STRICT FORMAT:
Title: [Your tech-focused title here]

Speaker 1: (emotion/tone) [dialogue content only]
Speaker 2: [dialogue content only]
Speaker 1: [dialogue content only]
Speaker 2: (emotion/tone) [dialogue content only]
...

IMPORTANT: Return ONLY the title and dialogue script. No background music, sound effects, production notes, or explanatory text.''',
    ),
    'storytelling': PodcastCategory(
      name: 'Storytelling',
      description: 'Narrative-driven presentation',
      systemPrompt: '''You are creating a storytelling podcast script. Your task is to create ONLY a podcast conversation script.

CRITICAL REQUIREMENTS:
1. Start with "Title: [Your storytelling title here]" on the first line
2. Create ONLY dialogue between the two speakers - no explanations, descriptions, or meta-commentary
3. Use the exact speaker names provided in the user prompt
4. Generate 8-12 minutes of conversation content (approximately 1200-1800 words)
5. Use voice styling instructions in parentheses for dramatic storytelling effect

VOICE STYLING:
- Add voice style instructions in parentheses before important lines 
- Example: "Speaker 1: (dramatically) The door creaked open revealing a forgotten world."
- Use tones like: dramatically, whispering, suspensefully, emotionally, passionately, reminiscently
- Use voice styling to enhance dramatic moments and create atmosphere
- Don't overuse - add to 40-50% of lines for maximum narrative impact

CONVERSATION STYLE:
- Narrative-driven with compelling story arcs
- Rich descriptions and vivid imagery through dialogue
- Emotional engagement and character development
- Building tension and resolution
- Include dramatic pauses and pacing
- Paint pictures with words through conversation
- Create immersive experiences
- Use storytelling techniques like foreshadowing

STRICT FORMAT:
Title: [Your storytelling title here]

Speaker 1: (emotion/tone) [dialogue content only]
Speaker 2: [dialogue content only]
Speaker 1: [dialogue content only]
Speaker 2: (emotion/tone) [dialogue content only]
...

IMPORTANT: Return ONLY the title and dialogue script. No background music, sound effects, production notes, or explanatory text.''',
    ),
  };

  @override
  void initState() {
    super.initState();
    _loadModels();
  }

  @override
  void dispose() {
    _userPromptController.dispose();
    _speaker1Controller.dispose();
    _speaker2Controller.dispose();
    super.dispose();
  }

  Future<void> _loadModels() async {
    setState(() {
      _isLoadingModels = true;
      _error = null;
    });

    try {
      final models = await _aiService.getModels(_selectedProvider);
      setState(() {
        _availableModels = models;
        _selectedModel = models.isNotEmpty ? models.first.id : null;
        _isLoadingModels = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoadingModels = false;
        _availableModels = [];
        _selectedModel = null;
      });
    }
  }

  Future<void> _generateScript() async {
    print('🎬 [Script Generation] Starting script generation...');

    if (_selectedModel == null) {
      print('❌ [Script Generation] No model selected');
      _showError('Please select a model');
      return;
    }

    // Check if model can handle the content
    final selectedModelObj = _availableModels.firstWhere((m) => m.id == _selectedModel);
    print('🎬 [Script Generation] Using model: ${selectedModelObj.name} (${selectedModelObj.id})');
    print('🎬 [Script Generation] Content length: ${widget.content.length} characters');
    print('🎬 [Script Generation] Model context length: ${selectedModelObj.contextLength}');

    if (!_aiService.canHandleContent(widget.content, selectedModelObj.contextLength)) {
      print('❌ [Script Generation] Content too long for model');
      _showError('Content is too long for ${selectedModelObj.name}. Please select a model with larger context window.');
      return;
    }

    setState(() {
      _isGeneratingScript = true;
      _error = null;
    });

    try {
      final category = _categories[_selectedCategory]!;
      print('🎬 [Script Generation] Category: ${category.name}');
      print('🎬 [Script Generation] Provider: $_selectedProvider');

      final basePrompt = _userPromptController.text.trim().isNotEmpty
          ? _userPromptController.text.trim()
          : 'Convert this content into an engaging podcast script conversation.';

      final userPrompt = '''$basePrompt

Speaker Names:
- Speaker 1: ${_speaker1Controller.text}
- Speaker 2: ${_speaker2Controller.text}

Please use these exact speaker names in the script.''';

      print('🎬 [Script Generation] User prompt length: ${userPrompt.length} characters');
      print('🎬 [Script Generation] System prompt length: ${category.systemPrompt.length} characters');

      final script = await _aiService.generateScript(
        provider: _selectedProvider,
        model: _selectedModel!,
        systemPrompt: category.systemPrompt,
        userPrompt: userPrompt,
        content: widget.content,
      );

      print('🎬 [Script Generation] Generated script length: ${script.length} characters');

      if (script.trim().isEmpty) {
        print('❌ [Script Generation] Generated script is empty!');
        _showError('Generated script is empty. Please try again with a different model or check your API keys.');
        setState(() {
          _isGeneratingScript = false;
        });
        return;
      }

      if (mounted) {
        setState(() {
          _isGeneratingScript = false;
        });

        // Extract title from the generated script
        final extractedTitle = _aiService.extractTitleFromScript(script);
        final finalTitle = extractedTitle.isNotEmpty ? extractedTitle : widget.sourceTitle;
        print('🎬 [Script Generation] Extracted title: "$extractedTitle"');
        print('🎬 [Script Generation] Final title: "$finalTitle"');

        // Save the generated script
        final generatedScript = GeneratedScript(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          script: script,
          sourceTitle: finalTitle,
          sourceUrl: widget.sourceUrl,
          category: category.name,
          speaker1: _speaker1Controller.text,
          speaker2: _speaker2Controller.text,
          provider: _selectedProvider,
          model: _selectedModel!,
          generatedAt: DateTime.now(),
        );

        await _storageService.saveGeneratedScript(generatedScript);
        print('🎬 [Script Generation] Script saved successfully');

        // Navigate to script preview screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ScriptPreviewScreen(
              script: script,
              sourceTitle: widget.sourceTitle,
              sourceUrl: widget.sourceUrl,
              category: category.name,
              speaker1: _speaker1Controller.text,
              speaker2: _speaker2Controller.text,
            ),
          ),
        );
        print('🎬 [Script Generation] Navigated to script preview');
      }
    } catch (e) {
      print('❌ [Script Generation] Error: $e');
      if (mounted) {
        setState(() {
          _isGeneratingScript = false;
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

    return Scaffold(
      appBar: const EchoGenAppBar(
        title: 'Generate Script',
        showLogo: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Source Information
            _buildSourceInfo(isDarkMode),
            const SizedBox(height: 24),
            
            // Provider Selection
            _buildProviderSelection(isDarkMode),
            const SizedBox(height: 24),
            
            // Model Selection
            _buildModelSelection(isDarkMode),
            const SizedBox(height: 24),
            
            // Podcast Category
            _buildCategorySelection(isDarkMode),
            const SizedBox(height: 24),
            
            // Speaker Names
            _buildSpeakerNames(isDarkMode),
            const SizedBox(height: 24),
            
            // User Prompt
            _buildUserPrompt(isDarkMode),
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

  Widget _buildSourceInfo(bool isDarkMode) {
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
              Icon(Icons.source, color: AppTheme.primaryBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                'Source Content',
                style: AppTheme.titleMedium.copyWith(
                  color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.sourceTitle,
            style: AppTheme.bodyMedium.copyWith(
              color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.sourceUrl,
            style: AppTheme.bodySmall.copyWith(
              color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.content.length} characters',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.primaryBlue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderSelection(bool isDarkMode) {
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
            value: _selectedProvider,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: _providers.map((provider) {
              return DropdownMenuItem(
                value: provider,
                child: Text(provider),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedProvider = value;
                  _selectedModel = null;
                  _availableModels = [];
                });
                _loadModels();
              }
            },
          ),
        ],
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
            'Model',
            style: AppTheme.titleMedium.copyWith(
              color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          if (_isLoadingModels)
            const Center(child: CircularProgressIndicator())
          else if (_availableModels.isEmpty)
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
                  value: _selectedModel,
                  isExpanded: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: _availableModels.map((model) {
                    final canHandle = _aiService.canHandleContent(widget.content, model.contextLength);
                    return DropdownMenuItem(
                      value: model.id,
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              model.name,
                              style: TextStyle(
                                color: canHandle ? null : AppTheme.secondaryRed,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            Text(
                              '${model.contextLength.toStringAsFixed(0)} tokens',
                              style: TextStyle(
                                fontSize: 12,
                                color: canHandle
                                    ? (Theme.of(context).brightness == Brightness.dark
                                        ? AppTheme.textSecondaryDark
                                        : AppTheme.textSecondary)
                                    : AppTheme.secondaryRed.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedModel = value;
                    });
                  },
                ),
                if (_selectedModel != null) ...[
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Context Length:',
                        style: AppTheme.bodySmall.copyWith(
                          color: isDarkMode ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Builder(
                        builder: (context) {
                          final selectedModelObj = _availableModels.firstWhere((m) => m.id == _selectedModel);
                          final canHandle = _aiService.canHandleContent(widget.content, selectedModelObj.contextLength);
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: canHandle
                                  ? AppTheme.primaryBlue.withOpacity(0.1)
                                  : AppTheme.secondaryRed.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: canHandle
                                    ? AppTheme.primaryBlue.withOpacity(0.3)
                                    : AppTheme.secondaryRed.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              '${selectedModelObj.contextLength} tokens${canHandle ? '' : ' (too small)'}',
                              style: AppTheme.bodySmall.copyWith(
                                color: canHandle ? AppTheme.primaryBlue : AppTheme.secondaryRed,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
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

  Widget _buildCategorySelection(bool isDarkMode) {
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
          ..._categories.entries.map((entry) =>
            _buildCategoryOption(entry.key, entry.value, isDarkMode)
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryOption(String key, PodcastCategory category, bool isDarkMode) {
    final isSelected = _selectedCategory == key;

    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = key),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: TextStyle(
                      color: isSelected ? AppTheme.primaryBlue : (isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category.description,
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

  Widget _buildSpeakerNames(bool isDarkMode) {
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
                  controller: _speaker1Controller,
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
                  controller: _speaker2Controller,
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

  Widget _buildUserPrompt(bool isDarkMode) {
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
            'Additional Instructions (Optional)',
            style: AppTheme.titleMedium.copyWith(
              color: isDarkMode ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _userPromptController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Add any specific instructions for the script generation...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton(bool isDarkMode) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: _isGeneratingScript ? null : _generateScript,
        icon: _isGeneratingScript
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(Icons.auto_awesome, color: Colors.white),
        label: Text(_isGeneratingScript ? 'Generating Script...' : 'Generate Script'),
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

class PodcastCategory {
  final String name;
  final String description;
  final String systemPrompt;

  PodcastCategory({
    required this.name,
    required this.description,
    required this.systemPrompt,
  });
}


