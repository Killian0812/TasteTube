import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart' as fpdart;
import 'package:taste_tube/api.dart';
import 'package:taste_tube/common/constant.dart';
import 'package:taste_tube/common/error.dart';
import 'package:taste_tube/global_data/order/order.dart';
import 'package:taste_tube/utils/user_data.util.dart';

class OrderRepository {
  final Dio http;

  OrderRepository({required this.http});

  Future<fpdart.Either<ApiError, List<Order>>> getOrders() async {
    try {
      final String endpoint =
          UserDataUtil.getUserRole() == AccountType.restaurant.value()
              ? Api.shopOrderApi
              : Api.customerOrderApi;
      final response = await http.get(endpoint);
      final List<dynamic> data = response.data;
      final orders = data.map((json) => Order.fromJson(json)).toList();
      return fpdart.Right(orders);
    } on DioException catch (e) {
      return fpdart.Left(ApiError.fromDioException(e));
    } catch (e) {
      return fpdart.Left(ApiError(500, e.toString()));
    }
  }

  Future<fpdart.Either<ApiError, String>> createOrder({
    required List<String> selectedCartItems,
    required String addressId,
    required String paymentMethod,
    required String notes,
  }) async {
    try {
      final response = await http.post(Api.orderApi, data: {
        'selectedCartItems': selectedCartItems,
        'addressId': addressId,
        'paymentMethod': paymentMethod,
        'notes': notes,
      });
      return fpdart.Right(response.data['message']);
    } on DioException catch (e) {
      return fpdart.Left(ApiError.fromDioException(e));
    } catch (e) {
      return fpdart.Left(ApiError(500, e.toString()));
    }
  }
}
