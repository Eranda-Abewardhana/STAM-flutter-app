import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:smart_passenger_alert/models/flight_model.dart';

/// Service to fetch real departure/arrival flight data from airport APIs
class FlightDataService {
  // Colombo International Airport API
  static const String _colomboAirportUrl =
      'https://www.airport.lk/fids_api/api/bia';

  // Fallback flight data for testing (when API is unavailable)
  static final List<Map<String, dynamic>> _fallbackFlights = [
    {
      'flight_number': 'UL101',
      'airline': 'SriLankan Airlines',
      'aircraft_type': 'Airbus A330',
      'departure_time': '08:00',
      'destination': 'Kuala Lumpur (KUL)',
      'status': 'Boarding',
      'weather': 'Clear',
      'traffic_level': 'Low',
    },
    {
      'flight_number': 'FD230',
      'airline': 'FitsAir',
      'aircraft_type': 'Boeing 737',
      'departure_time': '09:30',
      'destination': 'Chennai (MAA)',
      'status': 'On Time',
      'weather': 'Clear',
      'traffic_level': 'Low',
    },
    {
      'flight_number': 'SQ412',
      'airline': 'Singapore Airlines',
      'aircraft_type': 'Boeing 777',
      'departure_time': '11:15',
      'destination': 'Singapore (SIN)',
      'status': 'Delayed',
      'weather': 'Rain',
      'traffic_level': 'High',
    },
    {
      'flight_number': 'BA121',
      'airline': 'British Airways',
      'aircraft_type': 'Boeing 747',
      'departure_time': '14:00',
      'destination': 'London (LHR)',
      'status': 'On Time',
      'weather': 'Clear',
      'traffic_level': 'Medium',
    },
    {
      'flight_number': 'EK501',
      'airline': 'Emirates',
      'aircraft_type': 'Boeing 777',
      'departure_time': '16:45',
      'destination': 'Dubai (DXB)',
      'status': 'On Time',
      'weather': 'Storm',
      'traffic_level': 'High',
    },
    {
      'flight_number': 'MI601',
      'airline': 'Malindo Air',
      'aircraft_type': 'Boeing 737',
      'departure_time': '18:20',
      'destination': 'Kuala Lumpur (KUL)',
      'status': 'On Time',
      'weather': 'Clear',
      'traffic_level': 'Low',
    },
  ];

  /// Fetch real departure flights from airport API
  /// Requires API token - contact airport for authentication
  static Future<List<FlightData>> fetchRealDepartures({
    String? apiToken,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      // If no token, use fallback data
      if (apiToken == null || apiToken.isEmpty) {
        return _convertToFlightData(_fallbackFlights);
      }

      final response = await http
          .get(
            Uri.parse('$_colomboAirportUrl?type=dep'),
            headers: {
              'Authorization': 'Bearer $apiToken',
              'Content-Type': 'application/json',
            },
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Parse based on actual API response format
        if (data is Map && data.containsKey('flights')) {
          return _convertToFlightData(
              List<Map<String, dynamic>>.from(data['flights'] as List));
        } else if (data is List) {
          return _convertToFlightData(
              List<Map<String, dynamic>>.from(data));
        }
        // Fallback if parsing fails
        return _convertToFlightData(_fallbackFlights);
      } else {
        // API error - use fallback
        print('API Error: ${response.statusCode}');
        return _convertToFlightData(_fallbackFlights);
      }
    } catch (e) {
      print('Error fetching real flights: $e');
      // Network error or timeout - use fallback
      return _convertToFlightData(_fallbackFlights);
    }
  }

  /// Fetch arrival flights instead of departures
  static Future<List<FlightData>> fetchRealArrivals({
    String? apiToken,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      if (apiToken == null || apiToken.isEmpty) {
        return _convertToFlightData(_fallbackFlights);
      }

      final response = await http
          .get(
            Uri.parse('$_colomboAirportUrl?type=arr'),
            headers: {
              'Authorization': 'Bearer $apiToken',
              'Content-Type': 'application/json',
            },
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('flights')) {
          return _convertToFlightData(
              List<Map<String, dynamic>>.from(data['flights'] as List));
        } else if (data is List) {
          return _convertToFlightData(
              List<Map<String, dynamic>>.from(data));
        }
        return _convertToFlightData(_fallbackFlights);
      } else {
        print('API Error: ${response.statusCode}');
        return _convertToFlightData(_fallbackFlights);
      }
    } catch (e) {
      print('Error fetching real flights: $e');
      return _convertToFlightData(_fallbackFlights);
    }
  }

  /// Get sample fallback flights (for UI testing)
  static List<FlightData> getFallbackFlights() {
    return _convertToFlightData(_fallbackFlights);
  }

  /// Convert raw API data to FlightData model
  static List<FlightData> _convertToFlightData(
      List<Map<String, dynamic>> rawFlights) {
    return rawFlights.map((flight) {
      return FlightData(
        flightNumber: flight['flight_number'] ?? 'N/A',
        airline: flight['airline'] ?? 'Unknown Airline',
        aircraftType: flight['aircraft_type'] ?? 'Unknown',
        departureTime: flight['departure_time'] ?? flight['scheduled_time'] ?? '00:00',
        destination: flight['destination'] ?? flight['route'] ?? 'Unknown',
        status: flight['status'] ?? 'Unknown',
        // Additional fields for ML model
        weather: flight['weather'] ?? _randomWeather(),
        trafficLevel: flight['traffic_level'] ?? _randomTraffic(),
      );
    }).toList();
  }

  /// Random weather for fallback data
  static String _randomWeather() {
    final weathers = ['Clear', 'Rain', 'Storm'];
    return weathers[DateTime.now().microsecond % weathers.length];
  }

  /// Random traffic for fallback data
  static String _randomTraffic() {
    final traffic = ['Low', 'Medium', 'High'];
    return traffic[DateTime.now().microsecond % traffic.length];
  }
}

/// Extended FlightData model with prediction context
class FlightData {
  final String flightNumber;
  final String airline;
  final String aircraftType;
  final String departureTime;
  final String destination;
  final String status;
  final String weather;
  final String trafficLevel;

  FlightData({
    required this.flightNumber,
    required this.airline,
    required this.aircraftType,
    required this.departureTime,
    required this.destination,
    required this.status,
    required this.weather,
    required this.trafficLevel,
  });

  /// Get departure hour (for ML model prediction)
  int get departureHour {
    try {
      final parts = departureTime.split(':');
      return int.parse(parts[0]);
    } catch (e) {
      return 12; // Default to noon if parsing fails
    }
  }

  /// Check if flight is delayed
  bool get isDelayed => status.toLowerCase().contains('delayed');

  /// Check if flight is cancelled
  bool get isCancelled => status.toLowerCase().contains('cancelled');
}
