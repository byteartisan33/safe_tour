import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/user_models.dart';
import '../../services/safety_score_service.dart';
import '../../services/geo_fencing_service.dart';
import '../../services/emergency_service.dart';
import '../../services/google_maps_service.dart';
import '../alerts/geo_fencing_alerts_screen.dart';
import '../emergency/panic_button_screen.dart';
import '../../widgets/safety_score_widget.dart';
import '../../widgets/panic_button_widget.dart';
import '../../widgets/location_widget.dart';
import '../../widgets/trip_summary_widget.dart';
import '../../widgets/alerts_widget.dart';
import '../../widgets/digital_id_widget.dart';
import '../../widgets/google_maps_widget.dart';
import '../profile/profile_settings_screen.dart';
import '../blockchain/digital_id_screen.dart';
import '../maps/interactive_map_screen.dart';
import '../../services/blockchain_service.dart';
import '../../models/blockchain_models.dart';

class HomeDashboard extends StatefulWidget {
  final UserRegistrationData userData;
  final String selectedLanguage;

  const HomeDashboard({
    super.key,
    required this.userData,
    required this.selectedLanguage,
  });

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  int _safetyScore = 85;
  String _currentLocation = 'Loading location...';
  List<String> _activeAlerts = [];
  bool _isLocationLoading = true;
  bool _isPanicMode = false;
  DigitalTouristID? _digitalId;
  final BlockchainService _blockchainService = BlockchainService();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadDashboardData();
    _initializeGeoFencing();
    _initializeBlockchain();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  void _initializeGeoFencing() {
    // Initialize geo-fencing service
    GeoFencingService.initialize();
    GeoFencingService.startMonitoring((alert) {
      // Update active alerts when new alerts are received
      if (mounted) {
        setState(() {
          _activeAlerts.insert(0, alert.title);
        });
      }
    });

    // Initialize emergency service
    EmergencyService.initialize();
  }

  void _initializeBlockchain() async {
    // Initialize blockchain service
    await _blockchainService.initialize();

    // Listen for digital ID updates
    _blockchainService.digitalIdStream.listen((digitalId) {
      if (mounted) {
        setState(() {
          _digitalId = digitalId;
        });
      }
    });

    // Issue digital ID if user is registered
    if (widget.userData.personalInfo.fullName.isNotEmpty) {
      final digitalId = await _blockchainService.issueDigitalTouristID(
        widget.userData,
      );
      if (digitalId != null && mounted) {
        setState(() {
          _digitalId = digitalId;
        });
      }
    }
  }

