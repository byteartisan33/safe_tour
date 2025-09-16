// Data models for geo-fencing alerts and zones
import 'dart:math' as math;

class GeoAlert {
  final String id;
  final String title;
  final String description;
  final AlertType type;
  final AlertSeverity severity;
  final DateTime timestamp;
  final String location;
  final double latitude;
  final double longitude;
  final String? zoneId;
  final bool isActive;
  final bool isDismissed;

  GeoAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.severity,
    required this.timestamp,
    required this.location,
    required this.latitude,
    required this.longitude,
    this.zoneId,
    this.isActive = true,
    this.isDismissed = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'severity': severity.name,
      'timestamp': timestamp.toIso8601String(),
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'zoneId': zoneId,
      'isActive': isActive,
      'isDismissed': isDismissed,
    };
  }

  factory GeoAlert.fromJson(Map<String, dynamic> json) {
    return GeoAlert(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: AlertType.values.firstWhere((e) => e.name == json['type']),
      severity: AlertSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
      ),
      timestamp: DateTime.parse(json['timestamp']),
      location: json['location'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      zoneId: json['zoneId'],
      isActive: json['isActive'] ?? true,
      isDismissed: json['isDismissed'] ?? false,
    );
  }

  GeoAlert copyWith({
    String? id,
    String? title,
    String? description,
    AlertType? type,
    AlertSeverity? severity,
    DateTime? timestamp,
    String? location,
    double? latitude,
    double? longitude,
    String? zoneId,
    bool? isActive,
    bool? isDismissed,
  }) {
    return GeoAlert(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      timestamp: timestamp ?? this.timestamp,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      zoneId: zoneId ?? this.zoneId,
      isActive: isActive ?? this.isActive,
      isDismissed: isDismissed ?? this.isDismissed,
    );
  }
}

class GeoZone {
  final String id;
  final String name;
  final String description;
  final ZoneType type;
  final double centerLatitude;
  final double centerLongitude;
  final double radius; // in meters
  final List<GeoPoint> boundary; // for polygon zones
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  GeoZone({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.centerLatitude,
    required this.centerLongitude,
    required this.radius,
    this.boundary = const [],
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'centerLatitude': centerLatitude,
      'centerLongitude': centerLongitude,
      'radius': radius,
      'boundary': boundary.map((p) => p.toJson()).toList(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory GeoZone.fromJson(Map<String, dynamic> json) {
    return GeoZone(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: ZoneType.values.firstWhere((e) => e.name == json['type']),
      centerLatitude: json['centerLatitude'],
      centerLongitude: json['centerLongitude'],
      radius: json['radius'],
      boundary:
          (json['boundary'] as List?)
              ?.map((p) => GeoPoint.fromJson(p))
              .toList() ??
          [],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      metadata: json['metadata'],
    );
  }

  bool containsPoint(double latitude, double longitude) {
    if (boundary.isNotEmpty) {
      // Use polygon boundary for complex shapes
      return _isPointInPolygon(latitude, longitude, boundary);
    } else {
      // Use circular boundary
      double distance = _calculateDistance(
        latitude,
        longitude,
        centerLatitude,
        centerLongitude,
      );
      return distance <= radius;
    }
  }

  bool _isPointInPolygon(double lat, double lng, List<GeoPoint> polygon) {
    int intersectCount = 0;
    for (int j = 0, i = 1; i < polygon.length; j = i++) {
      if (((polygon[i].latitude <= lat && lat < polygon[j].latitude) ||
              (polygon[j].latitude <= lat && lat < polygon[i].latitude)) &&
          (lng <
              (polygon[j].longitude - polygon[i].longitude) *
                      (lat - polygon[i].latitude) /
                      (polygon[j].latitude - polygon[i].latitude) +
                  polygon[i].longitude)) {
        intersectCount++;
      }
    }
    return (intersectCount % 2) == 1;
  }

  double _calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const double earthRadius = 6371000; // Earth's radius in meters
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

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
}

class GeoPoint {
  final double latitude;
  final double longitude;
  final double? altitude;
  final DateTime? timestamp;

  GeoPoint({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'timestamp': timestamp?.toIso8601String(),
    };
  }

  factory GeoPoint.fromJson(Map<String, dynamic> json) {
    return GeoPoint(
      latitude: json['latitude'],
      longitude: json['longitude'],
      altitude: json['altitude'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : null,
    );
  }

  double distanceTo(GeoPoint other) {
    const double earthRadius = 6371000; // Earth's radius in meters
    double dLat = _degreesToRadians(other.latitude - latitude);
    double dLng = _degreesToRadians(other.longitude - longitude);

    double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(latitude)) *
            math.cos(_degreesToRadians(other.latitude)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
}

class AlertHistory {
  final String userId;
  final List<GeoAlert> alerts;
  final DateTime lastUpdated;
  final int totalAlerts;
  final Map<AlertType, int> alertCounts;

  AlertHistory({
    required this.userId,
    required this.alerts,
    required this.lastUpdated,
    required this.totalAlerts,
    required this.alertCounts,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'alerts': alerts.map((a) => a.toJson()).toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'totalAlerts': totalAlerts,
      'alertCounts': alertCounts.map((k, v) => MapEntry(k.name, v)),
    };
  }

  factory AlertHistory.fromJson(Map<String, dynamic> json) {
    return AlertHistory(
      userId: json['userId'],
      alerts: (json['alerts'] as List)
          .map((a) => GeoAlert.fromJson(a))
          .toList(),
      lastUpdated: DateTime.parse(json['lastUpdated']),
      totalAlerts: json['totalAlerts'],
      alertCounts: (json['alertCounts'] as Map<String, dynamic>).map(
        (k, v) =>
            MapEntry(AlertType.values.firstWhere((e) => e.name == k), v as int),
      ),
    );
  }
}

// Enums
enum AlertType { zoneEntry, zoneExit, highRisk, restricted, safety }

enum AlertSeverity { low, medium, high, critical }

enum ZoneType { safe, caution, highRisk, restricted }

// Extension methods for better display
extension AlertTypeExtension on AlertType {
  String get displayName {
    switch (this) {
      case AlertType.zoneEntry:
        return 'Zone Entry';
      case AlertType.zoneExit:
        return 'Zone Exit';
      case AlertType.highRisk:
        return 'High Risk';
      case AlertType.restricted:
        return 'Restricted Area';
      case AlertType.safety:
        return 'Safety Alert';
    }
  }
}

extension AlertSeverityExtension on AlertSeverity {
  String get displayName {
    switch (this) {
      case AlertSeverity.low:
        return 'Low';
      case AlertSeverity.medium:
        return 'Medium';
      case AlertSeverity.high:
        return 'High';
      case AlertSeverity.critical:
        return 'Critical';
    }
  }
}

extension ZoneTypeExtension on ZoneType {
  String get displayName {
    switch (this) {
      case ZoneType.safe:
        return 'Safe Zone';
      case ZoneType.caution:
        return 'Caution Zone';
      case ZoneType.highRisk:
        return 'High Risk Zone';
      case ZoneType.restricted:
        return 'Restricted Zone';
    }
  }
}
