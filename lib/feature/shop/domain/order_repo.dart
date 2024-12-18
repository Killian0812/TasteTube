import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart' as fpdart;
import 'package:taste_tube/api.dart';
import 'package:taste_tube/common/error.dart';
import 'package:taste_tube/global_data/order/order.dart';
import 'package:taste_tube/global_data/product/product.dart';

class OrderRepository {
  final Dio http;

  OrderRepository({required this.http});

  Future<fpdart.Either<ApiError, List<Order>>> getOrders() async {
    try {
      final response = await http.get(Api.customerOrderApi);
      final List<dynamic> data = response.data;
      final orders = data.map((json) => Order.fromJson(json)).toList();
      return fpdart.Right(orders);
    } on DioException catch (e) {
      return fpdart.Left(ApiError.fromDioException(e));
    } catch (e) {
      return fpdart.Left(ApiError(500, e.toString()));
    }
  }

  Future<fpdart.Either<ApiError, void>> createOrder({
    required List<String> selectedCartItems,
    required String addressId,
    required String paymentMethod,
    required String notes,
  }) async {
    try {
      final response = await http.get(Api.shopSearchApi, data: {
        'selectedCartItems': selectedCartItems,
        'addressId': addressId,
        'paymentMethod': paymentMethod,
        'notes': notes,
      });
      final List<dynamic> data = response.data;
      final products = data.map((json) => Product.fromJson(json)).toList();
      return const fpdart.Right(null);
    } on DioException catch (e) {
      return fpdart.Left(ApiError.fromDioException(e));
    } catch (e) {
      return fpdart.Left(ApiError(500, e.toString()));
    }
  }
}
