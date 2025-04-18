import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/global_data/discount/discount.dart';
import 'package:taste_tube/global_data/order/address.dart';
import 'package:taste_tube/global_data/order/cart.dart';
import 'package:taste_tube/global_data/order/order.dart';
import 'package:taste_tube/global_data/product/product.dart';
import 'package:taste_tube/global_repo/cart_repo.dart';
import 'package:taste_tube/core/injection.dart';

abstract class CartState {
  final Cart cart;
  final String? message;
  final List<String> selectedItems;
  final List<OrderSummary> orderSummary;
  final List<Discount> appliedDiscounts;
  final Address? address;

  const CartState({
    required this.cart,
    required this.selectedItems,
    required this.orderSummary,
    required this.appliedDiscounts,
    this.address,
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
          orderSummary: [],
          appliedDiscounts: [],
          address: null,
        );
}

class CartLoading extends CartState {
  const CartLoading(
    Cart cart,
    List<String> selectedItems,
    List<OrderSummary> orderSummary,
    List<Discount> appliedDiscounts,
    Address? address,
  ) : super(
          cart: cart,
          selectedItems: selectedItems,
          orderSummary: orderSummary,
          appliedDiscounts: appliedDiscounts,
          address: address,
        );
}

class CartLoaded extends CartState {
  const CartLoaded(
    Cart cart,
    List<String> selectedItems,
    List<OrderSummary> orderSummary,
    List<Discount> appliedDiscounts,
    Address? address,
  ) : super(
          cart: cart,
          selectedItems: selectedItems,
          orderSummary: orderSummary,
          appliedDiscounts: appliedDiscounts,
          address: address,
        );
}

class CartSuccess extends CartState {
  final String success;

  const CartSuccess(
    Cart cart,
    List<String> selectedItems,
    List<OrderSummary> orderSummary,
    List<Discount> appliedDiscounts,
    Address? address,
    this.success,
  ) : super(
          cart: cart,
          selectedItems: selectedItems,
          orderSummary: orderSummary,
          appliedDiscounts: appliedDiscounts,
          address: address,
          message: success,
        );
}

class CartError extends CartState {
  final String error;

  const CartError(
    Cart cart,
    List<String> selectedItems,
    List<OrderSummary> orderSummary,
    List<Discount> appliedDiscounts,
    Address? address,
    this.error,
  ) : super(
          cart: cart,
          selectedItems: selectedItems,
          orderSummary: orderSummary,
          appliedDiscounts: appliedDiscounts,
          address: address,
          message: error,
        );
}

class CartSelectItemUpdated extends CartState {
  final List<String> updateItemList;

  const CartSelectItemUpdated(
    Cart cart,
    List<OrderSummary> orderSummary,
    this.updateItemList,
    List<Discount> appliedDiscounts,
    Address? address,
  ) : super(
          cart: cart,
          orderSummary: orderSummary,
          selectedItems: updateItemList,
          appliedDiscounts: appliedDiscounts,
          address: address,
        );
}

class AddedToCartAndReadyToPay extends CartState {
  final List<String> updateItemList;

  const AddedToCartAndReadyToPay(
    Cart cart,
    List<OrderSummary> orderSummary,
    this.updateItemList,
    List<Discount> appliedDiscounts,
    Address? address,
  ) : super(
          cart: cart,
          orderSummary: orderSummary,
          selectedItems: updateItemList,
          appliedDiscounts: appliedDiscounts,
          address: address,
        );
}

class CartCubit extends Cubit<CartState> {
  final CartRepository repository = getIt<CartRepository>();

  CartCubit() : super(CartInitial());

  Future<void> getCart() async {
    emit(CartLoading(state.cart, state.selectedItems, state.orderSummary,
        state.appliedDiscounts, state.address));
    try {
      final result = await repository.getCart();
      result.fold(
          (error) => emit(CartError(
                state.cart,
                state.selectedItems,
                state.orderSummary,
                [],
                state.address,
                error.message ?? 'Error fetching cart',
              )), (cart) {
        final updatedSelectedItems = state.selectedItems
            .where((t) => cart.items.any((e) => e.id == t))
            .toList();
        emit(CartLoaded(
          cart,
          updatedSelectedItems,
          state.orderSummary,
          [],
          state.address,
        ));
      });
    } catch (e) {
      emit(CartError(
        state.cart,
        state.selectedItems,
        state.orderSummary,
        [],
        state.address,
        e.toString(),
      ));
    }
  }

  Future<void> updateOrderAddressOrDiscount(
      {Address? address, List<Discount>? discounts, String? shopId}) async {
    // Update address if provided, otherwise keep existing
    final updatedAddress = address ?? state.address;
    if (updatedAddress == null) return;

    // Replace existing discounts for the shopId if provided, otherwise keep existing
    final updatedDiscounts = discounts != null
        ? [
            ...state.appliedDiscounts.where((e) => e.shopId != shopId),
            ...discounts
          ]
        : state.appliedDiscounts;

    final orderSummaries = await repository.getOrderSummary(
      state.selectedItems,
      address: updatedAddress,
      discounts: updatedDiscounts,
    );
    orderSummaries.fold(
      (error) => emit(CartError(
        state.cart,
        state.selectedItems,
        state.orderSummary,
        state.appliedDiscounts,
        state.address,
        error.message ?? 'Error fetching order summary',
      )),
      (orderSummaryList) {
        emit(CartLoaded(
          state.cart,
          state.selectedItems,
          orderSummaryList,
          updatedDiscounts,
          updatedAddress,
        ));
      },
    );
  }

