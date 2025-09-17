// Real-time Data Synchronization Service

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/firestore_service.dart';
import '../services/location_service.dart';
import '../models/user_models.dart';
import '../models/blockchain_models.dart';

class RealtimeSyncService {
  static final RealtimeSyncService _instance = RealtimeSyncService._internal();
  factory RealtimeSyncService() => _instance;
  RealtimeSyncService._internal();

  final FirestoreService _firestoreService = FirestoreService();
  final LocationService _locationService = LocationService.instance;

  // Stream controllers for real-time data
  final StreamController<UserData?> _userDataController =
      StreamController<UserData?>.broadcast();
  final StreamController<List<Map<String, dynamic>>> _alertsController =
      StreamController<List<Map<String, dynamic>>>.broadcast();
  final StreamController<DigitalTouristID?> _digitalIdController =
      StreamController<DigitalTouristID?>.broadcast();
  final StreamController<List<EmergencyContact>> _emergencyContactsController =
      StreamController<List<EmergencyContact>>.broadcast();
  final StreamController<LocationData?> _locationController =
      StreamController<LocationData?>.broadcast();
  final StreamController<bool> _connectivityController =
      StreamController<bool>.broadcast();

  // Subscription management
  final Map<String, StreamSubscription> _subscriptions = {};

  // Sync state
  bool _isInitialized = false;
  bool _isOnline = true;
  String? _currentUserId;
  Timer? _locationSyncTimer;
  Timer? _heartbeatTimer;

  // Offline queue for pending operations
  final List<PendingOperation> _pendingOperations = [];

  // Getters for streams
  Stream<UserData?> get userDataStream => _userDataController.stream;
  Stream<List<Map<String, dynamic>>> get alertsStream =>
      _alertsController.stream;
  Stream<DigitalTouristID?> get digitalIdStream => _digitalIdController.stream;
  Stream<List<EmergencyContact>> get emergencyContactsStream =>
      _emergencyContactsController.stream;
  Stream<LocationData?> get locationStream => _locationController.stream;
  Stream<bool> get connectivityStream => _connectivityController.stream;

  bool get isOnline => _isOnline;
  bool get isInitialized => _isInitialized;

  /// Initialize real-time sync service
  Future<void> initialize(String userId) async {
    if (_isInitialized && _currentUserId == userId) return;

    _currentUserId = userId;

    try {
      // Setup connectivity monitoring
      await _setupConnectivityMonitoring();

      // Setup real-time data streams
      await _setupDataStreams(userId);

      // Setup location tracking
      await _setupLocationTracking(userId);

      // Setup heartbeat for connection monitoring
      _setupHeartbeat();

      // Process any pending offline operations
      await _processPendingOperations();

      _isInitialized = true;
      print('Real-time sync service initialized for user: $userId');
    } catch (e) {
      print('Real-time sync initialization error: $e');
      rethrow;
    }
  }

  /// Setup connectivity monitoring
  Future<void> _setupConnectivityMonitoring() async {
    // Check initial connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    _isOnline = connectivityResult != ConnectivityResult.none;
    _connectivityController.add(_isOnline);

    // Listen for connectivity changes
    _subscriptions['connectivity'] = Connectivity().onConnectivityChanged
        .listen((result) {
          final wasOnline = _isOnline;
          _isOnline = result != ConnectivityResult.none;
          _connectivityController.add(_isOnline);

          if (!wasOnline && _isOnline) {
            // Came back online - process pending operations
            _processPendingOperations();
          }
        });
  }

  /// Setup real-time data streams
  Future<void> _setupDataStreams(String userId) async {
    // User profile stream
    _subscriptions['userProfile'] = _firestoreService
        .streamUserProfile(userId)
        .listen(
          (userData) {
            _userDataController.add(userData);
          },
          onError: (error) {
            print('User profile stream error: $error');
          },
        );

    // Alerts stream
    _subscriptions['alerts'] = _firestoreService
        .streamUserAlerts(userId)
        .listen(
          (alerts) {
            _alertsController.add(alerts);
          },
          onError: (error) {
            print('Alerts stream error: $error');
          },
        );

    // Digital ID stream
    _subscriptions['digitalId'] = _firestoreService
        .streamDigitalId(userId)
        .listen(
          (digitalId) {
            _digitalIdController.add(digitalId);
          },
          onError: (error) {
            print('Digital ID stream error: $error');
          },
        );

    // Emergency contacts stream
    _subscriptions['emergencyContacts'] = _firestoreService
        .streamEmergencyContacts(userId)
        .listen(
          (contacts) {
            _emergencyContactsController.add(contacts);
          },
          onError: (error) {
            print('Emergency contacts stream error: $error');
          },
        );
  }

