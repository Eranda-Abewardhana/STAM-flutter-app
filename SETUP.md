# Development Setup Guide

## Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (v3.13.0 or later)
- **Dart SDK** (v3.0.0 or later)
- **Android Studio** (for Android development)
- **Xcode** (for iOS development on macOS)
- **Git** (for version control)
- **VS Code** or **Android Studio** IDE
- **Firebase CLI** (for Firebase setup)

## Step 1: Install Flutter

### macOS
```bash
# Using Homebrew
brew install --cask flutter

# Or download from official website
# https://flutter.dev/docs/get-started/install/macos
```

### Windows
```bash
# Download from official website and extract
# https://flutter.dev/docs/get-started/install/windows

# Add Flutter to PATH
# Add 'C:\flutter\bin' to your system PATH environment variable
```

### Linux
```bash
# Download and extract
cd ~/development
tar xf ~/Downloads/flutter_linux_3.13.0-stable.tar.gz

# Add to PATH in ~/.bashrc or ~/.zshrc
export PATH="$PATH:~/development/flutter/bin"
```

## Step 2: Verify Installation

```bash
# Check Flutter version
flutter --version

# Run diagnostics
flutter doctor -v

# Verify all components are installed
flutter doctor
```

## Step 3: Clone the Project

```bash
# Clone repository
git clone <repository_url> smart_passenger_alert

# Navigate to project
cd smart_passenger_alert

# Create a new branch for development
git checkout -b feature/your-feature-name
```

## Step 4: Setup IDE

### VS Code Setup

```bash
# Install Flutter and Dart extensions
# 1. Open VS Code
# 2. Go to Extensions (Ctrl+Shift+X / Cmd+Shift+X)
# 3. Search for "Flutter"
# 4. Install "Flutter" extension by Dart Code
# 5. Install "Dart" extension by Dart Code

# Select Flutter SDK
# 1. Press Cmd+Shift+P (or Ctrl+Shift+P)
# 2. Type "Flutter: Change Device or Emulator"
# 3. Select your device
```

### Android Studio Setup

```bash
# Install Flutter and Dart plugins
# 1. Open Android Studio
# 2. Go to Preferences > Plugins
# 3. Search for "Flutter"
# 4. Install Flutter plugin (automatically installs Dart)
# 5. Restart Android Studio
```

## Step 5: Firebase Setup

### Create Firebase Project

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Navigate to project directory
cd smart_passenger_alert

# Configure FlutterFire
flutterfire configure --project=smart-passenger-alert
```

### Firebase Console Setup

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project called "Smart Passenger Alert"
3. Enable following services:
   - Cloud Messaging (FCM)
   - Authentication
   - Realtime Database
   - Cloud Storage
4. Download service account key (for backend)
5. Create Android and iOS apps in Firebase Console

## Step 6: Install Dependencies

```bash
# Get all Flutter packages
flutter pub get

# Generate code for JSON serialization, Riverpod, etc.
flutter pub run build_runner build --delete-conflicting-outputs

# If you encounter issues
flutter pub get --no-example
flutter pub run build_runner build --delete-conflicting-outputs
```

## Step 7: Android Development Setup

### Install Android SDK Components

```bash
# Using Android Studio
# 1. Open Android Studio
# 2. Tools > SDK Manager
# 3. Install:
#    - Android SDK Platform 34
#    - Android SDK Build Tools 34.0.0
#    - Android Emulator
#    - Android SDK Tools

# Or using command line
sdkmanager "platforms;android-34"
sdkmanager "build-tools;34.0.0"
```

### Create Android Emulator

```bash
# List available emulator configurations
emulator -list-avds

# Create new emulator
avdmanager create avd -n "Pixel_6" -k "system-images;android-34;google_apis;x86_64"

# Start emulator
emulator -avd Pixel_6
```

## Step 8: iOS Development Setup

### Install Required Tools

```bash
# Install CocoaPods (if using macOS)
sudo gem install cocoapods

# Update CocoaPods
pod repo update
```

### Create iOS Simulator

```bash
# List available simulators
xcrun simctl list devices

# Create new simulator (if needed)
xcrun simctl create "iPhone-15" "com.apple.CoreSimulator.SimDeviceType.iPhone-15" "com.apple.CoreSimulator.SimRuntime.iOS-17-0"

# Start simulator
open -a Simulator
```

## Step 9: Environment Configuration

### Create .env File

```bash
# In project root directory, create .env file
cat > .env << EOF
API_BASE_URL=https://api.travelassistant.local/v1
FIREBASE_PROJECT_ID=smart-passenger-alert
ENVIRONMENT=development
DEBUG_MODE=true
EOF
```

### Update Configuration Files

Edit `lib/utils/constants.dart`:
```dart
class AppConstants {
  static const String apiBaseUrl = 'https://api.travelassistant.local/v1';
  static const String projectId = 'smart-passenger-alert';
  // ... other constants
}
```

## Step 10: Run the App

### First Run (Recommended)

```bash
# Clean previous builds
flutter clean

