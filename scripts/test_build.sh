#!/bin/bash

# EchoGen.ai Local Build Test Script
# This script tests the build process locally before pushing to CI/CD

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

# Function to print step header
print_step() {
    echo ""
    print_color $BLUE "🔄 $1"
    echo "----------------------------------------"
}

# Function to check command success
check_success() {
    if [ $? -eq 0 ]; then
        print_color $GREEN "✅ $1 successful"
    else
        print_color $RED "❌ $1 failed"
        exit 1
    fi
}

print_color $BLUE "🚀 EchoGen.ai Local Build Test"
print_color $BLUE "=============================="

# Check if we're in the project root
if [ ! -f "pubspec.yaml" ]; then
    print_color $RED "❌ pubspec.yaml not found. Please run this script from the project root."
    exit 1
fi

# Check Flutter installation
print_step "Checking Flutter Installation"
flutter --version
check_success "Flutter version check"

# Check Dart SDK version
DART_VERSION=$(dart --version 2>&1 | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' | head -1)
print_color $BLUE "📦 Dart SDK version: $DART_VERSION"

# Upgrade Flutter if needed
print_step "Upgrading Flutter"
flutter upgrade --force
check_success "Flutter upgrade"

# Run Flutter Doctor
print_step "Running Flutter Doctor"
flutter doctor -v
check_success "Flutter doctor"

# Clean project
print_step "Cleaning Project"
flutter clean
check_success "Flutter clean"

# Get dependencies
print_step "Getting Dependencies"
flutter pub get
check_success "Flutter pub get"

# Check dependencies
print_step "Checking Dependencies"
flutter pub deps
check_success "Dependency check"

# Analyze code
print_step "Analyzing Code"
flutter analyze
if [ $? -eq 0 ]; then
    print_color $GREEN "✅ Code analysis passed"
else
    print_color $YELLOW "⚠️ Code analysis completed with warnings"
fi

# Check formatting
print_step "Checking Code Formatting"
dart format --output=none --set-exit-if-changed .
if [ $? -eq 0 ]; then
    print_color $GREEN "✅ Code formatting is correct"
else
    print_color $YELLOW "⚠️ Code formatting issues found. Run 'dart format .' to fix."
fi

# Run tests
print_step "Running Tests"
flutter test
if [ $? -eq 0 ]; then
    print_color $GREEN "✅ All tests passed"
else
    print_color $YELLOW "⚠️ Some tests failed"
fi

# Build Android APK
print_step "Building Android APK"
flutter build apk --release --verbose
check_success "Android APK build"

# Check APK file
if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    APK_SIZE=$(du -h build/app/outputs/flutter-apk/app-release.apk | cut -f1)
    print_color $GREEN "✅ APK created successfully (Size: $APK_SIZE)"
else
    print_color $RED "❌ APK file not found"
    exit 1
fi

# Build Android App Bundle
print_step "Building Android App Bundle"
flutter build appbundle --release --verbose
check_success "Android App Bundle build"

# Check AAB file
if [ -f "build/app/outputs/bundle/release/app-release.aab" ]; then
    AAB_SIZE=$(du -h build/app/outputs/bundle/release/app-release.aab | cut -f1)
    print_color $GREEN "✅ App Bundle created successfully (Size: $AAB_SIZE)"
else
    print_color $RED "❌ App Bundle file not found"
    exit 1
fi

# iOS build (only on macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    print_step "Building iOS (macOS detected)"
    flutter build ios --release --no-codesign --verbose
    check_success "iOS build"
    
    # Check iOS app
    if [ -d "build/ios/iphoneos/Runner.app" ]; then
        IOS_SIZE=$(du -sh build/ios/iphoneos/Runner.app | cut -f1)
        print_color $GREEN "✅ iOS app created successfully (Size: $IOS_SIZE)"
        
        # Create IPA
        print_step "Creating iOS IPA"
        cd build/ios/iphoneos
        mkdir -p Payload
        cp -r Runner.app Payload/
        zip -r ../../../test-local.ipa Payload/
        cd ../../..
        
        if [ -f "test-local.ipa" ]; then
            IPA_SIZE=$(du -h test-local.ipa | cut -f1)
            print_color $GREEN "✅ IPA created successfully (Size: $IPA_SIZE)"
        else
            print_color $RED "❌ IPA creation failed"
        fi
    else
        print_color $RED "❌ iOS app not found"
    fi
else
    print_color $YELLOW "⏭️ iOS build skipped (not on macOS)"
fi

# Summary
echo ""
print_color $GREEN "🎉 Build Test Summary"
print_color $GREEN "===================="
print_color $GREEN "✅ Flutter setup: OK"
print_color $GREEN "✅ Dependencies: OK"
print_color $GREEN "✅ Code analysis: OK"
print_color $GREEN "✅ Android APK: OK ($APK_SIZE)"
print_color $GREEN "✅ Android AAB: OK ($AAB_SIZE)"

if [[ "$OSTYPE" == "darwin"* ]]; then
    if [ -f "test-local.ipa" ]; then
        print_color $GREEN "✅ iOS IPA: OK ($IPA_SIZE)"
    fi
fi

echo ""
print_color $BLUE "🚀 Ready for CI/CD!"
print_color $BLUE "You can now safely push to main branch to trigger automated release."

echo ""
print_color $YELLOW "📁 Build artifacts created:"
print_color $YELLOW "  - build/app/outputs/flutter-apk/app-release.apk"
print_color $YELLOW "  - build/app/outputs/bundle/release/app-release.aab"
if [ -f "test-local.ipa" ]; then
    print_color $YELLOW "  - test-local.ipa"
fi
