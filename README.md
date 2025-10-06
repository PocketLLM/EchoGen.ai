# 🎙️ EchoGen.ai

<p align="center">
  <img src="lib/assets/logo.png" alt="EchoGen.ai Logo" width="120" height="120" style="border-radius: 50%;" />
</p>

<p align="center">
  <strong>AI-assisted podcast production from research to release — all on your device.</strong>
</p>

<p align="center">
  <a href="https://github.com/Mr-Dark-debug/EchoGen.ai/actions/workflows/release.yml"><img src="https://github.com/Mr-Dark-debug/EchoGen.ai/actions/workflows/release.yml/badge.svg" alt="Build Status" /></a>
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.24+-02569B?style=flat&logo=flutter&logoColor=white" alt="Flutter" /></a>
  <a href="https://dart.dev"><img src="https://img.shields.io/badge/Dart-3.0+-0175C2?style=flat&logo=dart&logoColor=white" alt="Dart" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-green.svg" alt="MIT License" /></a>
  <a href="https://github.com/Mr-Dark-debug/EchoGen.ai/stargazers"><img src="https://img.shields.io/github/stars/Mr-Dark-debug/EchoGen.ai?style=social" alt="GitHub Stars" /></a>
  <a href="https://github.com/Mr-Dark-debug/EchoGen.ai/releases/latest"><img src="https://img.shields.io/github/v/release/Mr-Dark-debug/EchoGen.ai?style=flat&logo=github" alt="Latest Release" /></a>
</p>

---