  Future<void> addToCart(Product product, int quantity) async {
    emit(CartLoading(state.cart, state.selectedItems, state.orderSummary,
        state.appliedDiscounts, state.address));
    try {
      final result = await repository.addToCart(product, quantity);
      result.fold(
        (error) => emit(CartError(
          state.cart,
          state.selectedItems,
          state.orderSummary,
          state.appliedDiscounts,
          state.address,
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
          emit(CartSuccess(
            updatedCart,
            state.selectedItems,
            state.orderSummary,
            state.appliedDiscounts,
            state.address,
            "Added to cart",
          ));
        },
      );
    } catch (e) {
      emit(CartError(
        state.cart,
        state.selectedItems,
        state.orderSummary,
        state.appliedDiscounts,
        state.address,
        e.toString(),
      ));
    }
  }

  Future<void> removeFromCart(CartItem item) async {
    emit(CartLoading(state.cart, state.selectedItems, state.orderSummary,
        state.appliedDiscounts, state.address));
    try {
      final result = await repository.removeFromCart(item);
      result.fold(
        (error) => emit(CartError(
          state.cart,
          state.selectedItems,
          state.orderSummary,
          state.appliedDiscounts,
          state.address,
          error.message ?? 'Error removing cart item',
        )),
        (success) {
          final updatedCart = state.cart.clone();
          updatedCart.items.removeWhere((e) => e.id == item.id);
          final updatedSelectedItems = [...state.selectedItems];
          if (updatedSelectedItems.contains(item.id)) {
            updatedSelectedItems.removeWhere((e) => e == item.id);
          }
          emit(CartLoaded(
            updatedCart,
            updatedSelectedItems,
            state.orderSummary,
            state.appliedDiscounts,
            state.address,
          ));
        },
      );
    } catch (e) {
      emit(CartError(
        state.cart,
        state.selectedItems,
        state.orderSummary,
        state.appliedDiscounts,
        state.address,
        e.toString(),
      ));
    }
  }

  Future<void> updateItemQuantity(CartItem item, int quantity) async {
    emit(CartLoading(state.cart, state.selectedItems, state.orderSummary,
        state.appliedDiscounts, state.address));
    try {
      final result = await repository.updateItemQuantity(item, quantity);
      result.fold(
        (error) => emit(CartError(
          state.cart,
          state.selectedItems,
          state.orderSummary,
          state.appliedDiscounts,
          state.address,
          error.message ?? 'Error updating cart',
        )),
        (updatedItem) {
          final updatedCart = state.cart.clone();
          final index = updatedCart.items.indexWhere((e) => e.id == item.id);
          updatedCart.items[index] = updatedItem;
          emit(CartLoaded(
            updatedCart,
            state.selectedItems,
            state.orderSummary,
            state.appliedDiscounts,
            state.address,
          ));
        },
      );
    } catch (e) {
      emit(CartError(
        state.cart,
        state.selectedItems,
        state.orderSummary,
        state.appliedDiscounts,
        state.address,
        e.toString(),
      ));
    }
  }

  Future<void> selectOrUnselectCartItem(CartItem item) async {
    final updateItemList = [...state.selectedItems];
    if (updateItemList.contains(item.id)) {
      updateItemList.removeWhere((e) => e == item.id);
    } else {
      updateItemList.add(item.id);
    }
    emit(CartSelectItemUpdated(
      state.cart,
      [],
      updateItemList,
      state.appliedDiscounts,
      state.address,
    ));
  }

  Future<void> selectAllItemInSingleShop(List<CartItem> items) async {
    final updateItemList = [...state.selectedItems];
    for (var item in items) {
      if (!updateItemList.contains(item.id)) updateItemList.add(item.id);
    }
    emit(CartSelectItemUpdated(state.cart, state.orderSummary, updateItemList,
        state.appliedDiscounts, state.address));
  }

  Future<void> addToCartAndPayImmediate(Product product, int quantity) async {
    emit(CartLoading(
      state.cart,
      state.selectedItems,
      state.orderSummary,
      state.appliedDiscounts,
      state.address,
    ));
    try {
      final result = await repository.addToCart(product, quantity);
      result.fold(
        (error) => emit(CartError(
          state.cart,
          state.selectedItems,
          state.orderSummary,
          state.appliedDiscounts,
          state.address,
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
          emit(AddedToCartAndReadyToPay(
            updatedCart,
            state.orderSummary,
            updateItemList,
            state.appliedDiscounts,
            state.address,
          ));
        },
      );
    } catch (e) {
      emit(CartError(
        state.cart,
        state.selectedItems,
        state.orderSummary,
        state.appliedDiscounts,
        state.address,
        e.toString(),
      ));
    }
  }
}
