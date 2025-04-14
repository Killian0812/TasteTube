import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:taste_tube/global_bloc/getstream/getstream_cubit.dart';
import 'package:taste_tube/main.dart';

class LocalNotification {
  // Private static instance & constructor for singleton
  static final LocalNotification _instance = LocalNotification._internal();
  LocalNotification._internal();

  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Factory constructor to return the same instance
  factory LocalNotification() {
    return _instance;
  }

  static FlutterLocalNotificationsPlugin get flutterLocalNotificationsPlugin =>
      _flutterLocalNotificationsPlugin;

  static Future<FlutterLocalNotificationsPlugin>
      setupLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onLocalForegroundMessage,
      onDidReceiveBackgroundNotificationResponse: onLocalBackgroundMessage,
    );
    return _flutterLocalNotificationsPlugin;
  }

  @pragma('vm:entry-point')
  static void onLocalBackgroundMessage(NotificationResponse details) async {}

  static void onLocalForegroundMessage(NotificationResponse details) async {
    if (details.payload == 'chat') {
      navigatorKey.currentContext?.go('/chat');
      return;
    }
    if (details.payload == 'order') {
      navigatorKey.currentContext?.go('/store');
      return;
    }
  }

  static void handleNotification(RemoteMessage message) async {
    final data = message.data;
    if (data['type'] == 'message.new') {
      final messageId = data['id'];
      final response = await streamClient.getMessage(messageId);
      _flutterLocalNotificationsPlugin.show(
        1,
        'New message from ${response.message.user!.name}',
        response.message.text,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'new_message',
            'New message notifications channel',
          ),
        ),
        payload: "chat",
      );
    }
    if (data['type'] == 'order.new') {
      _flutterLocalNotificationsPlugin.show(
        1,
        message.notification?.title,
        message.notification?.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'new_order',
            'New order notifications channel',
          ),
        ),
        payload: "order",
      );
    }
  }
}
