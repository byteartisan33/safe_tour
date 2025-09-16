import 'package:flutter/material.dart';
import '../models/alert_models.dart';

class ZoneMapWidget extends StatefulWidget {
  final GeoPoint currentLocation;
  final List<GeoZone> zones;
  final Function(GeoZone) onZoneSelected;

  const ZoneMapWidget({
    super.key,
    required this.currentLocation,
    required this.zones,
    required this.onZoneSelected,
  });

  @override
  State<ZoneMapWidget> createState() => _ZoneMapWidgetState();
}

class _ZoneMapWidgetState extends State<ZoneMapWidget> {
  ZoneType? _selectedZoneType;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredZones = _getFilteredZones();

    return Column(
      children: [
        // Search and Filter Bar
        Container(
          padding: EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            children: [
              // Search Bar
              TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search zones...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              SizedBox(height: 12),
              
              // Zone Type Filters
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All', null),
                    SizedBox(width: 8),
                    _buildFilterChip('Safe', ZoneType.safe),
                    SizedBox(width: 8),
                    _buildFilterChip('Caution', ZoneType.caution),
                    SizedBox(width: 8),
                    _buildFilterChip('High Risk', ZoneType.highRisk),
                    SizedBox(width: 8),
                    _buildFilterChip('Restricted', ZoneType.restricted),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Zone Statistics
        Container(
          padding: EdgeInsets.all(16),
          color: Colors.grey[50],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Total Zones',
                widget.zones.length.toString(),
                Icons.location_on,
                Colors.blue,
              ),
              _buildStatItem(
                'Safe Zones',
                widget.zones.where((z) => z.type == ZoneType.safe).length.toString(),
                Icons.check_circle,
                Colors.green,
              ),
              _buildStatItem(
                'High Risk',
                widget.zones.where((z) => z.type == ZoneType.highRisk).length.toString(),
                Icons.warning,
                Colors.red,
              ),
            ],
          ),
        ),
        
        // Zones List
        Expanded(
          child: filteredZones.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: filteredZones.length,
                  itemBuilder: (context, index) {
                    final zone = filteredZones[index];
                    return _buildZoneItem(zone);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, ZoneType? type) {
    final isSelected = _selectedZoneType == type;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedZoneType = selected ? type : null;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: _getZoneColor(type ?? ZoneType.safe).withValues(alpha: 0.2),
      checkmarkColor: _getZoneColor(type ?? ZoneType.safe),
      labelStyle: TextStyle(
        color: isSelected 
            ? _getZoneColor(type ?? ZoneType.safe)
            : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildZoneItem(GeoZone zone) {
    final distance = _calculateDistance(zone);
    final isCurrentZone = _isCurrentZone(zone);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onZoneSelected(zone),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCurrentZone 
                    ? _getZoneColor(zone.type)
                    : _getZoneColor(zone.type).withValues(alpha: 0.3),
                width: isCurrentZone ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: _getZoneColor(zone.type).withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getZoneColor(zone.type).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getZoneIcon(zone.type),
                        color: _getZoneColor(zone.type),
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            zone.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(height: 2),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getZoneColor(zone.type).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              zone.type.displayName.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _getZoneColor(zone.type),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isCurrentZone)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'CURRENT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ),
                  ],
                ),
                
                SizedBox(height: 12),
                
                // Description
                Text(
                  zone.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
                
                SizedBox(height: 12),
                
                // Footer
                Row(
                  children: [
                    Icon(Icons.straighten, size: 14, color: Colors.grey[500]),
                    SizedBox(width: 4),
                    Text(
                      'Radius: ${(zone.radius / 1000).toStringAsFixed(1)}km',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Spacer(),
                    Icon(Icons.navigation, size: 14, color: Colors.grey[500]),
                    SizedBox(width: 4),
                    Text(
                      '${distance.toStringAsFixed(1)}km away',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No zones found',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  List<GeoZone> _getFilteredZones() {
    var zones = widget.zones.where((zone) => zone.isActive).toList();
    
    // Filter by type
    if (_selectedZoneType != null) {
      zones = zones.where((zone) => zone.type == _selectedZoneType).toList();
    }
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      zones = zones.where((zone) =>
          zone.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          zone.description.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    
    // Sort by distance
    zones.sort((a, b) => _calculateDistance(a).compareTo(_calculateDistance(b)));
    
    return zones;
  }

  double _calculateDistance(GeoZone zone) {
    return widget.currentLocation.distanceTo(GeoPoint(
      latitude: zone.centerLatitude,
      longitude: zone.centerLongitude,
    )) / 1000; // Convert to kilometers
  }

  bool _isCurrentZone(GeoZone zone) {
    return zone.containsPoint(
      widget.currentLocation.latitude,
      widget.currentLocation.longitude,
    );
  }

  Color _getZoneColor(ZoneType type) {
    switch (type) {
      case ZoneType.safe:
        return Colors.green;
      case ZoneType.caution:
        return Colors.orange;
      case ZoneType.highRisk:
        return Colors.red;
      case ZoneType.restricted:
        return Colors.red[900]!;
    }
  }

  IconData _getZoneIcon(ZoneType type) {
    switch (type) {
      case ZoneType.safe:
        return Icons.check_circle;
      case ZoneType.caution:
        return Icons.warning;
      case ZoneType.highRisk:
        return Icons.dangerous;
      case ZoneType.restricted:
        return Icons.block;
    }
  }
}