  /// Setup location tracking
  Future<void> _setupLocationTracking(String userId) async {
    try {
      // Initialize location service
      await _locationService.initialize();
      print('Location service initialized');

      // Start location tracking
      _locationService.startTracking();
      _subscriptions['location'] = _locationService.locationStream.listen(
        (locationData) {
          _locationController.add(locationData);
          _syncLocationToFirestore(userId, locationData);
        },
        onError: (error) {
          print('Location stream error: $error');
        },
      );

      // Setup periodic location sync
      _locationSyncTimer = Timer.periodic(Duration(minutes: 5), (timer) {
        _syncCurrentLocation(userId);
      });
    } catch (e) {
      print('Location tracking setup error: $e');
    }
  }

  /// Setup heartbeat for connection monitoring
  void _setupHeartbeat() {
    _heartbeatTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      _sendHeartbeat();
    });
  }

  /// Sync current location to Firestore
  Future<void> _syncCurrentLocation(String userId) async {
    try {
      final locationData = _locationService.currentLocation;
      if (locationData != null) {
        await _syncLocationToFirestore(userId, locationData);
      }
    } catch (e) {
      print('Current location sync error: $e');
    }
  }

  /// Sync location data to Firestore
  Future<void> _syncLocationToFirestore(
    String userId,
    LocationData locationData,
  ) async {
    final locationMap = {
      'latitude': locationData.latitude,
      'longitude': locationData.longitude,
      'accuracy': locationData.accuracy,
      'address': locationData.address,
      'timestamp': locationData.timestamp.toIso8601String(),
    };

    if (_isOnline) {
      try {
        await _firestoreService.saveLocation(userId, locationMap);
      } catch (e) {
        print('Location sync error: $e');
        // Add to pending operations if failed
        _addPendingOperation(
          PendingOperation(
            type: OperationType.saveLocation,
            data: locationMap,
            userId: userId,
          ),
        );
      }
    } else {
      // Add to pending operations when offline
      _addPendingOperation(
        PendingOperation(
          type: OperationType.saveLocation,
          data: locationMap,
          userId: userId,
        ),
      );
    }
  }

  /// Update user profile with real-time sync
  Future<void> updateUserProfile(UserData userData) async {
    if (_currentUserId == null) return;

    if (_isOnline) {
      try {
        await _firestoreService.saveUserProfile(_currentUserId!, userData);
      } catch (e) {
        print('User profile update error: $e');
        _addPendingOperation(
          PendingOperation(
            type: OperationType.updateProfile,
            data: userData.toJson(),
            userId: _currentUserId!,
          ),
        );
      }
    } else {
      _addPendingOperation(
        PendingOperation(
          type: OperationType.updateProfile,
          data: userData.toJson(),
          userId: _currentUserId!,
        ),
      );
    }
  }

  /// Save alert with real-time sync
  Future<void> saveAlert(Map<String, dynamic> alertData) async {
    if (_currentUserId == null) return;

    if (_isOnline) {
      try {
        await _firestoreService.saveAlert(_currentUserId!, alertData);
      } catch (e) {
        print('Alert save error: $e');
        _addPendingOperation(
          PendingOperation(
            type: OperationType.saveAlert,
            data: alertData,
            userId: _currentUserId!,
          ),
        );
      }
    } else {
      _addPendingOperation(
        PendingOperation(
          type: OperationType.saveAlert,
          data: alertData,
          userId: _currentUserId!,
        ),
      );
    }
  }

  /// Save emergency contact with real-time sync
  Future<void> saveEmergencyContact(EmergencyContact contact) async {
    if (_currentUserId == null) return;

    if (_isOnline) {
      try {
        await _firestoreService.saveEmergencyContact(_currentUserId!, contact);
      } catch (e) {
        print('Emergency contact save error: $e');
        _addPendingOperation(
          PendingOperation(
            type: OperationType.saveEmergencyContact,
            data: contact.toJson(),
            userId: _currentUserId!,
          ),
        );
      }
    } else {
      _addPendingOperation(
        PendingOperation(
          type: OperationType.saveEmergencyContact,
          data: contact.toJson(),
          userId: _currentUserId!,
        ),
      );
    }
  }

  /// Save digital ID with real-time sync
  Future<void> saveDigitalId(DigitalTouristID digitalId) async {
    if (_currentUserId == null) return;

    if (_isOnline) {
      try {
        await _firestoreService.saveDigitalId(_currentUserId!, digitalId);
      } catch (e) {
        print('Digital ID save error: $e');
        _addPendingOperation(
          PendingOperation(
            type: OperationType.saveDigitalId,
            data: digitalId.toJson(),
            userId: _currentUserId!,
          ),
        );
      }
    } else {
      _addPendingOperation(
        PendingOperation(
          type: OperationType.saveDigitalId,
          data: digitalId.toJson(),
          userId: _currentUserId!,
        ),
      );
    }
  }

  /// Add operation to pending queue
  void _addPendingOperation(PendingOperation operation) {
    _pendingOperations.add(operation);
    print('Added pending operation: ${operation.type}');
  }

  /// Process pending operations when back online
  Future<void> _processPendingOperations() async {
    if (!_isOnline || _pendingOperations.isEmpty) return;

    print('Processing ${_pendingOperations.length} pending operations');

    final operationsToProcess = List<PendingOperation>.from(_pendingOperations);
    _pendingOperations.clear();

    for (final operation in operationsToProcess) {
      try {
        await _executePendingOperation(operation);
      } catch (e) {
        print(
          'Failed to process pending operation: ${operation.type}, error: $e',
        );
        // Re-add failed operation to queue
        _pendingOperations.add(operation);
      }
    }
  }

  /// Execute a pending operation
  Future<void> _executePendingOperation(PendingOperation operation) async {
    switch (operation.type) {
      case OperationType.updateProfile:
        final userData = UserData.fromJson(operation.data);
        await _firestoreService.saveUserProfile(operation.userId, userData);
        break;
      case OperationType.saveAlert:
        await _firestoreService.saveAlert(operation.userId, operation.data);
        break;
      case OperationType.saveLocation:
        await _firestoreService.saveLocation(operation.userId, operation.data);
        break;
      case OperationType.saveEmergencyContact:
        final contact = EmergencyContact.fromJson(operation.data);
        await _firestoreService.saveEmergencyContact(operation.userId, contact);
        break;
      case OperationType.saveDigitalId:
        final digitalId = DigitalTouristID.fromJson(operation.data);
        await _firestoreService.saveDigitalId(operation.userId, digitalId);
        break;
    }
  }

  /// Send heartbeat to maintain connection
  Future<void> _sendHeartbeat() async {
    if (_currentUserId != null && _isOnline) {
      try {
        await _firestoreService.saveAnalyticsEvent(_currentUserId!, {
          'event': 'heartbeat',
          'timestamp': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        print('Heartbeat error: $e');
      }
    }
  }

  /// Stop real-time sync
  Future<void> stop() async {
    // Cancel all subscriptions
    for (final subscription in _subscriptions.values) {
      await subscription.cancel();
    }
    _subscriptions.clear();

    // Cancel timers
    _locationSyncTimer?.cancel();
    _heartbeatTimer?.cancel();

    _isInitialized = false;
    _currentUserId = null;

    print('Real-time sync service stopped');
  }

  /// Dispose resources
  void dispose() {
    stop();
    _userDataController.close();
    _alertsController.close();
    _digitalIdController.close();
    _emergencyContactsController.close();
    _locationController.close();
    _connectivityController.close();
  }
}

/// Pending operation for offline queue
class PendingOperation {
  final OperationType type;
  final Map<String, dynamic> data;
  final String userId;
  final DateTime timestamp;

  PendingOperation({
    required this.type,
    required this.data,
    required this.userId,
  }) : timestamp = DateTime.now();
}

enum OperationType {
  updateProfile,
  saveAlert,
  saveLocation,
  saveEmergencyContact,
  saveDigitalId,
}
