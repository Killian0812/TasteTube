import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// ignore: library_prefixes
import 'package:logger/logger.dart' as L;
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:taste_tube/global_bloc/getstream/getstream_cubit.dart';
import 'package:taste_tube/injection.dart';
import 'package:taste_tube/storage.dart';

class FCMService {
  static String fcmToken = '';

  static Future<void> initialSetup() async {
    final result = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );
    getIt<L.Logger>()
        .i("FCMService permission result: ${result.authorizationStatus}");

    fcmToken = await FirebaseMessaging.instance.getToken(
            vapidKey:
                "BAUMYof6QKNUTMu3gTaO3VT-7QBQt9ZA1kfZDmiVhgzd9G_LJ7AOXqTKwGhXI2pBmgdGavVG4FhX33AzFO242mA") ??
        '';
  }

  static Future<FlutterLocalNotificationsPlugin>
      setupLocalNotifications() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    return flutterLocalNotificationsPlugin;
  }

  // Send current fcmToken to server.
  static Future<void> updateFcmToken() async {
    if (fcmToken.isEmpty) return;
    final http = getIt<Dio>();
    try {
      await http.post(
        '/fcm/update-token',
        data: {
          'platform': kIsWeb ? 'web' : defaultTargetPlatform.name,
          'token': fcmToken,
        },
      );
      getIt<L.Logger>().i("Updated FCM Token $fcmToken");
    } catch (e) {
      getIt<L.Logger>().e("Error updating FCM token: $e");
    }
  }

  static Future<void> updateStreamFcmToken() async {
    if (fcmToken.isEmpty || kIsWeb) return;
    try {
      await streamClient.addDevice(fcmToken, PushProvider.firebase);
      getIt<L.Logger>().i("Updated Stream FCM Token $fcmToken");
    } catch (e) {
      getIt<L.Logger>().e("Error updating Stream FCM token: $e");
    }
  }

  @pragma('vm:entry-point')
  static Future<void> onBackgroundMessage(RemoteMessage message) async {
    final chatClient = StreamChatClient("cd5kkff8cewb");
    final streamData = await Future.wait([
      getIt<LocalStorage>().getValue("STREAM_USERID"),
      getIt<LocalStorage>().getValue("STREAM_TOKEN")
    ]);
    if (streamData[0] == null || streamData[1] == null) {
      await chatClient.connectUser(
        User(id: streamData[0]!),
        streamData[1]!,
        connectWebSocket: false,
      );
    }
    handleNotification(message, chatClient);
  }

  static void handleNotification(
    RemoteMessage message,
    StreamChatClient chatClient,
  ) async {
    final data = message.data;
    if (data['type'] == 'message.new') {
      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          await setupLocalNotifications();
      final messageId = data['id'];
      final response = await streamClient.getMessage(messageId);
      flutterLocalNotificationsPlugin.show(
        1,
        'New message from ${response.message.user!.name}',
        response.message.text,
        const NotificationDetails(
            android: AndroidNotificationDetails(
          'new_message',
          'New message notifications channel',
        )),
      );
    }
  }

  static Future<void> setupInteractedMessage(BuildContext context) async {
    // Handle interaction when the app is in background
    FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);

    // Handle interaction when the app is in foreground
    FirebaseMessaging.onMessage.listen(
      (message) => handleNotification(
        message,
        streamClient,
      ),
    );

    FirebaseMessaging.instance.onTokenRefresh.listen(
      // Fired at each app startup and whenever a new token is generated.
      (newToken) {
        updateFcmToken();
        updateStreamFcmToken();
      },
    ).onError(
      (err) {
        getIt<L.Logger>().e("Error retrieving FCM token: $err");
      },
    );
  }
}
