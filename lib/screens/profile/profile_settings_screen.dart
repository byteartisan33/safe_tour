import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/user_models.dart';
import '../../services/profile_service.dart';
import '../../services/language_service.dart';
import 'edit_profile_screen.dart';
import 'language_settings_screen.dart';
import 'accessibility_settings_screen.dart';
import 'emergency_contacts_screen.dart';

class ProfileSettingsScreen extends StatefulWidget {
  final String selectedLanguage;
  final UserRegistrationData? userData;

  const ProfileSettingsScreen({
    super.key,
    required this.selectedLanguage,
    this.userData,
  });

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  UserRegistrationData? _currentUserData;
  String _currentLanguage = 'English';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentUserData = widget.userData;
    _currentLanguage = widget.selectedLanguage;
    _initializeAnimations();
    _loadProfileData();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
  }

  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load user profile data
      final profileData = await ProfileService.getCurrentUserProfile();
      if (profileData != null) {
        setState(() {
          _currentUserData = profileData;
        });
      }

      // Load current language
      final language = await LanguageService.getCurrentLanguage();
      setState(() {
        _currentLanguage = language;
      });
    } catch (e) {
      print('Error loading profile data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Profile & Settings',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: _editProfile,
            icon: Icon(Icons.edit, color: Colors.white),
            tooltip: 'Edit Profile',
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _isLoading
            ? _buildLoadingView()
            : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Profile Header Card
                    _buildProfileHeaderCard(),
                    SizedBox(height: 24),

                    // Quick Stats Card
                    _buildQuickStatsCard(),
                    SizedBox(height: 24),

                    // Settings Categories
                    _buildSettingsSection('Account Settings', [
                      _buildSettingsItem(
                        'Personal Information',
                        'Update your profile details',
                        Icons.person,
                        Colors.blue,
                        () => _navigateToEditProfile(),
                      ),
                      _buildSettingsItem(
                        'Trip Details',
                        'Manage your travel information',
                        Icons.flight,
                        Colors.green,
                        () => _navigateToTripDetails(),
                      ),
                      _buildSettingsItem(
                        'Emergency Contacts',
                        'Update emergency contact information',
                        Icons.contacts,
                        Colors.red,
                        () => _navigateToEmergencyContacts(),
                      ),
                    ]),

                    SizedBox(height: 16),

                    _buildSettingsSection('App Settings', [
                      _buildSettingsItem(
                        'Language',
                        'Current: $_currentLanguage',
                        Icons.language,
                        Colors.orange,
                        () => _navigateToLanguageSettings(),
                      ),
                      _buildSettingsItem(
                        'Accessibility',
                        'Font size, screen reader settings',
                        Icons.accessibility,
                        Colors.purple,
                        () => _navigateToAccessibilitySettings(),
                      ),
                      _buildSettingsItem(
                        'Notifications',
                        'Manage alert preferences',
                        Icons.notifications,
                        Colors.teal,
                        () => _navigateToNotificationSettings(),
                      ),
                    ]),

                    SizedBox(height: 16),

                    _buildSettingsSection('Privacy & Security', [
                      _buildSettingsItem(
                        'Privacy Settings',
                        'Data sharing and privacy controls',
                        Icons.privacy_tip,
                        Colors.indigo,
                        () => _navigateToPrivacySettings(),
                      ),
                      _buildSettingsItem(
                        'Data & Storage',
                        'Manage app data and storage',
                        Icons.storage,
                        Colors.brown,
                        () => _navigateToDataSettings(),
                      ),
                    ]),

                    SizedBox(height: 16),

                    _buildSettingsSection('Support', [
                      _buildSettingsItem(
                        'Help & FAQ',
                        'Get help and find answers',
                        Icons.help,
                        Colors.cyan,
                        () => _navigateToHelp(),
                      ),
                      _buildSettingsItem(
                        'About',
                        'App version and information',
                        Icons.info,
                        Colors.grey,
                        () => _navigateToAbout(),
                      ),
                    ]),

                    SizedBox(height: 32),

                    // Logout Button
                    _buildLogoutButton(),

                    SizedBox(height: 16),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
          ),
          SizedBox(height: 16),
          Text(
            'Loading profile...',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeaderCard() {
    return Container(
      width: double.infinity,
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
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(Icons.person, size: 40, color: Colors.blue[700]),
          ),

          SizedBox(height: 16),

          // User Name
          Text(
            _currentUserData?.personalInfo.fullName ?? 'Tourist User',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          SizedBox(height: 4),

          // User Details
          Text(
            _currentUserData?.personalInfo.nationality ??
                'International Tourist',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),

          SizedBox(height: 8),

          // Registration Date
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Member since ${_formatDate(_currentUserData?.registrationDate ?? DateTime.now())}',
              style: TextStyle(fontSize: 12, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Trip Days',
            _calculateTripDays().toString(),
            Icons.calendar_today,
            Colors.green,
          ),
          _buildStatItem(
            'Emergency Contacts',
            (_currentUserData?.emergencyContacts.length ?? 0).toString(),
            Icons.contacts,
            Colors.red,
          ),
          _buildStatItem(
            'Language',
            _getLanguageCode(_currentLanguage),
            Icons.language,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
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
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
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
                        fontWeight: FontWeight.w600,
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
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _showLogoutDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[600],
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, size: 20),
            SizedBox(width: 8),
            Text(
              'Logout',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  int _calculateTripDays() {
    if (_currentUserData?.tripDetails.tripStartDate != null &&
        _currentUserData?.tripDetails.tripEndDate != null) {
      return _currentUserData!.tripDetails.tripEndDate
              .difference(_currentUserData!.tripDetails.tripStartDate)
              .inDays +
          1;
    }
    return 0;
  }

  String _getLanguageCode(String language) {
    final codes = {
      'English': 'EN',
      'Hindi': 'HI',
      'Bengali': 'BN',
      'Telugu': 'TE',
      'Marathi': 'MR',
      'Tamil': 'TA',
      'Gujarati': 'GU',
      'Urdu': 'UR',
      'Kannada': 'KN',
      'Odia': 'OD',
      'Malayalam': 'ML',
      'Spanish': 'ES',
      'French': 'FR',
      'German': 'DE',
      'Italian': 'IT',
      'Portuguese': 'PT',
      'Russian': 'RU',
      'Japanese': 'JA',
      'Chinese': 'ZH',
    };
    return codes[language] ?? 'EN';
  }

  // Navigation methods
  void _editProfile() {
    HapticFeedback.lightImpact();
    _navigateToEditProfile();
  }

  void _navigateToEditProfile() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => EditProfileScreen(
              userData: _currentUserData,
              selectedLanguage: _currentLanguage,
            ),
          ),
        )
        .then((updatedData) {
          if (updatedData != null) {
            setState(() {
              _currentUserData = updatedData;
            });
          }
        });
  }

  void _navigateToTripDetails() {
    // TODO: Implement trip details screen
    _showComingSoonDialog('Trip Details');
  }

  void _navigateToEmergencyContacts() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => EmergencyContactsScreen(
              emergencyContacts: _currentUserData?.emergencyContacts ?? [],
              selectedLanguage: _currentLanguage,
            ),
          ),
        )
        .then((updatedContacts) {
          if (updatedContacts != null && _currentUserData != null) {
            setState(() {
              _currentUserData = _currentUserData!.copyWith(
                emergencyContacts: updatedContacts,
              );
            });
          }
        });
  }

  void _navigateToLanguageSettings() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) =>
                LanguageSettingsScreen(currentLanguage: _currentLanguage),
          ),
        )
        .then((newLanguage) {
          if (newLanguage != null) {
            setState(() {
              _currentLanguage = newLanguage;
            });
          }
        });
  }

  void _navigateToAccessibilitySettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            AccessibilitySettingsScreen(selectedLanguage: _currentLanguage),
      ),
    );
  }

  void _navigateToNotificationSettings() {
    _showComingSoonDialog('Notification Settings');
  }

  void _navigateToPrivacySettings() {
    _showComingSoonDialog('Privacy Settings');
  }

  void _navigateToDataSettings() {
    _showComingSoonDialog('Data & Storage');
  }

  void _navigateToHelp() {
    _showComingSoonDialog('Help & FAQ');
  }

  void _navigateToAbout() {
    _showAboutDialog();
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
            ),
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Coming Soon'),
        content: Text('$feature will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('About Smart Tourist Safety'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text(
              'A comprehensive safety monitoring and incident response system for tourists.',
            ),
            SizedBox(height: 8),
            Text('Features:'),
            Text('• Real-time safety monitoring'),
            Text('• Emergency response system'),
            Text('• Geo-fencing alerts'),
            Text('• Multi-language support'),
            Text('• Accessibility features'),
          ],
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

  void _performLogout() {
    // TODO: Implement actual logout logic
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
