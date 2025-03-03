part of 'socket_provider.dart';

abstract class SocketEvent {
  final String name;

  const SocketEvent(this.name);
}

class BasicSocketEvent extends SocketEvent {
  const BasicSocketEvent(super.name);
}

class PaymentSocketEvent extends SocketEvent {
  final String? status;
  final String? pid;

  const PaymentSocketEvent(super.name, {this.status, this.pid});
}
