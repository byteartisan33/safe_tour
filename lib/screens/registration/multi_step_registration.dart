import 'package:flutter/material.dart';
import '../../models/user_models.dart';
import '../dashboard/home_dashboard.dart';
import 'steps/personal_info_step.dart';
import 'steps/kyc_documents_step.dart';
import 'steps/trip_details_step.dart';
import 'steps/emergency_contacts_step.dart';
import 'steps/health_info_step.dart';
import 'steps/credentials_step.dart';

class MultiStepRegistrationScreen extends StatefulWidget {
  final String selectedLanguage;

  const MultiStepRegistrationScreen({
    super.key,
    required this.selectedLanguage,
  });

  @override
  State<MultiStepRegistrationScreen> createState() =>
      _MultiStepRegistrationScreenState();
}

class _MultiStepRegistrationScreenState
    extends State<MultiStepRegistrationScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 6;

  // Registration data
  PersonalInformation? _personalInfo;
  KYCDocuments? _kycDocuments;
  TripDetails? _tripDetails;
  List<EmergencyContact> _emergencyContacts = [];
  HealthInformation? _healthInfo;
  UserCredentials? _credentials;

  final List<String> _stepTitles = [
    'Personal Information',
    'KYC Documents',
    'Trip Details',
    'Emergency Contacts',
    'Health Information',
    'Account Setup',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Tourist Registration',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Progress Indicator
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[700],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Step ${_currentStep + 1} of $_totalSteps',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                SizedBox(height: 8),
                Text(
                  _stepTitles[_currentStep],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                LinearProgressIndicator(
                  value: (_currentStep + 1) / _totalSteps,
                  backgroundColor: Colors.blue[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 4,
                ),
              ],
            ),
          ),

          // Step Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                PersonalInfoStep(
                  initialData: _personalInfo,
                  onDataChanged: (data) => _personalInfo = data,
                ),
                KYCDocumentsStep(
                  initialData: _kycDocuments,
                  onDataChanged: (data) => _kycDocuments = data,
                ),
                TripDetailsStep(
                  initialData: _tripDetails,
                  onDataChanged: (data) => _tripDetails = data,
                ),
                EmergencyContactsStep(
                  initialData: _emergencyContacts,
                  onDataChanged: (data) => _emergencyContacts = data,
                ),
                HealthInfoStep(
                  initialData: _healthInfo,
                  onDataChanged: (data) => _healthInfo = data,
                ),
                CredentialsStep(
                  initialData: _credentials,
                  onDataChanged: (data) => _credentials = data,
                ),
              ],
            ),
          ),

          // Navigation Buttons
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.blue[700]!),
                      ),
                      child: Text(
                        'Previous',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                if (_currentStep > 0) SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _currentStep < _totalSteps - 1
                        ? _nextStep
                        : _completeRegistration,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      _currentStep < _totalSteps - 1
                          ? 'Next'
                          : 'Complete Registration',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_validateCurrentStep()) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    setState(() {
      _currentStep--;
    });
    _pageController.previousPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _personalInfo != null;
      case 1:
        return _kycDocuments != null;
      case 2:
        return _tripDetails != null;
      case 3:
        return _emergencyContacts.isNotEmpty;
      case 4:
        return _healthInfo != null;
      case 5:
        return _credentials != null;
      default:
        return false;
    }
  }

  void _completeRegistration() {
    if (_validateCurrentStep()) {
      final registrationData = UserRegistrationData(
        personalInfo: _personalInfo!,
        kycDocuments: _kycDocuments!,
        tripDetails: _tripDetails!,
        emergencyContacts: _emergencyContacts,
        healthInfo: _healthInfo!,
        credentials: _credentials!,
        selectedLanguage: widget.selectedLanguage,
        registrationDate: DateTime.now(),
      );

      // TODO: Save registration data to backend/blockchain
      _showRegistrationSuccess(registrationData);
    }
  }

  void _showRegistrationSuccess(UserRegistrationData registrationData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Text('Registration Successful!'),
          ],
        ),
        content: Text(
          'Your tourist registration has been completed successfully. Welcome to Smart Tourist Safety!',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              // Navigate directly to dashboard
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => HomeDashboard(
                    userData: registrationData,
                    selectedLanguage: widget.selectedLanguage,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text(
              'Continue to Dashboard',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
