import 'package:json_annotation/json_annotation.dart';

part 'prediction_model.g.dart';

@JsonSerializable()
class DelayPrediction {
  final String id;
  final String flightId;
  final double delayProbability;
  final int estimatedDelayMinutes;
  final String impactFactor;
  final String recommendation;
  final List<PredictionFactor> factors;
  final double confidence;
  final DateTime timestamp;
  final String modelVersion;

  DelayPrediction({
    required this.id,
    required this.flightId,
    required this.delayProbability,
    required this.estimatedDelayMinutes,
    required this.impactFactor,
    required this.recommendation,
    required this.factors,
    required this.confidence,
    required this.timestamp,
    required this.modelVersion,
  });

  bool get hasHighProbability => delayProbability > 0.7;
  bool get hasModerateProbability => delayProbability > 0.4 && delayProbability <= 0.7;
  bool get hasLowProbability => delayProbability <= 0.4;

  factory DelayPrediction.fromJson(Map<String, dynamic> json) => _$DelayPredictionFromJson(json);

  Map<String, dynamic> toJson() => _$DelayPredictionToJson(this);
}

@JsonSerializable()
class PredictionFactor {
  final String name;
  final double weight;
  final String description;
  final String severity;

  PredictionFactor({
    required this.name,
    required this.weight,
    required this.description,
    required this.severity,
  });

  factory PredictionFactor.fromJson(Map<String, dynamic> json) => _$PredictionFactorFromJson(json);

  Map<String, dynamic> toJson() => _$PredictionFactorToJson(this);
}

@JsonSerializable()
class Weather {
  final String condition;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final double windGust;
  final int visibility;
  final int pressure;
  final String description;
  final String icon;
  final DateTime lastUpdate;

  Weather({
    required this.condition,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.windGust,
    required this.visibility,
    required this.pressure,
    required this.description,
    required this.icon,
    required this.lastUpdate,
  });

  bool get hasAdverseWeather => condition.toLowerCase().contains('storm') || 
                                 condition.toLowerCase().contains('rain') ||
                                 condition.toLowerCase().contains('snow');

  factory Weather.fromJson(Map<String, dynamic> json) => _$WeatherFromJson(json);

  Map<String, dynamic> toJson() => _$WeatherToJson(this);
}

@JsonSerializable()
class TravelOptimization {
  final String flightId;
  final Duration timeToAirport;
  final int recommendedLeaveMinutes;
  final String recommendation;
  final String trafficStatus;
  final String weatherImpact;
  final DateTime updateTime;

  TravelOptimization({
    required this.flightId,
    required this.timeToAirport,
    required this.recommendedLeaveMinutes,
    required this.recommendation,
    required this.trafficStatus,
    required this.weatherImpact,
    required this.updateTime,
  });

  factory TravelOptimization.fromJson(Map<String, dynamic> json) => _$TravelOptimizationFromJson(json);

  Map<String, dynamic> toJson() => _$TravelOptimizationToJson(this);
}
