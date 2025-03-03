import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:taste_tube/global_bloc/socket/socket_service.dart';
import 'package:taste_tube/injection.dart';

part 'socket_event.dart';

class SocketProvider extends ChangeNotifier with PaymentSocketService {
  Socket? _socket;
  final Logger logger = getIt<Logger>();
  SocketEvent event = BasicSocketEvent('init');

  bool get isConnected => _socket != null && _socket!.connected;

  void setEvent(SocketEvent newEvent) {
    event = newEvent;
    notifyListeners();
  }

  // Disconnect current socket connection
  void disconnectSocket() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket = null;
      event = BasicSocketEvent('disconnected');
      notifyListeners();
      logger.i('Socket manually disconnected');
    }
  }

  // Initialize the socket connection
  void initSocket(String userId) {
    if (isConnected) {
      logger.w('Socket already connected, disconnecting before reconnecting');
      disconnectSocket();
    }

    try {
      final socket = io(
        'https://first-shepherd-legible.ngrok-free.app',
        OptionBuilder()
            .setTransports(['websocket']).setQuery({'userId': userId}).build(),
      );

      socket.onConnect((_) {
        logger.i('Socket connected: ${socket.id}');
        event = BasicSocketEvent('connected');
        notifyListeners();
      });

      socket.onDisconnect((_) {
        logger.i('Socket disconnected');
        event = BasicSocketEvent('disconnected');
        notifyListeners();
      });

      _setupEventListeners(socket);

      socket.connect();
      _socket = socket;
      notifyListeners();
    } catch (e) {
      logger.e('Error initializing socket: ${e.toString()}');
      event = BasicSocketEvent('error');
      notifyListeners();
    }
  }

  // Event listeners for different events
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
    }
  }

  @override
  void dispose() {
    disconnectSocket();
    super.dispose();
  }
}
