// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sensor_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SensorData _$SensorDataFromJson(Map<String, dynamic> json) => SensorData(
      id: json['id'] as String,
      userId: json['userId'] as String,
      heartRate: (json['heartRate'] as num).toDouble(),
      movement: (json['movement'] as num).toDouble(),
      temperature: (json['temperature'] as num).toDouble(),
      oxygenLevel: (json['oxygenLevel'] as num).toDouble(),
      sleepPhase: json['sleepPhase'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      deviceId: json['deviceId'] as String,
    );

Map<String, dynamic> _$SensorDataToJson(SensorData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'heartRate': instance.heartRate,
      'movement': instance.movement,
      'temperature': instance.temperature,
      'oxygenLevel': instance.oxygenLevel,
      'sleepPhase': instance.sleepPhase,
      'timestamp': instance.timestamp.toIso8601String(),
      'deviceId': instance.deviceId,
    };

SleepAnalysis _$SleepAnalysisFromJson(Map<String, dynamic> json) =>
    SleepAnalysis(
      deepSleepPercentage: (json['deepSleepPercentage'] as num).toDouble(),
      lightSleepPercentage: (json['lightSleepPercentage'] as num).toDouble(),
      remCyclePercentage: (json['remCyclePercentage'] as num).toDouble(),
      awakePercentage: (json['awakePercentage'] as num).toDouble(),
      optimalWakeupWindow:
          DateTime.parse(json['optimalWakeupWindow'] as String),
      recommendation: json['recommendation'] as String,
    );

Map<String, dynamic> _$SleepAnalysisToJson(SleepAnalysis instance) =>
    <String, dynamic>{
      'deepSleepPercentage': instance.deepSleepPercentage,
      'lightSleepPercentage': instance.lightSleepPercentage,
      'remCyclePercentage': instance.remCyclePercentage,
      'awakePercentage': instance.awakePercentage,
      'optimalWakeupWindow': instance.optimalWakeupWindow.toIso8601String(),
      'recommendation': instance.recommendation,
    };

VitalityMetrics _$VitalityMetricsFromJson(Map<String, dynamic> json) =>
    VitalityMetrics(
      currentHeartRate: (json['currentHeartRate'] as num).toDouble(),
      averageHeartRate: (json['averageHeartRate'] as num).toDouble(),
      heartRateVariability: (json['heartRateVariability'] as num).toDouble(),
      stressLevel: (json['stressLevel'] as num).toDouble(),
      energyLevel: (json['energyLevel'] as num).toDouble(),
      currentPhase: json['currentPhase'] as String,
      lastUpdate: DateTime.parse(json['lastUpdate'] as String),
    );

Map<String, dynamic> _$VitalityMetricsToJson(VitalityMetrics instance) =>
    <String, dynamic>{
      'currentHeartRate': instance.currentHeartRate,
      'averageHeartRate': instance.averageHeartRate,
      'heartRateVariability': instance.heartRateVariability,
      'stressLevel': instance.stressLevel,
      'energyLevel': instance.energyLevel,
      'currentPhase': instance.currentPhase,
      'lastUpdate': instance.lastUpdate.toIso8601String(),
    };
