import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Models for Python Backend API Responses

class FlightDelayPrediction {
  final bool success;
  final String prediction; // "Yes" or "No"
  final bool delayPredicted;
  final String riskLevel; // "Very High", "High", "Low", "Very Low"
  final String confidence; // "95.2%"
  final String recommendation;
  final DateTime timestamp;
  final String? error;

  FlightDelayPrediction({
    required this.success,
    required this.prediction,
    required this.delayPredicted,
    required this.riskLevel,
    required this.confidence,
    required this.recommendation,
    required this.timestamp,
    this.error,
  });

  /// Parse confidence string "95.2%" to double (95.2)
  double get confidenceValue {
    try {
      final cleaned = confidence.replaceAll('%', '').trim();
      return double.parse(cleaned);
    } catch (e) {
      return 0.0;
    }
  }

  factory FlightDelayPrediction.fromJson(Map<String, dynamic> json) {
    return FlightDelayPrediction(
      success: json['success'] ?? false,
      prediction: json['prediction'] ?? 'Unknown',
      delayPredicted: json['delay_predicted'] ?? false,
      riskLevel: json['risk_level'] ?? 'Unknown',
      confidence: json['confidence'] ?? '0%',
      recommendation: json['recommendation'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      error: json['error'],
    );
  }

  factory FlightDelayPrediction.error(String message) {
    return FlightDelayPrediction(
      success: false,
      prediction: 'Error',
      delayPredicted: false,
      riskLevel: 'Unknown',
      confidence: '0%',
      recommendation: '',
      timestamp: DateTime.now(),
      error: message,
    );
  }
}

class SleepDetectionResult {
  final bool success;
  final String state; // "Yes" or "No"
  final bool isSleeping;
  final String confidence; // "95.2%"
  final String sleepQuality; // "Deep Sleep", "Light Sleep", "Good", "Awake"
  final VitalSigns vitalSigns;
  final List<String> alerts;
  final String recommendation;
  final DateTime timestamp;
  final String? error;

  SleepDetectionResult({
    required this.success,
    required this.state,
    required this.isSleeping,
    required this.confidence,
    required this.sleepQuality,
    required this.vitalSigns,
    required this.alerts,
    required this.recommendation,
    required this.timestamp,
    this.error,
  });

  /// Parse confidence string "95.2%" to double (95.2)
  double get confidenceValue {
    try {
      final cleaned = confidence.replaceAll('%', '').trim();
      return double.parse(cleaned);
    } catch (e) {
      return 0.0;
    }
  }

  factory SleepDetectionResult.fromJson(Map<String, dynamic> json) {
    return SleepDetectionResult(
      success: json['success'] ?? false,
      state: json['state'] ?? 'Unknown',
      isSleeping: json['is_sleeping'] ?? false,
      confidence: json['confidence'] ?? '0%',
      sleepQuality: json['sleep_quality'] ?? 'Unknown',
      vitalSigns: VitalSigns.fromJson(json['vital_signs'] ?? {}),
      alerts: List<String>.from(json['alerts'] ?? []),
      recommendation: json['recommendation'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      error: json['error'],
    );
  }

  factory SleepDetectionResult.error(String message) {
    return SleepDetectionResult(
      success: false,
      state: 'Error',
      isSleeping: false,
      confidence: '0%',
      sleepQuality: 'Unknown',
      vitalSigns: VitalSigns.empty(),
      alerts: [],
      recommendation: '',
      timestamp: DateTime.now(),
      error: message,
    );
  }
}

class VitalSigns {
  final int heartRate;
  final int movementLevel;
  final double bodyTemperature;
  final int oxygenSaturation;
  final int timeOfDay;

  VitalSigns({
    required this.heartRate,
    required this.movementLevel,
    required this.bodyTemperature,
    required this.oxygenSaturation,
    required this.timeOfDay,
  });

  factory VitalSigns.fromJson(Map<String, dynamic> json) {
    return VitalSigns(
      heartRate: json['heart_rate'] ?? 0,
      movementLevel: json['movement_level'] ?? 0,
      bodyTemperature: (json['body_temperature'] ?? 0.0).toDouble(),
      oxygenSaturation: json['oxygen_saturation'] ?? 0,
      timeOfDay: json['time_of_day'] ?? 0,
    );
  }

