// Firebase Cloud Functions for Smart Tourist Safety App

const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { GeoPoint } = require('firebase-admin/firestore');

// Initialize Firebase Admin SDK
admin.initializeApp();
const db = admin.firestore();
const messaging = admin.messaging();

// Geo-fencing and Safety Alert Functions

/**
 * Monitor user location and trigger geo-fence alerts
 */
exports.monitorGeoFences = functions.firestore
  .document('users/{userId}/locations/{locationId}')
  .onCreate(async (snap, context) => {
    const { userId } = context.params;
    const locationData = snap.data();
    
    try {
      // Get user's current location
      const userLat = locationData.latitude;
      const userLng = locationData.longitude;
      
      // Get all active geo-fences
      const geoFencesSnapshot = await db.collection('geo_fences')
        .where('isActive', '==', true)
        .get();
      
      const alerts = [];
      
      // Check each geo-fence
      for (const geoFenceDoc of geoFencesSnapshot.docs) {
        const geoFence = geoFenceDoc.data();
        const distance = calculateDistance(
          userLat, userLng,
          geoFence.center.latitude, geoFence.center.longitude
        );
        
        // Check if user entered a restricted zone
        if (distance <= geoFence.radius && geoFence.type === 'restricted') {
          alerts.push({
            type: 'geo_fence_alert',
            severity: 'high',
            title: 'Restricted Area Alert',
            message: `You have entered a restricted area: ${geoFence.name}`,
            location: { latitude: userLat, longitude: userLng },
            geoFenceId: geoFenceDoc.id,
            timestamp: admin.firestore.FieldValue.serverTimestamp()
          });
        }
        
        // Check if user entered a high-risk zone
        if (distance <= geoFence.radius && geoFence.type === 'high_risk') {
          alerts.push({
            type: 'geo_fence_alert',
            severity: 'medium',
            title: 'High-Risk Area Alert',
            message: `Caution: You are in a high-risk area: ${geoFence.name}`,
            location: { latitude: userLat, longitude: userLng },
            geoFenceId: geoFenceDoc.id,
            timestamp: admin.firestore.FieldValue.serverTimestamp()
          });
        }
      }
      
      // Save alerts and send notifications
      for (const alert of alerts) {
        await saveAlertAndNotify(userId, alert);
      }
      
    } catch (error) {
      console.error('Geo-fence monitoring error:', error);
    }
  });

/**
 * Handle emergency panic button activation
 */
exports.handlePanicButton = functions.firestore
  .document('users/{userId}/alerts/{alertId}')
  .onCreate(async (snap, context) => {
    const { userId } = context.params;
    const alertData = snap.data();
    
    if (alertData.type !== 'panic_button') return;
    
    try {
      // Get user profile for emergency contacts
      const userDoc = await db.collection('users').doc(userId).get();
      const userData = userDoc.data();
      
      // Get emergency contacts
      const emergencyContactsSnapshot = await db.collection('users')
        .doc(userId)
        .collection('emergency_contacts')
        .get();
      
      const emergencyContacts = emergencyContactsSnapshot.docs.map(doc => doc.data());
      
      // Send notifications to emergency contacts
      const notificationPromises = emergencyContacts.map(contact => 
        sendEmergencyNotification(contact, userData, alertData)
      );
      
      // Send notification to local authorities (mock implementation)
      notificationPromises.push(
        notifyLocalAuthorities(userData, alertData)
      );
      
      await Promise.all(notificationPromises);
      
      // Update alert status
      await snap.ref.update({
        status: 'notified',
        notifiedAt: admin.firestore.FieldValue.serverTimestamp()
      });
      
    } catch (error) {
      console.error('Panic button handling error:', error);
    }
  });

/**
 * Calculate safety score based on user behavior and location
 */
