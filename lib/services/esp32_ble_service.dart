import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:http/http.dart' as http;
import 'package:smart_passenger_alert/models/esp32_health_data.dart';

class Esp32BleService {
  // Singleton pattern
  static final Esp32BleService _instance = Esp32BleService._internal();
  factory Esp32BleService() => _instance;
  Esp32BleService._internal();

  static const String deviceName = "ESP32-HealthSensor";
  static const String serviceUuid = "12345678-1234-1234-1234-1234567890ab";
  static const String healthCharacteristicUuid = "abcd1234-5678-90ab-cdef-1234567890ab";
  static const String commandCharacteristicUuid = "dcba4321-ba21-ba21-ba21-fedcba654321";
  static const String predictionUrl = "https://eranda-sathsara-javi.hf.space/predict";

  BluetoothDevice? _targetDevice;
  BluetoothCharacteristic? _healthCharacteristic;
  BluetoothCharacteristic? _commandCharacteristic;
  
  final StreamController<Esp32HealthData> _dataController = StreamController<Esp32HealthData>.broadcast();
  Stream<Esp32HealthData> get healthDataStream => _dataController.stream;

  final StreamController<BluetoothConnectionState> _connectionController = StreamController<BluetoothConnectionState>.broadcast();
  Stream<BluetoothConnectionState> get connectionStateStream => _connectionController.stream;

  final StreamController<String> _predictionController = StreamController<String>.broadcast();
  Stream<String> get predictionStream => _predictionController.stream;

  BluetoothConnectionState _lastConnectionState = BluetoothConnectionState.disconnected;
  
  bool _isScanning = false;
  Esp32HealthData? _latestData;
  Timer? _predictionTimer;
  bool _isProcessing = false;

  // Use a static variable for throttling to survive re-instantiation (if any)
  static DateTime? _lastPredictionTime;

  Future<void> scanAndConnect() async {
    if (_isScanning) return;
    
    // If already connected, don't restart scan/connection logic
    if (_targetDevice != null && _lastConnectionState == BluetoothConnectionState.connected) {
      return;
    }

    _isScanning = true;
    print("BLE: [Lifecycle] scanAndConnect triggered");

    try {
      // 1. Check already connected devices first
      List<BluetoothDevice> connected = await FlutterBluePlus.connectedDevices;
      for (var d in connected) {
        if (d.platformName == deviceName) {
          _targetDevice = d;
          await _connectToDevice(d);
          _isScanning = false;
          return;
        }
      }

      // 2. Scan if not found
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 10),
        withNames: [deviceName],
      );

      StreamSubscription? scanSubscription;
      scanSubscription = FlutterBluePlus.onScanResults.listen((results) async {
        for (ScanResult r in results) {
          if (r.device.platformName == deviceName) {
            await FlutterBluePlus.stopScan();
            _targetDevice = r.device;
            await _connectToDevice(_targetDevice!);
            scanSubscription?.cancel();
            break;
          }
        }
      });

      await FlutterBluePlus.isScanning.where((scanning) => !scanning).first;
      scanSubscription?.cancel();
    } catch (e) {
      print('BLE: Scan error: $e');
    } finally {
      _isScanning = false;
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    // Only set up listeners once per device instance
    device.connectionState.listen((state) {
      if (_lastConnectionState != state) {
        print("BLE: Connection State -> $state");
        _lastConnectionState = state;
        _connectionController.add(state);
        if (state == BluetoothConnectionState.disconnected) {
          _stopPredictionTimer();
        }
      }
    });

    try {
      await device.connect(autoConnect: true);
      List<BluetoothService> services = await device.discoverServices();
      for (BluetoothService service in services) {
        if (service.uuid.toString().toLowerCase() == serviceUuid.toLowerCase()) {
          for (BluetoothCharacteristic characteristic in service.characteristics) {
            final charUuid = characteristic.uuid.toString().toLowerCase();
            if (charUuid == healthCharacteristicUuid.toLowerCase()) {
              _healthCharacteristic = characteristic;
            } else if (charUuid == commandCharacteristicUuid.toLowerCase()) {
              _commandCharacteristic = characteristic;
            }
          }
        }
      }

      if (_healthCharacteristic != null) {
        await _subscribeToNotifications(_healthCharacteristic!);
        _startPredictionTimer();
      }
    } catch (e) {
      print('BLE: Error connecting: $e');
    }
  }

  Future<void> _subscribeToNotifications(BluetoothCharacteristic characteristic) async {
    await characteristic.setNotifyValue(true);
    // Use onValueReceived to avoid multiple stream listeners if called again
    characteristic.onValueReceived.listen((value) {
      if (value.isNotEmpty) {
        try {
          final raw = utf8.decode(value);
          final data = Esp32HealthData.fromJson(jsonDecode(raw));
          _latestData = data; 
          _dataController.add(data); // Live data for charts
        } catch (_) {}
      }
    });
  }

  void _startPredictionTimer() {
    _stopPredictionTimer();
    
    // Check if we should run an immediate prediction (only if > 1 min since last one)
    _checkAndRunPrediction();

    // Set up the periodic check
    _predictionTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _checkAndRunPrediction();
    });
  }

  void _checkAndRunPrediction() {
    if (_latestData == null || _isProcessing) return;

    final now = DateTime.now();
    if (_lastPredictionTime == null || 
        now.difference(_lastPredictionTime!) >= const Duration(minutes: 1)) {
      _processPrediction(_latestData!);
    }
  }

  void _stopPredictionTimer() {
    _predictionTimer?.cancel();
    _predictionTimer = null;
  }

  Future<void> _processPrediction(Esp32HealthData data) async {
    _isProcessing = true;
    _lastPredictionTime = DateTime.now();
    
    print('BLE: [API CALL] Triggering AI Prediction at ${DateTime.now()}');

    try {
      final response = await http.post(
        Uri.parse(predictionUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "heart_rate": data.bpm,
          "motion": data.calculatedMotion,
        }),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final prediction = result['prediction']?.toString().toUpperCase() ?? "UNKNOWN";
        final confidence = (result['confidence'] ?? 0.0).toDouble();
        final status = confidence < 0.60 ? "UNCERTAIN" : prediction;

        final String bleResponse = "$status|${confidence.toStringAsFixed(2)}|${data.bpm}";
        _predictionController.add(bleResponse);
        
        // Write back to ESP32
        if (_commandCharacteristic != null && _lastConnectionState == BluetoothConnectionState.connected) {
          await _commandCharacteristic!.write(utf8.encode(bleResponse), withoutResponse: false);
          print("BLE: [API RESULT] Sent to ESP32: $bleResponse");
        }
      }
    } catch (e) {
      print('BLE: Prediction API Error: $e');
    } finally {
      _isProcessing = false;
    }
  }

  void disconnect() {
    _stopPredictionTimer();
    _targetDevice?.disconnect();
  }
}
