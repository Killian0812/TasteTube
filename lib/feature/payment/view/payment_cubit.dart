import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/feature/payment/data/payment_data.dart';
import 'package:taste_tube/feature/payment/domain/payment_repo.dart';
import 'package:taste_tube/global_bloc/socket/socket_provider.dart';
import 'package:taste_tube/injection.dart';

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

class PaymentUrlError extends PaymentState {
  final String error;

  PaymentUrlError(this.error) : super('');
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
  final SocketProvider socketProvider = getIt<SocketProvider>();

  PaymentCubit() : super(PaymentInitial()) {
    socketProvider.addListener(_onSocketEvent);
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
    try {
      final result = await repository.getPaymentUrl(amount, currency);
      result.fold(
        (error) =>
            emit(PaymentUrlError(error.message ?? 'Error creating new order')),
        (payment) {
          emit(PaymentUrlReady(payment.pid, payment.url));
        },
      );
    } catch (e) {
      emit(PaymentUrlError(e.toString()));
    }
  }

  void _onSocketEvent() {
    if (socketProvider.event is! PaymentSocketEvent) return;

    final payload = (socketProvider.event as PaymentSocketEvent);
    if (payload.pid != state.pid) return;

    if (payload.status == 'failed') {
      emit(PaymentFailed(state.pid, "Payment failed"));
      return;
    }
    emit(PaymentSuccess(state.pid));
  }

  @override
  Future<void> close() {
    socketProvider.removeListener(_onSocketEvent);
    return super.close();
  }
}
