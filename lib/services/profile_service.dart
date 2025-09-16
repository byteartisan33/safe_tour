import 'dart:async';
import '../models/user_models.dart';

class ProfileService {
  static ProfileService? _instance;
  static ProfileService get instance => _instance ??= ProfileService._();
  ProfileService._();

  // In-memory storage for demo purposes
  static UserRegistrationData? _currentUserProfile;
  static final StreamController<UserRegistrationData?> _profileController =
      StreamController<UserRegistrationData?>.broadcast();

  // Stream for profile updates
  static Stream<UserRegistrationData?> get profileStream =>
      _profileController.stream;

  // Initialize with sample data
  static Future<void> initialize() async {
    if (_currentUserProfile == null) {
      _currentUserProfile = _createSampleUserData();
      _profileController.add(_currentUserProfile);
    }
  }

  // Get current user profile
  static Future<UserRegistrationData?> getCurrentUserProfile() async {
    await initialize();
    return _currentUserProfile;
  }

  // Update user profile
  static Future<bool> updateUserProfile(UserRegistrationData userData) async {
    try {
      _currentUserProfile = userData;
      _profileController.add(_currentUserProfile);

      // In a real app, this would save to backend/local storage
      await _saveToStorage(userData);

      return true;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }

  // Update personal information
  static Future<bool> updatePersonalInformation(
    PersonalInformation personalInfo,
  ) async {
    if (_currentUserProfile != null) {
      final updatedProfile = _currentUserProfile!.copyWith(
        personalInfo: personalInfo,
      );
      return await updateUserProfile(updatedProfile);
    }
    return false;
  }

  // Update trip details
  static Future<bool> updateTripDetails(TripDetails tripDetails) async {
    if (_currentUserProfile != null) {
      final updatedProfile = _currentUserProfile!.copyWith(
        tripDetails: tripDetails,
      );
      return await updateUserProfile(updatedProfile);
    }
    return false;
  }

  // Update emergency contacts
  static Future<bool> updateEmergencyContacts(
    List<EmergencyContact> contacts,
  ) async {
    if (_currentUserProfile != null) {
      final updatedProfile = _currentUserProfile!.copyWith(
        emergencyContacts: contacts,
      );
      return await updateUserProfile(updatedProfile);
    }
    return false;
  }

  // Update health information
  static Future<bool> updateHealthInformation(
    HealthInformation healthInfo,
  ) async {
    if (_currentUserProfile != null) {
      final updatedProfile = _currentUserProfile!.copyWith(
        healthInfo: healthInfo,
      );
      return await updateUserProfile(updatedProfile);
    }
    return false;
  }

  // Get profile statistics
  static Map<String, dynamic> getProfileStatistics() {
    if (_currentUserProfile == null) return {};

    final tripDays =
        _currentUserProfile!.tripDetails.tripEndDate
            .difference(_currentUserProfile!.tripDetails.tripStartDate)
            .inDays +
        1;

    return {
      'tripDays': tripDays,
      'emergencyContacts': _currentUserProfile!.emergencyContacts.length,
      'placesToVisit': _currentUserProfile!.tripDetails.placesToVisit.length,
      'registrationDate': _currentUserProfile!.registrationDate,
      'isProfileComplete': _isProfileComplete(),
    };
  }

  // Check if profile is complete
  static bool _isProfileComplete() {
    if (_currentUserProfile == null) return false;

    final profile = _currentUserProfile!;
    return profile.personalInfo.fullName.isNotEmpty &&
        profile.personalInfo.nationality.isNotEmpty &&
        profile.emergencyContacts.isNotEmpty &&
        profile.tripDetails.placesToVisit.isNotEmpty;
  }

  // Save to storage (mock implementation)
  static Future<void> _saveToStorage(UserRegistrationData userData) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500));

    // In a real app, this would save to:
    // - Local storage (SharedPreferences, SQLite)
    // - Backend API
    // - Cloud storage

    print('Profile saved successfully');
  }

  // Create sample user data for demo
  static UserRegistrationData _createSampleUserData() {
    return UserRegistrationData(
      personalInfo: PersonalInformation(
        fullName: 'John Smith',
        gender: 'Male',
        dateOfBirth: DateTime(1990, 5, 15),
        nationality: 'United States',
        documentType: 'Passport',
        documentNumber: 'US123456789',
        documentExpiryDate: '2028-05-15',
      ),
      kycDocuments: KYCDocuments(
        passportImagePath: 'assets/sample_passport.jpg',
        isVerified: true,
      ),
      tripDetails: TripDetails(
        entryPoint: 'Delhi International Airport',
        tripStartDate: DateTime.now().add(Duration(days: 1)),
        tripEndDate: DateTime.now().add(Duration(days: 15)),
        detailedItinerary: 'Visiting Golden Triangle: Delhi, Agra, Jaipur',
        placesToVisit: [
          'Red Fort, Delhi',
          'Taj Mahal, Agra',
          'Hawa Mahal, Jaipur',
          'India Gate, Delhi',
          'Amber Fort, Jaipur',
        ],
      ),
      emergencyContacts: [
        EmergencyContact(
          name: 'Sarah Smith',
          relationship: 'Spouse',
          phoneNumber: '+1-555-0123',
          email: 'sarah.smith@email.com',
          isPrimary: true,
        ),
        EmergencyContact(
          name: 'Robert Smith',
          relationship: 'Father',
          phoneNumber: '+1-555-0124',
          email: 'robert.smith@email.com',
          isPrimary: false,
        ),
      ],
      healthInfo: HealthInformation(
        bloodGroup: 'O+',
        medicalConditions: ['None'],
        allergies: ['Peanuts'],
        medications: ['None'],
        emergencyMedicalInfo: 'No major medical conditions',
      ),
      credentials: UserCredentials(
        email: 'john.smith@email.com',
        password: 'hashedPassword123',
        acceptedTerms: true,
        acceptedPrivacyPolicy: true,
        acceptedBlockchainConsent: true,
      ),
      selectedLanguage: 'English',
      registrationDate: DateTime.now().subtract(Duration(days: 30)),
    );
  }

  // Clear profile data (for logout)
  static Future<void> clearProfile() async {
    _currentUserProfile = null;
    _profileController.add(null);
  }

  // Dispose resources
  static void dispose() {
    _profileController.close();
  }
}
