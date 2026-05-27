import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smart_passenger_alert/theme/theme.dart';
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
  final List<double> _bpmHistory = List.filled(40, 72.0);
  int _bpmHistoryIndex = 0;
  int _predictionSeq = 142; // Mocked sequence from image

  late AnimationController _pulseController;

  void _updateBpmHistory(double bpm) {
    if (bpm <= 0) return;
    setState(() {
      _bpmHistory[_bpmHistoryIndex % 40] = bpm;
      _bpmHistoryIndex++;
    });
  }

  // ── Helpers derived from sensor data ────────────────────────────────────

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

  int _stressFromBpm(int bpm) {
    if (bpm <= 0) return 0;
    if (bpm < 60) return 10 + Random().nextInt(5);
    if (bpm <= 80) return 20 + Random().nextInt(10);
    return (70 + (bpm - 100).clamp(0, 30)).round();
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

  int _energyFromAccel(Esp32HealthData d) {
    final r = sqrt(d.ax * d.ax + d.ay * d.ay + d.az * d.az);
    final movement = (r - 9.81).abs();
    return (30 + (movement * 10)).round().clamp(0, 100);
  }

  String _energyLabel(int energy) {
    if (energy < 40) return 'Moderate';
    return 'High';
  }

  Color _energyColor(int energy) {
    if (energy < 40) return const Color(0xFFE8A030);
    return const Color(0xFF4CAF50);
  }

  int _hrvFromBpm(int bpm) {
    if (bpm <= 0) return 0;
    return (7000 / bpm).round().clamp(20, 120);
  }

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
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
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
                        fontSize: 18,
                        fontWeight: FontWeight.w300,
                        color: Colors.white),
                  ),
                  TextSpan(
                    text: 'Vitality',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFE8304A)),
                  ),
                ],
              ),
            ),
            const Text(
              'ESP32-HealthSensor JAvi',
              style: TextStyle(fontSize: 10, color: Color(0xFF555555), fontWeight: FontWeight.w400),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1 ── Connection Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _buildConnectionBanner(esp32ConnectionAsync),
            ),

            // 2 ── Heart Rate Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: esp32DataAsync.when(
                data: (data) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _updateBpmHistory(data.bpm.toDouble());
                  });
                  return _buildHeartRateCard(data.bpm);
                },
                loading: () => _buildHeartRateCard(0),
                error: (_, __) => _buildHeartRateCard(0),
              ),
            ),

            const SizedBox(height: 12),

            // 3 ── Stress / Energy / HRV Metrics
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: esp32DataAsync.when(
                data: (d) => _buildQuickMetrics(d),
                loading: () => _buildQuickMetricsPlaceholder(),
                error: (_, __) => _buildQuickMetricsPlaceholder(),
              ),
            ),

            const SizedBox(height: 12),

            // 4 ── AI Prediction
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: esp32PredictionAsync.when(
                data: (pred) => _buildAiPredictionCard(pred),
                loading: () => _buildAiPredictionCard('READING|0.0|0'),
                error: (_, __) => _buildAiPredictionCard('UNKNOWN|0.0|0'),
              ),
            ),

            const SizedBox(height: 12),

            // 5 ── Accelerometer Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: esp32DataAsync.when(
                data: (d) => _buildAccelerometerCard(d),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),

            const SizedBox(height: 12),

            // 6 ── Sleep Analysis
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: sleepAnalysisAsync.when(
                data: (s) => _buildSleepAnalysisSection(s),
                loading: () => _buildSleepPlaceholder(),
                error: (_, __) => _buildSleepPlaceholder(),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionBanner(AsyncValue<BluetoothConnectionState> stateAsync) {
    return stateAsync.when(
      data: (state) {
        final isConnected = state == BluetoothConnectionState.connected;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isConnected ? const Color(0xFF101D14) : const Color(0xFF1D1A10),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isConnected ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isConnected ? const Color(0xFF4CAF50) : const Color(0xFFE8A030),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isConnected ? 'Connected · Live' : 'Scanning...',
                    style: TextStyle(
                      color: isConnected ? const Color(0xFF4CAF50) : const Color(0xFFE8A030),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (isConnected)
                    const Text(
                      'ESP32-HealthSensor 28:56:2F:4A:62:06',
                      style: TextStyle(color: Color(0xFF444444), fontSize: 9),
                    ),
                ],
              ),
              const Spacer(),
              const Text(
                'LIVE',
                style: TextStyle(color: Color(0xFF4CAF50), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ],
          ),
        );
      },
      loading: () => const LinearProgressIndicator(minHeight: 2, color: Color(0xFFE8304A), backgroundColor: Colors.transparent),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildHeartRateCard(int bpm) {
    final rhythm = _rhythmLabel(bpm);
    final rhythmColor = _rhythmColor(bpm);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'HEART RATE',
              style: TextStyle(fontSize: 10, color: Color(0xFF555555), letterSpacing: 1.5, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  bpm > 0 ? '$bpm' : '--',
                  style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w300, color: Colors.white, height: 1),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 8, left: 6),
                  child: Text('bpm', style: TextStyle(fontSize: 14, color: Color(0xFF444444))),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: rhythmColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(color: rhythmColor, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    rhythm,
                    style: TextStyle(color: rhythmColor, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: const [
                Text(
                  'ECG WAVEFORM · LIVE',
                  style: TextStyle(fontSize: 9, color: Color(0xFF333333), letterSpacing: 1),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 60,
              child: LineChart(
                LineChartData(
                  minY: 40,
                  maxY: 160,
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _bpmHistory
                          .asMap()
                          .entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value))
                          .toList(),
                      isCurved: true,
                      color: const Color(0xFFE8304A),
                      barWidth: 1.5,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
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

  Widget _buildQuickMetrics(Esp32HealthData d) {
    final stress = _stressFromBpm(d.bpm);
    final energy = _energyFromAccel(d);
    final hrv = _hrvFromBpm(d.bpm);

    return Row(
      children: [
        _metricTile('STRESS', '$stress%', _stressLabel(stress), _stressColor(stress)),
        const SizedBox(width: 12),
        _metricTile('ENERGY', '$energy%', _energyLabel(energy), _energyColor(energy)),
        const SizedBox(width: 12),
        _metricTile('HRV', '$hrv', 'ms', const Color(0xFF4CAF50)),
      ],
    );
  }

  Widget _buildQuickMetricsPlaceholder() {
    return Row(
      children: [
        _metricTile('STRESS', '--%', '--', const Color(0xFF333333)),
        const SizedBox(width: 12),
        _metricTile('ENERGY', '--%', '--', const Color(0xFF333333)),
        const SizedBox(width: 12),
        _metricTile('HRV', '--', 'ms', const Color(0xFF333333)),
      ],
    );
  }

  Widget _metricTile(String label, String value, String sub, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 8, color: Color(0xFF444444), letterSpacing: 0.5, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontSize: 20, color: color, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(sub, style: const TextStyle(fontSize: 9, color: Color(0xFF444444))),
          ],
        ),
      ),
    );
  }

  Widget _buildAiPredictionCard(String predictionString) {
    final parts = predictionString.split('|');
    final status = parts.isNotEmpty ? parts[0] : 'UNKNOWN';
    final confidence = parts.length > 1 ? (double.tryParse(parts[1]) ?? 0.0) : 0.0;

    String displayLabel;
    switch (status) {
      case 'AWAKE': displayLabel = 'Normal Rhythm'; break;
      case 'SLEEP': displayLabel = confidence >= 0.7 ? 'Deep Sleep' : 'Light Sleep'; break;
      case 'READING': displayLabel = 'Analyzing...'; break;
      default: displayLabel = 'Reading...';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8304A).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('AI PREDICTION', style: TextStyle(color: Color(0xFFE8304A), fontSize: 9, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              const Text('Model inference · live', style: TextStyle(color: Color(0xFF333333), fontSize: 10)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(displayLabel, style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('Class: ${status.toUpperCase()}  ·  Seq: $_predictionSeq', style: const TextStyle(color: Color(0xFF333333), fontSize: 10)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 100,
                    child: LinearProgressIndicator(
                      value: confidence,
                      backgroundColor: const Color(0xFF222222),
                      color: const Color(0xFFE8304A),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('${(confidence * 100).toStringAsFixed(1)}% confident', style: const TextStyle(color: Color(0xFF444444), fontSize: 10, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccelerometerCard(Esp32HealthData d) {
    // Convert to g (assuming input is in m/s^2)
    final axG = d.ax / 9.81;
    final ayG = d.ay / 9.81;
    final azG = d.az / 9.81;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('MOTION · ACCELEROMETER', style: TextStyle(fontSize: 9, color: Color(0xFF444444), letterSpacing: 1.2, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildGAxisRow('X', axG, const Color(0xFFE8304A)),
          const SizedBox(height: 14),
          _buildGAxisRow('Y', ayG, const Color(0xFFE8A030)),
          const SizedBox(height: 14),
          _buildGAxisRow('Z', azG, const Color(0xFF4CAF50)),
        ],
      ),
    );
  }

  Widget _buildGAxisRow(String label, double valG, Color color) {
    const maxG = 1.5;
    final progress = (valG.abs() / maxG).clamp(0.0, 1.0);
    return Row(
      children: [
        SizedBox(width: 14, child: Text(label, style: const TextStyle(color: Color(0xFF444444), fontSize: 10, fontWeight: FontWeight.bold))),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(2)),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: progress,
              child: Container(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text('${valG.toStringAsFixed(2)}g', style: TextStyle(color: color.withOpacity(0.8), fontSize: 10, fontFamily: 'monospace')),
      ],
    );
  }

  Widget _buildSleepAnalysisSection(dynamic s) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SLEEP ANALYSIS · LAST NIGHT', style: TextStyle(fontSize: 9, color: Color(0xFF444444), letterSpacing: 1.2, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 24,
              child: Row(
                children: [
                  Expanded(flex: 30, child: Container(color: const Color(0xFF1565C0))), // Deep
                  Expanded(flex: 20, child: Container(color: const Color(0xFF7B1FA2))), // REM
                  Expanded(flex: 40, child: Container(color: const Color(0xFF1976D2))), // Light
                  Expanded(flex: 10, child: Container(color: const Color(0xFF1B5E20))), // Awake
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _legendItem('Deep', const Color(0xFF1565C0)),
              const SizedBox(width: 12),
              _legendItem('REM', const Color(0xFF7B1FA2)),
              const SizedBox(width: 12),
              _legendItem('Light', const Color(0xFF1976D2)),
              const SizedBox(width: 12),
              _legendItem('Awake', const Color(0xFF1B5E20)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('DURATION', style: TextStyle(fontSize: 8, color: Color(0xFF444444), letterSpacing: 0.5)),
                    const SizedBox(height: 4),
                    const Text('7h 22m', style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('QUALITY', style: TextStyle(fontSize: 8, color: Color(0xFF444444), letterSpacing: 0.5)),
                    const SizedBox(height: 4),
                    const Text('Good', style: TextStyle(fontSize: 22, color: Color(0xFF4CAF50), fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Color(0xFF444444), fontSize: 9)),
      ],
    );
  }

  Widget _buildSleepPlaceholder() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(16)),
      child: const Center(child: Text('Calculating sleep history...', style: TextStyle(color: Color(0xFF333333)))),
    );
  }
}
