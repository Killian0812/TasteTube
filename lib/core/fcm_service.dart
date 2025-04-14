import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
// ignore: library_prefixes
import 'package:logger/logger.dart' as L;
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:taste_tube/global_bloc/getstream/getstream_cubit.dart';
import 'package:taste_tube/core/injection.dart';
import 'package:taste_tube/core/local_notification.dart';
import 'package:taste_tube/main.dart';

class FCMService {
  static String fcmToken = '';

  static Future<void> setupFirebaseMessaging() async {
    final result = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    getIt<L.Logger>()
        .i("FCMService permission result: ${result.authorizationStatus}");

    fcmToken = await FirebaseMessaging.instance.getToken(
            vapidKey:
                "BAUMYof6QKNUTMu3gTaO3VT-7QBQt9ZA1kfZDmiVhgzd9G_LJ7AOXqTKwGhXI2pBmgdGavVG4FhX33AzFO242mA") ??
        '';

    setupInteractedMessage();
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

  static void setupInteractedMessage() {
    // Handle interaction when the app is in background
    // FirebaseMessaging.onBackgroundMessage();

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (message.data['type'] == 'chat' &&
          navigatorKey.currentContext?.mounted == true) {
        navigatorKey.currentContext?.push('/chat');
      }
      if (message.data['type'] == 'order' &&
          navigatorKey.currentContext?.mounted == true) {
        navigatorKey.currentContext?.push('/store');
      }
    });

    // Handle interaction when the app is in foreground
    FirebaseMessaging.onMessage.listen(
      (message) => LocalNotification.handleNotification(message),
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
