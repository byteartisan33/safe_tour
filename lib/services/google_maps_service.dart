// Google Maps Service for Smart Tourist Safety App
// Integrates with Google Maps Platform API for real-world mapping functionality

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import '../config/firebase_config.dart';
import '../models/user_models.dart';

class GoogleMapsService {
  static final GoogleMapsService _instance = GoogleMapsService._internal();
  factory GoogleMapsService() => _instance;
  GoogleMapsService._internal();

  static GoogleMapsService get instance => _instance;

  // Google Maps API endpoints
  static const String _geocodingBaseUrl = 'https://maps.googleapis.com/maps/api/geocode/json';
  static const String _placesBaseUrl = 'https://maps.googleapis.com/maps/api/place';
  static const String _directionsBaseUrl = 'https://maps.googleapis.com/maps/api/directions/json';
  static const String _distanceMatrixBaseUrl = 'https://maps.googleapis.com/maps/api/distancematrix/json';

  /// Get address from coordinates (Reverse Geocoding)
  Future<String?> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      final url = Uri.parse('$_geocodingBaseUrl?latlng=$latitude,$longitude&key=${FirebaseConfig.googleMapsApiKey}');
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          return data['results'][0]['formatted_address'];
        }
      }
      
      return null;
    } catch (e) {
      print('Error getting address from coordinates: $e');
      return null;
    }
  }

  /// Get coordinates from address (Forward Geocoding)
  Future<LocationData?> getCoordinatesFromAddress(String address) async {
    try {
      final url = Uri.parse('$_geocodingBaseUrl?address=${Uri.encodeComponent(address)}&key=${FirebaseConfig.googleMapsApiKey}');
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          return LocationData.fromMap({
            'latitude': location['lat'],
            'longitude': location['lng'],
          });
        }
      }
      
      return null;
    } catch (e) {
      print('Error getting coordinates from address: $e');
      return null;
    }
  }

  /// Find nearby places (hospitals, police stations, tourist attractions)
  Future<List<PlaceResult>> findNearbyPlaces({
    required double latitude,
    required double longitude,
    required String type,
    int radius = 5000,
    String? keyword,
  }) async {
    try {
      String url = '$_placesBaseUrl/nearbysearch/json?location=$latitude,$longitude&radius=$radius&type=$type&key=${FirebaseConfig.googleMapsApiKey}';
      
      if (keyword != null) {
        url += '&keyword=${Uri.encodeComponent(keyword)}';
      }
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK') {
          final List<PlaceResult> places = [];
          
          for (final place in data['results']) {
            places.add(PlaceResult.fromJson(place));
          }
          
          return places;
        }
      }
      
      return [];
    } catch (e) {
      print('Error finding nearby places: $e');
      return [];
    }
  }

  /// Get directions between two points
  Future<DirectionsResult?> getDirections({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    String travelMode = 'driving',
  }) async {
    try {
      final url = Uri.parse(
        '$_directionsBaseUrl?origin=$originLat,$originLng&destination=$destLat,$destLng&mode=$travelMode&key=${FirebaseConfig.googleMapsApiKey}'
      );
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          return DirectionsResult.fromJson(data['routes'][0]);
        }
      }
      
      return null;
    } catch (e) {
      print('Error getting directions: $e');
      return null;
    }
  }

  /// Calculate distance and duration between multiple points
  Future<DistanceMatrixResult?> getDistanceMatrix({
    required List<String> origins,
    required List<String> destinations,
    String travelMode = 'driving',
  }) async {
    try {
      final originsStr = origins.join('|');
      final destinationsStr = destinations.join('|');
      
      final url = Uri.parse(
        '$_distanceMatrixBaseUrl?origins=${Uri.encodeComponent(originsStr)}&destinations=${Uri.encodeComponent(destinationsStr)}&mode=$travelMode&key=${FirebaseConfig.googleMapsApiKey}'
      );
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK') {
          return DistanceMatrixResult.fromJson(data);
        }
      }
      
      return null;
    } catch (e) {
      print('Error getting distance matrix: $e');
      return null;
    }
  }

  /// Find emergency services nearby
  Future<List<PlaceResult>> findEmergencyServices({
    required double latitude,
    required double longitude,
    int radius = 10000,
  }) async {
    final List<PlaceResult> emergencyServices = [];
    
    // Find hospitals
    final hospitals = await findNearbyPlaces(
      latitude: latitude,
      longitude: longitude,
      type: 'hospital',
      radius: radius,
    );
    emergencyServices.addAll(hospitals);
    
    // Find police stations
    final policeStations = await findNearbyPlaces(
      latitude: latitude,
      longitude: longitude,
      type: 'police',
      radius: radius,
    );
    emergencyServices.addAll(policeStations);
    
    // Find fire stations
    final fireStations = await findNearbyPlaces(
      latitude: latitude,
      longitude: longitude,
      type: 'fire_station',
      radius: radius,
    );
    emergencyServices.addAll(fireStations);
    
    return emergencyServices;
  }

  /// Find tourist attractions nearby
  Future<List<PlaceResult>> findTouristAttractions({
    required double latitude,
    required double longitude,
    int radius = 5000,
  }) async {
    final List<PlaceResult> attractions = [];
    
    // Find tourist attractions
    final touristAttractions = await findNearbyPlaces(
      latitude: latitude,
      longitude: longitude,
      type: 'tourist_attraction',
      radius: radius,
    );
    attractions.addAll(touristAttractions);
    
    // Find museums
    final museums = await findNearbyPlaces(
      latitude: latitude,
      longitude: longitude,
      type: 'museum',
      radius: radius,
    );
    attractions.addAll(museums);
    
    // Find parks
    final parks = await findNearbyPlaces(
      latitude: latitude,
      longitude: longitude,
      type: 'park',
      radius: radius,
    );
    attractions.addAll(parks);
    
    return attractions;
  }

  /// Check if location is in a safe area
  Future<SafetyAssessment> assessLocationSafety({
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Find nearby emergency services
      final emergencyServices = await findEmergencyServices(
        latitude: latitude,
        longitude: longitude,
      );
      
      // Calculate safety score based on proximity to emergency services
      int safetyScore = 50; // Base score
      
      // Increase score for nearby hospitals
      final nearbyHospitals = emergencyServices.where((place) => 
        place.types.contains('hospital') && place.distance < 5000).length;
      safetyScore += nearbyHospitals * 10;
      
      // Increase score for nearby police stations
      final nearbyPolice = emergencyServices.where((place) => 
        place.types.contains('police') && place.distance < 3000).length;
      safetyScore += nearbyPolice * 15;
      
      // Cap the score at 100
      safetyScore = safetyScore > 100 ? 100 : safetyScore;
      
      return SafetyAssessment(
        safetyScore: safetyScore,
        nearbyEmergencyServices: emergencyServices,
        recommendations: _generateSafetyRecommendations(safetyScore, emergencyServices),
      );
    } catch (e) {
      print('Error assessing location safety: $e');
      return SafetyAssessment(
        safetyScore: 50,
        nearbyEmergencyServices: [],
        recommendations: ['Unable to assess location safety. Please stay alert.'],
      );
    }
  }

  /// Generate safety recommendations based on assessment
  List<String> _generateSafetyRecommendations(int safetyScore, List<PlaceResult> emergencyServices) {
    final List<String> recommendations = [];
    
    if (safetyScore < 30) {
      recommendations.add('⚠️ Low safety area detected. Consider moving to a safer location.');
      recommendations.add('📱 Keep emergency contacts readily available.');
      recommendations.add('👥 Stay in groups and avoid isolated areas.');
    } else if (safetyScore < 60) {
      recommendations.add('⚡ Moderate safety area. Stay alert and aware of surroundings.');
      recommendations.add('🚨 Know the location of nearest emergency services.');
    } else {
      recommendations.add('✅ Good safety area with nearby emergency services.');
      recommendations.add('😊 Enjoy your visit while staying aware of surroundings.');
    }
    
    // Add specific recommendations based on nearby services
    final nearbyHospitals = emergencyServices.where((place) => place.types.contains('hospital')).toList();
    if (nearbyHospitals.isNotEmpty) {
      recommendations.add('🏥 Nearest hospital: ${nearbyHospitals.first.name}');
    }
    
    final nearbyPolice = emergencyServices.where((place) => place.types.contains('police')).toList();
    if (nearbyPolice.isNotEmpty) {
      recommendations.add('👮 Nearest police station: ${nearbyPolice.first.name}');
    }
    
    return recommendations;
  }
}

