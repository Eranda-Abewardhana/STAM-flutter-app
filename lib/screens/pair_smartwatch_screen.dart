import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_passenger_alert/models/sensor_model.dart';
import 'package:smart_passenger_alert/providers/app_providers.dart';
import 'package:smart_passenger_alert/services/sleep_api_service.dart';
import 'package:smart_passenger_alert/services/smartwatch_service.dart';
import 'package:smart_passenger_alert/theme/theme.dart';
import 'package:smart_passenger_alert/widgets/glass_morphism_container.dart';

class PairSmartwatchScreen extends ConsumerStatefulWidget {
  final String userId;

  const PairSmartwatchScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

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
  
  final SleepApiService _sleepApi = SleepApiService();
  SleepPrediction? _sleepPrediction;
  bool _isApiLoading = false;
  
  StreamSubscription? _scanSubscription;
  StreamSubscription<SensorData>? _sensorSubscription;

  @override
  void initState() {
    super.initState();
    _initializeConnection();
    _setupSensorListener();
  }

  void _setupSensorListener() {
    _sensorSubscription = ref.read(smartwatchServiceProvider).sensorDataStream.listen((data) {
      if (!mounted) return;
      if (data.userId == widget.userId && !_isApiLoading && (data.heartRate > 0 || data.movement > 0)) {
        _updateSleepPrediction(data);
      }
    });
  }

