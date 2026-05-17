import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:http/http.dart' as http;
import 'package:smart_passenger_alert/models/esp32_health_data.dart';

class Esp32BleService {
  static const String deviceName = "ESP32-HealthSensor";
  static const String serviceUuid = "12345678-1234-1234-1234-1234567890ab";
  static const String characteristicUuid = "abcd1234-5678-90ab-cdef-1234567890ab";
  static const String predictionUrl = "https://eranda-sathsara-javi.hf.space/predict";

  BluetoothDevice? _targetDevice;
  BluetoothCharacteristic? _targetCharacteristic;
  
  final StreamController<Esp32HealthData> _dataController = StreamController<Esp32HealthData>.broadcast();
  Stream<Esp32HealthData> get healthDataStream => _dataController.stream;

  final StreamController<BluetoothConnectionState> _connectionController = StreamController<BluetoothConnectionState>.broadcast();
  Stream<BluetoothConnectionState> get connectionStateStream => _connectionController.stream;

  final StreamController<String> _predictionController = StreamController<String>.broadcast();
  Stream<String> get predictionStream => _predictionController.stream;

  BluetoothConnectionState _lastConnectionState = BluetoothConnectionState.disconnected;
  BluetoothConnectionState get lastConnectionState => _lastConnectionState;

  bool _isScanning = false;

  Future<void> scanAndConnect() async {
    if (_isScanning) return;
    if (_targetDevice != null && _lastConnectionState == BluetoothConnectionState.connected) return;

    _isScanning = true;

    try {
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 15),
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
      print('BLE Scan error: $e');
    } finally {
      _isScanning = false;
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    device.connectionState.listen((state) {
      _lastConnectionState = state;
      _connectionController.add(state);
    });

    try {
      await device.connect();
      List<BluetoothService> services = await device.discoverServices();
      for (BluetoothService service in services) {
        if (service.uuid.toString().toLowerCase() == serviceUuid.toLowerCase()) {
          for (BluetoothCharacteristic characteristic in service.characteristics) {
            if (characteristic.uuid.toString().toLowerCase() == characteristicUuid.toLowerCase()) {
              _targetCharacteristic = characteristic;
              await _subscribeToNotifications(characteristic);
            }
          }
        }
      }
    } catch (e) {
      print('Error connecting to BLE device: $e');
    }
  }

  Future<void> _subscribeToNotifications(BluetoothCharacteristic characteristic) async {
    await characteristic.setNotifyValue(true);
    characteristic.lastValueStream.listen((value) async {
      if (value.isNotEmpty) {
        try {
          final raw = utf8.decode(value);
          final json = jsonDecode(raw);
          final data = Esp32HealthData.fromJson(json);
          _dataController.add(data);
          
          // Trigger prediction logic
          await _processPrediction(data);
        } catch (e) {
          print('Error decoding BLE data: $e');
        }
      }
    });
  }

  Future<void> _processPrediction(Esp32HealthData data) async {
    String statusResult = "API_ERROR";
    double confidence = 0.0;

    try {
      final response = await http.post(
        Uri.parse(predictionUrl),
        headers: {'Content-Type': 'application/json', 'accept': 'application/json'},
        body: jsonEncode({
          "heart_rate": data.bpm,
          "motion": data.calculatedMotion,
        }),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final prediction = result['prediction']?.toString().toUpperCase() ?? "UNKNOWN";
        confidence = (result['confidence'] ?? 0.0).toDouble();

        if (confidence < 0.60) {
          statusResult = "UNCERTAIN";
        } else {
          statusResult = prediction;
        }
      }
    } catch (e) {
      print('Prediction API Error: $e');
      statusResult = "API_ERROR";
    }

    final String bleResponse = "$statusResult|${confidence.toStringAsFixed(2)}|${data.bpm}";
    _predictionController.add(bleResponse);
    
    // Send back to ESP32
    if (_targetCharacteristic != null && _lastConnectionState == BluetoothConnectionState.connected) {
      try {
        await _targetCharacteristic!.write(utf8.encode(bleResponse), withoutResponse: false);
      } catch (e) {
        print('Error writing to ESP32: $e');
      }
    }
  }

  void disconnect() {
    _targetDevice?.disconnect();
  }
}
