import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> initialize() async {
    // Request permission for iOS
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Get the token
      String? token = await _messaging.getToken();
      if (token != null) {
        await _saveTokenToDatabase(token);
      }

      // Listen for token refreshes
      _messaging.onTokenRefresh.listen(_saveTokenToDatabase);
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  Future<void> _saveTokenToDatabase(String token) async {
    // This will be called when user is logged in to save their FCM token
    // For now, we just print it - in production, save to user's profile
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // Handle notification when app is in foreground
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    // Handle notification tap when app was in background
  }

  Future<void> saveUserToken(String userId, String token) async {
    await _db.collection('users').doc(userId).update({
      'fcmToken': token,
      'tokenUpdatedAt': DateTime.now().toUtc(),
    });
  }

  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  // Subscribe to ride topic for notifications
  Future<void> subscribeToRide(String rideId) async {
    await _messaging.subscribeToTopic('ride_$rideId');
  }

  // Unsubscribe from ride topic
  Future<void> unsubscribeFromRide(String rideId) async {
    await _messaging.unsubscribeFromTopic('ride_$rideId');
  }
}
