# Developer Onboarding Guide

## Welcome to Smart Passenger Alert! 🎉

This guide will get you up and running as a developer on the Smart Passenger Alert System project. Follow these steps sequentially.

## Phase 1: Prerequisites (30 minutes)

### Step 1.1: Verify System Requirements

Before you begin, ensure your system meets the minimum requirements:

**All Platforms:**
- 4GB RAM minimum (8GB recommended)
- 10GB disk space for Flutter SDK
- Git version control system
- A modern web browser (Chrome, Safari, or Firefox)

**macOS:**
- macOS 10.15 or later
- Xcode 12.4 or later
- CocoaPods

**Windows:**
- Windows 10 or later
- Have 64-bit machine
- Administrator access for some installations

**Linux:**
- Ubuntu 20.04 LTS or later
- GCC toolkit

### Step 1.2: Install Required Tools

```bash
# macOS (using Homebrew)
brew install git
brew install --cask flutter
brew install --cask android-studio
brew install --cask xcode
brew install cocoapods

# Windows (using Chocolatey)
choco install git
choco install android-studio
choco install visualstudio2022-workload-managed

# Linux (Ubuntu/Debian)
sudo apt-get update
sudo apt-get install git
# Follow Flutter installation guide for Linux
```

### Step 1.3: Verify Installation

```bash
# Check Flutter
flutter doctor -v

# Should see all green checkmarks for:
# ✓ Flutter SDK
# ✓ Dart SDK
# ✓ Android toolchain
# ✓ Xcode (macOS/iOS)
# ✓ ChromeOS toolchain

# If any failures, address them:
flutter doctor --android-licenses  # Accept Android licenses
```

## Phase 2: Environment Setup (20 minutes)

### Step 2.1: Clone Repository

```bash
# Navigate to your development directory
cd ~/dev  # or your preferred location

# Clone the repository
git clone https://github.com/smartpassenger/smart_passenger_alert.git

# Navigate into project
cd smart_passenger_alert

# Create your working branch
git checkout -b develop  # Your main development branch
```

### Step 2.2: Setup Development IDE

**Option A: VS Code (Recommended for Flutter)**

```bash
# Install VS Code
curl https://code.visualstudio.com/download

# Install extensions
# 1. Open VS Code
# 2. Go to Extensions (Ctrl+Shift+X)
# 3. Install:
#    - Flutter (Dart Code)
#    - Dart (Dart Code)
#    - Awesome Flutter Snippets
#    - Thunder Client (or Postman)
#    - GitLens
#    - ErrorLens

# Select Flutter SDK
# 1. Cmd+Shift+P > "Flutter: Change Device or Emulator"
```

**Option B: Android Studio**

```bash
# Launch Android Studio
# 1. File > Settings > Plugins
# 2. Search "Flutter"
# 3. Install Flutter plugin (installs Dart automatically)
# 4. Restart Android Studio
```

### Step 2.3: Configure Firebase

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Authenticate with Firebase
firebase login

# In project directory, configure FlutterFire
cd smart_passenger_alert
flutterfire configure --project=smart-passenger-alert

# This downloads:
# - google-services.json (Android)
# - GoogleService-Info.plist (iOS)
```

### Step 2.4: Install Project Dependencies

```bash
# Get all packages
flutter pub get

# Install build_runner and code generators
flutter pub global activate build_runner

# Generate code for models, providers, etc.
flutter pub run build_runner build --delete-conflicting-outputs

# Verify no errors
flutter analyze
```

## Phase 3: Understanding the Project (45 minutes)

### Step 3.1: Read Core Documentation

In order:

1. **[README.md](README.md)** - Project overview, features, architecture
2. **[API.md](API.md)** - API endpoints and integration
3. **[SETUP.md](SETUP.md)** - Detailed setup instructions
4. **[CONFIG.md](CONFIG.md)** - Configuration options
5. **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** - Common commands

**Time estimate:** 20 minutes

### Step 3.2: Review Project Structure

```
smart_passenger_alert/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── theme/                       # Design system
│   │   └── theme.dart              # Colors, typography
│   ├── models/                      # Data classes
│   │   ├── flight_model.dart
│   │   ├── user_model.dart
│   │   └── ...
│   ├── services/                    # API and Firebase
│   │   ├── api_service.dart
│   │   ├── firebase_service.dart
│   │   └── notification_service.dart
│   ├── providers/                   # State management
│   │   └── app_providers.dart      # Riverpod providers
│   ├── screens/                     # Full screen widgets
│   │   ├── splash_screen.dart
│   │   ├── login_screen.dart
│   │   ├── dashboard_screen.dart
│   │   └── ...
│   ├── widgets/                     # Reusable components
│   │   ├── glass_morphism_container.dart
│   │   ├── flight_card.dart
│   │   └── ...
│   ├── animations/                  # Custom animations
│   │   └── custom_animations.dart
│   └── utils/                       # Helper utilities
│       ├── constants.dart
│       └── app_utils.dart
├── test/                            # Unit and widget tests
├── assets/                          # Images, animations, fonts
├── pubspec.yaml                    # Dependencies
├── pubspec.lock                    # Locked versions
├── .github/                        # CI/CD workflows
└── README.md                       # Documentation

