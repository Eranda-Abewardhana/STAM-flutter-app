# Configuration Guide

## Overview

This document provides detailed instructions for configuring the Smart Passenger Alert System for different environments and use cases.

## Environment Configuration

### 1. Development Environment

#### Setup

```bash
# In project root, create .env.development
create .env.development
```

#### Contents: `.env.development`

```env
# API Configuration
API_BASE_URL=http://localhost:8080/api/v1
API_TIMEOUT=30000
ENABLE_LOGGING=true
DEBUG_MODE=true

# Firebase Configuration
FIREBASE_PROJECT_ID=smart-passenger-alert-dev
FIREBASE_API_KEY=AIzaSyXXXXXXX...
FIREBASE_AUTH_DOMAIN=smart-passenger-alert-dev.firebaseapp.com
FIREBASE_MESSAGING_SENDER_ID=123456789

# Feature Flags
ENABLE_CRASH_REPORTING=false
ENABLE_ANALYTICS=false
ENABLE_SMARTWATCH_INTEGRATION=true
ENABLE_AI_PREDICTIONS=true

# Notification Settings
NOTIFICATION_TEST_MODE=true
NOTIFICATION_LOG_EVENTS=true

# Database
USE_LOCAL_DATABASE=true
CLEAR_DB_ON_STARTUP=false
```

#### Update `lib/utils/constants.dart`

```dart
class AppEnvironment {
  static const String environment = 'development';
  static const String apiBaseUrl = 'http://localhost:8080/api/v1';
  static const int apiTimeout = 30000;
  static const bool enableLogging = true;
  static const bool debugMode = true;
  
  // Feature flags
  static const bool enableCrashReporting = false;
  static const bool enableAnalytics = false;
  static const bool enableSmartwatchIntegration = true;
  static const bool enableAIPredictions = true;
}
```

### 2. Staging Environment

#### Setup

```bash
# Create staging configuration
create .env.staging
```

#### Contents: `.env.staging`

```env
# API Configuration
API_BASE_URL=https://staging-api.travelassistant.com/v1
API_TIMEOUT=20000
ENABLE_LOGGING=true
DEBUG_MODE=false

# Firebase Configuration
FIREBASE_PROJECT_ID=smart-passenger-alert-staging
FIREBASE_API_KEY=AIzaSyYYYYYYY...
FIREBASE_AUTH_DOMAIN=smart-passenger-alert-staging.firebaseapp.com
FIREBASE_MESSAGING_SENDER_ID=987654321

# Feature Flags
ENABLE_CRASH_REPORTING=true
ENABLE_ANALYTICS=false
ENABLE_SMARTWATCH_INTEGRATION=true
ENABLE_AI_PREDICTIONS=true

# Notification Settings
NOTIFICATION_TEST_MODE=false
NOTIFICATION_LOG_EVENTS=true

# Database
USE_LOCAL_DATABASE=false
CLEAR_DB_ON_STARTUP=false
```

### 3. Production Environment

#### Setup

```bash
# Create production configuration
create .env.production
```

#### Contents: `.env.production`

```env
# API Configuration
API_BASE_URL=https://api.travelassistant.com/v1
API_TIMEOUT=15000
ENABLE_LOGGING=false
DEBUG_MODE=false

# Firebase Configuration
FIREBASE_PROJECT_ID=smart-passenger-alert-prod
FIREBASE_API_KEY=AIzaSyZZZZZZZ...
FIREBASE_AUTH_DOMAIN=smart-passenger-alert-prod.firebaseapp.com
FIREBASE_MESSAGING_SENDER_ID=555666777

# Feature Flags
ENABLE_CRASH_REPORTING=true
ENABLE_ANALYTICS=true
ENABLE_SMARTWATCH_INTEGRATION=true
ENABLE_AI_PREDICTIONS=true

# Notification Settings
NOTIFICATION_TEST_MODE=false
NOTIFICATION_LOG_EVENTS=false

# Database
USE_LOCAL_DATABASE=false
CLEAR_DB_ON_STARTUP=false
```

## Loading Environment Configuration

### Install flutter_dotenv

```bash
flutter pub add flutter_dotenv
```

### Update `pubspec.yaml`

```yaml
flutter:
  assets:
    - .env
    - .env.development
    - .env.staging
    - .env.production
```

