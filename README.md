# Smart Passenger Alert System – AI Travel Assistant

A production-level Flutter mobile application integrating real-time airport data, AI-based flight delay prediction, smartwatch sensor integration, and intelligent travel optimization.

## 🎯 Features

### 1. **Real-Time Flight Tracking**
- Integration with airport operational database (AODB)
- Live flight status, gate, and timing updates
- Flight history and favorite management
- Beautiful premium flight cards with glow effects

### 2. **AI-Based Delay Prediction**
- Machine learning model integration (Logistic Regression/Random Forest)
- Probabilistic delay predictions with confidence scores
- Impact factor analysis (weather, mechanical, traffic)
- Real-time recommendations

### 3. **Smart Travel Optimization**
- Intelligent travel time calculation
- Weather impact assessment
- Route optimization
- Leave-by time recommendations

### 4. **Smartwatch Integration (ESP32)**
- Heart rate monitoring (MAX30102 sensor)
- Movement detection (MPU6050 sensor)
- Sleep phase detection
- Vitality metrics tracking

### 5. **Sleep Detection System**
- Automatic sleep phase classification
- Optimal wake-up window detection
- AI-powered sleep recommendations
- Integration with flight schedules

### 6. **Firebase Cloud Messaging (FCM)**
- Push notifications for flight alerts
- Boarding notifications
- Travel reminders
- Real-time updates

### 7. **Intelligent Dashboard**
- Personalized greeting
- Current flight status card
- AI prediction card
- Weather information
- Quick action buttons
- Destination spotlight

### 8. **Intelligence Center**
- Real-time AI chat Interface
- Flight delay analysis
- Environmental monitoring
- Personalized recommendations

### 9. **Vitality Monitoring**
- Live heart rate tracking
- Sleep phase analysis
- Energy level assessment
- Stress monitoring

## 🏗️ Project Structure

```
lib/
├── animations/          # Custom animations and transitions
├── models/              # Data models with JSON serialization
├── providers/           # Riverpod state management
├── screens/             # Screens/pages
├── services/            # API, Firebase, Notifications
├── theme/               # Theme and styling
├── utils/               # Constants, helpers, validators
├── widgets/             # Reusable UI components
└── main.dart            # App entry point
```

## 🛠️ Tech Stack

### Frontend
- **Flutter** - Cross-platform mobile development
- **Dart** - Programming language
- **Riverpod** - State management
- **Provider** - Additional state management

### Backend Integration
- **REST APIs** - Hotel/Airport data, predictions
- **Dio** - HTTP client
- **JSON Serialization** - Type-safe JSON handling

### Firebase
- **Firebase Core** - Initialization
- **Firebase Messaging (FCM)** - Push notifications
- **Firebase Analytics** - Usage tracking

### Local Data
- **Shared Preferences** - Key-value storage
- **Hive** - Local database

### UI/UX
- **Glassmorphism** - Modern glass-effect containers
- **Custom Animations** - Fade, slide, scale, pulse effects
- **Dark Theme** - Dark mode with neon accents
- **Smooth Transitions** - Professional animations

## 📲 Getting Started

### Prerequisites
- Flutter SDK (v3.0.0 or higher)
- Dart SDK (v3.0.0 or higher)
- Android Studio / Xcode
- Firebase account
- Postman collection for API testing

### 1. Installation

```bash
# Clone the repository
git clone <repository-url>

# Navigate to project directory
cd smart_passenger_alert

# Get dependencies
flutter pub get

# Generate code (JSON serialization, Riverpod, etc.)
flutter pub run build_runner build
```

### 2. Firebase Setup

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Configure Flutter for Firebase
flutterfire configure --project=<project-id>
```

### 3. Backend Configuration

Update the API base URL in [lib/services/api_service.dart](lib/services/api_service.dart):

```dart
static const String baseUrl = 'https://your-api-endpoint.com/v1';
```

Configure your Postman collection endpoints:
- GET `/flights` - Fetch flights
- POST `/predict-delay` - Get delay predictions
- GET `/weather/{airport}` - Weather data
- POST `/sensor-data` - Send sensor readings

### 4. Run the App

```bash
# Run on debug mode
flutter run

# Run on release mode
flutter run --release

