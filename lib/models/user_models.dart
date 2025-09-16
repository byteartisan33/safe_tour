// Data models for user registration and profile information

class PersonalInformation {
  final String fullName;
  final String gender;
  final DateTime dateOfBirth;
  final String nationality;
  final String documentType; // 'passport' or 'aadhaar'
  final String documentNumber;
  final String? documentExpiryDate;
  final String? documentImagePath;

  PersonalInformation({
    required this.fullName,
    required this.gender,
    required this.dateOfBirth,
    required this.nationality,
    required this.documentType,
    required this.documentNumber,
    this.documentExpiryDate,
    this.documentImagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'gender': gender,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'nationality': nationality,
      'documentType': documentType,
      'documentNumber': documentNumber,
      'documentExpiryDate': documentExpiryDate,
      'documentImagePath': documentImagePath,
    };
  }

  factory PersonalInformation.fromJson(Map<String, dynamic> json) {
    return PersonalInformation(
      fullName: json['fullName'],
      gender: json['gender'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      nationality: json['nationality'],
      documentType: json['documentType'],
      documentNumber: json['documentNumber'],
      documentExpiryDate: json['documentExpiryDate'],
      documentImagePath: json['documentImagePath'],
    );
  }
}

class KYCDocuments {
  final String? passportImagePath;
  final String? aadhaarFrontPath;
  final String? aadhaarBackPath;
  final bool isVerified;

  KYCDocuments({
    this.passportImagePath,
    this.aadhaarFrontPath,
    this.aadhaarBackPath,
    this.isVerified = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'passportImagePath': passportImagePath,
      'aadhaarFrontPath': aadhaarFrontPath,
      'aadhaarBackPath': aadhaarBackPath,
      'isVerified': isVerified,
    };
  }

  factory KYCDocuments.fromJson(Map<String, dynamic> json) {
    return KYCDocuments(
      passportImagePath: json['passportImagePath'],
      aadhaarFrontPath: json['aadhaarFrontPath'],
      aadhaarBackPath: json['aadhaarBackPath'],
      isVerified: json['isVerified'] ?? false,
    );
  }
}

class TripDetails {
  final String entryPoint;
  final DateTime tripStartDate;
  final DateTime tripEndDate;
  final String detailedItinerary;
  final List<String> placesToVisit;

  TripDetails({
    required this.entryPoint,
    required this.tripStartDate,
    required this.tripEndDate,
    required this.detailedItinerary,
    required this.placesToVisit,
  });

  Map<String, dynamic> toJson() {
    return {
      'entryPoint': entryPoint,
      'tripStartDate': tripStartDate.toIso8601String(),
      'tripEndDate': tripEndDate.toIso8601String(),
      'detailedItinerary': detailedItinerary,
      'placesToVisit': placesToVisit,
    };
  }

  factory TripDetails.fromJson(Map<String, dynamic> json) {
    return TripDetails(
      entryPoint: json['entryPoint'],
      tripStartDate: DateTime.parse(json['tripStartDate']),
      tripEndDate: DateTime.parse(json['tripEndDate']),
      detailedItinerary: json['detailedItinerary'],
      placesToVisit: List<String>.from(json['placesToVisit'] ?? []),
    );
  }
}

class EmergencyContact {
  final String name;
  final String relationship;
  final String phoneNumber;
  final String? email;
  final bool isPrimary;

  EmergencyContact({
    required this.name,
    required this.relationship,
    required this.phoneNumber,
    this.email,
    required this.isPrimary,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'relationship': relationship,
      'phoneNumber': phoneNumber,
      'email': email,
      'isPrimary': isPrimary,
    };
  }

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name'],
      relationship: json['relationship'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      isPrimary: json['isPrimary'] ?? false,
    );
  }
}

class HealthInformation {
  final String? bloodGroup;
  final List<String> medicalConditions;
  final List<String> allergies;
  final List<String> medications;
  final String? emergencyMedicalInfo;

  HealthInformation({
    this.bloodGroup,
    this.medicalConditions = const [],
    this.allergies = const [],
    this.medications = const [],
    this.emergencyMedicalInfo,
  });

