import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'api_service.dart';
import '../firebase_options.dart';
import '../main.dart';
import '../screens/detail_screen.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static VoidCallback? onNotificationReceived;

  static Future<void> initialize() async {
    try {
      print("🚀 NotificationService: Initializing...");

      // 1. Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      final messaging = FirebaseMessaging.instance;

      // 2. Request permissions
      await messaging.requestPermission(alert: true, badge: true, sound: true);

      // 3. Setup Local Notifications
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings();
      const initSettings = InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      );

      await _localNotifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (details) {
          print("🖱️ Notification Clicked in Foreground/Background: ${details.payload}");
          if (details.payload != null) {
            _handleNotificationPayload(details.payload!);
          }
        },
      );

      // 4. Create Android Notification Channel
      if (!kIsWeb) {
        const channel = AndroidNotificationChannel(
          'high_importance_channel',
          'High Importance Notifications',
          description: 'This channel is used for important notifications.',
          importance: Importance.max,
        );

        await _localNotifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(channel);
        
        print("📺 Android Channel Created");
      }

      // 4. Handle background messages
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // 5. Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _showLocalNotification(message);
        onNotificationReceived?.call();
      });

      // 6. Handle notification click (Background/Killed)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handleMessage(message);
      });

      // 7. Handle initial message (Killed state)
      messaging.getInitialMessage().then((message) {
        if (message != null) {
          _handleMessage(message);
        }
      });

      // 8. Get and sync token
      syncToken();
    } catch (e) {
      debugPrint('NotificationService Initialization Error: $e');
    }
  }

  static Future<void> syncToken() async {
    if (!ApiService.isLoggedIn) return;

    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await ApiService.updateFcmToken(token);
        debugPrint('FCM Token Synced: $token');
      }
    } catch (e) {
      debugPrint('Error syncing FCM token: $e');
    }
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;

    if (notification != null && !kIsWeb) {
      const channelId = 'high_importance_channel';
      const channelName = 'High Importance Notifications';
      
      // Create payload from data
      final String payload = jsonEncode(message.data);

      await _localNotifications.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: payload,
      );
    }
  }

  static void _handleMessage(RemoteMessage message) {
    handleNotificationData(message.data);
  }

  static Future<void> _handleNotificationPayload(String payload) async {
    try {
      final data = jsonDecode(payload);
      if (data is Map<String, dynamic>) {
        handleNotificationData(data);
      }
    } catch (e) {
      debugPrint('Error handling notification payload: $e');
    }
  }

  static Future<void> handleNotificationData(Map<String, dynamic> data) async {
    try {
      debugPrint('🔔 Handling Notification Data: $data');
      
      // If it's a database notification, the real data might be nested in a 'data' key
      Map<String, dynamic> actualData = data;
      if (data.containsKey('data') && data['data'] is Map) {
        actualData = Map<String, dynamic>.from(data['data']);
      }

      final type = actualData['type']?.toString() ?? data['type']?.toString();
      final instIdStr = actualData['institution_id']?.toString() ?? data['institution_id']?.toString();

      if (type == 'post' && instIdStr != null) {
        final instId = int.tryParse(instIdStr);
        if (instId != null) {
          final institution = await ApiService.getInstitution(instId);
          if (institution != null) {
            int retries = 0;
            while (XwendngakanApp.navigatorKey.currentState == null && retries < 15) {
              await Future.delayed(const Duration(milliseconds: 500));
              retries++;
            }

            final state = XwendngakanApp.navigatorKey.currentState;
            if (state != null) {
              state.push(
                MaterialPageRoute(
                  builder: (_) => DetailScreen(
                    institution: institution,
                    initialTab: 1, 
                  ),
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error handling notification data: $e');
    }
  }
}

// Global background handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");
}
