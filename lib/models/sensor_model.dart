import 'package:json_annotation/json_annotation.dart';

part 'sensor_model.g.dart';

@JsonSerializable()
class SensorData {
  final String id;
  final String userId;
  final double heartRate;
  final double movement;
  final double temperature;
  final double oxygenLevel;
  final String sleepPhase;
  final DateTime timestamp;
  final String deviceId;
  final double? ax;
  final double? ay;
  final double? az;
  final bool mpuOk;

  SensorData({
    required this.id,
    required this.userId,
    required this.heartRate,
    required this.movement,
    required this.temperature,
    required this.oxygenLevel,
    required this.sleepPhase,
    required this.timestamp,
    required this.deviceId,
    this.ax = 0.0,
    this.ay = 0.0,
    this.az = 0.0,
    this.mpuOk = true,
  });

  bool get isSleeping => sleepPhase != 'AWAKE' && movement < 10;
  bool get hasAbnormalHeartRate => heartRate < 40 || heartRate > 120;
  
  factory SensorData.fromJson(Map<String, dynamic> json) => _$SensorDataFromJson(json);

  Map<String, dynamic> toJson() => _$SensorDataToJson(this);
}

@JsonSerializable()
class SleepAnalysis {
  final double deepSleepPercentage;
  final double lightSleepPercentage;
  final double remCyclePercentage;
  final double awakePercentage;
  final DateTime optimalWakeupWindow;
  final String recommendation;

  SleepAnalysis({
    required this.deepSleepPercentage,
    required this.lightSleepPercentage,
    required this.remCyclePercentage,
    required this.awakePercentage,
    required this.optimalWakeupWindow,
    required this.recommendation,
  });

  factory SleepAnalysis.fromJson(Map<String, dynamic> json) => _$SleepAnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$SleepAnalysisToJson(this);
}

@JsonSerializable()
class VitalityMetrics {
  final double currentHeartRate;
  final double averageHeartRate;
  final double heartRateVariability;
  final double stressLevel;
  final double energyLevel;
  final String currentPhase;
  final DateTime lastUpdate;

  VitalityMetrics({
    required this.currentHeartRate,
    required this.averageHeartRate,
    required this.heartRateVariability,
    required this.stressLevel,
    required this.energyLevel,
    required this.currentPhase,
    required this.lastUpdate,
  });

  factory VitalityMetrics.fromJson(Map<String, dynamic> json) => _$VitalityMetricsFromJson(json);

  Map<String, dynamic> toJson() => _$VitalityMetricsToJson(this);
}
