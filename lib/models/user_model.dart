import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? profileImage;
  final String? fcmToken;
  final bool notificationsEnabled;
  final bool emailNotifications;
  final bool smartwatchConnected;
  final String? preferredAirline;
  final List<String> frequentAirports;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.profileImage,
    this.fcmToken,
    this.notificationsEnabled = true,
    this.emailNotifications = true,
    this.smartwatchConnected = false,
    this.preferredAirline,
    this.frequentAirports = const [],
    this.createdAt,
    this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? profileImage,
    String? fcmToken,
    bool? notificationsEnabled,
    bool? emailNotifications,
    bool? smartwatchConnected,
    String? preferredAirline,
    List<String>? frequentAirports,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      fcmToken: fcmToken ?? this.fcmToken,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      smartwatchConnected: smartwatchConnected ?? this.smartwatchConnected,
      preferredAirline: preferredAirline ?? this.preferredAirline,
      frequentAirports: frequentAirports ?? this.frequentAirports,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
