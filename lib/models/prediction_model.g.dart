// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prediction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DelayPrediction _$DelayPredictionFromJson(Map<String, dynamic> json) =>
    DelayPrediction(
      id: json['id'] as String,
      flightId: json['flightId'] as String,
      delayProbability: (json['delayProbability'] as num).toDouble(),
      estimatedDelayMinutes: (json['estimatedDelayMinutes'] as num).toInt(),
      impactFactor: json['impactFactor'] as String,
      recommendation: json['recommendation'] as String,
      factors: (json['factors'] as List<dynamic>)
          .map((e) => PredictionFactor.fromJson(e as Map<String, dynamic>))
          .toList(),
      confidence: (json['confidence'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      modelVersion: json['modelVersion'] as String,
    );

Map<String, dynamic> _$DelayPredictionToJson(DelayPrediction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'flightId': instance.flightId,
      'delayProbability': instance.delayProbability,
      'estimatedDelayMinutes': instance.estimatedDelayMinutes,
      'impactFactor': instance.impactFactor,
      'recommendation': instance.recommendation,
      'factors': instance.factors,
      'confidence': instance.confidence,
      'timestamp': instance.timestamp.toIso8601String(),
      'modelVersion': instance.modelVersion,
    };

PredictionFactor _$PredictionFactorFromJson(Map<String, dynamic> json) =>
    PredictionFactor(
      name: json['name'] as String,
      weight: (json['weight'] as num).toDouble(),
      description: json['description'] as String,
      severity: json['severity'] as String,
    );

Map<String, dynamic> _$PredictionFactorToJson(PredictionFactor instance) =>
    <String, dynamic>{
      'name': instance.name,
      'weight': instance.weight,
      'description': instance.description,
      'severity': instance.severity,
    };

Weather _$WeatherFromJson(Map<String, dynamic> json) => Weather(
      condition: json['condition'] as String,
      temperature: (json['temperature'] as num).toDouble(),
      feelsLike: (json['feelsLike'] as num).toDouble(),
      humidity: (json['humidity'] as num).toInt(),
      windSpeed: (json['windSpeed'] as num).toDouble(),
      windGust: (json['windGust'] as num).toDouble(),
      visibility: (json['visibility'] as num).toInt(),
      pressure: (json['pressure'] as num).toInt(),
      description: json['description'] as String,
      icon: json['icon'] as String,
      lastUpdate: DateTime.parse(json['lastUpdate'] as String),
    );

Map<String, dynamic> _$WeatherToJson(Weather instance) => <String, dynamic>{
      'condition': instance.condition,
      'temperature': instance.temperature,
      'feelsLike': instance.feelsLike,
      'humidity': instance.humidity,
      'windSpeed': instance.windSpeed,
      'windGust': instance.windGust,
      'visibility': instance.visibility,
      'pressure': instance.pressure,
      'description': instance.description,
      'icon': instance.icon,
      'lastUpdate': instance.lastUpdate.toIso8601String(),
    };

TravelOptimization _$TravelOptimizationFromJson(Map<String, dynamic> json) =>
    TravelOptimization(
      flightId: json['flightId'] as String,
      timeToAirport:
          Duration(microseconds: (json['timeToAirport'] as num).toInt()),
      recommendedLeaveMinutes: (json['recommendedLeaveMinutes'] as num).toInt(),
      recommendation: json['recommendation'] as String,
      trafficStatus: json['trafficStatus'] as String,
      weatherImpact: json['weatherImpact'] as String,
      updateTime: DateTime.parse(json['updateTime'] as String),
    );

Map<String, dynamic> _$TravelOptimizationToJson(TravelOptimization instance) =>
    <String, dynamic>{
      'flightId': instance.flightId,
      'timeToAirport': instance.timeToAirport.inMicroseconds,
      'recommendedLeaveMinutes': instance.recommendedLeaveMinutes,
      'recommendation': instance.recommendation,
      'trafficStatus': instance.trafficStatus,
      'weatherImpact': instance.weatherImpact,
      'updateTime': instance.updateTime.toIso8601String(),
    };
