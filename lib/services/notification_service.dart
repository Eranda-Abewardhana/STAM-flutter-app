import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = 
      FlutterLocalNotificationsPlugin();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> initialize() async {
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInitSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('Notification tapped: ${response.payload}');
      },
    );

    // Create notification channel for Android
    await createNotificationChannel();
  }

  Future<void> createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'flight_alerts',
      'Flight Alerts',
      description: 'Notifications for flight delays and alerts',
      importance: Importance.max,
      enableVibration: true,
      enableLights: true,
      showBadge: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    bool playSound = true,
    bool enableVibration = true,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'flight_alerts',
      'Flight Alerts',
      channelDescription: 'Notifications for flight delays and alerts',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  Future<void> showFlightDelayNotification({
    required String flightNumber,
    required int delayMinutes,
    required String gate,
  }) async {
    await showNotification(
      id: 1,
      title: 'Flight Delayed ⏰',
      body: 'Flight $flightNumber delayed by $delayMinutes minutes at gate $gate',
      payload: 'flight_delay:$flightNumber',
    );
  }

  Future<void> showBoardingNotification({
    required String flightNumber,
    required String gate,
  }) async {
    await showNotification(
      id: 2,
      title: 'Boarding Now 🛫',
      body: 'Boarding for flight $flightNumber at gate $gate',
      payload: 'boarding:$flightNumber',
    );
  }

  Future<void> showWakeUpNotification({
    required String flightNumber,
    required int minutesUntilDeparture,
  }) async {
    await showNotification(
      id: 3,
      title: 'Wake Up! ⏰',
      body: 'Flight $flightNumber in $minutesUntilDeparture minutes',
      payload: 'wake_up:$flightNumber',
      enableVibration: true,
    );
  }

  Future<void> showAIRecommendation({
    required String title,
    required String recommendation,
  }) async {
    await showNotification(
      id: 4,
      title: 'AI Intelligence ✨',
      body: recommendation,
      payload: 'ai_recommendation:$title',
    );
  }

  Future<void> showWeatherAlert({
    required String condition,
    required String impact,
  }) async {
    await showNotification(
      id: 5,
      title: 'Weather Alert 🌦️',
      body: '$condition: $impact',
      payload: 'weather:$condition',
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'flight_alerts',
          'Flight Alerts',
          channelDescription: 'Notifications for flight delays and alerts',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }
}
