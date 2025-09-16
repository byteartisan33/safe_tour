import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';

class LocationService {
  static LocationService? _instance;
  static LocationService get instance => _instance ??= LocationService._();
  LocationService._();

  // Current location data
  LocationData? _currentLocation;
  final StreamController<LocationData> _locationController =
      StreamController<LocationData>.broadcast();
  Timer? _locationTimer;

  // Getters
  LocationData? get currentLocation => _currentLocation;
  Stream<LocationData> get locationStream => _locationController.stream;

  // Static method to get current location
  static Future<LocationData> getCurrentLocation() async {
    final service = instance;
    if (service._currentLocation == null) {
      await service.initialize();
    }
    return service._currentLocation!;
  }

  // Initialize location service
  Future<void> initialize() async {
    try {
      // For web platform, we'll simulate location updates
      if (kIsWeb) {
        _startSimulatedLocationUpdates();
      } else {
        // TODO: Implement actual location services for mobile platforms
        _startSimulatedLocationUpdates();
      }
    } catch (e) {
      print('Error initializing location service: $e');
      _startSimulatedLocationUpdates();
    }
  }

  // Start simulated location updates for demo purposes
  void _startSimulatedLocationUpdates() {
    // Simulate New Delhi location with slight variations
    double baseLat = 28.6139;
    double baseLng = 77.2090;

    _locationTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      // Add small random variations to simulate movement
      double lat = baseLat + (DateTime.now().millisecond % 100 - 50) * 0.0001;
      double lng = baseLng + (DateTime.now().millisecond % 100 - 50) * 0.0001;

      _currentLocation = LocationData(
        latitude: lat,
        longitude: lng,
        address: _getSimulatedAddress(lat, lng),
        timestamp: DateTime.now(),
        accuracy: 10.0,
      );

      _locationController.add(_currentLocation!);
    });

    // Set initial location
    _currentLocation = LocationData(
      latitude: baseLat,
      longitude: baseLng,
      address: 'Connaught Place, New Delhi, India',
      timestamp: DateTime.now(),
      accuracy: 10.0,
    );
    _locationController.add(_currentLocation!);
  }

  // Get simulated address based on coordinates
  String _getSimulatedAddress(double lat, double lng) {
    List<String> delhiAreas = [
      'Connaught Place, New Delhi',
      'India Gate, New Delhi',
      'Red Fort, Old Delhi',
      'Karol Bagh, New Delhi',
      'Chandni Chowk, Old Delhi',
      'Lajpat Nagar, New Delhi',
      'Khan Market, New Delhi',
      'Hauz Khas, New Delhi',
      'Saket, New Delhi',
      'Dwarka, New Delhi',
    ];

    int index = (lat * lng * 1000).abs().toInt() % delhiAreas.length;
    return delhiAreas[index];
  }

  // Get distance between two points (Haversine formula)
  static double calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    double dLat = _degreesToRadians(lat2 - lat1);
    double dLng = _degreesToRadians(lng2 - lng1);

    double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  // Check if user is in a safe area
  bool isInSafeArea(LocationData location) {
    // Define safe areas (tourist areas, police stations, hospitals, etc.)
    List<SafeArea> safeAreas = [
      SafeArea('India Gate Area', 28.6129, 77.2295, 2.0),
      SafeArea('Connaught Place', 28.6315, 77.2167, 1.5),
      SafeArea('Red Fort Area', 28.6562, 77.2410, 1.0),
      SafeArea('Lotus Temple', 28.5535, 77.2588, 1.0),
      SafeArea('Qutub Minar', 28.5245, 77.1855, 1.0),
    ];

    for (SafeArea area in safeAreas) {
      double distance = calculateDistance(
        location.latitude,
        location.longitude,
        area.latitude,
        area.longitude,
      );
      if (distance <= area.radius) {
        return true;
      }
    }
    return false;
  }

  // Get nearby points of interest
  List<PointOfInterest> getNearbyPOIs(LocationData location) {
    // This would typically fetch from a real database
    return [
      PointOfInterest(
        name: 'All India Institute of Medical Sciences',
        type: POIType.hospital,
        latitude: 28.5672,
        longitude: 77.2100,
        distance: calculateDistance(
          location.latitude,
          location.longitude,
          28.5672,
          77.2100,
        ),
        phone: '+91-11-26588500',
      ),
      PointOfInterest(
        name: 'Parliament Street Police Station',
        type: POIType.police,
        latitude: 28.6226,
        longitude: 77.2197,
        distance: calculateDistance(
          location.latitude,
          location.longitude,
          28.6226,
          77.2197,
        ),
        phone: '100',
      ),
      PointOfInterest(
        name: 'Tourist Helpline',
        type: POIType.helpline,
        latitude: location.latitude,
        longitude: location.longitude,
        distance: 0.0,
        phone: '1363',
      ),
    ];
  }

  // Start location tracking
  void startTracking() {
    if (_locationTimer == null || !_locationTimer!.isActive) {
      _startSimulatedLocationUpdates();
    }
  }

  // Stop location tracking
  void stopTracking() {
    _locationTimer?.cancel();
    _locationTimer = null;
  }

  // Dispose resources
  void dispose() {
    _locationTimer?.cancel();
    _locationController.close();
  }
}

// Location data model
class LocationData {
  final double latitude;
  final double longitude;
  final String address;
  final DateTime timestamp;
  final double accuracy;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.timestamp,
    required this.accuracy,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'timestamp': timestamp.toIso8601String(),
      'accuracy': accuracy,
    };
  }
}

// Safe area model
class SafeArea {
  final String name;
  final double latitude;
  final double longitude;
  final double radius; // in kilometers

  SafeArea(this.name, this.latitude, this.longitude, this.radius);
}

// Point of Interest model
class PointOfInterest {
  final String name;
  final POIType type;
  final double latitude;
  final double longitude;
  final double distance;
  final String phone;

  PointOfInterest({
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.distance,
    required this.phone,
  });
}

enum POIType { hospital, police, embassy, helpline, tourist_info, transport }