  Map<String, dynamic> toJson() {
    return {
      'bloodGroup': bloodGroup,
      'medicalConditions': medicalConditions,
      'allergies': allergies,
      'medications': medications,
      'emergencyMedicalInfo': emergencyMedicalInfo,
    };
  }

  factory HealthInformation.fromJson(Map<String, dynamic> json) {
    return HealthInformation(
      bloodGroup: json['bloodGroup'],
      medicalConditions: List<String>.from(json['medicalConditions'] ?? []),
      allergies: List<String>.from(json['allergies'] ?? []),
      medications: List<String>.from(json['medications'] ?? []),
      emergencyMedicalInfo: json['emergencyMedicalInfo'],
    );
  }
}

class UserCredentials {
  final String email;
  final String password;
  final bool acceptedTerms;
  final bool acceptedPrivacyPolicy;
  final bool acceptedBlockchainConsent;

  UserCredentials({
    required this.email,
    required this.password,
    required this.acceptedTerms,
    required this.acceptedPrivacyPolicy,
    required this.acceptedBlockchainConsent,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password, // In real app, this should be hashed
      'acceptedTerms': acceptedTerms,
      'acceptedPrivacyPolicy': acceptedPrivacyPolicy,
      'acceptedBlockchainConsent': acceptedBlockchainConsent,
    };
  }

  factory UserCredentials.fromJson(Map<String, dynamic> json) {
    return UserCredentials(
      email: json['email'],
      password: json['password'],
      acceptedTerms: json['acceptedTerms'] ?? false,
      acceptedPrivacyPolicy: json['acceptedPrivacyPolicy'] ?? false,
      acceptedBlockchainConsent: json['acceptedBlockchainConsent'] ?? false,
    );
  }
}

class UserRegistrationData {
  final PersonalInformation personalInfo;
  final KYCDocuments kycDocuments;
  final TripDetails tripDetails;
  final List<EmergencyContact> emergencyContacts;
  final HealthInformation healthInfo;
  final UserCredentials credentials;
  final String selectedLanguage;
  final DateTime registrationDate;

  UserRegistrationData({
    required this.personalInfo,
    required this.kycDocuments,
    required this.tripDetails,
    required this.emergencyContacts,
    required this.healthInfo,
    required this.credentials,
    required this.selectedLanguage,
    required this.registrationDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'personalInfo': personalInfo.toJson(),
      'kycDocuments': kycDocuments.toJson(),
      'tripDetails': tripDetails.toJson(),
      'emergencyContacts': emergencyContacts.map((e) => e.toJson()).toList(),
      'healthInfo': healthInfo.toJson(),
      'credentials': credentials.toJson(),
      'selectedLanguage': selectedLanguage,
      'registrationDate': registrationDate.toIso8601String(),
    };
  }

  factory UserRegistrationData.fromJson(Map<String, dynamic> json) {
    return UserRegistrationData(
      personalInfo: PersonalInformation.fromJson(json['personalInfo']),
      kycDocuments: KYCDocuments.fromJson(json['kycDocuments']),
      tripDetails: TripDetails.fromJson(json['tripDetails']),
      emergencyContacts: (json['emergencyContacts'] as List)
          .map((e) => EmergencyContact.fromJson(e))
          .toList(),
      healthInfo: HealthInformation.fromJson(json['healthInfo']),
      credentials: UserCredentials.fromJson(json['credentials']),
      selectedLanguage: json['selectedLanguage'],
      registrationDate: DateTime.parse(json['registrationDate']),
    );
  }

  UserRegistrationData copyWith({
    PersonalInformation? personalInfo,
    KYCDocuments? kycDocuments,
    TripDetails? tripDetails,
    List<EmergencyContact>? emergencyContacts,
    HealthInformation? healthInfo,
    UserCredentials? credentials,
    String? selectedLanguage,
    DateTime? registrationDate,
  }) {
    return UserRegistrationData(
      personalInfo: personalInfo ?? this.personalInfo,
      kycDocuments: kycDocuments ?? this.kycDocuments,
      tripDetails: tripDetails ?? this.tripDetails,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
      healthInfo: healthInfo ?? this.healthInfo,
      credentials: credentials ?? this.credentials,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      registrationDate: registrationDate ?? this.registrationDate,
    );
  }
}

// Alias for UserRegistrationData for Firebase services
typedef UserData = UserRegistrationData;
