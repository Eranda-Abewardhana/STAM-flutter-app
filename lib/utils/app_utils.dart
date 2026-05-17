import 'dart:math' as math;

import 'package:intl/intl.dart';

class DateTimeUtils {
  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  static String formatDate(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return formatDate(dateTime);
    }
  }

  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  static bool isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  static bool isTomorrow(DateTime dateTime) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return dateTime.year == tomorrow.year &&
        dateTime.month == tomorrow.month &&
        dateTime.day == tomorrow.day;
  }

  static bool isThisWeek(DateTime dateTime) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return dateTime.isAfter(weekAgo) && dateTime.isBefore(now.add(const Duration(days: 1)));
  }
}

class StringUtils {
  static String capitalizeFirst(String str) {
    if (str.isEmpty) return str;
    return str[0].toUpperCase() + str.substring(1);
  }

  static String capitalize(String str) {
    return str.toUpperCase();
  }

  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  static bool isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
    return phoneRegex.hasMatch(phone);
  }

  static String maskEmail(String email) {
    if (email.length < 3) return email;
    final parts = email.split('@');
    if (parts.length != 2) return email;

    final localPart = parts[0];
    final domain = parts[1];
    final masked = localPart[0] +
        '*' * (localPart.length - 2) +
        localPart[localPart.length - 1];

    return '$masked@$domain';
  }

  static String maskPhoneNumber(String phone) {
    if (phone.length < 4) return phone;
    return '*' * (phone.length - 4) + phone.substring(phone.length - 4);
  }
}

class ValidationUtils {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!StringUtils.isValidEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (!StringUtils.isValidPhone(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }
}

class NumberUtils {
  static String formatNumber(num number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toStringAsFixed(0);
  }

  static String formatCurrency(double amount, {String symbol = '\$'}) {
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  static String formatPercentage(double value, {int decimals = 1}) {
    return '${(value * 100).toStringAsFixed(decimals)}%';
  }

  static double roundToNearest(double value, double nearest) {
    return (value / nearest).round() * nearest;
  }
}

class GumilaiUtils {
  static double calculateFlightDuration(DateTime departure, DateTime arrival) {
    return arrival.difference(departure).inMinutes / 60;
  }

  static int calculateDelayPercentage(int actualDelay, int scheduledDuration) {
    return ((actualDelay / scheduledDuration) * 100).toInt();
  }

  static double calculateHeartRateZone(double heartRate) {
    if (heartRate < 40) return 0.0;
    if (heartRate < 60) return 0.25;
    if (heartRate < 80) return 0.5;
    if (heartRate < 100) return 0.75;
    return 1.0;
  }

  static String interpretSleepQuality(double deepSleepPercentage) {
    if (deepSleepPercentage >= 0.25) return 'Excellent';
    if (deepSleepPercentage >= 0.20) return 'Good';
    if (deepSleepPercentage >= 0.15) return 'Fair';
    return 'Poor';
  }
}

class LocationUtils {
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371;
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final sinDLat = math.sin(dLat / 2);
    final sinDLon = math.sin(dLon / 2);

    final a = sinDLat * sinDLat +
      math.cos(lat1 * math.pi / 180) *
        math.cos(lat2 * math.pi / 180) *
            sinDLon *
            sinDLon;

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadiusKm * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  static String formatDistance(double km) {
    if (km < 1) {
      return '${(km * 1000).toStringAsFixed(0)}m';
    }
    return '${km.toStringAsFixed(1)}km';
  }
}

class AppLogger {
  static void info(String message) {
    print('[INFO] $message');
  }

  static void debug(String message) {
    print('[DEBUG] $message');
  }

  static void warning(String message) {
    print('[WARNING] $message');
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    print('[ERROR] $message');
    if (error != null) print('[ERROR] Error: $error');
    if (stackTrace != null) print('[ERROR] StackTrace: $stackTrace');
  }
}
