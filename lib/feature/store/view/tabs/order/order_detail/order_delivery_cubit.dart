import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/feature/shop/data/delivery_quote.dart';
import 'package:taste_tube/feature/shop/domain/order_delivery_repo.dart';
import 'package:taste_tube/injection.dart';

abstract class OrderDeliveryState {
  final String orderId;
  final Map<String, DeliveryQuote>? quotes;
  final String? selectedDeliveryType;
  final String? origin;
  final String? destination;

  const OrderDeliveryState({
    required this.orderId,
    this.quotes,
    this.selectedDeliveryType,
    this.origin,
    this.destination,
  });
}

class OrderDeliveryInitial extends OrderDeliveryState {
  OrderDeliveryInitial({required super.orderId})
      : super(
            quotes: null,
            selectedDeliveryType: null,
            origin: null,
            destination: null);
}

class OrderDeliveryLoading extends OrderDeliveryState {
  OrderDeliveryLoading({
    required super.orderId,
    super.quotes,
    super.selectedDeliveryType,
    super.origin,
    super.destination,
  });
}

class OrderDeliveryLoaded extends OrderDeliveryState {
  OrderDeliveryLoaded({
    required super.orderId,
    required super.quotes,
    super.selectedDeliveryType,
    required super.origin,
    required super.destination,
  });
}

class OrderDeliverySuccess extends OrderDeliveryState {
  final String message;

  OrderDeliverySuccess({
    required super.orderId,
    required this.message,
    super.quotes,
    super.selectedDeliveryType,
    super.origin,
    super.destination,
  });
}

class OrderDeliveryError extends OrderDeliveryState {
  final String error;

  OrderDeliveryError({
    required super.orderId,
    required this.error,
    super.quotes,
    super.selectedDeliveryType,
    super.origin,
    super.destination,
  });
}

class OrderDeliveryCubit extends Cubit<OrderDeliveryState> {
  final OrderDeliveryRepository repository = getIt<OrderDeliveryRepository>();

  OrderDeliveryCubit(String orderId)
      : super(OrderDeliveryInitial(orderId: orderId));

  Future<void> fetchDeliveryQuotes() async {
    emit(OrderDeliveryLoading(
      orderId: state.orderId,
      quotes: state.quotes,
      selectedDeliveryType: state.selectedDeliveryType,
      origin: state.origin,
      destination: state.destination,
    ));
    try {
      final result = await repository.getDeliveryQuotes(state.orderId);
      result.fold(
        (error) => emit(OrderDeliveryError(
          orderId: state.orderId,
          error: error.message ?? 'Error fetching delivery quotes',
          quotes: state.quotes,
          selectedDeliveryType: state.selectedDeliveryType,
          origin: state.origin,
          destination: state.destination,
        )),
        (data) => emit(OrderDeliveryLoaded(
          orderId: state.orderId,
          quotes: data['quotes'] as Map<String, DeliveryQuote>,
          selectedDeliveryType: state.selectedDeliveryType,
          origin: data['origin'] as String,
          destination: data['destination'] as String,
        )),
      );
    } catch (e) {
      emit(OrderDeliveryError(
        orderId: state.orderId,
        error: e.toString(),
        quotes: state.quotes,
        selectedDeliveryType: state.selectedDeliveryType,
        origin: state.origin,
        destination: state.destination,
      ));
    }
  }

  void selectDeliveryType(String deliveryType) {
    emit(OrderDeliveryLoaded(
      orderId: state.orderId,
      quotes: state.quotes ?? {},
      selectedDeliveryType: deliveryType,
      origin: state.origin,
      destination: state.destination,
    ));
  }

  Future<void> updateDeliveryType() async {
    if (state.selectedDeliveryType == null || state.quotes == null) return;

    emit(OrderDeliveryLoading(
      orderId: state.orderId,
      quotes: state.quotes,
      selectedDeliveryType: state.selectedDeliveryType,
      origin: state.origin,
      destination: state.destination,
    ));
    try {
      final result = await repository.updateDeliveryType(
        orderId: state.orderId,
        deliveryType: state.selectedDeliveryType!,
      );
      result.fold(
        (error) => emit(OrderDeliveryError(
          orderId: state.orderId,
          error: error.message ?? 'Error updating delivery type',
          quotes: state.quotes,
          selectedDeliveryType: state.selectedDeliveryType,
          origin: state.origin,
          destination: state.destination,
        )),
        (message) => emit(OrderDeliverySuccess(
          orderId: state.orderId,
          message: message,
          quotes: state.quotes,
          selectedDeliveryType: state.selectedDeliveryType,
          origin: state.origin,
          destination: state.destination,
        )),
      );
    } catch (e) {
      emit(OrderDeliveryError(
        orderId: state.orderId,
        error: e.toString(),
        quotes: state.quotes,
        selectedDeliveryType: state.selectedDeliveryType,
        origin: state.origin,
        destination: state.destination,
      ));
    }
  }
}
