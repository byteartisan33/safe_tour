// Interactive Map Screen for Smart Tourist Safety App
// Full-screen Google Maps with safety features and real-time data

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import '../../services/google_maps_service.dart';
import '../../services/location_service.dart';
import '../../widgets/google_maps_widget.dart';

class InteractiveMapScreen extends StatefulWidget {
  const InteractiveMapScreen({super.key});

  @override
  State<InteractiveMapScreen> createState() => _InteractiveMapScreenState();
}

class _InteractiveMapScreenState extends State<InteractiveMapScreen> {
  bool _showEmergencyServices = true;
  bool _showTouristAttractions = false;
  bool _showSafetyZones = true;
  bool _showLegend = false;
  
  final GoogleMapsService _mapsService = GoogleMapsService.instance;
  final LocationService _locationService = LocationService.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interactive Safety Map'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_showLegend ? Icons.visibility_off : Icons.visibility),
            onPressed: () {
              setState(() {
                _showLegend = !_showLegend;
              });
            },
            tooltip: _showLegend ? 'Hide Legend' : 'Show Legend',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.layers),
            onSelected: _handleMenuSelection,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'emergency',
                child: Row(
                  children: [
                    Icon(
                      _showEmergencyServices ? Icons.check_box : Icons.check_box_outline_blank,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 8),
                    const Text('Emergency Services'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'attractions',
                child: Row(
                  children: [
                    Icon(
                      _showTouristAttractions ? Icons.check_box : Icons.check_box_outline_blank,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    const Text('Tourist Attractions'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'safety',
                child: Row(
                  children: [
                    Icon(
                      _showSafetyZones ? Icons.check_box : Icons.check_box_outline_blank,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    const Text('Safety Zones'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main Google Maps Widget
          GoogleMapsWidget(
            showEmergencyServices: _showEmergencyServices,
            showTouristAttractions: _showTouristAttractions,
            showSafetyZones: _showSafetyZones,
            onLocationTap: _onLocationTap,
            onPlaceTap: _onPlaceTap,
          ),
          
          // Map Legend
          if (_showLegend)
            Positioned(
              bottom: 100,
              left: 16,
              child: MapLegend(),
            ),
          
          // Quick Actions Panel
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: _buildQuickActionsPanel(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _findNearestEmergencyService,
        icon: const Icon(Icons.local_hospital),
        label: const Text('Find Help'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _handleMenuSelection(String value) {
    setState(() {
      switch (value) {
        case 'emergency':
          _showEmergencyServices = !_showEmergencyServices;
          break;
        case 'attractions':
          _showTouristAttractions = !_showTouristAttractions;
          break;
        case 'safety':
          _showSafetyZones = !_showSafetyZones;
          break;
      }
    });
  }

  void _onLocationTap(LatLng position) {
    _showLocationInfo(position);
  }

  void _onPlaceTap(PlaceResult place) {
    _showPlaceDetails(place);
  }

  void _showLocationInfo(LatLng position) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Location Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Latitude: ${position.latitude.toStringAsFixed(6)}'),
            Text('Longitude: ${position.longitude.toStringAsFixed(6)}'),
            const SizedBox(height: 16),
            FutureBuilder<String?>(
              future: _mapsService.getAddressFromCoordinates(
                position.latitude,
                position.longitude,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text('Address: ${snapshot.data}');
                }
                return const Text('Loading address...');
              },
            ),
            const SizedBox(height: 16),
            FutureBuilder<SafetyAssessment>(
              future: _mapsService.assessLocationSafety(
                latitude: position.latitude,
                longitude: position.longitude,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final assessment = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Safety Score: ${assessment.safetyScore}%'),
                      const SizedBox(height: 8),
                      ...assessment.recommendations.map((rec) => 
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('• $rec', style: const TextStyle(fontSize: 12)),
                        ),
                      ),
                    ],
                  );
                }
                return const Text('Assessing safety...');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPlaceDetails(PlaceResult place) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              place.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (place.address != null) Text('Address: ${place.address}'),
            if (place.rating > 0) Text('Rating: ${place.rating}/5'),
            Text('Type: ${place.types.join(', ')}'),
            Text('Status: ${place.isOpen ? 'Open' : 'Closed'}'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _getDirections(place),
                    icon: const Icon(Icons.directions),
                    label: const Text('Directions'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _callPlace(place),
                    icon: const Icon(Icons.phone),
                    label: const Text('Call'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildQuickActionButton(
            icon: Icons.local_hospital,
            label: 'Hospital',
            color: Colors.red,
            onTap: () => _findNearbyPlaces('hospital'),
          ),
          _buildQuickActionButton(
            icon: Icons.local_police,
            label: 'Police',
            color: Colors.blue,
            onTap: () => _findNearbyPlaces('police'),
          ),
          _buildQuickActionButton(
            icon: Icons.local_gas_station,
            label: 'Gas Station',
            color: Colors.green,
            onTap: () => _findNearbyPlaces('gas_station'),
          ),
          _buildQuickActionButton(
            icon: Icons.restaurant,
            label: 'Food',
            color: Colors.orange,
            onTap: () => _findNearbyPlaces('restaurant'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color),
          ),
        ],
      ),
    );
  }

  Future<void> _findNearbyPlaces(String type) async {
    try {
      final location = await _locationService.getCurrentLocation();
      if (location != null) {
        final places = await _mapsService.findNearbyPlaces(
          latitude: location.latitude!,
          longitude: location.longitude!,
          type: type,
        );
        
        if (places.isNotEmpty) {
          _showNearbyPlacesList(places, type);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No $type found nearby')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error finding $type: $e')),
      );
    }
  }

  void _showNearbyPlacesList(List<PlaceResult> places, String type) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nearby ${type.replaceAll('_', ' ').toUpperCase()}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: places.length,
                itemBuilder: (context, index) {
                  final place = places[index];
                  return ListTile(
                    title: Text(place.name),
                    subtitle: Text(place.address ?? 'No address available'),
                    trailing: place.rating > 0 
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            Text('${place.rating}'),
                          ],
                        )
                      : null,
                    onTap: () {
                      Navigator.pop(context);
                      _showPlaceDetails(place);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _findNearestEmergencyService() async {
    try {
      final location = await _locationService.getCurrentLocation();
      if (location != null) {
        final emergencyServices = await _mapsService.findEmergencyServices(
          latitude: location.latitude!,
          longitude: location.longitude!,
        );
        
        if (emergencyServices.isNotEmpty) {
          final nearest = emergencyServices.first;
          _showPlaceDetails(nearest);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No emergency services found nearby')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error finding emergency services: $e')),
      );
    }
  }

  void _getDirections(PlaceResult place) {
    // TODO: Implement directions functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Getting directions to ${place.name}...')),
    );
  }

  void _callPlace(PlaceResult place) {
    // TODO: Implement phone call functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Calling ${place.name}...')),
    );
  }
}

/// Map legend widget
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
          const SizedBox(height: 8),
          const Text(
            'Safety Zones:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          _buildLegendItem(Colors.green.withOpacity(0.3), 'Safe (70%+)'),
          _buildLegendItem(Colors.orange.withOpacity(0.3), 'Moderate (40-69%)'),
          _buildLegendItem(Colors.red.withOpacity(0.3), 'Caution (<40%)'),
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
