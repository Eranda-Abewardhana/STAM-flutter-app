import 'package:flutter/material.dart';
import 'package:smart_passenger_alert/screens/splash_screen.dart';
import 'package:smart_passenger_alert/screens/login_screen.dart';
import 'package:smart_passenger_alert/screens/dashboard_screen.dart';
import 'package:smart_passenger_alert/screens/flight_details_screen.dart';
import 'package:smart_passenger_alert/screens/alerts_screen.dart';
import 'package:smart_passenger_alert/screens/live_vitality_screen.dart';
import 'package:smart_passenger_alert/screens/intelligence_center_screen.dart';
import 'package:smart_passenger_alert/screens/pair_smartwatch_screen.dart';
import 'package:smart_passenger_alert/screens/vitality_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/dashboard':
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case '/flight-details':
        return MaterialPageRoute(builder: (_) => const FlightDetailsScreen());
      case '/alerts':
        final userId = settings.arguments as String? ?? 'user_123';
        return MaterialPageRoute(
          builder: (_) => AlertsScreen(userId: userId),
        );
      case '/vitality':
        final userId = settings.arguments as String? ?? 'user_123';
        return MaterialPageRoute(
          builder: (_) => LiveVitalityScreen(userId: userId),
        );
      case '/vitality-ai':
        final userId = settings.arguments as String? ?? 'user_123';
        return MaterialPageRoute(
          builder: (_) => VitalityScreen(userId: userId),
        );
      case '/intelligence':
        return MaterialPageRoute(
          builder: (_) => const IntelligenceCenterScreen(),
        );
      case '/pair-watch':
        final userId = settings.arguments as String? ?? 'user_123';
        return MaterialPageRoute(
          builder: (_) => PairSmartwatchScreen(userId: userId),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
