import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/global_data/order/cart.dart';
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

  // Future<void> addToCart(Product product) async {
  //   emit(OrderLoading(state.cart));
  //   try {
  //     final Either<ApiError, List<Product>> result =
  //         await orderRepository.(keyword);
  //     result.fold(
  //       (error) => emit(OrderError(
  //         state.products,
  //         error.message ?? 'Error searching products',
  //       )),
  //       (products) => emit(OrderLoaded(products)),
  //     );
  //   } catch (e) {
  //     emit(OrderError(state.products, e.toString()));
  //   }
  // }
}
