import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_passenger_alert/models/flight_model.dart';
import 'package:smart_passenger_alert/models/prediction_model.dart';
import 'package:smart_passenger_alert/models/alert_model.dart';
import 'package:smart_passenger_alert/models/user_model.dart';
import 'package:smart_passenger_alert/models/sensor_model.dart';
import 'package:smart_passenger_alert/models/esp32_health_data.dart';
import 'package:smart_passenger_alert/services/api_service.dart';
import 'package:smart_passenger_alert/services/ai_assistant_service.dart';
import 'package:smart_passenger_alert/services/health_monitor_service.dart';
import 'package:smart_passenger_alert/services/local_database_service.dart';
import 'package:smart_passenger_alert/services/smartwatch_service.dart';
import 'package:smart_passenger_alert/services/esp32_ble_service.dart';

// API Service Provider
final apiServiceProvider = Provider((ref) => ApiService());
final localDatabaseProvider = Provider((ref) => LocalDatabaseService());
final aiAssistantProvider = Provider((ref) => AIAssistantService());
final smartwatchServiceProvider = Provider((ref) => SmartwatchService());
final healthMonitorProvider = Provider((ref) => HealthMonitorService());

final esp32BleServiceProvider = Provider<Esp32BleService>((ref) {
  return Esp32BleService();
});

final esp32HealthDataProvider = StreamProvider<Esp32HealthData>((ref) async* {
  final service = ref.watch(esp32BleServiceProvider);
  await service.scanAndConnect();
  yield* service.healthDataStream;
});

final esp32ConnectionStateProvider = StreamProvider<BluetoothConnectionState>((ref) {
  final service = ref.watch(esp32BleServiceProvider);
  return service.connectionStateStream;
});

final esp32PredictionProvider = StreamProvider<String>((ref) {
  final service = ref.watch(esp32BleServiceProvider);
  return service.predictionStream;
});

final bluetoothAdapterStateProvider = StreamProvider<BluetoothAdapterState>((ref) {
  return FlutterBluePlus.adapterState;
});

final selectedWatchIdProvider = StateProvider<String?>((ref) => null);

final bleWatchScanProvider = FutureProvider<List<BleWatchDevice>>((ref) async {
  final smartwatchService = ref.watch(smartwatchServiceProvider);
  final adapterState = ref.watch(bluetoothAdapterStateProvider).value ?? BluetoothAdapterState.unknown;
  
  if (adapterState != BluetoothAdapterState.on) {
    return [];
  }
  
  return smartwatchService.scanForDevices();
});

final lastConnectedWatchProvider = FutureProvider<String?>((ref) async {
  final smartwatchService = ref.watch(smartwatchServiceProvider);
  return smartwatchService.getLastConnectedDeviceId();
});

// ==================== FLIGHT PROVIDERS ====================

final flightsProvider = FutureProvider<List<Flight>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getFlights();
});

final flightDetailsProvider = FutureProvider.family<Flight, String>((ref, flightId) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getFlightDetails(flightId);
});

final userFlightsProvider = FutureProvider.family<List<Flight>, String>((ref, userId) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getUserFlights(userId);
});

// State Notifier for managing flight favorites
class FlightFavoritesNotifier extends StateNotifier<List<String>> {
  FlightFavoritesNotifier() : super([]);

  void toggleFavorite(String flightId) {
    if (state.contains(flightId)) {
      state = state.where((id) => id != flightId).toList();
    } else {
      state = [...state, flightId];
    }
  }

  bool isFavorite(String flightId) => state.contains(flightId);
}

final flightFavoritesProvider = StateNotifierProvider<FlightFavoritesNotifier, List<String>>(
  (ref) => FlightFavoritesNotifier(),
);

// ==================== PREDICTION PROVIDERS ====================

final delayPredictionProvider = FutureProvider.family<DelayPrediction, String>((ref, flightId) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getPrediction(flightId);
});

final allPredictionsProvider = FutureProvider<List<DelayPrediction>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  final flights = await ref.watch(flightsProvider.future);
  
  final predictions = <DelayPrediction>[];
  for (final flight in flights) {
    try {
      final prediction = await apiService.getPrediction(flight.id);
      predictions.add(prediction);
    } catch (e) {
      // Handle error silently
    }
  }
  return predictions;
});

