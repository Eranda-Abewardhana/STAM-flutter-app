import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_passenger_alert/models/prediction_model.dart';
import 'package:smart_passenger_alert/providers/app_providers.dart';
import 'package:smart_passenger_alert/services/alert_service.dart';
import 'package:smart_passenger_alert/services/notification_service.dart';
import 'package:smart_passenger_alert/services/sleep_detection_service.dart';
import 'package:smart_passenger_alert/services/python_backend_service.dart';
import 'package:smart_passenger_alert/theme/theme.dart';
import 'package:smart_passenger_alert/widgets/alert_card.dart';
import 'package:smart_passenger_alert/widgets/glass_morphism_container.dart';

class VitalityScreen extends ConsumerStatefulWidget {
  final String userId;

  const VitalityScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  ConsumerState<VitalityScreen> createState() => _VitalityScreenState();
}

class _VitalityScreenState extends ConsumerState<VitalityScreen> {
  final SleepDetectionService _sleepService = SleepDetectionService();
  final AlertService _alertService = AlertService();
  final NotificationService _notificationService = NotificationService();

  Timer? _simulationTimer;
  Timer? _sleepDetectionTimer;
  SensorSample? _simulatedSample;
  SleepDetectionResult? _pythonSleepResult;
  bool _loadingSleepDetection = false;
  bool _debugMode = false;
  bool _forceSleeping = false;
  int _debugMinutesToFlight = 90;
  int _debugTravelMinutes = 48;
  int _debugDelayMinutes = 0;
  double _debugDistanceKm = 24.0;
  String _debugWeather = 'light rain and wind';
  String _debugFlightStatus = 'On Time';
  String? _lastNotificationSignature;
  DateTime? _lastNotificationTime;

