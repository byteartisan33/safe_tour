import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/alert_models.dart';
import '../../services/geo_fencing_service.dart';
import '../../widgets/alert_item_widget.dart';
import '../../widgets/zone_map_widget.dart';

class GeoFencingAlertsScreen extends StatefulWidget {
  final String selectedLanguage;

  const GeoFencingAlertsScreen({
    super.key,
    required this.selectedLanguage,
  });

  @override
  State<GeoFencingAlertsScreen> createState() => _GeoFencingAlertsScreenState();
}

class _GeoFencingAlertsScreenState extends State<GeoFencingAlertsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<GeoAlert> _activeAlerts = [];
  List<GeoAlert> _alertHistory = [];
  bool _isLoading = true;
  String _currentZone = 'Safe Zone';
  ZoneType _currentZoneType = ZoneType.safe;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _loadAlertsData();
    _startRealTimeMonitoring();
    _animationController.forward();
  }

  Future<void> _loadAlertsData() async {
    // Simulate loading alerts data
    await Future.delayed(Duration(seconds: 1));
    
    if (mounted) {
      setState(() {
        _activeAlerts = GeoFencingService.getActiveAlerts();
        _alertHistory = GeoFencingService.getAlertHistory();
        _currentZone = GeoFencingService.getCurrentZone();
        _currentZoneType = GeoFencingService.getCurrentZoneType();
        _isLoading = false;
      });
    }
  }

  void _startRealTimeMonitoring() {
    // Start listening to geo-fencing updates
    GeoFencingService.startMonitoring((alert) {
      if (mounted) {
        setState(() {
          _activeAlerts.insert(0, alert);
          _alertHistory.insert(0, alert);
        });
        _showRealTimeAlert(alert);
      }
    });
  }

  void _showRealTimeAlert(GeoAlert alert) {
    HapticFeedback.heavyImpact();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _getAlertIcon(alert.type),
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    alert.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    alert.description,
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: _getAlertColor(alert.severity),
        duration: Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () => _showAlertDetails(alert),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Geo-fencing Alerts',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              icon: Icon(Icons.warning),
              text: 'Active (${_activeAlerts.length})',
            ),
            Tab(
              icon: Icon(Icons.history),
              text: 'History',
            ),
            Tab(
              icon: Icon(Icons.map),
              text: 'Zones',
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _refreshAlerts,
            icon: Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: _showSettings,
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Current Zone Status
            _buildCurrentZoneStatus(),
            
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildActiveAlertsTab(),
                  _buildHistoryTab(),
                  _buildZonesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showEmergencyOptions,
        backgroundColor: Colors.red[600],
        icon: Icon(Icons.emergency, color: Colors.white),
        label: Text(
          'Emergency',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildCurrentZoneStatus() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getZoneColor(_currentZoneType),
            _getZoneColor(_currentZoneType).withValues(alpha: 0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: _getZoneColor(_currentZoneType).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getZoneIcon(_currentZoneType),
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Zone',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                Text(
                  _currentZone,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _getZoneDescription(_currentZoneType),
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _currentZoneType.name.toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveAlertsTab() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.blue[700]),
            SizedBox(height: 16),
            Text('Loading active alerts...'),
          ],
        ),
      );
    }

    if (_activeAlerts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 80,
              color: Colors.green[400],
            ),
            SizedBox(height: 16),
            Text(
              'No Active Alerts',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'You are currently in a safe zone',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshAlerts,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _activeAlerts.length,
        itemBuilder: (context, index) {
          final alert = _activeAlerts[index];
          return AlertItemWidget(
            alert: alert,
            onTap: () => _showAlertDetails(alert),
            onDismiss: () => _dismissAlert(alert),
            showDismissButton: true,
          );
        },
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_alertHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No Alert History',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Alert history will appear here',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _alertHistory.length,
      itemBuilder: (context, index) {
        final alert = _alertHistory[index];
        return AlertItemWidget(
          alert: alert,
          onTap: () => _showAlertDetails(alert),
          showDismissButton: false,
          isHistoryItem: true,
        );
      },
    );
  }

  Widget _buildZonesTab() {
    return ZoneMapWidget(
      currentLocation: GeoFencingService.getCurrentLocation(),
      zones: GeoFencingService.getAllZones(),
      onZoneSelected: _showZoneDetails,
    );
  }

  // Helper methods for colors and icons
  Color _getAlertColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.low:
        return Colors.blue;
      case AlertSeverity.medium:
        return Colors.orange;
      case AlertSeverity.high:
        return Colors.red;
      case AlertSeverity.critical:
        return Colors.red[900]!;
    }
  }

  IconData _getAlertIcon(AlertType type) {
    switch (type) {
      case AlertType.zoneEntry:
        return Icons.login;
      case AlertType.zoneExit:
        return Icons.logout;
      case AlertType.highRisk:
        return Icons.warning;
      case AlertType.restricted:
        return Icons.block;
      case AlertType.safety:
        return Icons.security;
    }
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

  String _getZoneDescription(ZoneType type) {
    switch (type) {
      case ZoneType.safe:
        return 'Safe for tourists - Normal precautions';
      case ZoneType.caution:
        return 'Exercise caution - Stay alert';
      case ZoneType.highRisk:
        return 'High risk area - Avoid if possible';
      case ZoneType.restricted:
        return 'Restricted area - Entry prohibited';
    }
  }

  // Event handlers
  Future<void> _refreshAlerts() async {
    await _loadAlertsData();
    HapticFeedback.lightImpact();
  }

  void _dismissAlert(GeoAlert alert) {
    setState(() {
      _activeAlerts.remove(alert);
    });
    GeoFencingService.dismissAlert(alert.id);
  }

  void _showAlertDetails(GeoAlert alert) {
    // TODO: Show detailed alert information
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(alert.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(alert.description),
            SizedBox(height: 16),
            Text(
              'Time: ${alert.timestamp.toString()}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              'Location: ${alert.location}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showZoneDetails(GeoZone zone) {
    // TODO: Show zone details
  }

  void _showSettings() {
    // TODO: Show alert settings
  }

  void _showEmergencyOptions() {
    // TODO: Show emergency options
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    GeoFencingService.stopMonitoring();
    super.dispose();
  }
}
