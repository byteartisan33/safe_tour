import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../models/user_models.dart';
import '../../models/emergency_models.dart';
import '../../services/location_service.dart' as location_service;
import '../../services/emergency_service.dart';
import '../../widgets/emergency_countdown_widget.dart';

class PanicButtonScreen extends StatefulWidget {
  final String selectedLanguage;
  final UserRegistrationData? userData;

  const PanicButtonScreen({
    super.key,
    required this.selectedLanguage,
    this.userData,
  });

  @override
  State<PanicButtonScreen> createState() => _PanicButtonScreenState();
}

class _PanicButtonScreenState extends State<PanicButtonScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late AnimationController _fadeController;

  // Animations
  late Animation<double> _pulseAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _fadeAnimation;

  // Emergency state
  bool _isEmergencyActive = false;
  bool _isCountdownActive = false;
  int _countdownSeconds = 10;
  Timer? _countdownTimer;
  Timer? _locationUpdateTimer;

  // Location and emergency data
  location_service.LocationData? _currentLocation;
  List<EmergencyContact> _emergencyContacts = [];
  List<PoliceStation> _nearbyPoliceStations = [];
  EmergencyAlert? _activeAlert;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadEmergencyData();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shakeController.dispose();
    _fadeController.dispose();
    _countdownTimer?.cancel();
    _locationUpdateTimer?.cancel();
    super.dispose();
  }

  void _initializeAnimations() {
    // Pulse animation for panic button
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Shake animation for urgent alerts
    _shakeController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    // Fade animation for screen transitions
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Start animations
    _pulseController.repeat(reverse: true);
    _fadeController.forward();
  }

  Future<void> _loadEmergencyData() async {
    // Load user's emergency contacts
    if (widget.userData?.emergencyContacts != null) {
      _emergencyContacts = widget.userData!.emergencyContacts;
    }

    // Get current location
    await _updateLocation();

    // Find nearby police stations
    if (_currentLocation != null) {
      _nearbyPoliceStations = await EmergencyService.findNearbyPoliceStations(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
      );
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _updateLocation() async {
    try {
      final location =
          await location_service.LocationService.getCurrentLocation();
      setState(() {
        _currentLocation = location;
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void _activatePanicButton() {
    if (_isEmergencyActive || _isCountdownActive) return;

    HapticFeedback.heavyImpact();

    setState(() {
      _isCountdownActive = true;
      _countdownSeconds = 10;
    });

    // Start countdown
    _startCountdown();

    // Show confirmation dialog
    _showEmergencyConfirmationDialog();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _countdownSeconds--;
      });

      if (_countdownSeconds <= 0) {
        timer.cancel();
        _triggerEmergencyAlert();
      }
    });
  }

  void _cancelEmergency() {
    _countdownTimer?.cancel();
    setState(() {
      _isCountdownActive = false;
      _countdownSeconds = 10;
    });

    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Emergency alert cancelled'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _triggerEmergencyAlert() async {
    setState(() {
      _isEmergencyActive = true;
      _isCountdownActive = false;
    });

    // Update location one more time
    await _updateLocation();

    // Create emergency alert
    final emergencyLocation = EmergencyLocationData(
      latitude: _currentLocation!.latitude,
      longitude: _currentLocation!.longitude,
      timestamp: _currentLocation!.timestamp,
      address: _currentLocation!.address,
      accuracy: _currentLocation!.accuracy,
    );

    _activeAlert = EmergencyAlert(
      id: 'emergency_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'current_user',
      timestamp: DateTime.now(),
      location: emergencyLocation,
      emergencyContacts: _emergencyContacts,
      nearbyPoliceStations: _nearbyPoliceStations,
      status: EmergencyStatus.active,
    );

    // Send alerts to emergency contacts
    await EmergencyService.sendEmergencyAlerts(_activeAlert!);

    // Notify nearby police stations
    await EmergencyService.notifyPoliceStations(_activeAlert!);

    // Start location tracking
    _startLocationTracking();

    // Show emergency active screen
    _showEmergencyActiveDialog();

    // Trigger haptic feedback
    HapticFeedback.heavyImpact();

    // Start shake animation
    _shakeController.repeat(reverse: true);
  }

  void _startLocationTracking() {
    _locationUpdateTimer = Timer.periodic(Duration(seconds: 30), (timer) async {
      await _updateLocation();
      if (_activeAlert != null && _currentLocation != null) {
        await EmergencyService.updateEmergencyLocation(
          _activeAlert!.id,
          _currentLocation!,
        );
      }
    });
  }

  void _deactivateEmergency() {
    setState(() {
      _isEmergencyActive = false;
    });

    _locationUpdateTimer?.cancel();
    _shakeController.stop();

    if (_activeAlert != null) {
      EmergencyService.deactivateEmergencyAlert(_activeAlert!.id);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Emergency alert deactivated'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isEmergencyActive ? Colors.red[50] : Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Emergency Panic Button',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: _isEmergencyActive ? Colors.red[700] : Colors.red[600],
        elevation: 0,
        actions: [
          if (_isEmergencyActive)
            IconButton(
              onPressed: _deactivateEmergency,
              icon: Icon(Icons.stop, color: Colors.white),
              tooltip: 'Deactivate Emergency',
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _isEmergencyActive
            ? _buildEmergencyActiveView()
            : _buildPanicButtonView(),
      ),
    );
  }

  Widget _buildPanicButtonView() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          // Emergency Instructions
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(Icons.info_outline, size: 48, color: Colors.blue[600]),
                SizedBox(height: 16),
                Text(
                  'Emergency Instructions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Press the panic button below in case of emergency. Your location will be shared with emergency contacts and nearby police stations.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 40),

          // Main Panic Button
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: GestureDetector(
                  onTap: _activatePanicButton,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [Colors.red[400]!, Colors.red[700]!],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.warning, size: 60, color: Colors.white),
                        SizedBox(height: 8),
                        Text(
                          'PANIC',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                        Text(
                          'BUTTON',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          SizedBox(height: 40),

          // Current Location Display
          if (_currentLocation != null) ...[
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: Colors.green, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Location',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        Text(
                          '${_currentLocation!.latitude.toStringAsFixed(6)}, ${_currentLocation!.longitude.toStringAsFixed(6)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                ],
              ),
            ),
            SizedBox(height: 16),
          ],

          // Emergency Contacts Summary
          if (_emergencyContacts.isNotEmpty) ...[
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.contacts, color: Colors.blue, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'Emergency Contacts',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  ...(_emergencyContacts
                      .take(2)
                      .map(
                        (contact) => Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.person,
                                size: 16,
                                color: Colors.grey[500],
                              ),
                              SizedBox(width: 8),
                              Text(
                                '${contact.name} (${contact.relationship})',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                  if (_emergencyContacts.length > 2)
                    Text(
                      '+${_emergencyContacts.length - 2} more contacts',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 16),
          ],

          // Nearby Police Stations
          if (_nearbyPoliceStations.isNotEmpty) ...[
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.local_police, color: Colors.orange, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'Nearby Police Stations',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  ...(_nearbyPoliceStations
                      .take(2)
                      .map(
                        (station) => Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_city,
                                size: 16,
                                color: Colors.grey[500],
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${station.name} - ${station.distance.toStringAsFixed(1)}km',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmergencyActiveView() {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                // Emergency Active Header
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red[700],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.emergency, size: 60, color: Colors.white),
                      SizedBox(height: 12),
                      Text(
                        'EMERGENCY ACTIVE',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Help is on the way',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24),

                // Emergency Status
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Location Tracking
                        _buildStatusCard(
                          'Location Tracking',
                          'Your location is being shared in real-time',
                          Icons.my_location,
                          Colors.green,
                          isActive: true,
                        ),

                        // Emergency Contacts Notified
                        _buildStatusCard(
                          'Emergency Contacts',
                          '${_emergencyContacts.length} contacts notified',
                          Icons.contacts,
                          Colors.blue,
                          isActive: true,
                        ),

                        // Police Stations Notified
                        _buildStatusCard(
                          'Police Stations',
                          '${_nearbyPoliceStations.length} stations notified',
                          Icons.local_police,
                          Colors.orange,
                          isActive: true,
                        ),

                        SizedBox(height: 24),

                        // Deactivate Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _deactivateEmergency,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange[600],
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'DEACTIVATE EMERGENCY',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusCard(
    String title,
    String subtitle,
    IconData icon,
    Color color, {
    bool isActive = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? color.withValues(alpha: 0.5)
              : Colors.grey.withValues(alpha: 0.3),
          width: isActive ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          if (isActive) Icon(Icons.check_circle, color: Colors.green, size: 20),
        ],
      ),
    );
  }

  void _showEmergencyConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => EmergencyCountdownWidget(
        countdownSeconds: _countdownSeconds,
        onCancel: () {
          Navigator.of(context).pop();
          _cancelEmergency();
        },
        onConfirm: () {
          Navigator.of(context).pop();
          _countdownTimer?.cancel();
          _triggerEmergencyAlert();
        },
      ),
    );
  }

  void _showEmergencyActiveDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.emergency, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Emergency alert activated! Help is on the way.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red[700],
        duration: Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