  Future<void> _loadDashboardData() async {
    // Simulate loading dashboard data
    await Future.delayed(Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _safetyScore = SafetyScoreService.calculateSafetyScore(
          widget.userData.tripDetails,
          widget.userData.personalInfo,
        );
        _currentLocation = 'New Delhi, India'; // Simulated location
        _activeAlerts = [
          'High tourist activity in your area',
          'Weather alert: Light rain expected',
        ];
        _isLocationLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: RefreshIndicator(
            onRefresh: _refreshDashboard,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  _buildHeader(),
                  SizedBox(height: 24),

                  // Safety Score Card
                  SafetyScoreWidget(
                    score: _safetyScore,
                    onTap: _showSafetyScoreDetails,
                  ),
                  SizedBox(height: 16),

                  // Digital Tourist ID Card
                  DigitalIdWidget(digitalId: _digitalId, onTap: _showDigitalId),
                  SizedBox(height: 16),

                  // Location and Trip Summary Row
                  Row(
                    children: [
                      Expanded(
                        child: LocationWidget(
                          currentLocation: _currentLocation,
                          isLoading: _isLocationLoading,
                          onLocationTap: _showLocationDetails,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: TripSummaryWidget(
                          tripDetails: widget.userData.tripDetails,
                          onTap: _showTripDetails,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Panic Button
                  PanicButtonWidget(
                    isPanicMode: _isPanicMode,
                    onPanicPressed: _handlePanicButton,
                  ),
                  SizedBox(height: 16),

                  // Quick Actions
                  _buildQuickActions(),
                  SizedBox(height: 16),

                  // Alerts Section
                  AlertsWidget(
                    alerts: _activeAlerts,
                    onAlertTap: _showAlertDetails,
                  ),
                  SizedBox(height: 16),

                  // Recent Activity
                  _buildRecentActivity(),
                  SizedBox(height: 80), // Bottom padding for FAB
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showEmergencyContacts,
        backgroundColor: Colors.red[600],
        icon: Icon(Icons.emergency, color: Colors.white),
        label: Text(
          'Emergency',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      drawer: _buildDrawer(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[700]!, Colors.blue[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Text(
              widget.userData.personalInfo.fullName.isNotEmpty
                  ? widget.userData.personalInfo.fullName[0].toUpperCase()
                  : 'U',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                Text(
                  widget.userData.personalInfo.fullName.split(' ').first,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Stay safe during your journey',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _showNotifications,
            icon: Stack(
              children: [
                Icon(Icons.notifications, color: Colors.white, size: 28),
                if (_activeAlerts.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '${_activeAlerts.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            onPressed: _navigateToProfile,
            icon: Icon(Icons.person, color: Colors.white, size: 28),
            tooltip: 'Profile & Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickActionButton(
                icon: Icons.map,
                label: 'View Map',
                color: Colors.green,
                onTap: _showMap,
              ),
              _buildQuickActionButton(
                icon: Icons.local_hospital,
                label: 'Hospitals',
                color: Colors.red,
                onTap: _showNearbyHospitals,
              ),
              _buildQuickActionButton(
                icon: Icons.local_police,
                label: 'Police',
                color: Colors.blue,
                onTap: _showNearbyPolice,
              ),
              _buildQuickActionButton(
                icon: Icons.phone,
                label: 'Helpline',
                color: Colors.orange,
                onTap: _showHelpline,
              ),
            ],
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(12),
        child: Column(
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
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16),
          _buildActivityItem(
            icon: Icons.location_on,
            title: 'Location Updated',
            subtitle: 'New Delhi, India',
            time: '2 minutes ago',
            color: Colors.green,
          ),
          _buildActivityItem(
            icon: Icons.security,
            title: 'Safety Score Updated',
            subtitle: 'Score: $_safetyScore/100',
            time: '5 minutes ago',
            color: Colors.blue,
          ),
          _buildActivityItem(
            icon: Icons.warning,
            title: 'Area Alert',
            subtitle: 'High tourist activity detected',
            time: '10 minutes ago',
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(time, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[700]!, Colors.blue[500]!],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Text(
                    widget.userData.personalInfo.fullName[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  widget.userData.personalInfo.fullName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.userData.credentials.email,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text('Dashboard'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            onTap: _showProfile,
          ),
          ListTile(
            leading: Icon(Icons.trip_origin),
            title: Text('Trip Details'),
            onTap: _showTripDetails,
          ),
          ListTile(
            leading: Icon(Icons.emergency),
            title: Text('Emergency Contacts'),
            onTap: _showEmergencyContacts,
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: _showSettings,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: _handleLogout,
          ),
        ],
      ),
    );
  }

  // Event Handlers
  Future<void> _refreshDashboard() async {
    await _loadDashboardData();
    HapticFeedback.lightImpact();
  }

  void _handlePanicButton() {
    setState(() {
      _isPanicMode = !_isPanicMode;
    });

    if (_isPanicMode) {
      _activatePanicMode();
    } else {
      _deactivatePanicMode();
    }
  }

  void _activatePanicMode() {
    HapticFeedback.heavyImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PanicButtonScreen(
          selectedLanguage: widget.selectedLanguage,
          userData: widget.userData,
        ),
      ),
    );
  }

  void _deactivatePanicMode() {
    // TODO: Implement panic mode deactivation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Panic mode deactivated'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showSafetyScoreDetails() {
    // TODO: Show detailed safety score breakdown
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Safety Score Details'),
        content: Text(
          'Your current safety score is $_safetyScore/100 based on your location, travel behavior, and area risk factors.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLocationDetails() {
    // TODO: Show detailed location information
  }

  void _showTripDetails() {
    // TODO: Show trip details screen
  }

  void _showAlertDetails(String alert) {
    // TODO: Show alert details
  }

  void _showNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            GeoFencingAlertsScreen(selectedLanguage: widget.selectedLanguage),
      ),
    );
  }

  void _navigateToProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileSettingsScreen(
          selectedLanguage: widget.selectedLanguage,
          userData: widget.userData,
        ),
      ),
    );
  }

  void _showDigitalId() {
    if (_digitalId != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DigitalIdScreen(
            digitalId: _digitalId!,
            selectedLanguage: widget.selectedLanguage,
          ),
        ),
      );
    } else {
      // Show dialog to create digital ID
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Create Digital Tourist ID'),
          content: Text(
            'Would you like to create your blockchain-verified Digital Tourist ID? '
            'This will provide secure, tamper-proof identity verification.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final digitalId = await _blockchainService
                    .issueDigitalTouristID(widget.userData);
                if (digitalId != null && mounted) {
                  setState(() {
                    _digitalId = digitalId;
                  });
                }
              },
              child: Text('Create ID'),
            ),
          ],
        ),
      );
    }
  }

  void _showMap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const InteractiveMapScreen()),
    );
  }

  void _showNearbyHospitals() {
    // TODO: Show nearby hospitals
  }

  void _showNearbyPolice() {
    // TODO: Show nearby police stations
  }

  void _showHelpline() {
    // TODO: Show helpline numbers
  }

  void _showEmergencyContacts() {
    // TODO: Show emergency contacts
  }

  void _showProfile() {
    // TODO: Show user profile
  }

  void _showSettings() {
    // TODO: Show settings screen
  }

  void _handleLogout() {
    // TODO: Handle logout
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
