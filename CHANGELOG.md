# Changelog

All notable changes to EchoGen.ai will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Automated GitHub Actions workflows for building and releasing
- Comprehensive issue and PR templates
- Version bump automation

## [0.2.0] - 2025-01-20

### 🎨 Major UI/UX Improvements

#### Enhanced Player Screen
- **Spinning Logo Animation**: Logo now smoothly rotates during audio playback for visual feedback
- **Improved Forward/Backward Buttons**: Enhanced visibility with gradient backgrounds, better icons, and improved styling
- **Horizontal Speed Control**: Speed control now expands horizontally showing all options (0.25x, 0.5x, 0.75x, 1.0x, 1.25x, 1.5x, 2.0x)
- **Transcript Slide View**: Swipe right from player to access full transcript view with mini player controls
- **Removed Audio Wave**: Cleaned up interface by removing the audio wave visualization
- **Darker Progress Bar**: Enhanced progress bar background for better visibility

#### Page Navigation
- **Swipeable Interface**: Seamless page navigation between player and transcript views
- **Page Indicators**: Visual dots showing current page with swipe hints
- **Mini Player**: Compact player controls in transcript view for continuous playback control

### 🖼️ AI-Powered Cover Art Generation

#### ImageRouter Integration
- **Custom Cover Art**: Generate AI-powered podcast cover art using ImageRouter API
- **Multiple AI Models**: Support for DALL-E 3, Stable Diffusion XL, Midjourney, and more
- **Model Selection**: User-selectable AI models with descriptions and capabilities
- **Quality Options**: Choose from auto, low, medium, and high quality settings
- **Size Options**: Multiple aspect ratios (512x512, 1024x1024, 1024x1792, 1792x1024)
- **API Key Management**: Secure storage and validation of ImageRouter API keys
- **Enhanced Prompts**: Automatically optimized prompts for podcast cover art generation
- **Local Storage**: Generated images saved locally for offline access
- **Preview & Edit**: Preview generated covers and regenerate with different settings

### 🎭 Enhanced Script Generation

#### Improved Emotion Handling
- **Tone Guidance System**: Emotions in parentheses now clearly marked as TTS tone guidance only
- **Never Spoken Aloud**: Emotion indicators are used for voice inflection but not read in audio
- **Enhanced Prompts**: All script categories updated with clear emotion handling instructions
- **Better Documentation**: Comprehensive guidance for AI on emotion vs. dialogue separation

### 🔧 Technical Improvements
- **HTTP Support**: Enhanced API communications
- **Shared Preferences**: Improved settings and API key storage
- **Path Provider**: Better file management for generated content
- **Error Handling**: Comprehensive error handling across all new features
- **Performance**: Optimized animations and UI rendering

### 🐛 Bug Fixes
- **Animation Performance**: Improved logo animation performance
- **UI Consistency**: Fixed various UI inconsistencies across screens
- **Memory Leaks**: Resolved potential memory leaks in animation controllers
- **Error States**: Better error state handling and user feedback

## [1.0.0] - 2024-12-19

### Added
- 🎙️ **Core Podcast Generation**: Transform any URL or text into AI-powered podcasts
- 🤖 **Multi-Provider AI Support**: Integration with Gemini, OpenAI, Groq, and OpenRouter
- 🎭 **Multi-Speaker Conversations**: Natural dialogues between two AI speakers
- 🌐 **Web Content Scraping**: Extract content using Firecrawl and HyperbrowserAI
- 🎵 **High-Quality TTS**: 30+ Google TTS voices for professional audio generation
- 📚 **Library Management**: Organize and manage all your generated content
- 🎨 **Modern UI/UX**: Beautiful, responsive interface with dark/light themes
- 📱 **Cross-Platform**: Native Android and iOS applications
- 🔒 **Privacy-First**: All data stored locally, user-controlled API keys
- 📁 **Flexible Storage**: Multiple download folder options including custom paths
- 🎯 **Podcast Categories**: Various styles (Educational, Entertainment, News, etc.)
- 🔊 **Audio Player**: Built-in player with speed controls and progress tracking
- 📝 **Script Viewing**: Review and edit generated scripts before audio creation
- 🎪 **SVG Icon Support**: Professional iconography throughout the app
- ⚙️ **Comprehensive Settings**: API key management and app preferences

### Technical Features
- **Flutter Framework**: Built with Flutter 3.24+ for optimal performance
- **State Management**: Provider pattern for efficient state handling
- **Local Storage**: SharedPreferences and file system integration
- **HTTP Client**: Robust API communication with error handling
- **Audio Processing**: Advanced audio generation and playback capabilities
- **Responsive Design**: Adaptive layouts for all screen sizes
- **Theme System**: Complete dark/light mode implementation

### Supported Platforms
- **Android**: APK and App Bundle builds
- **iOS**: IPA builds with sideloading support

### API Integrations
- **Google Gemini**: Text generation and TTS
- **OpenAI**: GPT models and TTS
- **Groq**: Fast inference for text generation
- **OpenRouter**: Access to multiple AI models
- **Firecrawl**: Web content extraction
- **HyperbrowserAI**: Alternative web scraping

### UI/UX Highlights
- **Playful Design**: Engaging and user-friendly interface
- **Consistent Theming**: Blue color scheme with proper contrast
- **Smooth Animations**: Polished transitions and interactions
- **Accessibility**: Screen reader support and proper contrast ratios
- **Responsive Layout**: Optimized for phones, tablets, and different orientations

### Developer Experience
- **Open Source**: MIT licensed for community contributions
- **Clean Architecture**: Modular, maintainable codebase
- **Comprehensive Documentation**: Detailed README and code comments
- **CI/CD Pipeline**: Automated testing and deployment
- **Issue Templates**: Structured bug reports and feature requests

## [0.1.0] - 2024-12-01

### Added
- Initial project setup
- Basic Flutter application structure
- Core dependencies and configuration

---

## Release Notes Format

### Types of Changes
- **Added** for new features
- **Changed** for changes in existing functionality
- **Deprecated** for soon-to-be removed features
- **Removed** for now removed features
- **Fixed** for any bug fixes
- **Security** for vulnerability fixes

### Emoji Guide
- 🎙️ Podcast/Audio features
- 🤖 AI/ML features
- 🎨 UI/UX improvements
- 🐛 Bug fixes
- ⚡ Performance improvements
- 🔒 Security improvements
- 📱 Platform-specific changes
- 🔧 Technical/Infrastructure changes
- 📚 Documentation updates
- 🧪 Testing improvements

### Version Numbering
- **Major** (X.0.0): Breaking changes, major new features
- **Minor** (0.X.0): New features, backwards compatible
- **Patch** (0.0.X): Bug fixes, small improvements

### Links
- [Unreleased]: https://github.com/Mr-Dark-debug/EchoGen.ai/compare/v1.0.0...HEAD
- [1.0.0]: https://github.com/Mr-Dark-debug/EchoGen.ai/releases/tag/v1.0.0
