part of 'socket_provider.dart';

class SocketEvent {
  final String name;
  final dynamic payload;

  SocketEvent(this.name, {this.payload});
}
