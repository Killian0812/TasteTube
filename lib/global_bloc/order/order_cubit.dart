import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/global_data/order/cart.dart';
import 'package:taste_tube/global_data/product/product.dart';
import 'package:taste_tube/global_repo/order_repo.dart';
import 'package:taste_tube/injection.dart';

abstract class OrderState {
  final Cart cart;
  final String? message;
  final List<String> selectedItems;

  const OrderState({
    required this.cart,
    required this.selectedItems,
    this.message,
  });
}

class OrderInitial extends OrderState {
  OrderInitial()
      : super(
          cart: Cart(
              id: "",
              userId: "",
              items: [],
              createdAt: DateTime.now(),
              updatedAt: DateTime.now()),
          selectedItems: [],
        );
}

class OrderLoading extends OrderState {
  const OrderLoading(Cart cart, List<String> selectedItems)
      : super(cart: cart, selectedItems: selectedItems);
}

class OrderLoaded extends OrderState {
  const OrderLoaded(Cart cart, List<String> selectedItems)
      : super(cart: cart, selectedItems: selectedItems);
}

class OrderSuccess extends OrderState {
  final String success;

  const OrderSuccess(Cart cart, List<String> selectedItems, this.success)
      : super(cart: cart, selectedItems: selectedItems, message: success);
}

class OrderError extends OrderState {
  final String error;

  const OrderError(Cart cart, List<String> selectedItems, this.error)
      : super(cart: cart, selectedItems: selectedItems, message: error);
}

class OrderSelectItemUpdated extends OrderState {
  final List<String> updateItemList;

  const OrderSelectItemUpdated(Cart cart, this.updateItemList)
      : super(
          cart: cart,
          selectedItems: updateItemList,
        );
}

class OrderCubit extends Cubit<OrderState> {
  final OrderRepository orderRepository;

  OrderCubit()
      : orderRepository = getIt<OrderRepository>(),
        super(OrderInitial());

  Future<void> getCart() async {
    emit(OrderLoading(state.cart, state.selectedItems));
    try {
      final result = await orderRepository.getCart();
      result.fold(
          (error) => emit(OrderError(
                state.cart,
                state.selectedItems,
                error.message ?? 'Error fetching cart',
              )), (cart) {
        final updatedSelectedItems = state.selectedItems
            .where((t) => cart.items.any((e) => e.id == t))
            .toList();
        emit(OrderLoaded(cart, updatedSelectedItems));
      });
    } catch (e) {
      emit(OrderError(state.cart, state.selectedItems, e.toString()));
    }
  }

  Future<void> addToCart(Product product, int quantity) async {
    emit(OrderLoading(state.cart, state.selectedItems));
    try {
      final result = await orderRepository.addToCart(product, quantity);
      result.fold(
        (error) => emit(OrderError(
          state.cart,
          state.selectedItems,
          error.message ?? 'Error add item to cart',
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
          emit(OrderSuccess(updatedCart, state.selectedItems, "Added to cart"));
        },
      );
    } catch (e) {
      emit(OrderError(state.cart, state.selectedItems, e.toString()));
    }
  }

  Future<void> removeFromCart(CartItem item) async {
    emit(OrderLoading(state.cart, state.selectedItems));
    try {
      final result = await orderRepository.removeFromCart(item);
      result.fold(
        (error) => emit(OrderError(
          state.cart,
          state.selectedItems,
          error.message ?? 'Error removing cart item',
        )),
        (success) {
          final updatedCart = state.cart.clone();
          updatedCart.items.removeWhere((e) => e.id == item.id);
          final updatedSelectedItems = [...state.selectedItems];
          if (updatedSelectedItems.contains(item.id)) {
            updatedSelectedItems.removeWhere((e) => e == item.id);
          }
          emit(OrderLoaded(updatedCart, updatedSelectedItems));
        },
      );
    } catch (e) {
      emit(OrderError(state.cart, state.selectedItems, e.toString()));
    }
  }

  Future<void> updateItemQuantity(CartItem item, int quantity) async {
    emit(OrderLoading(state.cart, state.selectedItems));
    try {
      final result = await orderRepository.updateItemQuantity(item, quantity);
      result.fold(
        (error) => emit(OrderError(
          state.cart,
          state.selectedItems,
          error.message ?? 'Error updating cart',
        )),
        (updatedItem) {
          final updatedCart = state.cart.clone();
          final index = updatedCart.items.indexWhere((e) => e.id == item.id);
          updatedCart.items[index] = updatedItem;
          emit(OrderLoaded(updatedCart, state.selectedItems));
        },
      );
    } catch (e) {
      emit(OrderError(state.cart, state.selectedItems, e.toString()));
    }
  }

  Future<void> selectOrUnselectCartItem(CartItem item) async {
    final updateItemList = [...state.selectedItems];
    if (updateItemList.contains(item.id)) {
      updateItemList.removeWhere((e) => e == item.id);
    } else {
      updateItemList.add(item.id);
    }
    emit(OrderSelectItemUpdated(state.cart, updateItemList));
  }

  Future<void> selectAllItemInSingleShop(List<CartItem> items) async {
    final updateItemList = [...state.selectedItems];
    for (var item in items) {
      if (!updateItemList.contains(item.id)) updateItemList.add(item.id);
    }
    emit(OrderSelectItemUpdated(state.cart, updateItemList));
  }
}
