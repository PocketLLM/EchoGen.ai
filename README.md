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
  
  [🚀 Features](#-features) • [🛣️ Upcoming Features](#-upcoming-features) • [📱 Screenshots](#-screenshots) • [🛠️ Installation](#️-installation) • [🔧 Configuration](#-configuration) • [🌐 Landing Page](#-landing-page) • [🤝 Contributing](#-contributing)
</div>

---

## 📖 About

EchoGen.ai is a powerful, open-source Flutter application that transforms any web content or text into engaging, multi-speaker AI-generated podcasts. Whether you're a content creator, educator, or just someone who loves podcasts, EchoGen.ai makes it easy to convert articles, blog posts, or custom scripts into professional-quality audio content.

### 🌟 Why EchoGen.ai v0.2.1?

- **📱 Android-first studio**: The entire creation journey is tuned for mobile with tactile controls and fast navigation.
- **🛣️ Guided creation timeline**: Move from research to publishing with contextual prompts and confidence checks.
- **🎙️ Voice twin engine**: Blend expressive, multi-speaker narration while keeping emotional cues out of your script copy.
- **🎨 Cinematic cover art**: Generate on-brand visuals with curated palettes and instant refinements.
- **⚡ Speed & stability**: Smarter caching, quicker renders, and resilient error recovery keep production flowing.
- **🛡️ Release safeguards**: Inline health checks verify API keys, storage, and quota limits before you press publish.
- **🆓 Open Source**: Completely free and open for contributions.

## ✨ Features

### 🆕 New in v0.2.1

- **✨ Android home revamp**: Focus views keep research, scripting, and publishing milestones crystal clear on small screens.
- **🧠 Tone guardrails**: Script intelligence separates emotion cues from spoken dialogue to keep narration natural.
- **🎚️ Voice twin tuning**: Improved blending removes abrupt cuts and trims silence automatically.
- **🎨 Cover art palettes**: Curated model presets speed up ideation while staying on-brand.
- **☁️ Offline-first caching**: Larger episode assets sync in the background so you can keep creating on the go.
- **🛡️ Preflight checklist**: Health checks surface missing API keys, low storage, and quota warnings before rendering.

### ✨ Previously in v0.2.0

- **🎵 Background Audio Playback**: Full background audio service with notification controls
- **🎮 Mini Player**: Floating mini player with spinning logo animation across all screens
- **🎨 AI Cover Art Generation**: Generate custom cover art using ImageRouter AI
- **📝 Smart Script Chunking**: Intelligent script splitting to handle long content without timeouts
- **🔑 Centralized API Key Management**: Secure management of all API keys in Settings
- **🎯 Enhanced Loading Experience**: Improved loading messages and progress tracking
- **🔧 Better Error Handling**: More helpful error messages and recovery options
- **🎨 UI/UX Improvements**: Redesigned library cards, better navigation, and visual enhancements

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
- **Emotion Guidance**: Advanced tone control for natural-sounding dialogue
- **Speed Control**: Variable playback speeds (0.25x to 2.0x)

### 🖼️ AI-Powered Cover Art Generation ✨ Introduced in v0.2.0
- **ImageRouter Integration**: Generate custom podcast cover art using AI
- **Multiple AI Models**: Support for DALL-E 3, Stable Diffusion XL, Midjourney
- **Quality Options**: Choose from auto, low, medium, and high quality
- **Size Options**: Multiple aspect ratios for different platforms
- **Local Storage**: Generated covers saved locally for offline access

### 🎨 Enhanced Player Experience ✨ Introduced in v0.2.0
- **Spinning Logo Animation**: Visual feedback during playback
- **Transcript Slide View**: Swipe to access full transcript with mini player
- **Horizontal Speed Control**: Expanded speed options with visual selection
- **Improved Controls**: Enhanced forward/backward buttons with better visibility
- **Page Navigation**: Seamless swipe navigation between player and transcript
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

## 🛣️ Upcoming Features

- **Live Collaboration**: Real-time co-editing of scripts, cover prompts, and publishing notes
- **Voice Marketplace**: Curated library of expressive voices sourced from community partners
- **Automated Distribution**: One-click syndication to Spotify, Apple Podcasts, and RSS feeds
- **Interactive Chapters**: Dynamic chapter markers with shareable highlights and key takeaways
- **Accessibility Studio**: Auto-captioning, transcript export, and audio leveling for inclusive listening

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

#### 🤖 Automated Releases (Recommended)

EchoGen.ai uses GitHub Actions for automated building and releasing. Every push to `main` triggers automated builds:

- **Automatic Builds**: Android APK, AAB, and iOS archives
- **Version Management**: Automatic version detection from `pubspec.yaml`
- **Release Creation**: Automated GitHub releases with downloadable assets
- **Quality Assurance**: Automated testing and analysis

#### 🔨 Manual Release Builds

**Android APK (Universal)**
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

**Android App Bundle (Google Play Store)**
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

**iOS (Requires macOS)**
```bash
flutter build ios --release
# For App Store distribution, use Xcode to archive and upload
```

**Web (Progressive Web App)**
```bash
flutter build web --release
# Output: build/web/
```

**Windows (Requires Windows)**
```bash
flutter build windows --release
# Output: build/windows/runner/Release/
```

**macOS (Requires macOS)**
```bash
flutter build macos --release
# Output: build/macos/Build/Products/Release/
```

**Linux (Requires Linux)**
```bash
flutter build linux --release
# Output: build/linux/x64/release/bundle/
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
- **OpenAI**: Alternative AI provider and TTS
  - Get your key: [OpenAI Platform](https://platform.openai.com/api-keys)
  - Format: `sk-...`

- **ElevenLabs**: Premium TTS provider
  - Get your key: [ElevenLabs](https://elevenlabs.io)
  - Format: Various formats supported

- **ImageRouter**: AI cover art generation
  - Get your key: [ImageRouter](https://imagerouter.io)
  - Format: Various formats supported (no specific prefix required)

- **Groq**: Fast inference provider
  - Get your key: [Groq Console](https://console.groq.com/keys)
  - Format: `gsk_...`

- **Firecrawl**: Web scraping service
  - Get your key: [Firecrawl](https://firecrawl.dev)
  - Format: `fc-...`

- **HyperbrowserAI**: Alternative web scraping
  - Get your key: [HyperbrowserAI](https://hyperbrowser.ai)
  - Format: Various formats supported

### Environment Setup

1. **Open the app** and navigate to Settings → API Keys
2. **Enter your API keys** for the services you want to use
3. **Test the configuration** by generating a sample podcast

### Permissions

The app requires the following permissions:
- **Storage**: To save podcasts and manage downloads
- **Internet**: To access AI APIs and scrape content
- **Network State**: To check connectivity

## 🌐 Landing Page

EchoGen.ai features a beautiful landing page hosted on GitHub Pages that showcases the app's features and provides download links.

### 🔗 Live Demo

**Visit the landing page**: [https://mr-dark-debug.github.io/EchoGen.ai/](https://mr-dark-debug.github.io/EchoGen.ai/)

### 🛠️ GitHub Pages Setup

The landing page is automatically deployed to GitHub Pages from the `docs/` folder:

1. **Source File**: `landing.html` (main project directory)
2. **Deployed As**: `docs/index.html` (GitHub Pages source)
3. **Live URL**: `https://[username].github.io/[repository-name]/`

#### Setting Up GitHub Pages

1. **Repository Settings**:
   - Go to your repository on GitHub
   - Navigate to **Settings** → **Pages**
   - Under **Source**, select **Deploy from a branch**
   - Choose **main** branch and **/ (root)** folder
   - Save the settings

2. **Automatic Deployment**:
   - Any changes to `docs/index.html` will automatically deploy
   - GitHub Actions can be configured for advanced deployment workflows
   - The site typically updates within 5-10 minutes

#### Landing Page Features

- **Responsive Design**: Works perfectly on desktop, tablet, and mobile
- **Modern UI**: Clean, professional design with smooth animations
- **Feature Showcase**: Highlights all major app features
- **Direct Downloads**: Links to latest GitHub releases
- **Social Links**: GitHub, Product Hunt, and other social platforms
- **Fast Loading**: Optimized images and minimal dependencies

#### Customizing the Landing Page

1. **Edit Content**: Modify `landing.html` in the project root
2. **Update Assets**: Replace images in `lib/assets/` (uses GitHub raw URLs)
3. **Deploy Changes**: Copy updated `landing.html` to `docs/index.html`
4. **Test Locally**: Open `landing.html` in a browser before deploying

```bash
# Quick deployment command
cp landing.html docs/index.html
git add docs/index.html
git commit -m "Update landing page"
git push origin main
```

#### 📊 SEO & Performance

The landing page includes:
- **SEO Optimized**: Meta tags, structured data, and semantic HTML
- **Performance**: Lightweight design with fast loading times
- **Accessibility**: WCAG guidelines compliance
- **Mobile First**: Responsive design for all devices

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

### ✅ Latest Release
- **v0.2.1**: Android-first studio polish, tone guardrails, voice twin tuning, cover art palettes, and offline-first caching boosts

### 🛠️ In Progress
- **Live Collaboration**: Multiplayer editing with inline comments and suggestions
- **Voice Marketplace**: Curated voice packs, marketplace submissions, and licensing controls
- **Automated Distribution**: Publish directly to major podcast networks and custom RSS feeds

### 🔮 On the Horizon
- **Interactive Chapters**: Audience-ready chapter markers, polls, and highlight reels
- **Accessibility Studio**: Auto-captioning, loudness normalization, and transcript export suites
- **Immersive Video Mode**: Optional video layers, AI avatars, and audiogram templates

### Version History
- **v0.2.1**: Android studio revamp, tone guardrails, voice twin tuning, cover art palettes, offline-first caching
- **v0.2.0**: Background audio playback, AI cover art generation, smart script chunking, centralized API management, enhanced UI/UX
- **v0.1.0**: Initial release with core features

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
