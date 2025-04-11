import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:taste_tube/injection.dart';

class FCMService {
  static String fcmToken = '';

  static Future<void> initialSetup() async {
    final result = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );
    getIt<Logger>()
        .i("FCMService permission result: ${result.authorizationStatus}");

    fcmToken = await FirebaseMessaging.instance.getToken(
            vapidKey:
                "BAUMYof6QKNUTMu3gTaO3VT-7QBQt9ZA1kfZDmiVhgzd9G_LJ7AOXqTKwGhXI2pBmgdGavVG4FhX33AzFO242mA") ??
        '';
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
      getIt<Logger>().i("Updated FCM Token $fcmToken");
    } catch (e) {
      getIt<Logger>().e("Error updating FCM token: $e");
    }
  }

  static Future<void> setupInteractedMessage() async {
    // Get message which caused the application to open from terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Handle interaction when the app is in the background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

    FirebaseMessaging.instance.onTokenRefresh.listen(
      // Fired at each app startup and whenever a new token is generated.
      (newToken) {
        updateFcmToken();
      },
    ).onError(
      (err) {
        getIt<Logger>().e("Error retrieving FCM token: $err");
      },
    );
  }

  static void _handleMessage(RemoteMessage message) {}
}
