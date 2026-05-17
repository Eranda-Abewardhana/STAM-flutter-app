# Troubleshooting Guide

## Common Issues and Solutions

### Build & Compilation Issues

#### Issue 1: "Flutter command not found"

**Symptoms:**
```
zsh: command not found: flutter
```

**Solutions:**

```bash
# Check if Flutter is installed
flutter --version

# Add Flutter to PATH (macOS/Linux)
export PATH="$PATH:/path/to/flutter/bin"

# Add to ~/.zshrc or ~/.bashrc permanently
echo 'export PATH="$PATH:/path/to/flutter/bin"' >> ~/.zshrc
source ~/.zshrc

# Windows: Add to System Environment Variables
# 1. Win + X, select System
# 2. Advanced system settings
# 3. Environment Variables
# 4. Add C:\flutter\bin to PATH
```

#### Issue 2: "Gradle build failed"

**Symptoms:**
```
FAILURE: Build failed with an exception.
```

**Solutions:**

```bash
# Clean Gradle cache
cd android
./gradlew clean
cd ..

# Remove build files
rm -rf android/build
rm -rf android/app/build

# Rebuild
flutter clean
flutter pub get
flutter run

# With verbose output
flutter run -v

# If JVM issues:
# Edit android/gradle.properties
# Add: org.gradle.jvmargs=-Xmx4096m
```

#### Issue 3: "build_runner failed to generate code"

**Symptoms:**
```
Failed to generate build files
```

**Solutions:**

```bash
# Clean build_runner cache
flutter pub run build_runner clean

# Regenerate with verbose output
flutter pub run build_runner build -v

# Force delete conflicting outputs
flutter pub run build_runner build --delete-conflicting-outputs

# Check for syntax errors in models
flutter analyze

# Run pub get again
flutter pub get
```

#### Issue 4: "Package not found" errors

**Symptoms:**
```
error: package 'riverpod' not found
```

**Solutions:**

```bash
# Update pubspec.yaml dependencies
flutter pub get

# Ensure all packages installed
flutter pub upgrade

# Check for version conflicts
flutter pub outdated

# Rebuild code generation
flutter pub run build_runner build

# Clean and reinstall
flutter clean
flutter pub get
```

#### Issue 5: Android NDK/SDK errors

**Symptoms:**
```
Android NDK not found or Android SDK not configured
```

**Solutions:**

```bash
# Check SDK installation
flutter doctor -v

# Install missing components
# Option 1: Using Android Studio
# 1. Open Android Studio
# 2. Tools > SDK Manager
# 3. Install Android 34 SDK and Build Tools

# Option 2: Using command line
sdkmanager "platforms;android-34"
sdkmanager "build-tools;34.0.0"
sdkmanager "ndk;25.1.8937393"

# Set ANDROID_HOME
export ANDROID_HOME=$HOME/Library/Android/sdk  # macOS
export ANDROID_HOME=$HOME/Android/Sdk  # Linux
export ANDROID_HOME=%USERPROFILE%\AppData\Local\Android\sdk  # Windows
```

### Firebase & Network Issues

#### Issue 6: "Firebase configuration error"

**Symptoms:**
```
FirebaseException: Failed to initialize Firebase
```

**Solutions:**

```bash
# Reconfigure Firebase
flutterfire configure --project=smart-passenger-alert

# Clear Firebase cache
rm -rf ios/Pods
rm ios/Podfile.lock
cd ios
pod install --repo-update
cd ..

# Rebuild
flutter clean
flutter pub get
flutter run

# Verify files generated
ls android/app/google-services.json
ls ios/Runner/GoogleService-Info.plist
```

#### Issue 7: "FCM token not generated"

**Symptoms:**
```
FCM Token: null
No notification received
```

**Solutions:**

```dart
// Check Firebase initialization
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp();
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization error: $e');
  }
  
  // Get FCM token
  try {
    final token = await FirebaseMessaging.instance.getToken();
    print('FCM Token: $token');
  } catch (e) {
    print('Error getting FCM token: $e');
  }
  
  runApp(const MyApp());
}

// Check in Firebase Console
// 1. Go to Cloud Messaging tab
// 2. Verify Google Play Services configured
// 3. Check APK built with release signing key
```