```

**Key files to examine:**
- `lib/main.dart` - App bootstrap
- `lib/theme/theme.dart` - Design system
- `lib/providers/app_providers.dart` - State structure
- `lib/services/api_service.dart` - Backend integration
- `pubspec.yaml` - Dependencies

**Time estimate:** 25 minutes

### Step 3.3: Understand Architecture

**State Management Pattern:**
```
UI Screens
    ↓
Riverpod Providers (lib/providers/)
    ↓
Services (lib/services/)
    ↓
Backend API / Firebase / Local Storage
```

**Data Flow Example:**
1. User taps "Get Flights" button
2. Screen watches `flightsProvider`
3. Provider calls `apiService.getFlights()`
4. API returns Flight objects
5. Models deserialize JSON to Flight instances
6. Provider updates state
7. UI rebuilds with new data

## Phase 4: Running Your First Build (15 minutes)

### Step 4.1: Setup Emulator/Device

**Android Emulator:**
```bash
# Create Android Virtual Device
flutter emulator --create --name "Pixel_6"

# Launch emulator
flutter emulation start Pixel_6

# Or use Android Studio
# Tools > Device Manager > Create Virtual Device
```

**iOS Simulator (macOS only):**
```bash
# Open simulator
open -a Simulator

# Or from command line
xcrun simctl boot <device-id>
```

**Physical Device:**
```bash
# Enable Developer Mode
# - Android: Settings > About > Tap Build 7 times
# - iOS: Settings > Developer

# Connect via USB
# Allow connection when prompted

# Verify connection
flutter devices
```

### Step 4.2: Run Your First Build

```bash
# Run development build
flutter run

# Or specify device
flutter run -d <device_id>

# This will:
# 1. Compile Dart code
# 2. Build app bundle
# 3. Deploy to device/emulator
# 4. Launch app
# 5. Enable hot reload
```

### Step 4.3: Verify Successful Run

✅ App should:
- Load splash screen with animation
- Navigate to login screen
- Display UI matching design mockups
- Show no red error messages
- Have proper styling with neon blue accents

❌ If issues occur:
- Check `flutter doctor -v`
- Review emulator logs: `flutter logs`
- Consult [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

## Phase 5: Development Workflow (20 minutes)

### Step 5.1: Create Feature Branch

```bash
git checkout -b feature/your-feature-name

# Branch naming convention:
# feature/  - New feature
# fix/      - Bug fix
# docs/     - Documentation
# refactor/ - Code refactoring
```

### Step 5.2: Make Changes

```dart
// Example: Add new method to a service
Future<List<Flight>> getUpcomingFlights() async {
  try {
    final response = await _dio.get('/flights/upcoming');
    return (response.data as List)
        .map((f) => Flight.fromJson(f))
        .toList();
  } catch (e) {
    rethrow;
  }
}
```

### Step 5.3: Test Locally

```bash
# Hot reload during development
# Press 'r' in terminal while app running

# Run tests
flutter test

# Check code quality
flutter analyze
flutter format .
```

### Step 5.4: Commit Changes

```bash
# Verify changes
git status
git diff

# Stage changes
git add .

# Commit with semantic message
git commit -m "feat(flights): Add upcoming flights endpoint"

# Push to remote
git push origin feature/your-feature-name
```

### Step 5.5: Create Pull Request

1. Go to GitHub repository
2. Click "Compare & pull request"
3. Fill template with:
   - Description of changes
   - Related issues
   - Testing performed
4. Submit for review

## Phase 6: Understanding Key Concepts (60 minutes)

### 6.1: Riverpod Providers

Understand how state management works:

```dart
// Simple async provider (fetch data)
final flightsProvider = FutureProvider((ref) async {
  final service = ref.watch(apiServiceProvider);
  return await service.getFlights();
});

// Watch in widget
@override
Widget build(BuildContext context, WidgetRef ref) {
  final flights = ref.watch(flightsProvider);
  
  return flights.when(
    data: (f) => FlightList(flights: f),
    loading: () => SkeletonLoader(),
    error: (e, st) => ErrorWidget(error: e),
  );
}

// State notifier for mutable state
final alertNotifierProvider = StateNotifierProvider((ref) {
  return AlertNotifier(ref.watch(apiServiceProvider));
});

// Use in widget
ref.read(alertNotifierProvider.notifier).addAlert(alert);
```

**Resources:**
- [Riverpod Documentation](https://riverpod.dev)
- Check `lib/providers/app_providers.dart` for examples

### 6.2: JSON Serialization

Models use code generation:

```dart
import 'package:json_annotation/json_annotation.dart';

part 'flight_model.g.dart';  // Generated file

@JsonSerializable()
class Flight {
  final String flightNumber;
  final String origin;
  final String destination;
  
  Flight({
    required this.flightNumber,
    required this.origin,
    required this.destination,
  });
  
  // Generated methods
  factory Flight.fromJson(Map<String, dynamic> json) => 
      _$FlightFromJson(json);
  
