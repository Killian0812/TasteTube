import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:taste_tube/api.dart';
import 'package:taste_tube/build_config.dart';
import 'package:taste_tube/global_bloc/realtime/realtime_service.dart';
import 'package:taste_tube/injection.dart';

part 'realtime_event.dart';

class RealtimeProvider extends ChangeNotifier with PaymentRealtimeService {
  Socket? _socket;
  final Logger logger = getIt<Logger>();
  RealtimeEvent event = BasicRealtimeEvent('init');

  // Firebase Realtime Database as a fallback for socket connection
  final FirebaseDatabase rtdb = FirebaseDatabase.instanceFor(
      app: getIt<FirebaseApp>(),
      databaseURL:
          "https://taste-tube-default-rtdb.asia-southeast1.firebasedatabase.app");
  DatabaseReference? _paymentRef;

  bool get isConnected => _socket != null && _socket!.connected;

  void setEvent(RealtimeEvent newEvent) {
    event = newEvent;
    notifyListeners();
  }

  // Disconnect current socket connection
  void disconnectSocket() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket = null;
      event = BasicRealtimeEvent('disconnected');
      notifyListeners();
      logger.i('Socket manually disconnected');
    }
    _paymentRef?.onDisconnect();
    _paymentRef = null;
  }

  void initSocket(String userId) {
    // Initialize Socket.IO
    if (BuildConfig.environment != 'vercel') {
      // Vercel serverless function does not support Socket.IO
      _initSocketIO(userId);
    }

    // Initialize Firebase Realtime Database
    _initFirebase(userId);
  }

  // Socket.IO initialization
  void _initSocketIO(String userId) {
    if (isConnected) {
      logger.w('Socket already connected, disconnecting before reconnecting');
      disconnectSocket();
    }

    try {
      final socket = io(
        Api.baseUrl,
        OptionBuilder()
            .setTransports(['websocket']).setQuery({'userId': userId}).build(),
      );

      socket.onConnect((_) {
        logger.i('Socket connected: ${socket.id}');
        event = BasicRealtimeEvent('connected');
        notifyListeners();
      });

      socket.onDisconnect((_) {
        logger.i('Socket disconnected');
        event = BasicRealtimeEvent('disconnected');
        notifyListeners();
      });

      _setupEventListeners(socket);

      socket.connect();
      _socket = socket;
      notifyListeners();
    } catch (e) {
      logger.e('Error initializing socket: ${e.toString()}');
      event = BasicRealtimeEvent('error');
      notifyListeners();
    }
  }

  // Firebase initialization
  void _initFirebase(String userId) {
    try {
      _paymentRef = rtdb.ref().child('users').child(userId).child('payments');

      bool isFirstFetch = true;

      _paymentRef!.onValue.listen((event) {
        final snapshot = event.snapshot;
        if (isFirstFetch) {
          isFirstFetch = false;
          return;
        }
        if (snapshot.exists) {
          final data = snapshot.value as Map<dynamic, dynamic>;
          data.forEach((key, value) {
            if (value is Map) {
              handlePaymentEvent(value, setEvent);
            }
          });
        }
      }, onError: (error) {
        logger.e('Firebase error: $error');
        event = BasicRealtimeEvent('error');
        notifyListeners();
      });

      logger.i('Firebase Realtime Database initialized for user: $userId');
    } catch (e) {
      logger.e('Error initializing Firebase: $e');
      event = BasicRealtimeEvent('error');
      notifyListeners();
    }
  }

  // Event listeners for Socket.IO events
  void _setupEventListeners(Socket socket) {
    socket.on(
      'payment',
      (data) => handlePaymentEvent(data, setEvent),
    );
  }

  void emitEvent(String event, dynamic data) {
    if (isConnected) {
      _socket?.emit(event, data);
      notifyListeners();
    } else {
      logger.w('Unable to emit event, socket not connected');
      // Fallback to Firebase if socket is not connected
      if (_paymentRef != null) {
        _paymentRef!.child('emittedEvents').push().set({
          'event': event,
          'data': data,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
      }
    }
  }

  @override
  void dispose() {
    disconnectSocket();
    super.dispose();
  }
}
