import 'package:sqflite/sqflite.dart';
import 'package:smart_passenger_alert/models/sensor_model.dart';
import 'package:smart_passenger_alert/utils/constants.dart';

class AssistantMessage {
  final int? id;
  final String role;
  final String message;
  final DateTime createdAt;

  AssistantMessage({
    this.id,
    required this.role,
    required this.message,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'role': role,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AssistantMessage.fromMap(Map<String, dynamic> map) {
    return AssistantMessage(
      id: map['id'] as int?,
      role: map['role'] as String,
      message: map['message'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}

class LocalDatabaseService {
  LocalDatabaseService._internal();
  static final LocalDatabaseService _instance = LocalDatabaseService._internal();
  factory LocalDatabaseService() => _instance;

  Database? _db;

  Future<Database> get database async {
    if (_db != null) {
      return _db!;
    }

    final basePath = await getDatabasesPath();
    final dbPath = '$basePath/${AppConstants.dbName}';

    _db = await openDatabase(
      dbPath,
      version: AppConstants.dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE sensor_logs(
            id TEXT PRIMARY KEY,
            userId TEXT NOT NULL,
            heartRate REAL NOT NULL,
            movement REAL NOT NULL,
            temperature REAL NOT NULL,
            oxygenLevel REAL NOT NULL,
            sleepPhase TEXT NOT NULL,
            timestamp TEXT NOT NULL,
            deviceId TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE assistant_messages(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            role TEXT NOT NULL,
            message TEXT NOT NULL,
            createdAt TEXT NOT NULL
          )
        ''');
      },
    );

    return _db!;
  }

  Future<void> saveSensorData(SensorData sensorData) async {
    final db = await database;
    await db.insert(
      'sensor_logs',
      {
        'id': sensorData.id,
        'userId': sensorData.userId,
        'heartRate': sensorData.heartRate,
        'movement': sensorData.movement,
        'temperature': sensorData.temperature,
        'oxygenLevel': sensorData.oxygenLevel,
        'sleepPhase': sensorData.sleepPhase,
        'timestamp': sensorData.timestamp.toIso8601String(),
        'deviceId': sensorData.deviceId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<SensorData>> getRecentSensorData(String userId, {int limit = 40}) async {
    final db = await database;
    final rows = await db.query(
      'sensor_logs',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
      limit: limit,
    );

    return rows.map(_sensorDataFromRow).toList();
  }

  Future<SensorData?> getLatestSensorData(String userId) async {
    final data = await getRecentSensorData(userId, limit: 1);
    if (data.isEmpty) {
      return null;
    }
    return data.first;
  }

  Future<void> saveAssistantMessage(AssistantMessage message) async {
    final db = await database;
    await db.insert(
      'assistant_messages',
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<AssistantMessage>> getAssistantMessages({int limit = 60}) async {
    final db = await database;
    final rows = await db.query(
      'assistant_messages',
      orderBy: 'createdAt DESC',
      limit: limit,
    );

    return rows.map(AssistantMessage.fromMap).toList().reversed.toList();
  }

  SensorData _sensorDataFromRow(Map<String, dynamic> row) {
    return SensorData(
      id: row['id'] as String,
      userId: row['userId'] as String,
      heartRate: (row['heartRate'] as num).toDouble(),
      movement: (row['movement'] as num).toDouble(),
      temperature: (row['temperature'] as num).toDouble(),
      oxygenLevel: (row['oxygenLevel'] as num).toDouble(),
      sleepPhase: row['sleepPhase'] as String,
      timestamp: DateTime.parse(row['timestamp'] as String),
      deviceId: row['deviceId'] as String,
    );
  }
}
