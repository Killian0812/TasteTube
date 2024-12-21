import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/feature/shop/domain/order_repo.dart';
import 'package:taste_tube/global_data/order/order.dart';
import 'package:taste_tube/injection.dart';

abstract class OrderState {
  final List<Order> orders;

  const OrderState({required this.orders});
}

class OrderInitial extends OrderState {
  OrderInitial() : super(orders: []);
}

class OrderLoading extends OrderState {
  const OrderLoading(List<Order> orders) : super(orders: orders);
}

class OrderLoaded extends OrderState {
  const OrderLoaded(List<Order> orders) : super(orders: orders);
}

class OrderSuccess extends OrderState {
  final String success;

  const OrderSuccess(List<Order> orders, this.success) : super(orders: orders);
}

class OrderError extends OrderState {
  final String error;

  const OrderError(List<Order> orders, this.error) : super(orders: orders);
}

class OrderCubit extends Cubit<OrderState> {
  final OrderRepository repository = getIt<OrderRepository>();

  OrderCubit() : super(OrderInitial());

  Future<void> getOrders() async {
    emit(OrderLoading(state.orders));
    try {
      final result = await repository.getOrders();
      result.fold(
        (error) => emit(OrderError(
          state.orders,
          error.message ?? 'Error fetching orders',
        )),
        (orders) {
          orders.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          emit(
            OrderLoaded(orders),
          );
        },
      );
    } catch (e) {
      emit(OrderError(state.orders, e.toString()));
    }
  }

  Future<void> createOrder(
    List<String> selectedCartItems,
    String addressId,
    String paymentMethod,
    String notes,
  ) async {
    emit(OrderLoading(state.orders));
    try {
      final result = await repository.createOrder(
        selectedCartItems: selectedCartItems,
        addressId: addressId,
        paymentMethod: paymentMethod,
        notes: notes,
      );
      result.fold(
        (error) => emit(OrderError(
          state.orders,
          error.message ?? 'Error creating new order',
        )),
        (successMsg) {
          emit(OrderSuccess(state.orders, successMsg));
        },
      );
    } catch (e) {
      emit(OrderError(state.orders, e.toString()));
    }
  }

  Future<void> updateOrderStatus(
    String id,
    String? newStatus,
  ) async {
    if (newStatus == null) return;
    try {
      final result =
          await repository.updateOrderStatus(id: id, newStatus: newStatus);
      result.fold(
        (error) => emit(OrderError(
          state.orders,
          error.message ?? 'Error creating new order',
        )),
        (updatedOrder) {
          final index = state.orders.indexWhere((order) => order.id == id);
          state.orders[index] = updatedOrder;
          emit(OrderLoaded(state.orders));
        },
      );
    } catch (e) {
      emit(OrderError(state.orders, e.toString()));
    }
  }
}
