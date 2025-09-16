import 'dart:async';
import 'dart:math' as math;
import '../models/alert_models.dart';
import 'location_service.dart';

class GeoFencingService {
  static GeoFencingService? _instance;
  static GeoFencingService get instance => _instance ??= GeoFencingService._();
  GeoFencingService._();

  // Current monitoring state
  bool _isMonitoring = false;
  StreamController<GeoAlert>? _alertController;
  Timer? _monitoringTimer;
  
  // Current location and zone tracking
  GeoPoint? _currentLocation;
  String _currentZoneId = 'safe_zone_delhi';
  ZoneType _currentZoneType = ZoneType.safe;
  
  // Alert storage
  final List<GeoAlert> _activeAlerts = [];
  final List<GeoAlert> _alertHistory = [];
  final List<GeoZone> _zones = [];

  // Initialize service
  static void initialize() {
    instance._initializeZones();
    instance._loadAlertHistory();
  }

  void _initializeZones() {
    // Define geo-fencing zones for Delhi and surrounding areas
    _zones.addAll([
      // Safe zones
      GeoZone(
        id: 'safe_zone_delhi',
        name: 'Central Delhi Safe Zone',
        description: 'Tourist-friendly areas with high security',
        type: ZoneType.safe,
        centerLatitude: 28.6139,
        centerLongitude: 77.2090,
        radius: 5000, // 5km radius
        createdAt: DateTime.now().subtract(Duration(days: 30)),
      ),
      
      GeoZone(
        id: 'safe_zone_india_gate',
        name: 'India Gate Area',
        description: 'Popular tourist destination with security',
        type: ZoneType.safe,
        centerLatitude: 28.6129,
        centerLongitude: 77.2295,
        radius: 2000,
        createdAt: DateTime.now().subtract(Duration(days: 30)),
      ),

      // Caution zones
      GeoZone(
        id: 'caution_zone_old_delhi',
        name: 'Old Delhi Markets',
        description: 'Crowded markets - exercise caution',
        type: ZoneType.caution,
        centerLatitude: 28.6562,
        centerLongitude: 77.2410,
        radius: 3000,
        createdAt: DateTime.now().subtract(Duration(days: 25)),
      ),

      // High-risk zones
      GeoZone(
        id: 'high_risk_outskirts',
        name: 'Delhi Outskirts',
        description: 'Less secure areas - avoid after dark',
        type: ZoneType.highRisk,
        centerLatitude: 28.7041,
        centerLongitude: 77.1025,
        radius: 8000,
        createdAt: DateTime.now().subtract(Duration(days: 20)),
      ),

      // Restricted zones
      GeoZone(
        id: 'restricted_military',
        name: 'Military Installation',
        description: 'Restricted military area - entry prohibited',
        type: ZoneType.restricted,
        centerLatitude: 28.5833,
        centerLongitude: 77.2167,
        radius: 1000,
        createdAt: DateTime.now().subtract(Duration(days: 15)),
      ),
    ]);
  }

  void _loadAlertHistory() {
    // Load sample alert history
    _alertHistory.addAll([
      GeoAlert(
        id: 'alert_001',
        title: 'Entered High Risk Zone',
        description: 'You have entered a high-risk area. Please exercise extreme caution.',
        type: AlertType.zoneEntry,
        severity: AlertSeverity.high,
        timestamp: DateTime.now().subtract(Duration(hours: 2)),
        location: 'Delhi Outskirts',
        latitude: 28.7041,
        longitude: 77.1025,
        zoneId: 'high_risk_outskirts',
        isActive: false,
      ),
      
      GeoAlert(
        id: 'alert_002',
        title: 'Safety Alert',
        description: 'Increased police patrol in your area due to recent incidents.',
        type: AlertType.safety,
        severity: AlertSeverity.medium,
        timestamp: DateTime.now().subtract(Duration(hours: 4)),
        location: 'Connaught Place',
        latitude: 28.6315,
        longitude: 77.2167,
        isActive: false,
      ),
    ]);
  }