#### Issue 8: "API connection timeout"

**Symptoms:**
```
DioException: Connection timeout
```

**Solutions:**

```bash
# Test API connectivity
curl -v https://api.travelassistant.local/v1/flights

# Check network settings
# 1. Verify API_BASE_URL in .env file
# 2. Check if backend is running
# 3. Verify firewall settings

# Increase timeout in constants.dart
static const int apiTimeoutMs = 60000; // 60 seconds

# Check Dio configuration
final dio = Dio(
  BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ),
);

# Enable logging to see requests
flutter run -v
flutter logs
```

#### Issue 9: "SSL certificate verification failed"

**Symptoms:**
```
DioException: Bad certificate
HandshakeException: Unhandled exception
```

**Solutions:**

```dart
// For development only (NOT for production)
class UnsafeHttpClient extends HttpClient {
  @override
  SecurityContext get badCertificateCallback =>
      (X509Certificate cert, String host, int port) => true;
}

// Update API service
final dio = Dio();
dio.httpClientAdapter = IOHttpClientAdapter(
  createHttpClient: () => UnsafeHttpClient(),
);

// Better: Use proper certificates
// 1. Get valid SSL certificate
// 2. Reference in SecurityContext
// 3. Test with https://badssl.com/
```

### iOS-Specific Issues

#### Issue 10: "CocoaPods dependency error"

**Symptoms:**
```
[!] CocoaPods could not find compatible versions
```

**Solutions:**

```bash
# Update CocoaPods repository
pod repo update

# Clear pods cache
cd ios
rm -rf Pods
rm Podfile.lock
pod install --repo-update
cd ..

# If still failing
cd ios
rm -rf Pods
rm Podfile.lock
flutter pub get
pod install --repo-update
cd ..

# Check for conflicting versions
pod outdated
```

#### Issue 11: "Xcode build error"

**Symptoms:**
```
Xcode build failed
Swift compilation error
```

**Solutions:**

```bash
# Clean Xcode build
cd ios
rm -rf Pods
rm Podfile.lock
xcode-select --reset
pod install --repo-update
cd ..

flutter clean
flutter pub get
flutter run -v

# Or rebuild from Xcode
# 1. Open Runner.xcworkspace (not .xcodeproj)
# 2. Product > Clean Build Folder (Cmd+Shift+K)
# 3. Product > Build (Cmd+B)
```

#### Issue 12: "iOS simulator launch error"

**Symptoms:**
```
Xcode couldn't find the following Simulators
```

**Solutions:**

```bash
# List available simulators
xcrun simctl list devices

# Erase simulator
xcrun simctl erase <device_id>

# Create new simulator
xcrun simctl create iPhone-15 com.apple.CoreSimulator.SimDeviceType.iPhone-15 com.apple.CoreSimulator.SimRuntime.iOS-17-0

# Boot simulator
xcrun simctl boot <device_id>
open -a Simulator

# Run app
flutter run -d <simulator_id>
```

### Android-Specific Issues

#### Issue 13: "Android emulator won't start"

**Symptoms:**
```
Emulator failed to start
QEMU initialization failed
```

**Solutions:**

```bash
# List available AVDs
emulator -list-avds

# Delete cached data
emulator -avd <avd_name> -wipe-data

# Start emulator
emulator -avd <avd_name> &

# Or use Android Studio
# Virtual Device Manager > Create > Run

# Enable hardware acceleration
# Linux: Check KVM support
kvm-ok

# Windows: Enable Hyper-V or use AMD-V
# Edit android/local.properties
# sdk.dir=/path/to/Android/sdk
# ndk.dir=/path/to/Android/ndk
```

#### Issue 14: "Permission denied to access camera/location"

**Symptoms:**
```
PlatformException: Permission denied
```

**Solutions:**

```dart
// Request permissions at runtime
import 'package:permission_handler/permission_handler.dart';

// In Android: Update AndroidManifest.xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />

// In code:
Future<void> requestPermissions() async {
  final status = await Permission.camera.request();
  if (status.isDenied) {
    print('Permission denied');
  } else if (status.isGranted) {
    print('Permission granted');
  }
}

// Check API level
// targetSdk >= 31 requires additional permissions in manifest
```

