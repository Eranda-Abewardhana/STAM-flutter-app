import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_passenger_alert/providers/app_providers.dart';
import 'package:smart_passenger_alert/services/smartwatch_service.dart';

class PairSmartwatchScreen extends ConsumerStatefulWidget {
  final String userId;
  const PairSmartwatchScreen({Key? key, required this.userId}) : super(key: key);

  @override
  ConsumerState<PairSmartwatchScreen> createState() => _PairSmartwatchScreenState();
}

class _PairSmartwatchScreenState extends ConsumerState<PairSmartwatchScreen> {
  bool _isScanning = false;
  int _scanCountdown = 10;
  Timer? _countdownTimer;
  List<BleWatchDevice> _foundDevices = [];
  String? _lastPairedId;
  String? _connectingDeviceId;

  @override
  void initState() {
    super.initState();
    _initializeConnection();
  }

  Future<void> _initializeConnection() async {
    final service = ref.read(smartwatchServiceProvider);
    _lastPairedId = await service.getLastConnectedDeviceId();
    _startScan();
  }

  Future<void> _startScan() async {
    final service = ref.read(smartwatchServiceProvider);
    if (!await service.requestPermissions()) return;
    if (!await service.ensureBluetoothOn()) return;

    setState(() {
      _isScanning = true;
      _foundDevices.clear();
      _scanCountdown = 10;
    });

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted && _scanCountdown > 0) setState(() => _scanCountdown--);
      else t.cancel();
    });

    try {
      final results = await service.scanForDevices(timeout: const Duration(seconds: 10));
      if (mounted) setState(() => _foundDevices = results);
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  Future<void> _connect(String deviceId) async {
    setState(() => _connectingDeviceId = deviceId);
    await ref.read(smartwatchServiceProvider).connectToSmartwatch(userId: widget.userId, deviceId: deviceId);
    if (mounted) setState(() => _connectingDeviceId = null);
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = ref.watch(smartwatchConnectedProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0B10),
      appBar: AppBar(
        title: const Text('Pair Device', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                if (_lastPairedId != null) _buildLastPairedTile(),
                const SizedBox(height: 30),
                _buildSectionHeader('AVAILABLE DEVICES'),
                const SizedBox(height: 15),
                if (_foundDevices.isEmpty && !_isScanning)
                  _buildNoDevicesFound()
                else
                  ..._foundDevices.map((d) => _buildDeviceCard(d, isConnected)),
              ],
            ),
          ),
          if (isConnected) _buildLiveStatusPanel(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        if (_isScanning)
          const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE8304A)))
        else
          IconButton(
            icon: const Icon(Icons.refresh, size: 18, color: Color(0xFFE8304A)),
            onPressed: _startScan,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
      ],
    );
  }

  Widget _buildLastPairedTile() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Row(
        children: [
          const Icon(Icons.history, color: Color(0xFFE8304A), size: 22),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Last paired: :${_lastPairedId!.substring(max(0, _lastPairedId!.length - 5))}', style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
                Text(_lastPairedId!, style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 10)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _connect(_lastPairedId!),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF21262D),
              foregroundColor: const Color(0xFFE8304A),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Reconnect', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(BleWatchDevice device, bool isConnected) {
    final bool isActive = isConnected && ref.read(smartwatchServiceProvider).activeDevice?.remoteId.str == device.id;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Row(
        children: [
          const Icon(Icons.wifi_tethering, color: Colors.blueAccent, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(device.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                    if (isActive) const Padding(padding: EdgeInsets.only(left: 8), child: Icon(Icons.circle, color: Colors.green, size: 8)),
                  ],
                ),
                Text(device.id, style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 11)),
              ],
            ),
          ),
          if (isActive) const Text('Connected', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12))
          else ElevatedButton(
              onPressed: _connectingDeviceId != null ? null : () => _connect(device.id),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE8304A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: _connectingDeviceId == device.id ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Pair', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  Widget _buildNoDevicesFound() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Icon(Icons.bluetooth_searching, size: 40, color: Colors.white.withOpacity(0.1)),
        const SizedBox(height: 16),
        const Text('No devices found nearby', style: TextStyle(color: Colors.white24, fontSize: 13)),
      ],
    );
  }

  Widget _buildLiveStatusPanel() {
    final esp32Data = ref.watch(esp32HealthDataProvider).value;
    final prediction = ref.watch(esp32PredictionProvider).value ?? "UNKNOWN|0.0|0";
    final parts = prediction.split('|');
    final status = parts[0];
    final conf = parts.length > 1 ? (double.tryParse(parts[1]) ?? 0.0) : 0.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 40, offset: const Offset(0, -10))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.circle, color: Colors.green, size: 10),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(text: 'ESP32-HealthSensor ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                        TextSpan(text: 'JAvi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFE8304A))),
                      ],
                    ),
                  ),
                  const Text(
                    'Realtime Monitoring Active',
                    style: TextStyle(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const Spacer(),
              const Text('Connected', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _metric('BPM', esp32Data?.bpm.toString() ?? '0', const Color(0xFF4CAF50)),
              _metric('Movement', '${esp32Data?.calculatedMotion.toStringAsFixed(1) ?? '0.0'} m/s²', Colors.blueAccent),
              _sleepBadge(status),
            ],
          ),
          const SizedBox(height: 24),
          if (esp32Data != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _axisText('AX', esp32Data.ax),
                const SizedBox(width: 16),
                _axisText('AY', esp32Data.ay),
                const SizedBox(width: 16),
                _axisText('AZ', esp32Data.az),
              ],
            ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Center(
              child: Text(
                'AI Prediction: ${status.toUpperCase()} conf: ${(conf * 100).toInt()}%',
                style: const TextStyle(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 1, duration: 600.ms, curve: Curves.easeOutQuart);
  }

  Widget _metric(String label, String val, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 10, letterSpacing: 0.5)),
        const SizedBox(height: 6),
        Text(val, style: TextStyle(color: color, fontSize: 26, fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _sleepBadge(String status) {
    final bool isAwake = status == 'AWAKE';
    final Color color = isAwake ? Colors.green : Colors.orange;
    return Column(
      children: [
        Text('Sleep', style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 10)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.25))),
          child: Text(isAwake ? 'AWAKE' : 'SLEEPING', style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _axisText(String label, double val) {
    return Text('$label: ${val.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white24, fontSize: 11));
  }
}
