#!/bin/bash

# EchoGen.ai Version Bump Script
# Usage: ./scripts/bump_version.sh [patch|minor|major]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_color() {
    printf "${1}${2}${NC}\n"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [patch|minor|major]"
    echo ""
    echo "Version bump types:"
    echo "  patch  - Bug fixes and small improvements (1.0.0 -> 1.0.1)"
    echo "  minor  - New features, backwards compatible (1.0.0 -> 1.1.0)"
    echo "  major  - Breaking changes (1.0.0 -> 2.0.0)"
    echo ""
    echo "Example: $0 patch"
    exit 1
}

# Check if argument is provided
if [ $# -eq 0 ]; then
    print_color $RED "Error: No version bump type specified"
    show_usage
fi

BUMP_TYPE=$1

# Validate bump type
if [[ ! "$BUMP_TYPE" =~ ^(patch|minor|major)$ ]]; then
    print_color $RED "Error: Invalid bump type '$BUMP_TYPE'"
    show_usage
fi

# Check if we're in the project root
if [ ! -f "pubspec.yaml" ]; then
    print_color $RED "Error: pubspec.yaml not found. Please run this script from the project root."
    exit 1
fi

# Check if git is clean
if [ -n "$(git status --porcelain)" ]; then
    print_color $YELLOW "Warning: You have uncommitted changes. Please commit or stash them first."
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

print_color $BLUE "🚀 Starting version bump process..."

# Get current version from pubspec.yaml
CURRENT_VERSION=$(grep '^version: ' pubspec.yaml | cut -d ' ' -f 2 | cut -d '+' -f 1)
CURRENT_BUILD=$(grep '^version: ' pubspec.yaml | cut -d '+' -f 2)

print_color $BLUE "📦 Current version: $CURRENT_VERSION+$CURRENT_BUILD"

# Calculate new version
IFS='.' read -ra VERSION_PARTS <<< "$CURRENT_VERSION"
MAJOR=${VERSION_PARTS[0]}
MINOR=${VERSION_PARTS[1]}
PATCH=${VERSION_PARTS[2]}

case $BUMP_TYPE in
    "major")
        MAJOR=$((MAJOR + 1))
        MINOR=0
        PATCH=0
        ;;
    "minor")
        MINOR=$((MINOR + 1))
        PATCH=0
        ;;
    "patch")
        PATCH=$((PATCH + 1))
        ;;
esac

NEW_VERSION="$MAJOR.$MINOR.$PATCH"
NEW_BUILD=$((CURRENT_BUILD + 1))

print_color $GREEN "📦 New version: $NEW_VERSION+$NEW_BUILD"

# Confirm with user
read -p "Proceed with version bump? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_color $YELLOW "Version bump cancelled."
    exit 0
fi

# Update pubspec.yaml
print_color $BLUE "📝 Updating pubspec.yaml..."
sed -i.bak "s/^version: .*/version: $NEW_VERSION+$NEW_BUILD/" pubspec.yaml
rm pubspec.yaml.bak

# Update CHANGELOG.md
print_color $BLUE "📝 Updating CHANGELOG.md..."
TODAY=$(date +%Y-%m-%d)
sed -i.bak "s/## \[Unreleased\]/## [Unreleased]\n\n## [$NEW_VERSION] - $TODAY/" CHANGELOG.md
rm CHANGELOG.md.bak

# Update README.md version history
print_color $BLUE "📝 Updating README.md..."
sed -i.bak "/### Version History/a\\
- **v$NEW_VERSION**: Latest release with new features and improvements" README.md
rm README.md.bak

# Git operations
print_color $BLUE "📝 Creating git commit and tag..."
git add pubspec.yaml CHANGELOG.md README.md
git commit -m "🔖 Bump version to v$NEW_VERSION

- Updated version in pubspec.yaml to $NEW_VERSION+$NEW_BUILD
- Updated CHANGELOG.md with release date
- Updated README.md version history"

git tag -a "v$NEW_VERSION" -m "Release v$NEW_VERSION"

print_color $GREEN "✅ Version bump completed successfully!"
print_color $BLUE "📋 Summary:"
print_color $BLUE "  - Version: $CURRENT_VERSION -> $NEW_VERSION"
print_color $BLUE "  - Build: $CURRENT_BUILD -> $NEW_BUILD"
print_color $BLUE "  - Tag: v$NEW_VERSION created"

print_color $YELLOW "🚀 Next steps:"
print_color $YELLOW "  1. Review the changes: git show"
print_color $YELLOW "  2. Push to remote: git push origin main --tags"
print_color $YELLOW "  3. GitHub Actions will automatically build and create a release"

print_color $BLUE "🔗 Useful commands:"
print_color $BLUE "  - View tags: git tag -l"
print_color $BLUE "  - View commit: git show v$NEW_VERSION"
print_color $BLUE "  - Push changes: git push origin main --tags"