  factory VitalSigns.empty() {
    return VitalSigns(
      heartRate: 0,
      movementLevel: 0,
      bodyTemperature: 0.0,
      oxygenSaturation: 0,
      timeOfDay: 0,
    );
  }
}

/// Service to communicate with Python Backend Modules

class PythonBackendService {
  // Base URLs - adjust for your machine/deployment
  // For Android Emulator: http://10.0.2.2:PORT
  // For Physical Device: http://YOUR_MACHINE_IP:PORT
  static String get _module2BaseUrl => _resolveBackendUrl(5000);
  static String get _module3BaseUrl => _resolveBackendUrl(5001);
  static const Duration _timeout = Duration(seconds: 30);

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

  /// ==================== MODULE 2 - FLIGHT DELAY PREDICTION ====================

  /// Predict flight delay
  static Future<FlightDelayPrediction> predictFlightDelay({
    required String weather,
    required String trafficLevel,
    required int departureHour,
    required String aircraftType,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_module2BaseUrl/predict'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'weather': weather,
              'traffic_level': trafficLevel,
              'departure_hour': departureHour,
              'aircraft_type': aircraftType,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return FlightDelayPrediction.fromJson(data);
      } else {
        return FlightDelayPrediction.error(
          'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return FlightDelayPrediction.error('Error predicting flight delay: $e');
    }
  }

  /// Batch predict multiple flights
  static Future<List<FlightDelayPrediction>> batchPredictFlights({
    required List<Map<String, dynamic>> flights,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_module2BaseUrl/batch-predict'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'flights': flights}),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final predictions = (data['predictions'] as List)
              .map((p) => FlightDelayPrediction.fromJson(p))
              .toList();
          return predictions;
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Check Module 2 health
  static Future<bool> checkModule2Health() async {
    try {
      final response = await http
          .get(Uri.parse('$_module2BaseUrl/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// ==================== MODULE 3 - SLEEP DETECTION ====================

  /// Detect sleep state from smartwatch sensor data
  static Future<SleepDetectionResult> detectSleepState({
    required int heartRate,
    required int movementLevel,
    required double bodyTemperature,
    required int oxygenSaturation,
    required int timeOfDay,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_module3BaseUrl/detect'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'heart_rate': heartRate,
              'movement_level': movementLevel,
              'body_temperature': bodyTemperature,
              'oxygen_saturation': oxygenSaturation,
              'time_of_day': timeOfDay,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SleepDetectionResult.fromJson(data);
      } else {
        return SleepDetectionResult.error(
          'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return SleepDetectionResult.error('Error detecting sleep state: $e');
    }
  }

  /// Batch detect sleep state for multiple passengers
  static Future<List<SleepDetectionResult>> batchDetectSleep({
    required List<Map<String, dynamic>> readings,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_module3BaseUrl/batch-detect'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'readings': readings}),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final predictions = (data['predictions'] as List)
              .map((p) => SleepDetectionResult.fromJson(p))
              .toList();
          return predictions;
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get alert statistics from batch detection
  static Future<Map<String, dynamic>> getAlertStats({
    required List<Map<String, dynamic>> readings,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_module3BaseUrl/alert-stats'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'readings': readings}),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['statistics'] ?? {};
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  /// Check Module 3 health
  static Future<bool> checkModule3Health() async {
    try {
      final response = await http
          .get(Uri.parse('$_module3BaseUrl/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// ==================== HELPER METHODS ====================

  /// Check if both backend modules are running
  static Future<bool> checkBackendHealth() async {
    final module2Health = await checkModule2Health();
    final module3Health = await checkModule3Health();
    return module2Health && module3Health;
  }

  /// Get API info from Module 2
  static Future<Map<String, dynamic>> getModule2Info() async {
    try {
      final response = await http
          .get(Uri.parse('$_module2BaseUrl/info'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      // Silent failure
    }
    return {};
  }

  /// Get API info from Module 3
  static Future<Map<String, dynamic>> getModule3Info() async {
    try {
      final response = await http
          .get(Uri.parse('$_module3BaseUrl/info'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      // Silent failure
    }
    return {};
  }
}
