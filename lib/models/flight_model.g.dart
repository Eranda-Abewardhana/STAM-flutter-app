// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flight_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Flight _$FlightFromJson(Map<String, dynamic> json) => Flight(
      id: json['id'] as String,
      flightNumber: json['flightNumber'] as String,
      airline: json['airline'] as String,
      aircraftType: json['aircraftType'] as String?,
      origin: json['origin'] as String,
      destination: json['destination'] as String,
      originCity: json['originCity'] as String?,
      destinationCity: json['destinationCity'] as String?,
      departureTime: DateTime.parse(json['departureTime'] as String),
      arrivalTime: DateTime.parse(json['arrivalTime'] as String),
      scheduledDeparture: json['scheduledDeparture'] == null
          ? null
          : DateTime.parse(json['scheduledDeparture'] as String),
      actualDeparture: json['actualDeparture'] == null
          ? null
          : DateTime.parse(json['actualDeparture'] as String),
      gate: json['gate'] as String?,
      terminal: json['terminal'] as String?,
      status: json['status'] as String,
      delayMinutes: (json['delayMinutes'] as num?)?.toInt(),
      isFavorite: json['isFavorite'] as bool? ?? false,
      hasAlert: json['hasAlert'] as bool? ?? false,
      boardingStatus: json['boardingStatus'] as String?,
      seatAssignment: json['seatAssignment'] as String?,
    );

Map<String, dynamic> _$FlightToJson(Flight instance) => <String, dynamic>{
      'id': instance.id,
      'flightNumber': instance.flightNumber,
      'airline': instance.airline,
      'aircraftType': instance.aircraftType,
      'origin': instance.origin,
      'destination': instance.destination,
      'originCity': instance.originCity,
      'destinationCity': instance.destinationCity,
      'departureTime': instance.departureTime.toIso8601String(),
      'arrivalTime': instance.arrivalTime.toIso8601String(),
      'scheduledDeparture': instance.scheduledDeparture?.toIso8601String(),
      'actualDeparture': instance.actualDeparture?.toIso8601String(),
      'gate': instance.gate,
      'terminal': instance.terminal,
      'status': instance.status,
      'delayMinutes': instance.delayMinutes,
      'isFavorite': instance.isFavorite,
      'hasAlert': instance.hasAlert,
      'boardingStatus': instance.boardingStatus,
      'seatAssignment': instance.seatAssignment,
    };