// ==================== WEATHER PROVIDERS ====================

final weatherProvider = FutureProvider.family<Weather, String>((ref, airportCode) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getWeather(airportCode);
});

// ==================== ALERT PROVIDERS ====================

final alertsProvider = FutureProvider.family<List<Alert>, String>((ref, userId) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getAlerts(userId);
});

class AlertsNotifier extends StateNotifier<List<Alert>> {
  final ApiService apiService;

  AlertsNotifier(this.apiService) : super([]);

  void addAlert(Alert alert) {
    state = [alert, ...state];
  }

  Future<void> markAsRead(String alertId) async {
    await apiService.markAlertAsRead(alertId);
    state = state.map((a) => a.id == alertId ? a.copyWith(read: true) : a).toList();
  }

  Future<void> deleteAlert(String alertId) async {
    await apiService.deleteAlert(alertId);
    state = state.where((a) => a.id != alertId).toList();
  }
}

final alertsNotifierProvider = StateNotifierProvider.family<AlertsNotifier, List<Alert>, String>(
  (ref, userId) {
    final apiService = ref.watch(apiServiceProvider);
    return AlertsNotifier(apiService);
  },
);

// ==================== SENSOR DATA PROVIDERS ====================

final latestSensorDataProvider = FutureProvider.family<SensorData, String>((ref, userId) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getLatestSensorData(userId);
});

final sleepAnalysisProvider = FutureProvider.family<SleepAnalysis, String>((ref, userId) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getSleepAnalysis(userId);
});

final vitalityMetricsProvider = FutureProvider.family<VitalityMetrics, String>((ref, userId) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getVitalityMetrics(userId);
});

final smartwatchConnectedProvider = StateProvider<bool>((ref) => false);

final smartwatchSensorStreamProvider = StreamProvider.family<SensorData, String>((ref, userId) async* {
  final smartwatchService = ref.read(smartwatchServiceProvider);
  await smartwatchService.connectToSmartwatch(userId: userId);
  ref.read(smartwatchConnectedProvider.notifier).state = smartwatchService.isConnected;

  ref.onDispose(() {
    smartwatchService.disconnect();
    ref.read(smartwatchConnectedProvider.notifier).state = false;
  });

  yield* smartwatchService.sensorDataStream.where((event) => event.userId == userId);
});

final recentSensorHistoryProvider = FutureProvider.family<List<SensorData>, String>((ref, userId) async {
  final db = ref.watch(localDatabaseProvider);
  return db.getRecentSensorData(userId, limit: 24);
});

final assistantHistoryProvider = FutureProvider<List<AssistantMessage>>((ref) async {
  final db = ref.watch(localDatabaseProvider);
  return db.getAssistantMessages(limit: 60);
});

// ==================== USER PROVIDERS ====================

final currentUserProvider = FutureProvider.family<User, String>((ref, userId) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getUser(userId);
});

class UserNotifier extends StateNotifier<User?> {
  final ApiService apiService;

  UserNotifier(this.apiService) : super(null);

  Future<void> loadUser(String userId) async {
    final user = await apiService.getUser(userId);
    state = user;
  }

  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    final updatedUser = await apiService.updateUser(userId, updates);
    state = updatedUser;
  }

  void logout() {
    state = null;
  }
}

final userNotifierProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return UserNotifier(apiService);
});

// ==================== TRAVEL OPTIMIZATION PROVIDER ====================

final travelOptimizationProvider = FutureProvider.family<
    TravelOptimization,
    ({
      String flightId,
      double latitude,
      double longitude,
      String airport,
    })>((ref, params) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getTravelOptimization(
    flightId: params.flightId,
    currentLatitude: params.latitude,
    currentLongitude: params.longitude,
    destinationAirport: params.airport,
  );
});

// ==================== GLOBAL STATE PROVIDERS ====================

final selectedFlightProvider = StateProvider<Flight?>((ref) => null);

final isLoadingProvider = StateProvider<bool>((ref) => false);

final appInitializedProvider = StateProvider<bool>((ref) => false);
