# Flutter Integration Guide

This guide shows how to integrate the Python backend APIs into your Flutter application.

## Table of Contents
1. [HTTP Setup](#http-setup)
2. [Module 2 Integration - Flight Delay Prediction](#module-2-integration)
3. [Module 3 Integration - Sleep Detection](#module-3-integration)
4. [Error Handling](#error-handling)
5. [Testing](#testing)

---

## HTTP Setup

### 1. Add Dependencies to pubspec.yaml

```yaml
dependencies:
  http: ^1.2.0
  dio: ^5.3.0
```

Run:
```bash
flutter pub get
```

### 2. Create API Service Layer

Create `lib/services/python_api_service.dart`:

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class PythonApiService {
  // For Android emulator
  static const String module2BaseUrl = 'http://10.0.2.2:5000';
  static const String module3BaseUrl = 'http://10.0.2.2:5001';
  
  // For physical device (replace with your machine IP)
  // static const String module2BaseUrl = 'http://192.168.x.x:5000';
  // static const String module3BaseUrl = 'http://192.168.x.x:5001';

  static const Duration timeout = Duration(seconds: 30);

  // Module 2 - Flight Prediction
  static Future<Map<String, dynamic>> predictFlightDelay({
    required String weather,
    required String trafficLevel,
    required int departureHour,
    required String aircraftType,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$module2BaseUrl/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'weather': weather,
          'traffic_level': trafficLevel,
          'departure_hour': departureHour,
          'aircraft_type': aircraftType,
        }),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to predict delay: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error predicting flight delay: $e');
    }
  }

  // Module 2 - Batch Prediction
  static Future<Map<String, dynamic>> batchPredictFlights({
    required List<Map<String, dynamic>> flights,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$module2BaseUrl/batch-predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'flights': flights}),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to batch predict: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error in batch prediction: $e');
    }
  }

  // Module 3 - Sleep Detection
  static Future<Map<String, dynamic>> detectSleepState({
    required int heartRate,
    required int movementLevel,
    required double bodyTemperature,
    required int oxygenSaturation,
    required int timeOfDay,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$module3BaseUrl/detect'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'heart_rate': heartRate,
          'movement_level': movementLevel,
          'body_temperature': bodyTemperature,
          'oxygen_saturation': oxygenSaturation,
          'time_of_day': timeOfDay,
        }),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to detect sleep: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error detecting sleep state: $e');
    }
  }

  // Module 3 - Batch Sleep Detection
  static Future<Map<String, dynamic>> batchDetectSleep({
    required List<Map<String, dynamic>> readings,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$module3BaseUrl/batch-detect'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'readings': readings}),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to batch detect sleep: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error in batch sleep detection: $e');
    }
  }

  // Health Check
  static Future<bool> checkModule2Health() async {
    try {
      final response = await http.get(
        Uri.parse('$module2BaseUrl/health'),
      ).timeout(Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> checkModule3Health() async {
    try {
      final response = await http.get(
        Uri.parse('$module3BaseUrl/health'),
      ).timeout(Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
```

---

## Module 2 Integration

### Flight Delay Prediction in Flight Details Screen

Update `lib/screens/flight_details_screen.dart`:

```dart
import 'package:smart_passenger_alert/services/python_api_service.dart';

class FlightDetailsScreen extends StatefulWidget {
  final Flight flight;
  
  const FlightDetailsScreen({required this.flight});

  @override
  State<FlightDetailsScreen> createState() => _FlightDetailsScreenState();
}

class _FlightDetailsScreenState extends State<FlightDetailsScreen> {
  Map<String, dynamic>? delayPrediction;
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _getPrediction();
  }

  Future<void> _getPrediction() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final prediction = await PythonApiService.predictFlightDelay(
        weather: _getCurrentWeather(),
        trafficLevel: _getTrafficLevel(),
        departureHour: widget.flight.departureTime.hour,
        aircraftType: widget.flight.aircraftType,
      );

      setState(() {
        delayPrediction = prediction;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  String _getCurrentWeather() {
    // Get from weather service or API
    return 'Clear';
  }

  String _getTrafficLevel() {
    // Get from traffic service
    return 'Low';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flight ${widget.flight.flightNumber}')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // ... existing flight details ...

          SizedBox(height: 24),
          Text('AI Delay Prediction', style: Theme.of(context).textTheme.headlineSmall),
          SizedBox(height: 12),

          if (isLoading)
            Center(child: CircularProgressIndicator())
          else if (errorMessage != null)
            Text('Error: $errorMessage', style: TextStyle(color: Colors.red))
          else if (delayPrediction != null)
            _buildPredictionCard(delayPrediction!)
          else
            Text('No prediction available'),
        ],
      ),
    );
  }

  Widget _buildPredictionCard(Map<String, dynamic> prediction) {
    final riskLevel = prediction['risk_level'] ?? 'Unknown';
    final confidence = prediction['confidence'] ?? 'N/A';
    final recommendation = prediction['recommendation'] ?? '';

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Delay Risk: $riskLevel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(confidence, style: TextStyle(color: Colors.grey)),
              ],
            ),
            SizedBox(height: 12),
            Text(recommendation),
          ],
        ),
      ),
    );
  }
}
```

---

## Module 3 Integration

### Sleep Detection in Vitality Screen

Update `lib/screens/vitality_screen.dart`:

```dart
import 'package:smart_passenger_alert/services/python_api_service.dart';