### State Management & Provider Issues

#### Issue 15: "Riverpod provider not updating"

**Symptoms:**
```
Widget not rebuilding when data changes
```

**Solutions:**

```dart
// Use correct provider type
// For async data:
final flightsProvider = FutureProvider((ref) async {
  return await apiService.getFlights();
});

// For mutable state:
final alertsProvider = StateNotifierProvider((ref) {
  return AlertNotifier(ref.watch(apiServiceProvider));
});

// For watched providers, use .select() to reduce rebuilds
final selectedFlightProvider = Provider.family((ref, String id) {
  return ref.watch(flightsProvider.select((flights) {
    return flights.maybeWhen(
      data: (f) => f.firstWhere((flight) => flight.id == id),
      orElse: () => null,
    );
  }));
});

// Invalidate cache when needed
ref.invalidate(flightsProvider);

// Check provider dependencies
// Use flutter_riverpod DevTools extension
```

#### Issue 16: "Widget rebuilds too often"

**Symptoms:**
```
Excessive widget rebuilds
Performance degradation
```

**Solutions:**

```dart
// Use .select() to watch specific fields
final currentUserProvider = Provider((ref) {
  return ref.watch(userNotifierProvider.select(
    (notifier) => notifier.currentUser?.name ?? '',
  ));
});

// Use const constructors
const SizedBox(height: 16);

// Use RepaintBoundary for expensive widgets
class ExpensiveWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ExpensiveChart(),
    );
  }
}

// Profile with DevTools
# Connect to running app
flutter pub global activate devtools
devtools

# Or use: Tools > Dart DevTools in VS Code
```

### Navigation Issues

#### Issue 17: "Navigation route not found"

**Symptoms:**
```
NoSuchMethodError: Navigator route not found
```

**Solutions:**

```dart
// Verify route is defined
if (GoRouter.of(context).canPop()) {
  GoRouter.of(context).pop();
} else {
  GoRouter.of(context).go('/home');
}

// Check route configuration
final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => HomePage()),
    GoRoute(path: '/login', builder: (context, state) => LoginPage()),
  ],
);

// Debug route state
GoRouter.of(context).routerDelegate.currentConfiguration

// Test navigation in debug mode
flutter run --verbose
# Look for "Navigating to" logs
```

#### Issue 18: "Deep linking not working"

**Symptoms:**
```
Deep link not opening app
Incorrect route opened
```

**Solutions:**

```bash
# Test deep link on Android
adb shell am start -W -a android.intent.action.VIEW \
  -d "smartpassenger://flight/BA173" \
  com.smartpassenger.alert

# Test on iOS
xcrun simctl openurl booted "smartpassenger://flight/BA173"

# Verify deep link configuration
# Android: Check AndroidManifest.xml
<intent-filter>
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="smartpassenger" />
</intent-filter>

# iOS: Check Info.plist
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>smartpassenger</string>
    </array>
  </dict>
</array>
```

### Data & Database Issues

#### Issue 19: "Hive database corruption"

**Symptoms:**
```
HiveError: Box not found
can't read from closed box
```

**Solutions:**

```dart
// Rebuild Hive database
Directory hiveDir = Directory('path/to/hive');
await Hive.close();
await hiveDir.delete(recursive: true);
await Hive.openBox('flights');

// Clear specific box
final box = Hive.box('flights');
await box.clear();

// Check box status
print(Hive.isBoxOpen('flights'));
print(Hive.boxes.keys);
```

#### Issue 20: "JSON serialization errors"

**Symptoms:**
```
SerializationException: unknown property 'newField'
```

**Solutions:**

```dart
// Update model to ignore unknown properties
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable(ignoreUnannotated: true)
class Flight {
  @JsonKey(name: 'flightNumber')
  final String flightNumber;
}

// Regenerate JSON code
flutter pub run build_runner build --delete-conflicting-outputs

// Handle null values properly
@JsonSerializable()
class Flight {
  @JsonKey(defaultValue: 'UNKNOWN')
  final String flightNumber;
  
  final int? delayMinutes; // nullable
}
```

### Performance Issues

#### Issue 21: "App crashes on large list"

