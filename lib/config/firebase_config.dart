// Firebase Configuration and Initialization

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class FirebaseConfig {
  static FirebaseApp? _app;
  static FirebaseAuth? _auth;
  static FirebaseFirestore? _firestore;
  static FirebaseMessaging? _messaging;
  static FirebaseAnalytics? _analytics;

  // Google Maps API Configuration
  static const String googleMapsApiKey =
      "AIzaSyBwYP-T4OrdoXoaOBMtEA1nzlm0R6wSiXY";
  static const String googleMapsProjectId = "safetourgit-91468817";

  // Firebase configuration options
  static const FirebaseOptions _firebaseOptions = FirebaseOptions(
    apiKey: 'AIzaSyBwYP-T4OrdoXoaOBMtEA1nzlm0R6wSiXY',
    appId: '1:91468817:web:abcdef123456789012345678',
    messagingSenderId: '91468817',
    projectId: 'safetourgit-91468817',
    authDomain: 'safetourgit-91468817.firebaseapp.com',
    storageBucket: 'safetourgit-91468817.appspot.com',
    measurementId: 'G-SAFETOURGIT',
  );

  /// Initialize Firebase services
  static Future<void> initialize() async {
    try {
      // Initialize Firebase app
      _app = await Firebase.initializeApp(options: _firebaseOptions);

      // Initialize Firebase services
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _messaging = FirebaseMessaging.instance;
      _analytics = FirebaseAnalytics.instance;

      // Configure Firestore settings
      await _configureFirestore();

      // Setup Firebase Messaging
      await _setupMessaging();

      // Setup Analytics
      await _setupAnalytics();

      print('Firebase initialized successfully');
    } catch (e) {
      print('Firebase initialization error: $e');
      rethrow;
    }
  }

  /// Configure Firestore settings
  static Future<void> _configureFirestore() async {
    if (_firestore != null) {
      // Enable offline persistence
      await _firestore!.enablePersistence();

      // Configure settings
      _firestore!.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    }
  }

  /// Setup Firebase Cloud Messaging
  static Future<void> _setupMessaging() async {
    if (_messaging != null) {
      // Request permission for notifications
      NotificationSettings settings = await _messaging!.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted permission for notifications');
      } else {
        print('User declined or has not accepted permission for notifications');
      }

      // Get FCM token
      String? token = await _messaging!.getToken();
      print('FCM Token: $token');

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Received foreground message: ${message.notification?.title}');
        // Handle foreground notification
      });

      // Handle notification taps
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('Notification tapped: ${message.notification?.title}');
        // Handle notification tap
      });
    }
  }

  /// Setup Firebase Analytics
  static Future<void> _setupAnalytics() async {
    if (_analytics != null) {
      await _analytics!.setAnalyticsCollectionEnabled(true);
      await _analytics!.logAppOpen();
    }
  }

  /// Background message handler
  static Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    await Firebase.initializeApp(options: _firebaseOptions);
    print('Handling background message: ${message.messageId}');
  }

  // Getters for Firebase services
  static FirebaseApp? get app => _app;
  static FirebaseAuth get auth => _auth!;
  static FirebaseFirestore get firestore => _firestore!;
  static FirebaseMessaging get messaging => _messaging!;
  static FirebaseAnalytics get analytics => _analytics!;

  /// Check if Firebase is initialized
  static bool get isInitialized => _app != null;

  /// Get current user
  static User? get currentUser => _auth?.currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  /// Sign out current user
  static Future<void> signOut() async {
    await _auth?.signOut();
  }

  /// Delete user account
  static Future<void> deleteAccount() async {
    final user = currentUser;
    if (user != null) {
      await user.delete();
    }
  }

  /// Update user profile
  static Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    final user = currentUser;
    if (user != null) {
      await user.updateDisplayName(displayName);
      await user.updatePhotoURL(photoURL);
    }
  }

  /// Send email verification
  static Future<void> sendEmailVerification() async {
    final user = currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  /// Send password reset email
  static Future<void> sendPasswordResetEmail(String email) async {
    await _auth?.sendPasswordResetEmail(email: email);
  }

  /// Log analytics event
  static Future<void> logEvent(
    String name,
    Map<String, Object>? parameters,
  ) async {
    await _analytics?.logEvent(name: name, parameters: parameters);
  }

  /// Set user properties for analytics
  static Future<void> setUserProperties(Map<String, String> properties) async {
    for (final entry in properties.entries) {
      await _analytics?.setUserProperty(name: entry.key, value: entry.value);
    }
  }

  /// Get FCM token
  static Future<String?> getFCMToken() async {
    return await _messaging?.getToken();
  }

  /// Subscribe to FCM topic
  static Future<void> subscribeToTopic(String topic) async {
    await _messaging?.subscribeToTopic(topic);
  }

  /// Unsubscribe from FCM topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging?.unsubscribeFromTopic(topic);
  }
}

/// Firebase Collections and Document References
class FirebaseCollections {
  static const String users = 'users';
  static const String trips = 'trips';
  static const String alerts = 'alerts';
  static const String locations = 'locations';
  static const String emergencyContacts = 'emergency_contacts';
  static const String digitalIds = 'digital_ids';
  static const String blockchainTransactions = 'blockchain_transactions';
  static const String consentRecords = 'consent_records';
  static const String auditTrails = 'audit_trails';
  static const String geoFences = 'geo_fences';
  static const String notifications = 'notifications';
  static const String analytics = 'analytics';

  /// Get user document reference
  static DocumentReference getUserDoc(String userId) {
    return FirebaseConfig.firestore.collection(users).doc(userId);
  }

  /// Get user trips collection reference
  static CollectionReference getUserTrips(String userId) {
    return getUserDoc(userId).collection(trips);
  }

  /// Get user alerts collection reference
  static CollectionReference getUserAlerts(String userId) {
    return getUserDoc(userId).collection(alerts);
  }

  /// Get user locations collection reference
  static CollectionReference getUserLocations(String userId) {
    return getUserDoc(userId).collection(locations);
  }

  /// Get user emergency contacts collection reference
  static CollectionReference getUserEmergencyContacts(String userId) {
    return getUserDoc(userId).collection(emergencyContacts);
  }

  /// Get user digital ID document reference
  static DocumentReference getUserDigitalId(String userId) {
    return FirebaseConfig.firestore.collection(digitalIds).doc(userId);
  }

  /// Get global geo-fences collection reference
  static CollectionReference getGeoFences() {
    return FirebaseConfig.firestore.collection(geoFences);
  }

  /// Get global notifications collection reference
  static CollectionReference getNotifications() {
    return FirebaseConfig.firestore.collection(notifications);
  }
}

/// Firebase Error Handling
class FirebaseErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email address.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        case 'email-already-in-use':
          return 'An account already exists with this email address.';
        case 'weak-password':
          return 'Password is too weak. Please choose a stronger password.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'user-disabled':
          return 'This account has been disabled. Please contact support.';
        case 'too-many-requests':
          return 'Too many failed attempts. Please try again later.';
        case 'operation-not-allowed':
          return 'This operation is not allowed. Please contact support.';
        default:
          return 'Authentication error: ${error.message}';
      }
    } else if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'You do not have permission to perform this action.';
        case 'unavailable':
          return 'Service is currently unavailable. Please try again later.';
        case 'deadline-exceeded':
          return 'Request timed out. Please check your connection and try again.';
        case 'not-found':
          return 'The requested data was not found.';
        case 'already-exists':
          return 'The data already exists.';
        default:
          return 'Firebase error: ${error.message}';
      }
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }
}
