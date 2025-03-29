import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart' as fpdart;
import 'package:taste_tube/api.dart';
import 'package:taste_tube/common/error.dart';
import 'package:taste_tube/feature/shop/data/delivery_quote.dart';

class OrderDeliveryRepository {
  final Dio http;

  OrderDeliveryRepository({required this.http});

  Future<fpdart.Either<ApiError, Map<String, dynamic>>> getDeliveryQuotes(
      String orderId) async {
    try {
      final response = await http.get(
        Api.orderDeliveryApi.replaceFirst(':id', orderId),
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

  Future<fpdart.Either<ApiError, String>> updateDeliveryType({
    required String orderId,
    required String deliveryType,
  }) async {
    try {
      final response = await http.put(
        '${Api.orderDeliveryApi.replaceFirst(':id', orderId)}/delivery',
        data: {'deliveryType': deliveryType},
      );
      return fpdart.Right(response.data['message']);
    } on DioException catch (e) {
      return fpdart.Left(ApiError.fromDioException(e));
    } catch (e) {
      return fpdart.Left(ApiError(500, e.toString()));
    }
  }
}
