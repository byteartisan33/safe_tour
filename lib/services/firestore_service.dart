// Firestore Database Service

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/firebase_config.dart';
import '../models/user_models.dart';
import '../models/blockchain_models.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseConfig.firestore;

  /// User Profile Operations
  
  /// Save user profile data
  Future<void> saveUserProfile(String userId, UserData userData) async {
    try {
      await FirebaseCollections.getUserDoc(userId).set({
        ...userData.toJson(),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Save user profile error: $e');
      rethrow;
    }
  }

  /// Get user profile data
  Future<UserData?> getUserProfile(String userId) async {
    try {
      final doc = await FirebaseCollections.getUserDoc(userId).get();
      if (doc.exists) {
        return UserData.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Get user profile error: $e');
      return null;
    }
  }

  /// Stream user profile data
  Stream<UserData?> streamUserProfile(String userId) {
    return FirebaseCollections.getUserDoc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return UserData.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  /// Trip Management Operations

  /// Save trip data
  Future<String> saveTrip(String userId, TripDetails tripDetails) async {
    try {
      final docRef = await FirebaseCollections.getUserTrips(userId).add({
        ...tripDetails.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      print('Save trip error: $e');
      rethrow;
    }
  }

  /// Update trip data
  Future<void> updateTrip(String userId, String tripId, TripDetails tripDetails) async {
    try {
      await FirebaseCollections.getUserTrips(userId).doc(tripId).update({
        ...tripDetails.toJson(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Update trip error: $e');
      rethrow;
    }
  }

  /// Get user trips
  Future<List<TripDetails>> getUserTrips(String userId) async {
    try {
      final snapshot = await FirebaseCollections.getUserTrips(userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return TripDetails.fromJson(data);
      }).toList();
    } catch (e) {
      print('Get user trips error: $e');
      return [];
    }
  }

  /// Stream user trips
  Stream<List<TripDetails>> streamUserTrips(String userId) {
    return FirebaseCollections.getUserTrips(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return TripDetails.fromJson(data);
      }).toList();
    });
  }

  /// Alert Management Operations

  /// Save alert data
  Future<String> saveAlert(String userId, Map<String, dynamic> alertData) async {
    try {
      final docRef = await FirebaseCollections.getUserAlerts(userId).add({
        ...alertData,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });
      return docRef.id;
    } catch (e) {
      print('Save alert error: $e');
      rethrow;
    }
  }

  /// Mark alert as read
  Future<void> markAlertAsRead(String userId, String alertId) async {
    try {
      await FirebaseCollections.getUserAlerts(userId).doc(alertId).update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Mark alert as read error: $e');
      rethrow;
    }
  }

  /// Get user alerts
  Future<List<Map<String, dynamic>>> getUserAlerts(String userId, {int limit = 50}) async {
    try {
      final snapshot = await FirebaseCollections.getUserAlerts(userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Get user alerts error: $e');
      return [];
    }
  }

  /// Stream user alerts
  Stream<List<Map<String, dynamic>>> streamUserAlerts(String userId, {int limit = 50}) {
    return FirebaseCollections.getUserAlerts(userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Location Tracking Operations

  /// Save location data
  Future<void> saveLocation(String userId, Map<String, dynamic> locationData) async {
    try {
      await FirebaseCollections.getUserLocations(userId).add({
        ...locationData,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Save location error: $e');
      rethrow;
    }
  }

  /// Get user location history
  Future<List<Map<String, dynamic>>> getUserLocationHistory(
    String userId, {
    int limit = 100,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = FirebaseCollections.getUserLocations(userId)
          .orderBy('timestamp', descending: true)
          .limit(limit);

      if (startDate != null) {
        query = query.where('timestamp', isGreaterThanOrEqualTo: startDate);
      }
      if (endDate != null) {
        query = query.where('timestamp', isLessThanOrEqualTo: endDate);
      }

      final snapshot = await query.get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Get location history error: $e');
      return [];
    }
  }

  /// Emergency Contacts Operations

  /// Save emergency contact
  Future<String> saveEmergencyContact(String userId, EmergencyContact contact) async {
    try {
      final docRef = await FirebaseCollections.getUserEmergencyContacts(userId).add({
        ...contact.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      print('Save emergency contact error: $e');
      rethrow;
    }
  }

  /// Update emergency contact
  Future<void> updateEmergencyContact(
    String userId,
    String contactId,
    EmergencyContact contact,
  ) async {
    try {
      await FirebaseCollections.getUserEmergencyContacts(userId).doc(contactId).update({
        ...contact.toJson(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Update emergency contact error: $e');
      rethrow;
    }
  }

  /// Delete emergency contact
  Future<void> deleteEmergencyContact(String userId, String contactId) async {
    try {
      await FirebaseCollections.getUserEmergencyContacts(userId).doc(contactId).delete();
    } catch (e) {
      print('Delete emergency contact error: $e');
      rethrow;
    }
  }

  /// Get emergency contacts
  Future<List<EmergencyContact>> getEmergencyContacts(String userId) async {
    try {
      final snapshot = await FirebaseCollections.getUserEmergencyContacts(userId)
          .orderBy('createdAt')
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return EmergencyContact.fromJson(data);
      }).toList();
    } catch (e) {
      print('Get emergency contacts error: $e');
      return [];
    }
  }

  /// Stream emergency contacts
  Stream<List<EmergencyContact>> streamEmergencyContacts(String userId) {
    return FirebaseCollections.getUserEmergencyContacts(userId)
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return EmergencyContact.fromJson(data);
      }).toList();
    });
  }

  /// Digital ID Operations

  /// Save digital tourist ID
  Future<void> saveDigitalId(String userId, DigitalTouristID digitalId) async {
    try {
      await FirebaseCollections.getUserDigitalId(userId).set({
        ...digitalId.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Save digital ID error: $e');
      rethrow;
    }
  }

  /// Get digital tourist ID
  Future<DigitalTouristID?> getDigitalId(String userId) async {
    try {
      final doc = await FirebaseCollections.getUserDigitalId(userId).get();
      if (doc.exists) {
        return DigitalTouristID.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Get digital ID error: $e');
      return null;
    }
  }

  /// Stream digital tourist ID
  Stream<DigitalTouristID?> streamDigitalId(String userId) {
    return FirebaseCollections.getUserDigitalId(userId).snapshots().map((doc) {
      if (doc.exists) {
        return DigitalTouristID.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  /// Geo-fence Operations

  /// Get geo-fences for area
  Future<List<Map<String, dynamic>>> getGeoFences({
    double? latitude,
    double? longitude,
    double? radiusKm,
  }) async {
    try {
      Query query = FirebaseCollections.getGeoFences();
      
      // Add geo-query logic here if needed
      // For now, get all geo-fences
      
      final snapshot = await query.get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Get geo-fences error: $e');
      return [];
    }
  }

  /// Analytics Operations

  /// Save analytics event
  Future<void> saveAnalyticsEvent(String userId, Map<String, dynamic> eventData) async {
    try {
      await _firestore.collection(FirebaseCollections.analytics).add({
        'userId': userId,
        ...eventData,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Save analytics event error: $e');
    }
  }

  /// Batch Operations

  /// Batch write operations
  Future<void> batchWrite(List<BatchOperation> operations) async {
    try {
      final batch = _firestore.batch();
      
      for (final operation in operations) {
        switch (operation.type) {
          case BatchOperationType.set:
            batch.set(operation.reference, operation.data!, SetOptions(merge: true));
            break;
          case BatchOperationType.update:
            batch.update(operation.reference, operation.data!);
            break;
          case BatchOperationType.delete:
            batch.delete(operation.reference);
            break;
        }
      }
      
      await batch.commit();
    } catch (e) {
      print('Batch write error: $e');
      rethrow;
    }
  }
}

/// Batch operation helper classes
class BatchOperation {
  final BatchOperationType type;
  final DocumentReference reference;
  final Map<String, dynamic>? data;

  BatchOperation({
    required this.type,
    required this.reference,
    this.data,
  });
}

enum BatchOperationType { set, update, delete }