### Update `lib/main.dart`

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment file based on flavor
  const String environment = String.fromEnvironment('ENVIRONMENT');
  final envFile = environment.isEmpty 
      ? '.env.development' 
      : '.env.$environment';
  
  await dotenv.load(fileName: envFile);
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
```

## Build Flavors

### Android Configuration

#### `android/build.gradle`

```gradle
project.ext.set("APPNAME", "SmartPassengerAlert")
project.ext.set("PACKAGE", "com.smartpassenger.alert")
```

#### `android/app/build.gradle`

```gradle
android {
    defaultConfig {
        applicationId "com.smartpassenger.alert"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }

    flavorDimensions "version"
    productFlavors {
        dev {
            dimension "version"
            applicationIdSuffix ".dev"
            manifestPlaceholders = [appLabel: "Smart Passenger (Dev)"]
        }
        staging {
            dimension "version"
            applicationIdSuffix ".staging"
            manifestPlaceholders = [appLabel: "Smart Passenger (Staging)"]
        }
        prod {
            dimension "version"
            manifestPlaceholders = [appLabel: "Smart Passenger Alert"]
        }
    }
}
```

### iOS Configuration

#### Create Configuration Files

```bash
# Development
touch ios/Flutter/Generated_dev.xcconfig
touch ios/Flutter/Generated_staging.xcconfig
touch ios/Flutter/Generated_prod.xcconfig
```

#### `ios/Flutter/Generated_dev.xcconfig`

```
DART_DEFINES=ENVIRONMENT=development
FLUTTER_ROOT=/path/to/flutter
```

#### iOS Build Schemes

```bash
# In Xcode: Product > Scheme > Edit Scheme
# Set Build Configuration for each scheme:
# - dev: Debug-development
# - staging: Release-staging  
# - prod: Release-production
```

### Flutter Command Examples

```bash
# Run development flavor
flutter run --flavor dev -t lib/main_dev.dart

# Run staging flavor
flutter run --flavor staging -t lib/main_staging.dart

# Run production flavor
flutter run --flavor prod -t lib/main_prod.dart

# Build APK for each flavor
flutter build apk --flavor dev --release
flutter build apk --flavor staging --release
flutter build apk --flavor prod --release

# Build iOS for each flavor
flutter build ios --flavor dev --release
flutter build ios --flavor staging --release
flutter build ios --flavor prod --release
```

## API Configuration

### Dynamic API URL

#### Update `lib/services/api_service.dart`

```dart
class ApiService {
  final Dio _dio;
  
  ApiService(this._dio) {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? 
        'https://api.travelassistant.local/v1';
    final timeout = int.tryParse(
        dotenv.env['API_TIMEOUT'] ?? '30000') ?? 30000;
    
    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(milliseconds: timeout),
      receiveTimeout: Duration(milliseconds: timeout),
    );
  }
  
  // ... rest of implementation
}
```

### API Request Interceptors

```dart
void _setupInterceptors() {
  // Request interceptor
  _dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add API key from environment
        final apiKey = dotenv.env['API_KEY'];
        if (apiKey != null) {
          options.headers['X-API-Key'] = apiKey;
        }
        
        // Log in development
        if (dotenv.env['ENABLE_LOGGING'] == 'true') {
          logger.info('Request: ${options.method} ${options.path}');
        }
        
        return handler.next(options);
      },
      onError: (error, handler) {
        logger.error('API Error: $error');
        return handler.next(error);
      },
    ),
  );
}
```

## Firebase Configuration

### Development Project

```bash
# Create separate Firebase project
firebase projects:create smart-passenger-alert-dev

# List projects
firebase projects:list

# Select project
firebase use smart-passenger-alert-dev
```

### Generate Firebase Config Files

```bash
# For Android
firebase apps:create android \
  --project=smart-passenger-alert-dev \
  --package-name=com.smartpassenger.alert.dev \
  --display-name="Smart Passenger (Dev)"

# Downloads google-services.json automatically

# For iOS
firebase apps:create ios \
  --project=smart-passenger-alert-dev \
  --bundle-id=com.smartpassenger.alert.dev \
  --display-name="Smart Passenger (Dev)"

# Downloads GoogleService-Info.plist automatically
```

### Multiple Firebase Projects

#### Android Structure

```
android/app/
├── google-services-dev.json
├── google-services-staging.json
└── google-services-prod.json
```

#### `android/app/build.gradle`

```gradle
android {
  flavorDimensions "environment"
  productFlavors {
    dev {
      dimension "environment"
      matchingFallbacks = ['debug', 'release']
    }
    staging { }
    prod { }
  }
}

// Copy appropriate google-services.json
task copyGoogleServicesFile {
  doLast {
    def flavor = "${project.ext.get('flavorName')}"
    copy {
      from "google-services-${flavor}.json"
      into "."
      rename { String fileName -> "google-services.json" }
    }
  }
}

preBuild.dependsOn copyGoogleServicesFile
```

### iOS Firebase Configuration

```swift
// In ios/Runner/GeneratedPluginRegistrant.m
// Multiple configs can be registered:

import FirebaseCore

