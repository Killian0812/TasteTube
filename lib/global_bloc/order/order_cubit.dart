import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:taste_tube/common/error.dart';
import 'package:taste_tube/global_data/product/product.dart';
import 'package:taste_tube/global_repo/order_repo.dart';
import 'package:taste_tube/injection.dart';

abstract class OrderState {
  final List<Product> products;
  final String? message;

  const OrderState(this.products, {this.message});
}

class OrderInitial extends OrderState {
  const OrderInitial() : super(const []);
}

class OrderLoading extends OrderState {
  const OrderLoading(super.products);
}

class OrderLoaded extends OrderState {
  const OrderLoaded(super.products);
}

class OrderError extends OrderState {
  final String error;

  const OrderError(super.products, this.error) : super(message: error);
}

class OrderCubit extends Cubit<OrderState> {
  final OrderRepository orderRepository;

  OrderCubit()
      : orderRepository = getIt<OrderRepository>(),
        super(const OrderInitial());

  // Future<void> searchProducts(String keyword) async {
  //   emit(OrderLoading(state.products));
  //   try {
  //     final Either<ApiError, List<Product>> result =
  //         await orderRepository.searchProducts(keyword);
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