  Future<void> _initializeConnection() async {
    final service = ref.read(smartwatchServiceProvider);
    _lastPairedId = await service.getLastConnectedDeviceId();
    
    // Check system-connected devices first
    final connected = await FlutterBluePlus.connectedSystemDevices;
    bool alreadyConnected = false;
    for (var d in connected) {
      if (d.remoteId.str == _lastPairedId) {
        await service.connectToSmartwatch(userId: widget.userId, deviceId: d.remoteId.str);
        alreadyConnected = true;
        break;
      }
    }

    if (!alreadyConnected && mounted) {
      _startScan();
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _sensorSubscription?.cancel();
    _countdownTimer?.cancel();
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  Future<void> _startScan() async {
    final service = ref.read(smartwatchServiceProvider);
    
    // Re-request permissions every time scan starts
    final granted = await service.requestPermissions();
    if (!granted) {
      _showPermissionDialog();
      return;
    }

    if (!await service.ensureBluetoothOn()) return;
    
    // 500ms delay after adapter check
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _isScanning = true;
      _foundDevices.clear();
      _scanCountdown = 10;
    });

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_scanCountdown > 0) {
        setState(() => _scanCountdown--);
      } else {
        timer.cancel();
      }
    });

    _scanSubscription?.cancel();
    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      if (!mounted) return;
      setState(() {
        for (final r in results) {
          final idx = _foundDevices.indexWhere((d) => d.id == r.device.remoteId.str);
          
          String name = r.advertisementData.advName.trim();
          if (name.isEmpty) name = r.device.platformName.trim();
          if (name.isEmpty) name = 'Unknown Device';

          final device = BleWatchDevice(
            id: r.device.remoteId.str,
            name: name,
            rssi: r.rssi,
            connectable: r.advertisementData.connectable,
          );

          if (idx != -1) {
            _foundDevices[idx] = device;
          } else {
            _foundDevices.add(device);
          }
        }
      });
    });

    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
      // Replace Completer with direct await pattern
      await FlutterBluePlus.isScanning.where((s) => s == false).first;
    } catch (e) {
      debugPrint('Scan error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _countdownTimer?.cancel();
        });
      }
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Required'),
        content: const Text('Bluetooth and Location permissions are needed to scan for devices.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _connect(String deviceId) async {
    setState(() => _connectingDeviceId = deviceId);
    try {
      await ref.read(smartwatchServiceProvider).connectToSmartwatch(
        userId: widget.userId,
        deviceId: deviceId,
      );
      if (mounted) {
        setState(() {
          _lastPairedId = deviceId;
        });
      }
    } catch (e) {
      debugPrint('Connection error: $e');
    } finally {
      if (mounted) setState(() => _connectingDeviceId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.watch(smartwatchServiceProvider);
    final isConnected = service.isConnected;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Pair Device'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // [1] LAST PAIRED ROW
                  if (_lastPairedId != null) _buildLastPairedRow(),
                  const SizedBox(height: 24),
                  
                  // [2] SCAN STATUS ROW
                  _buildScanStatusRow(),
                  const SizedBox(height: 12),
                  
                  // [3] DEVICE LIST
                  if (_foundDevices.isEmpty && !_isScanning)
                    _buildEmptyState()
                  else
                    ..._foundDevices.map((d) => _buildDeviceTile(d)).toList(),
                ],
              ),
            ),
          ),
          
          // [5] LIVE DATA PANEL
          if (isConnected) _buildLiveDataPanel(),
        ],
      ),
    );
  }

  Widget _buildLastPairedRow() {
    final lastChars = _lastPairedId!.length > 6 
        ? _lastPairedId!.substring(_lastPairedId!.length - 6) 
        : _lastPairedId!;
        
    return GlassMorphismContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.access_time, color: AppColors.primary), // Clock icon
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Last paired: $lastChars',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  _lastPairedId!,
                  style: const TextStyle(color: AppColors.textTertiary, fontSize: 10),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _connectingDeviceId != null ? null : () => _connect(_lastPairedId!),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              backgroundColor: AppColors.primary.withOpacity(0.1),
              foregroundColor: AppColors.primary,
            ),
            child: const Text('Reconnect', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildScanStatusRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_isScanning)
          Row(
            children: [
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
              ),
              const SizedBox(width: 8),
              Text(
                'Scanning... ${_scanCountdown}s remaining',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          )
        else
          Text(
            'Available Devices (${_foundDevices.length})',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.bold),
          ),
        
        if (!_isScanning)
          IconButton(
            icon: const Icon(Icons.refresh, size: 20, color: AppColors.primary),
            onPressed: _startScan,
            visualDensity: VisualDensity.compact,
          ),
      ],
    );
  }

  Widget _buildDeviceTile(BleWatchDevice device) {
    final isLinked = device.id == _lastPairedId;
    final isConnecting = _connectingDeviceId == device.id;
    final service = ref.read(smartwatchServiceProvider);
    final isCurrentlyConnected = service.activeDevice?.remoteId.str == device.id && service.isConnected;

    return GlassMorphismContainer(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          _buildRssiIcon(device.rssi),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(device.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (isLinked)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                        child: const Text('Linked', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    if (isCurrentlyConnected)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        width: 8, height: 8,
                        decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                      ),
                  ],
                ),
                Text(device.id, style: const TextStyle(color: AppColors.textTertiary, fontSize: 12)),
              ],
            ),
          ),
          if (isConnecting)
            const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
          else if (!isCurrentlyConnected)
            ElevatedButton(
              onPressed: _connectingDeviceId != null ? null : () => _connect(device.id),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                backgroundColor: isLinked ? AppColors.primary : AppColors.bgCardLight,
              ),
              child: const Text('Connect', style: TextStyle(fontSize: 12)),
            )
          else
            const Text('Connected', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildRssiIcon(int rssi) {
    IconData icon;
    if (rssi > -60) icon = Icons.signal_wifi_4_bar;
    else if (rssi > -70) icon = Icons.network_wifi_3_bar;
    else if (rssi > -80) icon = Icons.network_wifi_2_bar;
    else icon = Icons.network_wifi_1_bar;
    
    return Icon(icon, color: _getRssiColor(rssi), size: 18);
  }

  Color _getRssiColor(int rssi) {
    if (rssi > -60) return Colors.green;
    if (rssi > -80) return Colors.orange;
    return Colors.red;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const Icon(Icons.bluetooth_disabled, size: 64, color: AppColors.textDisabled),
            const SizedBox(height: 16),
            const Text('No devices found', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
            const SizedBox(height: 8),
            const Text('Make sure ESP32 is powered on and nearby', style: TextStyle(color: AppColors.textTertiary, fontSize: 12), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isScanning ? null : _startScan,
              child: _isScanning 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Scan Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveDataPanel() {
    return StreamBuilder<SensorData>(
      stream: ref.read(smartwatchServiceProvider).sensorDataStream,
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null) return const SizedBox.shrink();

        return Container(
          decoration: const BoxDecoration(
            color: AppColors.bgGlass,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2)],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.circle, color: Colors.green, size: 12),
                      const SizedBox(width: 8),
                      Text(
                        ref.read(smartwatchServiceProvider).activeDevice?.platformName ?? 'ESP32-HealthSensor',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70),
                      ),
                    ],
                  ),
                  const Text('Connected', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              const Divider(height: 32, color: Colors.white10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetric('BPM', data.heartRate.toInt().toString(), Colors.green),
                  _buildMetric('Movement', '${data.movement.toStringAsFixed(1)} m/s²', AppColors.primary),
                  _buildSleepStatusBadge(),
                ],
              ),
              const SizedBox(height: 20),
              _buildAxisData(data),
              const SizedBox(height: 16),
              _buildAiPredictionRow(),
            ],
          ),
        ).animate().slideY(begin: 1, duration: 400.ms, curve: Curves.easeOut);
      },
    );
  }

  Widget _buildMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppColors.textTertiary, fontSize: 10)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSleepStatusBadge() {
    String label = 'AWAKE';
    Color color = Colors.green;
    
    if (_sleepPrediction != null) {
      if (_sleepPrediction!.prediction == 'sleep') {
        if (_sleepPrediction!.confidence >= 0.70) {
          label = 'DEEP SLEEP';
          color = Colors.blue;
        } else {
          label = 'LIGHT SLEEP';
          color = Colors.orange;
        }
      } else if (_sleepPrediction!.prediction == 'awake') {
        label = 'AWAKE';
        color = Colors.green;
      }
    } else if (_isApiLoading) {
      label = 'ANALYZING...';
      color = Colors.grey;
    }

    return Column(
      children: [
        const Text('Sleep', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
          child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildAxisData(SensorData data) {
    if (!data.mpuOk) {
      return Container(
        padding: const EdgeInsets.all(8),
        width: double.infinity,
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
        child: const Center(child: Text('[MPU offline]', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _axisLabel('AX', data.ax ?? 0),
        const SizedBox(width: 16),
        _axisLabel('AY', data.ay ?? 0),
        const SizedBox(width: 16),
        _axisLabel('AZ', data.az ?? 0),
      ],
    );
  }

  Widget _axisLabel(String label, double val) {
    return Text('$label: ${val.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.textTertiary, fontSize: 11));
  }

  Widget _buildAiPredictionRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('AI Prediction: ', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          if (_isApiLoading)
            const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
          else if (_sleepPrediction != null)
            Text(
              '${_sleepPrediction!.prediction.toUpperCase()}  conf: ${(_sleepPrediction!.confidence * 100).toInt()}%',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            )
          else
            const Text('UNKNOWN', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Future<void> _updateSleepPrediction(SensorData data) async {
    setState(() => _isApiLoading = true);
    final result = await _sleepApi.predict(motion: data.movement, heartRate: data.heartRate);
    if (mounted) {
      setState(() {
        _sleepPrediction = result;
        _isApiLoading = false;
      });
    }
  }
}
