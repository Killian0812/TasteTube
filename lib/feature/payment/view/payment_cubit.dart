import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/feature/payment/domain/payment_repo.dart';
import 'package:taste_tube/global_bloc/socket/socket_provider.dart';
import 'package:taste_tube/injection.dart';

abstract class PaymentState {}

class PaymentInitial extends PaymentState {
  PaymentInitial() : super();
}

class PaymentLoading extends PaymentState {
  PaymentLoading() : super();
}

class PaymentUrlReady extends PaymentState {
  final String url;

  PaymentUrlReady(this.url) : super();
}

class PaymentUrlError extends PaymentState {
  final String error;

  PaymentUrlError(this.error) : super();
}

class PaymentFailed extends PaymentState {
  final String error;

  PaymentFailed(this.error) : super();
}

class PaymentSuccess extends PaymentState {
  PaymentSuccess() : super();
}

class PaymentCubit extends Cubit<PaymentState> {
  final PaymentRepository repository = getIt<PaymentRepository>();
  final SocketProvider socketProvider = getIt<SocketProvider>();

  PaymentCubit() : super(PaymentInitial()) {
    socketProvider.addListener(_onSocketEvent);
  }

  Future<void> createPayment(double amount, String currency) async {
    emit(PaymentLoading());
    try {
      final result = await repository.getPaymentUrl(amount, currency);
      result.fold(
        (error) =>
            emit(PaymentUrlError(error.message ?? 'Error creating new order')),
        (url) {
          emit(PaymentUrlReady(url));
        },
      );
    } catch (e) {
      emit(PaymentUrlError(e.toString()));
    }
  }

  void _onSocketEvent() {
    final event = socketProvider.event;
    if (event.name != 'payment') return;
    if (event.payload['status'] == 'failed') {
      emit(PaymentFailed(event.payload['message']));
      return;
    }
    emit(PaymentFailed(event.payload['message']));
  }

  @override
  Future<void> close() {
    socketProvider.removeListener(_onSocketEvent);
    return super.close();
  }
}