# Get dependencies again
flutter pub get

# Generate code
flutter pub run build_runner build

# Run on connected device
flutter run

# Or specify a device
flutter run -d <device_id>
```

### Debug Mode

```bash
# Run with verbose logging
flutter run -v

# Run with debug checks enabled
flutter run --debug

# Run with hot reload enabled (default)
flutter run
```

### Release Mode

```bash
# Build and run release APK
flutter run --release

# View release build output
flutter build apk --release
```

## Development Workflow

### Hot Reload

```bash
# During development, Flutter supports hot reload
# Press 'r' in terminal to hot reload
# Press 'R' to hot restart the app
```

### Code Generation

```bash
# Watch mode (auto-regenerate on file changes)
flutter pub run build_runner watch

# One-time build
flutter pub run build_runner build

# Clean and rebuild
flutter pub run build_runner clean
flutter pub run build_runner build
```

### Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/screens/login_screen_test.dart

# Watch mode for tests
flutter test --watch
```

### Code Formatting

```bash
# Format all Dart files
flutter format .

# Check formatting without changing files
flutter format --set-exit-if-changed .
```

### Code Analysis

```bash
# Analyze code for issues
flutter analyze

# Run linter with custom rules
flutter analyze --no-pub

# Export analysis results
flutter analyze > analysis_results.txt
```

## Troubleshooting

### Common Issues

#### 1. Flutter SDK Not Found
```bash
# Ensure Flutter is in PATH
export PATH="$PATH:/path/to/flutter/bin"

# Or configure in IDE settings
```

#### 2. Gradle Build Errors
```bash
# Clear Gradle cache
cd android
./gradlew clean
cd ..

# Rebuild
flutter pub get
flutter run
```

#### 3. CocoaPods Issues
```bash
# Remove pods and reinstall
cd ios
rm -rf Pods
rm Podfile.lock
pod install --repo-update
cd ..
```

#### 4. Build Runner Issues
```bash
# Clean and rebuild
flutter pub run build_runner clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

#### 5. Firebase Configuration Issues
```bash
# Reconfigure Firebase
flutterfire configure --project=smart-passenger-alert --overwrite

# Check all Firebase config files generated
find . -name "google-services.json"
find . -name "GoogleService-Info.plist"
```

## Useful Commands

```bash
# Check connected devices
flutter devices

# Get app logs
flutter logs

# Run specific test
flutter test test/unit/app_utils_test.dart

# Profile app performance
flutter run --profile

# Build release APK
flutter build apk --split-per-abi

# Build iOS app
flutter build ios --release

# Check dependency updates
flutter pub outdated

# Upgrade dependencies
flutter pub upgrade

# Generate app icon
flutter pub run flutter_launcher_icons:main

# Generate splash screen
flutter pub run flutter_native_splash:create
```

## Git Workflow

```bash
# Create feature branch
git checkout -b feature/flight-tracking

# Make your changes
git add .
git commit -m "feat: Add flight tracking feature"

# Push to remote
git push origin feature/flight-tracking

# Create Pull Request on GitHub
# After review and approval
git switch main
git pull origin main
git merge feature/flight-tracking
git push origin main
```

## Continuous Integration

### GitHub Actions

The project includes CI/CD pipeline in `.github/workflows/ci-cd.yml`

Automatic checks:
- Code formatting
- Linting
- Unit tests
- Build verification
- Security scanning

Manual deployment:
```bash
# Trigger production deployment
# Push to main branch with version tag
git tag v1.0.0
git push origin v1.0.0
```

## Additional Resources

- [Flutter Official Documentation](https://flutter.dev/docs)
- [Dart Programming Guide](https://dart.dev/guides)
- [Firebase Flutter Guide](https://firebase.flutter.dev)
- [Riverpod Documentation](https://riverpod.dev)
- [Flutter Community](https://www.reddit.com/r/FlutterDev)

## Performance Tips

1. **Use const constructors** where possible
2. **Avoid rebuilds** with Riverpod selectors
3. **Use RepaintBoundary** for expensive widgets
4. **Implement image caching** strategies
5. **Monitor memory usage** with DevTools

## Next Steps

1. Review existing code structure
2. Read the [README.md](README.md)
3. Check [API Documentation](API.md)
4. Review design specifications in attachments
5. Start working on assigned features

---

**Happy Coding!** 🚀

If you face any issues, please refer to the troubleshooting section or reach out to the team.

Last Updated: April 2026
