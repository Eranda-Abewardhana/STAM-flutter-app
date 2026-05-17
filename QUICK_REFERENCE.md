# Quick Reference Guide

## Essential Flutter Commands

### Project Management

```bash
# Create new Flutter app
flutter create app_name

# Create new package
flutter create --template=package package_name

# Create new plugin
flutter create --template=plugin plugin_name

# Add dependency
flutter pub add package_name

# Remove dependency
flutter pub remove package_name

# Get all dependencies
flutter pub get

# Upgrade dependencies
flutter pub upgrade

# Check outdated packages
flutter pub outdated
```

### Development

```bash
# Run app in debug mode
flutter run

# Run on specific device
flutter run -d device_id

# Get list of available devices
flutter devices

# Run with hot reload
flutter run
# Type 'r' to hot reload
# Type 'R' to hot restart

# Run in profile mode (performance profiling)
flutter run --profile

# Run in release mode
flutter run --release

# Run with verbose logging
flutter run -v

# Watch code changes
flutter run --watch
```

### Code Generation

```bash
# Generate code (one-time)
flutter pub run build_runner build

# Watch for changes and regenerate
flutter pub run build_runner watch

# Clean generated files
flutter pub run build_runner clean

# Delete conflicting outputs
flutter pub run build_runner build --delete-conflicting-outputs

# Generate with verbose output
flutter pub run build_runner build -v
```

### Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/models/flight_model_test.dart

# Run with coverage
flutter test --coverage

# Watch mode for tests
flutter test --watch

# Run with verbose output
flutter test -v

# Generate coverage report (Linux/macOS)
lcov --remove coverage/lcov.info '**/*.freezed.dart' -o coverage/lcov_filtered.info
genhtml coverage/lcov_filtered.info -o coverage/html
```

### Code Quality

```bash
# Analyze code for issues
flutter analyze

# Format code
flutter format .

# Format specific file
flutter format lib/main.dart

# Check format without changing
flutter format --set-exit-if-changed .

# Lint with custom rules
flutter analyze --no-pub

# Show lint severity
flutter analyze --severity=error
```

### Building & Deployment

```bash
# Clean build
flutter clean

# Build APK (Android)
flutter build apk --release

# Build split APK by architecture
flutter build apk --split-per-abi --release

# Build iOS
flutter build ios --release

# Build iOS framework
flutter build ios-framework

# Build web app
flutter build web --release

# Build Windows app
flutter build windows --release

# Build macOS app
flutter build macos --release

# Build Linux app
flutter build linux --release

# Build app bundle (Google Play)
flutter build appbundle --release
```

### Useful Options

```bash
# Target specific Dart entrypoint
flutter run -t lib/main_dev.dart

# Use specific flavor
flutter run --flavor dev

# Specify build number/version
flutter build apk --build-number=2 --build-name=1.0.1

# Split debug symbols
flutter build apk --split-debug-info=./symbols

# Obfuscate code
flutter build apk --obfuscate --split-debug-info=./symbols
```

## Project Structure Commands

```bash
# View project structure
tree -L 3 -I 'build|.git'

# Count lines of code
find lib -name "*.dart" -exec wc -l {} + | tail -1

# Find TODO comments
grep -r "TODO\|FIXME" lib/

# List all assets
find assets -type f

# Check file sizes
du -h lib/**/*.dart | sort -h
```

## Firebase Commands

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# List Firebase projects
firebase projects:list

# Select project
firebase use project-id

# Initialize Firebase in project
firebase init

# Deploy to Firebase Hosting
firebase deploy

# Deploy only specific services
firebase deploy --only hosting
firebase deploy --only functions
firebase deploy --only firestore

# Configure FlutterFire
flutterfire configure

# Reconfigure with overwrite
flutterfire configure --overwrite

# Check Firebase status
firebase status
```

## Git Workflow

