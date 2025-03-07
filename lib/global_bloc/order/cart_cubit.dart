import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/global_data/order/cart.dart';
import 'package:taste_tube/global_data/product/product.dart';
import 'package:taste_tube/global_repo/cart_repo.dart';
import 'package:taste_tube/injection.dart';

abstract class CartState {
  final Cart cart;
  final String? message;
  final List<String> selectedItems;

  const CartState({
    required this.cart,
    required this.selectedItems,
    this.message,
  });
}

class CartInitial extends CartState {
  CartInitial()
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

class CartLoading extends CartState {
  const CartLoading(Cart cart, List<String> selectedItems)
      : super(cart: cart, selectedItems: selectedItems);
}

class CartLoaded extends CartState {
  const CartLoaded(Cart cart, List<String> selectedItems)
      : super(cart: cart, selectedItems: selectedItems);
}

class CartSuccess extends CartState {
  final String success;

  const CartSuccess(Cart cart, List<String> selectedItems, this.success)
      : super(cart: cart, selectedItems: selectedItems, message: success);
}

class CartError extends CartState {
  final String error;

  const CartError(Cart cart, List<String> selectedItems, this.error)
      : super(cart: cart, selectedItems: selectedItems, message: error);
}

class CartSelectItemUpdated extends CartState {
  final List<String> updateItemList;

  const CartSelectItemUpdated(Cart cart, this.updateItemList)
      : super(
          cart: cart,
          selectedItems: updateItemList,
        );
}

class AddedToCartAndReadyToPay extends CartState {
  final List<String> updateItemList;

  const AddedToCartAndReadyToPay(Cart cart, this.updateItemList)
      : super(
          cart: cart,
          selectedItems: updateItemList,
        );
}

class CartCubit extends Cubit<CartState> {
  final CartRepository repository = getIt<CartRepository>();

  CartCubit() : super(CartInitial());

  Future<void> getCart() async {
    emit(CartLoading(state.cart, state.selectedItems));
    try {
      final result = await repository.getCart();
      result.fold(
          (error) => emit(CartError(
                state.cart,
                state.selectedItems,
                error.message ?? 'Error fetching cart',
              )), (cart) {
        final updatedSelectedItems = state.selectedItems
            .where((t) => cart.items.any((e) => e.id == t))
            .toList();
        emit(CartLoaded(cart, updatedSelectedItems));
      });
    } catch (e) {
      emit(CartError(state.cart, state.selectedItems, e.toString()));
    }
  }

  Future<void> addToCart(Product product, int quantity) async {
    emit(CartLoading(state.cart, state.selectedItems));
    try {
      final result = await repository.addToCart(product, quantity);
      result.fold(
        (error) => emit(CartError(
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
          emit(CartSuccess(updatedCart, state.selectedItems, "Added to cart"));
        },
      );
    } catch (e) {
      emit(CartError(state.cart, state.selectedItems, e.toString()));
    }
  }

  Future<void> removeFromCart(CartItem item) async {
    emit(CartLoading(state.cart, state.selectedItems));
    try {
      final result = await repository.removeFromCart(item);
      result.fold(
        (error) => emit(CartError(
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
          emit(CartLoaded(updatedCart, updatedSelectedItems));
        },
      );
    } catch (e) {
      emit(CartError(state.cart, state.selectedItems, e.toString()));
    }
  }

  Future<void> updateItemQuantity(CartItem item, int quantity) async {
    emit(CartLoading(state.cart, state.selectedItems));
    try {
      final result = await repository.updateItemQuantity(item, quantity);
      result.fold(
        (error) => emit(CartError(
          state.cart,
          state.selectedItems,
          error.message ?? 'Error updating cart',
        )),
        (updatedItem) {
          final updatedCart = state.cart.clone();
          final index = updatedCart.items.indexWhere((e) => e.id == item.id);
          updatedCart.items[index] = updatedItem;
          emit(CartLoaded(updatedCart, state.selectedItems));
        },
      );
    } catch (e) {
      emit(CartError(state.cart, state.selectedItems, e.toString()));
    }
  }

  Future<void> selectOrUnselectCartItem(CartItem item) async {
    final updateItemList = [...state.selectedItems];
    if (updateItemList.contains(item.id)) {
      updateItemList.removeWhere((e) => e == item.id);
    } else {
      updateItemList.add(item.id);
    }
    emit(CartSelectItemUpdated(state.cart, updateItemList));
  }

  Future<void> selectAllItemInSingleShop(List<CartItem> items) async {
    final updateItemList = [...state.selectedItems];
    for (var item in items) {
      if (!updateItemList.contains(item.id)) updateItemList.add(item.id);
    }
    emit(CartSelectItemUpdated(state.cart, updateItemList));
  }

  Future<void> addToCartAndPayImmediate(Product product, int quantity) async {
    emit(CartLoading(state.cart, state.selectedItems));
    try {
      final result = await repository.addToCart(product, quantity);
      result.fold(
        (error) => emit(CartError(
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
          final updateItemList = [item.id];
          emit(AddedToCartAndReadyToPay(updatedCart, updateItemList));
        },
      );
    } catch (e) {
      emit(CartError(state.cart, state.selectedItems, e.toString()));
    }
  }
}
