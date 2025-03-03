import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:taste_tube/global_bloc/socket/socket_provider.dart';
import 'package:taste_tube/injection.dart';

// Map to track unique payment events using pid as the key
final Map<String?, PaymentSocketEvent> _paymentEvents = {};
final Logger logger = getIt<Logger>();

mixin PaymentSocketService on ChangeNotifier {
  void handlePaymentEvent(dynamic data, Function(SocketEvent) setEvent) {
    logger.i('Payment socket event received: $data');
    final newPaymentEvent = PaymentSocketEvent(
      'payment',
      status: data['status'],
      pid: data['pid'],
    );

    // Check duplication
    if (!_paymentEvents.containsKey(newPaymentEvent.pid)) {
      _paymentEvents[newPaymentEvent.pid] = newPaymentEvent;
      setEvent(newPaymentEvent);
    }

    // Reset
    if (_paymentEvents.length > 100) {
      _paymentEvents.clear();
    }
  }
}
