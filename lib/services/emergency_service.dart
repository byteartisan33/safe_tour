import 'dart:async';
import 'dart:math' as math;
import '../models/user_models.dart';
import '../models/emergency_models.dart';
import 'location_service.dart' as location_service;

class EmergencyService {
  static EmergencyService? _instance;
  static EmergencyService get instance => _instance ??= EmergencyService._();
  EmergencyService._();

  // Active emergency alerts
  final Map<String, EmergencyAlert> _activeAlerts = {};
  final List<EmergencyAlert> _alertHistory = [];

  // Emergency contacts and services
  final List<PoliceStation> _policeStations = [];
  final List<HospitalService> _hospitals = [];
  final List<EmergencyService> _emergencyServices = [];

  // Initialize service with predefined emergency services
  static void initialize() {
    instance._initializeEmergencyServices();
  }

  void _initializeEmergencyServices() {
    // Initialize police stations in Delhi area
    _policeStations.addAll([
      PoliceStation(
        id: 'ps_001',
        name: 'Connaught Place Police Station',
        address: 'Connaught Place, New Delhi',
        latitude: 28.6315,
        longitude: 77.2167,
        phoneNumber: '+91-11-23341234',
        distance: 0.0, // Will be calculated dynamically
        isActive: true,
      ),
      PoliceStation(
        id: 'ps_002',
        name: 'India Gate Police Station',
        address: 'India Gate, New Delhi',
        latitude: 28.6129,
        longitude: 77.2295,
        phoneNumber: '+91-11-23385678',
        distance: 0.0,
        isActive: true,
      ),
      PoliceStation(
        id: 'ps_003',
        name: 'Red Fort Police Station',
        address: 'Red Fort, Old Delhi',
        latitude: 28.6562,
        longitude: 77.2410,
        phoneNumber: '+91-11-23279012',
        distance: 0.0,
        isActive: true,
      ),
      PoliceStation(
        id: 'ps_004',
        name: 'Karol Bagh Police Station',
        address: 'Karol Bagh, New Delhi',
        latitude: 28.6519,
        longitude: 77.1909,
        phoneNumber: '+91-11-25753456',
        distance: 0.0,
        isActive: true,
      ),
    ]);

    // Initialize hospitals
    _hospitals.addAll([
      HospitalService(
        id: 'hosp_001',
        name: 'All India Institute of Medical Sciences (AIIMS)',
        address: 'Ansari Nagar, New Delhi',
        latitude: 28.5672,
        longitude: 77.2100,
        phoneNumber: '+91-11-26588500',
        emergencyNumber: '+91-11-26588700',
        distance: 0.0,
        hasEmergencyServices: true,
        specialties: ['Emergency Medicine', 'Trauma Care', 'Critical Care'],
      ),
      HospitalService(
        id: 'hosp_002',
        name: 'Safdarjung Hospital',
        address: 'Safdarjung, New Delhi',
        latitude: 28.5706,
        longitude: 77.2094,
        phoneNumber: '+91-11-26165060',
        emergencyNumber: '+91-11-26165100',
        distance: 0.0,
        hasEmergencyServices: true,
        specialties: ['Emergency Medicine', 'Trauma Care'],
      ),
    ]);
  }

  // Find nearby police stations
  static Future<List<PoliceStation>> findNearbyPoliceStations(
    double latitude,
    double longitude, {
    double radiusKm = 10.0,
    int maxResults = 5,
  }) async {
    final service = instance;
    final nearbyStations = <PoliceStation>[];

    for (final station in service._policeStations) {
      if (!station.isActive) continue;

      final distance = _calculateDistance(
        latitude,
        longitude,
        station.latitude,
        station.longitude,
      );

      if (distance <= radiusKm) {
        nearbyStations.add(station.copyWith(distance: distance));
      }
    }

    // Sort by distance
    nearbyStations.sort((a, b) => a.distance.compareTo(b.distance));

    return nearbyStations.take(maxResults).toList();
  }

  // Find nearby hospitals
  static Future<List<HospitalService>> findNearbyHospitals(
    double latitude,
    double longitude, {
    double radiusKm = 15.0,
    int maxResults = 3,
  }) async {
    final service = instance;
    final nearbyHospitals = <HospitalService>[];

    for (final hospital in service._hospitals) {
      final distance = _calculateDistance(
        latitude,
        longitude,
        hospital.latitude,
        hospital.longitude,
      );

      if (distance <= radiusKm) {
        nearbyHospitals.add(hospital.copyWith(distance: distance));
      }
    }

    // Sort by distance
    nearbyHospitals.sort((a, b) => a.distance.compareTo(b.distance));

    return nearbyHospitals.take(maxResults).toList();
  }

  // Send emergency alerts to contacts and services
  static Future<void> sendEmergencyAlerts(EmergencyAlert alert) async {
    final service = instance;

    // Store the alert
    service._activeAlerts[alert.id] = alert;
    service._alertHistory.insert(0, alert);

    // Send SMS/notifications to emergency contacts
    for (final contact in alert.emergencyContacts) {
      await _sendEmergencyNotification(contact, alert);
    }

    // Notify nearby police stations
    await notifyPoliceStations(alert);

    // Notify nearby hospitals
    final nearbyHospitals = await findNearbyHospitals(
      alert.location.latitude,
      alert.location.longitude,
    );

    for (final hospital in nearbyHospitals) {
      await _notifyHospital(hospital, alert);
    }

    print('Emergency alert sent successfully: ${alert.id}');
  }