**Symptoms:**
```
Out of memory
Frame drops to 0 FPS
```

**Solutions:**

```dart
// Use ListView.builder instead of ListView
ListView.builder(
  itemCount: flights.length,
  itemBuilder: (context, index) {
    return FlightCard(flight: flights[index]);
  },
);

// Implement pagination
final paginatedFlightsProvider = FutureProvider((ref) async {
  final page = ref.watch(currentPageProvider);
  return await apiService.getFlights(page: page);
});

// Cache images
Image.network(
  imageUrl,
  cacheHeight: 200,
  cacheWidth: 200,
);

// Profile memory
flutter run --profile

# Enable memory profiling
# Dart DevTools > Memory tab
```

#### Issue 22: "Network requests are slow"

**Symptoms:**
```
API calls take 10+ seconds
High latency
```

**Solutions:**

```dart
// Implement caching
final flightsProvider = FutureProvider((ref) async {
  final cachedFlights = ref.read(cachedFlightsProvider);
  return cachedFlights ?? await apiService.getFlights();
});

// Use request timeout
const duration = Duration(seconds: 10);
Future.delayed(duration).then((_) {
  if (!mounted) return;
  showError('Request timeout');
});

// Compress requests
dio.interceptors.add(
  LoggingInterceptor(
    logPrint: (msg) => log(msg),
  ),
);

// Monitor with Charles/Fiddler
# Use HTTP proxy to inspect requests
# Set proxy URL in Dio
```

### Notification Issues

#### Issue 23: "Push notifications not received"

**Symptoms:**
```
FCM notifications not sent
Notification payload null
```

**Solutions:**

```dart
// Check notification permission
Future<void> checkNotificationPermission() async {
  final settings = await FirebaseMessaging.instance.getNotificationSettings();
  print('Notification authorization: ${settings.authorizationStatus}');
  
  if (settings.authorizationStatus == 
      AuthorizationStatus.notDetermined) {
    await FirebaseMessaging.instance.requestPermission();
  }
}

// Enable debug logging
FirebaseMessaging.instance.setAutoInitEnabled(true);

// Test notification from Console
# Firebase Console > Cloud Messaging
# Send test notification to FCM token

// Handle notification in foreground
FirebaseMessaging.onMessage.listen((message) {
  print('Message received: ${message.data}');
  // Handle notification
});

// Check notification service is initialized
await NotificationService().initialize();
```

#### Issue 24: "Notification sound not playing"

**Symptoms:**
```
Notification received but silent
```

**Solutions:**

```dart
# Android: Create notification channel
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  id: 'high_importance_channel',
  name: 'High Importance Notifications',
  description: 'This channel is used for important notifications.',
  importance: Importance.high,
  sound: RawResourceAndroidNotificationSound('notification_sound'),
  enableVibration: true,
);

await flutterLocalNotificationsPlugin
    .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
    ?.createNotificationChannel(channel);

# iOS: Add sound file
# Copy notification sound to ios/Runner/
# Add to Info.plist
```

### Debugging Techniques

#### Enable Verbose Logging

```bash
# Run with verbose output
flutter run -v

# Watch logs in real-time
flutter logs

# Save logs to file
flutter logs > app_logs.txt
```

#### Use DevTools

```bash
# Launch DevTools
flutter pub global activate devtools
devtools

# Or in IDE
# VS Code: Debug tab
# Android Studio: Tools > Dart DevTools
```

#### Check Device Logs

```bash
# Android logcat
adb logcat | grep flutter

# iOS system logs
log stream --device --predicate 'eventMessage contains[cd] "flutter"'
```

### Getting Help

1. **Check Flutter Status**
   ```bash
   flutter doctor -v
   ```

2. **Search Similar Issues**
   - GitHub Issues
   - Stack Overflow (tag: flutter)
   - Flutter Community

3. **File Bug Report**
   - GitHub Issues with minimal reproducible example
   - Include `flutter doctor` output
   - Share complete error logs

4. **Reach Out**
   - Flutter Community Discord
   - Firebase Slack community
   - StackOverflow

---

**Still stuck?** Create an issue with:
- Full error message
- `flutter doctor -v` output
- Minimal reproducible code
- Steps to reproduce
