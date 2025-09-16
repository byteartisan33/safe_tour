// Emergency-related data models
import 'user_models.dart';

class EmergencyLocationData {
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? accuracy;
  final DateTime timestamp;
  final String? address;

  EmergencyLocationData({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.accuracy,
    required this.timestamp,
    this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'accuracy': accuracy,
      'timestamp': timestamp.toIso8601String(),
      'address': address,
    };
  }

  factory EmergencyLocationData.fromJson(Map<String, dynamic> json) {
    return EmergencyLocationData(
      latitude: json['latitude'],
      longitude: json['longitude'],
      altitude: json['altitude'],
      accuracy: json['accuracy'],
      timestamp: DateTime.parse(json['timestamp']),
      address: json['address'],
    );
  }

  EmergencyLocationData copyWith({
    double? latitude,
    double? longitude,
    double? altitude,
    double? accuracy,
    DateTime? timestamp,
    String? address,
  }) {
    return EmergencyLocationData(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      accuracy: accuracy ?? this.accuracy,
      timestamp: timestamp ?? this.timestamp,
      address: address ?? this.address,
    );
  }
}

class EmergencyAlert {
  final String id;
  final String userId;
  final DateTime timestamp;
  final EmergencyLocationData location;
  final List<EmergencyContact> emergencyContacts;
  final List<PoliceStation> nearbyPoliceStations;
  final EmergencyStatus status;
  final DateTime? resolvedAt;
  final DateTime? lastUpdated;
  final String? notes;
  final EmergencyType type;

  EmergencyAlert({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.location,
    required this.emergencyContacts,
    required this.nearbyPoliceStations,
    this.status = EmergencyStatus.active,
    this.resolvedAt,
    this.lastUpdated,
    this.notes,
    this.type = EmergencyType.panic,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
      'location': location.toJson(),
      'emergencyContacts': emergencyContacts.map((c) => c.toJson()).toList(),
      'nearbyPoliceStations': nearbyPoliceStations
          .map((p) => p.toJson())
          .toList(),
      'status': status.name,
      'resolvedAt': resolvedAt?.toIso8601String(),
      'lastUpdated': lastUpdated?.toIso8601String(),
      'notes': notes,
      'type': type.name,
    };
  }

  factory EmergencyAlert.fromJson(Map<String, dynamic> json) {
    return EmergencyAlert(
      id: json['id'],
      userId: json['userId'],
      timestamp: DateTime.parse(json['timestamp']),
      location: EmergencyLocationData.fromJson(json['location']),
      emergencyContacts: (json['emergencyContacts'] as List)
          .map((c) => EmergencyContact.fromJson(c))
          .toList(),
      nearbyPoliceStations: (json['nearbyPoliceStations'] as List)
          .map((p) => PoliceStation.fromJson(p))
          .toList(),
      status: EmergencyStatus.values.firstWhere(
        (e) => e.name == json['status'],
      ),
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'])
          : null,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : null,
      notes: json['notes'],
      type: EmergencyType.values.firstWhere((e) => e.name == json['type']),
    );
  }

  EmergencyAlert copyWith({
    String? id,
    String? userId,
    DateTime? timestamp,
    EmergencyLocationData? location,
    List<EmergencyContact>? emergencyContacts,
    List<PoliceStation>? nearbyPoliceStations,
    EmergencyStatus? status,
    DateTime? resolvedAt,
    DateTime? lastUpdated,
    String? notes,
    EmergencyType? type,
  }) {
    return EmergencyAlert(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      timestamp: timestamp ?? this.timestamp,
      location: location ?? this.location,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
      nearbyPoliceStations: nearbyPoliceStations ?? this.nearbyPoliceStations,
      status: status ?? this.status,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      notes: notes ?? this.notes,
      type: type ?? this.type,
    );
  }
}

class PoliceStation {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String phoneNumber;
  final double distance; // in kilometers
  final bool isActive;
  final List<String> services;
  final String? website;