/// Place result model for Google Places API
class PlaceResult {
  final String placeId;
  final String name;
  final String? address;
  final double latitude;
  final double longitude;
  final double rating;
  final List<String> types;
  final bool isOpen;
  final double distance;

  PlaceResult({
    required this.placeId,
    required this.name,
    this.address,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.types,
    required this.isOpen,
    required this.distance,
  });

  factory PlaceResult.fromJson(Map<String, dynamic> json) {
    return PlaceResult(
      placeId: json['place_id'] ?? '',
      name: json['name'] ?? '',
      address: json['vicinity'],
      latitude: json['geometry']['location']['lat']?.toDouble() ?? 0.0,
      longitude: json['geometry']['location']['lng']?.toDouble() ?? 0.0,
      rating: json['rating']?.toDouble() ?? 0.0,
      types: List<String>.from(json['types'] ?? []),
      isOpen: json['opening_hours']?['open_now'] ?? true,
      distance: 0.0, // Will be calculated separately
    );
  }
}

/// Directions result model
class DirectionsResult {
  final String summary;
  final int distanceMeters;
  final int durationSeconds;
  final List<DirectionStep> steps;

  DirectionsResult({
    required this.summary,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.steps,
  });

  factory DirectionsResult.fromJson(Map<String, dynamic> json) {
    final leg = json['legs'][0];
    return DirectionsResult(
      summary: json['summary'] ?? '',
      distanceMeters: leg['distance']['value'] ?? 0,
      durationSeconds: leg['duration']['value'] ?? 0,
      steps: (leg['steps'] as List).map((step) => DirectionStep.fromJson(step)).toList(),
    );
  }
}

