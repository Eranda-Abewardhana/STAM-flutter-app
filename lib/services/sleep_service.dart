import 'dart:math';

class SensorSample {
  final double heartRate;
  final double movement;
  final DateTime timestamp;

  const SensorSample({
    required this.heartRate,
    required this.movement,
    required this.timestamp,
  });
}

class SleepDetectionService {
  final List<double> _heartRateWindow = <double>[];
  final int _windowSize;

  SleepDetectionService({int windowSize = 6}) : _windowSize = windowSize;

  bool detectSleep(double heartRate, double movement) {
    _heartRateWindow.add(heartRate);
    if (_heartRateWindow.length > _windowSize) {
      _heartRateWindow.removeAt(0);
    }

    final stableHeartRate = _isHeartRateStable();
    final lowMovement = movement < 8;

    return lowMovement && stableHeartRate;
  }

  String sleepStatusText(double heartRate, double movement) {
    return detectSleep(heartRate, movement) ? 'Sleeping' : 'Awake';
  }

  bool _isHeartRateStable() {
    if (_heartRateWindow.length < 3) {
      return false;
    }

    final maxRate = _heartRateWindow.reduce(max);
    final minRate = _heartRateWindow.reduce(min);
    return (maxRate - minRate) <= 8;
  }

  // Simulation helper for testing when ESP32 is not connected.
  SensorSample generateSimulatedSensorData({required bool sleepingMode}) {
    final rng = Random();
    final heartRate = sleepingMode
        ? 58 + rng.nextDouble() * 8
        : 82 + rng.nextDouble() * 22;
    final movement = sleepingMode
        ? rng.nextDouble() * 6
        : 14 + rng.nextDouble() * 24;

    return SensorSample(
      heartRate: heartRate,
      movement: movement,
      timestamp: DateTime.now(),
    );
  }
}
