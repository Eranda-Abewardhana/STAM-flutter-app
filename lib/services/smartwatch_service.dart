import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_passenger_alert/models/sensor_model.dart';
import 'package:smart_passenger_alert/services/local_database_service.dart';
import 'package:smart_passenger_alert/utils/constants.dart';

class BleWatchDevice {
  final String id;
  final String name;
  final int rssi;
  final bool connectable;

  const BleWatchDevice({
    required this.id,
    required this.name,
    required this.rssi,
    required this.connectable,
  });
}

class SmartwatchService {
  SmartwatchService._internal() {
    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (final r in results) {
        _scanCache[r.device.remoteId.str] = r.device;
      }
    });
  }
  static final SmartwatchService _instance = SmartwatchService._internal();
  factory SmartwatchService() => _instance;

  final _rng = Random();
  final _controller = StreamController<SensorData>.broadcast();
  final Map<String, BluetoothDevice> _scanCache = {};
  Timer? _timer;
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<List<int>>? _notificationSubscription;
  BluetoothDevice? _activeDevice;
  bool _connected = false;

  bool get isConnected => _connected;
  BluetoothDevice? get activeDevice => _activeDevice;
  Stream<SensorData> get sensorDataStream => _controller.stream;

  static final Guid _heartRateServiceGuid = Guid('180D');
  static final Guid _heartRateCharacteristicGuid = Guid('2A37');
  static final Guid _esp32ServiceUuid = Guid('12345678-1234-1234-1234-1234567890ab');
  static final Guid _esp32HealthCharacteristicUuid = Guid('abcd1234-5678-90ab-cdef-1234567890ab');

  static const String _lastConnectedDeviceKey = 'last_connected_ble_watch';

  Future<void> saveLastConnectedDevice(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastConnectedDeviceKey, deviceId);
  }

  Future<String?> getLastConnectedDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastConnectedDeviceKey);
  }

  Future<bool> tryAutoReconnect({required String userId}) async {
    if (kIsWeb) return false;
    if (_connected) return true;

    final lastDeviceId = await getLastConnectedDeviceId();
    if (lastDeviceId == null || lastDeviceId.isEmpty) return false;

    final connected = await FlutterBluePlus.connectedSystemDevices;
    for (var d in connected) {
      if (d.remoteId.str == lastDeviceId) {
        await _connectDevice(d, userId);
        return _connected;
      }
    }

    await scanForDevices(timeout: const Duration(seconds: 5));
    if (_scanCache.containsKey(lastDeviceId)) {
      await connectToSmartwatch(userId: userId, deviceId: lastDeviceId);
    }
    return _connected;
  }

  Future<bool> requestPermissions() async {
    if (kIsWeb) return true;
    if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = deviceInfo.version.sdkInt;
      if (sdkInt >= 31) {
        final statuses = await [
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
          Permission.bluetoothAdvertise,
          Permission.locationWhenInUse,
        ].request();
        return statuses[Permission.bluetoothScan]?.isGranted == true &&
            statuses[Permission.bluetoothConnect]?.isGranted == true;
      } else {
        final status = await Permission.locationWhenInUse.request();
        return status.isGranted;
      }
    }
    return true;
  }

  Future<bool> ensureBluetoothOn() async {
    if (kIsWeb) return true;
    var state = await FlutterBluePlus.adapterState.first;
    if (state != BluetoothAdapterState.on) {
      if (Platform.isAndroid) {
        try {
          await FlutterBluePlus.turnOn();
          await Future.delayed(const Duration(milliseconds: 1000));
          state = await FlutterBluePlus.adapterState.first;
        } catch (e) {
          debugPrint('Could not turn on Bluetooth: $e');
        }
      }
    }
    return state == BluetoothAdapterState.on;
  }

  Future<List<BleWatchDevice>> scanForDevices({Duration timeout = const Duration(seconds: 10)}) async {
    final permissionsGranted = await requestPermissions();
    if (!permissionsGranted) return [];
    
    final isBluetoothOn = await ensureBluetoothOn();
    if (!isBluetoothOn) return [];

    await Future.delayed(const Duration(milliseconds: 500));

    try {
      await FlutterBluePlus.startScan(
        timeout: timeout,
        androidUsesFineLocation: true,
      );
      
      await FlutterBluePlus.isScanning.where((scanning) => !scanning).first;
    } catch (e) {
      debugPrint('Error starting scan: $e');
    }
    
    return FlutterBluePlus.lastScanResults.map((scan) {
      String name = scan.advertisementData.advName.trim();
      if (name.isEmpty) {
        name = scan.device.platformName.trim();
      }
      if (name.isEmpty) {
        name = 'Unknown Device';
      }
      
      _scanCache[scan.device.remoteId.str] = scan.device;

      return BleWatchDevice(
        id: scan.device.remoteId.str,
        name: name,
        rssi: scan.rssi,
        connectable: scan.advertisementData.connectable,
      );
    }).toList();
  }

  Future<void> connectToSmartwatch({required String userId, String? deviceId}) async {
    if (_connected) return;
    if (!(await requestPermissions()) || !(await ensureBluetoothOn())) return;

    if (deviceId != null) {
      // 1. Check if already in cache
      if (_scanCache.containsKey(deviceId)) {
        await _connectDevice(_scanCache[deviceId]!, userId);
        if (_connected) return;
      }

      // 2. Check system connected devices
      final connected = await FlutterBluePlus.connectedSystemDevices;
      for (var d in connected) {
        if (d.remoteId.str == deviceId) {
          await _connectDevice(d, userId);
          if (_connected) return;
        }
      }

      // 3. Short targeted scan (3s)
      try {
        await FlutterBluePlus.startScan(timeout: const Duration(seconds: 3), withRemoteIds: [deviceId]);
        await FlutterBluePlus.isScanning.where((s) => !s).first;
        if (_scanCache.containsKey(deviceId)) {
          await _connectDevice(_scanCache[deviceId]!, userId);
          if (_connected) return;
        }
      } catch (e) {
        debugPrint('Targeted scan failed: $e');
      }
    }

    // Fallback to simulation if still not connected and no real device id provided, or if failed to connect to real device
    if (!_connected) {
      _startSimulatedStream(userId: userId, deviceId: deviceId ?? 'sim_watch_001');
    }
  }

  Future<void> _connectDevice(BluetoothDevice device, String userId) async {
    try {
      await device.connect(timeout: const Duration(seconds: 10), autoConnect: false);
      final services = await device.discoverServices();
      
      BluetoothCharacteristic? targetChar;
      bool isEsp32 = false;

      for (var s in services) {
        if (s.uuid == _esp32ServiceUuid) {
          for (var c in s.characteristics) {
            if (c.uuid == _esp32HealthCharacteristicUuid) {
              targetChar = c;
              isEsp32 = true;
              break;
            }
          }
        }
        if (targetChar != null) break;
      }

      if (targetChar == null) {
        for (var s in services) {
          if (s.uuid == _heartRateServiceGuid) {
            for (var c in s.characteristics) {
              if (c.uuid == _heartRateCharacteristicGuid) {
                targetChar = c;
                break;
              }
            }
          }
          if (targetChar != null) break;
        }
      }

      if (targetChar != null) {
        _connected = true;
        _activeDevice = device;
        await saveLastConnectedDevice(device.remoteId.str);
        
        await targetChar.setNotifyValue(true);
        _notificationSubscription = targetChar.onValueReceived.listen((value) {
          if (value.isNotEmpty) {
            SensorData data;
            if (isEsp32) {
              data = _parseEsp32Data(value, userId, device.remoteId.str);
            } else {
              final hr = _decodeHeartRate(value).toDouble();
              data = SensorData(
                id: 'ble_${DateTime.now().millisecondsSinceEpoch}',
                userId: userId,
                heartRate: hr,
                movement: _rng.nextDouble() * 5,
                temperature: 36.5,
                oxygenLevel: 98,
                sleepPhase: 'UNKNOWN',
                timestamp: DateTime.now(),
                deviceId: device.remoteId.str,
                mpuOk: true,
              );
            }
            _controller.add(data);
            LocalDatabaseService().saveSensorData(data);
          }
        });
      }
    } catch (e) {
      debugPrint('Connection error: $e');
    }
  }

  SensorData _parseEsp32Data(List<int> value, String userId, String deviceId) {
    try {
      final jsonStr = utf8.decode(value);
      final data = jsonDecode(jsonStr);
      
      final bpm = (data['bpm'] ?? 0).toDouble();
      final ax = (data['ax'] ?? 0.0).toDouble();
      final ay = (data['ay'] ?? 0.0).toDouble();
      final az = (data['az'] ?? 0.0).toDouble();
      final mpuOk = data['mpu_ok'] ?? true;
      
      final movement = mpuOk ? sqrt(ax * ax + ay * ay + az * az) : 0.0;

      return SensorData(
        id: 'esp32_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        heartRate: bpm,
        movement: movement,
        temperature: 36.6,
        oxygenLevel: 98,
        sleepPhase: 'UNKNOWN',
        timestamp: DateTime.now(),
        deviceId: deviceId,
        ax: ax,
        ay: ay,
        az: az,
        mpuOk: mpuOk,
      );
    } catch (e) {
      debugPrint('Error parsing ESP32 JSON: $e');
      return SensorData(
        id: 'err_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        heartRate: 0,
        movement: 0,
        temperature: 0,
        oxygenLevel: 0,
        sleepPhase: 'UNKNOWN',
        timestamp: DateTime.now(),
        deviceId: deviceId,
        mpuOk: false,
      );
    }
  }

  int _decodeHeartRate(List<int> data) {
    if (data.isEmpty) return 0;
    return (data[0] & 0x01) == 0 ? data[1] : (data[1] | (data[2] << 8));
  }

  void _startSimulatedStream({required String userId, required String deviceId}) {
    _connected = true;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      final hr = 45.0 + _rng.nextInt(40);
      final data = SensorData(
        id: 'sim_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        heartRate: hr,
        movement: _rng.nextDouble() * 5,
        temperature: 36.6,
        oxygenLevel: 98,
        sleepPhase: 'UNKNOWN',
        timestamp: DateTime.now(),
        deviceId: deviceId,
        ax: _rng.nextDouble(),
        ay: _rng.nextDouble(),
        az: 9.8,
        mpuOk: true,
      );
      if (!_controller.isClosed) _controller.add(data);
    });
  }

  Future<void> disconnect() async {
    _connected = false;
    _timer?.cancel();
    await _notificationSubscription?.cancel();
    try { await _activeDevice?.disconnect(); } catch (_) {}
    _activeDevice = null;
  }

  void dispose() {
    _controller.close();
    _timer?.cancel();
    _scanSubscription?.cancel();
  }
}
