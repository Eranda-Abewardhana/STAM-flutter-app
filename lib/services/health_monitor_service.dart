import 'package:smart_passenger_alert/models/prediction_model.dart';
import 'package:smart_passenger_alert/models/sensor_model.dart';
import 'package:smart_passenger_alert/services/notification_service.dart';

class HealthMonitorService {
  HealthMonitorService._internal();
  static final HealthMonitorService _instance = HealthMonitorService._internal();
  factory HealthMonitorService() => _instance;

  DateTime? _lastWeatherAlert;

  Future<void> processIncomingData({
    required SensorData sensorData,
    Weather? weather,
  }) async {
    if (sensorData.hasAbnormalHeartRate) {
      await NotificationService().showNotification(
        id: 901,
        title: 'Health Advisory',
        body: 'Heart rate is ${sensorData.heartRate.toStringAsFixed(0)} BPM. Please rest and hydrate.',
        payload: 'health:heart_rate',
      );
    }

    if (sensorData.isSleeping && sensorData.oxygenLevel < 93) {
      await NotificationService().showNotification(
        id: 902,
        title: 'Sleep Monitoring Alert',
        body: 'Low oxygen trend during sleep detected. Consider checking your wearable fit.',
        payload: 'health:sleep_oxygen',
      );
    }

    if (weather != null && weather.hasAdverseWeather) {
      final now = DateTime.now();
      final shouldNotify =
          _lastWeatherAlert == null || now.difference(_lastWeatherAlert!).inMinutes >= 30;
      if (shouldNotify) {
        await NotificationService().showWeatherAlert(
          condition: weather.condition,
          impact: 'Flight and traffic disruptions are possible. Leave earlier than usual.',
        );
        _lastWeatherAlert = now;
      }
    }
  }
}