class VitalityScreen extends StatefulWidget {
  @override
  State<VitalityScreen> createState() => _VitalityScreenState();
}

class _VitalityScreenState extends State<VitalityScreen> {
  Map<String, dynamic>? sleepState;
  bool isMonitoring = false;

  Future<void> _checkSleepState() async {
    try {
      // In real app, get from smartwatch sensors
      int heartRate = 58;
      int movementLevel = 1;
      double bodyTemp = 36.5;
      int oxygen = 98;
      int hour = DateTime.now().hour;

      final result = await PythonApiService.detectSleepState(
        heartRate: heartRate,
        movementLevel: movementLevel,
        bodyTemperature: bodyTemp,
        oxygenSaturation: oxygen,
        timeOfDay: hour,
      );

      setState(() {
        sleepState = result;
      });

      // Show alerts if any
      if (result['alerts'] != null && result['alerts'].isNotEmpty) {
        _showAlerts(result['alerts']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error detecting sleep state: $e')),
      );
    }
  }

  void _showAlerts(List alerts) {
    for (String alert in alerts) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(alert),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Vitality Monitor')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (sleepState != null) ...[
              Text(
                'State: ${sleepState!['state']}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text('Quality: ${sleepState!['sleep_quality']}'),
              Text('Confidence: ${sleepState!['confidence']}'),
            ] else
              Text('Press button to check sleep state'),
            
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _checkSleepState,
              child: Text('Check Sleep State'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Error Handling

```dart
try {
  final prediction = await PythonApiService.predictFlightDelay(...);
  
  if (prediction['success'] == false) {
    print('Prediction failed: ${prediction['error']}');
  } else {
    print('Risk Level: ${prediction['risk_level']}');
  }
} on SocketException {
  print('Network error - backend server not reachable');
} on TimeoutException {
  print('Request timeout');
} catch (e) {
  print('Unexpected error: $e');
}
```

---

## Testing

### Test Both Modules

```dart
// In your test widget
FloatingActionButton(
  onPressed: () async {
    // Test Module 2
    bool m2Health = await PythonApiService.checkModule2Health();
    print('Module 2 Health: $m2Health');

    // Test Module 3
    bool m3Health = await PythonApiService.checkModule3Health();
    print('Module 3 Health: $m3Health');

    // Test prediction
    var prediction = await PythonApiService.predictFlightDelay(
      weather: 'Clear',
      trafficLevel: 'Low',
      departureHour: 8,
      aircraftType: 'Boeing 777',
    );
    print('Prediction: $prediction');

    // Test sleep detection
    var sleepState = await PythonApiService.detectSleepState(
      heartRate: 60,
      movementLevel: 2,
      bodyTemperature: 36.5,
      oxygenSaturation: 98,
      timeOfDay: 23,
    );
    print('Sleep State: $sleepState');
  },
  child: Icon(Icons.bug_report),
),
```

---

## Production Deployment

For production, update your API URLs:

```dart
// lib/utils/constants.dart
class AppConstants {
  static const String pythonModule2Url = 'https://api.travelassistant.com/module2';
  static const String pythonModule3Url = 'https://api.travelassistant.com/module3';
}
```

---

## Troubleshooting

### Connection Refused
- Ensure Python backend is running
- Check ports 5000 and 5001 are accessible
- For emulator, use `10.0.2.2` instead of `localhost`

### CORS Errors
- Backend has CORS enabled
- If still issues, check Flask version

### Slow Predictions
- First prediction trains model (~5 seconds)
- Subsequent predictions ~50-100ms
- Consider caching results
