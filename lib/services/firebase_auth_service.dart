// Firebase Authentication Service

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/firebase_config.dart';
import '../models/user_models.dart';

class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  final FirebaseAuth _auth = FirebaseConfig.auth;
  final FirebaseFirestore _firestore = FirebaseConfig.firestore;

  // Stream controllers for authentication state
  final StreamController<User?> _authStateController =
      StreamController<User?>.broadcast();
  final StreamController<UserData?> _userDataController =
      StreamController<UserData?>.broadcast();

  Stream<User?> get authStateStream => _authStateController.stream;
  Stream<UserData?> get userDataStream => _userDataController.stream;

  User? get currentUser => _auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  /// Initialize authentication service
  Future<void> initialize() async {
    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) {
      _authStateController.add(user);
      if (user != null) {
        _loadUserData(user.uid);
      } else {
        _userDataController.add(null);
      }
    });

    // Load current user data if authenticated
    if (isAuthenticated) {
      await _loadUserData(currentUser!.uid);
    }
  }

  /// Register new user with email and password
  Future<AuthResult> registerWithEmailPassword({
    required String email,
    required String password,
    required UserData userData,
  }) async {
    try {
      // Create user account
      final UserCredential credential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      final User? user = credential.user;
      if (user != null) {
        // Update user profile
        await user.updateDisplayName(userData.personalInfo.fullName);

        // Save user data to Firestore
        await _saveUserData(user.uid, userData);

        // Send email verification
        await user.sendEmailVerification();

        // Log analytics event
        await FirebaseConfig.logEvent('user_registered', {
          'method': 'email_password',
          'user_id': user.uid,
        });

        return AuthResult.success(user, userData);
      } else {
        return AuthResult.failure('Failed to create user account');
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(FirebaseErrorHandler.getErrorMessage(e));
    } catch (e) {
      return AuthResult.failure('Registration failed: $e');
    }
  }

  /// Sign in with email and password
  Future<AuthResult> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = credential.user;
      if (user != null) {
        // Load user data
        final userData = await _loadUserData(user.uid);

        // Log analytics event
        await FirebaseConfig.logEvent('user_signed_in', {
          'method': 'email_password',
          'user_id': user.uid,
        });

        return AuthResult.success(user, userData);
      } else {
        return AuthResult.failure('Failed to sign in');
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(FirebaseErrorHandler.getErrorMessage(e));
    } catch (e) {
      return AuthResult.failure('Sign in failed: $e');
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();

      // Log analytics event
      await FirebaseConfig.logEvent('user_signed_out', {});
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      print('Password reset error: $e');
      return false;
    }
  }

  /// Update user password
  Future<bool> updatePassword(String newPassword) async {
    try {
      final user = currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
        return true;
      }
      return false;
    } catch (e) {
      print('Password update error: $e');
      return false;
    }
  }

  /// Update user email
  Future<bool> updateEmail(String newEmail) async {
    try {
      final user = currentUser;
      if (user != null) {
        await user.updateEmail(newEmail);
        await user.sendEmailVerification();
        return true;
      }
      return false;
    } catch (e) {
      print('Email update error: $e');
      return false;
    }
  }

  /// Delete user account
  Future<bool> deleteAccount() async {
    try {
      final user = currentUser;
      if (user != null) {
        // Delete user data from Firestore
        await _deleteUserData(user.uid);

        // Delete user account
        await user.delete();

        // Log analytics event
        await FirebaseConfig.logEvent('user_deleted', {'user_id': user.uid});

        return true;
      }
      return false;
    } catch (e) {
      print('Account deletion error: $e');
      return false;
    }
  }

  /// Update user profile data
  Future<bool> updateUserData(UserData userData) async {
    try {
      final user = currentUser;
      if (user != null) {
        await _saveUserData(user.uid, userData);
        _userDataController.add(userData);
        return true;
      }
      return false;
    } catch (e) {
      print('User data update error: $e');
      return false;
    }
  }

  /// Load user data from Firestore
  Future<UserData?> _loadUserData(String userId) async {
    try {
      final doc = await FirebaseCollections.getUserDoc(userId).get();
      if (doc.exists) {
        final userData = UserData.fromJson(doc.data() as Map<String, dynamic>);
        _userDataController.add(userData);
        return userData;
      }
      return null;
    } catch (e) {
      print('Load user data error: $e');
      return null;
    }
  }

  /// Save user data to Firestore
  Future<void> _saveUserData(String userId, UserData userData) async {
    try {
      await FirebaseCollections.getUserDoc(userId).set({
        ...userData.toJson(),
        'lastUpdated': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Save user data error: $e');
      throw e;
    }
  }

  /// Delete user data from Firestore
  Future<void> _deleteUserData(String userId) async {
    try {
      final batch = _firestore.batch();

      // Delete user document
      batch.delete(FirebaseCollections.getUserDoc(userId));

      // Delete user subcollections
      final collections = [
        FirebaseCollections.getUserTrips(userId),
        FirebaseCollections.getUserAlerts(userId),
        FirebaseCollections.getUserLocations(userId),
        FirebaseCollections.getUserEmergencyContacts(userId),
      ];

      for (final collection in collections) {
        final docs = await collection.get();
        for (final doc in docs.docs) {
          batch.delete(doc.reference);
        }
      }

      // Delete digital ID
      batch.delete(FirebaseCollections.getUserDigitalId(userId));

      await batch.commit();
    } catch (e) {
      print('Delete user data error: $e');
      throw e;
    }
  }

  /// Reauthenticate user (required for sensitive operations)
  Future<bool> reauthenticate(String password) async {
    try {
      final user = currentUser;
      if (user != null && user.email != null) {
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
        return true;
      }
      return false;
    } catch (e) {
      print('Reauthentication error: $e');
      return false;
    }
  }

  /// Send email verification
  Future<bool> sendEmailVerification() async {
    try {
      final user = currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        return true;
      }
      return false;
    } catch (e) {
      print('Email verification error: $e');
      return false;
    }
  }

  /// Check if email is verified
  bool get isEmailVerified => currentUser?.emailVerified ?? false;

  /// Reload user to get latest verification status
  Future<void> reloadUser() async {
    await currentUser?.reload();
  }

  /// Dispose resources
  void dispose() {
    _authStateController.close();
    _userDataController.close();
  }
}

/// Authentication result wrapper
class AuthResult {
  final bool isSuccess;
  final String? errorMessage;
  final User? user;
  final UserData? userData;

  AuthResult._({
    required this.isSuccess,
    this.errorMessage,
    this.user,
    this.userData,
  });

  factory AuthResult.success(User user, UserData? userData) {
    return AuthResult._(isSuccess: true, user: user, userData: userData);
  }

  factory AuthResult.failure(String errorMessage) {
    return AuthResult._(isSuccess: false, errorMessage: errorMessage);
  }
}
