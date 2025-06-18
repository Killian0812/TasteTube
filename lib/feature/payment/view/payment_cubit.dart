import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/feature/payment/data/payment_data.dart';
import 'package:taste_tube/feature/payment/domain/payment_repo.dart';
import 'package:taste_tube/global_bloc/realtime/realtime_provider.dart';
import 'package:taste_tube/core/injection.dart';

abstract class PaymentState {
  final String pid;

  const PaymentState(this.pid);
}

class PaymentInitial extends PaymentState {
  PaymentInitial() : super('');
}

class PaymentLoading extends PaymentState {
  PaymentLoading() : super('');
}

class PaymentUrlReady extends PaymentState {
  final String url;

  PaymentUrlReady(super.pid, this.url);
}

class PaymentError extends PaymentState {
  final String error;

  PaymentError(this.error) : super('');
}

class WaitingCardConfirm extends PaymentState {
  WaitingCardConfirm(super.pid);
}

class PaymentFailed extends PaymentState {
  final String error;

  PaymentFailed(super.pid, this.error);
}

class PaymentSuccess extends PaymentState {
  PaymentSuccess(super.pid);
}

class PaymentCubit extends Cubit<PaymentState> {
  final PaymentRepository repository = getIt<PaymentRepository>();
  final RealtimeProvider realtimeProvider = getIt<RealtimeProvider>();

  PaymentCubit() : super(PaymentInitial()) {
    realtimeProvider.addListener(_onSocketEvent);
  }

  Future<void> createPayment(
    PaymentMethod paymentMethod,
    double amount,
    String currency,
  ) async {
    emit(PaymentLoading());
    if (paymentMethod == PaymentMethod.COD) {
      emit(PaymentSuccess(''));
      return;
    }
    if (paymentMethod == PaymentMethod.CARD) {
      final result = await repository.createCardPayment(amount, currency);
      result.fold(
        (error) =>
            emit(PaymentError(error.message ?? 'Error creating payment')),
        (payment) {
          emit(WaitingCardConfirm(''));
        },
      );
      return;
    }
    try {
      final result = await repository.getPaymentUrl(amount, currency);
      result.fold(
        (error) =>
            emit(PaymentError(error.message ?? 'Error creating payment')),
        (payment) {
          emit(PaymentUrlReady(payment.pid, payment.url));
        },
      );
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }

  Future<void> confirmPayment(String otp) async {
    try {
      final result = await repository.confirmCardPayment(otp);
      result.fold(
        (error) =>
            emit(PaymentError(error.message ?? 'Error confirming payment')),
        (payment) {
          emit(PaymentSuccess(''));
        },
      );
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }

  void _onSocketEvent() {
    if (realtimeProvider.event is! PaymentRealtimeEvent) return;

    final payload = (realtimeProvider.event as PaymentRealtimeEvent);
    if (payload.pid != state.pid) return;

    if (payload.status == 'failed') {
      emit(PaymentFailed(state.pid, "Payment failed"));
      return;
    }
    emit(PaymentSuccess(state.pid));
  }

  @override
  Future<void> close() {
    realtimeProvider.removeListener(_onSocketEvent);
    return super.close();
  }
}
