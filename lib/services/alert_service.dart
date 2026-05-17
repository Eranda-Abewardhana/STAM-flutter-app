enum AlertPriority {
  low,
  medium,
  high,
  critical,
}

class SmartAlertResult {
  final String message;
  final AlertPriority priority;
  final List<String> alerts;

  const SmartAlertResult({
    required this.message,
    required this.priority,
    required this.alerts,
  });
}

class AlertService {
  String generateSmartAlert({
    required DateTime flightTime,
    required String weather,
    required int travelTime,
    required bool sleepStatus,
    String flightStatus = 'On Time',
    int delayMinutes = 0,
    double distanceToAirportKm = 18,
  }) {
    return evaluateSmartAlert(
      flightTime: flightTime,
      weather: weather,
      travelTime: travelTime,
      sleepStatus: sleepStatus,
      flightStatus: flightStatus,
      delayMinutes: delayMinutes,
      distanceToAirportKm: distanceToAirportKm,
    ).message;
  }

  SmartAlertResult evaluateSmartAlert({
    required DateTime flightTime,
    required String weather,
    required int travelTime,
    required bool sleepStatus,
    String flightStatus = 'On Time',
    int delayMinutes = 0,
    double distanceToAirportKm = 18,
  }) {
    final now = DateTime.now();
    final minutesToFlight = flightTime.difference(now).inMinutes;
    final alerts = <String>[];
    var priority = AlertPriority.low;

    final isCriticalWindow = minutesToFlight > 0 && minutesToFlight <= 120;
    final weatherLower = weather.toLowerCase();
    final hasRoadWeatherRisk = weatherLower.contains('rain') ||
        weatherLower.contains('storm') ||
        weatherLower.contains('wind');

    if (sleepStatus && isCriticalWindow) {
      alerts.add('Wake up! Your flight is in ${_formatTime(minutesToFlight)}.');
      priority = AlertPriority.critical;
    }

    if (flightStatus.toLowerCase() == 'delayed' || delayMinutes > 0) {
      final delay = delayMinutes <= 0 ? 20 : delayMinutes;
      alerts.add('Your flight is delayed by $delay minutes.');
      if (priority.index < AlertPriority.high.index) {
        priority = AlertPriority.high;
      }
    }

    if (minutesToFlight > 0 && travelTime >= (minutesToFlight - 20)) {
      alerts.add('Leave now to reach the airport on time.');
      if (priority.index < AlertPriority.high.index) {
        priority = AlertPriority.high;
      }
    }

    if (hasRoadWeatherRisk) {
      alerts.add('Weather alert: $weather. Expect possible road delays.');
      if (priority.index < AlertPriority.medium.index) {
        priority = AlertPriority.medium;
      }
    }

    if (alerts.isEmpty) {
      alerts.add('All conditions are stable. Continue monitoring until departure.');
      priority = AlertPriority.low;
    }

    final combined = alerts.join(' ');
    final assistantMessage = generateAssistantRecommendation(
      sleepStatus: sleepStatus,
      weather: weather,
      minutesToFlight: minutesToFlight,
      travelTime: travelTime,
      distanceToAirportKm: distanceToAirportKm,
      flightStatus: flightStatus,
      delayMinutes: delayMinutes,
    );

    return SmartAlertResult(
      message: '$combined\n\n$assistantMessage',
      priority: priority,
      alerts: alerts,
    );
  }

  String generateAssistantRecommendation({
    required bool sleepStatus,
    required String weather,
    required int minutesToFlight,
    required int travelTime,
    required double distanceToAirportKm,
    required String flightStatus,
    required int delayMinutes,
  }) {
    final isDelayed = flightStatus.toLowerCase() == 'delayed' || delayMinutes > 0;
    final delayText = isDelayed ? 'with a $delayMinutes minute delay' : 'currently on time';

    if (sleepStatus && minutesToFlight <= 120) {
      final leaveIn = (minutesToFlight - travelTime).clamp(0, 120);
      return 'AI Assistant: Based on weather ($weather), travel distance (${distanceToAirportKm.toStringAsFixed(1)} km), and your sleep state, wake up now and leave within $leaveIn minutes. Flight is $delayText.';
    }

    if (minutesToFlight > 120) {
      return 'AI Assistant: You are outside the critical window. Keep monitoring weather and vitals, then prepare ${minutesToFlight - 120} minutes before the alert window starts.';
    }

    return 'AI Assistant: You are awake and in control. With $weather conditions, leave in ${(minutesToFlight - travelTime).clamp(0, 120)} minutes to stay on schedule.';
  }

  String _formatTime(int minutes) {
    if (minutes < 60) {
      return '$minutes minutes';
    }

    final hours = minutes ~/ 60;
    final rem = minutes % 60;
    if (rem == 0) {
      return '$hours hour${hours > 1 ? 's' : ''}';
    }

    return '$hours hour${hours > 1 ? 's' : ''} $rem minutes';
  }
}