## 📚 Table of Contents
- [Overview](#-overview)
- [Product Highlights](#-product-highlights)
- [Feature Deep Dive](#-feature-deep-dive)
- [Architecture](#-architecture)
- [Getting Started](#-getting-started)
- [Configuration](#-configuration)
- [Build & Release](#-build--release)
- [Screenshots](#-screenshots)
- [Roadmap](#-roadmap)
- [Landing Page](#-landing-page)
- [Contributing](#-contributing)

## 🔎 Overview
EchoGen.ai is an open-source Flutter studio for transforming articles, notes, or research into cinematic podcasts. A guided creation timeline walks you from content discovery to multi-speaker narration, with AI models orchestrated behind the scenes. Whether you’re a solo creator or an editorial team, EchoGen.ai keeps production fast, tactile, and mobile-first.

> **Current Release:** `v0.2.1`

## 🌟 Product Highlights
- **Android-first creative studio** – Designed for thumb-friendly navigation, quick scrubbing, and offline-friendly workflows.
- **Guided production timeline** – Structured steps keep research, scripting, and publishing aligned.
- **Voice twin engine** – Blend expressive speakers while preserving narrative tone.
- **Cinematic cover art** – Curated palettes and AI image routes for on-brand visuals.
- **Health & stability guardrails** – Inline checks surface API, quota, and storage issues before render time.
- **Fully open source** – MIT licensed with a growing contributor community.

## 🧭 Feature Deep Dive

### Creation Workflow
- **Content ingestion** via Firecrawl or HyperbrowserAI with smart parsing and batch URL support.
- **Script generation** using Gemini, OpenAI, Groq, or OpenRouter with tone guardrails and conversational formatting.
- **Timeline tracking** that keeps milestones visible across research, scripting, cover art, and publishing.

### Audio Production
- **Multi-speaker TTS** leveraging premium Google voices and optional ElevenLabs models.
- **Emotion-aware guidance** to keep narration natural without overscripting.
- **Mini player & background audio** with notification controls, waveform animation, and transcript sync.

### Visual Identity
- **AI cover art generator** powered by ImageRouter with presets for DALL·E 3, SDXL, and Midjourney styles.
- **Palette presets & refinements** for fast iteration and on-brand consistency.

### Library & Sharing
- **Structured library system** to manage scraped URLs, scripts, and rendered episodes.
- **Search, filter, and export** tools for sharing scripts or podcast files.
- **Offline-first caching** keeps large assets available even without connectivity.

## 🏗 Architecture
- **Flutter Client (`lib/`)** – Providers manage auth, theming, and global audio state. Services wrap AI, scraping, and storage integrations while widgets deliver a polished mobile UI.
- **FastAPI Backend (`backend/`)** – REST APIs manage auth, Supabase persistence, job orchestration, and integration secrets.
- **Landing Experience (`docs/`, `landing.html`)** – Lightweight marketing site deployed to GitHub Pages.

Dive deeper in [`AGENTS.md`](AGENTS.md) for a guided tour of the codebase.

## 🚀 Getting Started

### Prerequisites
- Flutter SDK **3.7.0+**
- Dart SDK **3.0+**
- Android Studio or VS Code with Flutter extensions
- Android SDK (for Android builds)
- Xcode (for iOS builds on macOS)

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

## 🛠 Configuration

### API Keys
Configure provider keys from **Settings → API Keys** inside the app.

| Provider | Purpose | Where to obtain | Key format |
| --- | --- | --- | --- |
| Google Gemini | Script generation & TTS | [Google AI Studio](https://makersuite.google.com/app/apikey) | `AIza...` |
| OpenAI (optional) | Alternate LLM & TTS | [OpenAI Platform](https://platform.openai.com/api-keys) | `sk-...` |
| ElevenLabs (optional) | Premium voices | [ElevenLabs](https://elevenlabs.io) | Various |
| ImageRouter (optional) | AI cover art | [ImageRouter](https://imagerouter.io) | Various |
| Groq (optional) | Fast LLM inference | [Groq Console](https://console.groq.com/keys) | `gsk_...` |
| Firecrawl (optional) | Web scraping | [Firecrawl](https://firecrawl.dev) | `fc-...` |
| HyperbrowserAI (optional) | Alternate scraping | [HyperbrowserAI](https://hyperbrowser.ai) | Various |

After adding keys, generate a sample episode to validate the configuration. Required permissions include **Storage**, **Internet**, and **Network State**.

## 🛠️ Build & Release

### Manual Builds
```bash
# Universal Android APK
flutter build apk --release

# Google Play App Bundle
flutter build appbundle --release

# iOS (run on macOS)
flutter build ios --release

# Progressive Web App
flutter build web --release

# Desktop Targets
flutter build windows --release
flutter build macos --release
flutter build linux --release
```

### Continuous Delivery
Automated GitHub Actions workflows handle version bumps, testing, and packaging for Android and iOS on every push to `main`. Visit the [latest release](https://github.com/Mr-Dark-debug/EchoGen.ai/releases/latest) for downloadable APK, AAB, and IPA artifacts.

## 📱 Screenshots
<p align="center">
  <img src="screenshots/home.png" alt="Home Screen" width="200" />
  <img src="screenshots/create.png" alt="Create Podcast" width="200" />
  <img src="screenshots/player.png" alt="Podcast Player" width="200" />
  <img src="screenshots/library.png" alt="Library" width="200" />
</p>

## 🛣 Roadmap
- Live collaboration on scripts, prompts, and publishing notes.
- Voice marketplace featuring community-curated narration styles.
- Automated distribution to Spotify, Apple Podcasts, and RSS feeds.
- Interactive chapters with shareable highlights and key takeaways.
- Accessibility studio with transcripts, captions, and audio leveling.

Track detailed progress in [`TASKS.md`](TASKS.md).

## 🌐 Landing Page
Experience EchoGen.ai in your browser: **[mr-dark-debug.github.io/EchoGen.ai](https://mr-dark-debug.github.io/EchoGen.ai/)**

GitHub Pages deploys directly from `docs/index.html`. Update `landing.html`, copy changes into `docs/index.html`, and push to `main` for an instant refresh.

## 🤝 Contributing
We welcome new ideas, bug fixes, and integrations! Open an issue to discuss your proposal, then submit a pull request following the existing architecture patterns. Run `flutter analyze`, add tests where possible, and document user-facing changes.

---

Made with ❤️ by the EchoGen.ai community.
