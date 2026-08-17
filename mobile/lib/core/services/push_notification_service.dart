import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/utils/logger.dart';

// Top-level background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  logger.i('Handling a background message: ${message.messageId}');
}

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final ApiClient _apiClient;

  PushNotificationService(this._apiClient);

  Future<void> init() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permissions
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      logger.i('User granted push notification permission');
      
      // Get the token and send it to backend
      String? token = await _fcm.getToken();
      if (token != null) {
        await _sendTokenToBackend(token);
      }

      // Listen for token refreshes
      _fcm.onTokenRefresh.listen(_sendTokenToBackend);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        logger.i('Received foreground message: ${message.notification?.title}');
        _showLocalNotification(message);
      });
    } else {
      logger.w('User declined or has not accepted push notification permissions');
    }
  }

  Future<void> _sendTokenToBackend(String token) async {
    try {
      await _apiClient.dio.put(
        '/v1/users/me/fcm-token',
        data: {'token': token},
      );
      logger.i('Successfully registered FCM token with backend');
    } catch (e) {
      logger.e('Failed to register FCM token with backend: $e');
    }
  }

  void _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'salasel_high_importance_channel',
        'High Importance Notifications',
        importance: Importance.max,
        priority: Priority.high,
      );
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await _localNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        platformChannelSpecifics,
      );
    }
  }
}
