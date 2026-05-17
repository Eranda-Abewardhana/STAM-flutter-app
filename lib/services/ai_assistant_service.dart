import 'package:smart_passenger_alert/models/prediction_model.dart';
import 'package:smart_passenger_alert/models/sensor_model.dart';
import 'package:smart_passenger_alert/services/local_database_service.dart';

class AIAssistantService {
  AIAssistantService._internal();
  static final AIAssistantService _instance = AIAssistantService._internal();
  factory AIAssistantService() => _instance;

  final LocalDatabaseService _db = LocalDatabaseService();

  Future<List<AssistantMessage>> loadConversationHistory() async {
    return _db.getAssistantMessages();
  }

  Future<String> generateTravelAdvice({
    required String userMessage,
    Weather? weather,
    VitalityMetrics? vitality,
    SleepAnalysis? sleepAnalysis,
  }) async {
    final lower = userMessage.toLowerCase();
    final weatherLine = _weatherAdvice(weather);
    final vitalityLine = _vitalityAdvice(vitality);
    final sleepLine = _sleepAdvice(sleepAnalysis);

    String response;

    if (lower.contains('weather') || lower.contains('rain') || lower.contains('storm')) {
      response = weatherLine;
    } else if (lower.contains('sleep') || lower.contains('rest')) {
      response = sleepLine;
    } else if (lower.contains('heart') || lower.contains('pulse') || lower.contains('watch')) {
      response = vitalityLine;
    } else if (lower.contains('delay') || lower.contains('flight')) {
      response = 'I recommend keeping a 20-30 minute buffer. $weatherLine Also, $vitalityLine';
    } else {
      response = 'Here is your current travel summary: $weatherLine $vitalityLine $sleepLine';
    }

    await _db.saveAssistantMessage(
      AssistantMessage(
        role: 'user',
        message: userMessage,
        createdAt: DateTime.now(),
      ),
    );

    await _db.saveAssistantMessage(
      AssistantMessage(
        role: 'ai',
        message: response,
        createdAt: DateTime.now(),
      ),
    );

    return response;
  }

  String _weatherAdvice(Weather? weather) {
    if (weather == null) {
      return 'Weather data is syncing. Keep umbrella-ready planning for airport transfer.';
    }

    if (weather.hasAdverseWeather) {
      return 'Adverse weather detected (${weather.description}). Leave earlier and monitor gate updates.';
    }

    return 'Weather is stable (${weather.temperature.toStringAsFixed(0)}C, ${weather.description}). Standard departure timing is fine.';
  }

  String _vitalityAdvice(VitalityMetrics? vitality) {
    if (vitality == null) {
      return 'Smartwatch heart-rate stream is warming up.';
    }

    if (vitality.currentHeartRate < 45 || vitality.currentHeartRate > 120) {
      return 'Your heart-rate trend is outside the normal range. Slow down and hydrate before transit.';
    }

    return 'Heart-rate profile looks normal (${vitality.currentHeartRate.toStringAsFixed(0)} BPM).';
  }

  String _sleepAdvice(SleepAnalysis? sleep) {
    if (sleep == null) {
      return 'Sleep analytics are not ready yet.';
    }

    if (sleep.deepSleepPercentage < 20) {
      return 'Deep sleep is low. Consider a recovery break before your next travel leg.';
    }

    return 'Sleep balance is healthy. Optimal wake window: ${sleep.optimalWakeupWindow.hour.toString().padLeft(2, '0')}:${sleep.optimalWakeupWindow.minute.toString().padLeft(2, '0')}.';
  }
}
