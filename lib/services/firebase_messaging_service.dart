// Firebase Cloud Messaging Service

import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import '../config/firebase_config.dart';
import '../services/firestore_service.dart';

class FirebaseMessagingService {
  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;
  FirebaseMessagingService._internal();

  final FirebaseMessaging _messaging = FirebaseConfig.messaging;
  final FirestoreService _firestoreService = FirestoreService();
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Stream controllers for notifications
  final StreamController<RemoteMessage> _messageController =
      StreamController<RemoteMessage>.broadcast();
  final StreamController<String> _tokenController =
      StreamController<String>.broadcast();

  Stream<RemoteMessage> get messageStream => _messageController.stream;
  Stream<String> get tokenStream => _tokenController.stream;

  String? _currentToken;
  String? _currentUserId;
  bool _isInitialized = false;

  String? get currentToken => _currentToken;
  bool get isInitialized => _isInitialized;

  /// Initialize Firebase Cloud Messaging
  Future<void> initialize(String userId) async {
    if (_isInitialized && _currentUserId == userId) return;

    _currentUserId = userId;

    try {
      // Initialize local notifications
      await _initializeLocalNotifications();

      // Request notification permissions
      await _requestPermissions();

      // Get FCM token
      await _getFCMToken();

      // Setup message handlers
      _setupMessageHandlers();

      // Subscribe to user-specific topics
      await _subscribeToUserTopics(userId);

      _isInitialized = true;
      print('Firebase Messaging initialized for user: $userId');
    } catch (e) {
      print('Firebase Messaging initialization error: $e');
      throw e;
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels for Android
    await _createNotificationChannels();
  }

  /// Create notification channels for different types of notifications
  Future<void> _createNotificationChannels() async {
    const channels = [
      AndroidNotificationChannel(
        'emergency_alerts',
        'Emergency Alerts',
        description: 'Critical emergency notifications',
        importance: Importance.max,
        enableVibration: true,
        enableLights: true,
        ledColor: Colors.red,
      ),
      AndroidNotificationChannel(
        'geo_fence_alerts',
        'Geo-fence Alerts',
        description: 'Location-based safety alerts',
        importance: Importance.high,
        enableVibration: true,
      ),
      AndroidNotificationChannel(
        'trip_updates',
        'Trip Updates',
        description: 'Trip and itinerary notifications',
        importance: Importance.defaultImportance,
      ),
      AndroidNotificationChannel(
        'general_notifications',
        'General Notifications',
        description: 'General app notifications',
        importance: Importance.defaultImportance,
      ),
    ];

    for (final channel in channels) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);
    }
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted notification permissions');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional notification permissions');
    } else {
      print('User declined notification permissions');
    }
  }

  /// Get FCM token
  Future<void> _getFCMToken() async {
    try {
      _currentToken = await _messaging.getToken();
      if (_currentToken != null) {
        print('FCM Token: $_currentToken');
        _tokenController.add(_currentToken!);

        // Save token to Firestore for server-side messaging
        if (_currentUserId != null) {
          await _saveTokenToFirestore(_currentUserId!, _currentToken!);
        }
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        _currentToken = newToken;
        _tokenController.add(newToken);

        if (_currentUserId != null) {
          _saveTokenToFirestore(_currentUserId!, newToken);
        }
      });
    } catch (e) {
      print('FCM token error: $e');
    }
  }

  /// Save FCM token to Firestore
  Future<void> _saveTokenToFirestore(String userId, String token) async {
    try {
      await FirebaseCollections.getUserDoc(userId).update({
        'fcmToken': token,
        'tokenUpdatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Save FCM token error: $e');
    }
  }

  /// Setup message handlers
  void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received foreground message: ${message.notification?.title}');
      _messageController.add(message);
      _showLocalNotification(message);
    });

    // Handle background message taps
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message opened app: ${message.notification?.title}');
      _messageController.add(message);
      _handleNotificationTap(message);
    });

    // Handle initial message when app is opened from terminated state
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print(
          'App opened from terminated state: ${message.notification?.title}',
        );
        _messageController.add(message);
        _handleNotificationTap(message);
      }
    });
  }

  /// Show local notification for foreground messages
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;

    if (notification != null) {
      final channelId = _getChannelId(data['type'] ?? 'general');

      final androidDetails = AndroidNotificationDetails(
        channelId,
        _getChannelName(channelId),
        channelDescription: _getChannelDescription(channelId),
        importance: _getImportance(channelId),
        priority: _getPriority(channelId),
        icon: '@mipmap/ic_launcher',
        color: _getNotificationColor(channelId),
        enableVibration: true,
        enableLights: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        message.hashCode,
        notification.title,
        notification.body,
        details,
        payload: jsonEncode(message.data),
      );
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      final data = jsonDecode(response.payload!);
      final message = RemoteMessage(
        messageId: data['messageId'] ?? '',
        data: Map<String, String>.from(data),
      );
      _handleNotificationTap(message);
    }
  }

  /// Handle notification tap navigation
  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    final type = data['type'];

    switch (type) {
      case 'emergency_alert':
        // Navigate to emergency screen
        _navigateToScreen('/emergency');
        break;
      case 'geo_fence_alert':
        // Navigate to alerts screen
        _navigateToScreen('/alerts');
        break;
      case 'trip_update':
        // Navigate to trip details
        _navigateToScreen('/trip/${data['tripId']}');
        break;
      case 'panic_response':
        // Navigate to panic button screen
        _navigateToScreen('/panic');
        break;
      default:
        // Navigate to home
        _navigateToScreen('/home');
    }
  }

  /// Navigate to screen (placeholder - implement with your navigation system)
  void _navigateToScreen(String route) {
    // TODO: Implement navigation based on your app's navigation system
    print('Navigate to: $route');
  }

  /// Subscribe to user-specific topics
  Future<void> _subscribeToUserTopics(String userId) async {
    try {
      // Subscribe to user-specific topic
      await _messaging.subscribeToTopic('user_$userId');

      // Subscribe to general topics
      await _messaging.subscribeToTopic('all_users');
      await _messaging.subscribeToTopic('safety_alerts');

      print('Subscribed to FCM topics for user: $userId');
    } catch (e) {
      print('Topic subscription error: $e');
    }
  }

  /// Unsubscribe from user-specific topics
  Future<void> _unsubscribeFromUserTopics(String userId) async {
    try {
      await _messaging.unsubscribeFromTopic('user_$userId');
      await _messaging.unsubscribeFromTopic('all_users');
      await _messaging.unsubscribeFromTopic('safety_alerts');

      print('Unsubscribed from FCM topics for user: $userId');
    } catch (e) {
      print('Topic unsubscription error: $e');
    }
  }

  /// Send emergency alert notification
  Future<void> sendEmergencyAlert({
    required String userId,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    try {
      // Save notification to Firestore for server-side sending
      await FirebaseCollections.getNotifications().add({
        'userId': userId,
        'type': 'emergency_alert',
        'title': title,
        'body': body,
        'data': data ?? {},
        'priority': 'high',
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
    } catch (e) {
      print('Send emergency alert error: $e');
    }
  }

  /// Send geo-fence alert notification
  Future<void> sendGeoFenceAlert({
    required String userId,
    required String title,
    required String body,
    required Map<String, String> locationData,
  }) async {
    try {
      await FirebaseCollections.getNotifications().add({
        'userId': userId,
        'type': 'geo_fence_alert',
        'title': title,
        'body': body,
        'data': locationData,
        'priority': 'high',
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
    } catch (e) {
      print('Send geo-fence alert error: $e');
    }
  }

  /// Send trip update notification
  Future<void> sendTripUpdate({
    required String userId,
    required String title,
    required String body,
    required String tripId,
  }) async {
    try {
      await FirebaseCollections.getNotifications().add({
        'userId': userId,
        'type': 'trip_update',
        'title': title,
        'body': body,
        'data': {'tripId': tripId},
        'priority': 'normal',
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
    } catch (e) {
      print('Send trip update error: $e');
    }
  }

  /// Helper methods for notification channels
  String _getChannelId(String type) {
    switch (type) {
      case 'emergency_alert':
      case 'panic_response':
        return 'emergency_alerts';
      case 'geo_fence_alert':
        return 'geo_fence_alerts';
      case 'trip_update':
        return 'trip_updates';
      default:
        return 'general_notifications';
    }
  }

  String _getChannelName(String channelId) {
    switch (channelId) {
      case 'emergency_alerts':
        return 'Emergency Alerts';
      case 'geo_fence_alerts':
        return 'Geo-fence Alerts';
      case 'trip_updates':
        return 'Trip Updates';
      default:
        return 'General Notifications';
    }
  }

  String _getChannelDescription(String channelId) {
    switch (channelId) {
      case 'emergency_alerts':
        return 'Critical emergency notifications';
      case 'geo_fence_alerts':
        return 'Location-based safety alerts';
      case 'trip_updates':
        return 'Trip and itinerary notifications';
      default:
        return 'General app notifications';
    }
  }

  Importance _getImportance(String channelId) {
    switch (channelId) {
      case 'emergency_alerts':
        return Importance.max;
      case 'geo_fence_alerts':
        return Importance.high;
      default:
        return Importance.defaultImportance;
    }
  }

  Priority _getPriority(String channelId) {
    switch (channelId) {
      case 'emergency_alerts':
      case 'geo_fence_alerts':
        return Priority.high;
      default:
        return Priority.defaultPriority;
    }
  }

  Color _getNotificationColor(String channelId) {
    switch (channelId) {
      case 'emergency_alerts':
        return Colors.red;
      case 'geo_fence_alerts':
        return Colors.orange;
      case 'trip_updates':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  /// Stop messaging service
  Future<void> stop() async {
    if (_currentUserId != null) {
      await _unsubscribeFromUserTopics(_currentUserId!);
    }
    _currentUserId = null;
    _isInitialized = false;
  }

  /// Dispose resources
  void dispose() {
    stop();
    _messageController.close();
    _tokenController.close();
  }
}