  @override
  void initState() {
    super.initState();
    _simulationTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        final now = DateTime.now();
        final sleepyMode = _debugMode ? _forceSleeping : now.second % 2 == 0;
        _simulatedSample = _sleepService.generateSimulatedSensorData(
          sleepingMode: sleepyMode,
        );
      });
    });

    // Start Python sleep detection timer (every 10 seconds)
    _sleepDetectionTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!mounted) return;
      _checkSleepStateWithPython();
    });

    // Check once immediately
    _checkSleepStateWithPython();
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    _sleepDetectionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sensorAsync = ref.watch(smartwatchSensorStreamProvider(widget.userId));
    final weatherAsync = ref.watch(weatherProvider('CMB'));
    final flightsAsync = ref.watch(flightsProvider);
    final watchConnected = ref.watch(smartwatchConnectedProvider);

    final sensorData = sensorAsync.valueOrNull;
    final heartRate = sensorData?.heartRate ?? _simulatedSample?.heartRate ?? 72.0;
    final movement = sensorData?.movement ?? _simulatedSample?.movement ?? 10.0;
    final isSleeping = _sleepService.detectSleep(heartRate, movement);
    final statusText = isSleeping ? 'Sleeping' : 'Awake';

    final flight = flightsAsync.valueOrNull?.isNotEmpty == true
        ? flightsAsync.valueOrNull!.first
        : null;
    final flightTime = _debugMode
      ? DateTime.now().add(Duration(minutes: _debugMinutesToFlight))
      : (flight?.departureTime ?? DateTime.now().add(const Duration(minutes: 90)));
    final flightStatus = _debugMode ? _debugFlightStatus : (flight?.status ?? 'On Time');
    final delayMinutes = _debugMode ? _debugDelayMinutes : (flight?.delayMinutes ?? 0);

    final weather = weatherAsync.valueOrNull;
    final weatherDescription = _debugMode ? _debugWeather : _weatherSummary(weather);

    // Travel simulation input required by module brief.
    final distanceToAirportKm = _debugMode ? _debugDistanceKm : 24.0;
    final estimatedTravelTimeMin = _debugMode ? _debugTravelMinutes : 48;

    final alertResult = _alertService.evaluateSmartAlert(
      flightTime: flightTime,
      weather: weatherDescription,
      travelTime: estimatedTravelTimeMin,
      sleepStatus: isSleeping,
      flightStatus: flightStatus,
      delayMinutes: delayMinutes,
      distanceToAirportKm: distanceToAirportKm,
    );

    _maybeSendAlertNotification(
      alertResult: alertResult,
      minutesToFlight: flightTime.difference(DateTime.now()).inMinutes,
      flightStatus: flightStatus,
      delayMinutes: delayMinutes,
      weather: weatherDescription,
    );

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Live Vitality Screen'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Smart Sleep Detection and Intelligent Alert System',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              sensorData == null
                  ? 'Sensor source: simulation (ESP32/watch not available)'
                  : 'Sensor source: smartwatch stream (${sensorData.deviceId})',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(
                  Icons.watch,
                  size: 16,
                  color: watchConnected ? AppColors.accentGreen : AppColors.warning,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  watchConnected ? 'Smartwatch Connected' : 'Smartwatch Disconnected',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: watchConnected ? AppColors.accentGreen : AppColors.warning,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            GlassMorphismContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Debug Scenario Panel',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      Switch(
                        value: _debugMode,
                        onChanged: (value) => setState(() => _debugMode = value),
                      ),
                    ],
                  ),
                  if (_debugMode) ...[
                    _buildSliderControl(
                      label: 'Minutes to Flight',
                      value: _debugMinutesToFlight.toDouble(),
                      min: 30,
                      max: 240,
                      onChanged: (v) => setState(() => _debugMinutesToFlight = v.round()),
                    ),
                    _buildSliderControl(
                      label: 'Travel Time (min)',
                      value: _debugTravelMinutes.toDouble(),
                      min: 10,
                      max: 180,
                      onChanged: (v) => setState(() => _debugTravelMinutes = v.round()),
                    ),
                    _buildSliderControl(
                      label: 'Delay Minutes',
                      value: _debugDelayMinutes.toDouble(),
                      min: 0,
                      max: 180,
                      onChanged: (v) => setState(() => _debugDelayMinutes = v.round()),
                    ),
                    _buildSliderControl(
                      label: 'Distance to Airport (km)',
                      value: _debugDistanceKm,
                      min: 2,
                      max: 80,
                      onChanged: (v) => setState(() => _debugDistanceKm = v),
                    ),
                    DropdownButtonFormField<String>(
                      value: _debugFlightStatus,
                      decoration: const InputDecoration(labelText: 'Flight Status'),
                      items: const [
                        DropdownMenuItem(value: 'On Time', child: Text('On Time')),
                        DropdownMenuItem(value: 'Delayed', child: Text('Delayed')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _debugFlightStatus = value);
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    DropdownButtonFormField<String>(
                      value: _debugWeather,
                      decoration: const InputDecoration(labelText: 'Weather Condition'),
                      items: const [
                        DropdownMenuItem(value: 'clear skies', child: Text('Clear Skies')),
                        DropdownMenuItem(value: 'light rain and wind', child: Text('Light Rain + Wind')),
                        DropdownMenuItem(value: 'storm warning with heavy rain', child: Text('Storm + Heavy Rain')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _debugWeather = value);
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Force Sleeping Simulation',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        Switch(
                          value: _forceSleeping,
                          onChanged: (value) => setState(() => _forceSleeping = value),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: _metricCard(
                    title: 'Heart Rate',
                    value: '${heartRate.toStringAsFixed(0)} BPM',
                    color: AppColors.accentRed,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _metricCard(
                    title: 'Movement',
                    value: movement.toStringAsFixed(1),
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _metricCard(
              title: 'Sleep Status',
              value: statusText,
              color: isSleeping ? AppColors.warning : AppColors.accentGreen,
            ),
            const SizedBox(height: AppSpacing.md),
            if (_pythonSleepResult != null)
              _buildPythonSleepDetectionCard(context),
            const SizedBox(height: AppSpacing.xl),
            SmartAlertCard(
              message: alertResult.message,
              priority: alertResult.priority,
            ),
            const SizedBox(height: AppSpacing.xl),
            GlassMorphismContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Context Snapshot',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _contextRow('Flight Time', _timeText(flightTime)),
                  _contextRow('Flight Status', flightStatus),
                  _contextRow('Weather', weatherDescription),
                  _contextRow('Distance to Airport', '${distanceToAirportKm.toStringAsFixed(1)} km'),
                  _contextRow('Estimated Travel Time', '$estimatedTravelTimeMin min'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return GlowingContainer(
      glowColor: color,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }

  Widget _contextRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderControl({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ${value.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Slider(
            min: min,
            max: max,
            value: value.clamp(min, max),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  String _weatherSummary(Weather? weather) {
    if (weather == null) {
      return 'Light rain and gusty wind';
    }

    return weather.description;
  }

  String _timeText(DateTime dateTime) {
    final hh = dateTime.hour.toString().padLeft(2, '0');
    final mm = dateTime.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  Future<void> _maybeSendAlertNotification({
    required SmartAlertResult alertResult,
    required int minutesToFlight,
    required String flightStatus,
    required int delayMinutes,
    required String weather,
  }) async {
    if (alertResult.priority != AlertPriority.high &&
        alertResult.priority != AlertPriority.critical) {
      return;
    }

    final signature =
        '${alertResult.priority.name}|$minutesToFlight|$flightStatus|$delayMinutes|$weather';
    final now = DateTime.now();
    final recentlySent = _lastNotificationSignature == signature &&
        _lastNotificationTime != null &&
        now.difference(_lastNotificationTime!).inSeconds < 90;
    if (recentlySent) {
      return;
    }

    _lastNotificationSignature = signature;
    _lastNotificationTime = now;

    await _notificationService.showAIRecommendation(
      title: 'Vitality Alert',
      recommendation: alertResult.message,
    );
  }

  Future<void> _checkSleepStateWithPython() async {
    if (!mounted) return;

    setState(() => _loadingSleepDetection = true);

    try {
      // Get current sensor data
      int heartRate = (_simulatedSample?.heartRate ?? 72).toInt();
      int movement = (_simulatedSample?.movement ?? 10).toInt();
      double temperature = 36.5 + (movement / 20); // Simulate temp variation
      int oxygen = 96 + (movement ~/ 5); // Simulate oxygen saturation
      int hour = DateTime.now().hour;

      // Call Python sleep detection service
      final result = await PythonBackendService.detectSleepState(
        heartRate: heartRate,
        movementLevel: movement,
        bodyTemperature: temperature,
        oxygenSaturation: oxygen,
        timeOfDay: hour,
      );

      if (mounted) {
        setState(() {
          _pythonSleepResult = result;
          _loadingSleepDetection = false;
        });

        // Show alerts if any
        if (result.alerts.isNotEmpty) {
          for (String alert in result.alerts) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(alert),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingSleepDetection = false);
      }
    }
  }

  Widget _buildPythonSleepDetectionCard(BuildContext context) {
    if (_loadingSleepDetection) {
      return GlassMorphismContainer(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: const SizedBox(
          height: 100,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_pythonSleepResult == null) {
      return const SizedBox.shrink();
    }

    final result = _pythonSleepResult!;
    final qualityColor = _getSleepQualityColor(result.sleepQuality);
    final hasAlerts = result.alerts.isNotEmpty;

    return GlassMorphismContainer(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '🤖 AI Sleep Analysis',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              Chip(
                label: Text(result.confidence),
                backgroundColor: qualityColor.withOpacity(0.2),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: qualityColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      'Sleep Quality: ${result.sleepQuality}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  result.recommendation,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          if (hasAlerts) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.accentRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.accentRed),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '⚠️ Health Alerts',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.accentRed,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...result.alerts.map((alert) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: Text(
                          alert,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.accentRed,
                              ),
                        ),
                      )),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getSleepQualityColor(String quality) {
    switch (quality.toLowerCase()) {
      case 'deep sleep':
        return AppColors.accentGreen;
      case 'light sleep':
        return const Color(0xFF8BC34A);
      case 'good':
        return AppColors.primary;
      case 'awake':
        return AppColors.warning;
      default:
        return AppColors.textTertiary;
    }
  }
}
