import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:taste_tube/global_bloc/auth/auth_bloc.dart';
import 'package:taste_tube/global_bloc/realtime/realtime_provider.dart';
import 'package:taste_tube/core/injection.dart';

// Map to track unique payment events using pid as the key
final Map<String?, PaymentRealtimeEvent> _paymentEvents = {};
final Logger logger = getIt<Logger>();

mixin PaymentRealtimeService on ChangeNotifier {
  void handlePaymentEvent(dynamic data, Function(RealtimeEvent) setEvent) {
    logger.i('Payment socket event received: $data');
    final newPaymentEvent = PaymentRealtimeEvent(
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

mixin UserBannedRealtimeService on ChangeNotifier {
  void handleUserBan(
      Map<String, String> data, Function(RealtimeEvent) setEvent) {
    final createdAt = DateTime.parse(data['createdAt'] as String);
    if (DateTime.now().difference(createdAt) >= const Duration(minutes: 1)) {
      return;
    }
    logger.i('User banned socket event received: $data');
    getIt<AuthBloc>().add(LogoutEvent());
  }
}
