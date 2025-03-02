import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:taste_tube/injection.dart';

part 'socket_event.dart';

class SocketProvider extends ChangeNotifier {
  Socket? _socket;
  final Logger logger = getIt<Logger>();
  SocketEvent event = SocketEvent('init');

  void disconnectSocket() {
    _socket?.disconnect();
    notifyListeners();
  }

  void initSocket(String userId) {
    try {
      _socket?.disconnect();

      final socket = io(
          'https://first-shepherd-legible.ngrok-free.app',
          OptionBuilder().setTransports(['websocket']).setQuery(
            {'userId': userId},
          ).build());

      socket.onConnect((_) {
        logger.i('Socket connected');
        event = SocketEvent('connected');
        notifyListeners();
      });

      socket.on('payment', (data) {
        logger.i('Socket event received');
        event = SocketEvent('payment', payload: data);
        notifyListeners();
      });

      socket.onDisconnect((_) {
        logger.i('Socket disconnected');
        event = SocketEvent('disconnected');
        notifyListeners();
      });

      socket.connect();

      _socket = socket;
      notifyListeners();
    } catch (e) {
      logger.e(e.toString());
      notifyListeners();
    }
  }

  void emitEvent(String event, dynamic data) {
    _socket?.emit(event, data);
    notifyListeners();
  }

  @override
  void dispose() {
    _socket?.dispose();
    super.dispose();
  }
}