```bash
# Clone repository
git clone <repo-url>

# Create feature branch
git checkout -b feature/feature-name

# Check status
git status

# View changes
git diff

# Stage changes
git add .
git add lib/screens/

# Commit changes
git commit -m "feat(scope): description"

# Push to remote
git push origin feature/feature-name

# Pull latest changes
git pull origin main

# Merge branch locally
git checkout main
git pull
git merge feature/feature-name

# Rebase on main
git rebase main

# View commit history
git log --oneline

# View branches
git branch -a

# Delete local branch
git branch -d feature-name

# Delete remote branch
git push origin --delete feature-name

# Create tag
git tag v1.0.0
git push origin v1.0.0
```

## Android Development

```bash
# List connected devices
adb devices

# Start emulator
emulator -avd emulator-name

# Install APK
adb install path/to/app.apk

# Run app on device
adb shell am start -n com.package/com.package.MainActivity

# View logs
adb logcat

# Filter Flutter logs
adb logcat | grep flutter

# Clear logs
adb logcat -c

# Take screenshot
adb shell screencap -p /sdcard/screenshot.png
adb pull /sdcard/screenshot.png

# Open app settings
adb shell pm grant com.package android.permission.CAMERA

# Clear app cache
adb shell pm clear com.package
```

## iOS Development

```bash
# List available simulators
xcrun simctl list devices

# Create simulator
xcrun simctl create "iPhone-15" com.apple.CoreSimulator.SimDeviceType.iPhone-15

# Boot simulator
xcrun simctl boot device-id

# Shutdown simulator
xcrun simctl shutdown device-id

# Erase simulator
xcrun simctl erase device-id

# Open Simulator
open -a Simulator

# Connect real device
# 1. Plugin device via USB
# 2. Trust computer when prompted
# 3. Use in Xcode

# Build for device
flutter build ios --release

# Install on device via Xcode
# 1. Open ios/Runner.xcworkspace
# 2. Select device
# 3. Product > Run (Cmd+R)
```

## Useful VS Code Extensions

```bash
# Install Flutter extension
code --install-extension Dart-Code.flutter

# Install Dart extension
code --install-extension Dart-Code.dart-code

# Productivity extensions
code --install-extension eamodio.gitlens
code --install-extension esbenp.prettier-vscode
code --install-extension ms-vscode.makefile-tools
```

## Environment Variables

```bash
# macOS/Linux
export PATH="$PATH:/path/to/flutter/bin"
export ANDROID_HOME=$HOME/Library/Android/sdk
export iOS_SIGNING_CERT=""  # Certificate name for iOS

# Windows (Command Prompt)
set PATH=%PATH%;C:\flutter\bin
set ANDROID_HOME=%USERPROFILE%\AppData\Local\Android\sdk

# Windows (PowerShell)
$env:PATH += ";C:\flutter\bin"
$env:ANDROID_HOME = "$env:USERPROFILE\AppData\Local\Android\sdk"
```

## Riverpod Commands

```bash
# Generate Riverpod code
flutter pub run build_runner build

# Watch for changes
flutter pub run build_runner watch

# Filter providers by name
# In code:
ref.read(flightsProvider)           // Get data
ref.watch(flightsProvider)          // Watch changes
ref.refresh(flightsProvider)        // Refresh
ref.invalidate(flightsProvider)     // Invalidate cache
```

## DevTools Usage

```bash
# Activate DevTools
flutter pub global activate devtools

# Launch DevTools
devtools

# Connect running app
# Open DevTools URL in browser
# Select running device from dropdown

# Main features:
# - Inspector: Widget tree
# - Console: Logs and debugging
# - Network: API calls
# - Memory: Memory profiling
# - Performance: Frame analysis
# - Debugger: Breakpoints and stepping
```

## Debugging

```bash
# Check Flutter doctor
flutter doctor -v

# Get app logs
flutter logs

# Find package location
flutter pub cache dir

# Show pub dependencies tree
flutter pub deps --no-dev

# Check package versions
flutter pub outdated

# See global packages
flutter pub global list
```

## Common Patterns

### Create a new screen

```bash
# Create screen file
touch lib/screens/new_screen.dart

# Create model file
touch lib/models/new_model.dart

# Create provider
touch lib/providers/new_provider.dart

# Create widget components
touch lib/widgets/new_card.dart
```

### Update dependencies

```bash
flutter pub upgrade

# Or update specific package
flutter pub upgrade package_name

# Update to latest compatible versions
flutter pub upgrade --major-versions
```

