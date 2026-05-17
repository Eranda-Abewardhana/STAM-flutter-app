class Esp32HealthData {
  final int bpm;
  final double ax;
  final double ay;
  final double az;
  final double? motion; // Value between 0.0 and 1.0

  Esp32HealthData({
    required this.bpm,
    required this.ax,
    required this.ay,
    required this.az,
    this.motion,
  });

  factory Esp32HealthData.fromJson(Map<String, dynamic> json) {
    // Handle heart rate from different possible keys
    int heartRate = json['bpm'] ?? json['heart_rate'] ?? 0;
    
    // Handle motion as a double (0.0 to 1.0)
    double? m;
    if (json['motion'] != null) {
      m = (json['motion']).toDouble();
    }
    
    double x = (json['ax'] ?? 0).toDouble();
    double y = (json['ay'] ?? 0).toDouble();
    double z = (json['az'] ?? 0).toDouble();

    return Esp32HealthData(
      bpm: heartRate,
      ax: x,
      ay: y,
      az: z,
      motion: m,
    );
  }

  /// Returns the motion value. If not provided by the sensor, 
  /// it calculates a normalized intensity based on accelerometer deviation.
  double get calculatedMotion {
    if (motion != null) return motion!;
    
    // Calculate magnitude of acceleration
    double magnitude = (ax * ax + ay * ay + az * az);
    
    // Gravity squared is approx 96.04 (9.8^2).
    // We calculate deviation from 1G.
    double deviation = (magnitude - 96.04).abs();
    
    // Normalize deviation to a 0.0 - 1.0 range.
    // Assuming a deviation of 20 (approx 2m/s^2 or 0.2G) is "full motion".
    double normalized = deviation / 20.0;
    
    return normalized.clamp(0.0, 1.0);
  }
}
