part of 'realtime_provider.dart';

abstract class RealtimeEvent {
  final String name;

  const RealtimeEvent(this.name);
}

class BasicRealtimeEvent extends RealtimeEvent {
  const BasicRealtimeEvent(super.name);
}

class PaymentRealtimeEvent extends RealtimeEvent {
  final String? status;
  final String? pid;

  const PaymentRealtimeEvent(super.name, {this.status, this.pid});
}
