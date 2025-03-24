import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:taste_tube/api.dart';
import 'package:taste_tube/common/error.dart';
import 'package:taste_tube/global_data/order/address.dart';
import 'package:taste_tube/global_data/order/cart.dart';
import 'package:taste_tube/global_data/order/order.dart';
import 'package:taste_tube/global_data/product/product.dart';

class CartRepository {
  final Dio http;

  CartRepository({required this.http});

  Future<Either<ApiError, Cart>> getCart() async {
    try {
      final response = await http.get(Api.cartApi);
      final cart = Cart.fromJson(response.data['cart']);
      return Right(cart);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }

  Future<Either<ApiError, CartItem>> addToCart(
      Product product, int quantity) async {
    try {
      final response = await http.post(Api.addCartApi, data: {
        'productId': product.id,
        'quantity': quantity,
      });
      final cartItem = CartItem.fromJson(response.data['cartItem']);
      return Right(cartItem);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }

  Future<Either<ApiError, bool>> removeFromCart(CartItem item) async {
    try {
      await http.delete(Api.cartApi, data: {'cartItemId': item.id});
      return const Right(true);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }

  Future<Either<ApiError, CartItem>> updateItemQuantity(
      CartItem item, int quantity) async {
    try {
      final response = await http.post(Api.updateCartApi, data: {
        'cartItemId': item.id,
        'quantity': quantity,
      });
      final cartItem = CartItem.fromJson(response.data['cartItem']);
      return Right(cartItem);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }

  Future<Either<ApiError, List<OrderSummary>>> getOrderSummary(
      List<String> selectedItems, Address address) async {
    try {
      final response = await http.post(Api.orderSummary, data: {
        'selectedItems': selectedItems,
        'address': address.toJson(),
      });

      final orderSummaryList = (response.data['orderSummary'] as List<dynamic>)
          .map((item) => OrderSummary.fromJson(item))
          .toList();
      return Right(orderSummaryList);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }
}