  // Start real-time monitoring
  static void startMonitoring(Function(GeoAlert) onAlert) {
    final service = instance;
    if (service._isMonitoring) return;

    service._isMonitoring = true;
    service._alertController = StreamController<GeoAlert>.broadcast();
    service._alertController!.stream.listen(onAlert);

    // Start location monitoring
    LocationService.instance.initialize();
    LocationService.instance.locationStream.listen((location) {
      service._updateLocation(GeoPoint(
        latitude: location.latitude,
        longitude: location.longitude,
        timestamp: location.timestamp,
      ));
    });

    // Start periodic zone checking
    service._monitoringTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      service._checkZoneChanges();
    });
  }

  void _updateLocation(GeoPoint location) {
    _currentLocation = location;
    _checkZoneChanges();
  }

  void _checkZoneChanges() {
    if (_currentLocation == null) return;

    // Find current zone
    GeoZone? currentZone;
    for (final zone in _zones) {
      if (zone.containsPoint(_currentLocation!.latitude, _currentLocation!.longitude)) {
        currentZone = zone;
        break;
      }
    }

    // Check for zone changes
    if (currentZone != null && currentZone.id != _currentZoneId) {
      _handleZoneChange(currentZone);
    }

    // Generate random alerts for demo
    if (math.Random().nextInt(100) < 5) { // 5% chance every check
      _generateRandomAlert();
    }
  }

  void _handleZoneChange(GeoZone newZone) {
    final previousZoneType = _currentZoneType;
    _currentZoneId = newZone.id;
    _currentZoneType = newZone.type;

    // Create zone entry alert
    final alert = GeoAlert(
      id: 'alert_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Entered ${newZone.type.displayName}',
      description: newZone.description,
      type: AlertType.zoneEntry,
      severity: _getZoneSeverity(newZone.type),
      timestamp: DateTime.now(),
      location: newZone.name,
      latitude: _currentLocation!.latitude,
      longitude: _currentLocation!.longitude,
      zoneId: newZone.id,
    );

    _addAlert(alert);
  }

  void _generateRandomAlert() {
    final alertTypes = [
      {
        'title': 'Traffic Alert',
        'description': 'Heavy traffic reported in your area',
        'type': AlertType.safety,
        'severity': AlertSeverity.low,
      },
      {
        'title': 'Weather Warning',
        'description': 'Sudden weather change - rain expected',
        'type': AlertType.safety,
        'severity': AlertSeverity.medium,
      },
      {
        'title': 'Security Update',
        'description': 'Increased security measures in tourist areas',
        'type': AlertType.safety,
        'severity': AlertSeverity.low,
      },
    ];

    final randomAlert = alertTypes[math.Random().nextInt(alertTypes.length)];
    
    final alert = GeoAlert(
      id: 'alert_${DateTime.now().millisecondsSinceEpoch}',
      title: randomAlert['title'] as String,
      description: randomAlert['description'] as String,
      type: randomAlert['type'] as AlertType,
      severity: randomAlert['severity'] as AlertSeverity,
      timestamp: DateTime.now(),
      location: getCurrentZone(),
      latitude: _currentLocation?.latitude ?? 28.6139,
      longitude: _currentLocation?.longitude ?? 77.2090,
    );

    _addAlert(alert);
  }

  void _addAlert(GeoAlert alert) {
    _activeAlerts.insert(0, alert);
    _alertHistory.insert(0, alert);
    _alertController?.add(alert);
  }

  AlertSeverity _getZoneSeverity(ZoneType zoneType) {
    switch (zoneType) {
      case ZoneType.safe:
        return AlertSeverity.low;
      case ZoneType.caution:
        return AlertSeverity.medium;
      case ZoneType.highRisk:
        return AlertSeverity.high;
      case ZoneType.restricted:
        return AlertSeverity.critical;
    }
  }

  // Public API methods
  static List<GeoAlert> getActiveAlerts() {
    return List.from(instance._activeAlerts);
  }

  static List<GeoAlert> getAlertHistory() {
    return List.from(instance._alertHistory);
  }

  static String getCurrentZone() {
    final zone = instance._zones.firstWhere(
      (z) => z.id == instance._currentZoneId,
      orElse: () => instance._zones.first,
    );
    return zone.name;
  }

  static ZoneType getCurrentZoneType() {
    return instance._currentZoneType;
  }

  static GeoPoint getCurrentLocation() {
    return instance._currentLocation ?? GeoPoint(
      latitude: 28.6139,
      longitude: 77.2090,
      timestamp: DateTime.now(),
    );
  }

  static List<GeoZone> getAllZones() {
    return List.from(instance._zones);
  }

  static void dismissAlert(String alertId) {
    instance._activeAlerts.removeWhere((alert) => alert.id == alertId);
  }

  static void stopMonitoring() {
    final service = instance;
    service._isMonitoring = false;
    service._monitoringTimer?.cancel();
    service._alertController?.close();
    service._alertController = null;
  }

  // Zone management methods
  static void addZone(GeoZone zone) {
    instance._zones.add(zone);
  }

  static void removeZone(String zoneId) {
    instance._zones.removeWhere((zone) => zone.id == zoneId);
  }

  static GeoZone? getZone(String zoneId) {
    try {
      return instance._zones.firstWhere((zone) => zone.id == zoneId);
    } catch (e) {
      return null;
    }
  }

  // Alert statistics
  static Map<String, int> getAlertStatistics() {
    final history = instance._alertHistory;
    return {
      'total': history.length,
      'today': history.where((a) => 
          a.timestamp.isAfter(DateTime.now().subtract(Duration(days: 1)))).length,
      'thisWeek': history.where((a) => 
          a.timestamp.isAfter(DateTime.now().subtract(Duration(days: 7)))).length,
      'highSeverity': history.where((a) => 
          a.severity == AlertSeverity.high || a.severity == AlertSeverity.critical).length,
    };
  }
}
