import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socket_io_client/socket_io_client.dart';

class SocketCubit extends Cubit<void> {
  Socket? _socket;

  SocketCubit() : super(null);

  void disconnectSocket() {
    _socket?.disconnect();
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
        print('connect');
      });

      socket.on('event', (data) => print(data));
      socket.onDisconnect((_) {
        print('disconnected');
      });

      socket.connect();

      _socket = socket;
    } catch (e) {
      print(e.toString());
    }
  }

  void emitEvent(String event, dynamic data) {
    _socket?.emit(event, data);
  }

  @override
  Future<void> close() {
    _socket?.dispose();
    return super.close();
  }
}
