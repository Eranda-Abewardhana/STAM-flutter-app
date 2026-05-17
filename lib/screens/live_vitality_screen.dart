import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smart_passenger_alert/theme/theme.dart';
import 'package:smart_passenger_alert/widgets/glass_morphism_container.dart';
import 'package:smart_passenger_alert/providers/app_providers.dart';
import 'package:smart_passenger_alert/models/esp32_health_data.dart';

class LiveVitalityScreen extends ConsumerStatefulWidget {
  final String userId;

  const LiveVitalityScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  ConsumerState<LiveVitalityScreen> createState() => _LiveVitalityScreenState();
}

class _LiveVitalityScreenState extends ConsumerState<LiveVitalityScreen>
    with TickerProviderStateMixin {
  // ── BPM ring buffer (40 samples) ─────────────────────────────────────────
  final List<double> _bpmHistory = List.filled(40, 0.0);
  int _bpmHistoryIndex = 0;
  int _predictionSeq = 0;

  late AnimationController _pulseController;

  void _updateBpmHistory(double bpm) {
    setState(() {
      _bpmHistory[_bpmHistoryIndex % 40] = bpm;
      _bpmHistoryIndex++;
    });
  }

  // ── Helpers derived from sensor data ────────────────────────────────────

  /// Heart rhythm label based on BPM.
  String _rhythmLabel(int bpm) {
    if (bpm <= 0) return 'Reading...';
    if (bpm < 50) return 'Bradycardia';
    if (bpm > 100) return 'Tachycardia';
    return 'Normal sinus rhythm';
  }

  Color _rhythmColor(int bpm) {
    if (bpm <= 0) return const Color(0xFF888888);
    if (bpm < 50 || bpm > 100) return const Color(0xFFE8304A);
    return const Color(0xFF4CAF50);
  }

  /// Stress 0–100 derived from BPM (simple heuristic).
  int _stressFromBpm(int bpm) {
    if (bpm <= 0) return 0;
    if (bpm < 60) return 10;
    if (bpm <= 80) return ((bpm - 60) / 20 * 30).round(); // 0–30 %
    if (bpm <= 100) return (30 + (bpm - 80) / 20 * 40).round(); // 30–70 %
    return (70 + (bpm - 100).clamp(0, 40)).round().clamp(0, 100);
  }

  String _stressLabel(int stress) {
    if (stress < 30) return 'Low';
    if (stress < 60) return 'Moderate';
    return 'High';
  }

  Color _stressColor(int stress) {
    if (stress < 30) return const Color(0xFF4CAF50);
    if (stress < 60) return const Color(0xFFE8A030);
    return const Color(0xFFE8304A);
  }

  /// Energy 0–100 derived from accelerometer resultant.
  int _energyFromAccel(Esp32HealthData d) {
    final r = sqrt(d.ax * d.ax + d.ay * d.ay + d.az * d.az);
    final movement = (r - 9.81).abs();          // renamed: 'dynamic' is a keyword
    return (movement / 5.0 * 100).round().clamp(0, 100);
  }

  String _energyLabel(int energy) {
    if (energy < 20) return 'Low';
    if (energy < 60) return 'Moderate';
    return 'High';
  }

  Color _energyColor(int energy) {
    if (energy < 20) return const Color(0xFF2196F3);
    if (energy < 60) return const Color(0xFFE8A030);
    return const Color(0xFF4CAF50);
  }

  /// Pseudo-HRV estimate (ms) — replace with real RMSSD when available.
  int _hrvFromBpm(int bpm) {
    if (bpm <= 0) return 0;
    // Healthy HRV roughly inverse to resting HR
    return (7000 / bpm).round().clamp(20, 120);
  }

  // ────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  BUILD
  // ═════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final vitalityAsync = ref.watch(vitalityMetricsProvider(widget.userId));
    final sleepAnalysisAsync = ref.watch(sleepAnalysisProvider(widget.userId));
    final esp32DataAsync = ref.watch(esp32HealthDataProvider);
    final esp32ConnectionAsync = ref.watch(esp32ConnectionStateProvider);
    final esp32PredictionAsync = ref.watch(esp32PredictionProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Live ',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                        color: Colors.white),
                  ),
                  TextSpan(
                    text: 'Vitality',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFE8304A)),
                  ),
                ],
              ),
            ),
            const Text(
              'ESP32-HealthSensor',
              style: TextStyle(fontSize: 11, color: Color(0xFF555555)),
            ),
          ],
        ),
        actions: [
          esp32ConnectionAsync.when(
            data: (state) {
              if (state == BluetoothConnectionState.connected) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        final scale = 1.0 + (_pulseController.value * 0.3);
                        return Container(
                          width: 10 * scale,
                          height: 10 * scale,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4CAF50),
                            shape: BoxShape.circle,
                          ),
                        );
                      },
                    ),
                  ),
                );
              }
              return const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        color: Color(0xFFE8A030), strokeWidth: 2),
                  ),
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Connection Banner ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: esp32ConnectionAsync.when(
                data: (state) =>
                state == BluetoothConnectionState.connected
                    ? _connectedBanner()
                    : _scanningBanner(),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),

            // ── Heart Rate Card (with embedded waveform) ──────────────────
            esp32DataAsync.when(
              data: (esp32Data) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _updateBpmHistory(esp32Data.bpm.toDouble());
                });
                return esp32PredictionAsync.when(
                  data: (pred) {
                    _predictionSeq++;
                    return _buildHeartRateCard(context, esp32Data.bpm,
                        pred: pred, isLive: true);
                  },
                  loading: () => _buildHeartRateCard(context, esp32Data.bpm,
                      pred: 'READING|0.0|0', isLive: true),
                  error: (_, __) => _buildHeartRateCard(context, esp32Data.bpm,
                      pred: 'UNKNOWN|0.0|0', isLive: true),
                );
              },
              loading: () => vitalityAsync.when(
                data: (v) => _buildHeartRateCard(
                    context, v.currentHeartRate.toInt(),
                    pred: 'UNKNOWN|0.0|0', isLive: false),
                loading: () => const SizedBox(
                    height: 320,
                    child: Center(child: CircularProgressIndicator())),
                error: (_, __) => const SizedBox.shrink(),
              ),
              error: (_, __) => vitalityAsync.when(
                data: (v) => _buildHeartRateCard(
                    context, v.currentHeartRate.toInt(),
                    pred: 'UNKNOWN|0.0|0', isLive: false),
                loading: () => const SizedBox(
                    height: 320,
                    child: Center(child: CircularProgressIndicator())),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),

            const SizedBox(height: 12),

            // ── STRESS / ENERGY / HRV ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: esp32DataAsync.when(
                data: (d) => _buildStressEnergyHrv(context, d),
                loading: () => _buildStressEnergyHrvPlaceholder(context),
                error: (_, __) => _buildStressEnergyHrvPlaceholder(context),
              ),
            ),

            const SizedBox(height: 12),

            // ── AI Prediction Card ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: esp32PredictionAsync.when(
                data: (pred) =>
                    _buildPredictionCard(context, pred, _predictionSeq),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),

            const SizedBox(height: 12),

            // ── Motion / Accelerometer ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: esp32DataAsync.when(
                data: (d) => _buildAccelerometerCard(context, d),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),

            const SizedBox(height: 12),

            // ── Sleep Analysis ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: sleepAnalysisAsync.when(
                data: (s) => _buildSleepAnalysisSection(context, s),
                loading: () =>
                const Center(child: CircularProgressIndicator()),
                error: (e, _) =>
                    Text('Error: $e', style: const TextStyle(color: Colors.red)),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
      // ── Styled footer bar ─────────────────────────────────────────────
      bottomNavigationBar: _buildFooter(
        esp32DataAsync: esp32DataAsync,
        esp32ConnectionAsync: esp32ConnectionAsync,
        esp32PredictionAsync: esp32PredictionAsync,
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  FOOTER
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildFooter({
    required AsyncValue<Esp32HealthData> esp32DataAsync,
    required AsyncValue<BluetoothConnectionState> esp32ConnectionAsync,
    required AsyncValue<String> esp32PredictionAsync,
  }) {
    final isConnected = esp32ConnectionAsync.asData?.value ==
        BluetoothConnectionState.connected;

    return esp32DataAsync.when(
      data: (data) {
        final isMpuOffline =
            data.ax == 0.0 && data.ay == 0.0 && data.az == 0.0;
        final resultant =
        sqrt(data.ax * data.ax + data.ay * data.ay + data.az * data.az);
        final movementMs2 = (resultant - 9.81).abs();

        String sleepLabel = 'UNKNOWN';
        esp32PredictionAsync.whenData((pred) {
          final parts = pred.split('|');
          final status = parts.isNotEmpty ? parts[0] : 'UNKNOWN';
          final conf =
          parts.length > 1 ? (double.tryParse(parts[1]) ?? 0.0) : 0.0;
          if (status == 'AWAKE') {
            sleepLabel = 'AWAKE';
          } else if (status == 'SLEEP') {
            sleepLabel = conf >= 0.70 ? 'DEEP SLEEP' : 'LIGHT SLEEP';
          } else {
            sleepLabel = status;
          }
        });

        return _footerWidget(
          isConnected: isConnected,
          bpm: data.bpm,
          movementMs2: movementMs2,
          sleepLabel: sleepLabel,
          isMpuOffline: isMpuOffline,
        );
      },
      loading: () => _footerWidget(
        isConnected: isConnected,
        bpm: 0,
        movementMs2: 0,
        sleepLabel: '--',
        isMpuOffline: false,
      ),
      error: (_, __) => _footerWidget(
        isConnected: isConnected,
        bpm: 0,
        movementMs2: 0,
        sleepLabel: '--',
        isMpuOffline: false,
      ),
    );
  }

  Widget _footerWidget({
    required bool isConnected,
    required int bpm,
    required double movementMs2,
    required String sleepLabel,
    required bool isMpuOffline,
  }) {
    final connColor =
    isConnected ? const Color(0xFF4CAF50) : const Color(0xFFE8A030);

    Color sleepColor;
    switch (sleepLabel) {
      case 'DEEP SLEEP':
        sleepColor = const Color(0xFF2196F3);
        break;
      case 'LIGHT SLEEP':
        sleepColor = const Color(0xFFE8A030);
        break;
      case 'AWAKE':
        sleepColor = const Color(0xFF4CAF50);
        break;
      default:
        sleepColor = const Color(0xFF888888);
    }

    Color bpmColor;
    if (bpm <= 0) {
      bpmColor = const Color(0xFF888888);
    } else if (bpm < 50 || bpm > 100) {
      bpmColor = const Color(0xFFE8304A);
    } else {
      bpmColor = Colors.white;
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        border: const Border(
          top: BorderSide(color: Color(0xFF222222), width: 1),
        ),
        boxShadow: const [
          BoxShadow(
              color: Color(0x66000000), blurRadius: 20, offset: Offset(0, -4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Row 1: device name + connection pill ─────────────────────
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (_, __) => Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: connColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: connColor.withOpacity(0.5),
                            blurRadius: 6,
                            spreadRadius: 1),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'ESP32-HealthSensor',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: connColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border:
                    Border.all(color: connColor.withOpacity(0.4)),
                  ),
                  child: Text(
                    isConnected ? 'Connected' : 'Scanning...',
                    style: TextStyle(
                        color: connColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: Color(0xFF1E1E1E), height: 1),

          // ── Row 2: BPM | Movement | Sleep ────────────────────────────
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // BPM
                  Expanded(
                    child: _footerMetric(
                      label: 'BPM',
                      child: Text(
                        bpm > 0 ? '$bpm' : '--',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: bpmColor),
                      ),
                    ),
                  ),
                  const VerticalDivider(
                      color: Color(0xFF222222), width: 1, thickness: 1),
                  // Movement
                  Expanded(
                    child: _footerMetric(
                      label: 'Movement',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            movementMs2.toStringAsFixed(1),
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF00BCD4)),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 3, left: 3),
                            child: Text('m/s²',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF888888))),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const VerticalDivider(
                      color: Color(0xFF222222), width: 1, thickness: 1),
                  // Sleep badge
                  Expanded(
                    child: _footerMetric(
                      label: 'Sleep',
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: sleepColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: sleepColor.withOpacity(0.5)),
                        ),
                        child: Text(
                          sleepLabel,
                          style: TextStyle(
                              color: sleepColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Row 3: MPU offline warning (conditional) ──────────────────
          if (isMpuOffline)
            Container(
              width: double.infinity,
              color: const Color(0xFF1A0E00),
              padding: const EdgeInsets.symmetric(
                  vertical: 6, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.warning_amber_rounded,
                      size: 13, color: Color(0xFFE8A030)),
                  SizedBox(width: 6),
                  Text(
                    'MPU6050 offline  ·  ax · ay · az defaulted to 0',
                    style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFFE8A030),
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _footerMetric({required String label, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF888888),
                  letterSpacing: 0.8)),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  CONNECTION BANNERS
  // ═════════════════════════════════════════════════════════════════════════

  Widget _connectedBanner() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0xFF0D1F0D),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        AnimatedBuilder(
          animation: _pulseController,
          builder: (_, __) => Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
                color: Color(0xFF4CAF50), shape: BoxShape.circle),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Connected · Live',
                style: TextStyle(
                    color: Color(0xFF4CAF50),
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            Text('ESP32-HealthSensor  28:56:2F:4A:62:06',
                style: TextStyle(color: Color(0xFF555555), fontSize: 10)),
          ],
        ),
        const Spacer(),
        const Text('LIVE',
            style: TextStyle(
                color: Color(0xFF4CAF50),
                fontSize: 10,
                fontWeight: FontWeight.w700)),
      ],
    ),
  );

  Widget _scanningBanner() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: BoxDecoration(
        color: const Color(0xFF1F1A0D),
        borderRadius: BorderRadius.circular(12)),
    child: Row(
      children: const [
        SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
              color: Color(0xFFE8A030), strokeWidth: 1.5),
        ),
        SizedBox(width: 8),
        Text('Scanning for device...',
            style: TextStyle(color: Color(0xFFE8A030), fontSize: 13)),
      ],
    ),
  );

  // ═════════════════════════════════════════════════════════════════════════
  //  HEART RATE CARD  (with embedded ECG waveform)
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildHeartRateCard(BuildContext context, int bpm,
      {required String pred, bool isLive = true}) {
    final rhythm = _rhythmLabel(bpm);
    final rhythmColor = _rhythmColor(bpm);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33E8304A),
            blurRadius: 60,
            offset: Offset(0, 40),
            spreadRadius: -20,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label
            const Text('HEART RATE',
                style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF888888),
                    letterSpacing: 1.5)),
            const SizedBox(height: 12),

            // BPM value
            if (bpm <= 0 || bpm < 50)
              const Text('Warming up...',
                  style: TextStyle(fontSize: 22, color: Color(0xFFE8A030)))
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$bpm',
                    style: const TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 14, left: 6),
                    child: Text('bpm',
                        style: TextStyle(
                            fontSize: 14, color: Color(0xFF888888))),
                  ),
                ],
              ),

            const SizedBox(height: 10),

            // Rhythm badge
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: rhythmColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: rhythmColor.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                        color: rhythmColor, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(rhythm,
                      style: TextStyle(
                          color: rhythmColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ECG Waveform
            Row(
              children: const [
                Text('ECG WAVEFORM',
                    style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF888888),
                        letterSpacing: 1.2)),
                SizedBox(width: 6),
                Text('·',
                    style:
                    TextStyle(fontSize: 10, color: Color(0xFF444444))),
                SizedBox(width: 6),
                Text('LIVE',
                    style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF4CAF50),
                        fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 90,
              child: LineChart(
                LineChartData(
                  minY: 40,
                  maxY: 160,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (v) => FlLine(
                        color: Colors.white.withOpacity(0.04),
                        strokeWidth: 1),
                  ),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _bpmHistory
                          .asMap()
                          .entries
                          .map((e) => FlSpot(e.key.toDouble(),
                          e.value == 0 ? 72 : e.value))
                          .toList(),
                      color: const Color(0xFFE8304A),
                      barWidth: 1.5,
                      isCurved: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                          show: true,
                          color: const Color(0xFFE8304A).withOpacity(0.07)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  STRESS · ENERGY · HRV ROW
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildStressEnergyHrv(BuildContext context, Esp32HealthData d) {
    final stress = _stressFromBpm(d.bpm);
    final energy = _energyFromAccel(d);
    final hrv = _hrvFromBpm(d.bpm);

    return Container(
      decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(16)),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _metricTile(
                label: 'STRESS',
                value: '$stress%',
                sub: _stressLabel(stress),
                valueColor: _stressColor(stress),
              ),
            ),
            VerticalDivider(
                color: const Color(0xFF222222), width: 1, thickness: 1),
            Expanded(
              child: _metricTile(
                label: 'ENERGY',
                value: '$energy%',
                sub: _energyLabel(energy),
                valueColor: _energyColor(energy),
              ),
            ),
            VerticalDivider(
                color: const Color(0xFF222222), width: 1, thickness: 1),
            Expanded(
              child: _metricTile(
                label: 'HRV',
                value: '$hrv',
                sub: 'ms',
                valueColor: const Color(0xFF4CAF50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStressEnergyHrvPlaceholder(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(16)),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(child: _metricTile(label: 'STRESS', value: '--%', sub: '--', valueColor: const Color(0xFF888888))),
            VerticalDivider(color: const Color(0xFF222222), width: 1, thickness: 1),
            Expanded(child: _metricTile(label: 'ENERGY', value: '--%', sub: '--', valueColor: const Color(0xFF888888))),
            VerticalDivider(color: const Color(0xFF222222), width: 1, thickness: 1),
            Expanded(child: _metricTile(label: 'HRV', value: '--', sub: 'ms', valueColor: const Color(0xFF888888))),
          ],
        ),
      ),
    );
  }

  Widget _metricTile({
    required String label,
    required String value,
    required String sub,
    required Color valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      child: Column(
        children: [
          Text(label,
              style:
              const TextStyle(fontSize: 10, color: Color(0xFF888888), letterSpacing: 1)),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: valueColor)),
          const SizedBox(height: 2),
          Text(sub,
              style: const TextStyle(fontSize: 11, color: Color(0xFF888888))),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  AI PREDICTION CARD
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildPredictionCard(
      BuildContext context, String predictionString, int seq) {
    final parts = predictionString.split('|');
    final status = parts.isNotEmpty ? parts[0] : 'UNKNOWN';
    final confidence =
    parts.length > 1 ? (double.tryParse(parts[1]) ?? 0.0) : 0.0;

    String displayLabel;
    Color statusColor;

    switch (status) {
      case 'AWAKE':
        displayLabel = 'Normal Rhythm';
        statusColor = const Color(0xFF4CAF50);
        break;
      case 'SLEEP' when confidence >= 0.70:
        displayLabel = 'Deep Sleep';
        statusColor = const Color(0xFF2196F3);
        break;
      case 'SLEEP':
        displayLabel = 'Light Sleep';
        statusColor = const Color(0xFFE8A030);
        break;
      case 'READING':
        displayLabel = 'Reading...';
        statusColor = const Color(0xFF888888);
        break;
      default:
        displayLabel = 'Unknown';
        statusColor = const Color(0xFFE8304A);
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: Container(
        key: ValueKey(status),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8304A).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: const Color(0xFFE8304A).withOpacity(0.5)),
                  ),
                  child: const Text('AI PREDICTION',
                      style: TextStyle(
                          color: Color(0xFFE8304A),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8)),
                ),
                const SizedBox(width: 10),
                const Text('Model inference · live',
                    style:
                    TextStyle(fontSize: 11, color: Color(0xFF555555))),
              ],
            ),

            const SizedBox(height: 16),

            // Prediction label + confidence bar
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Left: label + class info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayLabel,
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Class: ${status.toUpperCase()}  ·  Seq: $seq',
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF555555)),
                      ),
                    ],
                  ),
                ),

                // Right: confidence bar + percentage
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 100,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: confidence,
                          backgroundColor:
                          statusColor.withOpacity(0.12),
                          color: statusColor,
                          minHeight: 5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(confidence * 100).toStringAsFixed(1)}% confident',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusColor),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  MOTION · ACCELEROMETER  (in g units)
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildAccelerometerCard(BuildContext context, Esp32HealthData data) {
    // Convert m/s² → g  (1 g ≈ 9.81 m/s²)
    final axG = data.ax / 9.81;
    final ayG = data.ay / 9.81;
    final azG = data.az / 9.81;
    final isMpuOffline =
        data.ax == 0.0 && data.ay == 0.0 && data.az == 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text('MOTION · ACCELEROMETER',
                  style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF888888),
                      letterSpacing: 1.2)),
              const Spacer(),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: (isMpuOffline
                      ? const Color(0xFFE8A030)
                      : const Color(0xFF4CAF50))
                      .withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isMpuOffline ? 'OFFLINE' : 'ACTIVE',
                  style: TextStyle(
                      color: isMpuOffline
                          ? const Color(0xFFE8A030)
                          : const Color(0xFF4CAF50),
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          if (isMpuOffline)
            Center(
              child: Column(
                children: const [
                  Icon(Icons.warning_amber,
                      size: 32, color: Color(0xFFE8A030)),
                  SizedBox(height: 8),
                  Text('MPU6050 Offline',
                      style:
                      TextStyle(fontSize: 14, color: Colors.white)),
                  Text('ax · ay · az defaulted to 0',
                      style: TextStyle(
                          fontSize: 11, color: Color(0xFF555555))),
                ],
              ),
            )
          else ...[
            _buildGAxisRow('X', axG, const Color(0xFFE8304A)),
            const SizedBox(height: 14),
            _buildGAxisRow('Y', ayG, const Color(0xFFE8A030)),
            const SizedBox(height: 14),
            _buildGAxisRow('Z', azG, const Color(0xFF4CAF50)),
          ],
        ],
      ),
    );
  }

  /// Axis bar showing value in g units.  Bar fills from 0 → maxG (2 g).
  Widget _buildGAxisRow(String label, double valueG, Color color) {
    const maxG = 2.0;
    final fill = (valueG.abs() / maxG).clamp(0.0, 1.0);
    return Row(
      children: [
        SizedBox(
          width: 18,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF888888),
                  fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: LayoutBuilder(builder: (ctx, constraints) {
            return Stack(
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(2)),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 4,
                  width: fill * constraints.maxWidth,
                  decoration: BoxDecoration(
                      color: color, borderRadius: BorderRadius.circular(2)),
                ),
              ],
            );
          }),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 48,
          child: Text(
            '${valueG.toStringAsFixed(2)}g',
            textAlign: TextAlign.right,
            style: TextStyle(
                fontSize: 12, color: color, fontFamily: 'monospace'),
          ),
        ),
      ],
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  SLEEP ANALYSIS  (timeline blocks + duration / quality)
  // ═════════════════════════════════════════════════════════════════════════

  // Safe cast helper — never throws even if the field is missing.
  double _safePct(Object? v) {
    try { return (v as num).toDouble(); } catch (_) { return 0.0; }
  }

  Widget _buildSleepAnalysisSection(
      BuildContext context, dynamic sleepAnalysis) {
    final deep  = _safePct(sleepAnalysis.deepSleepPercentage);
    final light = _safePct(sleepAnalysis.lightSleepPercentage);
    final rem   = _safePct(sleepAnalysis.remCyclePercentage);
    final awake = _safePct(sleepAnalysis.awakePercentage);

    // Optional fields — fall back gracefully if not on model yet.
    int totalMin = 0;
    String quality = '';
    try { totalMin = (sleepAnalysis.totalMinutes as num).toInt(); } catch (_) {}
    try { quality = sleepAnalysis.qualityLabel as String; } catch (_) {}

    final hours = totalMin ~/ 60;
    final mins = totalMin % 60;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: const [
              Icon(Icons.nights_stay, size: 14, color: Color(0xFF2196F3)),
              SizedBox(width: 8),
              Text('SLEEP ANALYSIS · LAST NIGHT',
                  style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF888888),
                      letterSpacing: 1.2)),
            ],
          ),

          const SizedBox(height: 16),

          // Timeline blocks
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 36,
              child: Row(
                children: [
                  if (deep > 0)
                    Expanded(
                      flex: deep.round(),
                      child: Container(color: const Color(0xFF1565C0)),
                    ),
                  if (rem > 0)
                    Expanded(
                      flex: rem.round(),
                      child: Container(color: const Color(0xFF7B1FA2)),
                    ),
                  if (light > 0)
                    Expanded(
                      flex: light.round(),
                      child: Container(color: const Color(0xFF1976D2)),
                    ),
                  if (awake > 0)
                    Expanded(
                      flex: awake.round(),
                      child: Container(color: const Color(0xFF2E7D32)),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Legend
          Wrap(
            spacing: 16,
            children: [
              _legendDot('Deep', const Color(0xFF1565C0)),
              _legendDot('REM', const Color(0xFF7B1FA2)),
              _legendDot('Light', const Color(0xFF1976D2)),
              _legendDot('Awake', const Color(0xFF2E7D32)),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(color: Color(0xFF1E1E1E), height: 1),
          const SizedBox(height: 16),

          // Duration + Quality
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('DURATION',
                        style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF888888),
                            letterSpacing: 1)),
                    const SizedBox(height: 4),
                    Text(
                      totalMin > 0
                          ? '${hours}h ${mins.toString().padLeft(2, '0')}m'
                          : '--h --m',
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('QUALITY',
                        style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF888888),
                            letterSpacing: 1)),
                    const SizedBox(height: 4),
                    Text(
                      quality.isNotEmpty ? quality : '--',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: _qualityColor(quality)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(String label, Color color) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 8,
        height: 8,
        decoration:
        BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 4),
      Text(label,
          style: const TextStyle(
              fontSize: 11, color: Color(0xFF888888))),
    ],
  );

  Color _qualityColor(String quality) {
    switch (quality.toLowerCase()) {
      case 'good':
      case 'great':
        return const Color(0xFF4CAF50);
      case 'fair':
        return const Color(0xFFE8A030);
      case 'poor':
        return const Color(0xFFE8304A);
      default:
        return const Color(0xFF888888);
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Confidence Arc Painter (kept for reuse if needed)
// ═══════════════════════════════════════════════════════════════════════════

class _ConfidenceArcPainter extends CustomPainter {
  final double progress;
  final Color color;
  _ConfidenceArcPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()
      ..color = color.withOpacity(0.15)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;
    final fg = Paint()
      ..color = color
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final rect = Rect.fromLTWH(5, 5, size.width - 10, size.height - 10);
    canvas.drawArc(rect, -1.5708, 6.2832, false, bg);
    canvas.drawArc(rect, -1.5708, 6.2832 * progress, false, fg);
  }

  @override
  bool shouldRepaint(_ConfidenceArcPainter old) =>
      old.progress != progress || old.color != color;
}