@UIApplicationMain
class Runner: UIResponder, UIApplicationDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions
    launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let environment = Bundle.main.object(
      forInfoDictionaryKey: "ENVIRONMENT") as? String ?? "prod"
    
    let plistName = "GoogleService-Info-\(environment)"
    if let plistPath = Bundle.main.path(
      forResource: plistName,
      ofType: "plist"),
       let options = FirebaseOptions(contentsOfFile: plistPath) {
      FirebaseApp.configure(options: options)
    } else {
      FirebaseApp.configure()
    }
    
    return true
  }
}
```

## Feature Flags

### Riverpod Provider

```dart
// lib/providers/feature_flags_provider.dart
final featureFlagsProvider = Provider<FeatureFlags>((ref) {
  return FeatureFlags(
    enableCrashReporting: 
        dotenv.env['ENABLE_CRASH_REPORTING'] == 'true',
    enableAnalytics: 
        dotenv.env['ENABLE_ANALYTICS'] == 'true',
    enableSmartwatchIntegration: 
        dotenv.env['ENABLE_SMARTWATCH_INTEGRATION'] == 'true',
    enableAIPredictions: 
        dotenv.env['ENABLE_AI_PREDICTIONS'] == 'true',
  );
});

class FeatureFlags {
  final bool enableCrashReporting;
  final bool enableAnalytics;
  final bool enableSmartwatchIntegration;
  final bool enableAIPredictions;
  
  FeatureFlags({
    required this.enableCrashReporting,
    required this.enableAnalytics,
    required this.enableSmartwatchIntegration,
    required this.enableAIPredictions,
  });
}
```

### Using Feature Flags

```dart
class DashboardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flags = ref.watch(featureFlagsProvider);
    
    return Scaffold(
      body: Column(
        children: [
          // Always shown
          FlightCard(flight: flight),
          
          // Only if AI predictions enabled
          if (flags.enableAIPredictions)
            AIPredictionCard(prediction: prediction),
          
          // Only if smartwatch enabled
          if (flags.enableSmartwatchIntegration)
            VitalityMonitoringCard(),
        ],
      ),
    );
  }
}
```

## Logging Configuration

### Setup Logger

```dart
// lib/utils/app_logger.dart
import 'package:logger/logger.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    printTime: true,
  ),
  level: _getLogLevel(),
);

Level _getLogLevel() {
  final debugMode = dotenv.env['DEBUG_MODE'] == 'true';
  return debugMode ? Level.debug : Level.info;
}

class AppLogger {
  static void debug(String message) => logger.d(message);
  static void info(String message) => logger.i(message);
  static void warning(String message) => logger.w(message);
  static void error(String message, [dynamic error, StackTrace? st]) {
    logger.e(message, error: error, stackTrace: st);
  }
}
```

### Conditional Logging in Services

```dart
class ApiService {
  void _logRequest(RequestOptions options) {
    if (dotenv.env['ENABLE_LOGGING'] == 'true') {
      final method = options.method.toUpperCase();
      final url = options.uri;
      final headers = options.headers;
      
      logger.i('→ $method $url');
      logger.d('Headers: $headers');
      if (options.data != null) {
        logger.d('Body: ${options.data}');
      }
    }
  }
}
```

## Database Configuration

### Local Database Settings

```dart
// lib/providers/database_provider.dart
final databaseProvider = FutureProvider<AppDatabase>((ref) async {
  final useLocal = dotenv.env['USE_LOCAL_DATABASE'] == 'true';
  final clearOnStartup = 
      dotenv.env['CLEAR_DB_ON_STARTUP'] == 'true';
  
  final database = AppDatabase();
  
  if (clearOnStartup) {
    await database.clearDatabase();
  }
  
  return database;
});
```

## Secure Configuration

### Store Sensitive Data

```bash
# Don't commit .env files with sensitive data
echo ".env.local" >> .gitignore
echo ".env.*.local" >> .gitignore
echo "google-services*.json" >> .gitignore
echo "GoogleService-Info*.plist" >> .gitignore
```

### Use Environment Variables

```bash
# Set in CI/CD system (GitHub Actions, Firebase, etc)
# Never hardcode API keys or secrets
```

### GitHub Secrets

```yaml
# .github/workflows/build.yml
env:
  FIREBASE_API_KEY: ${{ secrets.FIREBASE_API_KEY }}
  API_BACKEND_URL: ${{ secrets.API_BACKEND_URL }}
```

## Configuration Checklist

- [ ] Copy appropriate `.env` file for target environment
- [ ] Verify API base URL is correct
- [ ] Check Firebase project ID matches
- [ ] Ensure feature flags are appropriate
- [ ] Confirm logging level (disabled in production)
- [ ] Verify notification settings
- [ ] Test API connectivity
- [ ] Validate Firebase configuration
- [ ] Check database location (local vs cloud)

## Troubleshooting

### Environment Not Loading

```bash
# Rebuild to include new assets
flutter clean
flutter pub get
flutter run
```

### Firebase Configuration Issues

```bash
# Reconfigure all Firebase apps
flutterfire configure --overwrite

# Clear and reinstall
rm ios/Podfile.lock
rm -rf ios/Pods
flutter pub get
```

### API Connection Failures

```dart
// Check in logs
flutter logs

// Verify API base URL
print(dotenv.env['API_BASE_URL']);

// Test endpoint manually
curl 'https://your-api-url/v1/flights'
```

---

For more information, see [README.md](README.md) and [API.md](API.md)