### Deploy to Play Store

```bash
# Build release APK
flutter build appbundle --release

# Upload to Play Console
# 1. Go to Google Play Console
# 2. Select app
# 3. Release management > Releases
# 4. Create release
# 5. Upload .aab file
```

### Deploy to App Store

```bash
# Build for iOS
flutter build ios --release

# Create archive in Xcode
# 1. Open Runner.xcworkspace
# 2. Select Generic iOS Device
# 3. Product > Archive
# 4. Validate with App Store
# 5. Distribute

# Or use command line
flutter build ios --release
xcodebuild -workspace ios/Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -archivePath release.xcarchive \
  -allowProvisioningUpdates \
  archive
```

## Terminal Shortcuts

```bash
# Clear screen
clear  # or Ctrl+L

# Exit terminal
exit   # or Ctrl+D

# Go to home directory
cd ~

# Go to previous directory
cd -

# List all files including hidden
ls -la  # macOS/Linux

# Create file
touch filename.txt

# Remove file
rm filename.txt

# Remove directory
rm -rf dirname

# Copy file
cp source destination

# Move file
mv source destination

# Create directory
mkdir dirname

# Change directory
cd dirname

# Create nested directories
mkdir -p path/to/nested/dir
```

## Keyboard Shortcuts (VS Code)

```
Ctrl+Shift+P  / Cmd+Shift+P     : Command Palette
Ctrl+`        / Cmd+`           : Toggle Terminal
Ctrl+/        / Cmd+/           : Toggle Comment
Ctrl+H        / Cmd+H           : Find and Replace
Ctrl+F        / Cmd+F           : Find
Ctrl+G        / Cmd+G           : Go to Line
Alt+Up/Down   / Option+Up/Down  : Move Line Up/Down
Ctrl+D        / Cmd+D           : Select Word
F2 / Cmd+Shift+R                : Rename Symbol
Alt+Enter     / Cmd+Option+I    : Format Document
Ctrl+Shift+F  / Cmd+Shift+X     : Format (with prettier)
```

## Keyboard Shortcuts (iOS Simulator)

```
Cmd+Z         : Undo
Cmd+Y         : Redo
Cmd+Left      : Home button
Cmd+Right     : Lock button
Cmd+Y         : Toggle device rotation
Cmd+I         : Toggle iOS simctl interaction
```

## Memory & Performance

```bash
# Check available memory
free -h  # Linux
vm_stat  # macOS
wmic OS get TotalVisibleMemorySize  # Windows

# Monitor app performance
flutter run --profile

# Use DevTools Memory profiler
# Dart DevTools > Memory tab

# Check APK size
flutter build apk --analyze-size --release

# Check app bundle size
flutter build appbundle --analyze-size --release
```

## Useful Resources

- [Flutter Docs](https://flutter.dev/docs)
- [Dart Docs](https://dart.dev/guides)
- [Firebase Docs](https://firebase.flutter.dev)
- [Riverpod Docs](https://riverpod.dev)
- [Pub.dev](https://pub.dev)

## Emergency Commands

```bash
# When nothing else works:
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs

# And then:
flutter run

# Or nuclear option:
rm -rf .dart_tool
rm -rf pubspec.lock
rm -rf android/build
rm -rf ios/Pods
rm ios/Podfile.lock
flutter pub get
flutter pub run build_runner build
flutter run
```

## Productivity Tips

1. **Use IDE shortcuts** - Learn vs code/Android Studio shortcuts
2. **Set up git locally** - Configure git for commits
3. **Use proper branch names** - `feature/`, `fix/`, `docs/` prefixes
4. **Test locally before pushing** - Run `flutter test` and `flutter analyze`
5. **Use meaningful commit messages** - Follow semantic versioning
6. **Keep dependencies updated** - Run `flutter pub upgrade` regularly
7. **Use DevTools effectively** - Profile memory, network, and performance
8. **Organize imports** - Use automatic import organization
9. **Comment complex code** - Use documentation comments `///`
10. **Review before committing** - Check `git diff` before committing

---

**Bookmark this page** for quick reference during development!

Last Updated: April 2026
