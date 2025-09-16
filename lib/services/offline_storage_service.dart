// Offline Data Persistence Service

import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_models.dart';
import '../models/blockchain_models.dart';

class OfflineStorageService {
  static final OfflineStorageService _instance = OfflineStorageService._internal();
  factory OfflineStorageService() => _instance;
  OfflineStorageService._internal();

  Database? _database;
  SharedPreferences? _prefs;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  /// Initialize offline storage
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize SharedPreferences
      _prefs = await SharedPreferences.getInstance();

      // Initialize SQLite database
      await _initializeDatabase();

      _isInitialized = true;
      print('Offline storage service initialized');
    } catch (e) {
      print('Offline storage initialization error: $e');
      rethrow;
    }
  }

  /// Initialize SQLite database
  Future<void> _initializeDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'safe_tour_offline.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
      onUpgrade: _upgradeTables,
    );
  }

  /// Create database tables
  Future<void> _createTables(Database db, int version) async {
    // User profiles table
    await db.execute('''
      CREATE TABLE user_profiles (
        id TEXT PRIMARY KEY,
        data TEXT NOT NULL,
        last_updated INTEGER NOT NULL,
        sync_status TEXT DEFAULT 'pending'
      )
    ''');

    // Trips table
    await db.execute('''
      CREATE TABLE trips (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        last_updated INTEGER NOT NULL,
        sync_status TEXT DEFAULT 'pending'
      )
    ''');

    // Alerts table
    await db.execute('''
      CREATE TABLE alerts (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        is_read INTEGER DEFAULT 0,
        sync_status TEXT DEFAULT 'pending'
      )
    ''');

    // Locations table
    await db.execute('''
      CREATE TABLE locations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        accuracy REAL,
        timestamp INTEGER NOT NULL,
        sync_status TEXT DEFAULT 'pending'
      )
    ''');

    // Emergency contacts table
    await db.execute('''
      CREATE TABLE emergency_contacts (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        sync_status TEXT DEFAULT 'pending'
      )
    ''');

    // Digital IDs table
    await db.execute('''
      CREATE TABLE digital_ids (
        user_id TEXT PRIMARY KEY,
        data TEXT NOT NULL,
        last_updated INTEGER NOT NULL,
        sync_status TEXT DEFAULT 'pending'
      )
    ''');

    // Pending operations table
    await db.execute('''
      CREATE TABLE pending_operations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        operation_type TEXT NOT NULL,
        data TEXT NOT NULL,
        user_id TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        retry_count INTEGER DEFAULT 0
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_locations_user_timestamp ON locations(user_id, timestamp)');
    await db.execute('CREATE INDEX idx_alerts_user_created ON alerts(user_id, created_at)');
    await db.execute('CREATE INDEX idx_pending_operations_user ON pending_operations(user_id)');
  }

  /// Upgrade database tables
  Future<void> _upgradeTables(Database db, int oldVersion, int newVersion) async {
    // Handle database schema upgrades here
    if (oldVersion < newVersion) {
      // Add migration logic for future versions
    }
  }

  /// User Profile Operations

  /// Save user profile offline
  Future<void> saveUserProfile(String userId, UserData userData) async {
    await _ensureInitialized();

    final data = jsonEncode(userData.toJson());
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    await _database!.insert(
      'user_profiles',
      {
        'id': userId,
        'data': data,
        'last_updated': timestamp,
        'sync_status': 'pending',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get user profile from offline storage
  Future<UserData?> getUserProfile(String userId) async {
    await _ensureInitialized();

    final result = await _database!.query(
      'user_profiles',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (result.isNotEmpty) {
      final data = jsonDecode(result.first['data'] as String);
      return UserData.fromJson(data);
    }

    return null;
  }

  /// Trip Operations

  /// Save trip offline
  Future<String> saveTrip(String userId, TripDetails tripDetails) async {
    await _ensureInitialized();

    final tripId = 'trip_${DateTime.now().millisecondsSinceEpoch}';
    final data = jsonEncode(tripDetails.toJson());
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    await _database!.insert('trips', {
      'id': tripId,
      'user_id': userId,
      'data': data,
      'created_at': timestamp,
      'last_updated': timestamp,
      'sync_status': 'pending',
    });

    return tripId;
  }

  /// Get user trips from offline storage
  Future<List<TripDetails>> getUserTrips(String userId) async {
    await _ensureInitialized();

    final result = await _database!.query(
      'trips',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return result.map((row) {
      final data = jsonDecode(row['data'] as String);
      return TripDetails.fromJson(data);
    }).toList();
  }

  /// Alert Operations

  /// Save alert offline
  Future<String> saveAlert(String userId, Map<String, dynamic> alertData) async {
    await _ensureInitialized();

    final alertId = 'alert_${DateTime.now().millisecondsSinceEpoch}';
    final data = jsonEncode(alertData);
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    await _database!.insert('alerts', {
      'id': alertId,
      'user_id': userId,
      'data': data,
      'created_at': timestamp,
      'is_read': 0,
      'sync_status': 'pending',
    });

    return alertId;
  }

  /// Get user alerts from offline storage
  Future<List<Map<String, dynamic>>> getUserAlerts(String userId, {int limit = 50}) async {
    await _ensureInitialized();

    final result = await _database!.query(
      'alerts',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
      limit: limit,
    );

    return result.map((row) {
      final data = jsonDecode(row['data'] as String) as Map<String, dynamic>;
      data['id'] = row['id'];
      data['isRead'] = (row['is_read'] as int) == 1;
      return data;
    }).toList();
  }

  /// Mark alert as read
  Future<void> markAlertAsRead(String alertId) async {
    await _ensureInitialized();

    await _database!.update(
      'alerts',
      {'is_read': 1},
      where: 'id = ?',
      whereArgs: [alertId],
    );
  }

  /// Location Operations

  /// Save location offline
  Future<void> saveLocation(String userId, Map<String, dynamic> locationData) async {
    await _ensureInitialized();

    final timestamp = DateTime.now().millisecondsSinceEpoch;

    await _database!.insert('locations', {
      'user_id': userId,
      'latitude': locationData['latitude'],
      'longitude': locationData['longitude'],
      'accuracy': locationData['accuracy'],
      'timestamp': timestamp,
      'sync_status': 'pending',
    });
  }

  /// Get user location history from offline storage
  Future<List<Map<String, dynamic>>> getUserLocationHistory(
    String userId, {
    int limit = 100,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await _ensureInitialized();

    String whereClause = 'user_id = ?';
    List<dynamic> whereArgs = [userId];

    if (startDate != null) {
      whereClause += ' AND timestamp >= ?';
      whereArgs.add(startDate.millisecondsSinceEpoch);
    }

    if (endDate != null) {
      whereClause += ' AND timestamp <= ?';
      whereArgs.add(endDate.millisecondsSinceEpoch);
    }

    final result = await _database!.query(
      'locations',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'timestamp DESC',
      limit: limit,
    );

    return result.map((row) => {
      'id': row['id'],
      'latitude': row['latitude'],
      'longitude': row['longitude'],
      'accuracy': row['accuracy'],
      'timestamp': DateTime.fromMillisecondsSinceEpoch(row['timestamp'] as int),
    }).toList();
  }

  /// Emergency Contacts Operations

  /// Save emergency contact offline
  Future<String> saveEmergencyContact(String userId, EmergencyContact contact) async {
    await _ensureInitialized();

    final contactId = 'contact_${DateTime.now().millisecondsSinceEpoch}';
    final data = jsonEncode(contact.toJson());
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    await _database!.insert('emergency_contacts', {
      'id': contactId,
      'user_id': userId,
      'data': data,
      'created_at': timestamp,
      'sync_status': 'pending',
    });

    return contactId;
  }

  /// Get emergency contacts from offline storage
  Future<List<EmergencyContact>> getEmergencyContacts(String userId) async {
    await _ensureInitialized();

    final result = await _database!.query(
      'emergency_contacts',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at',
    );

    return result.map((row) {
      final data = jsonDecode(row['data'] as String);
      return EmergencyContact.fromJson(data);
    }).toList();
  }

  /// Digital ID Operations

  /// Save digital ID offline
  Future<void> saveDigitalId(String userId, DigitalTouristID digitalId) async {
    await _ensureInitialized();

    final data = jsonEncode(digitalId.toJson());
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    await _database!.insert(
      'digital_ids',
      {
        'user_id': userId,
        'data': data,
        'last_updated': timestamp,
        'sync_status': 'pending',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get digital ID from offline storage
  Future<DigitalTouristID?> getDigitalId(String userId) async {
    await _ensureInitialized();

    final result = await _database!.query(
      'digital_ids',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    if (result.isNotEmpty) {
      final data = jsonDecode(result.first['data'] as String);
      return DigitalTouristID.fromJson(data);
    }

    return null;
  }

  /// Sync Operations

  /// Get pending sync operations
  Future<List<Map<String, dynamic>>> getPendingSyncOperations() async {
    await _ensureInitialized();

    final tables = ['user_profiles', 'trips', 'alerts', 'locations', 'emergency_contacts', 'digital_ids'];
    final pendingOperations = <Map<String, dynamic>>[];

    for (final table in tables) {
      final result = await _database!.query(
        table,
        where: 'sync_status = ?',
        whereArgs: ['pending'],
      );

      for (final row in result) {
        pendingOperations.add({
          'table': table,
          'data': row,
        });
      }
    }

    return pendingOperations;
  }

  /// Mark operation as synced
  Future<void> markAsSynced(String table, String id) async {
    await _ensureInitialized();

    await _database!.update(
      table,
      {'sync_status': 'synced'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// SharedPreferences Operations

  /// Save simple key-value data
  Future<void> savePreference(String key, dynamic value) async {
    await _ensureInitialized();

    if (value is String) {
      await _prefs!.setString(key, value);
    } else if (value is int) {
      await _prefs!.setInt(key, value);
    } else if (value is double) {
      await _prefs!.setDouble(key, value);
    } else if (value is bool) {
      await _prefs!.setBool(key, value);
    } else if (value is List<String>) {
      await _prefs!.setStringList(key, value);
    } else {
      await _prefs!.setString(key, jsonEncode(value));
    }
  }

  /// Get preference value
  T? getPreference<T>(String key) {
    if (!_isInitialized || _prefs == null) return null;

    final value = _prefs!.get(key);
    if (value is T) {
      return value;
    } else if (value is String && T != String) {
      try {
        return jsonDecode(value) as T;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Clear all offline data
  Future<void> clearAllData() async {
    await _ensureInitialized();

    // Clear database
    await _database!.delete('user_profiles');
    await _database!.delete('trips');
    await _database!.delete('alerts');
    await _database!.delete('locations');
    await _database!.delete('emergency_contacts');
    await _database!.delete('digital_ids');
    await _database!.delete('pending_operations');

    // Clear preferences
    await _prefs!.clear();
  }

  /// Ensure service is initialized
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _database?.close();
    _database = null;
    _prefs = null;
    _isInitialized = false;
  }
}