  // Notify police stations
  static Future<void> notifyPoliceStations(EmergencyAlert alert) async {
    for (final station in alert.nearbyPoliceStations) {
      await _notifyPoliceStation(station, alert);
    }
  }

  // Update emergency location
  static Future<void> updateEmergencyLocation(
    String alertId,
    location_service.LocationData newLocation,
  ) async {
    final service = instance;
    final alert = service._activeAlerts[alertId];

    if (alert != null) {
      final emergencyLocation = EmergencyLocationData(
        latitude: newLocation.latitude,
        longitude: newLocation.longitude,
        timestamp: newLocation.timestamp,
        address: newLocation.address,
        accuracy: newLocation.accuracy,
      );

      final updatedAlert = alert.copyWith(
        location: emergencyLocation,
        lastUpdated: DateTime.now(),
      );

      service._activeAlerts[alertId] = updatedAlert;

      // Send location update to all notified parties
      for (final contact in alert.emergencyContacts) {
        await _sendLocationUpdate(contact, updatedAlert);
      }

      print('Location updated for emergency: $alertId');
    }
  }

  // Deactivate emergency alert
  static Future<void> deactivateEmergencyAlert(String alertId) async {
    final service = instance;
    final alert = service._activeAlerts[alertId];

    if (alert != null) {
      final deactivatedAlert = alert.copyWith(
        status: EmergencyStatus.resolved,
        resolvedAt: DateTime.now(),
      );

      service._activeAlerts.remove(alertId);

      // Update in history
      final historyIndex = service._alertHistory.indexWhere(
        (a) => a.id == alertId,
      );
      if (historyIndex != -1) {
        service._alertHistory[historyIndex] = deactivatedAlert;
      }

      // Notify all parties that emergency is resolved
      for (final contact in alert.emergencyContacts) {
        await _sendEmergencyResolved(contact, deactivatedAlert);
      }

      print('Emergency alert deactivated: $alertId');
    }
  }

  // Get active alerts
  static List<EmergencyAlert> getActiveAlerts() {
    return instance._activeAlerts.values.toList();
  }

  // Get alert history
  static List<EmergencyAlert> getAlertHistory() {
    return List.from(instance._alertHistory);
  }

  // Private helper methods
  static Future<void> _sendEmergencyNotification(
    EmergencyContact contact,
    EmergencyAlert alert,
  ) async {
    // Simulate sending SMS/notification
    await Future.delayed(Duration(milliseconds: 500));

    final message =
        '''
🚨 EMERGENCY ALERT 🚨

${contact.name}, this is an automated emergency alert.

Location: ${alert.location.latitude.toStringAsFixed(6)}, ${alert.location.longitude.toStringAsFixed(6)}
Time: ${alert.timestamp.toString()}
Alert ID: ${alert.id}

Please respond immediately or contact local emergency services.

This message was sent by Smart Tourist Safety App.
''';

    print(
      'Emergency SMS sent to ${contact.name} (${contact.phoneNumber}): $message',
    );
  }

  static Future<void> _sendLocationUpdate(
    EmergencyContact contact,
    EmergencyAlert alert,
  ) async {
    await Future.delayed(Duration(milliseconds: 200));

    final message =
        '''
📍 LOCATION UPDATE

New location: ${alert.location.latitude.toStringAsFixed(6)}, ${alert.location.longitude.toStringAsFixed(6)}
Updated: ${alert.lastUpdated?.toString() ?? 'Now'}
Alert ID: ${alert.id}

Smart Tourist Safety App
''';

    print('Location update sent to ${contact.name}: $message');
  }

  static Future<void> _sendEmergencyResolved(
    EmergencyContact contact,
    EmergencyAlert alert,
  ) async {
    await Future.delayed(Duration(milliseconds: 200));

    final message =
        '''
✅ EMERGENCY RESOLVED

The emergency alert has been resolved.
Resolved at: ${alert.resolvedAt?.toString() ?? 'Now'}
Alert ID: ${alert.id}

Thank you for your concern.
Smart Tourist Safety App
''';

    print('Emergency resolved notification sent to ${contact.name}: $message');
  }

  static Future<void> _notifyPoliceStation(
    PoliceStation station,
    EmergencyAlert alert,
  ) async {
    await Future.delayed(Duration(milliseconds: 300));

    print('Police station notified: ${station.name}');
    print(
      'Emergency location: ${alert.location.latitude}, ${alert.location.longitude}',
    );
    print('Distance: ${station.distance.toStringAsFixed(2)}km');
  }

  static Future<void> _notifyHospital(
    HospitalService hospital,
    EmergencyAlert alert,
  ) async {
    await Future.delayed(Duration(milliseconds: 300));

    print('Hospital notified: ${hospital.name}');
    print(
      'Emergency location: ${alert.location.latitude}, ${alert.location.longitude}',
    );
    print('Distance: ${hospital.distance.toStringAsFixed(2)}km');
  }

  // Calculate distance between two points using Haversine formula
  static double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
}
