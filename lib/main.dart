import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smart_passenger_alert/services/local_database_service.dart';
import 'package:smart_passenger_alert/services/notification_service.dart';
import 'package:smart_passenger_alert/services/smartwatch_service.dart';
import 'package:smart_passenger_alert/theme/theme.dart';
import 'package:smart_passenger_alert/navigation/app_router.dart';
import 'package:smart_passenger_alert/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyDExample',
        appId: '1:123456789:android:abcdef1234567890',
        messagingSenderId: '123456789',
        projectId: 'smart-passenger-alert',
        databaseURL: 'https://smart-passenger-alert.firebaseio.com',
        storageBucket: 'smart-passenger-alert.appspot.com',
      ),
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  if (!kIsWeb) {
    await LocalDatabaseService().database;
    unawaited(SmartwatchService().tryAutoReconnect(userId: 'user_123'));
  }

  await NotificationService().initialize();

  runApp(
    const ProviderScope(
      child: SmartPassengerAlertApp(),
    ),
  );
}

class SmartPassengerAlertApp extends ConsumerWidget {
  const SmartPassengerAlertApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Smart Passenger Alert',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
      navigatorKey: navigatorKey,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}

final navigatorKey = GlobalKey<NavigatorState>();