exports.calculateSafetyScore = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }
  
  const { userId } = data;
  
  try {
    let score = 100; // Start with perfect score
    
    // Get user's recent alerts
    const alertsSnapshot = await db.collection('users')
      .doc(userId)
      .collection('alerts')
      .where('timestamp', '>=', new Date(Date.now() - 7 * 24 * 60 * 60 * 1000)) // Last 7 days
      .get();
    
    // Deduct points for alerts
    alertsSnapshot.docs.forEach(doc => {
      const alert = doc.data();
      switch (alert.severity) {
        case 'high':
          score -= 15;
          break;
        case 'medium':
          score -= 10;
          break;
        case 'low':
          score -= 5;
          break;
      }
    });
    
    // Get user's location history
    const locationsSnapshot = await db.collection('users')
      .doc(userId)
      .collection('locations')
      .orderBy('timestamp', 'desc')
      .limit(10)
      .get();
    
    // Check if user frequently visits safe areas
    let safeAreaVisits = 0;
    for (const locationDoc of locationsSnapshot.docs) {
      const location = locationDoc.data();
      const isInSafeArea = await checkIfInSafeArea(location.latitude, location.longitude);
      if (isInSafeArea) safeAreaVisits++;
    }
    
    // Bonus points for staying in safe areas
    if (safeAreaVisits >= 8) score += 5;
    else if (safeAreaVisits >= 5) score += 2;
    
    // Ensure score is between 0 and 100
    score = Math.max(0, Math.min(100, score));
    
    return { safetyScore: score };
    
  } catch (error) {
    console.error('Safety score calculation error:', error);
    throw new functions.https.HttpsError('internal', 'Failed to calculate safety score');
  }
});

/**
 * Send push notifications for various events
 */
exports.sendNotification = functions.firestore
  .document('notifications/{notificationId}')
  .onCreate(async (snap, context) => {
    const notification = snap.data();
    
    try {
      // Get user's FCM token
      const userDoc = await db.collection('users').doc(notification.userId).get();
      const userData = userDoc.data();
      
      if (!userData.fcmToken) {
        console.log('No FCM token for user:', notification.userId);
        return;
      }
      
      // Prepare notification payload
      const payload = {
        token: userData.fcmToken,
        notification: {
          title: notification.title,
          body: notification.body,
        },
        data: notification.data || {},
        android: {
          priority: notification.priority === 'high' ? 'high' : 'normal',
          notification: {
            channelId: getChannelId(notification.type),
            priority: notification.priority === 'high' ? 'high' : 'default',
          }
        },
        apns: {
          payload: {
            aps: {
              alert: {
                title: notification.title,
                body: notification.body,
              },
              badge: 1,
              sound: 'default',
            }
          }
        }
      };
      
      // Send notification
      const response = await messaging.send(payload);
      console.log('Notification sent successfully:', response);
      
      // Update notification status
      await snap.ref.update({
        status: 'sent',
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
        messageId: response
      });
      
    } catch (error) {
      console.error('Send notification error:', error);
      
      // Update notification status
      await snap.ref.update({
        status: 'failed',
        error: error.message,
        failedAt: admin.firestore.FieldValue.serverTimestamp()
      });
    }
  });

/**
 * Validate and process digital tourist ID
 */
exports.processDigitalId = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }
  
  const { userId, personalInfo, documents } = data;
  
  try {
    // Validate required documents
    const requiredDocs = ['passport', 'visa'];
    const providedDocs = Object.keys(documents);
    const missingDocs = requiredDocs.filter(doc => !providedDocs.includes(doc));
    
    if (missingDocs.length > 0) {
      throw new functions.https.HttpsError('invalid-argument', 
        `Missing required documents: ${missingDocs.join(', ')}`);
    }
    
    // Generate blockchain address (mock implementation)
    const blockchainAddress = generateBlockchainAddress(userId);
    
    // Create digital ID
    const digitalId = {
      id: `did_${userId}_${Date.now()}`,
      userId: userId,
      blockchainAddress: blockchainAddress,
      personalInfo: personalInfo,
      documents: documents,
      status: 'pending_verification',
      issuedAt: admin.firestore.FieldValue.serverTimestamp(),
      expiresAt: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000), // 1 year
      auditTrail: [{
        action: 'Digital ID Created',
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        details: 'Digital Tourist ID created and submitted for verification',
        transactionHash: generateTransactionHash(),
        blockNumber: Math.floor(Math.random() * 1000000)
      }]
    };
    
    // Save digital ID
    await db.collection('digital_ids').doc(userId).set(digitalId);
    
    return { digitalId: digitalId };
    
  } catch (error) {
    console.error('Digital ID processing error:', error);
    throw new functions.https.HttpsError('internal', 'Failed to process digital ID');
  }
});

