import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseService {
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
      (fcmToken) {
        // TODO: Send token to application server.
      },
    ).onError(
      (err) {},
    );
  }

  static void _handleMessage(RemoteMessage message) {}
}
