# 🎙️ EchoGen.ai

<div align="center">
  <img src="lib/assets/logo.png" alt="EchoGen.ai Logo" width="120" height="120" style="border-radius: 50%;">
  
  **Transform any content into engaging AI-powered podcasts**
  
  [![Build and Release](https://github.com/Mr-Dark-debug/EchoGen.ai/actions/workflows/release.yml/badge.svg)](https://github.com/Mr-Dark-debug/EchoGen.ai/actions/workflows/release.yml)
  [![Flutter](https://img.shields.io/badge/Flutter-3.24+-02569B?style=flat&logo=flutter&logoColor=white)](https://flutter.dev)
  [![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=flat&logo=dart&logoColor=white)](https://dart.dev)
  [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
  [![GitHub Stars](https://img.shields.io/github/stars/Mr-Dark-debug/EchoGen.ai?style=social)](https://github.com/Mr-Dark-debug/EchoGen.ai/stargazers)
  [![GitHub Release](https://img.shields.io/github/v/release/Mr-Dark-debug/EchoGen.ai?style=flat&logo=github)](https://github.com/Mr-Dark-debug/EchoGen.ai/releases/latest)
  
  [🚀 Features](#-features) • [📱 Screenshots](#-screenshots) • [🛠️ Installation](#️-installation) • [🔧 Configuration](#-configuration) • [🤝 Contributing](#-contributing)
</div>

---

## 📖 About

EchoGen.ai is a powerful, open-source Flutter application that transforms any web content or text into engaging, multi-speaker AI-generated podcasts. Whether you're a content creator, educator, or just someone who loves podcasts, EchoGen.ai makes it easy to convert articles, blog posts, or custom scripts into professional-quality audio content.

### 🌟 Why EchoGen.ai?

- **🎯 Content Transformation**: Convert any URL or text into podcast format
- **🤖 AI-Powered**: Leverages cutting-edge AI models (Gemini, OpenAI, Groq)
- **🎭 Multi-Speaker**: Natural conversations between two AI speakers
- **🎨 Beautiful UI**: Modern, intuitive interface with dark/light themes
- **📱 Cross-Platform**: Works on Android, iOS, and desktop
- **🔒 Privacy-First**: All data stored locally on your device
- **🆓 Open Source**: Completely free and open for contributions

## ✨ Features

### 🌐 Content Scraping
- **Web Scraping**: Extract content from any URL using Firecrawl or HyperbrowserAI
- **Smart Parsing**: Automatically extracts main content and metadata
- **Multiple Formats**: Support for articles, blogs, news, and documentation
- **Batch Processing**: Scrape multiple URLs simultaneously

### 🤖 AI-Powered Script Generation
- **Multiple Providers**: Support for Gemini, OpenAI, Groq, and OpenRouter
- **Podcast Categories**: Choose from various styles (Educational, Entertainment, News, etc.)
- **Custom Speakers**: Personalize speaker names and characteristics
- **Smart Formatting**: Automatically formats content for natural conversation

### 🎙️ Text-to-Speech Generation
- **30+ Voices**: Access to Google's premium TTS voices
- **Multi-Speaker**: Realistic conversations between different speakers
- **High Quality**: Professional-grade audio output
- **Custom Settings**: Adjust speed, tone, and speaking style

### 📚 Content Management
- **Library System**: Organize scraped URLs, scripts, and generated podcasts
- **Search & Filter**: Easily find your content
- **Export Options**: Share podcasts or scripts
- **Local Storage**: Everything saved securely on your device

### 🎨 User Experience
- **Modern UI**: Beautiful, intuitive interface
- **Dark/Light Themes**: Comfortable viewing in any environment
- **Responsive Design**: Optimized for all screen sizes
- **Smooth Animations**: Polished interactions and transitions

## 📱 Screenshots

<div align="center">
  <img src="screenshots/home.png" alt="Home Screen" width="200">
  <img src="screenshots/create.png" alt="Create Podcast" width="200">
  <img src="screenshots/player.png" alt="Podcast Player" width="200">
  <img src="screenshots/library.png" alt="Library" width="200">
</div>

## 🛠️ Installation

### Prerequisites

- **Flutter SDK**: 3.7.0 or higher
- **Dart SDK**: 3.0 or higher
- **Android Studio** or **VS Code** with Flutter extensions
- **Android SDK** (for Android development)
- **Xcode** (for iOS development, macOS only)

### Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/Mr-Dark-debug/EchoGen.ai.git
   cd EchoGen.ai
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Building for Production

#### Android APK
```bash
flutter build apk --release
```

#### Android App Bundle
```bash
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release
```

### 🤖 Automated Releases

EchoGen.ai uses GitHub Actions for automated building and releasing:

- **Automatic Builds**: Every push to `main` triggers automated builds for Android and iOS
- **Version Management**: Use the version bump workflow to automatically increment versions
- **Release Creation**: Releases are automatically created with APK, AAB, and IPA files
- **Quality Assurance**: All builds go through automated testing before release

#### Download Latest Release

Visit our [Releases page](https://github.com/Mr-Dark-debug/EchoGen.ai/releases/latest) to download:
- **Android APK**: Direct installation file
- **Android AAB**: Google Play Store format
- **iOS IPA**: For sideloading on iOS devices

## 🔧 Configuration

### API Keys Setup

EchoGen.ai requires API keys for various services. Configure them in the app's settings:

#### Required APIs
- **Google Gemini**: For AI text generation and TTS
  - Get your key: [Google AI Studio](https://makersuite.google.com/app/apikey)
  - Format: `AIza...`

#### Optional APIs
- **OpenAI**: Alternative AI provider
  - Get your key: [OpenAI Platform](https://platform.openai.com/api-keys)
  - Format: `sk-...`

- **Groq**: Fast inference provider
  - Get your key: [Groq Console](https://console.groq.com/keys)
  - Format: `gsk_...`

- **Firecrawl**: Web scraping service
  - Get your key: [Firecrawl](https://firecrawl.dev)
  - Format: `fc-...`

### Environment Setup

1. **Open the app** and navigate to Settings → API Keys
2. **Enter your API keys** for the services you want to use
3. **Test the configuration** by generating a sample podcast

### Permissions

The app requires the following permissions:
- **Storage**: To save podcasts and manage downloads
- **Internet**: To access AI APIs and scrape content
- **Network State**: To check connectivity

## 🎯 Usage

### Creating Your First Podcast

1. **Choose Input Method**:
   - **From URL**: Paste any article or blog URL
   - **From Text**: Write or paste your own content

2. **Configure Settings**:
   - Select AI provider (Gemini recommended)
   - Choose podcast category and style
   - Set speaker names and voices

3. **Generate Script**:
   - AI converts your content into a natural conversation
   - Review and edit the generated script

4. **Create Audio**:
   - Generate high-quality TTS audio
   - Listen to your podcast in the built-in player

5. **Manage Content**:
   - Access all your content in the Library
   - Share, download, or delete podcasts

### Pro Tips

- **Use descriptive speaker names** for better context
- **Choose appropriate categories** for better script generation
- **Review scripts before generating audio** to ensure quality
- **Experiment with different AI providers** for varied results

## 🏗️ Architecture

EchoGen.ai follows a clean, modular architecture:

```
lib/
├── constants/          # App-wide constants and themes
├── models/            # Data models and entities
├── screens/           # UI screens and pages
├── services/          # Business logic and API services
├── widgets/           # Reusable UI components
└── main.dart         # App entry point
```

### Key Components

- **AI Service**: Handles communication with various AI providers
- **TTS Service**: Manages text-to-speech generation
- **Storage Service**: Local data persistence
- **Web Scraping Service**: Content extraction from URLs
- **Theme Provider**: Dark/light theme management

## 🤝 Contributing

We welcome contributions from the community! Here's how you can help:

### Ways to Contribute

- 🐛 **Report Bugs**: Found an issue? Let us know!
- 💡 **Suggest Features**: Have ideas for improvements?
- 🔧 **Submit PRs**: Fix bugs or add new features
- 📖 **Improve Docs**: Help make our documentation better
- 🌍 **Translations**: Help localize the app

### Development Setup

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Make your changes** and test thoroughly
4. **Commit your changes**: `git commit -m 'Add amazing feature'`
5. **Push to the branch**: `git push origin feature/amazing-feature`
6. **Open a Pull Request**

### Code Style

- Follow [Dart style guidelines](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Add comments for complex logic
- Write tests for new features

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Flutter Team**: For the amazing framework
- **Google AI**: For Gemini API and TTS services
- **OpenAI**: For GPT models and APIs
- **Community**: For feedback, contributions, and support

## 🚀 Roadmap

### Upcoming Features
- **🌍 Multi-language Support**: Generate podcasts in multiple languages
- **🎵 Background Music**: Add ambient music to podcasts
- **📊 Analytics**: Track podcast performance and engagement
- **☁️ Cloud Sync**: Optional cloud backup for your content
- **🎨 Custom Themes**: More theme options and customization
- **🔊 Voice Cloning**: Clone your own voice for personalized podcasts
- **📱 Mobile Widgets**: Quick access widgets for mobile devices
- **🎬 Video Podcasts**: Generate video content with AI avatars

### Version History
- **v1.0.0**: Initial release with core features
- **v1.1.0**: Enhanced UI, multi-provider support, improved TTS
- **v1.2.0**: Library management, folder browsing, SVG icons

## 🔧 Troubleshooting

### Common Issues

#### Audio Generation Fails
- **Check API Keys**: Ensure your Gemini API key is valid and has TTS access
- **Network Connection**: Verify you have a stable internet connection
- **Quota Limits**: Check if you've exceeded your API quota

#### App Crashes on Startup
- **Clear Cache**: Go to Settings → Clear Cache
- **Reinstall App**: Uninstall and reinstall the application
- **Check Permissions**: Ensure all required permissions are granted

#### SVG Icons Not Displaying
- **Restart App**: Close and reopen the application
- **Clear Assets**: The app will rebuild asset cache automatically

### Getting Help
1. Check the [FAQ section](https://github.com/Mr-Dark-debug/EchoGen.ai/wiki/FAQ)
2. Search [existing issues](https://github.com/Mr-Dark-debug/EchoGen.ai/issues)
3. Create a [new issue](https://github.com/Mr-Dark-debug/EchoGen.ai/issues/new) with detailed information

## 🌟 Community

Join our growing community of podcast creators and developers:

- **Discord**: [Join our Discord server](https://discord.gg/echogenai) (Coming Soon)
- **Reddit**: [r/EchoGenAI](https://reddit.com/r/echogenai) (Coming Soon)
- **Twitter**: [@EchoGenAI](https://twitter.com/echogenai) (Coming Soon)

## 📊 Stats

<div align="center">
  <img src="https://img.shields.io/github/downloads/Mr-Dark-debug/EchoGen.ai/total?style=for-the-badge&logo=github" alt="Downloads">
  <img src="https://img.shields.io/github/forks/Mr-Dark-debug/EchoGen.ai?style=for-the-badge&logo=github" alt="Forks">
  <img src="https://img.shields.io/github/issues/Mr-Dark-debug/EchoGen.ai?style=for-the-badge&logo=github" alt="Issues">
  <img src="https://img.shields.io/github/license/Mr-Dark-debug/EchoGen.ai?style=for-the-badge" alt="License">
</div>

## 📞 Support

- **GitHub Issues**: [Report bugs or request features](https://github.com/Mr-Dark-debug/EchoGen.ai/issues)
- **Discussions**: [Join community discussions](https://github.com/Mr-Dark-debug/EchoGen.ai/discussions)
- **Sponsor**: [Support development](https://buymeacoffee.com/mrdarkdebug)

---

<div align="center">
  <p>Made with ❤️ by <a href="https://github.com/Mr-Dark-debug">Mr-Dark-debug</a></p>
  <p>⭐ Star this repo if you find it helpful!</p>

  <br>

  <a href="https://github.com/Mr-Dark-debug/EchoGen.ai">
    <img src="https://img.shields.io/badge/GitHub-View%20Source-black?style=for-the-badge&logo=github" alt="View Source">
  </a>
  <a href="https://buymeacoffee.com/mrdarkdebug">
    <img src="https://img.shields.io/badge/Buy%20Me%20A%20Coffee-Support-orange?style=for-the-badge&logo=buy-me-a-coffee" alt="Buy Me A Coffee">
  </a>
</div>
