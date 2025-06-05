@echo off
setlocal enabledelayedexpansion

REM EchoGen.ai Version Bump Script for Windows
REM Usage: scripts\bump_version.bat [patch|minor|major]

echo.
echo 🚀 EchoGen.ai Version Bump Script
echo ================================

REM Check if argument is provided
if "%1"=="" (
    echo Error: No version bump type specified
    echo.
    echo Usage: %0 [patch^|minor^|major]
    echo.
    echo Version bump types:
    echo   patch  - Bug fixes and small improvements ^(1.0.0 -^> 1.0.1^)
    echo   minor  - New features, backwards compatible ^(1.0.0 -^> 1.1.0^)
    echo   major  - Breaking changes ^(1.0.0 -^> 2.0.0^)
    echo.
    echo Example: %0 patch
    exit /b 1
)

set BUMP_TYPE=%1

REM Validate bump type
if not "%BUMP_TYPE%"=="patch" if not "%BUMP_TYPE%"=="minor" if not "%BUMP_TYPE%"=="major" (
    echo Error: Invalid bump type '%BUMP_TYPE%'
    echo Valid types: patch, minor, major
    exit /b 1
)

REM Check if we're in the project root
if not exist "pubspec.yaml" (
    echo Error: pubspec.yaml not found. Please run this script from the project root.
    exit /b 1
)

REM Check if git is clean
git status --porcelain > temp_status.txt
set /p GIT_STATUS=<temp_status.txt
del temp_status.txt

if not "!GIT_STATUS!"=="" (
    echo Warning: You have uncommitted changes. Please commit or stash them first.
    set /p CONTINUE="Continue anyway? (y/N): "
    if /i not "!CONTINUE!"=="y" exit /b 1
)

echo 📦 Starting version bump process...

REM Get current version from pubspec.yaml
for /f "tokens=2 delims= " %%a in ('findstr "^version:" pubspec.yaml') do set FULL_VERSION=%%a
for /f "tokens=1 delims=+" %%a in ("!FULL_VERSION!") do set CURRENT_VERSION=%%a
for /f "tokens=2 delims=+" %%a in ("!FULL_VERSION!") do set CURRENT_BUILD=%%a

echo 📦 Current version: !CURRENT_VERSION!+!CURRENT_BUILD!

REM Parse version parts
for /f "tokens=1,2,3 delims=." %%a in ("!CURRENT_VERSION!") do (
    set MAJOR=%%a
    set MINOR=%%b
    set PATCH=%%c
)

REM Calculate new version
if "%BUMP_TYPE%"=="major" (
    set /a MAJOR=!MAJOR!+1
    set MINOR=0
    set PATCH=0
) else if "%BUMP_TYPE%"=="minor" (
    set /a MINOR=!MINOR!+1
    set PATCH=0
) else if "%BUMP_TYPE%"=="patch" (
    set /a PATCH=!PATCH!+1
)

set NEW_VERSION=!MAJOR!.!MINOR!.!PATCH!
set /a NEW_BUILD=!CURRENT_BUILD!+1

echo 📦 New version: !NEW_VERSION!+!NEW_BUILD!

REM Confirm with user
set /p PROCEED="Proceed with version bump? (y/N): "
if /i not "!PROCEED!"=="y" (
    echo Version bump cancelled.
    exit /b 0
)

REM Update pubspec.yaml
echo 📝 Updating pubspec.yaml...
powershell -Command "(Get-Content pubspec.yaml) -replace '^version: .*', 'version: !NEW_VERSION!+!NEW_BUILD!' | Set-Content pubspec.yaml"

REM Update CHANGELOG.md
echo 📝 Updating CHANGELOG.md...
for /f "tokens=2 delims= " %%a in ('date /t') do set TODAY=%%a
powershell -Command "(Get-Content CHANGELOG.md) -replace '## \[Unreleased\]', ('## [Unreleased]' + [Environment]::NewLine + [Environment]::NewLine + '## [!NEW_VERSION!] - !TODAY!') | Set-Content CHANGELOG.md"

REM Update README.md
echo 📝 Updating README.md...
powershell -Command "$content = Get-Content README.md; $index = $content.IndexOf($content -match '### Version History'); $content = $content[0..$index] + '- **v!NEW_VERSION!**: Latest release with new features and improvements' + $content[($index+1)..($content.Length-1)]; $content | Set-Content README.md"

REM Git operations
echo 📝 Creating git commit and tag...
git add pubspec.yaml CHANGELOG.md README.md
git commit -m "🔖 Bump version to v!NEW_VERSION!" -m "- Updated version in pubspec.yaml to !NEW_VERSION!+!NEW_BUILD!" -m "- Updated CHANGELOG.md with release date" -m "- Updated README.md version history"
git tag -a "v!NEW_VERSION!" -m "Release v!NEW_VERSION!"

echo.
echo ✅ Version bump completed successfully!
echo 📋 Summary:
echo   - Version: !CURRENT_VERSION! -^> !NEW_VERSION!
echo   - Build: !CURRENT_BUILD! -^> !NEW_BUILD!
echo   - Tag: v!NEW_VERSION! created
echo.
echo 🚀 Next steps:
echo   1. Review the changes: git show
echo   2. Push to remote: git push origin main --tags
echo   3. GitHub Actions will automatically build and create a release
echo.
echo 🔗 Useful commands:
echo   - View tags: git tag -l
echo   - View commit: git show v!NEW_VERSION!
echo   - Push changes: git push origin main --tags

pause
