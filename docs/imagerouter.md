# ImageRouter Integration Guide

This document provides comprehensive information about integrating ImageRouter for AI-powered cover art generation in EchoGenAI.

## Overview

ImageRouter is a unified API that provides access to multiple AI image generation models including DALL-E 3, Stable Diffusion XL, Midjourney, and more. EchoGenAI integrates with ImageRouter to allow users to generate custom podcast cover art.

## Features

- **Multiple AI Models**: Access to various image generation models
- **Quality Control**: Different quality settings for generated images
- **Size Options**: Multiple aspect ratios and resolutions
- **API Key Management**: Secure storage and validation
- **Local Storage**: Generated images saved locally
- **Error Handling**: Comprehensive error handling and user feedback

## Getting Started

### 1. Get an ImageRouter API Key

1. Visit [ImageRouter.io](https://imagerouter.io)
2. Sign up for an account
3. Navigate to your dashboard
4. Generate an API key
5. Note your rate limits and pricing

### 2. Configure in EchoGenAI

1. Open EchoGenAI
2. Navigate to Podcast Generation
3. Look for the "Custom Cover Art" section
4. Click "Generate Cover Art"
5. Enter your ImageRouter API key when prompted
6. The key will be securely stored for future use

## Usage

### Generating Cover Art

1. **Start Podcast Generation**: Begin creating a new podcast
2. **Access Cover Art Section**: Scroll to the "Custom Cover Art" section
3. **Click Generate**: Tap "Generate Cover Art" button
4. **Enter API Key** (first time only): Provide your ImageRouter API key
5. **Customize Prompt**: Describe the cover art you want
6. **Select Model**: Choose from available AI models
7. **Set Quality**: Choose quality level (auto, low, medium, high)
8. **Set Size**: Select aspect ratio and resolution
9. **Generate**: Click "Generate Cover Art"
10. **Preview**: Review the generated image
11. **Use or Regenerate**: Either use the cover or generate a new one

### Available Models

- **DALL-E 3**: High-quality, detailed images with excellent prompt following
- **Stable Diffusion XL**: Fast generation with creative interpretations
- **Midjourney**: Artistic and stylized image generation
- **Additional Models**: More models available based on ImageRouter offerings

### Quality Settings

- **Auto**: Automatically selects optimal quality
- **Low**: Faster generation, lower quality
- **Medium**: Balanced quality and speed
- **High**: Best quality, slower generation

### Size Options

- **512x512**: Square format, good for social media
- **1024x1024**: High-resolution square format
- **1024x1792**: Portrait orientation
- **1792x1024**: Landscape orientation

## Best Practices

### Prompt Writing

1. **Be Specific**: Include details about style, colors, and composition
2. **Mention Podcast**: Reference that it's for a podcast cover
3. **Include Title**: Mention the podcast title for context
4. **Style Keywords**: Use terms like "professional", "modern", "clean"
5. **Avoid Text**: Don't request specific text in the image

### Example Prompts

```
Professional podcast cover art with modern design, vibrant colors, and clean typography. 
Theme related to "Tech Innovation Podcast". Minimalist style with good contrast.
```

```
Artistic podcast cover design featuring abstract technology elements, blue and orange 
color scheme, professional layout suitable for "Future Tech Discussions" podcast.
```

```
Clean, modern podcast cover art with geometric patterns, dark background, bright accent 
colors, professional typography space for "AI and Society" podcast series.
```

## API Integration Details

### Service Architecture

The ImageRouter integration consists of:

- **ImageRouterService**: Main service class handling API communication
- **ImageModel**: Data model for available AI models
- **CoverArtGenerationScreen**: UI for cover art generation
- **Error Handling**: Comprehensive error management

### Key Methods

```dart
// Get available models
Future<List<ImageModel>> getAvailableModels()

// Generate cover art
Future<String?> generateCoverArt({
  required String prompt,
  required String modelId,
  String quality = 'auto',
  String size = '1024x1024',
  String? podcastTitle,
})

// API key management
Future<void> saveApiKey(String apiKey)
Future<String?> getApiKey()
Future<bool> validateApiKey(String apiKey)
```

### Error Handling

The service handles various error scenarios:

- **Invalid API Key**: Clear error message with validation
- **Network Issues**: Retry logic and offline handling
- **Rate Limiting**: User-friendly rate limit messages
- **Generation Failures**: Fallback options and error recovery
- **Storage Issues**: Local storage error handling

## Troubleshooting

### Common Issues

1. **Invalid API Key**
   - Verify the key is correct
   - Check if the key has proper permissions
   - Ensure the key hasn't expired

2. **Generation Failures**
   - Check your prompt for inappropriate content
   - Verify you haven't exceeded rate limits
   - Try a different model or quality setting

3. **Network Issues**
   - Check internet connection
   - Verify ImageRouter service status
   - Try again after a few minutes

4. **Storage Issues**
   - Check device storage space
   - Verify app permissions
   - Clear app cache if needed

### Rate Limits

ImageRouter has rate limits that vary by plan:
- **Free Tier**: Limited requests per minute/hour
- **Paid Plans**: Higher limits based on subscription
- **Monitor Usage**: Check your dashboard regularly

### Cost Management

- **Quality Settings**: Lower quality = lower cost
- **Model Selection**: Different models have different costs
- **Prompt Optimization**: Better prompts reduce regeneration needs
- **Preview Before Use**: Review generated images before accepting

## Security

### API Key Storage

- Keys are stored securely using Flutter's SharedPreferences
- Keys are encrypted at rest
- Keys are never logged or transmitted unnecessarily
- Users can remove keys at any time

### Privacy

- Generated images are stored locally only
- No image data is sent to EchoGenAI servers
- Users have full control over their generated content
- API communication is encrypted (HTTPS)

## Advanced Features

### Batch Generation

Future versions may include:
- Multiple cover art options per podcast
- Batch generation for podcast series
- Template-based generation
- Style consistency across episodes

### Integration with Podcast Metadata

- Automatic prompt enhancement based on podcast content
- Genre-specific style suggestions
- Title and description integration
- Speaker information incorporation

## Support

### Getting Help

1. **Documentation**: Check this guide first
2. **ImageRouter Support**: Contact ImageRouter for API issues
3. **EchoGenAI Issues**: Report bugs via GitHub
4. **Community**: Join our Discord for community support

### Reporting Issues

When reporting issues, include:
- Error messages (without API keys)
- Steps to reproduce
- Device and app version information
- Network conditions

## Future Enhancements

### Planned Features

- **Style Templates**: Pre-defined styles for different podcast genres
- **Brand Integration**: Company logo and brand color integration
- **Series Consistency**: Maintain visual consistency across episodes
- **Advanced Editing**: Basic image editing capabilities
- **Batch Processing**: Generate multiple variations simultaneously

### API Improvements

- **Model Comparison**: Side-by-side model comparisons
- **Cost Estimation**: Real-time cost estimates
- **Usage Analytics**: Track generation history and costs
- **Prompt Suggestions**: AI-powered prompt improvements

## Conclusion

ImageRouter integration provides powerful AI-driven cover art generation capabilities for EchoGenAI users. By following this guide, users can create professional, engaging podcast cover art that enhances their content's visual appeal and brand recognition.

For the latest updates and features, check the EchoGenAI changelog and ImageRouter documentation.
