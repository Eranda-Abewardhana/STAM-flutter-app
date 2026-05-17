// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Alert _$AlertFromJson(Map<String, dynamic> json) => Alert(
      id: json['id'] as String,
      userId: json['userId'] as String,
      flightId: json['flightId'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      severity: json['severity'] as String,
      action: json['action'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      read: json['read'] as bool? ?? false,
      timestamp: DateTime.parse(json['timestamp'] as String),
      actionTakenAt: json['actionTakenAt'] == null
          ? null
          : DateTime.parse(json['actionTakenAt'] as String),
    );

Map<String, dynamic> _$AlertToJson(Alert instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'flightId': instance.flightId,
      'type': instance.type,
      'title': instance.title,
      'message': instance.message,
      'severity': instance.severity,
      'action': instance.action,
      'data': instance.data,
      'read': instance.read,
      'timestamp': instance.timestamp.toIso8601String(),
      'actionTakenAt': instance.actionTakenAt?.toIso8601String(),
    };

AlertPreference _$AlertPreferenceFromJson(Map<String, dynamic> json) =>
    AlertPreference(
      userId: json['userId'] as String,
      flightDelayAlerts: json['flightDelayAlerts'] as bool? ?? true,
      boardingAlerts: json['boardingAlerts'] as bool? ?? true,
      weatherAlerts: json['weatherAlerts'] as bool? ?? true,
      sleepAlerts: json['sleepAlerts'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      screenWakeup: json['screenWakeup'] as bool? ?? true,
      quietHoursStart: (json['quietHoursStart'] as num?)?.toInt() ?? 22,
      quietHoursEnd: (json['quietHoursEnd'] as num?)?.toInt() ?? 8,
    );

Map<String, dynamic> _$AlertPreferenceToJson(AlertPreference instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'flightDelayAlerts': instance.flightDelayAlerts,
      'boardingAlerts': instance.boardingAlerts,
      'weatherAlerts': instance.weatherAlerts,
      'sleepAlerts': instance.sleepAlerts,
      'soundEnabled': instance.soundEnabled,
      'vibrationEnabled': instance.vibrationEnabled,
      'screenWakeup': instance.screenWakeup,
      'quietHoursStart': instance.quietHoursStart,
      'quietHoursEnd': instance.quietHoursEnd,
    };