  Map<String, dynamic> toJson() => _$FlightToJson(this);
}
```

**Generate after model changes:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 6.3: Widget Patterns

Follow these patterns for consistency:

```dart
// StatelessWidget for UI
class FlightCard extends StatelessWidget {
  final Flight flight;
  
  const FlightCard({
    required this.flight,
    Key? key,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      // Implementation
    );
  }
}

// ConsumerWidget for Riverpod
class Dashboard extends ConsumerWidget {
  const Dashboard({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flights = ref.watch(flightsProvider);
    
    return Scaffold(
      // Implementation
    );
  }
}

// Custom widgets should be small and focused
// Each widget has one responsibility
```

### 6.4: API Integration

Services handle backend communication:

```dart
// Define endpoint
Future<List<Flight>> getFlights() async {
  try {
    final response = await _dio.get('/flights');
    return (response.data as List)
        .map((f) => Flight.fromJson(f))
        .toList();
  } catch (e) {
    logger.error('Failed to get flights', e);
    rethrow;
  }
}

// Use in provider
final flightsProvider = FutureProvider((ref) {
  final service = ref.watch(apiServiceProvider);
  return service.getFlights();
});

// Use in widget
final flights = ref.watch(flightsProvider);
```

**Real API Integration:**
- Update `API_BASE_URL` in environment config
- Replace placeholder endpoints with real ones
- Test with actual backend

### 6.5: Theme & Styling

Use theme constants for consistency:

```dart
import 'package:smart_passenger_alert/theme/theme.dart';

// Colors
AppColors.primary  // #5B9EFF (primary blue)
AppColors.danger   // #FF4444 (error red)

// Text styles
AppTheme.displayLarge
AppTheme.bodyLarge
AppTheme.labelSmall

// Spacing
AppSpacing.xs      // 4px
AppSpacing.md      // 16px
AppSpacing.lg      // 24px

// Radius
AppRadius.xs       // 4px
AppRadius.lg       // 16px

// Example usage
Container(
  padding: EdgeInsets.all(AppSpacing.md),
  decoration: BoxDecoration(
    color: AppColors.primary,
    borderRadius: BorderRadius.circular(AppRadius.lg),
  ),
  child: Text('Hello', style: AppTheme.bodyLarge),
)
```

## Common Tasks

### Create a New Screen

1. Create screen file
2. Add route to `app_router.dart`
3. Create provider if needed
4. Design UI using theme
5. Test navigation

```bash
# Files to create
touch lib/screens/new_screen.dart
touch lib/widgets/new_screen_widgets.dart  # If needed
```

### Add API Endpoint

1. Add method to `ApiService`
2. Create/update model
3. Generate serialization: `flutter pub run build_runner build`
4. Create provider in `app_providers.dart`
5. Use provider in screen

### Debug Issues

```bash
# Check errors
flutter analyze

# View logs
flutter logs

# Use DevTools
devtools

# Check device
flutter devices
```

## Useful Keyboard Shortcuts

| Action | Shortcut |
|--------|----------|
| Command Palette | `Cmd+Shift+P` |
| Start Debugging | `F5` |
| Hot Reload | `Ctrl+S` (auto-reload enabled) |
| Go to Definition | `F12` |
| Find Symbol | `Cmd+T` |
| Show Problems | `Cmd+Shift+M` |
| Format Document | `Shift+Alt+F` |
| Comment Line | `Cmd+/` |

## Daily Development Workflow

```
1. Start day:
   git pull origin develop

2. Create feature branch:
   git checkout -b feature/your-feature

3. Develop:
   flutter run
   # Make changes
   # Test with hot reload
   # Test thoroughly

4. Before commit:
   flutter test
   flutter analyze
   flutter format .

5. Commit:
   git add .
   git commit -m "type(scope): description"

6. Push:
   git push origin feature/your-feature

7. Create Pull Request:
   # Review > Approve > Merge > Delete branch
```

## Next Steps

1. **Read [CONTRIBUTING.md](CONTRIBUTING.md)** - Understand coding standards
2. **Review [API.md](API.md)** - Learn about backend endpoints
3. **Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Know how to debug
4. **Pick a small issue** - Make your first contribution
5. **Attend code review** - Learn from feedback

## Getting Help

- 📚 Documentation: Check README, API, CONFIG files
- 🔍 Search: GitHub Issues, Stack Overflow
- 💬 Ask: Team lead, peer developers
- 🐛 Debug: Use DevTools, check logs
- 📖 Learn: Dart/Flutter official documentation

## Success Criteria

You're ready to contribute when you can:
- ✅ Run app successfully
- ✅ Understand project structure
- ✅ Modify code and hot reload
- ✅ Make and run tests
- ✅ Commit with semantic messages
- ✅ Create pull requests
- ✅ Follow coding standards

## Congratulations! 🎉

You're now ready to start developing Smart Passenger Alert System.

Welcome to the team! Feel free to ask questions, we're here to help.

---

**Questions?** Reach out to the dev team or create a discussion in GitHub!

---

**Last Updated:** April 2026
**Maintenance:** Dev Team
**Status:** ✅ Updated
