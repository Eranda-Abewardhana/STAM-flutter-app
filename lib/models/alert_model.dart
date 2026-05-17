import 'package:json_annotation/json_annotation.dart';

part 'alert_model.g.dart';

@JsonSerializable()
class Alert {
  final String id;
  final String userId;
  final String flightId;
  final String type;
  final String title;
  final String message;
  final String severity;
  final String? action;
  final Map<String, dynamic>? data;
  final bool read;
  final DateTime timestamp;
  final DateTime? actionTakenAt;

  Alert({
    required this.id,
    required this.userId,
    required this.flightId,
    required this.type,
    required this.title,
    required this.message,
    required this.severity,
    this.action,
    this.data,
    this.read = false,
    required this.timestamp,
    this.actionTakenAt,
  });

  bool get isCritical => severity.toLowerCase() == 'critical';
  bool get isWarning => severity.toLowerCase() == 'warning';
  bool get isInfo => severity.toLowerCase() == 'info';

  factory Alert.fromJson(Map<String, dynamic> json) => _$AlertFromJson(json);

  Map<String, dynamic> toJson() => _$AlertToJson(this);

  Alert copyWith({
    String? id,
    String? userId,
    String? flightId,
    String? type,
    String? title,
    String? message,
    String? severity,
    String? action,
    Map<String, dynamic>? data,
    bool? read,
    DateTime? timestamp,
    DateTime? actionTakenAt,
  }) {
    return Alert(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      flightId: flightId ?? this.flightId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      severity: severity ?? this.severity,
      action: action ?? this.action,
      data: data ?? this.data,
      read: read ?? this.read,
      timestamp: timestamp ?? this.timestamp,
      actionTakenAt: actionTakenAt ?? this.actionTakenAt,
    );
  }
}

@JsonSerializable()
class AlertPreference {
  final String userId;
  final bool flightDelayAlerts;
  final bool boardingAlerts;
  final bool weatherAlerts;
  final bool sleepAlerts;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool screenWakeup;
  final int quietHoursStart;
  final int quietHoursEnd;

  AlertPreference({
    required this.userId,
    this.flightDelayAlerts = true,
    this.boardingAlerts = true,
    this.weatherAlerts = true,
    this.sleepAlerts = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.screenWakeup = true,
    this.quietHoursStart = 22,
    this.quietHoursEnd = 8,
  });

  factory AlertPreference.fromJson(Map<String, dynamic> json) => _$AlertPreferenceFromJson(json);

  Map<String, dynamic> toJson() => _$AlertPreferenceToJson(this);
}
