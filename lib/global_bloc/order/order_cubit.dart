import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/global_data/order/cart.dart';
import 'package:taste_tube/global_data/product/product.dart';
import 'package:taste_tube/global_repo/order_repo.dart';
import 'package:taste_tube/injection.dart';

abstract class OrderState {
  final Cart cart;
  final String? message;

  const OrderState(this.cart, {this.message});
}

class OrderInitial extends OrderState {
  OrderInitial()
      : super(Cart(
          id: "",
          userId: "",
          items: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
}

class OrderLoading extends OrderState {
  const OrderLoading(super.cart);
}

class OrderLoaded extends OrderState {
  const OrderLoaded(super.cart);
}

class OrderError extends OrderState {
  final String error;

  const OrderError(super.cart, this.error) : super(message: error);
}

class OrderCubit extends Cubit<OrderState> {
  final OrderRepository orderRepository;

  OrderCubit()
      : orderRepository = getIt<OrderRepository>(),
        super(OrderInitial());

  Future<void> getCart() async {
    emit(OrderLoading(state.cart));
    try {
      final result = await orderRepository.getCart();
      result.fold(
        (error) => emit(OrderError(
          state.cart,
          error.message ?? 'Error searching products',
        )),
        (cart) => emit(OrderLoaded(cart)),
      );
    } catch (e) {
      emit(OrderError(state.cart, e.toString()));
    }
  }

  Future<void> addToCart(Product product, int quantity) async {
    emit(OrderLoading(state.cart));
    try {
      final result = await orderRepository.addToCart(product, quantity);
      result.fold(
        (error) => emit(OrderError(
          state.cart,
          error.message ?? 'Error searching products',
        )),
        (item) {
          final updatedCart = state.cart.clone();
          int index =
              updatedCart.items.indexWhere((e) => e.product.id == product.id);
          if (index == -1) {
            updatedCart.items.add(item);
          } else {
            updatedCart.items[index] = item;
          }
          emit(OrderLoaded(updatedCart));
        },
      );
    } catch (e) {
      emit(OrderError(state.cart, e.toString()));
    }
  }

  Future<void> removeFromCart(CartItem item) async {
    emit(OrderLoading(state.cart));
    try {
      final result = await orderRepository.removeFromCart(item);
      result.fold(
        (error) => emit(OrderError(
          state.cart,
          error.message ?? 'Error searching products',
        )),
        (success) {
          final updatedCart = state.cart.clone();
          updatedCart.items.removeWhere((e) => e.id == item.id);
          emit(OrderLoaded(updatedCart));
        },
      );
    } catch (e) {
      emit(OrderError(state.cart, e.toString()));
    }
  }
}