# Run on specific device
flutter run -d <device-id>
```

## 📱 Screen Overview

### Splash Screen
- Animated logo and app name
- Smooth transition to login

### Login Screen
- Email/password authentication
- Social login options (Google, Apple)
- Sign up tab for new users

### Dashboard
- User greeting with current date/time
- Current flight card with status
- AI prediction card
- Travel information card
- Quick action buttons
- Destination spotlight
- Bottom navigation bar

### Flight Details
- Flight status and timeline
- Seat assignment information
- Baggage tracking
- Flight progress timeline
- AI delay prediction details

### Live Vitality
- Heart rate monitoring
- Sleep phase detection
- Sleep quality analysis
- Optimal wake-up window
- Environmental conditions

### Alerts Screen
- Real-time alerts and notifications
- Filter by criticality
- Alert management
- Action buttons for each alert

### Intelligence Center
- AI chatbot interface
- Real-time flight analysis
- System alerts and recommendations
- Natural language queries

## 🔌 API Integration

### Flight Data
```json
{
  "id": "FL001",
  "flightNumber": "UL123",
  "airline": "Emirates",
  "origin": "CMB",
  "destination": "DXB",
  "departureTime": "2024-10-24T08:30:00Z",
  "arrivalTime": "2024-10-24T13:00:00Z",
  "gate": "B14",
  "status": "delayed",
  "delayMinutes": 30
}
```

### Prediction Response
```json
{
  "id": "PRED001",
  "flightId": "FL001",
  "delayProbability": 0.75,
  "estimatedDelayMinutes": 30,
  "impactFactor": "Storm Cell",
  "recommendation": "High probability of delay due to weather",
  "confidence": 0.84
}
```

### Sensor Data
```json
{
  "id": "SENSOR001",
  "userId": "USER123",
  "heartRate": 62,
  "movement": 5.2,
  "temperature": 36.8,
  "oxygenLevel": 98,
  "sleepPhase": "LIGHT_SLEEP",
  "timestamp": "2024-10-24T02:30:00Z"
}
```

## 🎨 Theme & Styling

### Color Palette
- **Primary Blue**: #5B9EFF
- **Neon Green**: #32D74B
- **Neon Purple**: #BF5AF0
- **Dark Background**: #0F1419
- **Card Background**: #1A202C

### Typography
- **Display**: SF Pro Display (28-32px, bold)
- **Body**: Poppins (14-16px, regular)
- **Labels**: San Francisco (10-12px, semibold)

### Effects
- Glassmorphism with backdrop blur
- Neon glow shadows on alerts
- Smooth fade and slide animations
- Rounded corners (12-24px radius)

## 🔐 Security

- **Authentication**: JWT token handling
- **Data Encryption**: Secure local storage with Hive
- **API Security**: HTTPS only, request validation
- **Permission Handling**: Runtime permissions for sensors
- **Token Refresh**: Automatic token refresh on expiration

## 📊 State Management

### Providers Architecture
```
app_providers.dart
├── API Service Provider
├── Flight Providers
│   ├── flightsProvider
│   ├── flightDetailsProvider
│   └── flightFavoritesProvider
├── Prediction Providers
│   ├── delayPredictionProvider
│   └── allPredictionsProvider
├── User Providers
│   ├── currentUserProvider
│   └── userNotifierProvider
├── Alerts Providers
│   ├── alertsProvider
│   └── alertsNotifierProvider
└── Sensor Providers
    ├── latestSensorDataProvider
    ├── sleepAnalysisProvider
    └── vitalityMetricsProvider
```

## 🧪 Testing

### Unit Tests
```bash
flutter test
```

### Widget Tests
```bash
flutter test --verbose
```

### Integration Tests
```bash
flutter test integration_test/
```

## 📈 Performance Optimization

- **Image Caching**: Cached network images
- **List Optimization**: Efficient scrolling with ListView.separated
- **Animation Performance**: Hardware-accelerated animations
- **State Management**: Efficient provider updates
- **Memory Management**: Proper disposal of controllers

## 🚀 Deployment

### Android

1. Generate signed APK:
```bash
flutter build apk --split-per-abi --release
```

2. Generate signed AAB for Play Store:
```bash
flutter build appbundle --release
```

### iOS

1. Build for iOS:
```bash
flutter build ios --release
```

2. Upload to App Store using Xcode:
```bash
open ios/Runner.xcworkspace
```

## 📝 Environment Variables

Create a `.env` file:
```
API_BASE_URL=https://api.example.com/v1
FCM_SERVER_KEY=your_fcm_key
FIREBASE_PROJECT_ID=your_project_id
```

## 🐛 Troubleshooting

### Build Issues
```bash
# Clean build
flutter clean
flutter pub get

# Rebuild generated files
flutter pub run build_runner build --delete-conflicting-outputs
```

### Firebase Issues
```bash
# Reconfigure Firebase
flutterfire configure --project=<project-id> --overwrite
```

### Device Issues
```bash
# Get device list
flutter devices

# Doctor check
flutter doctor -v
```

## 📚 Documentation

- [Flutter Docs](https://flutter.dev/docs)
- [Riverpod Docs](https://riverpod.dev)
- [Firebase Docs](https://firebase.google.com/docs)
- [Dio Docs](https://pub.dev/packages/dio)

## 🤝 Contributing

1. Create a feature branch
2. Commit your changes
3. Push to the branch
4. Create a Pull Request

## 📄 License

This project is proprietary and confidential.

## 👤 Author

Smart Passenger Alert System Development Team

## 📞 Support

For support, email: support@smartpassenger.local

---

**Last Updated**: April 2026  
**Version**: 1.0.0  
**Status**: Production Ready
# STAM-flutter-app
