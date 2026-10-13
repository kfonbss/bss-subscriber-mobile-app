import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kfon_subscriber/core/routes/app_routes.dart';
import 'package:kfon_subscriber/core/routes/navigator_key.dart';

/// Runs in its own isolate when a message arrives while the app is in the
/// background or terminated. The system shows the notification itself.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'Notifications',
    description: 'General app notifications',
    importance: Importance.high,
  );

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  /// Latest FCM token, available after [init].
  String? fcmToken;

  Future<void> init() async {
    final messaging = FirebaseMessaging.instance;

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await messaging.requestPermission(alert: true, badge: true, sound: true);

    // iOS shows foreground notifications itself when these are enabled.
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    await _local.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (_) => _openNotifications(),
    );
    await _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    FirebaseMessaging.onMessage.listen(_showForeground);
    FirebaseMessaging.onMessageOpenedApp.listen((_) => _openNotifications());

    final initial = await messaging.getInitialMessage();
    if (initial != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _openNotifications(),
      );
    }

    fcmToken = await _readToken(messaging);
    debugPrint('FCM token: $fcmToken');
    messaging.onTokenRefresh.listen((token) {
      fcmToken = token;
      debugPrint('FCM token refreshed: $token');
    });
  }

  Future<String?> _readToken(FirebaseMessaging messaging) async {
    try {
      if (Platform.isIOS) {
        // The APNs token must exist before the FCM token can be issued.
        await messaging.getAPNSToken();
      }
      return await messaging.getToken();
    } catch (e) {
      debugPrint('FCM token unavailable: $e');
      return null;
    }
  }

  Future<void> _showForeground(RemoteMessage message) async {
    final notification = message.notification;
    // iOS already presents it; only Android needs a local notification.
    if (notification == null || !Platform.isAndroid) return;
    await _local.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  void _openNotifications() {
    navigatorKey.currentState?.pushNamed(AppRoutes.notificationPage);
  }
}
