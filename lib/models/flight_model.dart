import 'package:json_annotation/json_annotation.dart';

part 'flight_model.g.dart';

@JsonSerializable()
class Flight {
  final String id;
  final String flightNumber;
  @JsonKey(name: 'airline')
  final String airline;
  @JsonKey(name: 'aircraftType')
  final String? aircraftType;
  @JsonKey(name: 'origin')
  final String origin;
  @JsonKey(name: 'destination')
  final String destination;
  @JsonKey(name: 'originCity')
  final String? originCity;
  @JsonKey(name: 'destinationCity')
  final String? destinationCity;
  @JsonKey(name: 'departureTime')
  final DateTime departureTime;
  @JsonKey(name: 'arrivalTime')
  final DateTime arrivalTime;
  @JsonKey(name: 'scheduledDeparture')
  final DateTime? scheduledDeparture;
  @JsonKey(name: 'actualDeparture')
  final DateTime? actualDeparture;
  @JsonKey(name: 'gate')
  final String? gate;
  @JsonKey(name: 'terminal')
  final String? terminal;
  @JsonKey(name: 'status')
  final String status;
  @JsonKey(name: 'delayMinutes')
  final int? delayMinutes;
  @JsonKey(name: 'isFavorite')
  final bool isFavorite;
  @JsonKey(name: 'hasAlert')
  final bool hasAlert;
  @JsonKey(name: 'boardingStatus')
  final String? boardingStatus;
  @JsonKey(name: 'seatAssignment')
  final String? seatAssignment;

  Flight({
    required this.id,
    required this.flightNumber,
    required this.airline,
    this.aircraftType,
    required this.origin,
    required this.destination,
    this.originCity,
    this.destinationCity,
    required this.departureTime,
    required this.arrivalTime,
    this.scheduledDeparture,
    this.actualDeparture,
    this.gate,
    this.terminal,
    required this.status,
    this.delayMinutes,
    this.isFavorite = false,
    this.hasAlert = false,
    this.boardingStatus,
    this.seatAssignment,
  });

  factory Flight.fromJson(Map<String, dynamic> json) => _$FlightFromJson(json);

  Map<String, dynamic> toJson() => _$FlightToJson(this);

  bool get isDelayed => status.toLowerCase() == 'delayed' || (delayMinutes ?? 0) > 0;
  bool get isCancelled => status.toLowerCase() == 'cancelled';
  bool get isOnTime => status.toLowerCase() == 'on time';
  bool get isBoardingStarted => boardingStatus != null;
  bool get isDeparted => status.toLowerCase() == 'departed' || 
                          actualDeparture != null;

  Duration get timeToFlight {
    return departureTime.difference(DateTime.now());
  }

  bool get isUpcoming => timeToFlight.isNegative == false && 
                        timeToFlight.inMinutes > 0;

  String get formattedFlightTime {
    return '${departureTime.hour.toString().padLeft(2, '0')}:${departureTime.minute.toString().padLeft(2, '0')}';
  }

  String get formattedArrivalTime {
    return '${arrivalTime.hour.toString().padLeft(2, '0')}:${arrivalTime.minute.toString().padLeft(2, '0')}';
  }

  String get durationText {
    final duration = arrivalTime.difference(departureTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  Flight copyWith({
    String? id,
    String? flightNumber,
    String? airline,
    String? aircraftType,
    String? origin,
    String? destination,
    String? originCity,
    String? destinationCity,
    DateTime? departureTime,
    DateTime? arrivalTime,
    DateTime? scheduledDeparture,
    DateTime? actualDeparture,
    String? gate,
    String? terminal,
    String? status,
    int? delayMinutes,
    bool? isFavorite,
    bool? hasAlert,
    String? boardingStatus,
    String? seatAssignment,
  }) {
    return Flight(
      id: id ?? this.id,
      flightNumber: flightNumber ?? this.flightNumber,
      airline: airline ?? this.airline,
      aircraftType: aircraftType ?? this.aircraftType,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      originCity: originCity ?? this.originCity,
      destinationCity: destinationCity ?? this.destinationCity,
      departureTime: departureTime ?? this.departureTime,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      scheduledDeparture: scheduledDeparture ?? this.scheduledDeparture,
      actualDeparture: actualDeparture ?? this.actualDeparture,
      gate: gate ?? this.gate,
      terminal: terminal ?? this.terminal,
      status: status ?? this.status,
      delayMinutes: delayMinutes ?? this.delayMinutes,
      isFavorite: isFavorite ?? this.isFavorite,
      hasAlert: hasAlert ?? this.hasAlert,
      boardingStatus: boardingStatus ?? this.boardingStatus,
      seatAssignment: seatAssignment ?? this.seatAssignment,
    );
  }
}