/**
 * Clean up old location data
 */
exports.cleanupOldData = functions.pubsub.schedule('every 24 hours').onRun(async (context) => {
  const cutoffDate = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000); // 30 days ago
  
  try {
    // Clean up old location data
    const usersSnapshot = await db.collection('users').get();
    
    for (const userDoc of usersSnapshot.docs) {
      const oldLocationsSnapshot = await db.collection('users')
        .doc(userDoc.id)
        .collection('locations')
        .where('timestamp', '<', cutoffDate)
        .get();
      
      const batch = db.batch();
      oldLocationsSnapshot.docs.forEach(doc => {
        batch.delete(doc.ref);
      });
      
      if (oldLocationsSnapshot.docs.length > 0) {
        await batch.commit();
        console.log(`Cleaned up ${oldLocationsSnapshot.docs.length} old locations for user ${userDoc.id}`);
      }
    }
    
    // Clean up old notifications
    const oldNotificationsSnapshot = await db.collection('notifications')
      .where('createdAt', '<', cutoffDate)
      .get();
    
    const notificationBatch = db.batch();
    oldNotificationsSnapshot.docs.forEach(doc => {
      notificationBatch.delete(doc.ref);
    });
    
    if (oldNotificationsSnapshot.docs.length > 0) {
      await notificationBatch.commit();
      console.log(`Cleaned up ${oldNotificationsSnapshot.docs.length} old notifications`);
    }
    
  } catch (error) {
    console.error('Data cleanup error:', error);
  }
});

// Helper Functions

function calculateDistance(lat1, lng1, lat2, lng2) {
  const R = 6371; // Earth's radius in kilometers
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLng = (lng2 - lng1) * Math.PI / 180;
  const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
    Math.sin(dLng / 2) * Math.sin(dLng / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

async function saveAlertAndNotify(userId, alertData) {
  // Save alert to user's alerts collection
  await db.collection('users').doc(userId).collection('alerts').add(alertData);
  
  // Create notification
  await db.collection('notifications').add({
    userId: userId,
    type: alertData.type,
    title: alertData.title,
    body: alertData.message,
    data: {
      alertType: alertData.type,
      severity: alertData.severity,
      location: JSON.stringify(alertData.location)
    },
    priority: alertData.severity === 'high' ? 'high' : 'normal',
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    status: 'pending'
  });
}

async function sendEmergencyNotification(contact, userData, alertData) {
  // This would integrate with SMS/email services
  console.log(`Sending emergency notification to ${contact.name} (${contact.phone})`);
  
  // Mock implementation - in production, integrate with Twilio, SendGrid, etc.
  return Promise.resolve();
}

async function notifyLocalAuthorities(userData, alertData) {
  // This would integrate with local emergency services APIs
  console.log('Notifying local authorities of emergency');
  
  // Mock implementation
  return Promise.resolve();
}

async function checkIfInSafeArea(latitude, longitude) {
  // Check if location is in a designated safe area
  const safeAreasSnapshot = await db.collection('geo_fences')
    .where('type', '==', 'safe')
    .where('isActive', '==', true)
    .get();
  
  for (const safeAreaDoc of safeAreasSnapshot.docs) {
    const safeArea = safeAreaDoc.data();
    const distance = calculateDistance(
      latitude, longitude,
      safeArea.center.latitude, safeArea.center.longitude
    );
    
    if (distance <= safeArea.radius) {
      return true;
    }
  }
  
  return false;
}

function getChannelId(notificationType) {
  switch (notificationType) {
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

function generateBlockchainAddress(userId) {
  // Mock blockchain address generation
  const timestamp = Date.now();
  const hash = require('crypto').createHash('sha256').update(`${userId}_${timestamp}`).digest('hex');
  return `0x${hash.substring(0, 40)}`;
}

function generateTransactionHash() {
  // Mock transaction hash generation
  const timestamp = Date.now();
  const random = Math.random().toString(36).substring(2);
  return require('crypto').createHash('sha256').update(`${timestamp}_${random}`).digest('hex');
}
