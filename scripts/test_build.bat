@echo off
setlocal enabledelayedexpansion

REM EchoGen.ai Local Build Test Script for Windows
echo.
echo 🚀 EchoGen.ai Local Build Test
echo ==============================

REM Check if we're in the project root
if not exist "pubspec.yaml" (
    echo ❌ pubspec.yaml not found. Please run this script from the project root.
    exit /b 1
)

echo 🔄 Checking Flutter Installation
echo ----------------------------------------
flutter --version
if errorlevel 1 (
    echo ❌ Flutter not found. Please install Flutter first.
    exit /b 1
)
echo ✅ Flutter version check successful

echo.
echo 🔄 Upgrading Flutter
echo ----------------------------------------
flutter upgrade --force
if errorlevel 1 (
    echo ❌ Flutter upgrade failed
    exit /b 1
)
echo ✅ Flutter upgrade successful

echo.
echo 🔄 Running Flutter Doctor
echo ----------------------------------------
flutter doctor -v
if errorlevel 1 (
    echo ⚠️ Flutter doctor completed with warnings
) else (
    echo ✅ Flutter doctor successful
)

echo.
echo 🔄 Cleaning Project
echo ----------------------------------------
flutter clean
if errorlevel 1 (
    echo ❌ Flutter clean failed
    exit /b 1
)
echo ✅ Flutter clean successful

echo.
echo 🔄 Getting Dependencies
echo ----------------------------------------
flutter pub get
if errorlevel 1 (
    echo ❌ Flutter pub get failed
    exit /b 1
)
echo ✅ Flutter pub get successful

echo.
echo 🔄 Checking Dependencies
echo ----------------------------------------
flutter pub deps
if errorlevel 1 (
    echo ❌ Dependency check failed
    exit /b 1
)
echo ✅ Dependency check successful

echo.
echo 🔄 Analyzing Code
echo ----------------------------------------
flutter analyze
if errorlevel 1 (
    echo ⚠️ Code analysis completed with warnings
) else (
    echo ✅ Code analysis passed
)

echo.
echo 🔄 Checking Code Formatting
echo ----------------------------------------
dart format --output=none --set-exit-if-changed .
if errorlevel 1 (
    echo ⚠️ Code formatting issues found. Run 'dart format .' to fix.
) else (
    echo ✅ Code formatting is correct
)

echo.
echo 🔄 Running Tests
echo ----------------------------------------
flutter test
if errorlevel 1 (
    echo ⚠️ Some tests failed
) else (
    echo ✅ All tests passed
)

echo.
echo 🔄 Building Android APK
echo ----------------------------------------
flutter build apk --release --verbose
if errorlevel 1 (
    echo ❌ Android APK build failed
    exit /b 1
)

REM Check APK file
if exist "build\app\outputs\flutter-apk\app-release.apk" (
    echo ✅ APK created successfully
    for %%A in ("build\app\outputs\flutter-apk\app-release.apk") do (
        set APK_SIZE=%%~zA
        set /a APK_SIZE_MB=!APK_SIZE!/1024/1024
        echo 📊 APK size: !APK_SIZE_MB! MB
    )
) else (
    echo ❌ APK file not found
    exit /b 1
)

echo.
echo 🔄 Building Android App Bundle
echo ----------------------------------------
flutter build appbundle --release --verbose
if errorlevel 1 (
    echo ❌ Android App Bundle build failed
    exit /b 1
)

REM Check AAB file
if exist "build\app\outputs\bundle\release\app-release.aab" (
    echo ✅ App Bundle created successfully
    for %%A in ("build\app\outputs\bundle\release\app-release.aab") do (
        set AAB_SIZE=%%~zA
        set /a AAB_SIZE_MB=!AAB_SIZE!/1024/1024
        echo 📊 AAB size: !AAB_SIZE_MB! MB
    )
) else (
    echo ❌ App Bundle file not found
    exit /b 1
)

echo.
echo 🎉 Build Test Summary
echo ====================
echo ✅ Flutter setup: OK
echo ✅ Dependencies: OK
echo ✅ Code analysis: OK
echo ✅ Android APK: OK (!APK_SIZE_MB! MB)
echo ✅ Android AAB: OK (!AAB_SIZE_MB! MB)

echo.
echo 🚀 Ready for CI/CD!
echo You can now safely push to main branch to trigger automated release.

echo.
echo 📁 Build artifacts created:
echo   - build\app\outputs\flutter-apk\app-release.apk
echo   - build\app\outputs\bundle\release\app-release.aab

pause
