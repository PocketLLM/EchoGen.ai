# 🚀 EchoGen.ai Release Process

This document outlines the automated and manual release processes for EchoGen.ai.

## 🤖 Automated Release Process

### Overview
EchoGen.ai uses GitHub Actions to automatically build and release the app whenever changes are pushed to the main branch or when a new tag is created.

### Workflow Triggers
- **Push to main branch**: Triggers build and release
- **New tag creation**: Triggers build and release
- **Pull request**: Triggers build and test (no release)

### What Gets Built
1. **Android APK**: Direct installation file for Android devices
2. **Android AAB**: App Bundle for Google Play Store distribution
3. **iOS IPA**: Installation file for iOS devices (requires sideloading)

### Automated Steps
1. **Version Detection**: Extracts version from `pubspec.yaml`
2. **Build Android**: Compiles APK and AAB files
3. **Build iOS**: Compiles IPA file (unsigned)
4. **Run Tests**: Executes all unit tests
5. **Create Release**: Automatically creates GitHub release with:
   - Release notes generated from commit messages
   - All build artifacts attached
   - Proper versioning and tagging

## 📋 Manual Release Process

### Prerequisites
- Git repository with clean working directory
- Flutter SDK installed and configured
- Proper permissions to push to main branch

### Step 1: Version Bump

#### Option A: Using GitHub Actions (Recommended)
1. Go to GitHub Actions tab
2. Select "Version Bump" workflow
3. Click "Run workflow"
4. Choose version bump type (patch/minor/major)
5. Review and merge the created pull request

#### Option B: Using Local Scripts
```bash
# Linux/macOS
./scripts/bump_version.sh patch

# Windows
scripts\bump_version.bat patch
```

#### Option C: Manual Version Bump
1. Update version in `pubspec.yaml`:
   ```yaml
   version: 1.2.3+45
   ```
2. Update `CHANGELOG.md` with new version and date
3. Update `README.md` version history
4. Commit changes:
   ```bash
   git add pubspec.yaml CHANGELOG.md README.md
   git commit -m "🔖 Bump version to v1.2.3"
   git tag -a "v1.2.3" -m "Release v1.2.3"
   ```

### Step 2: Push and Release
```bash
git push origin main --tags
```

This will trigger the automated build and release process.

## 📦 Release Artifacts

### Android APK
- **File**: `EchoGenAI-Android-v{version}.apk`
- **Purpose**: Direct installation on Android devices
- **Installation**: Enable "Unknown sources" and install APK

### Android App Bundle (AAB)
- **File**: `EchoGenAI-Android-v{version}.aab`
- **Purpose**: Google Play Store distribution
- **Usage**: Upload to Google Play Console

### iOS IPA
- **File**: `EchoGenAI-iOS-v{version}.ipa`
- **Purpose**: iOS device installation
- **Installation**: Use AltStore, Sideloadly, or similar tools

## 🔄 Version Numbering

### Semantic Versioning
We follow [Semantic Versioning](https://semver.org/):
- **MAJOR.MINOR.PATCH+BUILD**
- Example: `1.2.3+45`

### Version Types
- **Major** (1.0.0 → 2.0.0): Breaking changes
- **Minor** (1.0.0 → 1.1.0): New features, backwards compatible
- **Patch** (1.0.0 → 1.0.1): Bug fixes, small improvements
- **Build** (+1 → +2): Automatic increment based on commit count

### When to Bump
- **Patch**: Bug fixes, small UI improvements, dependency updates
- **Minor**: New features, new AI providers, major UI changes
- **Major**: Breaking API changes, major architecture changes

## 📝 Release Notes

### Automatic Generation
Release notes are automatically generated from:
- Commit messages since last release
- Predefined template with download instructions
- Installation guides for each platform

### Manual Enhancement
After release creation, you can:
1. Edit the release on GitHub
2. Add screenshots or videos
3. Highlight important changes
4. Add migration guides for breaking changes

## 🧪 Testing Before Release

### Automated Testing
- Unit tests run automatically
- Build tests for all platforms
- Code analysis and formatting checks

### Manual Testing Checklist
- [ ] Test core podcast generation functionality
- [ ] Verify all AI providers work correctly
- [ ] Test audio playback and controls
- [ ] Check UI in both light and dark modes
- [ ] Test on different screen sizes
- [ ] Verify download and sharing features
- [ ] Test settings and API key management

## 🚨 Hotfix Process

For critical bugs that need immediate release:

1. **Create hotfix branch**:
   ```bash
   git checkout -b hotfix/v1.2.4 main
   ```

2. **Fix the issue and test**

3. **Bump patch version**:
   ```bash
   ./scripts/bump_version.sh patch
   ```

4. **Merge to main**:
   ```bash
   git checkout main
   git merge hotfix/v1.2.4
   git push origin main --tags
   ```

5. **Delete hotfix branch**:
   ```bash
   git branch -d hotfix/v1.2.4
   ```

## 🔧 Troubleshooting

### Build Failures
1. Check GitHub Actions logs
2. Verify all dependencies are compatible
3. Ensure version format is correct in `pubspec.yaml`
4. Check for any missing files or permissions

### Release Not Created
1. Verify the tag was pushed correctly
2. Check if the workflow has proper permissions
3. Ensure `GITHUB_TOKEN` has release permissions

### iOS Build Issues
1. iOS builds are unsigned and for sideloading only
2. For App Store distribution, additional signing is required
3. Check iOS deployment target compatibility

## 📊 Release Metrics

### Tracking Success
- Download counts from GitHub releases
- User feedback and issue reports
- Crash reports and analytics
- Performance metrics

### Post-Release Monitoring
- Monitor GitHub issues for bug reports
- Check app performance and stability
- Gather user feedback and feature requests
- Plan next release based on feedback

## 🔗 Related Documentation

- [Contributing Guidelines](../CONTRIBUTING.md)
- [Issue Templates](../.github/ISSUE_TEMPLATE/)
- [Pull Request Template](../.github/pull_request_template.md)
- [Release Template](../.github/RELEASE_TEMPLATE.md)
- [Changelog](../CHANGELOG.md)

## 📞 Support

If you encounter issues with the release process:
1. Check existing [GitHub Issues](https://github.com/Mr-Dark-debug/EchoGen.ai/issues)
2. Create a new issue with the "build" or "release" label
3. Contact the maintainers directly

---

**Remember**: Every push to main triggers a release, so ensure your changes are ready for production!
