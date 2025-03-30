import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart' as fpdart;
import 'package:taste_tube/api.dart';
import 'package:taste_tube/common/error.dart';
import 'package:taste_tube/feature/shop/data/delivery_data.dart';

class OrderDeliveryRepository {
  final Dio http;

  OrderDeliveryRepository({required this.http});

  Future<fpdart.Either<ApiError, OrderDelivery>> getOrderDelivery(
      String orderId) async {
    try {
      final response = await http.get(
        Api.orderDeliveryApi.replaceFirst(':orderId', orderId),
      );
      final orderDelivery =
          OrderDelivery.fromJson(response.data as Map<String, dynamic>);
      return fpdart.Right(orderDelivery);
    } on DioException catch (e) {
      return fpdart.Left(ApiError.fromDioException(e));
    } catch (e) {
      return fpdart.Left(ApiError(500, e.toString()));
    }
  }

  Future<fpdart.Either<ApiError, Map<String, dynamic>>> getDeliveryQuotes(
      String orderId) async {
    try {
      final response = await http.get(
        Api.orderDeliveryQuoteApi.replaceFirst(':orderId', orderId),
      );
      final data = response.data as Map<String, dynamic>;
      final quotes = {
        'selfDelivery': DeliveryQuote.fromJson(data['selfDeliveryQuote']),
        'grabDelivery': DeliveryQuote.fromJson(data['grabDeliveryQuote']),
      };
      return fpdart.Right({
        'quotes': quotes,
        'origin': data['origin'] as String,
        'destination': data['destination'] as String,
      });
    } on DioException catch (e) {
      return fpdart.Left(ApiError.fromDioException(e));
    } catch (e) {
      return fpdart.Left(ApiError(500, e.toString()));
    }
  }

  Future<fpdart.Either<ApiError, bool>> createOrderDelivery({
    required String orderId,
    required String deliveryType,
  }) async {
    try {
      await http.post(
        Api.orderDeliveryApi.replaceFirst(':orderId', orderId),
        queryParameters: {'deliveryType': deliveryType},
      );
      return fpdart.Right(true);
    } on DioException catch (e) {
      return fpdart.Left(ApiError.fromDioException(e));
    } catch (e) {
      return fpdart.Left(ApiError(500, e.toString()));
    }
  }

  Future<fpdart.Either<ApiError, bool>> updateSelfOrderDelivery({
    required String orderId,
    required String newStatus,
  }) async {
    try {
      await http.put(
        Api.orderDeliveryApi.replaceFirst(':orderId', orderId),
        queryParameters: {'newStatus': newStatus},
      );
      return fpdart.Right(true);
    } on DioException catch (e) {
      return fpdart.Left(ApiError.fromDioException(e));
    } catch (e) {
      return fpdart.Left(ApiError(500, e.toString()));
    }
  }
}