/// Direction step model
class DirectionStep {
  final String instructions;
  final int distanceMeters;
  final int durationSeconds;

  DirectionStep({
    required this.instructions,
    required this.distanceMeters,
    required this.durationSeconds,
  });

  factory DirectionStep.fromJson(Map<String, dynamic> json) {
    return DirectionStep(
      instructions: json['html_instructions'] ?? '',
      distanceMeters: json['distance']['value'] ?? 0,
      durationSeconds: json['duration']['value'] ?? 0,
    );
  }
}

/// Distance matrix result model
class DistanceMatrixResult {
  final List<List<DistanceElement>> elements;

  DistanceMatrixResult({required this.elements});

  factory DistanceMatrixResult.fromJson(Map<String, dynamic> json) {
    final rows = json['rows'] as List;
    final elements = rows.map((row) {
      final rowElements = row['elements'] as List;
      return rowElements.map((element) => DistanceElement.fromJson(element)).toList();
    }).toList();

    return DistanceMatrixResult(elements: elements);
  }
}

/// Distance element model
class DistanceElement {
  final int distanceMeters;
  final int durationSeconds;
  final String status;

  DistanceElement({
    required this.distanceMeters,
    required this.durationSeconds,
    required this.status,
  });

  factory DistanceElement.fromJson(Map<String, dynamic> json) {
    return DistanceElement(
      distanceMeters: json['distance']?['value'] ?? 0,
      durationSeconds: json['duration']?['value'] ?? 0,
      status: json['status'] ?? 'UNKNOWN',
    );
  }
}

/// Safety assessment model
class SafetyAssessment {
  final int safetyScore;
  final List<PlaceResult> nearbyEmergencyServices;
  final List<String> recommendations;

  SafetyAssessment({
    required this.safetyScore,
    required this.nearbyEmergencyServices,
    required this.recommendations,
  });
}
