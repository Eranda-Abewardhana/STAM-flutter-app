import 'package:flutter/foundation.dart';

class AppConstants {
  // API Configuration
  static const String apiBaseUrl = 'https://api.travelassistant.local/v1';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Python Backend Configuration
  // Desktop/Web: localhost, Android Emulator: 10.0.2.2
  static String get pythonModule2BaseUrl => _resolveBackendUrl(5000); // Flight Delay Prediction
  static String get pythonModule3BaseUrl => _resolveBackendUrl(5001); // Sleep Detection
  static const Duration pythonBackendTimeout = Duration(seconds: 30);

  static String _resolveBackendUrl(int port) {
    final useLocalhost =
        kIsWeb ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS;

    if (useLocalhost) {
      return 'http://127.0.0.1:$port';
    }

    return 'http://10.0.2.2:$port';
  }

  // Sri Lanka Route Defaults
  static const String defaultOriginAirport = 'CMB';
  static const String defaultDestinationAirport = 'DXB';

  // Firebase Configuration
  static const String fcmServerKey = 'YOUR_FCM_SERVER_KEY';
  static const String projectId = 'smart-passenger-alert';

  // Feature Flags
  static const bool enableOfflineMode = true;
  static const bool enableAnalytics = true;
  static const bool enableCrashlytics = true;

  // Notification Settings
  static const String flightAlertsChannel = 'flight_alerts';
  static const String generalNotificationsChannel = 'general';
  static const String urgentAlertsChannel = 'urgent_alerts';

  // Database Configuration
  static const String dbName = 'smart_passenger_alert.db';
  static const int dbVersion = 1;

  // Sensor Configuration
  static const int heartRateRefreshIntervalMs = 5000;
  static const int movementSensorIntervalMs = 10000;
  static const double normalhealthyHeartRateMin = 40.0;
  static const double normalHealthyHeartRateMax = 120.0;

  // Sleep Detection Configuration
  static const double sleepDetectionMovementThreshold = 10.0;
  static const double sleepDetectionHeartRateThreshold = 60.0;
  static const int sleepDetectionDurationSeconds = 300;

  // Prediction Thresholds
  static const double highDelayProbabilityThreshold = 0.7;
  static const double moderateDelayProbabilityThreshold = 0.4;

  // UI Configuration
  static const int animationDurationMs = 400;
  static const int fastAnimationDurationMs = 200;
  static const int slowAnimationDurationMs = 800;

  // Refresh Intervals
  static const Duration flightDataRefreshInterval = Duration(minutes: 5);
  static const Duration weatherRefreshInterval = Duration(minutes: 30);
  static const Duration predictionRefreshInterval = Duration(minutes: 15);
  static const Duration sensorDataRefreshInterval = Duration(seconds: 30);

  // Error Messages
  static const Map<String, String> errorMessages = {
    'network_error': 'Network error. Please check your connection.',
    'timeout_error': 'Request timeout. Please try again.',
    'server_error': 'Server error. Please try again later.',
    'auth_error': 'Authentication failed. Please log in again.',
    'invalid_data': 'Invalid data received from server.',
    'sensor_error': 'Failed to read sensor data.',
    'permission_denied': 'Permission denied. Please grant access.',
  };

  // Success Messages
  static const Map<String, String> successMessages = {
    'alert_set': 'Alert set successfully!',
    'flight_updated': 'Flight information updated.',
    'sensor_synced': 'Sensor data synchronized.',
    'profile_updated': 'Profile updated successfully!',
  };
}

class DateTimeFormats {
  static const String timeFormat = 'HH:mm';
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String monthFormat = 'MMMM';
}

class FlightStatus {
  static const String onTime = 'on time';
  static const String delayed = 'delayed';
  static const String cancelled = 'cancelled';
  static const String departed = 'departed';
  static const String boarding = 'boarding';
  static const String scheduled = 'scheduled';
  static const String unknown = 'unknown';
}

class AlertTypes {
  static const String flightDelay = 'flight_delay';
  static const String boarding = 'boarding';
  static const String weather = 'weather';
  static const String sleepAlert = 'sleep_alert';
  static const String travelReminder = 'travel_reminder';
  static const String maintenance = 'maintenance';
  static const String custom = 'custom';
}

class AlertSeverity {
  static const String critical = 'critical';
  static const String warning = 'warning';
  static const String info = 'info';
  static const String success = 'success';
}

class SleepPhases {
  static const String awake = 'AWAKE';
  static const String lightSleep = 'LIGHT_SLEEP';
  static const String deepSleep = 'DEEP_SLEEP';
  static const String remCycle = 'REM_CYCLE';
}
