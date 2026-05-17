import 'package:dio/dio.dart';
import 'package:smart_passenger_alert/models/flight_model.dart';
import 'package:smart_passenger_alert/models/alert_model.dart';
import 'package:smart_passenger_alert/models/prediction_model.dart';
import 'package:smart_passenger_alert/models/sensor_model.dart';
import 'package:smart_passenger_alert/models/user_model.dart';
import 'package:smart_passenger_alert/utils/constants.dart';

class ApiService {
  late Dio _dio;
  static const String baseUrl = 'https://api.travelassistant.local/v1';
  static const Duration timeout = Duration(seconds: 30);

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: timeout,
        receiveTimeout: timeout,
        contentType: 'application/json',
        responseType: ResponseType.json,
      ),
    );

    // Add interceptors for logging and error handling
    _dio.interceptors.add(
      LoggingInterceptor(),
    );

    // Add auth interceptor (to be implemented with real token)
    _dio.interceptors.add(
      AuthInterceptor(),
    );
  }

  // ==================== FLIGHT ENDPOINTS ====================

  Future<List<Flight>> getFlights({
    String? status,
    String? origin,
    String? destination,
    int page = 1,
    int limit = 20,
  }) async {
    if (AppConstants.enableOfflineMode) {
      return _mockFlights();
    }

    try {
      final response = await _dio.get(
        '/flights',
        queryParameters: {
          if (status != null) 'status': status,
          if (origin != null) 'origin': origin,
          if (destination != null) 'destination': destination,
          'page': page,
          'limit': limit,
        },
      );

      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((flight) => Flight.fromJson(flight as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Flight> getFlightDetails(String flightId) async {
    if (AppConstants.enableOfflineMode) {
      return _mockFlights().firstWhere(
        (flight) => flight.id == flightId,
        orElse: () => _mockFlights().first,
      );
    }

    try {
      final response = await _dio.get('/flights/$flightId');
      return Flight.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Flight>> getUserFlights(String userId) async {
    if (AppConstants.enableOfflineMode) {
      return _mockFlights();
    }

    try {
      final response = await _dio.get('/users/$userId/flights');
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((flight) => Flight.fromJson(flight as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Flight> updateFlight(String flightId, Map<String, dynamic> updates) async {
    if (AppConstants.enableOfflineMode) {
      final current = await getFlightDetails(flightId);
      return current.copyWith(
        status: updates['status'] as String? ?? current.status,
        gate: updates['gate'] as String? ?? current.gate,
        terminal: updates['terminal'] as String? ?? current.terminal,
        delayMinutes: updates['delayMinutes'] as int? ?? current.delayMinutes,
      );
    }

    try {
      final response = await _dio.put('/flights/$flightId', data: updates);
      return Flight.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  // ==================== PREDICTION ENDPOINTS ====================

  Future<DelayPrediction> getPrediction(String flightId) async {
    if (AppConstants.enableOfflineMode) {
      return _mockPrediction(flightId);
    }

    try {
      final response = await _dio.get('/predictions/$flightId');
      return DelayPrediction.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<DelayPrediction> predictFlightDelay({
    required String flightNumber,
    required String airline,
    required String origin,
    required String destination,
    required DateTime departureTime,
    required Map<String, dynamic> weatherData,
    required Map<String, dynamic> historicalData,
  }) async {
    if (AppConstants.enableOfflineMode) {
      return _mockPrediction('pred_$flightNumber');
    }

    try {
      final response = await _dio.post(
        '/predictions/predict-delay',
        data: {
          'flightNumber': flightNumber,
          'airline': airline,
          'origin': origin,
          'destination': destination,
          'departureTime': departureTime.toIso8601String(),
          'weatherData': weatherData,
          'historicalData': historicalData,
        },
      );
      return DelayPrediction.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  // ==================== WEATHER ENDPOINTS ====================

  Future<Weather> getWeather(String airportCode) async {
    final normalized = airportCode.toUpperCase();

    if (AppConstants.enableOfflineMode) {
      return _mockWeather();
    }

    try {
      final response = await _dio.get(
        '/weather/current',
        queryParameters: {
          'airportCode': normalized,
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final payload = data['data'];
        if (payload is Map<String, dynamic>) {
          return Weather.fromJson(payload);
        }
        return Weather.fromJson(data);
      }

      throw const FormatException('Invalid weather response format');
    } catch (e) {
      rethrow;
    }
  }

  // ==================== SENSOR DATA ENDPOINTS ====================

  Future<void> postSensorData(SensorData sensorData) async {
    if (AppConstants.enableOfflineMode) {
      return;
    }

    try {
      await _dio.post(
        '/sensor-data',
        data: sensorData.toJson(),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<SensorData> getLatestSensorData(String userId) async {
    if (AppConstants.enableOfflineMode) {
      return _mockSensorData(userId);
    }

    try {
      final response = await _dio.get('/sensor-data/$userId/latest');
      return SensorData.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<SleepAnalysis> getSleepAnalysis(String userId, {int days = 7}) async {
    if (AppConstants.enableOfflineMode) {
      return _mockSleepAnalysis();
    }

    try {
      final response = await _dio.get(
        '/sensor-data/$userId/sleep-analysis',
        queryParameters: {'days': days},
      );
      return SleepAnalysis.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<VitalityMetrics> getVitalityMetrics(String userId) async {
    if (AppConstants.enableOfflineMode) {
      return _mockVitalityMetrics();
    }

    try {
      final response = await _dio.get('/sensor-data/$userId/vitality');
      return VitalityMetrics.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  // ==================== ALERT ENDPOINTS ====================

  Future<List<Alert>> getAlerts(String userId, {int limit = 20}) async {
    if (AppConstants.enableOfflineMode) {
      return _mockAlerts(userId).take(limit).toList();
    }

    try {
      final response = await _dio.get(
        '/alerts',
        queryParameters: {'userId': userId, 'limit': limit},
      );
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((alert) => Alert.fromJson(alert as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAlertAsRead(String alertId) async {
    if (AppConstants.enableOfflineMode) {
      return;
    }

    try {
      await _dio.put('/alerts/$alertId/mark-read');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAlert(String alertId) async {
    if (AppConstants.enableOfflineMode) {
      return;
    }

    try {
      await _dio.delete('/alerts/$alertId');
    } catch (e) {
      rethrow;
    }
  }

  // ==================== USER ENDPOINTS ====================

  Future<User> getUser(String userId) async {
    if (AppConstants.enableOfflineMode) {
      return _mockUser(userId);
    }

    try {
      final response = await _dio.get('/users/$userId');
      return User.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<User> updateUser(String userId, Map<String, dynamic> updates) async {
    if (AppConstants.enableOfflineMode) {
      final current = _mockUser(userId);
      return current.copyWith(
        firstName: updates['firstName'] as String? ?? current.firstName,
        lastName: updates['lastName'] as String? ?? current.lastName,
        email: updates['email'] as String? ?? current.email,
        phone: updates['phone'] as String? ?? current.phone,
      );
    }

    try {
      final response = await _dio.put('/users/$userId', data: updates);
      return User.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<User> registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phone,
  }) async {
    if (AppConstants.enableOfflineMode) {
      return User(
        id: 'user_123',
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        smartwatchConnected: true,
        preferredAirline: 'British Airways',
        frequentAirports: const ['LHR', 'DXB', 'JFK'],
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      );
    }

    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
          if (phone != null) 'phone': phone,
        },
      );
      return User.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    if (AppConstants.enableOfflineMode) {
      return {
        'token': 'offline-token',
        'user': _mockUser('user_123').toJson(),
      };
    }

    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      return response.data['data'] as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  // ==================== TRAVEL OPTIMIZATION ====================

  Future<TravelOptimization> getTravelOptimization({
    required String flightId,
    required double currentLatitude,
    required double currentLongitude,
    required String destinationAirport,
  }) async {
    if (AppConstants.enableOfflineMode) {
      return _mockTravelOptimization(flightId);
    }

    try {
      final response = await _dio.get(
        '/travel-optimization',
        queryParameters: {
          'flightId': flightId,
          'currentLat': currentLatitude,
          'currentLng': currentLongitude,
          'destinationAirport': destinationAirport,
        },
      );
      return TravelOptimization.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  List<Flight> _mockFlights() {
    final now = DateTime.now();
    return [
      Flight(
        id: 'flight_001',
        flightNumber: 'UL 123',
        airline: 'SriLankan Airlines',
        aircraftType: 'Airbus A330',
        origin: 'CMB',
        destination: 'DXB',
        originCity: 'Colombo',
        destinationCity: 'Dubai',
        departureTime: now.add(const Duration(hours: 2, minutes: 30)),
        arrivalTime: now.add(const Duration(hours: 7, minutes: 0)),
        scheduledDeparture: now.add(const Duration(hours: 2)),
        gate: 'B14',
        terminal: '3',
        status: 'delayed',
        delayMinutes: 30,
        hasAlert: true,
        boardingStatus: 'Now Boarding',
        seatAssignment: '12K',
      ),
      Flight(
        id: 'flight_002',
        flightNumber: 'EK 0002',
        airline: 'Emirates',
        aircraftType: 'Airbus A380',
        origin: 'DXB',
        destination: 'LHR',
        originCity: 'Dubai',
        destinationCity: 'London',
        departureTime: now.add(const Duration(hours: 8, minutes: 30)),
        arrivalTime: now.add(const Duration(hours: 15, minutes: 45)),
        scheduledDeparture: now.add(const Duration(hours: 8, minutes: 15)),
        gate: 'A6',
        terminal: '1',
        status: 'delayed',
        delayMinutes: 25,
        hasAlert: true,
        boardingStatus: 'Gate Opens in 40m',
        seatAssignment: '22A',
      ),
    ];
  }

  DelayPrediction _mockPrediction(String flightId) {
    return DelayPrediction(
      id: 'pred_$flightId',
      flightId: flightId,
      delayProbability: 0.84,
      estimatedDelayMinutes: 30,
      impactFactor: 'Storm Cell',
      recommendation: 'High probability of delay due to weather near Colombo approach lanes.',
      factors: [
        PredictionFactor(
          name: 'Storm Cell',
          weight: 0.61,
          description: 'Thunderstorm activity over Sri Lanka western corridor.',
          severity: 'medium',
        ),
        PredictionFactor(
          name: 'Crosswinds',
          weight: 0.23,
          description: 'Crosswinds at Bandaranaike International exceed preferred thresholds.',
          severity: 'high',
        ),
      ],
      confidence: 0.84,
      timestamp: DateTime.now(),
      modelVersion: 'offline-v1',
    );
  }

  Weather _mockWeather() {
    return Weather(
      condition: 'Windy',
      temperature: 28,
      feelsLike: 30,
      humidity: 64,
      windSpeed: 18,
      windGust: 26,
      visibility: 9000,
      pressure: 1010,
      description: 'Windy with scattered showers',
      icon: 'cloud',
      lastUpdate: DateTime.now(),
    );
  }

  SensorData _mockSensorData(String userId) {
    return SensorData(
      id: 'sensor_001',
      userId: userId,
      heartRate: 72,
      movement: 4,
      temperature: 36.8,
      oxygenLevel: 98,
      sleepPhase: 'LIGHT_SLEEP',
      timestamp: DateTime.now(),
      deviceId: 'watch_001',
    );
  }

  SleepAnalysis _mockSleepAnalysis() {
    return SleepAnalysis(
      deepSleepPercentage: 38,
      lightSleepPercentage: 32,
      remCyclePercentage: 22,
      awakePercentage: 8,
      optimalWakeupWindow: DateTime.now().add(const Duration(hours: 7)),
      recommendation: 'Your energy peak is expected at 07:15 AM.',
    );
  }

  VitalityMetrics _mockVitalityMetrics() {
    return VitalityMetrics(
      currentHeartRate: 74,
      averageHeartRate: 69,
      heartRateVariability: 42,
      stressLevel: 0.24,
      energyLevel: 0.82,
      currentPhase: 'LIGHT_SLEEP',
      lastUpdate: DateTime.now(),
    );
  }

  List<Alert> _mockAlerts(String userId) {
    final now = DateTime.now();
    return [
      Alert(
        id: 'alert_001',
        userId: userId,
        flightId: 'flight_001',
        type: 'boarding',
        title: 'Boarding Soon',
        message: 'BA 0173 begins boarding in 45 minutes at Gate B14.',
        severity: 'info',
        read: false,
        timestamp: now.subtract(const Duration(minutes: 5)),
      ),
      Alert(
        id: 'alert_002',
        userId: userId,
        flightId: 'flight_002',
        type: 'flight_delay',
        title: 'Delay Notice',
        message: 'EK 0002 delayed by 25 minutes due to traffic congestion.',
        severity: 'warning',
        read: false,
        timestamp: now.subtract(const Duration(minutes: 20)),
      ),
    ];
  }

  User _mockUser(String userId) {
    return User(
      id: userId,
      firstName: 'Javindi',
      lastName: 'Nethnika',
      email: 'javindi@example.com',
      phone: '+94770000000',
      smartwatchConnected: true,
      preferredAirline: 'British Airways',
      frequentAirports: const ['LHR', 'DXB', 'JFK'],
      createdAt: DateTime.now().subtract(const Duration(days: 120)),
      updatedAt: DateTime.now(),
    );
  }

  TravelOptimization _mockTravelOptimization(String flightId) {
    return TravelOptimization(
      flightId: flightId,
      timeToAirport: const Duration(minutes: 35),
      recommendedLeaveMinutes: 25,
      recommendation: 'Leave in 25 minutes to avoid terminal queue peaks.',
      trafficStatus: 'Light traffic',
      weatherImpact: 'Low impact',
      updateTime: DateTime.now(),
    );
  }
}

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('REQUEST >>> ${options.method} ${options.path}');
    debugPrint('Headers: ${options.headers}');
    debugPrint('Data: ${options.data}');
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('RESPONSE <<< ${response.statusCode} ${response.requestOptions.path}');
    debugPrint('Data: ${response.data}');
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('ERROR >>> ${err.message}');
    debugPrint('Error: ${err.error}');
    return super.onError(err, handler);
  }
}

class AuthInterceptor extends Interceptor {
  // This will be integrated with your auth state management
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add auth token when available
    // options.headers['Authorization'] = 'Bearer \$token';
    return super.onRequest(options, handler);
  }
}

void debugPrint(String message) {
  print('[API SERVICE] $message');
}
