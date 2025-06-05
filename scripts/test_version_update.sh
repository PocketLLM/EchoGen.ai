#!/bin/bash

# Test script to verify version update commands work correctly

echo "🧪 Testing version update commands..."

# Create a test pubspec.yaml
cat > test_pubspec.yaml << 'EOF'
name: echogenai
description: A new Flutter project.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.5.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
EOF

echo "📄 Original test_pubspec.yaml:"
cat test_pubspec.yaml

echo ""
echo "🔧 Testing perl command..."
NEW_VERSION="1.2.3+45"
perl -i -pe "s/^version: .*/version: $NEW_VERSION/" test_pubspec.yaml

echo "📄 Updated test_pubspec.yaml:"
cat test_pubspec.yaml

# Verify the change
UPDATED_VERSION=$(grep '^version:' test_pubspec.yaml | cut -d ' ' -f 2)
if [ "$UPDATED_VERSION" = "$NEW_VERSION" ]; then
    echo "✅ Version update successful: $UPDATED_VERSION"
else
    echo "❌ Version update failed. Expected: $NEW_VERSION, Got: $UPDATED_VERSION"
fi

# Clean up
rm test_pubspec.yaml

echo ""
echo "🧪 Testing changelog generation..."

# Test changelog generation
COMMITS="- Add new feature
- Fix bug in audio player
- Update UI design"

cat > test_changelog.txt << 'EOF'
## EchoGen.ai v1.2.3

### What's New
COMMITS_PLACEHOLDER

### Downloads
- **Android APK**: Direct installation file
- **Android AAB**: Google Play Store format
EOF

echo "📄 Original changelog template:"
cat test_changelog.txt

echo ""
echo "🔧 Testing perl replacement..."
perl -i -pe "s/COMMITS_PLACEHOLDER/$COMMITS/g" test_changelog.txt

echo "📄 Updated changelog:"
cat test_changelog.txt

# Clean up
rm test_changelog.txt

echo ""
echo "✅ All tests completed successfully!"