  PoliceStation({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phoneNumber,
    this.distance = 0.0,
    this.isActive = true,
    this.services = const [],
    this.website,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phoneNumber': phoneNumber,
      'distance': distance,
      'isActive': isActive,
      'services': services,
      'website': website,
    };
  }

  factory PoliceStation.fromJson(Map<String, dynamic> json) {
    return PoliceStation(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      phoneNumber: json['phoneNumber'],
      distance: json['distance'] ?? 0.0,
      isActive: json['isActive'] ?? true,
      services: List<String>.from(json['services'] ?? []),
      website: json['website'],
    );
  }

  PoliceStation copyWith({
    String? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    String? phoneNumber,
    double? distance,
    bool? isActive,
    List<String>? services,
    String? website,
  }) {
    return PoliceStation(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      distance: distance ?? this.distance,
      isActive: isActive ?? this.isActive,
      services: services ?? this.services,
      website: website ?? this.website,
    );
  }
}

class HospitalService {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String phoneNumber;
  final String emergencyNumber;
  final double distance; // in kilometers
  final bool hasEmergencyServices;
  final List<String> specialties;
  final String? website;

  HospitalService({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phoneNumber,
    required this.emergencyNumber,
    this.distance = 0.0,
    this.hasEmergencyServices = true,
    this.specialties = const [],
    this.website,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phoneNumber': phoneNumber,
      'emergencyNumber': emergencyNumber,
      'distance': distance,
      'hasEmergencyServices': hasEmergencyServices,
      'specialties': specialties,
      'website': website,
    };
  }

  factory HospitalService.fromJson(Map<String, dynamic> json) {
    return HospitalService(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      phoneNumber: json['phoneNumber'],
      emergencyNumber: json['emergencyNumber'],
      distance: json['distance'] ?? 0.0,
      hasEmergencyServices: json['hasEmergencyServices'] ?? true,
      specialties: List<String>.from(json['specialties'] ?? []),
      website: json['website'],
    );
  }

  HospitalService copyWith({
    String? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    String? phoneNumber,
    String? emergencyNumber,
    double? distance,
    bool? hasEmergencyServices,
    List<String>? specialties,
    String? website,
  }) {
    return HospitalService(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emergencyNumber: emergencyNumber ?? this.emergencyNumber,
      distance: distance ?? this.distance,
      hasEmergencyServices: hasEmergencyServices ?? this.hasEmergencyServices,
      specialties: specialties ?? this.specialties,
      website: website ?? this.website,
    );
  }
}

// Enums
enum EmergencyStatus { active, resolved, cancelled, inProgress }

enum EmergencyType { panic, medical, accident, crime, natural, other }

// Extension methods for better display
extension EmergencyStatusExtension on EmergencyStatus {
  String get displayName {
    switch (this) {
      case EmergencyStatus.active:
        return 'Active';
      case EmergencyStatus.resolved:
        return 'Resolved';
      case EmergencyStatus.cancelled:
        return 'Cancelled';
      case EmergencyStatus.inProgress:
        return 'In Progress';
    }
  }

  String get description {
    switch (this) {
      case EmergencyStatus.active:
        return 'Emergency is currently active';
      case EmergencyStatus.resolved:
        return 'Emergency has been resolved';
      case EmergencyStatus.cancelled:
        return 'Emergency was cancelled';
      case EmergencyStatus.inProgress:
        return 'Emergency response in progress';
    }
  }
}

extension EmergencyTypeExtension on EmergencyType {
  String get displayName {
    switch (this) {
      case EmergencyType.panic:
        return 'Panic Alert';
      case EmergencyType.medical:
        return 'Medical Emergency';
      case EmergencyType.accident:
        return 'Accident';
      case EmergencyType.crime:
        return 'Crime/Security';
      case EmergencyType.natural:
        return 'Natural Disaster';
      case EmergencyType.other:
        return 'Other Emergency';
    }
  }
}
