// Google Maps Widget for Smart Tourist Safety App
// Displays interactive map with safety features and real-time location tracking

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import '../services/google_maps_service.dart';
import '../services/location_service.dart';
import '../config/firebase_config.dart';

class GoogleMapsWidget extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final bool showCurrentLocation;
  final bool showEmergencyServices;
  final bool showTouristAttractions;
  final bool showSafetyZones;
  final Function(LatLng)? onLocationTap;
  final Function(PlaceResult)? onPlaceTap;

  const GoogleMapsWidget({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.showCurrentLocation = true,
    this.showEmergencyServices = true,
    this.showTouristAttractions = false,
    this.showSafetyZones = true,
    this.onLocationTap,
    this.onPlaceTap,
  });

  @override
  State<GoogleMapsWidget> createState() => _GoogleMapsWidgetState();
}

class _GoogleMapsWidgetState extends State<GoogleMapsWidget> {
  GoogleMapController? _mapController;
  LocationData? _currentLocation;
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  StreamSubscription<LocationData>? _locationSubscription;
  
  final GoogleMapsService _mapsService = GoogleMapsService.instance;
  final LocationService _locationService = LocationService.instance;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initializeMap() async {
    try {
      // Get current location
      _currentLocation = await _locationService.getCurrentLocation();
      
      if (_currentLocation != null) {
        await _updateMapData();
        
        // Start location tracking if enabled
        if (widget.showCurrentLocation) {
          _startLocationTracking();
        }
      }
    } catch (e) {
      print('Error initializing map: $e');
    }
  }

  void _startLocationTracking() {
    _locationSubscription = _locationService.locationStream.listen((location) {
      if (mounted) {
        setState(() {
          _currentLocation = location;
        });
        _updateCurrentLocationMarker();
      }
    });
  }

  Future<void> _updateMapData() async {
    if (_currentLocation == null) return;

    final markers = <Marker>{};
    final circles = <Circle>{};

    // Add current location marker
    if (widget.showCurrentLocation) {
      markers.add(Marker(
        markerId: const MarkerId('current_location'),
        position: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(
          title: 'Your Location',
          snippet: 'Current position',
        ),
      ));
    }

    // Add emergency services markers
    if (widget.showEmergencyServices) {
      final emergencyServices = await _mapsService.findEmergencyServices(
        latitude: _currentLocation!.latitude!,
        longitude: _currentLocation!.longitude!,
      );

      for (final service in emergencyServices) {
        BitmapDescriptor icon;
        if (service.types.contains('hospital')) {
          icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
        } else if (service.types.contains('police')) {
          icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
        } else {
          icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
        }

        markers.add(Marker(
          markerId: MarkerId('emergency_${service.placeId}'),
          position: LatLng(service.latitude, service.longitude),
          icon: icon,
          infoWindow: InfoWindow(
            title: service.name,
            snippet: service.address ?? 'Emergency Service',
          ),
          onTap: () => widget.onPlaceTap?.call(service),
        ));
      }
    }

    // Add tourist attractions markers
    if (widget.showTouristAttractions) {
      final attractions = await _mapsService.findTouristAttractions(
        latitude: _currentLocation!.latitude!,
        longitude: _currentLocation!.longitude!,
      );

      for (final attraction in attractions) {
        markers.add(Marker(
          markerId: MarkerId('attraction_${attraction.placeId}'),
          position: LatLng(attraction.latitude, attraction.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: attraction.name,
            snippet: 'Rating: ${attraction.rating}/5',
          ),
          onTap: () => widget.onPlaceTap?.call(attraction),
        ));
      }
    }

    // Add safety zones
    if (widget.showSafetyZones) {
      final safetyAssessment = await _mapsService.assessLocationSafety(
        latitude: _currentLocation!.latitude!,
        longitude: _currentLocation!.longitude!,
      );

      // Add safety circle based on assessment
      Color circleColor;
      if (safetyAssessment.safetyScore >= 70) {
        circleColor = Colors.green.withOpacity(0.3);
      } else if (safetyAssessment.safetyScore >= 40) {
        circleColor = Colors.orange.withOpacity(0.3);
      } else {
        circleColor = Colors.red.withOpacity(0.3);
      }

      circles.add(Circle(
        circleId: const CircleId('safety_zone'),
        center: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
        radius: 1000, // 1km radius
        fillColor: circleColor,
        strokeColor: circleColor.withOpacity(0.8),
        strokeWidth: 2,
      ));
    }

    if (mounted) {
      setState(() {
        _markers = markers;
        _circles = circles;
      });
    }
  }

  void _updateCurrentLocationMarker() {
    if (_currentLocation == null) return;

    final updatedMarkers = Set<Marker>.from(_markers);
    updatedMarkers.removeWhere((marker) => marker.markerId.value == 'current_location');
    
    updatedMarkers.add(Marker(
      markerId: const MarkerId('current_location'),
      position: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow: const InfoWindow(
        title: 'Your Location',
        snippet: 'Current position',
      ),
    ));

    if (mounted) {
      setState(() {
        _markers = updatedMarkers;
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    
    // Move camera to current location or initial location
    if (_currentLocation != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
          15.0,
        ),
      );
    } else if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(widget.initialLatitude!, widget.initialLongitude!),
          15.0,
        ),
      );
    }
  }

  void _onMapTap(LatLng position) {
    widget.onLocationTap?.call(position);
  }

  Future<void> _refreshMapData() async {
    await _updateMapData();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: _onMapCreated,
          onTap: _onMapTap,
          initialCameraPosition: CameraPosition(
            target: LatLng(
              widget.initialLatitude ?? _currentLocation?.latitude ?? 37.7749,
              widget.initialLongitude ?? _currentLocation?.longitude ?? -122.4194,
            ),
            zoom: 15.0,
          ),
          markers: _markers,
          circles: _circles,
          myLocationEnabled: widget.showCurrentLocation,
          myLocationButtonEnabled: true,
          compassEnabled: true,
          mapToolbarEnabled: true,
          zoomControlsEnabled: true,
          zoomGesturesEnabled: true,
          scrollGesturesEnabled: true,
          tiltGesturesEnabled: true,
          rotateGesturesEnabled: true,
          mapType: MapType.normal,
        ),
        
        // Refresh button
        Positioned(
          top: 16,
          right: 16,
          child: FloatingActionButton(
            mini: true,
            onPressed: _refreshMapData,
            backgroundColor: Colors.white,
            child: const Icon(Icons.refresh, color: Colors.blue),
          ),
        ),
        
        // Safety score indicator
        if (widget.showSafetyZones && _currentLocation != null)
          Positioned(
            top: 16,
            left: 16,
            child: FutureBuilder<SafetyAssessment>(
              future: _mapsService.assessLocationSafety(
                latitude: _currentLocation!.latitude!,
                longitude: _currentLocation!.longitude!,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final assessment = snapshot.data!;
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.security,
                              color: assessment.safetyScore >= 70 
                                ? Colors.green 
                                : assessment.safetyScore >= 40 
                                  ? Colors.orange 
                                  : Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Safety: ${assessment.safetyScore}%',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${assessment.nearbyEmergencyServices.length} emergency services nearby',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
      ],
    );
  }
}

/// Map legend widget to show marker meanings
class MapLegend extends StatelessWidget {
  const MapLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Map Legend',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          _buildLegendItem(Colors.blue, 'Your Location'),
          _buildLegendItem(Colors.red, 'Hospitals'),
          _buildLegendItem(Colors.orange, 'Police Stations'),
          _buildLegendItem(Colors.yellow, 'Fire Stations'),
          _buildLegendItem(Colors.green, 'Tourist Attractions'),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
